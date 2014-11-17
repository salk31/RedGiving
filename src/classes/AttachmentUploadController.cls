public with sharing class AttachmentUploadController {

  public Attachment attachment {
    get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
    }
    set;
  }

  // http://salesforce.stackexchange.com/questions/11805/blob-is-not-a-valid-utf-8-string-error?atw=1
  // https://developer.salesforce.com/forums/ForumsMain?id=906F00000008ygFIAQ
  public static String blobToString(Blob input, String inCharset){
    String hex = EncodingUtil.convertToHex(input);
    System.assertEquals(0, hex.length() & 1);
    final Integer bytesCount = hex.length() >> 1;
    String[] bytes = new String[bytesCount];
    for(Integer i = 0; i < bytesCount; ++i)
        bytes[i] =  hex.mid(i << 1, 2);
    return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
  }

  public PageReference upload() {
    String raw;
    
    try {
      raw = attachment.body.toString();
      // XXX need test
      if (65279 == raw.codePointAt(0)) {
        raw = raw.substring(1);
      }
    } catch (StringException ex) {
      // TODO only continue if 'BLOB is not a valid UTF-8 string'
      raw = blobToString(attachment.body, 'Windows-1252');
    }


    AttachmentUploadBatchable b =
        new AttachmentUploadBatchable(new SSSCsvReader(raw));   
    ID myBatchJobID = Database.executeBatch(b, 10);


    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Batch upload started ' + myBatchJobID));
    return Page.redGivingJobs;
  }


}