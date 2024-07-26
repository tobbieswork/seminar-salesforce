public without sharing class CH4_SendContactCardController {
    @future(callout=true)
    public static void sendContactCard(String contactCardId, String contactEmail) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        // Set the recipient
        email.setToAddresses(new List<String>{ contactEmail });

        // Set the email subject and body
        email.setSubject('My Email Subject');
        email.setHtmlBody('Hello, Please find the attached Visualforce page.');

        // Generate the PDF content from the Visualforce page
        PageReference pageRef = Page.CH2_ContactCardCreatePage;
        pageRef.getParameters().put('id', contactCardId);
        Blob pdfContent = pageRef.getContentAsPDF();

        // Create an email attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('ContactCard.pdf');
        attachment.setBody(pdfContent);
        attachment.setContentType('application/pdf');

        // Add the attachment to the email
        email.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });

        // Send the email
        Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }
}