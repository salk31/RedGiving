@isTest
private class SSSCsvReaderTest {
  static testMethod void testQuotedNewlines() {
    String x = 'a,b\n'
        + '123,"asd\nasdasd\n"\n'
        + 'm,n\n';
    SSSCsvReader reader = new SSSCsvReader(x);
    System.assert(reader.hasNext());
    SSSCsvRow row = reader.next();
    System.assertEquals('123', row.getString('a'));
    System.assertEquals('asd\nasdasd\n', row.getString('b'));
    
    row = reader.next();
    System.assertEquals('m', row.getString('a'));
    System.assertEquals('n', row.getString('b'));
    
    System.assert(!reader.hasNext());
  }
  
  static testMethod void testQuoteThenEol() {
    String x = 'a,b\n'
        + '123,"asd\nasdasd';
    SSSCsvReader reader = new SSSCsvReader(x);
    System.assert(reader.hasNext());
    SSSCsvRow row = reader.next();
    System.assertEquals('123', row.getString('a'));
    System.assertEquals('asd\nasdasd', row.getString('b'));
    
    System.assert(!reader.hasNext());
  }
  
  static testMethod void testTrailingComma() {
    String x = 'a,b\n'
        + '123,\n'
        + 'm,n\n';
    SSSCsvReader reader = new SSSCsvReader(x);
    System.assert(reader.hasNext());
    SSSCsvRow row = reader.next();
    System.assertEquals('123', row.getString('a'));
    System.assertEquals('', row.getString('b'));
    
    row = reader.next();
    System.assertEquals('m', row.getString('a'));
    System.assertEquals('n', row.getString('b'));
    
    System.assert(!reader.hasNext());
  }
  
  static testMethod void testFindQuote() {
    System.assertEquals(-1, SSSCsvReader.findQuote('""', 0));
    System.assertEquals(2, SSSCsvReader.findQuote('"""', 0));
    System.assertEquals(-1, SSSCsvReader.findQuote('""""', 0));
  }

  static testMethod void testCommaThenNewline() {
        String x = 'a,b,c\n'
        + '123,"x,\ny\nz.",p\n'
        + 'm,n,o\n';
    SSSCsvReader reader = new SSSCsvReader(x);
    System.assert(reader.hasNext());
    SSSCsvRow row = reader.next();
    System.assertEquals('123', row.getString('a'));
    System.assertEquals('x,\ny\nz.', row.getString('b'));
    System.assertEquals('p', row.getString('c'));
    
        
    row = reader.next();
    System.assertEquals('m', row.getString('a'));
    System.assertEquals('n', row.getString('b'));
    System.assertEquals('o', row.getString('c'));
    
    System.assert(!reader.hasNext());
  }
  
  
    static testMethod void testEscapedDoubleQuotes() {
        String x = 'a,b,c\n'
        + 'v,"I\'ll \'The Black Pig\'.......""Heave ho, mi hearties!""",g\n'
        + 'm,n,o\n';
    SSSCsvReader reader = new SSSCsvReader(x);
    System.assert(reader.hasNext());
    SSSCsvRow row = reader.next();
    System.assertEquals('v', row.getString('a'));
    System.assertEquals('I\'ll \'The Black Pig\'......."Heave ho, mi hearties!"', row.getString('b'));
    System.assertEquals('g', row.getString('c'));
    
        
    row = reader.next();
    System.assertEquals('m', row.getString('a'));
    System.assertEquals('n', row.getString('b'));
    System.assertEquals('o', row.getString('c'));
    
    System.assert(!reader.hasNext());
  }
  
  static testMethod void testSSSCsvReader() {
    CsvBuilder csv = new CsvBuilder();
    csv.add('donor code 1 label', '123');
    csv.eol();

    //System.assertEquals('', content);
    SSSCsvReader reader = new SSSCsvReader(csv.build());
    SSSCsvRow row = reader.next();
    System.assert(row.hasColumn('donor code 1 label'));
    System.assert(!row.hasColumn('nonsense'));
  }
  
  static testMethod void testDoubleQuoteTastic() {
    SSSCsvReader reader = new SSSCsvReader(
        '"foo bar","b","c","d","e","f"\n' +
        '"1","","","","dah",""\n' +
        '"2","","","","tree",""');
    SSSCsvRow row1 = reader.next();
    System.assertEquals('1', row1.getString('foo bar'));
    System.assertEquals('dah', row1.getString('e'));
    
    SSSCsvRow row2 = reader.next();
    System.assertEquals('2', row2.getString('foo bar'));
    System.assertEquals('tree', row2.getString('e'));
  }
}