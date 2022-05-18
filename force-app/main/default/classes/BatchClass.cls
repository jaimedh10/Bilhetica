public class BatchClass implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext dbc) {
        return Database.getQueryLocator([SELECT Id FROM Session__c]); 
    }
    
    public void execute(Database.BatchableContext dbc, List<Session__c> sessions){
        // process each batch of records
        List<Session_Venue__c> sessionVenueList = new List<Session_Venue__c>();

        for(Session__c s : sessions) {
            // Query to retrieve the Sections related list from the Venue of the Session
            List<Venue__c> sectionsList = new List<Venue__c>([SELECT Id FROM Venue__c WHERE Venue__c =:s.Venue__c AND RecordType.DeveloperName ='Venue_Section']); 
            if(sectionsList.isEmpty()) { return true; }

            for(Venue__c venue : sectionsList) {
                Session_Venue__c sessionVenue = new Session_Venue__c();
                sessionVenue.Price__c = s.session_Price__c;
                sessionVenue.Session__c = s.Id;
                sessionVenue.Venue__c = venue.Id;
                System.debug(LoggingLevel.INFO, sessionVenue);
                sessionVenueList.add(sessionVenue);
            }
        }

        try {
            insert sessionVenueList;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext dbc){
        // execute any post-processing operations
        System.debug('Done');
    }
}