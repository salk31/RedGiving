public class VirginMoneyGivingTester extends AbstractSourceTest {

  String getPrefix() {
    return 'VMG';
  }

  void addPage(CsvBuilder csv, String id, String name) {
    csv.add('charity fundraising page id', id);
    csv.add('fundraising page name', name);
  }
  
  void addFundraiser(CsvBuilder csv, String id, String familyName) {
    csv.add('charity fundraiser id', id);
    csv.add('fundraiser surname', familyName);
  }
  
  void addFundraiserEmailOk(CsvBuilder csv) {
    csv.add('Fundraiser charity marketing allowed', 'Charity Marketing Allowed');
  }
  
  void addDonor(CsvBuilder csv, String id, String familyName) {
    csv.add('charity donor id', id);

    csv.add('donor surname', familyName);
    csv.add('donor email address', 'yah@boo.com');
  }
  
  void addDonorEmailOk(CsvBuilder csv) {
    csv.add('Donor charity marketing allowed', 'Charity Marketing Allowed');
  }
  
  void addDonation(CsvBuilder csv, String id) {
    csv.add('donation id', id);
    csv.add('donation date', '30-May-2013');
    csv.add('donation type', 'Single Web Donation');
    csv.add('gross amount', '10.00');
    csv.add('total_deductions', '0.15');
    
    csv.add('donor code 1 label', '');
  }
}