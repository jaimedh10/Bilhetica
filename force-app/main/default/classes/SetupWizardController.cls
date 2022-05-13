public with sharing class SetupWizardController {

    @AuraEnabled
    public static List<Venue__c> createSections(Integer numberOfSections, String venueId) {
        if(String.isBlank(venueId))
            return null;
        
        System.debug(LoggingLevel.INFO, venueId); 
        List<Venue__c> sections = new List<Venue__c>();
        Id recordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Venue__c' AND DeveloperName = 'Venue_Section' LIMIT 1].Id;

        for(Integer i=0; i<numberOfSections; i++) {
            Venue__c section = new Venue__c();
            section.Name = 'Section-' + (i+1); 
            section.Capacity__c = 0;
            section.Venue__c = venueId;
            section.RecordTypeId = recordTypeId;
            System.debug(LoggingLevel.INFO, section);
            sections.add(section);
        }

        try {
            insert sections;
            return sections;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
        
    }

    @AuraEnabled
    public static List<Row__c> createRows(Integer numberOfRows, String sectionId){
        if(String.isBlank(sectionId))
            return null;
        
        System.debug(LoggingLevel.INFO, sectionId); 
        List<Row__c> rows = new List<Row__c>();

        for(Integer i=0; i<numberOfRows; i++) {
            Row__c row = new Row__c();
            row.Name = 'Row-' + (i+1); 
            row.Number_of_seats__c = 0;
            row.Venue__c = sectionId;
            System.debug(LoggingLevel.INFO, row);
            rows.add(row);
        }

        try {
            insert rows;
            return rows;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    /* @AuraEnabled
    public static boolean createDiscount(){
        try {
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    } */
}