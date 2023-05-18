trigger CH1_BookingTrigger on Booking__c (before insert, before update) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            CH1_BookingTriggerHandler.validateBookingInsertion(Trigger.new);
        }
    }
}