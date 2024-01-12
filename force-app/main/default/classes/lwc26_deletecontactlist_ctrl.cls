public without sharing class lwc26_deletecontactlist_ctrl {

    @AuraEnabled
    public static void deleteSingleContactFromId(String idContact) {

        deleteContactList([SELECT Id FROM Contact WHERE Id = :idContact]);
    }

    @AuraEnabled
    public static void deleteContactList(List<Contact> l_contactToDelete) {
    
        List<Contact> l_contacts = [SELECT Id, Firstname, Lastname, Email, Phone, MailingCity, MailingState, MailingCountry, MailingPostalCode,
                                            Birthdate, LU_Is_Deleted__c, LU_Contact_Number__c, MailingStreet
                                      FROM Contact 
                                     WHERE Id IN :l_contactToDelete];

        lwc26_deletecontactlist_ctrl.sendDeletionConfirmationEmail(l_contacts);

        for(Contact con : l_contacts){
            con.Firstname = '';
            con.Lastname = con.LU_Contact_Number__c;
            con.Phone = '';
            con.Email = '';
            con.MailingCity = '';
            con.MailingState = '';
            con.MailingCountry = '';
            con.MailingPostalCode = '';
            con.MailingStreet = '';
            con.Birthdate = null;
            con.LU_Is_Deleted__c = true;
        }     

        update l_contacts;                                             
    }

    public static void sendDeletionConfirmationEmail(List<Contact> l_contactToDelete) {

        EmailTemplate templateEm = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Customer_ConfirmDeletion_ITA' LIMIT 1];

        OrgWideEmailAddress emailAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Stanhome' LIMIT 1];

        if (templateEm != null) {
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            
            for(Contact con : l_contactToDelete){
                if(!String.IsBlank(con.Email)){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String html = templateEm.HtmlValue.replace('{!Contact.LastName}', con.LastName);
                    String text = templateEm.Body.replace('{!Contact.LastName}', con.LastName);

                    if(!String.isBlank(con.FirstName)){
                        html = html.replace('{!Contact.FirstName}', con.FirstName);
                        text = text.replace('{!Contact.FirstName}', con.FirstName);
                    }
                    else{
                        html = html.replace('{!Contact.FirstName}', '');
                        text = text.replace('{!Contact.FirstName}', '');
                    }

                    mail.setToAddresses(new List<String>{con.Email});
                    mail.setOrgWideEmailAddressId(emailAddress.Id);
                    mail.setSubject(templateEm.Subject);
                    mail.setPlainTextBody(text);
                    mail.setHtmlBody(html);
                    mail.setSaveAsActivity(false);

                    messages.add(mail);
                }
            }

            if (!messages.isEmpty()){
                // Send email                
                if(!Test.isRunningTest())Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
    }
}