/******************************************************************************
*   @author Philippe Cazabonne
*   @date 06/05/2021
*   @description AP50_Btn_Test_Sinch_Templates test class
*
*/
@isTest
public with sharing class AP50_Btn_Test_Sinch_Templates_Test {

    @testSetup 
    static void dataCreation() {
        Contact contactTest = new Contact(MobilePhone='0600000000', DealerSenioritySegment__c = 'Argento', FirstName = 'TEST_TEMPLATE_SINCH', LastName = 'TEST_TEMPLATE_SINCH');
        insert contactTest;
    }

    @isTest
    public static void setIdsWithExternalIdInfo() {

        Test.startTest();
        AP50_Btn_Test_Sinch_Templates.sendTests();
        Test.stopTest();

    }
}