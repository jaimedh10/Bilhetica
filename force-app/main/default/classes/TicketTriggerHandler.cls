public with sharing class TicketTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        duplicateTicket(trigger.new);
    }

    public override void afterInsert() {
        sendPaymentConfirmationEmail(trigger.new);
    }

    public override void afterUpdate() {
        sendPaymentConfirmationEmail(trigger.new);
    }
    



    // Method to send confirmation email after the ticket is paid.
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

    // Method to block duplicate tickets insertion
    private static void duplicateTicket(List<Ticket__c> tickets) {
        Set<Id> ticketSessionId = new Set<Id>();
        Set<Id> ticketSessionVenueId = new Set<Id>();
        Set<Id> ticketSeat = new Set<Id>();

        for(Ticket__c t : tickets) {
            ticketSessionId.add(t.Session__c);
            ticketSessionVenueId.add(t.Session_Venue__c);
            ticketSeat.add(t.Seat__c);
        }
        // Query to retrieve the tickets for that Session, Session Venue and Seat
        List<Ticket__c> ticketsList = [SELECT Id FROM Ticket__c WHERE Session__c IN :ticketSessionId AND Session_Venue__c IN :ticketSessionVenueId AND Seat__c IN :ticketSeat];
        System.debug(ticketsList);
        if(!ticketsList.isEmpty()) {
            // Duplicate found
            tickets.get(0).addError('The current ticket record is duplicated.');
            //System.debug(tickets.get(0));
        }
    }

    @future(callout=true) // A future method runs in the background, asynchronously.
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
                        Blob b;
                        if(Test.isRunningTest()) { 
                            b = Blob.valueOf('Unit.Test');
                        } else {
                            b = pdf.getContent();
                        }
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
