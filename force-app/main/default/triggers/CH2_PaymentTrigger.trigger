trigger CH2_PaymentTrigger on Payment__c (before insert, after insert) {
    if(Trigger.isAfter){
        if (Trigger.isInsert) {
            CH2_PaymentTriggerHandler.checkPaymentPrice(Trigger.new);
        }
    }
}