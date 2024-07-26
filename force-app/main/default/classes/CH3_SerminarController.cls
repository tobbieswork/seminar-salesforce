public with sharing class CH3_SerminarController {
    @AuraEnabled(cacheable=false)
    public static List<Serminar__c> getSerminarList(String searchKey) {
        
        if (searchKey == ''){
            return [
                SELECT Id, Name, Description__c, Price__c, Start_Date__c, Image__c 
                FROM Serminar__c  
                WHERE Is_Public__c = 'True'
            ];
        }
        
        searchKey = searchKey + '*';
        
        return [
            FIND :searchKey 
            IN ALL FIELDS 
            RETURNING Serminar__c(Id, Name, Description__c, Price__c, Start_Date__c, Image__c WHERE Is_Public__c = 'True')
        ][0];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Serminar__c> getAllPublicSerminar(){
        return [
            SELECT Id, Name, Description__c, Price__c, Start_Date__c, Image__c 
            FROM Serminar__c  
            WHERE Is_Public__c = 'True'
            ORDER BY Name ASC
        ];
        
    }
    
}