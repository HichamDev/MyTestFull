@isTest
public with sharing class lwc92_forgot_username_ctrl_test {
    
    @IsTest
    public static void testSendUsernameEmail(){

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA';
        u.email = 'test@test.test';
        insert u;

        lwc92_forgot_username_ctrl.sendUsernameEmail(u.email);
    }
}