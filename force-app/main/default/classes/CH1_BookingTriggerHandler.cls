public with sharing class CH1_BookingTriggerHandler {
    public static void validateBookingInsertion(List<Booking__c> bookingList) {
		
        //Store seminar ID and the number of bookings in each seminar
        Map<Id, Integer> serminarIdToBookingCountMap = new Map<Id, Integer>();
        //Store serminar ID in list to reuse for looping
        Set<Id> serminarIdSet = new Set<Id>();
        //Loop through booking list (BookingList) to get the number of insertion on each serminar
		for(Booking__c booking : bookingList){
            Id serminarId = booking.Serminar__c;
            serminarIdSet.add(serminarId); //add seminar ID to the set
            if(serminarIdToBookingCountMap.containsKey(serminarId)){
                serminarIdToBookingCountMap.put(serminarId, serminarIdToBookingCountMap.get(serminarId) + 1);
            } else {
                serminarIdToBookingCountMap.put(serminarId, 1);
            }
        }

        List<Serminar__c> seminarList = [
            SELECT Id, Quantity__c, (SELECT Id FROM Booking__r WHERE Status__c='Done')
            FROM Serminar__c
            WHERE Id IN :serminarIdSet
        ];
    
        for(Serminar__c sermi : seminarList){
            Integer currentBookings = Integer.valueOf(sermi.Booking__r.size());
            Integer serminarQuantity = Integer.valueOf(sermi.Quantity__c);
            Integer newBookings = serminarIdToBookingCountMap.get(sermi.Id);
            if(currentBookings + newBookings > serminarQuantity){
                bookingList[0].addError(
                    'Error:The amount of insertion is more than available slot! Available: ' 
                    + String.valueOf(serminarQuantity - currentBookings)
                    + '. Bookings: ' + String.valueOf(newBookings)
                );
            }
        }
    }
}