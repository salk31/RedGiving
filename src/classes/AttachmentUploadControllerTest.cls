@isTest
private class AttachmentUploadControllerTest {

  static void upload(String content) {
    AttachmentUploadController controller = new AttachmentUploadController ();
    Blob bodyBlob = Blob.valueOf(content);
    controller.attachment.body = bodyBlob;

    controller.upload();

  }

  static testMethod void testJustGivingSingle() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('Fundraiser User Id', '1');
    csv.add('Fundraiser Firstname','Fred');
    csv.add('Fundraiser Lastname','Smith');
    csv.add('Fundraising Page Id','2');
    csv.add('Fundraising Page Title','Test 1');
    csv.add('Donor User Id', '3');
    csv.add('Donor FirstName','John');
    csv.add('Donor LastName','Jones');
    csv.add('Message from Donor','Test message');
    csv.add('Donation Ref', '4');
    csv.add('Donation Source', 'Event');
    csv.add('Donation Date','12/12/2011');
    csv.add('Donation Amount', '21');
    csv.add('Net Donation Amount', '20');
    csv.add('Payment Processing Fee Amount', '0.10');
    csv.add('JustGiving Transaction Fee Amount', '0.90');
    csv.eol();

    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
  }
  
  static testMethod void testVirginMoneyTwoDigitDates() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('donation id', '"123,123,123"')
        .add('donation date', '30-May-13')
        .add('donation type', 'Single Web Donation')
        .add('donor code 1 label', 'donorOneCode')
        .add('charity fundraising page id', 'vmPage1')
        .add('fundraising page name', 'For Fred')
        .add('charity fundraiser id', 'FundRaiseId')
        .add('charity donor id', 'd123')
        .add('gross amount', '10.00')
        .add('total_deductions', '0.15')
        .add('charity fundraiser id', 'f45f')
        .add('donor surname', '"Smith, Lawson"')
        .add('donor email address', 'yah@boo.com')
        .add('fundraiser surname', 'Hussain')
        .eol();
    

    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
    
 
    List<Opportunity> insertedDonations = [SELECT Name, CloseDate, redspr__Gift_aid_eligible__c
                                      FROM Opportunity WHERE redspr__RedGivingId__c = 'VMG_123,123,123'];
    System.assertEquals(1, insertedDonations.size());
    Opportunity donation = insertedDonations.get(0);
    System.assertEquals(Date.newInstance(2013, 5, 30), donation.CloseDate);
  }

  static testMethod void testImportDonorGiveTwice() {
    String pageTitle = 'pn' + Math.random();
    String donorLn = 'd' + Math.random();
    String fundraiserLn = 'f' + Math.random();

    CsvBuilder csv = new CsvBuilder();
    csv.add('Fundraiser User Id', '1fr');
    csv.add('Fundraiser Firstname','Fred');
    csv.add('Fundraiser Lastname', fundraiserLn);
    csv.add('Fundraising Page Id','2');
    csv.add('Fundraising Page Title', pageTitle);
    csv.add('Fundraising Page URL', 'http://www.redgiving.com');
    csv.add('Donor User Id', '3');
    csv.add('Donor FirstName','John');
    csv.add('Donor LastName', donorLn);
    csv.add('Message from Donor','Test message');
    csv.add('Donation Ref', '5');
    csv.add('Donation Source', 'Event');
    csv.add('Donation Date','13/12/2011');
    csv.add('Donation Amount', '25');
    csv.add('Net Donation Amount', '20');
    csv.add('Payment Processing Fee Amount', '0.10');
    csv.add('JustGiving Transaction Fee Amount', '0.90');
    csv.eol();
    
    csv.add('Fundraiser User Id', '1fr');
    csv.add('Fundraiser Firstname','Fred');
    csv.add('Fundraiser Lastname', fundraiserLn);
    csv.add('Fundraising Page Id','2');
    csv.add('Fundraising Page Title', pageTitle);
    csv.add('Fundraising Page URL', 'http://www.redgiving.com');
    csv.add('Donor User Id', '3');
    csv.add('Donor FirstName','John');
    csv.add('Donor LastName', donorLn);
    csv.add('Message from Donor','Test message');
    csv.add('Donation Ref', '4');
    csv.add('Donation Source', 'Event');
    csv.add('Donation Date','12/12/2011');
    csv.add('Donation Amount', '21');
    csv.add('Net Donation Amount', '20');
    csv.add('Payment Processing Fee Amount', '0.10');
    csv.add('JustGiving Transaction Fee Amount', '0.90');
    csv.eol();

    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
    
    List<Account> insertedAccounts = [SELECT Name, Website
                                      FROM Account WHERE Name = :pageTitle];
    System.assertEquals(1, insertedAccounts.size());
    Account page = insertedAccounts.get(0);
    System.assertEquals('http://www.redgiving.com', page.Website);
    
    List<Contact> insertedFundraisers = [SELECT LastName, Email, AccountId
                                        FROM Contact
                                        WHERE LastName = :fundraiserLn];
    System.assertEquals(1, insertedFundraisers.size());
    Contact fundraiser = insertedFundraisers.get(0);
    System.assertEquals(page.Id, fundraiser.AccountId);

    
    List<Contact> insertedDonors = [SELECT LastName, AccountId
                                    FROM Contact WHERE LastName = :donorLn];
    System.assertEquals(1, insertedDonors.size());
    Contact donor = insertedDonors.get(0);
    System.assertEquals(page.Id, donor.AccountId);
    
    List<Opportunity> insertedDonations = [SELECT Name, redspr__Gift_aid_eligible__c
                                      FROM Opportunity WHERE AccountId = :page.Id
                                      ORDER BY CloseDate];
    System.assertEquals(2, insertedDonations.size());
    Opportunity donation = insertedDonations.get(0);
    System.assertEquals(False, donation.redspr__Gift_aid_eligible__c);
    
    List<OpportunityContactRole> ocrs = [SELECT OpportunityId FROM OpportunityContactRole WHERE ContactId = :donor.Id];
    System.assertEquals(2, ocrs.size());
  }
  
  static testMethod void testImportDonationTwice() {
    String pageTitle = 'pn' + Math.random();
    String donorLn = 'd' + Math.random();
    String fundraiserLn = 'f' + Math.random();

    CsvBuilder csv = new CsvBuilder();
    csv.add('Fundraiser User Id', '1fr');
    csv.add('Fundraiser Firstname','Fred');
    csv.add('Fundraiser Lastname', fundraiserLn);
    csv.add('Fundraising Page Id','2');
    csv.add('Fundraising Page Title', pageTitle);
    csv.add('Donor User Id', '3');
    csv.add('Donor FirstName','John');
    csv.add('Donor LastName', donorLn);
    csv.add('Message from Donor','Test message');
    csv.add('Donation Ref', '4');
    csv.add('Donation Source', 'Event');
    csv.add('Donation Date','12/12/2011');
    csv.add('Donation Amount', '21');
    csv.add('Net Donation Amount', '20');
    csv.add('Payment Processing Fee Amount', '0.10');
    csv.add('JustGiving Transaction Fee Amount', '0.90');
    csv.eol();

    Test.StartTest();
    upload(csv.build());
    
    // do it again
    upload(csv.build());
    Test.StopTest();
    
    List<Account> insertedAccounts = [SELECT Name
                                      FROM Account WHERE Name = :pageTitle];
    System.assertEquals(1, insertedAccounts.size());
    Account page = insertedAccounts.get(0);
    
    List<Contact> insertedFundraisers = [SELECT LastName, Email
                                        FROM Contact
                                        WHERE LastName = :fundraiserLn];
    System.assertEquals(1, insertedFundraisers.size());
    Contact fundraiser = insertedFundraisers.get(0);

    
    List<Contact> insertedDonors = [SELECT LastName
                                    FROM Contact WHERE LastName = :donorLn];
    System.assertEquals(1, insertedDonors.size());
    Contact donor = insertedDonors.get(0);

    
    List<Opportunity> insertedDonations = [SELECT Name, redspr__Gift_aid_eligible__c
                                      FROM Opportunity WHERE redspr__RedGivingId__c='JG_4'];
    System.assertEquals(1, insertedDonations.size());
    Opportunity donation = insertedDonations.get(0);
    System.assertEquals(False, donation.redspr__Gift_aid_eligible__c);
    
    List<OpportunityContactRole> ocrs = [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :donation.Id];
    System.assertEquals(1, ocrs.size());
  }
  

  
  static testMethod void testVirginMoneySingle() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('donation id', '"123,123,123"')
        .add('donation date', '30-May-2013')
        .add('donation type', 'Single Web Donation')
        .add('donor code 1 label', 'donorOneCode')
        .add('charity fundraising page id', 'vmPage1')
        .add('fundraising page name', 'For Fred')
        .add('charity fundraiser id', 'FundRaiseId')
        .add('charity donor id', 'd123')
        .add('gross amount', '10.00')
        .add('total_deductions', '0.15')
        .add('charity fundraiser id', 'f45f')
        .add('donor surname', '"Smith, Lawson"')
        .add('donor email address', 'yah@boo.com')
        .add('fundraiser url', 'tumble')
        .add('fundraiser surname', 'Hussain')
    
        .eol();
    
    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
    
    List<Account> insertedAccounts = [SELECT Name, Website
                                      FROM Account WHERE Name='For Fred'];
    System.assertEquals(1, insertedAccounts.size());
    Account account = insertedAccounts.get(0);
    System.assertEquals('http://uk.virginmoneygiving.com/tumble', account.Website);
    
    List<Contact> insertedFundraisers = [SELECT LastName, Email
                                        FROM Contact
                                        WHERE LastName='Hussain'];
    System.assertEquals(1, insertedFundraisers.size());

    Contact fundraiser = insertedFundraisers.get(0);
    System.assertEquals('Hussain', fundraiser.LastName);
    
    List<redspr__Contact_Mapping__c> insertedDonors = [SELECT redspr__Contact__c
                                    FROM redspr__Contact_Mapping__c 
                                    WHERE Name='VMG_D_d123'];
    System.assertEquals(1, insertedDonors.size());
    //Contact donor = insertedDonors.get(0);
    //System.assertEquals('yah@boo.com', donor.Email);
  }
    
  static testMethod void testBulk() {
    CsvBuilder csv = new CsvBuilder();
    for (Integer i = 0; i < 2; i++) {
      csv.add('Fundraiser User Id','1' + i)
          .add('Fundraiser Firstname','Fred')
          .add('Fundraiser Lastname','Smith')
          .add('Fundraising Page Id','2' + i)
          .add('Fundraising Page Title','Test 1' + i)
          .add('Donor User Id', '3' + i)
          .add('Donor FirstName','John')
          .add('Donor LastName','Jones')
          .add('Message from Donor','Test message')
          .add('Donation Ref', '4' + i)
          .add('Donation Source', 'Event')
          .add('Donation Date','12/12/2011')
          .add('Donation Amount', '22')
          .add('Net Donation Amount', '20')
          .add('Payment Processing Fee Amount', '0.10')
          .add('JustGiving Transaction Fee Amount', '1.90')
          .eol();
    }

    Test.StartTest();
    upload(csv.build());
        Test.StopTest();
  }
  
  static void noPage(CsvBuilder csv, String id) {
    Test.StartTest();
    upload(csv.build());
    Test.StopTest();

    List<Opportunity> donations = [SELECT Name FROM Opportunity WHERE redspr__RedGivingId__c = :id];
    System.assertEquals(1, donations.size());
  }
  	
  	
  static testMethod void testJustGivingNoPage() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('Fundraiser User Id', '0')
        .add('Donor User Id', '3')
        .add('Donor FirstName','John')
        .add('Donor LastName','Jones')
        .add('Message from Donor','Test message')
        .add('Donation Ref', '4')
        .add('Donation Source', 'Event')
        .add('Donation Date','12/12/2011')
        .add('Donation Amount', '22')
        .add('Net Donation Amount', '20')
        .add('Payment Processing Fee Amount', '0.10')
        .add('JustGiving Transaction Fee Amount', '1.90')
        .eol();
    noPage(csv, 'JG_4');
  }
  
  static testMethod void testVirginMoneyNoPage() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('donation id', '"123,123,123"')
        .add('donation date', '30-May-2013')
        .add('donation type', 'Single Web Donation')
        .add('donor code 1 label', 'donorOneCode')
        .add('charity donor id', 'd123')
        .add('gross amount', '10.00')
        .add('total_deductions', '0.15')
        .add('donor surname', '"Smith, Lawson"')
        .add('donor email address', 'yah@boo.com')
        .eol();
    noPage(csv, 'VMG_123,123,123');
  }
  
  static testMethod void testVirginMoneyBlankLine() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('donor message', 'nonsense')
        .add('donor code 1 label', 'Just to select the adapter')
        .eol();

    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
  }
  
  static testMethod void testContactMerge() {
    String pageTitle = 'pn' + Math.random();
    String donorLn = 'd' + Math.random();
    String fundraiserLn = 'f' + Math.random();

    CsvBuilder csv = new CsvBuilder();
    csv.add('Fundraiser User Id', '1fr');
    csv.add('Fundraiser Firstname','Fred');
    csv.add('Fundraiser Lastname', fundraiserLn);
    csv.add('Fundraising Page Id','2');
    csv.add('Fundraising Page Title', pageTitle);
    csv.add('Fundraising Page URL', 'http://www.redgiving.com');
    csv.add('Donor User Id', '34');
    csv.add('Donor FirstName','John');
    csv.add('Donor LastName', donorLn);
    csv.add('Message from Donor','Test message');
    csv.add('Donation Ref', '5');
    csv.add('Donation Source', 'Event');
    csv.add('Donation Date','13/12/2011');
    csv.add('Donation Amount', '25');
    csv.add('Net Donation Amount', '20');
    csv.add('Payment Processing Fee Amount', '0.10');
    csv.add('JustGiving Transaction Fee Amount', '0.90');
    csv.eol();
    
    csv.add('Fundraiser User Id', '2gp');
    csv.add('Fundraiser Firstname','Fred');
    csv.add('Fundraiser Lastname', fundraiserLn);
    csv.add('Fundraising Page Id','2');
    csv.add('Fundraising Page Title', pageTitle);
    csv.add('Fundraising Page URL', 'http://www.redgiving.com');
    csv.add('Donor User Id', '63');
    csv.add('Donor FirstName','John');
    csv.add('Donor LastName', donorLn);
    csv.add('Message from Donor','Test message');
    csv.add('Donation Ref', '4');
    csv.add('Donation Source', 'Event');
    csv.add('Donation Date','12/12/2011');
    csv.add('Donation Amount', '21');
    csv.add('Net Donation Amount', '20');
    csv.add('Payment Processing Fee Amount', '0.10');
    csv.add('JustGiving Transaction Fee Amount', '0.90');
    csv.eol();

    CsvBuilder csv2 = new CsvBuilder();
    csv2.add('Fundraiser User Id', '1fr');
    csv2.add('Fundraiser Firstname','Fred');
    csv2.add('Fundraiser Lastname', fundraiserLn);
    csv2.add('Fundraising Page Id','2');
    csv2.add('Fundraising Page Title', pageTitle);
    csv2.add('Fundraising Page URL', 'http://www.redgiving.com');
    csv2.add('Donor User Id', '34');
    csv2.add('Donor FirstName','John');
    csv2.add('Donor LastName', donorLn);
    csv2.add('Message from Donor','Test message');
    csv2.add('Donation Ref', '5b');
    csv2.add('Donation Source', 'Event');
    csv2.add('Donation Date','13/12/2011');
    csv2.add('Donation Amount', '25');
    csv2.add('Net Donation Amount', '20');
    csv2.add('Payment Processing Fee Amount', '0.10');
    csv2.add('JustGiving Transaction Fee Amount', '0.90');
    csv2.eol();
    
    csv2.add('Fundraiser User Id', '2gp');
    csv2.add('Fundraiser Firstname','Fred');
    csv2.add('Fundraiser Lastname', fundraiserLn);
    csv2.add('Fundraising Page Id','2');
    csv2.add('Fundraising Page Title', pageTitle);
    csv2.add('Fundraising Page URL', 'http://www.redgiving.com');
    csv2.add('Donor User Id', '63');
    csv2.add('Donor FirstName','John');
    csv2.add('Donor LastName', donorLn);
    csv2.add('Message from Donor','Test message');
    csv2.add('Donation Ref', '4b');
    csv2.add('Donation Source', 'Event');
    csv2.add('Donation Date','12/12/2011');
    csv2.add('Donation Amount', '21');
    csv2.add('Net Donation Amount', '20');
    csv2.add('Payment Processing Fee Amount', '0.10');
    csv2.add('JustGiving Transaction Fee Amount', '0.90');
    csv2.eol();
  
    Test.StartTest();
    upload(csv.build());

    List<Contact> insertedDonors = [SELECT LastName, AccountId
                                    FROM Contact WHERE LastName = :donorLn];
    // TODO System.assertEquals(2, insertedDonors.size());
    //Contact donor0 = insertedDonors.get(0);
    //Contact donor1 = insertedDonors.get(1);
    
    //merge donor0 donor1;
    
    //upload(csv2.build());
    
    Test.StopTest();
    
    //List<Contact> insertedDonors2 = [SELECT LastName, AccountId
    //                                FROM Contact WHERE LastName = :donorLn];
    //System.assertEquals(1, insertedDonors2.size());

    // problem is want to run thing twice but can only stop/start once...
  }



  static testMethod void testJustGivingFutherContactNeither() {
    CsvBuilder csv = new CsvBuilder();
    justGivingFurtherContact(csv, False, False);
  }
  
  static testMethod void testJustGivingFutherContactDonor() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('Donor Further Contact', 'Yes');
    justGivingFurtherContact(csv, False, True);
  }
  
  static testMethod void testJustGivingFutherContactFundraiser() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('Fundraiser Further Contact', 'Yes');
    justGivingFurtherContact(csv, True, False);
  }
  
  static testMethod void testJustGivingFurtherContactBoth() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('Donor Further Contact', 'Yes');
    csv.add('Fundraiser Further Contact', 'Yes');
    justGivingFurtherContact(csv, True, True);
  }
  
  
  static void justGivingFurtherContact(CsvBuilder csv, Boolean forFundraiser, Boolean forDonor) {
    String donorLn = 'd' + Math.random();
    String fundraiserLn = 'f' + Math.random();
    
    csv.add('Fundraiser User Id', '1');
    csv.add('Fundraiser Firstname','Fred');
    csv.add('Fundraiser Lastname', fundraiserLn);
    csv.add('Fundraising Page Id','2');
    csv.add('Fundraising Page Title','Test 1');
    csv.add('Donor User Id', '3');
    csv.add('Donor FirstName','John');
    csv.add('Donor LastName', donorLn);
    csv.add('Message from Donor','Test message');
    csv.add('Donation Ref', '4');
    csv.add('Donation Source', 'Event');
    csv.add('Donation Date','12/12/2011');
    csv.add('Donation Amount', '21');
    csv.add('Net Donation Amount', '20');
    csv.add('Payment Processing Fee Amount', '0.10');
    csv.add('JustGiving Transaction Fee Amount', '0.90');
    csv.eol();

    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
    
    List<Contact> insertedDonors = [SELECT HasOptedOutOfEmail
                                    FROM Contact WHERE LastName = :donorLn];
    System.assertEquals(!forDonor, insertedDonors.get(0).HasOptedOutOfEmail);
    
                                    
    List<Contact> insertedFundraisers = [SELECT HasOptedOutOfEmail
                                    FROM Contact WHERE LastName = :fundraiserLn];
    System.assertEquals(!forFundraiser, insertedFundraisers.get(0).HasOptedOutOfEmail); 
  }
  
  static testMethod void testVirginMoneyFutherContactNeither() {
    CsvBuilder csv = new CsvBuilder();
    virginMoneyFurtherContact(csv, False, False);
  }
  
  static testMethod void testVirginMoneyFutherContactDonor() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('Donor charity marketing allowed', 'Charity Marketing Allowed');
    virginMoneyFurtherContact(csv, False, True);
  }
  
  static testMethod void testVirginMoneyFutherContactFundraiser() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('Fundraiser charity marketing allowed', 'Charity Marketing Allowed');
    virginMoneyFurtherContact(csv, True, False);
  }
  
  static testMethod void testVirginMoneyFurtherContactBoth() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('Donor charity marketing allowed', 'Charity Marketing Allowed');
    csv.add('Fundraiser charity marketing allowed', 'Charity Marketing Allowed');
    virginMoneyFurtherContact(csv, True, True);
  }
  
  
  static void virginMoneyFurtherContact(CsvBuilder csv, Boolean forFundraiser, Boolean forDonor) {
    String donorLn = 'd' + Math.random();
    String fundraiserLn = 'f' + Math.random();

    csv.add('donation id', '"123,123,123"')
        .add('donation date', '30-May-13')
        .add('donation type', 'Single Web Donation')
        .add('donor code 1 label', 'donorOneCode')
        .add('charity fundraising page id', 'vmPage1')
        .add('fundraising page name', 'For Fred')
        .add('charity fundraiser id', 'FundRaiseId')
        .add('charity donor id', 'd123')
        .add('gross amount', '10.00')
        .add('total_deductions', '0.15')
        .add('charity fundraiser id', 'f45f')
        .add('donor surname', donorLn)
        .add('donor email address', 'yah@boo.com')
        .add('fundraiser surname', fundraiserLn)
        .eol();

    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
    
    List<Contact> insertedDonors = [SELECT HasOptedOutOfEmail
                                    FROM Contact WHERE LastName = :donorLn];
    System.assertEquals(!forDonor, insertedDonors.get(0).HasOptedOutOfEmail);
    
                                    
    List<Contact> insertedFundraisers = [SELECT HasOptedOutOfEmail
                                    FROM Contact WHERE LastName = :fundraiserLn];
    System.assertEquals(!forFundraiser, insertedFundraisers.get(0).HasOptedOutOfEmail); 
  }
  
  static testMethod void testJustGivingNoDonorSurname() {
    String donorFn = 'd' + Math.random();

    CsvBuilder csv = new CsvBuilder();
    csv.add('Fundraiser User Id', '1');
    csv.add('Fundraiser Firstname','Fred');
    csv.add('Fundraiser Lastname','Smith');
    csv.add('Fundraising Page Id','2');
    csv.add('Fundraising Page Title','Test 1');
    csv.add('Donor User Id', '3');
    csv.add('Donor FirstName', donorFn);
    csv.add('Donor LastName','');
    csv.add('Message from Donor','Test message');
    csv.add('Donation Ref', '4');
    csv.add('Donation Source', 'Event');
    csv.add('Donation Date','12/12/2011');
    csv.add('Donation Amount', '21');
    csv.add('Net Donation Amount', '20');
    csv.add('Payment Processing Fee Amount', '0.10');
    csv.add('JustGiving Transaction Fee Amount', '0.90');
    csv.eol();

    Test.StartTest();
    upload(csv.build());
    Test.StopTest();
    
    List<Contact> insertedDonors = [SELECT HasOptedOutOfEmail
                                    FROM Contact WHERE FirstName = :donorFn];
    System.assertEquals(0, insertedDonors.size());
  }
}