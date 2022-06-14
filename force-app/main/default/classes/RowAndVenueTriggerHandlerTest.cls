@isTest
private class RowAndVenueTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        List<Venue__c> venues = TestDataFactory.createVenuesWithPredefinedCapacity(1, 10);
        List<Venue__c> sections = SetupWizardController.createSections(2, venues.get(0).Id);
        sections.get(0).Capacity__c = 10;
        update sections;
        List<Row__c> rows = SetupWizardController.createRows(1, venues.get(0).Id);
        List<Row__c> sectionRows = SetupWizardController.createRows(1, sections.get(0).Id);
    }

    // Positive Testing

    @isTest
    static void testCreateSeats() {
        List<Row__c> rows = [SELECT Id, Number_of_seats__c FROM Row__c LIMIT 1];
        Integer numberOfSeats = [SELECT Id, Seat_Row__c FROM Seat__c WHERE Seat_Row__c IN :rows].size();
        System.assertEquals(10, numberOfSeats);
    }

    @isTest
    static void testNumberOfSeatsUpdate() {
        List<Venue__c> venues = [SELECT Id, Capacity__c, Row_Max_Capacity__c FROM Venue__c LIMIT 1];
        venues.get(0).Capacity__c = 12;
        update venues;
        System.debug(venues);
        List<Row__c> rows = [SELECT Id, Number_of_seats__c, Venue__c FROM Row__c WHERE Venue__c IN :venues LIMIT 1];
        System.debug(rows);
        rows.get(0).Number_of_seats__c = 12;
        update rows;
        System.debug(rows);
        Integer numberOfSeats = [SELECT Id, Seat_Row__c FROM Seat__c WHERE Seat_Row__c IN :rows].size();
        System.assertEquals(12, numberOfSeats);
    }

    @isTest
    static void testCheckIfSectionCapacityChanged() {
        List<Venue__c> venues = [SELECT Id, Capacity__c, Row_Max_Capacity__c FROM Venue__c LIMIT 1];
        venues.get(0).Capacity__c = 12;
        update venues;
        List<Venue__c> sections = [SELECT Id, Capacity__c, Venue__c FROM Venue__c WHERE Venue__c IN :venues LIMIT 1];
        sections.get(0).Capacity__c = 12;
        update sections;
        System.assertEquals(12, sections.get(0).Capacity__c);

    }

    // Negative Testing

    @isTest
    static void testRowCapacityExceedSectionCapacity() {
        List<Venue__c> venues = [SELECT Id, Capacity__c, Row_Max_Capacity__c FROM Venue__c LIMIT 1];
        venues.get(0).Capacity__c = 12;
        update venues;
        List<Venue__c> sections = [SELECT Id, Capacity__c, Venue__c FROM Venue__c WHERE Venue__c IN :venues LIMIT 1];
        sections.get(0).Capacity__c = 12;
        Row__c row = [SELECT Id, Number_of_seats__c FROM Row__c WHERE Venue__c IN :sections LIMIT 1];
        row.Number_of_seats__c = 13;
        Database.SaveResult result = Database.update(row, false);

    }

    @isTest
    static void testRowCapacityReduction() {
        List<Venue__c> venues = [SELECT Id, Capacity__c, Row_Max_Capacity__c FROM Venue__c LIMIT 1];
        venues.get(0).Capacity__c = 12;
        update venues;
        List<Venue__c> sections = [SELECT Id, Capacity__c, Venue__c FROM Venue__c LIMIT 1];
        sections.get(0).Capacity__c = 12;
        Row__c row = [SELECT Id, Number_of_seats__c FROM Row__c WHERE Venue__c IN :sections LIMIT 1];
        row.Number_of_seats__c = 12;
        update row;
        row.Number_Of_Seats__c = 10;
        Database.SaveResult negativeResult = Database.update(row, false);
    }

    @isTest
    static void testSectionCapacityReduction() {
        Venue__c section = [SELECT Id, Capacity__c, Venue__c FROM Venue__c WHERE Venue__c != null LIMIT 1];
        section.Capacity__c = 10;
        update(section);
        section.Capacity__c = 5;
        Database.SaveResult result = Database.update(section, false);

    }
}
