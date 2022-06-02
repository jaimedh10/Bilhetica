public with sharing class RowTriggerHandler extends TriggerHandler{
    public override void afterInsert() {
        createSeats(trigger.new);
    }

    private static void createSeats(List<Row__c> rows) {
        List<Seat__c> seats = new List<Seat__c>();
        for(Row__c row : rows) {
            for(Integer i = 0; i < row.Number_of_seats__c; i++) {
                Seat__c s = new Seat__c();
                s.Seat_Number__c = (i+1);
                s.Seat_Row__c = row.Id;
                seats.add(s);
            }
        }

        if(!seats.isEmpty()) {
            try {
                insert seats;
                System.debug(seats);
            } catch(Exception e) {
                System.debug('Error on insert ' + e.getMessage() + ' in line ' + e.getLineNumber());
            }

        }    
    }
}
