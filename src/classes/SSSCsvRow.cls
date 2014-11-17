/**
 * Used to read a delimited file.
 */
global class SSSCsvRow {
  private SSSCsvReader reader;
	
  private Integer rowNumber;
	
  private String[] line;
  
  public Map<String, Integer> headingToIndex = new Map<String, Integer>();

  public SSSCsvRow(SSSCsvReader reader, Integer rowNumber, String[] line2){
    this.reader = reader;
    this.rowNumber = rowNumber;
    this.line = line2;
    this.headingToIndex = reader.getHeadingToIndex();
  }

  public SSSCsvReader getReaderX() {
    return reader;
  }

  public String getString(String n) {
    Integer i = headingToIndex.get(n.toLowerCase());
    if (i == null) {
      return ''; // XXX hmmm. better to fail?
    }
    return line[i];
  }
  
  public Boolean hasColumn(String columnName) {
    return headingToIndex.containsKey(columnName.toLowerCase());
  }
  
  public Integer getRowNumber() {
    return rowNumber;
  }
  
  public Map<String, Integer> getFoo() {return headingToIndex;}
  
  public String[] getLine() {return line;}
}