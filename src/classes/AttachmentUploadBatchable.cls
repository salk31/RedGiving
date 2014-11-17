global class AttachmentUploadBatchable implements Database.batchable<SSSCsvRow>, Database.Stateful { 
  private SSSCsvReader reader;
   
  private SourceAdapter sourceAdapter;

  global ImportStatus status;

  global AttachmentUploadBatchable(SSSCsvReader reader2) {
    this.reader = reader2;
    
    this.status = new ImportStatus();
  }

  global Iterable<SSSCsvRow> start(Database.BatchableContext info){ 
    return reader; 
  }

  private Contact getContact(String extId) {
    List<Contact> contacts =
        [SELECT Name FROM Contact WHERE Id IN (SELECT redspr__Contact__c FROM redspr__Contact_Mapping__c WHERE Name = :extId)];
    if (contacts.size() == 0) {
      return null;
    }
    return contacts.get(0);
  }
  
  private void addContact(Contact contact, String extId) {
    insert contact;
    
    redspr__Contact_Mapping__c cm = new redspr__Contact_Mapping__c();
    
    cm.redspr__Contact__c = contact.Id;
    cm.Name = extId;
    insert cm;
  }

  private void addContactInfo(Contact contact, SourceContactAdapter contactAdapter) {
    contact.HasOptedOutOfEmail = contactAdapter.hasOptedOutOfEmail();

    contact.DoNotCall = contactAdapter.isDoNotCall();
  }
 
  global void execute(Database.BatchableContext info, List<SSSCsvRow> scope){


    for (SSSCsvRow csv : scope) {
    try {
      status.rowInc();
      // XXX really do this every time, not sniff the CSV?
      if (sourceAdapter == null) {
        sourceAdapter = new SourceAdapterFactory().createInstance(csv);
       
      }
      sourceAdapter.init(csv.getReaderX());
      sourceAdapter.next(csv);
      
      if (!sourceAdapter.isValidRow()) {
        continue;
      }

      

      Account page = null;

      if (sourceAdapter.hasPage()) {
        String pageId = sourceAdapter.getPageId();
      

        List<Account> pages = [SELECT Name FROM Account WHERE Id IN (SELECT redspr__Account__c FROM redspr__Account_Mapping__c
                                     WHERE Name = :pageId)];
        if (pages.size() == 0) {
          page = new Account();
          page.Name = sourceAdapter.getPageTitle();
          page.Website = sourceAdapter.getPageUrl();
          insert page;
     
          redspr__Account_Mapping__c mapping = new redspr__Account_Mapping__c();
          mapping.Name = pageId;
          mapping.redspr__Account__c = page.Id;

          insert mapping;
          
          status.pageCountInc();
        } else {
          page = pages.get(0);
        }

        
        
      Contact fundraiser = null;
    
      if (page != null) {
        String fundraiserId = sourceAdapter.getFundraiserId();
        fundraiser = getContact(fundraiserId);
        if (fundraiser == null) {
          SourceContactAdapter fundraiserAdapter = sourceAdapter.getFundraiserAdapter();
          fundraiser = new Contact();
          fundraiser.AccountId = page.Id;
          fundraiserAdapter.updateContact(fundraiser);

          fundraiser.Title = sourceAdapter.getFundraiserRole();
          
          addContactInfo(fundraiser, fundraiserAdapter);
 
          addContact(fundraiser, fundraiserId);
          
          status.contactCountInc();
        }
      }
} // has page

      Contact donor = null;
      if (!sourceAdapter.isDonorAnonymous()) {
        String donorId = sourceAdapter.getDonorId();
        donor = getContact(donorId);
        if (donor == null) {
          SourceContactAdapter donorAdapter = sourceAdapter.getDonorAdapter();
          donor = new Contact();
          if (page != null) {
            donor.AccountId = page.Id;
          }
          donorAdapter.updateContact(donor);
            
          donor.Title = sourceAdapter.getDonorRole();
          
          addContactInfo(donor, donorAdapter);
          
          addContact(donor, donorId);
          
          status.contactCountInc();
        }
      }

      String donationId = sourceAdapter.getDonationId();
      List<Opportunity> donations =
          [SELECT Name FROM Opportunity WHERE redspr__RedGivingId__c = :donationId];
      if (donations.size() == 0) {
        Opportunity donation = sourceAdapter.createDonation();
        donation.redspr__RedGivingId__c = sourceAdapter.getDonationId();
        donation.redspr__Gift_aid_eligible__c = sourceAdapter.isGiftAidEligible();
        if (page != null) {
          donation.AccountId = page.Id;
        }

        insert donation;
      
        if (donor != null) {
          OpportunityContactRole thisRole = new OpportunityContactRole();
          thisRole.OpportunityId = donation.Id;
          thisRole.ContactId = donor.Id;
          thisRole.Role = sourceAdapter.getDonorRole();
          thisRole.isPrimary = true;
        
          insert thisRole;
        }
       
        status.donationCountInc();
      }
      } catch (Exception ex) {
         throw new ImportException('Xrow ' + csv.getRowNumber() + ' : ' + ex);
      }
    }
  }

  global void finish(Database.BatchableContext info){
    // TODO __ dump status so can go in results table? status.email(info);
  }
}