public with sharing class SessionWizardController {

  @AuraEnabled(cacheable=true)
  public static List<Venue__c> findVenues(String queryTerm, Id recordId) {
    try {
      String key = '%' + queryTerm + '%';
      return [SELECT Id, Name FROM Venue__c WHERE Name LIKE :key AND Active__c = True AND RecordType.DeveloperName ='Venue'];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  
  public SessionWizardController() {
  }
}
