public without sharing class CH4_BookingController {
    @AuraENabled
    public static Id insertBooking(String id, String name, String email, String phone, List<Integer> birthdate, String voucher, String serName, String price) {
        Contact newCt = new Contact();
        newCt.LastName = name;
        newCt.Email = email;
        newCt.Phone = phone;

        if(birthdate.size() == 3){
            newCt.Birthdate = date.newinstance(Integer.valueOf(birthdate[0]), Integer.valueOf(birthdate[1]), Integer.valueOf(birthdate[2]));
        }

        insert newCt;

        Booking__c newBooking = new Booking__c();
        newBooking.Serminar__c = id;
        newBooking.Contact__c = newCt.Id;
        newBooking.Voucher__c = voucher;
        newBooking.Total_Amount__c = Integer.valueOf(price);

        insert newBooking;

        return newBooking.Id;
    }
    @AuraENabled
    public static Decimal validateVoucher(String voucher) {
        Date today = Date.today();
        try {
            return [SELECT Discount__c FROM Promotion_Code__c WHERE Start_Date__c <= :today AND End_Date__c >= :today AND Code__c =: voucher].Discount__c;
        } catch (QueryException ex) {
            // Handle the query exception
            return null;
        }
    }
    @AuraENabled
    public static Boolean updateBookingToDone(String bookingId){
        Booking__c booking = new Booking__c(Id = bookingId);
        booking.Status__c = 'Done';
        try {
            update booking;
            return true;
        } catch (Exception e) {
            System.debug('Can not update booking ' + e.getMessage());
            return false;
        }
    }
}