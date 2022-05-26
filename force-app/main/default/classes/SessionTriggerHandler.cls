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
        updateEventVenue(trigger.oldMap, trigger.newMap);
    }


    // Método de preenchimento do campo data e hora da sessão (usado posteriormente no flow)
    private static void fillSessionDT(List<Session__c> sessionList) {

        try {
            for(Session__c s : sessionList) {
                s.Session_D_T__c = DateTime.newInstanceGmt(s.Date__c, s.Start_Time__c);
            }
        } catch (Exception e) {
            System.debug('Erro no update ' + e.getMessage() + ' na linha ' + e.getLineNumber());
        }
    }
    
    // Método que verifica se a lotação máxima do espaço já foi atingida tendo em consideração o número de bilhetes vendidos
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
            System.debug('Erro no update ' + e.getMessage() + ' na linha ' + e.getLineNumber());
        }
    }

    // Método responsável por criar o espaço do evento, utilizando o espaço da sessão
    private static void createEventVenue(List<Session__c> sessionList) {
        List<Event_Venue__c> newEventVenues = new List<Event_Venue__c>();

        for(Session__c s : sessionList) {
            List<Event_Venue__c> eventVenues = [SELECT Id, Event__c, Venue__c FROM Event_Venue__c WHERE Event__c =:s.Session__c AND Venue__c =:s.Venue__c];
            if(!eventVenues.isEmpty()) { break;}
            Event_Venue__c eventVenue = new Event_Venue__c();
            eventVenue.Event__c = s.Session__c;
            eventVenue.Venue__c = s.Venue__c;
            newEventVenues.add(eventVenue);
        }

        try {
            insert newEventVenues;
            System.debug(LoggingLevel.INFO, newEventVenues);
        }catch (Exception e) {
            System.debug('Erro no insert ' + e.getMessage() + ' na linha ' + e.getLineNumber());
        }
    }

    // Método responsável por atualizar o espaço e/ou o evento da related list 'Event Venues'
    private static void updateEventVenue(Map<Id, Session__c> oldSession, Map<Id, Session__c> newSession) {
        List<Event_Venue__c> eventVenues = new List<Event_Venue__c>();
         
        // não foi alterado nenhum campo no update
        if(oldSession.equals(newSession)) {
            return;
        }

        for(Session__c s : newSession) {

        }

        eventVenues = [SELECT Id, Event__c, Venue__c, Active__c FROM Event_Venue__c WHERE Event__c =:newSessionList.get(i).Session__c AND Venue__c =:newSessionList.get(i).Venue__c]; 

        for(Id id : oldSession.keySet()) {
            if(newSession.containsKey(id) == true) {
                if(oldSession.get(id).Venue__c == newSession.get(id).Venue__c) {
                    break;
                }
                // ver se o EV já existe
                if() {

                }
                // caso não exista EV, cria
                else {
                    Event_Venue__c eventVenue = new Event_Venue__c();
                    eventVenue.Event__c = newSessionList.get(id).Session__c;
                    eventVenue.Venue__c = newSessionList.get(id).Venue__c;
                    eventVenues.add(eventVenue);
                }
            }
        }

        
        for(Session__c s : newSessionList) {
            if(eventVenues.get(0).Event__c != newSessionList.get(i).Session__c && eventVenues.get(0).Venue__c == newSessionList.get(i).Venue__c) {
                System.debug(LoggingLevel.INFO, 'if' + eventVenues);
                continue;
            } 
        }

        try {
            update eventVenues;
            //System.debug(LoggingLevel.INFO, eventVenues);
        }catch (Exception e) {
            System.debug('Erro no insert ' + e.getMessage() + ' na linha ' + e.getLineNumber());
        }
    }

    private static void updateEventVenue(List<Session__c> oldSessionList, List<Session__c> newSessionList) {
        /* List<Event_Venue__c> eventVenues = new List<Event_Venue__c>();

        for(Integer i = 0; i < oldSessionList.size(); i++) {
            if(oldSessionList.get(i).Session__c != newSessionList.get(i).Session__c || oldSessionList.get(i).Venue__c != newSessionList.get(i).Venue__c) {
                eventVenues = [SELECT Id, Event__c, Venue__c, Active__c FROM Event_Venue__c WHERE Event__c =:oldSessionList.get(i).Session__c AND Venue__c =:oldSessionList.get(i).Venue__c LIMIT 1]; 
                if(eventVenues.isEmpty()) { break;}
                //System.debug(LoggingLevel.INFO, eventVenues);
                for(Integer j = 0; j<eventVenues.size(); j++) {
                    if(eventVenues.get(j).Event__c == oldSessionList.get(i).Session__c && eventVenues.get(j).Venue__c == oldSessionList.get(i).Venue__c) {
                        eventVenues.get(j).Active__c = false;
                        System.debug(LoggingLevel.INFO, 'if' + eventVenues);
                        continue;
                    }
                    eventVenues.get(j).Event__c = newSessionList.get(i).Session__c;
                    eventVenues.get(j).Venue__c = newSessionList.get(i).Venue__c;
                }
            }
        }

        try {
            update eventVenues;
            //System.debug(LoggingLevel.INFO, eventVenues);
        }catch (Exception e) {
            System.debug('Erro no insert ' + e.getMessage() + ' na linha ' + e.getLineNumber());
        } */
    }

}