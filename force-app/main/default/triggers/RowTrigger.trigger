trigger RowTrigger on Row__c(after insert, before update) {
    new RowTriggerHandler().run();
}