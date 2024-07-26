public without sharing class CH4_PaymentController {
    @AuraEnabled
    public static Boolean createPaymentForBooking(String bookingId, String bookingPrice) {
        Payment__c payment = new Payment__c();
        payment.Booking__c = bookingId;
        payment.Price__c = Decimal.valueOf(bookingPrice);
        payment.Payment_Date__c = Datetime.now();
        try {
            insert payment;
        } catch (Exception e) {
            System.debug('Insert payment has an error: ' + e.getMessage());
            return false;
        }
        return true;
    }
}