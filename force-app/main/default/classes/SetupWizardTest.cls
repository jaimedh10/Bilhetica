@isTest
private class SetupWizardTest {
    @isTest 
    static void testCreateSections() {
        Integer numberOfSections = 2;
        Id venueId = 'a057Q0000025906QAA';
        List<Venue__c> sections = SetupWizardController.createSections(numberOfSections, venueId);
        System.assertEquals(sections.size(), 2);
    }

    @isTest
    static void testCreateRows(){
        Integer numberOfRows = 2;
        Id sectionId = 'a057Q0000026esLQAQ';
        List<Row__c> rows = SetupWizardController.createRows(numberOfRows, sectionId);
        System.assertEquals(rows.size(),2);
    }

}