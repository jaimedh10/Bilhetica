public with sharing class SessionTriggerHandler extends TriggerHandler {
    
    public override void beforeUpdate() {
        fillSessionDT(trigger.new);
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
    


}