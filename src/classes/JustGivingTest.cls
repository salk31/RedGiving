@isTest
private class JustGivingTest {

  static AbstractSourceTest create() {
    return new JustGivingTester();
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
}