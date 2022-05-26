public with sharing class TicketTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
    }

    public override void afterUpdate() {
        sendPaymentConfirmationEmail(trigger.new);
    }
    
    // 
    private static void sendPaymentConfirmationEmail(List<Ticket__c> ticketList) {
        List<Id> contactIdsList = new List<Id>();
        
        for(Ticket__c t : ticketList) {
            if(t.Status__c == 'Paid') {
                contactIdsList.add(t.Contact__c);
            }
        }
        
        System.debug(LoggingLevel.INFO, contactIdsList);

        if(contactIdsList.size() > 0) {
            Messaging.reserveMassEmailCapacity(contactIdsList.size());
            Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            EmailTemplate template = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'Ticket_1652720392473' LIMIT 1];
            mail.setTargetObjectIds(contactIdsList);
            mail.setTemplateId(template.Id);
            Messaging.SendEmail(New Messaging.MassEmailMessage[]{mail});
        }
    }
}
