public without sharing class lwc72_gdpr_consent_ctrl {
	
    @AuraEnabled
    public static void updateContact(String idContact, Boolean optOut){

        System.debug(idContact);
        System.debug(optOut);
        
        if(!String.IsBlank(idContact) && optOut != null){
            update new Contact(id = idContact, LU_Consent_Answer_Date__c = System.Now(), HasOptedOutOfEmail = optOut);
        }
    }
}