@isTest
private class SessionWizardControllerTest {
    @TestSetup
    static void makeData(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Seller' LIMIT 1];
        User usr = new User(LastName = 'Test',
            Alias = 'testcase',
            Email = 'testcase@gmail.com',
            Username = 'testcase@gmail.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert usr;
        
        String userId = [SELECT Id From User WHERE Alias = 'testcase'].Id;
        Date startDate = Date.today();
        Date finishDate = Date.today().addMonths(2);
        List<Event__c> events = TestDataFactory.createEvents(1, userId, startDate, finishDate);
        List<Venue__c> venues = TestDataFactory.createVenues(1);
        List<Venue__c> sections = TestDataFactory.createSections(1, venues.get(0).Id);
        List<Session__c> sessions = TestDataFactory.createSessions(50, venues.get(0).Id, events.get(0).Id);
        //List<Venue__c> sessionVenues = SessionWizardController.createSessionVenues(, );
        
        /* System.runAs(user){
        } */
    }

    // Positive Tests

    @isTest
    static void testfindVenues() {
        String queryTerm = 'Venue';
        List<Venue__c> venues = SessionWizardController.findVenues(queryTerm);
        System.assert(venues.size()==1);
    }

    @isTest 
    static void testCreateSessionVenues() {
        Id sessionId = [SELECT Id FROM Session__c LIMIT 1].Id;
        
        SessionWizardController.createSessionVenues(sessionId);
        List<Session_Venue__c> sessionVenues = [SELECT Id FROM Session_Venue__c WHERE Session__c =:sessionId];
        System.assert(sessionVenues.size()==1);
    }

    @isTest
    static void testSimpleSessionVenuesCreation() {
        List<Session__c> sessions = [SELECT Id, Name, Venue__c, Session_Price__c FROM Session__c LIMIT 1];
        Boolean result = SessionWizardController.simpleSessionVenuesCreation(sessions);
        System.assertEquals(true, result);
    }

    @isTest
    static void testDailyCloneSessionsAndSessionVenues() {
        List<Id> sessions = new List<Id>();
        
        Id session = [SELECT Id FROM Session__c LIMIT 1].Id;
        sessions.add(session);
        Boolean result = SessionWizardController.cloneSessionsAndSessionVenues(sessions, 'Daily');
        System.assertEquals(true, result);
    }

    @isTest
    static void testWeeklyCloneSessionsAndSessionVenues() {
        List<Id> sessions = new List<Id>();
        
        Id session = [SELECT Id FROM Session__c LIMIT 1].Id;
        sessions.add(session);
        Boolean result = SessionWizardController.cloneSessionsAndSessionVenues(sessions, 'Weekly');
        System.assertEquals(true, result);
    }

    @isTest
    static void testMonthlyCloneSessionsAndSessionVenues() {
        List<Id> sessions = new List<Id>();
        
        Id session = [SELECT Id FROM Session__c LIMIT 1].Id;
        sessions.add(session);
        Boolean result = SessionWizardController.cloneSessionsAndSessionVenues(sessions, 'Monthly');
        System.assertEquals(true, result);
    }

    @isTest
    static void testAnnualyCloneSessionsAndSessionVenues() {
        List<Id> sessions = new List<Id>();
        
        Id session = [SELECT Id FROM Session__c LIMIT 1].Id;
        sessions.add(session);
        Boolean result = SessionWizardController.cloneSessionsAndSessionVenues(sessions, 'Annualy');
        System.assertEquals(false, result);
    }

    // Bulk Testing 

    /* @isTest 
    static void bulkTestCreateSessionVenues() {
        Id sessionId = [SELECT Id FROM Session__c LIMIT 1].Id;
        
        SessionWizardController.createSessionVenues(sessionId);
        List<Session_Venue__c> sessionVenues = [SELECT Id FROM Session_Venue__c WHERE Session__c =:sessionId];
        System.assert(sessionVenues.size()==50);
    }

    @isTest
    static void bulkTestsimpleSessionVenuesCreation() {
        List<Session__c> sessions = [SELECT Id, Name, Venue__c, Session_Price__c FROM Session__c LIMIT 50];
        Boolean result = SessionWizardController.simpleSessionVenuesCreation(sessions);
        System.assertEquals(true, result);
    } */

    // Negative Tests

    @isTest
    static void testfindVenuesFail() {
        SessionWizardController.throwException = true;
        Test.startTest();
        try {
            List<Venue__c> venues = SessionWizardController.findVenues('abc');
        }catch(AuraHandledException e) {
            System.debug(e.getMessage());
            System.assert(e.getMessage().length()>0);
            //System.assertEquals(e.getMessage(), e.getMessage());  
        }
        Test.stopTest();
    }

    /* @isTest
    static void testsimpleSessionVenuesCreationFail() {
        List<Session__c> sessions = [SELECT Id, Name FROM Session__c LIMIT 1];
        
        try {
            SessionWizardController.simpleSessionVenuesCreation(sessions);
        }catch(Exception e) {
            System.debug(e.getMessage());
            System.assert(e.getMessage().length()>0);
        }
    } */
    /* @isTest
    static void createSessionVenuesFail() {
        Id eventId = [SELECT Id FROM Event__c LIMIT 1].Id;
        
        Test.startTest();
        try {
            SessionWizardController.createSessionVenues(sessionId);
        }catch(AuraHandledException e) {
            System.debug(e.getMessage());
            //System.assertEquals(e.getMessage(), e.getMessage());  
        }
        Test.stopTest();
            
    } */

}
