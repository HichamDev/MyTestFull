@isTest
public with sharing class lwc05_home_shortcuts_Ctrl_TEST {
    
    @isTest static void unittest_wrapperClassItem() {

        lwc05_home_shortcuts_Ctrl.Item it = new lwc05_home_shortcuts_Ctrl.Item();
        it.label = 'label';
        it.link = 'www.google.fr';
        it.icon = 'www.img.fr/img.png';

        system.assert(it != null, 'ASSERT ERROR : Wrapper variable is null');
        
    }

    @isTest static void unittest_getShortcuts_FRA() {

        Test.setMock(WebServiceMock.class, new MOCK_SthMainApiSoap_Test());
        String userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Conseillière', 'Dealer', 'FRA_LU_DEALER_MEMBER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];

        STHEndpoints__c setting = new STHEndpoints__c();
        setting.Name = 'FRA';
        setting.Card_Payment_Coef__c = 1.001;
        setting.Google_Endpoint__c = 'Whatever';
        insert setting;

        System.runAs(u) {

            Test.startTest();
            List<lwc05_home_shortcuts_Ctrl.Item> lLinks = lwc05_home_shortcuts_Ctrl.getShortcuts();
            Test.stopTest();
            system.assert(lLinks != null, 'ASSERT ERROR : No links retrieved for the Leader user');
        }

    }

    @isTest static void unittest_getShortcuts_ITA() {

        Test.setMock(WebServiceMock.class, new MOCK_SthMainApiSoap_Test());

        String userId = AP01_TestDataFactory.createCommunityManagerWithTeam('ITA', 'Sales Consultant', 'Dealer', 'ITA_LU_DEALER_MEMBER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];

        STHEndpoints__c setting = new STHEndpoints__c();
        setting.Name = 'ITA';
        setting.Card_Payment_Coef__c = 1.001;
        setting.Google_Endpoint__c = 'Whatever';
        insert setting;

        System.runAs(u) {

            Test.startTest();
            List<lwc05_home_shortcuts_Ctrl.Item> lLinks = lwc05_home_shortcuts_Ctrl.getShortcuts();
            Test.stopTest();
            system.assert(lLinks != null, 'ASSERT ERROR : No links retrieved for the Leader user');
        }
    }

}