public with sharing class CH1_BookingTriggerHandler {
    public static void validateBookingInsertion(List<Booking__c> bookingList) {
        
        //Store serminar ID in list to reuse for looping and query
        Set<Id> serminarIdSet = new Set<Id>();

        //Loop through booking list to get the focused Serminars
        //add Serminar ID to SerminarIdSet collection
		for(Booking__c booking : bookingList){
            if(booking.Status__c == 'Done'){
                Id serminarId = booking.Serminar__c;
                serminarIdSet.add(serminarId);
            }
        }
               
		//Query Serminar Quantity and their related Bookings from Serminar Set
        Map<Id, Serminar__c> serminarIdToSerminarMap = new Map<Id, Serminar__c> ([
            SELECT Id, Quantity__c, (SELECT Id FROM Booking__r WHERE Status__c='Done')
            FROM Serminar__c
            WHERE Id IN :serminarIdSet
        ]);
        
        //Map store the number of bookings will be after insertion
        Map<Id, Integer> idToBookingsAfterInsertMap = new Map<Id, Integer>();
        
        //Get current bookings of each serminar ID in Database
        for(Id sermId : serminarIdSet) {
            Integer currentBookings = Integer.valueOf(serminarIdToSerminarMap.get(sermId).Booking__r.size());
            idToBookingsAfterInsertMap.put(sermId, currentBookings);
        }
        
        //Loop though booking item and check for availability!
        for(Booking__c booking : bookingList){
            if(booking.Status__c == 'Done'){
                Id serminarId = booking.Serminar__c;
            	Serminar__c serminar = serminarIdToSerminarMap.get(serminarId);
                Integer totalCurrentBooking = idToBookingsAfterInsertMap.get(serminarId);
                Integer serminarQuantity = Integer.valueOf(serminar.Quantity__c);
                
                //Validation
                if(totalCurrentBooking >= serminarQuantity){
                    booking.addError('The amount of insertion is more than available slots!');
                }else{
                    idToBookingsAfterInsertMap.put(serminarId, totalCurrentBooking + 1);
                }
            }
        }
    }
}