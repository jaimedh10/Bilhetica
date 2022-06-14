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
        String dailyEventName = 'Daily Event', weeklyEventName = 'Weekly Event', monthlyEventName = 'Monthly Event', annualyEventName = 'Annualy Event';
        String userId = [SELECT Id From User WHERE Alias = 'testcase'].Id;
        Date startDate = Date.today();
        Date finishDateDailyEvent=Date.today().addDays(2), finishDateWeeklyEvent=Date.today().addDays(14);
        Date finishDateMonthlyEvent=Date.today().addMonths(2), finishDateAnnualyEvent = Date.today().addYears(2);
        Time startTime = Time.newInstance(3, 3, 3, 0);

        
        List<Event__c> dailyEvents = TestDataFactory.createEvents(1, userId, startDate, finishDateDailyEvent, dailyEventName);
        List<Event__c> weeklyEvents = TestDataFactory.createEvents(1, userId, startDate, finishDateWeeklyEvent, weeklyEventName);
        List<Event__c> monthlyEvents = TestDataFactory.createEvents(1, userId, startDate, finishDateMonthlyEvent, monthlyEventName);
        List<Event__c> annualyEvents = TestDataFactory.createEvents(1, userId, startDate, finishDateAnnualyEvent, annualyEventName);
        
        List<Venue__c> venues = TestDataFactory.createVenues(2);
        List<Venue__c> sections = TestDataFactory.createSections(1, venues.get(0).Id);
        List<Session__c> dailySessions = TestDataFactory.createSessions(1, venues.get(0).Id, dailyEvents.get(0).Id, startTime);
        List<Session__c> weeklySessions = TestDataFactory.createSessions(1, venues.get(0).Id, weeklyEvents.get(0).Id, startTime.addHours(1));
        List<Session__c> monthlySessions = TestDataFactory.createSessions(1, venues.get(1).Id, monthlyEvents.get(0).Id, startTime.addHours(2));
        List<Session__c> annualySessions = TestDataFactory.createSessions(1, venues.get(0).Id, annualyEvents.get(0).Id, startTime.addHours(3));

        String sectionId = [SELECT Id FROM Venue__c LIMIT 1]?.Id;
        List<Row__c> rows = TestDataFactory.createRows(1, 1, sectionId);
        String seatId = [SELECT Id FROM Seat__c LIMIT 1]?.Id;
        String sessionId = [SELECT Id FROM Session__c WHERE Session__r.Name = 'Monthly Event 1' LIMIT 1]?.Id;
        SessionWizardController.createSessionVenues(sessionId);
        String sessionVenueId = [SELECT Id FROM Session_Venue__c WHERE Session__c = :sessionId LIMIT 1]?.Id;
        List<Contact> contacts = TestDataFactory.createContacts(1);
        String contactId = [SELECT Id FROM Contact LIMIT 1]?.Id;
        List<Ticket__c> tickets = TestDataFactory.createTickets(2, seatId, sessionId, sessionVenueId, contactId);

        // Data to Test checkMaxCapacity method 
        String dailySessionId = [SELECT Id FROM Session__c WHERE Session__r.Name = 'Daily Event 1' LIMIT 1]?.Id;
        SessionWizardController.createSessionVenues(dailySessionId);
        String dailySessionVenueId = [SELECT Id FROM Session_Venue__c WHERE Session__c = :dailySessionId LIMIT 1]?.Id;
        TestDataFactory.createTickets(1, seatId, dailySessionId, dailySessionVenueId, contactId);
        /* System.runAs(user){
        } */
    }

    // Positive Tests

    @isTest
    static void testfindVenues() {
        String queryTerm = 'Venue';
        List<Venue__c> venues = SessionWizardController.findVenues(queryTerm);
        System.assert(venues.size() > 0);
    }

    @isTest 
    static void testCreateSessionVenues() {
        Id sessionId = [SELECT Id FROM Session__c LIMIT 1].Id;
        
        SessionWizardController.createSessionVenues(sessionId);
        List<Session_Venue__c> sessionVenues = [SELECT Id FROM Session_Venue__c WHERE Session__c =:sessionId];
        System.assert(sessionVenues.size()>0);
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
        
        Id session = [SELECT Id FROM Session__c WHERE Session__r.Name='Daily Event 1' LIMIT 1].Id;
        sessions.add(session);
        Boolean result = SessionWizardController.cloneSessionsAndSessionVenues(sessions, 'Daily');
        System.assertEquals(true, result);
    }

    @isTest
    static void testWeeklyCloneSessionsAndSessionVenues() {
        List<Id> sessions = new List<Id>();
        
        Id session = [SELECT Id FROM Session__c WHERE Session__r.Name='Weekly Event 1' LIMIT 1].Id;
        sessions.add(session);
        Boolean result = SessionWizardController.cloneSessionsAndSessionVenues(sessions, 'Weekly');
        System.assertEquals(true, result);
    }

    @isTest
    static void testMonthlyCloneSessionsAndSessionVenues() {
        List<Id> sessions = new List<Id>();
        
        Id session = [SELECT Id FROM Session__c WHERE Session__r.Name='Monthly Event 1' LIMIT 1].Id;
        sessions.add(session);
        Boolean result = SessionWizardController.cloneSessionsAndSessionVenues(sessions, 'Monthly');
        System.assertEquals(true, result);
    }

    @isTest
    static void testAnnualyCloneSessionsAndSessionVenues() {
        List<Id> sessions = new List<Id>();
        
        Id session = [SELECT Id FROM Session__c WHERE Session__r.Name='Annualy Event 1' LIMIT 1].Id;
        sessions.add(session);
        Boolean result = SessionWizardController.cloneSessionsAndSessionVenues(sessions, 'Annualy');
        System.assertEquals(true, result);
    }

    // Test for SessionTrigger
    @isTest
    static void testUpdateSessionVenue() {
        List<Session__c> sessions = [SELECT Id, Session__c, Status__c, Date__c, Start_Time__c, Session_D_T__c, Max_Capacity__c, Tickets_Sold__c FROM Session__c WHERE Session__r.Name='Daily Event 1' LIMIT 1];
        sessions.get(0).Session__c = [SELECT Id FROM Event__c  WHERE Name='Annualy Event 1' LIMIT 1]?.Id;
        update sessions;

        // Assert for fillSessionDT method
        DateTime sessionDateAndTime = DateTime.newInstanceGmt(sessions.get(0).Date__c, sessions.get(0).Start_Time__c);
        System.assertEquals(sessionDateAndTime, sessions.get(0).Session_D_T__c);
        // Assert for checkMaxCapacity method
        if(sessions.get(0).Max_Capacity__c == sessions.get(0).Tickets_Sold__c) {
            System.assertEquals('Sold Out', sessions.get(0).Status__c);
        }
    }
    

    // Test for TicketTriggerHandler

    @isTest 
    static void testSendPaymentConfirmationEmail() {
        Ticket__c ticket = [SELECT Id, Status__c FROM Ticket__c LIMIT 1];
        ticket.Status__c = 'Paid';
        update ticket;
        System.assertEquals('Paid', ticket.Status__c);
    }

    // Test for TicketCustomController

    // Positive Testing

    @isTest 
    static void testValidateTicket() {
        String ticketId = [SELECT Id FROM Ticket__c WHERE Status__c = 'Paid' LIMIT 1]?.Id;
        Ticket__c updatedTicket = TicketCustomController.validateTicket(ticketId);
        if(updatedTicket == null) {
            System.assertEquals(null, updatedTicket);
        } else {
            System.assertEquals('Invalid', updatedTicket.Status__c);
        }
    }

    @isTest
    static void testCheckQrCode() {
        Ticket__c ticket = [SELECT Id, QRCode_Url__c FROM Ticket__c WHERE Status__c = 'Paid' LIMIT 1];
        Ticket__c updatedTicket = TicketCustomController.checkQrCode(ticket.QRCode_Url__c);
        if(updatedTicket == null) {
            System.assertEquals(null, updatedTicket);
        } else {
            System.assertEquals('Invalid', updatedTicket.Status__c);
        }
    }

    @isTest
    static void testContactTickets() {
        PageReference pageRef = Page.contactTickets;
        Test.setCurrentPage(pageRef);
      
        // Instantiate a new controller with all parameters in the page
        TicketCustomController controller = new TicketCustomController();

        String contactId = [SELECT Id FROM Contact LIMIT 1]?.Id;
        String sessionId = [SELECT Id FROM Session__c LIMIT 1]?.Id;
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', contactId);
        ApexPages.currentPage().getParameters().put('sessionId', sessionId);
    }


    // Bulk Testing 

    /* @isTest 
    static void bulkTestCreateSessionVenues() {
        Id sessionId = [SELECT Id FROM Session__c LIMIT 1]?.Id;
        // Method to create 25 sections for the Venue of the Session
        SessionWizardController.createSessionVenues(sessionId);
        List<Session_Venue__c> sessionVenues = [SELECT Id FROM Session_Venue__c WHERE Session__c =:sessionId];
        System.assert(sessionVenues.size()==25);
    } */

    /* @isTest
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
        }
        Test.stopTest();
    }

    // For TicketCustomController

    @isTest
    static void testEmptyQRCodeUrl() {
        Ticket__c t = TicketCustomController.checkQrCode('');
        System.assertEquals(null, t);
    }

    @isTest
    static void testInvalidTicketId() {
        Ticket__c t = TicketCustomController.validateTicket('123');
        System.assertEquals(null, t);
    }

    @isTest
    static void testValidateNotPaidTicket() {
        String ticketId = [SELECT Id FROM Ticket__c WHERE Status__c != 'Paid' LIMIT 1]?.Id;
        Ticket__c ticket = TicketCustomController.validateTicket(ticketId);
        System.assertEquals(null, ticket);
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
            System.assertEquals(e.getMessage(), e.getMessage());  
        }
        Test.stopTest();
            
    } */

}
