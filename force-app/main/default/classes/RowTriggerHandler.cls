public with sharing class RowTriggerHandler extends TriggerHandler{
    public override void afterInsert() {
        createSeats(trigger.new);
    }

    public override void beforeUpdate() {
        createOrDeleteSeats(trigger.old, trigger.new);
        checkIfRowCapacityExceedsVenueCapacity(trigger.old, trigger.new);
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

        if(oldRowsList.isEmpty() || newRowsList.isEmpty()) {
            return;
        }

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
                        // 
                        System.debug(r.Venue__r.Capacity__c);
                        System.debug(r.Venue__r.Row_Max_Capacity__c);
                        System.debug(row.Venue__c);
                        /* if(lastSeat > (row.Venue__r.Capacity__c - row.Venue__r.Row_Max_Capacity__c)) {
                            row.addError('Update is not possible because it exceeds the venue capacity.');
                        } else {
                            createSeatRange(row.Id, startSeat, lastSeat);
                        } */
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
    private static void createSeatRange(String rowId, Integer startSeat, Integer lastSeat) {
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
            } catch(Exception e) {
                System.debug('Error on insert ' + e.getMessage() + ' in line ' + e.getLineNumber());
            }

        } 
    }
}


