@IsTest
public class AP53_QuickContractCallout_test {
    
    @IsTest
    public static void pushFilesForSignature(){

        STHEndpoints__c setting = new STHEndpoints__c();
        setting.Name = 'FRA';
        setting.QuickContract_Endpoint__c = 'www.testtesttest.com';
        setting.QuickContract_Token__c = 'test';
        insert setting;
        
        Integer statusCode = 201;
        String message = 'response';
        Test.setMock(HttpCalloutMock.class, new AP52_SingleRequestMock(statusCode, 'Success', message, null ));
        
        Test.startTest();
            Lead l = new Lead(
                LastName = 'last',
                Company = 'company',
                Email = 'test@test.com',
                FirstName = 'first',
                SubscribeMode__c = 'Online'
            );
            insert l;
        Test.stopTest();

        l = [SELECT QuickContract_StatusCode__c, QuickContract_Message__c FROM LEad WHERE Id = :l.Id];

        System.AssertEquals(String.valueOf(201), l.QuickContract_StatusCode__c);
        System.AssertEquals(message, l.QuickContract_Message__c);
    }
}