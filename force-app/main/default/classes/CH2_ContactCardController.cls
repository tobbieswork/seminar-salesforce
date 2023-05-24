public with sharing class CH2_ContactCardController {
    private ApexPages.StandardController standardController;

    public CH2_ContactCardController(ApexPages.StandardController controller) {
        standardController = controller;

        Contact_Card__c currentRecord = (Contact_Card__c)standardController.getRecord();
        avatar = currentRecord.Contact__r.Avatar__c;
    }

    public Contact_Card__c contactCard { get; set; }
    public String avatar { get; set; }

	
    
}