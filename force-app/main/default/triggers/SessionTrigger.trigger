trigger SessionTrigger on Session__c (before insert, before update, after insert) {
    new SessionTriggerHandler().run();
}