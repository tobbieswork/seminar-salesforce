public with sharing class CH2_PaymentTriggerHandler {
    public static void checkPaymentPrice(List<Payment__c> payments){
        
        //GET Bookings ID from all Payments
        Set<Id> bookingIdsSet = new Set<Id>();
        for(Payment__c payment: payments){
            bookingIdsSet.add(payment.Booking__c);
        }
        
        //SET Bookings FROM Database TO Ids
        Map<Id, Booking__c> idToBookingMap = new Map<Id, Booking__c>([SELECT Id, Total_Amount__c, Contact__c, Serminar__c, Serminar__r.Code__c, Serminar__r.Start_Date__c  FROM Booking__c WHERE Id IN : bookingIdsSet]);
        
        //LOOP through Payments Insert List and CHECK condition (Payment price equal to Booking total amount)
        List<Contact_Card__c> ctcardList = new List<Contact_Card__c>();
        for(Payment__c payment: payments){
            Booking__c bk = idToBookingMap.get(payment.Booking__c);
            //Create contact card for valid payment
            if(payment.Price__c == idToBookingMap.get(payment.Booking__c).Total_Amount__c){
                Contact_Card__c ctcard = new Contact_Card__c(
                    Contact__c = bk.Contact__c,
                    Serminar__c = bk.Serminar__c
                );
                ctcardList.add(ctcard);
            }
        }
        
        if(ctcardList.size() > 0){
        	insert ctcardList;
        }
    }
}