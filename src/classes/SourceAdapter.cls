public interface SourceAdapter {

  void init(SSSCsvReader csv);

  void next(SSSCsvRow row);
  
  Boolean isValidRow();
  
  Boolean hasPage();
  
  String getPageId();

  String getPageTitle();
  
  String getPageUrl();

  String getFundraiserId();
        
  String getFundraiserRole();

  Boolean isDonorAnonymous();

  String getDonorId();
  
  String getDonorRole();

  SourceContactAdapter getFundraiserAdapter();

  SourceContactAdapter getDonorAdapter();
  
  String getDonationId();
  
  Opportunity createDonation();
  
  Boolean isGiftAidEligible();
}