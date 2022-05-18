trigger SessionTrigger on Session__c (before insert, before update, after insert, after update) {
    new SessionTriggerHandler().run();
}