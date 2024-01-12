public with sharing class lwc82_gdpr_resend_consent_ctrl {
    
    @AuraEnabled
    public static String resendConsentEmail(String contactId) {

        String ret = 'ko';
        if (contactId != null && contactId != '') {
            Contact c = new Contact(Id = contactId, LU_Consent_Resend_Email_Date__c = System.now());
            update c;
            ret = 'ok';
        }

        return (ret);
    }
}