public without sharing class LWC03_EmailForm_Ctrl {

    public class BackgroundImage {
        @AuraEnabled
        public String templateName {get;set;}
        @AuraEnabled
        public String link {get;set;}
    }

/* UI METHODS */

    /* Get current contact */
    @AuraEnabled(Cacheable=true)
    public static Contact getCurrentContact() {
        return (AP1002_Utils_User.getConnectedUserContact());
    }

    /* Method to search contact */
    @AuraEnabled(Cacheable=true)
    public static List<AP1002_LookupSearchResult> search(String contactType, String searchTerm, List<String> selectedIds) {

        // Get contact of the current User
        User u = [SELECT Id, TECH_MergeContactID__c FROM User WHERE Id =: UserInfo.getUserId()];
        system.debug('>>>> contactType :' + contactType);

        if (contactType == Label.LU_TECH_Contact_Team) {
            return (LWC03_EmailForm_Ctrl.searchTeamMember(u, searchTerm, selectedIds));
        } else {
             return (LWC03_EmailForm_Ctrl.searchCustomer(u, searchTerm, selectedIds));
        }
        
        // Always return team member (as customer not set yet)
        //return (LWC03_EmailForm_Ctrl.searchTeamMember(u, searchTerm, selectedIds));

    }

    /* Method to send email to selected contacts */
    @AuraEnabled
    public static AP39_BackResults sendEmail(String subject, String body, List<AP1002_LookupSearchResult> targets, List<String> files, Boolean sendToManager, String contactType) {

        // Variables
        AP39_BackResults res = new AP39_BackResults();
        List<String> lFilesId = new List<String>();
        List<ContentDocument> lVersions = null;
        // Get current contact information
        Contact con = AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());
        Set<Id> s_idContactBcc = new Set<Id>();


        try {

            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            
            // If target for the mail
            if (targets != null && !targets.isEmpty()) {

                // get all the recipients of the mail to be send
                for (AP1002_LookupSearchResult lsr : targets){
                    s_idContactBcc.add(lsr.id);
                }

                // If a copy should be send to the manager
                if (sendToManager) {

                    Id managerId = AP1003_Utils_Contact.getDirectManagerContactid(con);
                    if (managerId != null) {
                        s_idContactBcc.add(managerId);
                    }
        
                }

                // Manage files to be attached
                if (files != null && !files.isEmpty()) {
                    lVersions = [SELECT Id, LatestPublishedVersionId 
                                    FROM ContentDocument
                                    WHERE Id in: files];
                    for (ContentDocument doc : lVersions) {
                        lFilesId.add(doc.LatestPublishedVersionId);
                    }
                }

                // For every user that should receive the mail, prepare the mail
                if (contactType == Label.LU_TECH_Contact_Team) {
                    // Get the users to who send the email
                    List<User> l_userToSend = new List<User>();

                    //JJE - 20/04/2021 - Problème d'envoi de mail si la liste est > 80 contacts (pb avec la query)
                    if(s_idContactBcc.size() > 70){
                        Set<Id> s_idContactBcc1 = new Set<Id>();
                        Set<Id> s_idContactBcc2 = new Set<Id>();
                        Integer x = 0;
                        for(Id id : s_idContactBcc){
                            if(x < 70) s_idContactBcc1.add(id);
                            else s_idContactBcc2.add(id);
                            x ++;
                        }
                        List<User> l_userToSend1 = [SELECT Id, TECH_MergeContactID__c FROM User WHERE TECH_MergeContactID__c IN :s_idContactBcc1];
                        List<User> l_userToSend2 = [SELECT Id, TECH_MergeContactID__c FROM User WHERE TECH_MergeContactID__c IN :s_idContactBcc2];
                        l_userToSend.addAll(l_userToSend1);
                        l_userToSend.addAll(l_userToSend2);
                    }
                    else l_userToSend = [SELECT Id, TECH_MergeContactID__c FROM User WHERE TECH_MergeContactID__c IN :s_idContactBcc];
                    for(User u : l_userToSend) {

                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(u.Id);
                        mail.setSubject(subject);
                        mail.setHTMLBody(body);
                        mail.setSaveAsActivity(false);
                        if(u.TECH_MergeContactID__c != null){
                            mail.setWhatId(u.TECH_MergeContactID__c);
                        }
                        if (!lFilesId.isEmpty()) {
                            mail.setEntityAttachments(lFilesId);
                        }

                        messages.add(mail);
                    }
                } else {
                    List<Contact> l_ContactToSend = [SELECT Id, Email, FirstName, LastName 
                                                    FROM Contact 
                                                    WHERE Id IN :s_idContactBcc];
                    
                    res.message = '';

                    for(Contact vCon : l_ContactToSend){
                        if(String.IsBlank(vCon.Email)){
                            res.success = false;
                            if(res.message != ''){
                                res.message += ', ';
                            }
                            res.message += vCon.FirstName + ' ' + vCon.LastName;
                        }
                    }

                    if(res.message != ''){
                        res.message = 'Contacts sans adresse email : ' + res.message;
                        return res;
                    }

                    for(Contact vCon : l_ContactToSend) {
                        String vUnsub = Label.LU_Unsubscribe_Link;
                        String vConMail = vCon.Email;
                        String vConId = vCon.Id;
                        if(String.isNotBlank(vConMail) && String.isNotBlank(vConId)){
                            vUnsub = vUnsub.replace('$mail', vCon.Email);
                            vUnsub = vUnsub.replace('$id', vCon.Id);
                        }

                        String vBody = body + vUnsub;

                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(vCon.Id);
                        mail.setSubject(subject);
                        mail.setHTMLBody(vBody);
                        mail.setSaveAsActivity(false);
                        mail.setWhatId(vCon.Id);
                        if (!lFilesId.isEmpty()) {
                            mail.setEntityAttachments(lFilesId);
                        }
    
                        messages.add(mail);
                    }
                }

                messages.add( getSenderMail(subject, body, targets, lFilesId, sendToManager, contactType) );

            }

            // If mails are to be sent
            if (!messages.isEmpty())
            {   

                // Send email                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) {
                    res.success = true;
                    res.message = '';

                    // Delete the attachment from the Files
                    if (lVersions != null && !lVersions.isEmpty()) {
                        delete lVersions;
                    }


                } else {
                    res.success = false;
                    res.message = results[0].errors[0].message;
                }
            }

        } catch (Exception e) {
            res.success = false;
            res.message = e.getMessage();
        }

        return (res);
    }

    private static Messaging.SingleEmailMessage getSenderMail(String subject, String body, List<AP1002_LookupSearchResult> targets, 
                                                                List<String> files, Boolean sendToManager, String contactType) {
                                                                    
        // Prepare the body of the mail
        String sendTo = '<b>' + Label.LU_Mail_Sender_SendTo + ' </b><br/>';
        for (AP1002_LookupSearchResult t : targets){
            sendTo += t.title + ' - ';
        }
        sendTo = sendTo.left(sendTo.length() - 3) + '\n \n';
        String copyManager = '';
        if(contactType != Label.LU_TECH_Contact_Customer) {
            copyManager = '<br/><br/><b>' + Label.LU_Mail_Sender_CopyManager + ' </b><br/>';
            copyManager += (sendToManager ? Label.LU_Mail_Sender_CopyManager_YES : Label.LU_Mail_Sender_CopyManager_NO); 
            copyManager = copyManager.left(sendTo.length() - 3) + '\n \n';
        }
        body = sendTo + copyManager + '<br/><br/><b>' + Label.LU_Mail_Sender_BodySent + '</b><br/><br/>' + body;

        // Prepare the mail itself
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSubject(subject);
        mail.setHTMLBody(body);
        mail.setSaveAsActivity(false);
        if (files != null && !files.isEmpty()) {
            mail.setEntityAttachments(files);
        }

        return mail;
    }


    // Remove files uploaded
    @AuraEnabled
    public static Boolean deleteContentDocument(List<String> contentDocumentIds) {
        
        try {
            List<ContentDocument> lDoc = new List<ContentDocument>();
            for (String idDoc : contentDocumentIds) {
                ContentDocument doc = new ContentDocument(Id = idDoc);
                lDoc.add(doc);
            }
            
            if (!lDoc.isEmpty()) {
                delete lDoc;
            }

        } catch (Exception e) {
            return (false);
        }

        return (true);
    }



    /* BUSINESS METHODS */
    public static List<AP1002_LookupSearchResult> searchCustomer(User u, String searchTerm, List<String> selectedIds) {

        String likeStr = (searchTerm != '' ? '%' + searchTerm + '%' : '');
        List<AP1002_LookupSearchResult> lRes = new List<AP1002_LookupSearchResult>();

        List <String> lIds = new List<String>();
        for (String ids : selectedIds) {
            ids = '\'' + ids + '\'';
            lIds.add(ids);
        }

        String soql = 'SELECT Id, FirstName, LastName, Email ' +
                        ' FROM Contact ' + 
                        ' WHERE RecordType.DeveloperName = \'LU_Personal_Contact\'  AND LU_Is_Deleted__c = false AND Email != \'\' AND OwnerId = \'' + u.Id + '\' AND HasOptedOutOfEmail = false AND LU_Consent_Answer_Date__c != null';

        String whereSoql = ' AND ';
        if (lIds != null && !lIds.isEmpty()) {
            whereSoql += ' Id Not In ' + lIds + ' ';
        }
        if (likeStr != '') {
            whereSoql += (whereSoql == ' AND ' ? '' : ' AND ');
            whereSoql += ' (LastName LIKE \'' + likeStr + '\' OR FirstName LIKE \'' + likeStr + '\' ) ';
        }

        soql += (whereSoql != ' AND ' ? whereSoql : '');
        system.debug(soql);
        List<Contact> lContacts = Database.query(soql);
                                    
        if (!lContacts.isEmpty()) {
            for (Contact con : lContacts) {
                AP1002_LookupSearchResult res = new AP1002_LookupSearchResult(con.Id, 'Contact', 'standard:contact',
                                                                               con.FirstName + ' ' + con.LastName,
                                                                               con.Email);
                lRes.add(res);
            }
        }

        return (lRes);

    }

    public static List<AP1002_LookupSearchResult> searchTeamMember(User u, String searchTerm, List<String> selectedIds) {
        
        Contact contactUser = AP1002_Utils_User.getContactFromUser(u.Id);//[SELECT Id, AccountCountryCode__c FROM Contact WHERE Id = :u.TECH_MergeContactID__c];

        List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(u, contactUser);
 
        List<Contact> lContacts = null;
        if (l_teamAccounts != null) {
            lContacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE AccountId IN :l_teamAccounts AND LU_Out_Of_Business__c = false];
        } else {
            lContacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE LU_Out_Of_Business__c = false AND (ReportsToId =: contactUser.Id AND Parent_STH_Id__c =: contactUser.Id)];
        }
        String strTeamIds = '';
        for (Contact c : lContacts) {
            strTeamIds += (strTeamIds != '' ? ',' : '') + '\'' + c.Id + '\'';
        }

        List<AP1002_LookupSearchResult> lRes = new List<AP1002_LookupSearchResult>();

        String likeStr = (searchTerm != '' ? '%' + searchTerm + '%' : '');

        List <String> lIds = new List<String>();
        for (String ids : selectedIds) {
            if (ids != '...' && ids != ', ...') {
                ids = '\'' + ids + '\'';
                lIds.add(ids);
            }
        }

        String soql = 'SELECT Id, FirstName, LastName, Email ' +
                        ' FROM Contact ' + 
                        ' WHERE RecordType.DeveloperName != \'LU_Personal_Contact\' ' + 
                        ' AND Email != \'\' AND ActivityStatus__c = true ';
        if(strTeamIds != ''){
            soql += ' AND Id in ( ' + strTeamIds + '  ) ';
        }
                        // ' WHERE RecordType.DeveloperName != \'LU_Personal_Contact\' AND Email != \'\' AND ActivityStatus__c = true AND ( Parent_STH_Id__c = \'' + u.TECH_MergeContactID__c + '\' OR ReportsToId = \'' + u.TECH_MergeContactID__c + '\' ) ';
        String whereSoql = ' AND ';
        if (lIds != null && !lIds.isEmpty()) {
            whereSoql += ' Id Not In ' + lIds + ' ';
        }
        if (likeStr != '') {
            whereSoql += (whereSoql == ' AND ' ? '' : ' AND ');
            whereSoql += ' (LastName LIKE \'' + likeStr + '\' OR FirstName LIKE \'' + likeStr + '\' ) ';
        }

        soql += (whereSoql != ' AND ' ? whereSoql : '');
        if(soql.contains(', ...')) soql = soql.replace(', ...', '');
        System.debug(soql);
        if(soql.length() > 150) System.debug(soql.substring(150, soql.length()-1));
        if(soql.length() > 300) System.debug(soql.substring(300, soql.length()-1));
        lContacts = Database.query(soql);
                                    
        if (!lContacts.isEmpty()) {
            for (Contact con : lContacts) {
                AP1002_LookupSearchResult res = new AP1002_LookupSearchResult(con.Id, 'Contact', 'standard:contact',
                                                                               con.FirstName + ' ' + con.LastName,
                                                                               con.Email);
                lRes.add(res);
            }
        }

        return (lRes);

    }

    @AuraEnabled
    public static List<EmailTemplate> getEmailTemplate(){

        String country = AP1002_Utils_User.getUserCountry(UserInfo.getUserId()) + '_TEMPLATE_MANAGER_NB_%';

        return [SELECT DeveloperName, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName LIKE :country];
    }

    @AuraEnabled
    public static List<BackgroundImage> getEmailTemplateBackgroundImages(){

        String country = AP1002_Utils_User.getUserCountry(UserInfo.getUserId()) + '_TEMPLATE_MANAGER_NB_%';

        List<BackgroundImage> l_backgroundImages = new List<BackgroundImage>();

        List<String> l_templateName = new List<String>();
        for(EmailTemplate temp : [SELECT DeveloperName, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName LIKE :country]){
            l_templateName.add(temp.DeveloperName);
        }

        for(Document doc : [SELECT Id, Keywords FROM Document WHERE Keywords IN :l_templateName]){

            BackgroundImage img = new BackgroundImage();
            img.templateName = doc.Keywords;
            img.link = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + doc.Id + '&oid=' + UserInfo.getOrganizationId();

            l_backgroundImages.add(img);
        }

        return l_backgroundImages;
    }
}