@isTest
private class VirginMoneyGivingTest {

  static AbstractSourceTest create() {
    return new VirginMoneyGivingTester();
  }
  
  // COPY N PASTE FROM HERE ON
  
  static testMethod void testSingle() {
    create().testSingle();
  }
  
  static testMethod void testReImport() {
    create().testReImport();
  }
  
  static testMethod void testDonorGiveTwice() {
    create().testDonorGiveTwice();
  }
  
  static testMethod void testImportDonationTwice() {
    create().testImportDonationTwice();
  }
  
  static testMethod void testBulk() {
    create().testBulk();
  }
  
  static testMethod void testEmailOkNeither() {
    create().testEmailOkNeither();
  }
  
  static testMethod void testEmailOkDonor() {
    create().testEmailOkDonor();
  }
  
  static testMethod void testEmailOkFundraiser() {
    create().testEmailOkFundraiser();
  }
  
  static testMethod void testEmailOkBoth() {
    create().testEmailOkBoth();
  }
}