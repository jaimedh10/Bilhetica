trigger VenueTrigger on Venue__c (before insert, after delete, before update) {
    new VenueTriggerHandler().run();
}