@isTest
private class SetupWizardTest {
    @TestSetup
    static void makeData() {
        List<Venue__c> venues = TestDataFactory.createVenues(1);
        List<Venue__c> sections = SetupWizardController.createSections(1, venues.get(0).Id);
    }

    @isTest 
    static void testCreateSections() {
        Integer numberOfSections = 2;
        Id venueId = [SELECT Id FROM Venue__c WHERE RecordType.DeveloperName ='Venue' LIMIT 1].Id;
        List<Venue__c> sections = SetupWizardController.createSections(numberOfSections, venueId);
        System.assertEquals(sections.size(), 2);
    }

    @isTest
    static void testCreateRows() {
        Integer numberOfRows = 2;
        Id sectionId = [SELECT Id FROM Venue__c WHERE RecordType.DeveloperName ='Venue_Section' LIMIT 1].Id;
        List<Row__c> rows = SetupWizardController.createRows(numberOfRows, sectionId);
        System.assertEquals(rows.size(),2);
    }

}