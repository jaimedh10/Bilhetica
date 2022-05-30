public with sharing class TicketTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
    }

    public override void afterUpdate() {
        sendPaymentConfirmationEmail(trigger.new);
    }
    
    
    private static void sendPaymentConfirmationEmail(List<Ticket__c> ticketList) {
        List<Id> contactIdsList = new List<Id>();
        List<Id> ticketsIdsList = new List<Id>();
        
        for(Ticket__c t : ticketList) {
            if(t.Status__c == 'Paid') {
                contactIdsList.add(t.Contact__c);
                ticketsIdsList.add(t.Id);
            }
        }
        
        if(contactIdsList.size() > 0) {
            sendEmail(contactIdsList, ticketsIdsList);
            System.debug(LoggingLevel.INFO, contactIdsList);
        }
        
    }

    @future(callout=true)
    public static void sendEmail(List<Id> contactIdsList, List<Id> ticketsIdList) {
        if(contactIdsList.size() > 0) {
            Messaging.reserveSingleEmailCapacity(contactIdsList.size());
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
            // Reference the attachment page
            PageReference pdf = Page.contactTickets;
 
            // Create the email attachment
            Messaging.EmailFileAttachment emailFile = new Messaging.EmailFileAttachment();

            // Get the template Id
            EmailTemplate template = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'Ticket_1652720392473' LIMIT 1];
            mail.setTemplateId(template.Id);
            mail.setToAddresses(contactIdsList);
            emailFile.setFileName('tickets.pdf');

            List<Ticket__c> tickets = new List<Ticket__c>();
            // Loop to retrieve the ticket contact based on the ticket id 
            for(Ticket__c t : [SELECT Id, Contact__c, Session__c FROM Ticket__c WHERE Id IN :ticketsIdList]) {
                tickets.add(t);
            }
            
            for(Integer j = 0; j < contactIdsList.size(); j++) {
                for(Ticket__c t : tickets) {
                    if(t.Contact__c == contactIdsList.get(j)) {
                        mail.setTargetObjectId(contactIdsList.get(j));
                        pdf.getParameters().put('id', contactIdsList.get(j));
                        pdf.getParameters().put('sessionId', t.Session__c);
                        pdf.setRedirect(true);
                        // Take the PDF content
                        Blob b = pdf.getContent();
                        emailFile.setBody(b);
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {emailFile});
                        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage> {mail};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                        if (results[0].success) {
                            System.debug('The email was sent successfully.');
                        } else {
                            System.debug('The email failed to send: ' + results[0].errors[0].message);
                        }
                        break;
                    }
                } 
            }
        }
    }
}
