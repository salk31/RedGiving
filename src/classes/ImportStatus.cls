public class ImportStatus {

  private Integer rowCount = 0;

  private Integer pageCount = 0;
  
  private Integer contactCount = 0;
  
  private Integer donationCount = 0;
  
  private SSSCsvRow context;

  public void rowInc() {
    rowCount++;
  }

  public void pageCountInc() {
    pageCount++;
  }
  
  public void contactCountInc() {
    contactCount++;
  }
  
  public void donationCountInc() {
    donationCount++;
  }

  public void email(Database.BatchableContext info) {
    AsyncApexJob job = [Select Id, Status, NumberOfErrors, JobItemsProcessed,  
        TotalJobItems, CreatedBy.Email, ExtendedStatus  
        from AsyncApexJob where Id = :info.getJobId()]; 

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    String emailAddr = job.CreatedBy.Email;

    String[] toAddresses = new String[] {emailAddr};
    mail.setToAddresses(toAddresses);

    mail.setSubject('RedGiving import report');

    String html = ''
        + '<h3>RedGiving import report.</h3>';
        
        
    if (job.NumberOfErrors > 0) {
      html +=
          '<p><strong>'
          + 'Warning, some errors during import. '
          + 'The bottom of this e-mail contains debug information. '
          + 'If appropriate please forward this e-mail to support@redgiving.com'
          + '</strong></p>';
    }
    
    html +=
        '<p>'
        + 'Rows processed: ' + rowCount + '<br/>'
        + 'New pages imported: ' + pageCount + '<br/>'
        + 'New contacts imported: ' + contactCount + '<br/>'
        + 'New donactions imported: ' + donationCount + '<br/>'
        + '</p>';
    html +=
        '<p>'
        + 'If you have any problems please contact support@redgiving.com'
        + '</p>';
    
    if (job.NumberOfErrors > 0) {
      html += 
          '<hr/><pre>'
          + job.ExtendedStatus.replaceAll('<', '&lt;')
          + '</pre><hr/>';
    }
    
    

    mail.setHtmlBody(html);

    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
}