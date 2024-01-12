@IsTest
public class AP55_ContactHandler_Test {
    
    @IsTest
    public static void createLeadFromContact(){

        STHEndpoints__c setting = new STHEndpoints__c();
        setting.Name = 'FRA';
        setting.QuickContract_Endpoint__c = 'www.testtesttest.com';
        setting.QuickContract_Token__c = 'test';
        insert setting;
        
        Integer statusCode = 201;
        String message = 'response';
        Test.setMock(HttpCalloutMock.class, new AP52_SingleRequestMock(statusCode, 'Success', message, null ));

        User user = [SELECT id FROM User WHERE Profile.Name LIKE '%Admin%' AND isActive = true LIMIT 1];
        
        Contact c = new Contact(
            FirstName = 'test',
            LastName = 'test',
            OwnerId = user.Id
        );
        insert c;

        List<Contact> l_con = new List<Contact>{c};

        Test.startTest();
        AP55_ContactHandler.createLeadFromContact(l_con);
        Test.stopTest();
    }
}