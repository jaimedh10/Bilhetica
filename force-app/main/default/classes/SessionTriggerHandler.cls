public with sharing class SessionTriggerHandler extends TriggerHandler {
    
    public override void beforeUpdate() {
        fillSessionDT(trigger.new);
        checkMaxCapacity(trigger.new);

    }
    public override void beforeInsert() {
        fillSessionDT(trigger.new);
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
    
    // Method that verifies if the maximum capacity of the Venue has been reached, considering the number of tickets sold
    private static void checkMaxCapacity(List<Session__c> sessionList) {
        try {
            for(Session__c s : sessionList) {
                System.debug(s.Max_Capacity__c );
                System.debug(s.Tickets_Sold__c);
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
                Set<Id> eventVenues = venuesByEvent.get(s.Session__c);
                eventVenues.add(s.Venue__c);
                venuesByEvent.put(s.Session__c, eventVenues);
            } else {
                Set<Id> eventVenues = new Set<Id>();
                eventVenues.add(s.Venue__c);
                venuesByEvent.put(s.Session__c, eventVenues);
            }
        }

        List<Event_Venue__c> newEventVenues = new List<Event_Venue__c>();
        if(!venuesByEvent.keySet().isEmpty()) {
            // Query to check if there is already a Event Venue for that Event. If not, proceeds to create one.
            Integer numberOfEventVenues = [SELECT Id FROM Event_Venue__c WHERE Event__c IN :venuesByEvent.keySet()].size();
            if(numberOfEventVenues == 0) {
                for(Id eventId : venuesByEvent.keySet()) {
                    Set<Id> venues = venuesByEvent.get(eventId);
                    for(Id venueId : venues) {
                        Event_Venue__c eventVenue = new Event_Venue__c();
                        eventVenue.Event__c = eventId; 
                        eventVenue.Venue__c = venueId;
                        newEventVenues.add(eventVenue);
                    }
                }
            } 
        }

        if(!newEventVenues.isEmpty()) {
            try {
                insert newEventVenues;
                System.debug(LoggingLevel.INFO, newEventVenues);
            }catch (Exception e) {
                System.debug('Error on insert ' + e.getMessage() + ' in line ' + e.getLineNumber());
            }
        }
    }
}