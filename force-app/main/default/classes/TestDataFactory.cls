@isTest
public class TestDataFactory {
    public static List<Venue__c> createVenues(Integer numberOfVenues) {
        List<Venue__c> venues = new List<Venue__c>();
        Id recordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get('Venue').getRecordTypeId();
        for(Integer i=0; i<numberOfVenues; i++) {
            Venue__c venue = new Venue__c();
            venue.Name = 'Venue-'+ i;
            venue.Capacity__c = 100;
            venue.RecordTypeId = recordTypeId; 
            venues.add(venue);
        }
        
        insert venues;
        return venues;
    }

    public static List<Venue__c> createSections(Integer numberOfSections, Id venueId) {
        List<Venue__c> sections = new List<Venue__c>();
        Id recordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get('Venue_Section').getRecordTypeId();
        for(Integer i=0; i<numberOfSections; i++) {
            Venue__c section = new Venue__c();
            section.Name = 'Section- '+ i;
            section.Capacity__c = 1;
            section.RecordTypeId = recordTypeId;
            section.Venue__c = venueId;
            sections.add(section);
        }

        insert sections;
        return sections;
    }
}
