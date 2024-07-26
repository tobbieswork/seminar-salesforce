public without sharing class CH4_SerminarController {
    @AuraEnabled(cacheable=false)
    public static List<Serminar__c> getSerminarList( String searchKey, String sortField, String sortOrder, String fromDate, String toDate, String fromPrice, String toPrice) {

        // FIND {Sa*} IN ALL FIELDS 
        // RETURNING Serminar__c
        // (Id, Name, Start_Date__c, Description__c, Price__c, Is_Public__c 
        // WHERE (Is_Public__c='True' AND  Price__c > 10 
        // AND Price__c < 10000000 AND Start_Date__c > 2023-06-21 
        // AND Start_Date__c < 2023-06-23) ORDER BY Name DESC)

        searchKey = searchKey != null ? searchKey : '';
        fromDate = fromDate != null ? fromDate : '';
        toDate = toDate != null ? toDate : '';
        fromPrice = fromPrice != null ? fromPrice : '';
        toPrice = toPrice != null ? toPrice : '';

        String optionalFilter = '';
        optionalFilter = fromDate == '' ? optionalFilter : optionalFilter + ' AND Start_Date__c>' + fromDate;
        optionalFilter = toDate == '' ? optionalFilter : optionalFilter + ' AND End_Date__c<'  + toDate;
        optionalFilter = fromPrice == '' ? optionalFilter : optionalFilter + ' AND Price__c>='  + fromPrice;
        optionalFilter = toPrice == '' ? optionalFilter : optionalFilter + ' AND  Price__c<='  + toPrice;
            
        sortOrder = sortOrder.toUppercase();

        if (searchKey == '' || searchKey.length() == 1){
            String statementQueryAllSerminar = 'SELECT Id, Name, Booking_Done_Quantity__c, Quantity__c, Description__c, Price__c, Start_Date__c, Image__c, End_Date__c '
            + ' FROM Serminar__c '
            + ' WHERE Is_Public__c = \'True\' ' + optionalFilter
            + ' ORDER BY '+ sortField + ' ' + sortOrder;

            List<Serminar__c> allSerminar = Database.query(statementQueryAllSerminar);

            return allSerminar;
        }

        searchKey = searchKey + '*';

        String queryStatement = 'FIND \'' + searchKey
        + '\' IN ALL FIELDS RETURNING Serminar__c(Id, Name, Booking_Done_Quantity__c, Quantity__c, Description__c, Price__c, Start_Date__c, Image__c, End_Date__c '
        +' WHERE (Is_Public__c = \'True\' ' + optionalFilter + ')'
        +' ORDER BY ' + sortField + ' ' + sortOrder + ')';

        try {
            List<List<SObject>> searchSerminars = search.query(queryStatement);
            return searchSerminars[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Serminar__c> getAllPublicSerminar(){
        try {
            return [
                SELECT Id, Name, Booking_Done_Quantity__c, Quantity__c, Description__c, Price__c, Start_Date__c, Image__c, End_Date__c, (SELECT Id FROM Booking__r WHERE Status__c = 'Done') 
                FROM Serminar__c  
                WHERE Is_Public__c = 'True'
                ORDER BY Name ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Serminar__c getRecordDataFromId(String recordId){
        return [
            SELECT Name, Image__c, Booking_Done_Quantity__c, Quantity__c, Description__c, Price__c, Start_Date__c, End_Date__c, (SELECT Name, Description__c, Status__c, Order__c FROM Section__r ORDER BY Order__c NULLS LAST) 
            FROM Serminar__c 
            WHERE Id=:recordId
        ];
    }
}