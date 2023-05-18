@isTest
public class CH1_BookingTriggerHandlerTest {
    @isTest static void inSert5SerminarAnd50BookingRecordsForEach() {
        //Create test data
        
        //Create serminars
        List<Serminar__c> serminars = new List<Serminar__c>();
        for(Integer i = 0; i < 5; i++){
            Serminar__c serminar = new Serminar__c(
                Name = 'Serminar Test' + i,
                Quantity__c = 10
            );
            serminars.add(serminar);
        }
        insert serminars;
		//Create bookings each serminar
        List<Booking__c> bookings = new List<Booking__c>();
        for(Integer i = 0; i < 5; i++){
            for(Integer j = 0; j < 10; j++){
                Booking__c booking = new Booking__c(
                    Serminar__c = serminars[i].Id,
                    Status__c = 'Done'
                );
                bookings.add(booking);
            }
        }
		
        //Test positive scenario
        Test.startTest();
        insert bookings;

        //Verify that no errors are thrown
        System.assertEquals(false, ApexPages.hasMessages(ApexPages.Severity.ERROR));

        //Test negative scenario
        Booking__c bookingOverFlow = new Booking__c(
            Serminar__c = serminars[0].Id,
            Status__c = 'Done'
        );
        bookings.add(bookingOverFlow);
        List<Database.SaveResult> results = Database.insert(bookings, false);
		
        //Verify that an error is thrownW
        for (Database.SaveResult result : results){
            if (!result.isSuccess()) {
                // Notify insertion is success!
                System.debug('Record inserted successfully. ID: ' + result.getId());
            }
            else{
        		// Handle insert failure
        		for (Database.Error error : result.getErrors()) {
            		// Process the error
            		System.debug('Insert error: ' + error.getStatusCode() + ' - ' + error.getMessage());
        		}
    		}
        }
        Test.stopTest();
    }
}