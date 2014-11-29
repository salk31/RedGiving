// "Donor Report CSV"
public class MuchLovedAdapter implements SourceAdapter {
	
  public class MLContactAdapter implements SourceContactAdapter {
    private SSSCsvRow csv;
    
    private Boolean donor;
    
    private String pfx;
    
    public MLContactAdapter(SSSCsvRow csv2, Boolean donor2) {
      this.csv = csv2;
      this.donor = donor2;
      pfx = donor ? 'Donor ' : 'Fundraiser ';
    }

    public Boolean isDoNotCall() {
      return donor && !'Yes'.equals(csv.getString(pfx + 'Contact By Phone'));
    }

    public Boolean hasOptedOutOfEmail() {
      return donor && !'Yes'.equals(csv.getString(pfx + 'Contact By Email'));
    }

    public void updateContact(Contact contact) {

      contact.Email = csv.getString(pfx + 'Email');
      contact.Salutation = csv.getString(pfx + 'Title');
      contact.FirstName = csv.getString(pfx + 'First Name');
      contact.LastName = csv.getString(pfx + 'Family Name');

      if (donor) {
        contact.MailingPostalCode = csv.getString(pfx
              + 'Postcode');

        contact.MailingState = csv.getString(pfx + 'County');
        contact.MailingCity = csv.getString(pfx + 'Town');

        String address = csv.getString(pfx + 'Address 1');
        String address2 = csv.getString(pfx + 'Address 2');
        if (address2.length() > 0)
            address += '\n' + address2;
        contact.MailingStreet = address;
        contact.MailingCountry = csv.getString(pfx + 'Country');
        
        contact.HomePhone = csv.getString(pfx + 'Tel');
      }
    }
  }
	
  private SSSCsvRow csv;

  private static DateParser dateParser = new DateParser();

  public void init(SSSCsvReader reader) {
    String pfx = null;
    String[] headings = reader.getHeadings();
    for (Integer i = 0; i < headings.size(); i++) {
      String heading = headings[i];
      if ('User ID'.equals(heading)) {
        pfx = 'Fundraiser ';
      } else if ('Donor ID'.equals(heading)) {
        pfx = 'Donor ';
      } else if ('CAF Id'.equals(heading) || 'Donation'.equals(heading)) {
        pfx = null;
      }
      if (pfx != null) {
        reader.setHeading(pfx + heading, i);
      }
    }
  }
  
  public void next(SSSCsvRow csv2) {
    this.csv = csv2;
  }
  
  public SourceContactAdapter getDonorAdapter() {
    return new MLContactAdapter(csv, true);
  }

  public SourceContactAdapter getFundraiserAdapter() {
    return new MLContactAdapter(csv, false);
  }
  
  public Boolean isValidRow() {
    return true;
  }
  
  public Boolean hasPage() {
    return !'0'.equals(getFundraiserId());
  }
  
  public String getPageId() {
    return 'ML_P_' + csv.getString('Tribute ID');
  }

  public String getPageTitle() {
    return getPageUrl();
  }
  
  public String getPageUrl() {
    return csv.getString('Tribute');
  }

  public String getFundraiserId() {
    return 'ML_C_' + csv.getString('Fundraiser User Id');
  }

  private String getDonorEmail() {
    return csv.getString('Donor Email');
  }

  public Boolean isDonorAnonymous() {
    return 'Opt-out'.equals(getDonorEmail());
  }
 
  public String getDonorId() {
    String raw = csv.getString('Donor Donor Id');
    if ('0'.equals(raw)) {
      raw = getDonorEmail();
    }
    return 'ML_C_' + raw;
  }
  
  public String getDonorRole() {
    return 'MuchLoved donor';
  }

  public String getDonationId() {
    return 'ML_' + csv.getString('CAF Id');
  }
  
  public static Decimal parseMoney(String value) {
    return Decimal.valueOf(value.replaceAll('^\u00a3|,' ,''));
  }
  
  private Decimal getMoney(String key) {
    return parseMoney(csv.getString(key));
  }
  
  public Opportunity createDonation() {
    Opportunity donation = new Opportunity();
    donation.Name = 'Much Loved';
    donation.CloseDate = dateParser.parseDDMMYYY(csv.getString('Donation Date'));
    donation.StageName = 'Posted';
    donation.Amount = getMoney('Donation');
    donation.Description = csv.getString('Donation Nickname') + ': ' + csv.getString('Message From Donor');
    donation.Total_deductions__c = getMoney('Fee');
    return donation;
  }

  public Boolean isGiftAidEligible() {
    return 'Yes'.equals(csv.getString('Is Donation GA Eligible'));
  }

  public String getFundraiserRole() {
    return 'MuchLoved fundraiser';
  }
}