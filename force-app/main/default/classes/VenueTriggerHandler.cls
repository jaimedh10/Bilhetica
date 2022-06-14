public with sharing class VenueTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        checkIfNewSectionCapacityExceedsVenueCapacity(trigger.new);
    }
    
    public override void beforeUpdate() {
        checkIfSectionCapacityChanged(trigger.old, trigger.new);
    }    


    

    public class VenueCapacity {
        public Decimal maxCapacity;
        public Decimal usedCapacity;

        public VenueCapacity(Decimal maxCapacity, Decimal usedCapacity) {
            this.maxCapacity = maxCapacity;
            this.usedCapacity = usedCapacity;
        }
    }

    private static void checkIfNewSectionCapacityExceedsVenueCapacity(List<Venue__c> venuesList) {
        Map<Id, VenueCapacity> venueIdAndSectionsCapacitySum = new Map<Id, VenueCapacity>();
        Set<Id> mainVenuesId = new Set<Id>();
        Id recordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get('Venue').getRecordTypeId();

        for(Venue__c v : venuesList) {
            if(v.RecordTypeId == recordTypeId) {
                continue;
            }
            mainVenuesId.add(v.Venue__c);
        }

        if(mainVenuesId.isEmpty()) {
            return;
        }
        System.debug(mainVenuesId);
        List<Venue__c> venues = [SELECT Id, Venue__c, Capacity__c, Venue__r.Capacity__c FROM Venue__c WHERE RecordTypeId != :recordTypeId AND Venue__c IN :mainVenuesId];
        if(!venues.isEmpty()) {
            for(Venue__c v : venues) {
                VenueCapacity sum;
                System.debug(v);
                if(venueIdAndSectionsCapacitySum.containsKey(v.Venue__c)) {
                    sum = venueIdAndSectionsCapacitySum.get(v.Venue__c);
                    sum.usedCapacity += v.Capacity__c;
                    venueIdAndSectionsCapacitySum.put(v.Venue__c, sum);
                } else {
                    sum = new VenueCapacity(v.Venue__r.Capacity__c, 0);
                    sum.usedCapacity += v.Capacity__c;
                    venueIdAndSectionsCapacitySum.put(v.Venue__c, sum);
                    System.debug(venueIdAndSectionsCapacitySum);
                }
            }
            
            for(Venue__c v : venuesList) {
                if(venueIdAndSectionsCapacitySum.containsKey(v.Venue__c)) {
                    VenueCapacity sumTotal = venueIdAndSectionsCapacitySum.get(v.Venue__c);
                    System.debug(sumTotal);
                    if(v.Capacity__c > (sumTotal.maxCapacity - sumTotal.usedCapacity)) {
                        v.addError('Current Section(s) capacity exceeds Venue max capacity.');
                    }
                }
            }
        }
        System.debug(venueIdAndSectionsCapacitySum);
    }

    private static void checkIfSectionCapacityChanged(List<Venue__c> oldVenuesList, List<Venue__c> newVenuesList) {
        Map<Id, VenueCapacity> venueIdAndSectionsCapacitySum = new Map<Id, VenueCapacity>();
        Set<Id> mainVenuesId = new Set<Id>();
        Decimal oldCapacity = 0;
        Id recordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get('Venue').getRecordTypeId();

        for(Venue__c v : oldVenuesList) {
            for(Venue__c venue : newVenuesList) {
                if(v.Capacity__c == venue.Capacity__c || venue.recordTypeId == recordTypeId) {
                    continue;
                }
                else if (venue.Capacity__c > v.Capacity__c && venue.Venue__c == v.Venue__c) {
                    oldCapacity = v.Capacity__c;
                    mainVenuesId.add(v.Venue__c);
                }
                else {
                    venue.addError('Section capacity decrease is not possible.');
                }
            }
        }

        if(mainVenuesId.isEmpty()) {
            return;
        }
        System.debug(mainVenuesId);
        List<Venue__c> sections = [SELECT Id, Venue__c, Capacity__c, Venue__r.Capacity__c FROM Venue__c WHERE RecordTypeId != :recordTypeId AND Venue__c IN :mainVenuesId];
        if(!sections.isEmpty()) {
            for(Venue__c v : sections) {
                VenueCapacity sum;
                System.debug(v);
                if(venueIdAndSectionsCapacitySum.containsKey(v.Venue__c)) {
                    sum = venueIdAndSectionsCapacitySum.get(v.Venue__c);
                    sum.usedCapacity += v.Capacity__c;
                    venueIdAndSectionsCapacitySum.put(v.Venue__c, sum);
                } else {
                    sum = new VenueCapacity(v.Venue__r.Capacity__c, 0);
                    sum.usedCapacity += v.Capacity__c;
                    venueIdAndSectionsCapacitySum.put(v.Venue__c, sum);
                    System.debug(venueIdAndSectionsCapacitySum);
                }
            }
            
            for(Venue__c v : newVenuesList) {
                if(venueIdAndSectionsCapacitySum.containsKey(v.Venue__c)) {
                    VenueCapacity sumTotal = venueIdAndSectionsCapacitySum.get(v.Venue__c);
                    System.debug(sumTotal);
                    if(v.Capacity__c > (sumTotal.maxCapacity - (sumTotal.usedCapacity - oldCapacity))) {
                        v.addError('Current Section(s) capacity exceeds Venue maximum capacity');
                    }
                }
            }
        }
        System.debug(venueIdAndSectionsCapacitySum);
    }    
}
