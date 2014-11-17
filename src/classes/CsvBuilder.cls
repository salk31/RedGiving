@isTest
public class CsvBuilder {
  private String content;
  private String header = 'x';
  private String body = 'y';
    
  public CsvBuilder add(String head, String val) {
    header += ',' + head;
    body += ',' + val;
    return this;
  }

  public CsvBuilder eol() {
    if (content == null) {
      content = header + '\n';
    }
    content += body;
    content += '\n';
    
    header = 'x';
    body = 'y';
    return this;
  }

  public String build() {
    return content;
  }
}