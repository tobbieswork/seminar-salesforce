trigger CH1_BookingRecordTrigger on Booking__c (before insert, before update) {
    if(Trigger.isInsert){
        Boolean result = CH1_BookingRecordTriggerHandler.cH1_BookingRecordsCheck(Trigger.new);
    	if(result == false){
        	Trigger.new[0].addError('The amount of insertion is more than available slot!');
    	}
    }
	
}