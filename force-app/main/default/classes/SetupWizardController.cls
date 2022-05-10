public with sharing class SetupWizardController {

    @AuraEnabled(cacheable=true)
    public static List<Venue__c> createSections(Integer numberOfSections, Id venueId) {
        if(String.isBlank(venueId))
            return null;
        System.debug(LoggingLevel.INFO, venueId);        
        List<Venue__c> sections = new List<Venue__c>();
        Id recordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Venue__c' AND DeveloperName = 'Venue_Section' LIMIT 1].Id;
        for(Integer i=0; i<numberOfSections; i++) {
            Venue__c section = new Venue__c();
            section.Venue__c = venueId;
            section.RecordTypeId = recordTypeId;
            System.debug(LoggingLevel.INFO, section);
            sections.add(section);
        }
        
        return sections;
        
        /* try {
            insert sections;
        } catch (Exception e) {
            throw new System.debug(e.getMessage());
        } */
    }

    public SetupWizardController() {
    }
}