public class DateParser {
  public class SomeException extends Exception {
   
  }
	
  private Map<String, Integer> months = new Map<String, Integer>();
  
  public DateParser() {
    months.put('Jan', 1);
    months.put('Feb', 2);
    months.put('Mar', 3);
    months.put('Apr', 4);
    months.put('May', 5);
    months.put('Jun', 6);
    months.put('Jul', 7);
    months.put('Aug', 8);
    months.put('Sep', 9);
    months.put('Oct', 10);
    months.put('Nov', 11);
    months.put('Dec', 12);
  }
  
  public Date parse(String raw) {
    String[] split = raw.split('-');

    Integer day = Integer.valueOf(split[0]);
    Integer month = months.get(split[1]);
    Integer year = Integer.valueOf(split[2]);
    if (year < 100) {
      year += 2000;
    }
    return Date.newInstance(year, month, day);
  }
  
  public Date parseDDMMYYY(String raw) {
  	//System.assertEquals('foo', raw);
    Pattern p = Pattern.compile('([0-9]{2})\\/([0-9]{2})\\/([0-9]{4}).*');
    Matcher pm = p.matcher(raw);
    if (!pm.matches()) {
      throw new SomeException('Unable to extract date from "' + raw + '"');
    }
    Integer day = Integer.valueOf(pm.group(1));
    Integer month = Integer.valueOf(pm.group(2));
    Integer year = Integer.valueOf(pm.group(3));
    return Date.newInstance(year, month, day);
  }
}