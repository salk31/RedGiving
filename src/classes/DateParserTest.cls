@isTest
private class DateParserTest {
  static testMethod void testTwoDigitYears() {
    DateParser dp = new DateParser();
    System.assertEquals(Date.newInstance(2014, 6, 10), dp.parse('10-Jun-14'));
  }
}