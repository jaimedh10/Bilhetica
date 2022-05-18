public with sharing class TicketTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
    }

    public override void afterUpdate() {
        sendPaymentConfirmationEmail(trigger.new);
    }
    
    // 
    private static void sendPaymentConfirmationEmail(List<Ticket__c> ticketList) {
        Messaging.reserveMassEmailCapacity(ticketList.size());
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        List<Id> contactIdsList = new List<Id>();
        
        for(Ticket__c t : ticketList) {
            contactIdsList.add(t.Contact__c);
        }
        
        System.debug(LoggingLevel.INFO, contactIdsList);
        EmailTemplate template = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'Ticket_1652720392473' LIMIT 1];

        mail.setTargetObjectIds(contactIdsList);
        mail.setTemplateId(template.Id);
        Messaging.SendEmail(New Messaging.MassEmailMessage[]{mail});

    }
}
