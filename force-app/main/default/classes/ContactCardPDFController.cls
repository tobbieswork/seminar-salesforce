public class ContactCardPDFController {
    public ContactCardPDFController(ApexPages.StandardController controller) {
        Contact_Card__c acc = (Contact_Card__c)controller.getRecord();
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment');
    }
}