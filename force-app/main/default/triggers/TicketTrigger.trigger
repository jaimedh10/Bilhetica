trigger TicketTrigger on Ticket__c (after insert, after update) {
    new TicketTriggerHandler().run();
}