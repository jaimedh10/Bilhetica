@isTest
public class TestDataFactory {

    // For Setup Wizard

    public static List<Venue__c> createVenues(Integer numberOfVenues) {
        List<Venue__c> venues = new List<Venue__c>();
        Id recordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get('Venue').getRecordTypeId();
        for(Integer i=0; i<numberOfVenues; i++) {
            Venue__c venue = new Venue__c();
            venue.Name = 'Venue-'+ (i+1);
            venue.Capacity__c = (i+1);
            venue.RecordTypeId = recordTypeId; 
            venues.add(venue);
        }
        
        insert venues;
        return venues;
    }

    public static List<Venue__c> createVenuesWithPredefinedCapacity(Integer numberOfVenues, Integer venueCapacity) {
        List<Venue__c> venues = new List<Venue__c>();
        Id recordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get('Venue').getRecordTypeId();
        for(Integer i=0; i<numberOfVenues; i++) {
            Venue__c venue = new Venue__c();
            venue.Name = 'Venue-'+ (i+1);
            venue.Capacity__c = venueCapacity;
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

    public static List<Session__c> createSessions(Integer numberOfSessions, String venueId, String eventId, Time startTime) {
        List<Session__c> sessions = new List<Session__c>();
        //Time newTime = Time.newInstance(3, 3, 3, 0);

        for(Integer i=0; i<numberOfSessions; i++) {
            Session__c session = new Session__c();
            session.Session__c = eventId;
            session.Venue__c = venueId;
            session.Date__c = Date.today(); 
            session.Start_Time__c = startTime;
            session.End_Time__c = startTime.addHours(1);
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

    // For Ticket Trigger Handler

    public static List<Contact> createContacts(Integer numberOfContacts) {
        List<Contact> contacts = new List<Contact>();

        for(Integer i=0; i<numberOfContacts; i++) {
            //lastName = 'Test ' + (i+1);
            Contact c = new Contact(lastName='Test ' + (i+1), email='jaime.oliveira@loba.pt');
            contacts.add(c);
        }

        insert contacts;
        System.debug(contacts);
        return contacts;
    }

    public static List<Row__c> createRows(Integer numberOfRows, Integer numberOfSeats, String sectionId){
        List<Row__c> rows = new List<Row__c>();

        for(Integer i=0; i<numberOfRows; i++) {
            Row__c row = new Row__c();
            row.Name = 'Row-' + (i+1); 
            row.Number_of_seats__c = numberOfSeats;
            row.Venue__c = sectionId;
            rows.add(row);
        }

        insert rows;
        return rows;
    }

    public static List<Ticket__c> createTickets(Integer numberOfTickets, String seatId, String sessionId, String sessionVenueId, String contactId) {
        List<Ticket__c> tickets = new List<Ticket__c>();

        for(Integer i=0; i<numberOfTickets; i++) {
            Ticket__c ticket = new Ticket__c();
            if(i == 0) {
                ticket.Status__c = 'Paid';
            }
            ticket.Seat__c = seatId;
            ticket.Session__c = sessionId;
            ticket.Session_Venue__c = sessionVenueId;
            ticket.Contact__c = contactId;
            tickets.add(ticket);
            System.debug(ticket.Contact__c);
        }

        insert tickets;
        return tickets;
    }
}
