@isTest
private class RowAndVenueTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        List<Venue__c> venues = TestDataFactory.createVenuesWithPredefinedCapacity(1, 10);
        /* List<Venue__c> sections = SetupWizardController.createSections(1, venues.get(0).Id);
        sections.get(0).Capacity__c = 10;
        update sections; */
        List<Row__c> rows = SetupWizardController.createRows(1, venues.get(0).Id);
    }

    @isTest
    static void testCreateSeats() {
        List<Row__c> rows = [SELECT Id, Number_of_seats__c FROM Row__c LIMIT 1];
        Integer numberOfSeats = [SELECT Id, Seat_Row__c FROM Seat__c WHERE Seat_Row__c IN :rows].size();
        System.assertEquals(10, numberOfSeats);
    }

    @isTest
    static void testCreateOrDeleteSeats() {
        List<Venue__c> venues = [SELECT Id, Capacity__c, Row_Max_Capacity__c FROM Venue__c LIMIT 1];
        venues.get(0).Capacity__c = 12;
        update venues;
        System.debug(venues);
        List<Row__c> rows = [SELECT Id, Number_of_seats__c FROM Row__c WHERE Venue__c IN :venues LIMIT 1];
        rows.get(0).Number_of_seats__c = 12;
        update rows;
        System.debug(rows);
        Integer numberOfSeats = [SELECT Id, Seat_Row__c FROM Seat__c WHERE Seat_Row__c IN :rows].size();
        System.assertEquals(12, numberOfSeats);
    }
}
