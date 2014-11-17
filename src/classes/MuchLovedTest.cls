@isTest
private class MuchLovedTest {
  static AbstractSourceTest create() {
    return new MuchLovedTester();
  }
  
  static testMethod void testParseMoney() {
    System.assertEquals(1200.45, MuchLovedAdapter.parseMoney('\u00a31,200.45'));
  }
  
  // TODO __ test passing on "do not phone"
  // TODO __ test 0 person id
  // TODO __ donor and fundraiser ids match.. auto merge?
  
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