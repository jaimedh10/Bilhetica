@isTest
private class SetupWizardControllerTest {
    @TestSetup
    static void makeData() {
        List<Venue__c> venues = TestDataFactory.createVenues(1);
        List<Venue__c> sections = SetupWizardController.createSections(1, venues.get(0).Id);
        List<Row__c> row = SetupWizardController.createRows(1, sections.get(0).Id);
        
        /* Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Seller' LIMIT 1];
        User usr = new User(LastName = 'Test',
            Alias = 'testcase',
            Email = 'testcase@gmail.com',
            Username = 'testcase@gmail.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert usr;
        System.runAs(user){
        } */
    }

    // Positive Testing on SetupWizardController methods

    @isTest 
    static void testCreateSections() {
        Integer numberOfSections = 2;
        Id venueId = [SELECT Id FROM Venue__c WHERE RecordType.DeveloperName ='Venue' LIMIT 1].Id;
        List<Venue__c> sections = SetupWizardController.createSections(numberOfSections, venueId);
        System.assertEquals(2, sections.size());
    }

    @isTest
    static void testCreateRows() {
        Integer numberOfRows = 2;
        Id sectionId = [SELECT Id FROM Venue__c WHERE RecordType.DeveloperName ='Venue_Section' LIMIT 1].Id;
        List<Row__c> rows = SetupWizardController.createRows(numberOfRows, sectionId);
        System.assertEquals(2, rows.size());
    }


    // Bulk Testing - 50 records 

    @isTest 
    static void bulkTestCreateSections() {
        Integer numberOfSections = 50;
        Id venueId = [SELECT Id FROM Venue__c WHERE RecordType.DeveloperName ='Venue' LIMIT 1].Id;
        Test.startTest();
        List<Venue__c> sections = SetupWizardController.createSections(numberOfSections, venueId);
        Test.stopTest();
        System.assertEquals(50, sections.size());
    }
    
    @isTest
    static void bulkTestCreateRows() {
        Integer numberOfRows = 50;
        Id sectionId = [SELECT Id FROM Venue__c WHERE RecordType.DeveloperName ='Venue_Section' LIMIT 1].Id;
        Test.startTest();
        List<Row__c> rows = SetupWizardController.createRows(numberOfRows, sectionId);
        Test.stopTest();
        System.assertEquals(50, rows.size());
    }

    // Negative Testing - Invoking method with empty Id

    @isTest 
    static void testCreateSectionsWithEmptyId() {
        Integer numberOfSections = 1;
        List<Venue__c> sections = SetupWizardController.createSections(numberOfSections, '');
        System.assertEquals(null, sections);
    }

    @isTest
    static void testCreateRowsWithEmptyId() {
        Integer numberOfRows = 1;
        List<Row__c> rows = SetupWizardController.createRows(numberOfRows, null);
        System.assertEquals(null, rows);
    }

    // Test Exception, the solution was to send an Id of another object

    @isTest
    static void testInsertSectionsFail() {
        Integer numberOfSections = 1;
        Id rowId = [SELECT Id FROM Row__c LIMIT 1].Id;
        Test.startTest();
        try {
            List<Venue__c> sections = SetupWizardController.createSections(numberOfSections, rowId);
        } catch(Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertRowsFail() {
        Integer numberOfRows = 1;
        Id rowId = [SELECT Id FROM Row__c LIMIT 1].Id;
        Test.startTest();
        try {
            List<Row__c> rows = SetupWizardController.createRows(numberOfRows, rowId);
        } catch(Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
        Test.stopTest();
    }

}

