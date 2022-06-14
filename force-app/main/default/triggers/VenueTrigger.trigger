trigger VenueTrigger on Venue__c (before insert, before update) {
    new VenueTriggerHandler().run();
}