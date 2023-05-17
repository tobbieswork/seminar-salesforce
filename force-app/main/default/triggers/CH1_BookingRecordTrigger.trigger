trigger CH1_BookingRecordTrigger on Booking__c (before insert, before update) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            CH1_BookingRecordTriggerHandler.cH1_BookingRecordsCheck(Trigger.new);
        }
    }
}