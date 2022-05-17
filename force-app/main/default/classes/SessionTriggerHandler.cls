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


    // o que acontece se o espaço for alterado?
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

}