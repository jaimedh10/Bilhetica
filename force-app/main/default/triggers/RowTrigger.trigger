trigger RowTrigger on Row__c(after insert) {
    new RowTriggerHandler().run();
}