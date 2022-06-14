public with sharing class RowTriggerHandler extends TriggerHandler{
    public override void afterInsert() {
        createSeats(trigger.new);
    }

    public override void beforeUpdate() {
        createOrDeleteSeats(trigger.old, trigger.new);
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

    private static void createOrDeleteSeats(List<Row__c> oldRowsList, List<Row__c> newRowsList) {
        Set<Id> venuesId = new Set<Id>();

        for(Row__c r : oldRowsList) {
            for(Row__c row : newRowsList) {
                if(r.Id == row.Id) {
                    if(r.Number_of_seats__c == row.Number_of_seats__c) {
                        // Nothing to do;
                        continue;
                    }
                    else if(r.Number_of_seats__c < row.Number_of_seats__c) {
                        // Create seat(s);
                        Integer startSeat = (Integer) r.Number_of_seats__c;
                        Integer lastSeat = (Integer) (startSeat + (row.Number_of_seats__c - r.Number_of_seats__c));
                        System.debug(lastSeat);
                        Boolean result = createSeatRange(row.Id, row.Venue__c, startSeat, lastSeat);
                        if(result == false) {
                            row.addError('Update is not possible because it exceeds the venue capacity.');
                        }
                    }
                    else {
                        // Delete seat(s)
                        row.addError('Update is not possible because it will delete seats, which can only be done mannualy.');
                    }
                }
            }
        }
    }

    // Auxiliar method to create Seats given the start Seat and the last Seat
    private static Boolean createSeatRange(String rowId, String venueId, Integer startSeat, Integer lastSeat) {
        if(String.isBlank(venueId) || String.isBlank(rowId)) {
            return false;
        }
        List<Row__c> rows = [SELECT Id, Number_Of_Seats__c, Venue__c FROM Row__c WHERE Venue__c = :venueId];
        List<Venue__c> venue = [SELECT Capacity__c, Row_Max_Capacity__c FROM Venue__c WHERE Id = :venueId LIMIT 1];

        for(Row__c r : rows) {
            if(r.Venue__c == venueId) {
                
                if((lastSeat - startSeat) > (venue.get(0).Capacity__c - venue.get(0).Row_Max_Capacity__c)) {
                    return false;
                }
                List<Seat__c> seats = new List<Seat__c>();
                for(Integer i = startSeat; i < lastSeat; i++) {
                    Seat__c s = new Seat__c();
                    s.Seat_Number__c = (i+1);
                    s.Seat_Row__c = rowId;
                    seats.add(s);
                }

                if(!seats.isEmpty()) {
                    try {
                        insert seats;
                        System.debug(seats);
                        return true;
                    } catch(Exception e) {
                        System.debug('Error on insert ' + e.getMessage() + ' in line ' + e.getLineNumber());
                    }
                }
            }
        }
        return false;
    }
}


