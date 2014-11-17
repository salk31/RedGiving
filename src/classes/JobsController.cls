public with sharing class JobsController {
  public List<AsyncApexJob> jobs {get;set;}
      
  public PageReference listJobs() {
    jobs = [SELECT TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, 
                                    CreatedDate, CreatedById, CompletedDate 
                                    , ExtendedStatus From AsyncApexJob 
                                    WHERE ApexClass.Name = 'AttachmentUploadBatchable'
                                    ORDER BY CreatedDate desc];

    return null;
  }
}