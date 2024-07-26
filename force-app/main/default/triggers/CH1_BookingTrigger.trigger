trigger CH1_BookingTrigger on Booking__c (before insert, before update, after insert, after update, after delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            CH1_BookingTriggerHandler.validateBookingInsertion(Trigger.new);
        }
    }else if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isDelete || Trigger.isUpdate){
            Set<Id> seminarIds = new Set<Id>();
            if (Trigger.new != null) {
                for (Booking__c booking : Trigger.new) {
                    seminarIds.add(booking.Serminar__c);
                }
            }
            if (Trigger.old != null) {
                for (Booking__c booking : Trigger.old) {
                    seminarIds.add(booking.Serminar__c);
                }
            }

            // Query the related Booking__c records and count them for each Serminar__c record
            List<Serminar__c> seminarsToUpdate = [SELECT Id, (SELECT Id FROM Booking__r WHERE Status__c = 'Done') FROM Serminar__c WHERE Id IN :seminarIds];

            // Update the Booking_Done_Quantity__c field on the Serminar__c records
            for (Serminar__c seminar : seminarsToUpdate) {
                if (seminar.Booking__r != null) {
                    seminar.Booking_Done_Quantity__c = seminar.Booking__r.size();
                } else {
                    seminar.Booking_Done_Quantity__c = 0;
                }
            }

            // Perform the update on the Serminar__c records
            update seminarsToUpdate;
        }
    }

}