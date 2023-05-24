trigger CH1_BookingTrigger on Booking__c (before insert, before update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            CH1_BookingTriggerHandler.validateBookingInsertion(Trigger.new);
        }
    }
}