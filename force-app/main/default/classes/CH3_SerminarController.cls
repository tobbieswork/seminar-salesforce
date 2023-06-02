public with sharing class CH3_SerminarController {
    @AuraEnabled(cacheable=false)
    public static List<Serminar__c> getSerminarList(String searchKey) {

        // FIND {Sa*} IN ALL FIELDS 
        // RETURNING Serminar__c
        // (Id, Name, Start_Date__c, Description__c, Price__c, Is_Public__c 
        // WHERE (Is_Public__c='True' AND  Price__c > 10 
        // AND Price__c < 10000000 AND Start_Date__c > 2023-06-21 
        // AND Start_Date__c < 2023-06-23) ORDER BY Name DESC)

        if (searchKey == ''){
            return [
                SELECT Id, Name, Description__c, Price__c, Start_Date__c, Image__c 
                FROM Serminar__c  
                WHERE Is_Public__c = 'True'
            ];
        }

        searchKey = searchKey + '*';

        // String optionalFilter = '';
        // optionalFilter = fromDate == '' ? optionalFilter : optionalFilter + ' AND' + fromDate;
        // optionalFilter = toDate == '' ? optionalFilter : optionalFilter + ' AND '  + toDate;
        // optionalFilter = fromPrice == '' ? optionalFilter : optionalFilter + ' AND '  + fromPrice;
        // optionalFilter = toPrice == '' ? optionalFilter : optionalFilter + ' AND '  + toPrice;

        // String queryStatement = 'FIND \'' + searchKey
        // + '\' IN ALL FIELDS RETURNING Serminar__c(Id, Name, Description__c, Price__c, Start_Date__c '
        // +' WHERE (isPublic__c = \'True\' ' + optionalFilter + ')'
        // +' ORDER BY ' + fieldSort + ' ' + order + ')';

        try {
            return [
                FIND :searchKey 
                IN ALL FIELDS 
                RETURNING Serminar__c(Id, Name, Description__c, Price__c, Start_Date__c, Image__c WHERE Is_Public__c = 'True')
            ][0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Serminar__c> getAllPublicSerminar(){
        try {
            return [
                SELECT Id, Name, Description__c, Price__c, Start_Date__c, Image__c 
                FROM Serminar__c  
                WHERE Is_Public__c = 'True'
                ORDER BY Name ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}