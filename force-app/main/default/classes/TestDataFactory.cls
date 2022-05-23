@isTest
public class TestDataFactory {

    // For Setup Wizard

    public static List<Venue__c> createVenues(Integer numberOfVenues) {
        List<Venue__c> venues = new List<Venue__c>();
        Id recordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get('Venue').getRecordTypeId();
        for(Integer i=0; i<numberOfVenues; i++) {
            Venue__c venue = new Venue__c();
            venue.Name = 'Venue-'+ (i+1);
            venue.Capacity__c = 100;
            venue.RecordTypeId = recordTypeId; 
            venues.add(venue);
        }
        
        insert venues;
        return venues;
    }


    public static List<Venue__c> createSections(Integer numberOfSections, Id venueId) {
        List<Venue__c> sections = new List<Venue__c>();
        Id recordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get('Venue_Section').getRecordTypeId();
        for(Integer i=0; i<numberOfSections; i++) {
            Venue__c section = new Venue__c();
            section.Name = 'Section- '+ i;
            section.Capacity__c = 1;
            section.RecordTypeId = recordTypeId;
            section.Venue__c = venueId;
            sections.add(section);
        }

        insert sections;
        return sections;
    }


    // For Session Wizard

    public static List<Session__c> createSessions(Integer numberOfSessions, String venueId, String eventId) {
        List<Session__c> sessions = new List<Session__c>();
        Time newTime = Time.newInstance(3, 3, 3, 0);

        for(Integer i=0; i<numberOfSessions; i++) {
            Session__c session = new Session__c();
            session.Session__c = eventId;
            session.Venue__c = venueId;
            session.Date__c = Date.today(); 
            session.Start_Time__c = newTime;
            session.End_Time__c = newTime.addHours(1);
            session.Session_Price__c = 1;
            sessions.add(session);
        }

        insert sessions;
        //System.debug(LoggingLevel.INFO, sessions);
        return sessions;
    }


    public static List<Event__c> createEvents(Integer numberOfEvents, Id userId, Date startDate, Date finishDate, String Name) {
        List<Event__c> events = new List<Event__c>();

        for(Integer i=0; i<numberOfEvents; i++) {
            Event__c event = new Event__c();
            event.Name = Name + ' ' + (i+1);
            event.Event_Manager__c = userId;
            event.Start_Date__c = startDate;
            event.Finish_Date__c = finishDate; 
            event.Sale_Start_Date__c = startDate;
            event.Sale_Finish_Date__c = startDate;
            events.add(event);
        }

        insert events;
        //System.debug(LoggingLevel.INFO, events);
        return events;
    }
}
