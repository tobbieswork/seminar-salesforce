public with sharing class CH1_BookingRecordTriggerHandler {
    public static Boolean cH1_BookingRecordsCheck(List<Booking__c> bookingList) {
		
        //Store Id seminar and the number of bookings for this seminar
        Map<Id, Integer> countBookings = new Map<Id, Integer>();
        //Loop through bookingList to get the number of insertion on each serminar
		for(Booking__c booking : bookingList){
            Id serminarId = booking.Serminar__c;
            if(countBookings.get(serminarId) != null){
                countBookings.put(serminarId, countBookings.get(serminarId) + 1);
            } else {
                countBookings.put(serminarId, 1);
            }
        }
        
        //Query all seminars in one SOQL statement and store them in a map by Id
		Map<Id, Serminar__c> serminarMap = new Map<Id, Serminar__c>([
            SELECT Id, Quantity__c 
            FROM Serminar__c 
            WHERE Id IN : countBookings.keySet()
        ]);
        
        //Loop through countBookings map and check availability for each seminar
        for (Id serminarId : countBookings.keySet()){
            Integer numberOfBooked = [SELECT count() FROM Booking__c WHERE Serminar__c = :serminarId];
            Integer numberOfBooking = countBookings.get(serminarId);
            Integer quantity = Integer.valueOf(serminarMap.get(serminarId).Quantity__c);
            
            if(numberOfBooked + numberOfBooking > quantity){
                return false;
            }
        }
        return true;
        
        
    }
}