public with sharing class SessionTriggerHandler extends TriggerHandler {
    
    public override void beforeUpdate() {
        fillSessionDT(trigger.new);
        checkMaxCapacity(trigger.new);

    }
    public override void beforeInsert() {
        fillSessionDT(trigger.new);
        blockDuplicateSession(trigger.new);
    }

    public override void afterInsert() {
        createEventVenue(trigger.new);
    }

    public override void afterUpdate() {
        //updateEventVenue(trigger.oldMap, trigger.newMap);
    }


    // Method for filling in the Session date and time field (used later in a Flow)
    private static void fillSessionDT(List<Session__c> sessionList) {

        try {
            for(Session__c s : sessionList) {
                s.Session_D_T__c = DateTime.newInstanceGmt(s.Date__c, s.Start_Time__c);
            }
        } catch (Exception e) {
            System.debug('Error updating ' + e.getMessage() + ' in line ' + e.getLineNumber());
        }
    }

    private static void blockDuplicateSession(List<Session__c> sessionList) {
        Set<Id> venueId = new Set<Id>();
        for(Session__c s : sessionList) {
            venueId.add(s.Venue__c);
        }

        List<Session__c> sessions = [SELECT Id, Name, Session__c, Venue__c, Date__c, Start_Time__c, End_Time__c FROM Session__c WHERE Venue__c IN :venueId];
        if(!sessions.isEmpty()) {
            for(Session__c ses : sessionList) {
                for(Session__c s : sessions) {
                    if(s.Venue__c != ses.Venue__c) {
                        continue;
                    }
                    // Duplicate found
                    else if(ses.Date__c == s.Date__c && ses.Start_Time__c >= s.Start_Time__c && ses.End_Time__c <= s.End_Time__c || ses.Date__c == s.Date__c && ses.Start_Time__c <= s.Start_Time__c && ses.End_Time__c >= s.End_Time__c) {
                        ses.addError('Current session is overlapping another session.');
                        /* System.debug(ses);
                        System.debug(s); */
                    }
                }    
            }
        }
    }
    
    // Method that verifies if the maximum capacity of the Venue has been reached, considering the number of tickets sold
    private static void checkMaxCapacity(List<Session__c> sessionList) {
        try {
            for(Session__c s : sessionList) {
                /* System.debug(s.Max_Capacity__c );
                System.debug(s.Tickets_Sold__c); */
                if(s.Tickets_Sold__c < s.Max_Capacity__c) {
                    continue;
                }
                s.Status__c = 'Sold Out';
            }
        } catch (Exception e) {
            System.debug('Error updating ' + e.getMessage() + ' in line ' + e.getLineNumber());
        }
    }

    // Method responsible for creating the Event Venue and ensuring that no duplicate records are created
    private static void createEventVenue(List<Session__c> sessionList) {
        Map<Id, Set<Id>> venuesByEvent = new Map<Id, Set<Id>>();

        // Loop on created Sessions, which creates a Map with the Event Id as Key and the Venues Ids as values
        for(Session__c s : sessionList) {
            // Verify if that Event is Mapped, otherwise create a Set and add the Venues to the Set
            if(venuesByEvent.containsKey(s.Session__c)) {
                Set<Id> currentEventVenues = venuesByEvent.get(s.Session__c);
                currentEventVenues.add(s.Venue__c);
                venuesByEvent.put(s.Session__c, currentEventVenues);
            } else {
                Set<Id> currentEventVenues = new Set<Id>();
                currentEventVenues.add(s.Venue__c);
                venuesByEvent.put(s.Session__c, currentEventVenues);
            }
        }

        System.debug(LoggingLevel.INFO, venuesByEvent);
        List<Event_Venue__c> newEventVenues = new List<Event_Venue__c>();
        if(!venuesByEvent.keySet().isEmpty()) {
            // Query to retrieve the Venue from the Event Venues based on the Event.
            List<Event_Venue__c> eventVenues = [SELECT Id, Venue__c FROM Event_Venue__c WHERE Event__c IN :venuesByEvent.keySet()];

            // Add the Venues Ids to a Set
            Set<Id> venuesSet = new Set<Id>();
            for(Event_Venue__c ev : eventVenues) {
                venuesSet.add(ev.Venue__c); 
            }

            for(Id eventId : venuesByEvent.keySet()) {
                Set<Id> venues = venuesByEvent.get(eventId);
                System.debug(venues);
                System.debug(venuesSet);
                // If the venuesSet matches the venuesByEvent Set does not create a Event Venue, otherwise creates 1
            
                for(Id venueId : venues) {
                    if(venuesSet.contains(venueId)) {
                        break;
                    }
                    Event_Venue__c eventVenue = new Event_Venue__c();
                    eventVenue.Event__c = eventId; 
                    eventVenue.Venue__c = venueId;
                    newEventVenues.add(eventVenue);
                }
            }
        }

        System.debug(LoggingLevel.INFO, newEventVenues);
        if(!newEventVenues.isEmpty()) {
            try {
                insert newEventVenues;
            }catch (Exception e) {
                System.debug('Error on insert ' + e.getMessage() + ' in line ' + e.getLineNumber());
            }
        }
    }
}