@IsTest
public class AP1005_ApplicationAccess_Test {

    @IsTest
    static void testGetFiltersInactiveITA() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;

        Contact con = [SELECT Id, TECH_ApplicationDateSent__c, AccountCountryCode__c FROM Contact WHERE Id = :u.ContactId];

        STHEndpoints__c setting = new STHEndpoints__c();
        setting.Name = 'FRA';
        setting.Card_Payment_Coef__c = 1.001;
        setting.Google_Endpoint__c = 'Whatever';
        insert setting;

        Test.setMock(WebServiceMock.class, new MOCK_SthMainApiSoap_Test());

        System.RunAs(u){

            Test.startTest();
            List<AP19_ApplicationResponse> l = AP1005_ApplicationAccess.getSSOLinksForContact(con);
            Test.stopTest();

            // Boolean b = AP1005_ApplicationAccess.checkValidity(con);

            // l = AP1005_ApplicationAccess.handleWSSSO(con);

            // apiStanhomeComSso.ApplicationReturn a = AP1005_ApplicationAccess.getWebServiceResponse(new AP19_ApplicationRequest('FRA', '', 1, ''));

            
        }
    }
}