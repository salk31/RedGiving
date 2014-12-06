public class JustGivingTester extends AbstractSourceTest {

  String getPrefix() {
    return 'JG';
  }
  
  Boolean isSingleContactId() {
    return True;
  }

  void addPage(CsvBuilder csv, String id, String name) {
    csv.add('Fundraising Page Id', id);
    csv.add('Fundraising Page Title', name);
    csv.add('Fundraising Page URL', 'http://www.redgiving.com');
  }
  
  void addFundraiser(CsvBuilder csv, String id, String familyName) {
    csv.add('Fundraiser User Id', id);
    csv.add('Fundraiser Firstname','Fred');
    csv.add('Fundraiser Lastname', familyName);
  }
  
  void addFundraiserEmailOk(CsvBuilder csv) {
    csv.add('Fundraiser Further Contact', 'Yes');
  }
  
  void addDonor(CsvBuilder csv, String id, String familyName) {
    csv.add('Donor User Id', id);
    csv.add('Donor FirstName','John');
    csv.add('Donor LastName', familyName);
  }
  
  void addAnonymousDonor(CsvBuilder csv) {

  }
  
  void addDonorEmailOk(CsvBuilder csv) {
    csv.add('Donor Further Contact', 'Yes');
  }
  
  void addDonation(CsvBuilder csv, String id) {
    csv.add('Message from Donor','Test message');
    csv.add('Donation Ref', id);
    csv.add('Donation Source', 'Event');
    csv.add('Donation Date','12/12/2011');
    csv.add('Donation Amount', '21');
    csv.add('Net Donation Amount', '20');
    csv.add('Payment Processing Fee Amount', '0.10');
    csv.add('JustGiving Transaction Fee Amount', '0.90');
  }
}