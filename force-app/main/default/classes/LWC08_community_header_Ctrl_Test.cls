@IsTest
public class LWC08_community_header_Ctrl_Test {

    @IsTest
    static void getMenuItemsTest_FRA() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        Profile p = [select Id,name from Profile where Name = 'FRA_LU_DEALER_MANAGER' limit 1];
        u.profileId = p.Id;
        insert u;
        
        STHEndpoints__c setting = new STHEndpoints__c();
        setting.Name = 'FRA';
        setting.Card_Payment_Coef__c = 1.001;
        setting.Google_Endpoint__c = 'Whatever';
        insert setting;
        
        String idAcc = [SELECT AccountId FROM User WHERE Id = :u.Id].AccountId;
        
        Account acc = [SELECT Country_Code__c FROM Account WHERE Id = :idAcc];
		
        Test.setMock(WebServiceMock.class, new MOCK_SthMainApiSoap_Test());
        
        System.RunAs(u){
            Test.startTest();
            LWC08_community_header_Ctrl.MenuItem menuItem = LWC08_community_header_Ctrl.getMenuItems('Mobile');
            Test.stopTest();
            
            System.assert(menuItem.lMenuItems.size() > 0);
        }
        
    }
    
    @IsTest
    static void getMenuItemsTest_ITA() {
        
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;
        
        STHEndpoints__c setting = new STHEndpoints__c();
        setting.Name = 'ITA';
        setting.Card_Payment_Coef__c = 1.001;
        setting.Google_Endpoint__c = 'Whatever';
        insert setting;
        
        String idAcc = [SELECT AccountId FROM User WHERE Id = :u.Id].AccountId;
        
        Account acc = [SELECT Country_Code__c FROM Account WHERE Id = :idAcc];
		acc.Country_Code__c = 'ITA';
        update acc;
        
        Test.setMock(WebServiceMock.class, new MOCK_SthMainApiSoap_Test());
        
        System.RunAs(u){
            Test.startTest();
            LWC08_community_header_Ctrl.MenuItem menuItem = LWC08_community_header_Ctrl.getMenuItems('Desktop');
            Test.stopTest();
            System.assert(menuItem.lBurgerItems.size() > 0);
        }

    }

}