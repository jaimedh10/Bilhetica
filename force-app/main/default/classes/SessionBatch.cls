@isTest
public class SessionBatch {
    @testSetup
    static void setup() {
        
        // Load test data
        List<Session__c> sessions = new List<Session__c>();
        for (Integer i=0;i<200;i++) {
            sessions.add(new Session__c(Name='Session '+i, Venue__c='Teste'));
        }
        insert sessions;
    }
    
    @isTest 
    static void test() {
        // Perform the test
        Test.startTest();
        BatchClass bc = new BatchClass();
        Id batchId = Database.executeBatch(bc, 200);
        Test.stopTest();
        
        // After the testing stops, assert records were updated properly
        List<Session__c> updatedLeads = [SELECT Id FROM Lead WHERE LeadSource = 'Dreamforce'];
        System.assertEquals(200, updatedLeads.size(), 'Error: At least 1 Lead record not updated');
    }
    
}