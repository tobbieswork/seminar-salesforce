trigger CH2_ContactCardTrigger on Contact_Card__c (after insert) {
	CH2_ContactCardTriggerHandler.configCardNumber(Trigger.newMap);
}