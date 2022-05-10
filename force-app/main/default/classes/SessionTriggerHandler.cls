public with sharing class SessionTriggerHandler extends TriggerHandler {
    
    public override void beforeUpdate() {
        fillSessionDT(trigger.new);
        checkMaxCapacity(trigger.new);

    }
    public override void beforeInsert() {
        fillSessionDT(trigger.new);
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


}