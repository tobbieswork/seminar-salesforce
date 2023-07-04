@RestResource(urlMapping='/paypal/ipn')
// URL: https://furucrm72-dev-ed.develop.my.site.com/services/apexrest/paypal/ipn
global without sharing class CH4_PaymentWebhook {
    @HttpPost
    global static void handleOrder() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(request.requestBody.toString()));
        Map<String, Object> resourceMap = (Map<String, Object>)requestMap.get('resource');
        List<Object> purchaseUnits = (List<Object>)resourceMap.get('purchase_units');
        Map<String, Object> purchaseUnitsMap = (Map<String, Object>)purchaseUnits[0];
        Map<String, Object> amountMap = (Map<String, Object>)purchaseUnitsMap.get('amount');

        String amountValue = String.valueOf(amountMap.get('value'));
        String referenceId = String.valueOf(purchaseUnitsMap.get('reference_id'));
        String orderId = String.valueOf(resourceMap.get('id'));

        try {
            response.statusCode = 200;
            CH4_PayPalAPI.capturePayment(orderId);

            Booking__c bookingRecord = new Booking__c(Id = referenceId);
            bookingRecord.Status__c = 'Done';
            try {
                update bookingRecord;
            } catch (Exception e) {
                System.debug('Update booking has an error: ' + e.getMessage());
                bookingRecord.Status__c = 'Refund';
                update bookingRecord;
            }

            CH4_PaymentController.createPaymentForBooking(referenceId, amountValue);
        } catch (Exception e) {
            // response.statusCode = 422;
            System.debug(e.getMessage());
        }
    }

    @HttpGet
    global static void getOrder() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        Map<String, Object> responseBody = new Map<String, Object>();
        responseBody.put('status', 'success');
        responseBody.put('message', 'Webhook processed successfully');
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf(JSON.serialize(responseBody));
        response.statusCode = 200;
    }
}