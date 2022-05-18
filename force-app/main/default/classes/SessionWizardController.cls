public with sharing class SessionWizardController {

  @TestVisible private static Boolean throwException = false;

  @AuraEnabled(cacheable=true) // To call an Apex method imperatively, you can choose to set cacheable=true
  public static List<Venue__c> findVenues(String queryTerm) {
    try {
      System.debug(throwException);
      if(throwException) {
        QueryException e = new QueryException();
        throw e;
      }
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
  public static Session createSessionVenues(String sessionId) {
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

  @AuraEnabled
  public static Boolean simpleSessionVenuesCreation(List<Session__c> sessions) {

    if(sessions.isEmpty()) { return false; }
    
    List<Session_Venue__c> sessionVenueList = new List<Session_Venue__c>();

    for(Session__c s : sessions) {
      List<Venue__c> sectionsList = new List<Venue__c>([SELECT Id FROM Venue__c WHERE Venue__c =:s.Venue__c AND RecordType.DeveloperName ='Venue_Section']); // Query to retrieve the Sections related list from the Venue of the Session 
      if(sectionsList.isEmpty()) { return true; }

      for(Venue__c venue : sectionsList) {
        Session_Venue__c sessionVenue = new Session_Venue__c();
        sessionVenue.Price__c = s.session_Price__c;
        sessionVenue.Session__c = s.Id;
        sessionVenue.Venue__c = venue.Id;
        System.debug(LoggingLevel.INFO, sessionVenue);
        sessionVenueList.add(sessionVenue);
      }
    }
    try {
      insert sessionVenueList;
      return true;
    } catch (Exception e) {
      System.debug(e.getMessage());
      return false;
    }
  }

  @AuraEnabled
  public static Boolean cloneSessionsAndSessionVenues(List<Id> sessionIdList, String peridiocityValue) {

      System.debug(LoggingLevel.INFO, sessionIdList);
      System.debug(LoggingLevel.INFO, peridiocityValue);
      if(sessionIdList.isEmpty()) {
        return false; 
      }

      List<Session__c> sessions = [SELECT Id, Date__c, Session__c, Start_Time__c, End_Time__c, Venue__c, Session_Price__c FROM Session__c WHERE Id IN :sessionIdList];
      List<Event__c> endDate = [SELECT Finish_Date__c FROM Event__c WHERE Id = :sessions.get(0).Session__c];
      System.debug(LoggingLevel.INFO, endDate);
      List<Session__c> newSessions = new List<Session__c>();
      Session ses;
      //Date endDate = sessions.get(0).Session__r.Finish_Date__c;
      //List<Session_Venue__c> sessionVenues = [SELECT Id FROM Session_Venue__c WHERE Session__c IN :sessionIdList];
      //List<Session_Venue__c> newSessionVenues = new List<Session_Venue__c>();


      switch on peridiocityValue {
        // Clonagem de sessões diárias
        when 'Daily' {
            for(Session__c s : sessions) {
              for(Date sessionDate = s.Date__c.addDays(1); sessionDate <= endDate.get(0).Finish_Date__c; sessionDate = sessionDate.addDays(1)) {
                Session__c newSession = s.clone(false, true, false, false);
                newSession.Date__c = sessionDate;
                System.debug(LoggingLevel.INFO, sessionDate);
                System.debug(LoggingLevel.INFO, endDate.get(0).Finish_Date__c);
                newSessions.add(newSession);
              }
            } 
        }

        // Clonagem de sessões semanais
        when 'Weekly' {
            for(Session__c s : sessions) {
              for(Date sessionDate = s.Date__c.addDays(7); sessionDate <= endDate.get(0).Finish_Date__c; sessionDate = sessionDate.addDays(7)) {
                Session__c newSession = s.clone(false, true, false, false);
                newSession.Date__c = sessionDate;
                System.debug(LoggingLevel.INFO, sessionDate);
                newSessions.add(newSession);
              }
            }
        }

        // Clonagem de sessões mensais
        when 'Monthly' {
              for(Session__c s : sessions) {
              for(Date sessionDate = s.Date__c.addMonths(1); sessionDate <= endDate.get(0).Finish_Date__c; sessionDate = sessionDate.addMonths(1)) {
                Session__c newSession = s.clone(false, true, false, false);
                newSession.Date__c = sessionDate;
                System.debug(LoggingLevel.INFO, sessionDate);
                newSessions.add(newSession);
              }
            }
        }

        // Clonagem de sessões anuais
        when 'Annualy' {
          for(Session__c s : sessions) {
            for(Date sessionDate = s.Date__c.addYears(1); sessionDate <= endDate.get(0).Finish_Date__c; sessionDate = sessionDate.addYears(1)) {
              Session__c newSession = s.clone(false, true, false, false);
              newSession.Date__c = sessionDate;
              System.debug(LoggingLevel.INFO, sessionDate);
              newSessions.add(newSession);
            }
          }
        }
        
        when else {
          System.debug(LoggingLevel.INFO, 'else condition');
          return false;
        }
      }
      try {
        if(newSessions.isEmpty()) {
          return false; 
        }
        insert newSessions;
        // Criação de sessionVenues
        Boolean result = simpleSessionVenuesCreation(newSessions);
        System.debug(LoggingLevel.INFO, result);
        return result; 
      }
      catch(Exception e) {
        System.debug(e.getMessage());
        return false;
      }
      
  }

}