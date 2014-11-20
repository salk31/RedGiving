@isTest
private class MuchLovedTest {
  static MuchLovedTester create() {
    return new MuchLovedTester();
  }
  
  static testMethod void testParseMoney() {
    System.assertEquals(1200.45, MuchLovedAdapter.parseMoney('\u00a31,200.45'));
  }

  static testMethod void testZeroDonorId() {
    create().testZeroDonorId();
  }
  
  // TODO __ test passing on "do not phone"

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
    // NOT SUPPORTED create().testEmailOkNeither();
  }
  
  static testMethod void testEmailOkDonor() {
    // NOT SUPPORTED create().testEmailOkDonor();
  }
  
  static testMethod void testEmailOkFundraiser() {
    create().testEmailOkFundraiser();
  }
  
  static testMethod void testEmailOkBoth() {
    create().testEmailOkBoth();
  }
}