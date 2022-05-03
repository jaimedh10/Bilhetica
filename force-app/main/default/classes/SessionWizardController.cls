public with sharing class SessionWizardController {

  @AuraEnabled(cacheable=true) // To call an Apex method imperatively, you can choose to set cacheable=true
  public static List<Venue__c> findVenues(String queryTerm, Id recordId) {
    try {
      String key = '%' + queryTerm + '%';
      return [SELECT Id, Name FROM Venue__c WHERE Name LIKE :key AND Active__c = True AND RecordType.DeveloperName ='Venue'];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class Session {
    @AuraEnabled
    public Id sessionId;
    @AuraEnabled
    public List<Id> sessionVenuesId;
  }

  @AuraEnabled
  public static Session createSessionVenues(Id sessionId) {
    if(String.isBlank(sessionId)) { return null; }
    
    List<Session__c> session = [SELECT Venue__c, Session_Price__c FROM Session__c WHERE Id =:sessionId LIMIT 1];
    if(session.isEmpty()) { return null; }
    Session selectedSession = new Session();
    selectedSession.sessionId = sessionId;
    
    Decimal sessionPrice = session.get(0).session_Price__c;
    List<Venue__c> sectionsList = new List<Venue__c>([SELECT Id, Name FROM Venue__c WHERE Venue__c =:session.get(0).Venue__c AND RecordType.DeveloperName ='Venue_Section']); // Query to retrieve the Sections related list from the Venue of the Session 
    if(sectionsList.isEmpty()) { return selectedSession; }

    List<Session_Venue__c> sessionVenueList = new List<Session_Venue__c>();

    for(Venue__c venue : sectionsList) {
      Session_Venue__c sessionVenue = new Session_Venue__c();
      sessionVenue.Price__c = sessionPrice;
      sessionVenue.Session__c = sessionId;
      sessionVenue.Venue__c = venue.Id;
      System.debug(LoggingLevel.INFO, sessionVenue);
      sessionVenueList.add(sessionVenue);
    }
    try {
      insert sessionVenueList;
      List<Session_Venue__c> createdSessionVenues = [SELECT Id FROM Session_Venue__c WHERE Session__c =:sessionId];
      if( !createdSessionVenues.isEmpty()) {
        selectedSession.sessionVenuesId = new List<Id>();
        for (Session_Venue__c createdSessionVenue : createdSessionVenues) {
          selectedSession.sessionVenuesId.add(createdSessionVenue.Id);
        }
      }
      System.debug(selectedSession);
      return selectedSession;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    
  }
  
  public SessionWizardController() {
  }
}
