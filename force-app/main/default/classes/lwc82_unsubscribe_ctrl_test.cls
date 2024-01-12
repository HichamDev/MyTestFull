/******************************************************************************
*   @author Simon Gourreau
*   @date 31/07/2020
*   @description lwc82_unsubscribe_ctrl test class
*
*/
@IsTest
public with sharing class lwc82_unsubscribe_ctrl_test {
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
    public static void unsubscribeContact(){
        Contact vConBef = [Select Id, LU_ConsentUnsubscribeDate__c, HasOptedOutOfEmail
                            From Contact 
                            Where Name = :CONTACT_NAME];
        Test.startTest();
        lwc82_unsubscribe_ctrl.unsubscribeContact(CONTACT_EMAIL, vConBef.Id);
        Test.stopTest();
        Contact vConAft = [Select Id, LU_ConsentUnsubscribeDate__c, HasOptedOutOfEmail
                            From Contact 
                            Where Name = :CONTACT_NAME];

        System.assert(vConAft.HasOptedOutOfEmail);
        System.assert(vConAft.LU_ConsentUnsubscribeDate__c <= Datetime.now());
    }
}