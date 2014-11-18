public class JustGivingAdapter implements SourceAdapter {

public class JGContactAdapter implements SourceContactAdapter {
    private SSSCsvRow csv;
    
    private String pfx;
    
    public JGContactAdapter(SSSCsvRow csv2, String pfx2) {
      this.csv = csv2;
      this.pfx = pfx2;
    }

    public Boolean isDoNotCall() {
      return false;
    }

    public Boolean hasOptedOutOfEmail() {
      return !'Yes'.equals(csv.getString(pfx + 'Further Contact'));
    }
 
    public void updateContact(Contact contact) {


        contact.Email = csv.getString(pfx + 'E-mail');
        contact.Salutation = csv.getString(pfx + 'Title');
        contact.FirstName = csv.getString(pfx + 'FirstName');
        contact.LastName = csv.getString(pfx + 'LastName');

        contact.MailingPostalCode = csv.getString(pfx
                + 'Postcode');

        contact.MailingState = csv.getString(pfx + 'County');
        contact.MailingCity = csv.getString(pfx + 'Town');

        String address = csv.getString(pfx + 'Address Line 1');
        String address2 = csv.getString(pfx + 'Address Line 2');
        if (address2.length() > 0)
            address += '\n' + address2;
        contact.MailingStreet = address;
        contact.MailingCountry = csv.getString(pfx + 'Country');
    }
  }

  private SSSCsvRow csv;

  public void init(SSSCsvReader reader) {
  }
  
  public void next(SSSCsvRow csv2) {
    this.csv = csv2;
  }
  
  public SourceContactAdapter getDonorAdapter() {
    return new JGContactAdapter(csv, 'donor ');
  }

  public SourceContactAdapter getFundraiserAdapter() {
    return new JGContactAdapter(csv, 'fundraiser ');
  }
  
  public Boolean isValidRow() {
    return true;
  }
  
  public Boolean hasPage() {
    return !'0'.equals(getFundraiserId());
  }
  
  public String getPageId() {
    return csv.getString('Fundraising Page Id');
  }

  public String getPageTitle() {
    return csv.getString('Fundraising Page Title');
  }
  
  public String getPageUrl() {
    return csv.getString('Fundraising Page URL');
  }

  public String getFundraiserId() {
    return csv.getString('Fundraiser User Id');
  }

  public Boolean isDonorAnonymous() {
    String donorEmail = csv.getString('Donor E-mail');
    if ('Anonymous'.equals(donorEmail)) {
      return true;
    }
    String donorLastName = csv.getString('Donor LastName');

    return (''.equals(donorLastName));
  }


 
  public String getDonorId() {
    return csv.getString('Donor User Id');
  }
  
  public String getDonorRole() {
    return 'JustGiving donor';
  }
    
  public String getDonationId() {
    return 'JG_' + csv.getString('Donation Ref');
  }

  public Opportunity createDonation() {
    Opportunity donation = new Opportunity();
    donation.Name = csv.getString('Donation Source');
    donation.CloseDate = date.parse(csv.getString('Donation Date'));
    donation.StageName = 'Posted';
    donation.Amount = decimal.valueOf(csv.getString('Donation Amount'));
    donation.Description = csv.getString('Donation Nickname') + ': ' + csv.getString('Message From Donor');
    donation.Total_deductions__c = decimal.valueOf(csv.getString('Payment Processing Fee Amount'))
                + decimal.valueOf(csv.getString('JustGiving Transaction Fee Amount'));
    return donation;
  }

  public Boolean isGiftAidEligible() {
    return 'Yes'.equals(csv.getString('Is Donation GA Eligible'));
  }

  public String getFundraiserRole() {
    return 'JustGiving fundraiser';
  }
}