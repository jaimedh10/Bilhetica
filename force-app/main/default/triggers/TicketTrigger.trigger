trigger TicketTrigger on Ticket__c (after insert, after update, before insert) {
    new TicketTriggerHandler().run();
}