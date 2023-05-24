/*public with sharing class CH1_2BookingTriggerHandler {
    public static void validateBookingInsertion(List<Booking__c> bookingList) {
        
        //Store serminar ID in list to reuse for looping and query
        Set<Id> serminarIdSet = new Set<Id>();

        //Loop through booking list to get the focused Serminars!
        //And add Serminar ID to SerminarIdSet collection
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
                    booking.addError(
                    	'The amount of insertion is more than available slots!. Fail to insert booking : ' 
                    	+ String.valueOf(booking)
                	);
                }else{
                    idToBookingsAfterInsertMap.put(serminarId, totalCurrentBooking + 1);//
                }
            }
        }
    }
}*/

public with sharing class Draft_BookingTriggerHandler {
    public static void validateBookingInsertion(List<Booking__c> bookingList) {

        //Store seminar ID and the number of bookings in each seminar
        Map<Id, Integer> serminarIdToBookingCountMap = new Map<Id, Integer>();
        //Store serminar ID in list to reuse for looping
        Set<Id> serminarIdSet = new Set<Id>();

        //Loop through booking list (BookingList) to get the number of insertion on each serminar
        //And add Serminar ID to SerminarIdSet collection
		for(Booking__c booking : bookingList){
            Id serminarId = booking.Serminar__c;
            if(booking.Status__c == 'Done'){
                serminarIdSet.add(serminarId); //add seminar ID to the set
                if(serminarIdToBookingCountMap.containsKey(serminarId)){
                	serminarIdToBookingCountMap.put(serminarId, serminarIdToBookingCountMap.get(serminarId) + 1);
            	} else {
                	serminarIdToBookingCountMap.put(serminarId, 1);
            	}
            }
        }
        
		//Query Serminar Quantity and their related Bookings from Serminar Set
        List<Serminar__c> seminarList = [
            SELECT Id, Quantity__c, (SELECT Id FROM Booking__r WHERE Status__c='Done')
            FROM Serminar__c
            WHERE Id IN :serminarIdSet
        ];
        //Loop through Serminar info List to validate that the amount of New Bookings is less than available slots!
        for(Serminar__c sermi : seminarList){
            Integer currentBookings = Integer.valueOf(sermi.Booking__r.size());
            Integer serminarQuantity = Integer.valueOf(sermi.Quantity__c);
            Integer newBookings = serminarIdToBookingCountMap.get(sermi.Id);
            if(currentBookings + newBookings > serminarQuantity){
                bookingList[0].addError(
                    'The amount of insertion is more than available slots! Available: '
                    + String.valueOf(serminarQuantity - currentBookings)
                    + '. Bookings: ' + String.valueOf(newBookings)
                );
            }
        }
    }
}