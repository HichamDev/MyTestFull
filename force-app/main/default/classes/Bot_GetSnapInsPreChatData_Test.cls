@isTest
public with sharing class Bot_GetSnapInsPreChatData_Test {
    @istest
    public static void getSnapInsPrechatData_Test() {
        List<Bot_GetSnapInsPreChatData.PrechatInput> inputParameters = new List<Bot_GetSnapInsPreChatData.PrechatInput>();
        Bot_GetSnapInsPreChatData.PrechatInput input = new Bot_GetSnapInsPreChatData.PrechatInput();
        input.sChatKey = '1234';
        inputParameters.add(input);

        LiveChatVisitor lv = new LiveChatVisitor();
        insert lv;
        LiveChatTranscript lt = new LiveChatTranscript();
        lt.ChatKey = '1234';
        lt.LiveChatVisitorId = lv.Id;
        lt.UserName__c = 'test@test.Fr';
        insert lt;

        Test.startTest();
        Bot_GetSnapInsPreChatData.getSnapInsPrechatData(inputParameters);
        Bot_PreChatCmpCnt.getCurrentUser();
        EmailMessage em = new EmailMessage();
        em.Subject = ' New case email notification ';
        insert em;
        Test.stopTest();
    }

    @istest
    public static void getSnapInsPrechatData_TestAsUser() {
        List<Bot_GetSnapInsPreChatData.PrechatInput> inputParameters = new List<Bot_GetSnapInsPreChatData.PrechatInput>();
        Bot_GetSnapInsPreChatData.PrechatInput input = new Bot_GetSnapInsPreChatData.PrechatInput();
        input.sChatKey = '1234';
        inputParameters.add(input);

        LiveChatVisitor lv = new LiveChatVisitor();
        insert lv;
        LiveChatTranscript lt = new LiveChatTranscript();
        lt.ChatKey = '1234';
        lt.LiveChatVisitorId = lv.Id;
        lt.UserName__c = 'newPortalUser@yahoo.com';
        insert lt;

        User u = AP01_TestDataFactory.createPortalUser();
        insert u;

        System.runAs(u){
            Test.startTest();
            Bot_GetSnapInsPreChatData.getSnapInsPrechatData(inputParameters);
            Test.stopTest();
        }
    }
}