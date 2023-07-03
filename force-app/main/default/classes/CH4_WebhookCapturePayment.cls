@RestResource(urlMapping='/paypal/captured')
// https://furucrm72-dev-ed.develop.my.site.com/services/apexrest/paypal/captured
global without sharing class CH4_WebhookCapturePayment {
    @HttpPost
    global static void handlePatchBookingAndInsertPayment() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        System.debug('Captured');
        System.debug(request);
        System.debug(String.valueOf(request.requestBody.toString()));
        System.debug(response);
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(request.requestBody.toString()));
        
        Map<String, Object> resourceMap = (Map<String, Object>)requestBodyMap.get('resource');
        Map<String, Object> supplementaryDataMap = (Map<String, Object>)resourceMap.get('supplementary_data');
        Map<String, Object> relatedIdsMap = (Map<String, Object>)supplementaryDataMap.get('related_ids');
        String orderId = (String) relatedIdsMap.get('order_id');

        Map<String, Object> amountMap = (Map<String, Object>)resourceMap.get('amount');
        String amountValue = (String) amountMap.get('value');

        String bookingId;
        try {
                bookingId = CH4_PayPalAPI.showOrderDetail(orderId);
        } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
        }

        Booking__c bookingRecord = new Booking__c(Id = bookingId);

        Payment__c payment = new Payment__c();
        payment.Booking__c = bookingId;
        // payment.Payment_Date__c = Datetime.now();
        payment.Price__c = Decimal.valueOf(amountValue);

        
        bookingRecord.Status__c = 'Done';
        // try {
        //     update bookingRecord;
        // } catch (Exception e) {
        //     System.debug('Update booking has an error: ' + e.getMessage());
        //     bookingRecord.Status__c = 'Refund';
        //     update bookingRecord;
        // }
        
        // try {
        //     insert payment;
        // } catch (Exception e) {
        //     System.debug('Insert payment has an error: ' + e.getMessage());
        // }
        response.statusCode = 200;
    }
    @HttpGet
    global static void handleGetCapture() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        System.debug('calling!!!');
        System.debug(request);
        System.debug(response);
        Map<String, Object> responseBody = new Map<String, Object>();
        responseBody.put('status', 'success');
        responseBody.put('message', 'Webhook processed successfully');

        // Set the response body and status code
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf(JSON.serialize(responseBody));
        response.statusCode = 200;
    }

}