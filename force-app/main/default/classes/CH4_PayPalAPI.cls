public without sharing class CH4_PayPalAPI {

    // PayPal API base URL
    private static final String BASE_URL = 'https://api-m.sandbox.paypal.com';

    // PayPal API endpoint for generate access token
    private static final String GENERATE_ACCESS_TOKEN = BASE_URL + '/v1/oauth2/token';

    // PayPal API endpoint for creating an order
    private static final String CREATE_ORDER_ENDPOINT = BASE_URL + '/v2/checkout/orders';

    // PayPal API endpoint for showing order detail
    private static final String SHOW_ORDER_DETAIL_ENDPOINT = BASE_URL + '/v2/checkout/orders/';

    // PayPal API endpoint for capturing the payment
    private static final String CAPTURE_PAYMENT_ENDPOINT = BASE_URL + '/v2/checkout/orders/';

    // PayPal API client credentials
    private static final String PAYPAL_API_CLIENT_ID = 'example-key';
    private static final String PAYPAL_API_CLIENT_SECRET = 'example-key';
    
    
    private static String getAccessToken() {
        
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

    @AuraEnabled
    public static String createOrder(String orderBody) {
        String newAccessToken = CH4_PayPalAPI.getAccessToken();
        String authorizationValue = 'Bearer ' + newAccessToken;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(CREATE_ORDER_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationValue);
        request.setBody(orderBody);

        
        try {
            HttpResponse response = new Http().send(request);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(response.getBody()));
            List<Object> links = (List<Object>)responseMap.get('links');
            Map<String, Object> payLink = (Map<String, Object>)links[1];
            String payUrl = (String)payLink.get('href');
            return payUrl;
        } catch (Exception e) {
            System.debug('Has error when create order: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static String showOrderDetail(String orderId) {
        String newAccessToken = CH4_PayPalAPI.getAccessToken();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(SHOW_ORDER_DETAIL_ENDPOINT + orderId);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + newAccessToken);

        try {
            // Send the request and get the response
            HttpResponse response = new Http().send(request);
            
            if (response.getStatusCode() == 200) {
                // Successful response
                String responseBody = response.getBody();
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                Map<String, Object> purchaseUnits = (Map<String, Object>) (((List<Object>)responseMap.get('purchase_units'))[0]);
                return (String) purchaseUnits.get('reference_id');
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

    @AuraEnabled
    public static Boolean capturePayment(String orderId) {
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