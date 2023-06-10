public without sharing class CH4_BookingController {
    @AuraENabled
    public static Boolean insertBooking(String id, String name, String email, String phone, List<String> birthdate, String voucher, String serName, String price) {
        Contact newCt = new Contact();
        newCt.LastName = name;
        newCt.Email = email;
        newCt.Phone = phone;
        newCt.Birthdate = date.newinstance(Integer.valueOf(birthdate[0]), Integer.valueOf(birthdate[1]), Integer.valueOf(birthdate[2]));

        insert newCt;

        Booking__c newBooking = new Booking__c();
        newBooking.Serminar__c = id;
        newBooking.Contact__c = newCt.Id;
        newBooking.Voucher__c = voucher;
        newBooking.Total_Amount__c = Integer.valueOf(price);

        insert newBooking;

        return true;
    }
    @AuraENabled
    public static Decimal validateVoucher(String voucher) {
        try {
            return [SELECT Discount__c FROM Promotion_Code__c WHERE Code__c =: voucher].Discount__c;
        } catch (QueryException ex) {
            // Handle the query exception
            return null;
        }
    }
}