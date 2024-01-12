public without sharing class lwc92_forgot_username_ctrl {
    
    @AuraEnabled
    public static void sendUsernameEmail(String email) {

        User us;
        try{
            us = [SELECT Id, Username FROM User WHERE Email = :email];
        } catch(Exception e){
            return;
        }

        System.debug('user' + us);

        EmailTemplate et = [SELECT Id, Body, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'LU_ITA_Forgot_Username' LIMIT 1];

        Messaging.SingleEmailMessage[] l_messages = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        et.Body = et.Body.replace('{!User.Username}', us.Username);
        et.HtmlValue = et.HtmlValue.replace('{!User.Username}', us.Username);

        message.setTargetObjectId(us.Id);
        message.setSubject(et.Subject);
        message.setPlainTextBody(et.Body);
        message.setHtmlBody(et.HtmlValue);
        message.setSaveAsActivity(false);

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};

        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
}