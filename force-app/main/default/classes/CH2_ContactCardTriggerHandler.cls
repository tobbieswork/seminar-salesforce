public class CH2_ContactCardTriggerHandler {
	public static void configCardNumber(Map<Id, Contact_Card__c> ctcards){
        
        Integer nextIndex = 1;
        System.debug(nextIndex);
        List<Contact_Card__c> ctcardsListUpdate = new List<Contact_Card__c>();
        
        List<Contact_Card__c> listCtCard = [
            SELECT Name, Card_Number__c, Serminar__r.Code__c, Serminar__r.Start_Date__c 
            FROM Contact_Card__c 
            WHERE Id IN : ctcards.keySet()];
        List<Contact_Card__c> allCtCards = [
            SELECT Card_Number__c 
            FROM Contact_Card__c];
        
        for(Contact_Card__c ctc : allCtCards){
            if(ctc.Card_Number__c != null){
                List<String> splitCardName = ctc.Card_Number__c.split('-');
                System.debug(ctc.Card_Number__c);
                Integer autoNum = Integer.valueOf(splitCardName[Integer.valueOf(splitCardName.size() - 1)]);
                if(autoNum >= nextIndex){
                    nextIndex = autoNum + 1;
                }
            }
        }
        
        for(Contact_Card__c ctcard : listCtCard){
            String autoIndex = String.valueOf(nextIndex);
            while(autoIndex.length() < 3){
                autoIndex = '0' + autoIndex;
            }
            DateTime dt = Date.valueOf(ctcard.Serminar__r.Start_Date__c);
            ctcard.Card_Number__c = ctcard.Serminar__r.Code__c + '-' + String.valueOf(dt.format('yyyyMMdd')) + '-' + autoIndex;
            ctcardsListUpdate.add(ctcard);
            nextIndex++;
        }
        update ctcardsListUpdate;
    }
}