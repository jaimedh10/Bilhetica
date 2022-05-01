trigger SessionTrigger on Session__c (before insert, before update) {
    new SessionTriggerHandler().run();
}