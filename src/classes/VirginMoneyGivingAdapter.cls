/**
 * VirginMoneyGiving
 * donations_flexible.csv
 *
 **/
public class VirginMoneyGivingAdapter implements SourceAdapter {

  public class VMGContactAdapter implements SourceContactAdapter {
    private SSSCsvRow csv;
    
    private String pfx;
    
    public VMGContactAdapter(SSSCsvRow csv2, String pfx2) {
      this.csv = csv2;
      this.pfx = pfx2;
    }

    public Boolean isDoNotCall() {
      return false;
    }

    public Boolean hasOptedOutOfEmail() {
      return !'Charity Marketing Allowed'
          .equals(csv.getString(pfx + 'charity marketing allowed'));
    }

    public void updateContact(Contact contact) {
      contact.Email = csv.getString(pfx + 'email address');
      contact.Salutation = csv.getString(pfx + 'Title');
      contact.FirstName = csv.getString(pfx + 'forename');
      contact.LastName = csv.getString(pfx + 'surname');

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

  private static DateParser dateParser = new DateParser();

  public void init(SSSCsvReader reader) {
  }

  public void next(SSSCsvRow csv2) {
    this.csv = csv2;
  }

  public SourceContactAdapter getDonorAdapter() {
    return new VMGContactAdapter(csv, 'donor ');
  }

  public SourceContactAdapter getFundraiserAdapter() {
    return new VMGContactAdapter(csv, 'fundraiser ');
  }

  public Boolean isValidRow() {
    return !''.equals(csv.getString('donation id'));
  }

  public Boolean hasPage() {
    return !''.equals(csv.getString('charity fundraiser id'));
  }

  public String getPageId() {
    return 'VMG_P_' + csv.getString('charity fundraising page id');
  }

  public String getPageTitle() {
    return csv.getString('fundraising page name');
  }
  
  public String getPageUrl() {
    return 'http://uk.virginmoneygiving.com/' + csv.getString('fundraiser url');
  }

  public String getFundraiserId() {
    return 'VMG_F_' + csv.getString('charity fundraiser id');
  }

  public Boolean isDonorAnonymous() {
    return 'Anonymous'.equals(csv.getString('Donor LastName'));
  }

  public String getDonorId() {
    return 'VMG_D_' + csv.getString('charity donor id');
  }
  
  public String getDonorRole() {
    return 'VirginMoneyGiving donor';
  }

  public String getDonationId() {
    return 'VMG_' + csv.getString('donation id');
  }
    

  public Opportunity createDonation() {
    Opportunity donation = new Opportunity();
    donation.Name = csv.getString('donation type');
    donation.CloseDate = dateParser.parse(csv.getString('donation Date'));
    donation.StageName = 'Posted';
    donation.Amount = decimal.valueOf(csv.getString('gross amount'));
    donation.Description = csv.getString('donor message');
    donation.Total_deductions__c = decimal.valueOf(csv.getString('total_deductions'));
    return donation;
  }

  public Boolean isGiftAidEligible() {
    return 'Paid to Charity'.equals(csv.getString('gift aid paid to charity status'));
  }

  public String getFundraiserRole() {
    return 'VirginMoneyGiving fundraiser';
  }
}