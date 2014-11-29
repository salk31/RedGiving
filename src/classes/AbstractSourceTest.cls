public abstract class AbstractSourceTest {

  protected void upload(String content) {
    AttachmentUploadController controller = new AttachmentUploadController ();
    Blob bodyBlob = Blob.valueOf(content);
    controller.attachment.body = bodyBlob;

    controller.upload();
  }
  
  abstract String getPrefix();

  abstract void addPage(CsvBuilder csv, String id, String name);
  
  abstract void addFundraiser(CsvBuilder csv, String id, String familyName);
  
  abstract void addFundraiserEmailOk(CsvBuilder csv);
  
  abstract void addDonor(CsvBuilder csv, String id, String familyName);

  abstract void addAnonymousDonor(CsvBuilder csv);

  abstract void addDonorEmailOk(CsvBuilder csv);

  abstract void addDonation(CsvBuilder csv, String id);
  
  public void testSingle() {
    CsvBuilder csv = new CsvBuilder();
    addPage(csv, '123', 'Hello');
    addFundraiser(csv, 'abc', 'Smith');
    addDonor(csv, 'xyz', 'Jones');
    addDonation(csv, 'p123');
    csv.eol();
  
    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
  }
  
  public void testReImport() {
    
  }
  
  public void testDonorGiveTwice() {
    String pageTitle = 'SomePage';
    String donorLn = 'd' + Math.random();
    String fundraiserLn = 'f' + Math.random();

    CsvBuilder csv = new CsvBuilder();
    addPage(csv, '123', pageTitle);
    addFundraiser(csv, 'abc', fundraiserLn);
    addDonor(csv, 'xyz', donorLn);
    addDonation(csv, 'p123');
    csv.eol();
    
    addPage(csv, '123', pageTitle);
    addFundraiser(csv, 'abc', 'Smith');
    addDonor(csv, 'xyz', donorLn);
    addDonation(csv, 'p124');
    csv.eol();
    
    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
    
    List<Account> insertedAccounts = [SELECT Name, Website
                                      FROM Account WHERE Name = :pageTitle];
    System.assertEquals(1, insertedAccounts.size());
    Account page = insertedAccounts.get(0);
    
    List<Contact> insertedFundraisers = [SELECT LastName, Email, AccountId
                                        FROM Contact
                                        WHERE LastName = :fundraiserLn];
    System.assertEquals(1, insertedFundraisers.size());
    Contact fundraiser = insertedFundraisers.get(0);
    System.assertEquals(page.Id, fundraiser.AccountId);

    
    
    List<Contact> insertedDonors = [SELECT LastName, AccountId
                                    FROM Contact WHERE LastName = :donorLn];
    System.assertEquals(1, insertedDonors.size());
    Contact donor = insertedDonors.get(0);
    System.assertEquals(page.Id, donor.AccountId);
    
    List<Opportunity> insertedDonations = [SELECT Name, Gift_aid_eligible__c
                                      FROM Opportunity WHERE AccountId = :page.Id
                                      ORDER BY CloseDate];
    System.assertEquals(2, insertedDonations.size());
    Opportunity donation = insertedDonations.get(0);
    System.assertEquals(False, donation.Gift_aid_eligible__c);
    
    List<OpportunityContactRole> ocrs = [SELECT OpportunityId FROM OpportunityContactRole WHERE ContactId = :donor.Id];
    System.assertEquals(2, ocrs.size());
  }
  
  
  public void testImportDonationTwice() {
    String pageTitle = 'pn' + Math.random();
    String donorLn = 'd' + Math.random();
    String fundraiserLn = 'f' + Math.random();

    CsvBuilder csv = new CsvBuilder();
    addPage(csv, '2', pageTitle);
    addFundraiser(csv, '1fr', fundraiserLn);
    addDonor(csv, '3', donorLn);
    addDonation(csv, '4');
    csv.eol();

    Test.StartTest();
    upload(csv.build());
    
    // do it again
    upload(csv.build());
    Test.StopTest();
    
    List<Account> insertedAccounts = [SELECT Name
                                      FROM Account WHERE Name = :pageTitle];
    System.assertEquals(1, insertedAccounts.size());
    Account page = insertedAccounts.get(0);
    
    List<Contact> insertedFundraisers = [SELECT LastName, Email
                                        FROM Contact
                                        WHERE LastName = :fundraiserLn];
    System.assertEquals(1, insertedFundraisers.size());
    Contact fundraiser = insertedFundraisers.get(0);

    
    List<Contact> insertedDonors = [SELECT LastName
                                    FROM Contact WHERE LastName = :donorLn];
    System.assertEquals(1, insertedDonors.size());
    Contact donor = insertedDonors.get(0);
    
    // TODO __ System.assertEquals('JustGiving fundraiser', afil.npe5__Role__c);
    
    List<Opportunity> insertedDonations = [SELECT Name, Gift_aid_eligible__c
        FROM Opportunity
        WHERE RedGivingId__c= :getPrefix() + '_4'];
    System.assertEquals(1, insertedDonations.size());
    Opportunity donation = insertedDonations.get(0);
    System.assertEquals(False, donation.Gift_aid_eligible__c);
    
    List<OpportunityContactRole> ocrs = [SELECT ContactId 
        FROM OpportunityContactRole 
        WHERE OpportunityId = :donation.Id];
    System.assertEquals(1, ocrs.size());
  }
  
     
  public void testBulk() {
    CsvBuilder csv = new CsvBuilder();
    for (Integer i = 0; i < 2; i++) {
      addPage(csv, '2' + i, 'Test ' + i);
      addFundraiser(csv, '1' + i, 'Smith');
      addDonor(csv, '3' + i, 'Jones');
      addDonation(csv, '4' + i);
      csv.eol();
    }

    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
  }
  
  public void furtherContact(Boolean forFundraiser, Boolean forDonor) {
    CsvBuilder csv = new CsvBuilder();
    String donorLn = 'd' + Math.random();
    String fundraiserLn = 'f' + Math.random();

    addFundraiser(csv, '1', fundraiserLn);
      
    if (forFundraiser) {
      addFundraiserEmailOk(csv);
    }
    
    addPage(csv, '2', 'Test 1');
    addDonor(csv, '3', donorLn);

    if (forDonor) {
      addDonorEmailOk(csv);
    }
    
    addDonation(csv, '4');
    csv.eol();

    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
    
    List<Contact> insertedDonors = [SELECT HasOptedOutOfEmail
                                    FROM Contact WHERE LastName = :donorLn];
    System.assertEquals(!forDonor, insertedDonors.get(0).HasOptedOutOfEmail);
    
                                    
    List<Contact> insertedFundraisers = [SELECT HasOptedOutOfEmail
                                    FROM Contact WHERE LastName = :fundraiserLn];
    System.assertEquals(!forFundraiser, insertedFundraisers.get(0).HasOptedOutOfEmail); 
  }
  
  public void testEmailOkNeither() {
    furtherContact(False, False);
  }
  
  public void testEmailOkDonor() {
    furtherContact(False, True);
  }
  
  public void testEmailOkFundraiser() {
    furtherContact(True, False);
  }
  
  public void testEmailOkBoth() {
    furtherContact(True, True);
  }
  
  public void testAnonymousDonor() {
    CsvBuilder csv = new CsvBuilder();

    addPage(csv, '2', 'Test');
    addFundraiser(csv, '1', 'Smith');
    addAnonymousDonor(csv);
    addDonation(csv, '4');
    csv.eol();

    Test.StartTest();
    upload(csv.build());
    Test.StopTest();

    List<Contact> insertedFundraisers = [SELECT LastName
        FROM Contact];
    System.assertEquals(1, insertedFundraisers.size());
    System.assertEquals('Smith', insertedFundraisers[0].LastName);
  }
  
  // TODO __ test correct prefixes XX_D, XX_F, XX_ and XX_P
  // TODO __ explicit expectation of headings for detection and renaming
}