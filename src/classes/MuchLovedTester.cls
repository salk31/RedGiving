public class MuchLovedTester extends AbstractSourceTest {

  String getPrefix() {
    return 'ML';
  }

  Boolean isSingleContactId() {
    return True;
  }

  void addPage(CsvBuilder csv, String id, String name) {
    csv.add('Tribute ID', id);
    csv.add('Tribute', name);
  }
  
  void addFundraiser(CsvBuilder csv, String id, String familyName) {
    csv.add('User ID', id);
    
    csv.add('Fundraiser First Name','Fred');
    csv.add('Fundraiser Family Name', familyName);
    
    csv.add('Fundraiser Email','foo@boo.com');
  }
  
  void addFundraiserEmailOk(CsvBuilder csv) {
    // NO SUPPORT
  }
  
  void addDonor(CsvBuilder csv, String id, String familyName) {
    csv.add('Donor ID', id);
    csv.add('Donor First Name','John');
    csv.add('Donor Family Name', familyName);
    
    csv.add('Donor Email','fip@fop.com');
    
    csv.add('Donor Tel', '123 123 123');
  }
  
  void addAnonymousDonor(CsvBuilder csv) {
    csv.add('Donor ID', '0');
    csv.add('Donor Email', 'Opt-out');
  }

  void addDonorEmailOk(CsvBuilder csv) {
    csv.add('Donor Contact By Email', 'Yes');
  }
  
  void addDonation(CsvBuilder csv, String id) {
    csv.add('CAF Id', id);
    csv.add('Donation Date', '"01/06/2013  17:41:30"');
    csv.add('Donation', '\u00a321.00');
    csv.add('Net', '\u00a320.00');
    csv.add('Fee', '\u00a30.10');
  }
  
  public void testZeroDonorId() {
    String donorLn = 'd' + Math.random();
    
    CsvBuilder csv = new CsvBuilder();
    addPage(csv, '123', 'pageTitle');
    addFundraiser(csv, 'abc', 'fundraiserLn');
    addDonor(csv, '0', donorLn);
    addDonation(csv, 'p123');
    csv.eol();
    
    addPage(csv, '123', 'pageTitle');
    addFundraiser(csv, 'abc', 'Smith');
    // XXX cut n paste
    csv.add('Donor ID', '0');
    csv.add('Donor First Name', 'John');
    csv.add('Donor Family Name', donorLn);
    
    csv.add('Donor Email','somebodyelse@fop.com');
    
    csv.add('Donor Tel', '123 123 123');
    
    addDonation(csv, 'p124');
    csv.eol();
    
    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
    
    List<Contact> insertedDonors = [SELECT LastName, AccountId
                                    FROM Contact WHERE LastName = :donorLn];
    System.assertEquals(2, insertedDonors.size());
  }
}