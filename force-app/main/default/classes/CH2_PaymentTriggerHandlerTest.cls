@isTest
public class CH2_PaymentTriggerHandlerTest {
    @isTest static void paymentTest() {
		//CREATE TEST DATA
        //Create serminars
        List<Serminar__c> serminars = new List<Serminar__c>();
        for(Integer i = 0; i < 2; i++){
            Serminar__c serminar = new Serminar__c(
                Name = 'Serminar for Payment Test' + i,
                Quantity__c = 2,
                Start_Date__c = date.newInstance(2023, 6, 25),
                End_Date__c = date.newInstance(2023, 8, 17),
                Code__c = 'TEST'
            );
            System.debug(serminar.Start_Date__c);
            serminars.add(serminar);
        }
        insert serminars;
        
        //Create contacts
        Contact newCt = new Contact(
        	FirstName = 'Ca Loc',
    		LastName = 'Kho To',
            Phone = '868006',
            Email = 'cabasa@vipro.com'
        );
        insert newCt;
        
        //Create bookings
        List<Booking__c> bookings = new List<Booking__c>();
        for(Integer i = 0; i < 2; i++){
            for(Integer j = 0; j < 2; j++){
                Booking__c booking = new Booking__c(
                    Serminar__c = serminars[i].Id,
                    Contact__c = newCt.Id,
                    Total_Amount__c = 2000,
                    Status__c = 'Done'
                );
                bookings.add(booking);
            }
            for(Integer j = 0; j < 2; j++){
                Booking__c booking = new Booking__c(
                    Serminar__c = serminars[i].Id,
                    Contact__c = newCt.Id,
                    Total_Amount__c = 2000,
                    Status__c = 'Pending'
                );
                bookings.add(booking);
            }
        }
        insert bookings;
        
        //Create payments
        List<Payment__c> pms = new List<Payment__c>();
        for(Booking__c bk : bookings){
            for(Integer i = 0; i < 5; i++){
                Payment__c pm = new Payment__c(
                	Booking__c = bk.Id,
                    Price__c = bk.Total_Amount__c
                );
                System.debug(bk.Id);
                pms.add(pm);
            }
        }
        
        //This payment does not satisfy condition for create new contact card
        Payment__c newPm = new Payment__c(
            Booking__c = bookings[0].Id,
            Price__c = bookings[0].Total_Amount__c + 1
        );
        
		//TEST
		//Confirm that contact cards will be created when have valid payments
		Test.startTest();
        
        Integer numberCtcards = [SELECT COUNT() FROM Contact_Card__c];
        insert pms;
        Integer newNumberCtcards = [SELECT COUNT() FROM Contact_Card__c];
        System.assertEquals(newNumberCtcards, numberCtcards + 40);
        
        //No contact card be created after insert this unsatisfy payment
        insert newPm;
        //Query contact card after insert
        Integer newestNumberCtcards = [SELECT COUNT() FROM Contact_Card__c];
        System.assertEquals(newestNumberCtcards, newNumberCtcards);
        
        Test.stopTest();
    }
}