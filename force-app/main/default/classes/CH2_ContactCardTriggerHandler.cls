public without sharing class CH2_ContactCardTriggerHandler {
	public static void configCardNumber(Map<Id, Contact_Card__c> ctcards){
        
        Integer nextIndex = 1;
        System.debug(nextIndex);
        List<Contact_Card__c> ctcardsListUpdate = new List<Contact_Card__c>();
        
        List<Contact_Card__c> listCtCard = [
            SELECT Name, Card_Number__c, Contact__r.Email, Contact__r.Name, Serminar__r.Code__c, Serminar__r.Start_Date__c 
            FROM Contact_Card__c 
            WHERE Id IN : ctcards.keySet()
        ];

        List<Contact_Card__c> allCtCards = [
            SELECT Card_Number__c 
            FROM Contact_Card__c
        ];
        
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
        try {
            for (Contact_Card__c ctc : ctcardsListUpdate) {
                sendContactCard(ctc.Id, ctc.Contact__r.Email, ctc.Contact__r.Name);
                update ctcardsListUpdate;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @future(callout=true)
    public static void sendContactCard(String contactCardId, String contactEmail, String contactName) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        email.setToAddresses(new List<String>{ contactEmail });
        email.setOrgWideEmailAddressId('0D25i000000CcEUCA0');
        email.setSubject('Hello ' + contactName + ', welcome to furuCRM');
        email.setHtmlBody('Dear Recipient\'s Name,\nThank you for your recent request. We have prepared a PDF file containing the details of your information. Please review the PDF attached to this email and confirm that all the information is accurate.\nIf you have any updates or changes, kindly let us know by replying to this email or contacting our customer support team. Your feedback is important to us.\nAttached is the PDF file: ContactCard.pdf\nWe appreciate your prompt attention to this matter. Thank you for choosing our services.\nBest regards,\nDang Phat\nfuruCRM');

        PageReference pageRef = Page.CH2_ContactCardCreatePage;
        pageRef.getParameters().put('id', contactCardId);
        Blob pdfContent = pageRef.getContentAsPDF();

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('ContactCard.pdf');
        attachment.setBody(pdfContent);
        attachment.setContentType('application/pdf');

        email.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });

        Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }
}