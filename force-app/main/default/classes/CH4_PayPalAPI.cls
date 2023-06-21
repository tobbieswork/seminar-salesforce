public class CH4_PayPalAPI {

    // PayPal API base URL
    private static final String BASE_URL = 'https://api-m.sandbox.paypal.com';

    // PayPal API endpoint for generate access token
    private static final String GENERATE_ACCESS_TOKEN = BASE_URL + '/v1/oauth2/token';

    // PayPal API endpoint for creating an order
    private static final String CREATE_ORDER_ENDPOINT = BASE_URL + '/v2/checkout/orders';

    // PayPal API endpoint for capturing the payment
    private static final String CAPTURE_PAYMENT_ENDPOINT = BASE_URL + '/v2/checkout/orders/';

    // PayPal API client credentials
    private static final String PAYPAL_API_CLIENT_ID = 'AXRWjzDtGJ20Ux2zuuwn38V5LFxTOgubfE6wFbrsYmXlgukePZuoSM3FDdxYVCX576r9Qj46EQFRMEWD';
    private static final String PAYPAL_API_CLIENT_SECRET = 'EG5LRXP8t6uSObqqCuxLmhPVdUSPsBHVd3cZCSe-S1bLWoQ0Qs0G_81FoIqaxVShv-3CMd93tc1_pF7_';

    @AuraEnabled
    public static String getAccessToken() {

        String clientId = PAYPAL_API_CLIENT_ID;
        String clientSecret = PAYPAL_API_CLIENT_SECRET;
        String credentials = clientId + ':' + clientSecret;

        String encodedCredentials = EncodingUtil.base64Encode(Blob.valueof(credentials));
        String base64EncodedCredentials = EncodingUtil.urlEncode(encodedCredentials, 'UTF-8');
        String authorizationHeader = 'Basic ' + encodedCredentials;

        // Create an HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GENERATE_ACCESS_TOKEN);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Authorization', authorizationHeader);
        
        // Set the request body
        String requestBody = 'grant_type=client_credentials';
        request.setBody(requestBody);
        
        // Create an HTTP object to send the request
        Http http = new Http();
        
        try {
            // Send the request and get the response
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Successful response
                String responseBody = response.getBody();
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                return (String) responseMap.get('access_token');
            } else {
                // Error response
                String errorMessage = 'API call failed with status code: ' + response.getStatusCode();
                System.debug(errorMessage);
                return null;
            }
        } catch (Exception e) {
            // Exception occurred
            System.debug('Error occurred while making API call: ' + e.getMessage());
            return null;
        }
    }

    public static HttpResponse createOrder() {
        String newAccessToken = CH4_PayPalAPI.getAccessToken();
        String authorizationValue = 'Bearer ' + newAccessToken;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(CREATE_ORDER_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationValue);

        // Set the request body
        request.setBody('{"intent": "CAPTURE", "purchase_units": [{"amount": {"currency_code": "USD", "value": "10.00"}}]}');

        HttpResponse response = new Http().send(request);
        return response;
    }

    @AuraEnabled
    public static Boolean executePayment(String orderId) {
        String newAccessToken = CH4_PayPalAPI.getAccessToken();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(CAPTURE_PAYMENT_ENDPOINT + orderId + '/capture');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + newAccessToken);

        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 201) {
            return true;
        } else {
            throw new AuraHandledException('Failed to execute PayPal payment: ' + response.getBody());
        }
    }
    
}
