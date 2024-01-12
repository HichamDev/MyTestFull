@isTest
private class lwc82_gdpr_resend_consent_ctrl_TEST {
    
    private final static String CONTACT_NAME = 'Test con';
    private final static String CONTACT_EMAIL = 'email@test.com';
    
    @testSetup 
    static void dataCreation() {
        Id rtId = [SELECT Id 
                    FROM RecordType 
                    WHERE DeveloperName = :AppConstants.RT_CON_PERSONALCONTACT 
                    AND Sobjecttype = 'Contact' LIMIT 1].Id;
        Contact vCon = AP01_TestDataFactory.getContact(CONTACT_NAME, rtId);
        vCon.Email= CONTACT_EMAIL;
        Database.insert(vCon);
    }

    @isTest
    public static void unit_1_resend(){
        Contact vCon = [Select Id, LU_Consent_Resend_Email_Date__c
                        From Contact 
                        Where Name = :CONTACT_NAME];

        Test.startTest();
        lwc82_gdpr_resend_consent_ctrl.resendConsentEmail(vCon.Id);
        Test.stopTest();
        
        vCon = [Select Id, LU_Consent_Resend_Email_Date__c
                    From Contact 
                    Where Name = :CONTACT_NAME];

        System.assert(vCon.LU_Consent_Resend_Email_Date__c <= Datetime.now());
    }

}