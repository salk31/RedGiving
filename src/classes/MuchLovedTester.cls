public class MuchLovedTester extends AbstractSourceTest {

  String getPrefix() {
    return 'ML';
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
}