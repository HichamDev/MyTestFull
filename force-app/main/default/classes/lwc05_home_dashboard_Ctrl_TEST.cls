@isTest
public with sharing class lwc05_home_dashboard_Ctrl_TEST {
    
    @isTest static void unittest_wrapperClass() {

        lwc05_home_dashboard_Ctrl.Indicator wr = new lwc05_home_dashboard_Ctrl.Indicator();
        wr.isText = true;
        wr.isNumber = true;
        wr.isDonught = true;
        wr.label = 'test label';
        wr.isCurrencyDecimal1 = true;
        wr.isPercentDecimal1 = true;
        wr.isNbDecimal1 = true;
        wr.vDecimal1 = 10;
        wr.vDecimal1Txt = 'Decimal 1 text';
        wr.isCurrencyDecimal2 = true;
        wr.vDecimal2 = 12;
        wr.vDecimal2Txt = 'Decimal 2 text';
        wr.isCurrencyDecimal3 = true;
        wr.vDecimal3 = 8;
        wr.vDecimal3Txt = 'Decimal 3 text';
        wr.isCurrencyDecimal4 = true;
        wr.vDecimal4 = 3;
        wr.vDecimal4Txt = 'Decimal 4 text';
        wr.vString1 = 'String 1';
        wr.vString2 = 'String 2';
        
        system.assert(wr != null, 'ASSERT ERROR : Wrapper variable is null');

    }
    
    @isTest static void unittest_getCurrentContact() {

        String userId = AP01_TestDataFactory.createPortalUserWithClients();
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            Contact con = lwc05_home_dashboard_Ctrl.getCurrentContact();
            system.assert(con != null, 'ASSERT ERROR : Current Contact is null');
        }
    }


    /* FRANCE */

    @isTest static void unittest_getCurrentContactIndicators_FRA_Dealer() {

        String userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Conseillière', 'Dealer', 'FRA_LU_DEALER_MEMBER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            List<lwc05_home_dashboard_Ctrl.Indicator> lIndicators = lwc05_home_dashboard_Ctrl.getCurrentContactIndicators();
            system.assert(lIndicators != null, 'ASSERT ERROR : No KPI retrieved for the Leader user');
        }
    }


    @isTest static void unittest_getCurrentContactIndicators_FRA_Leader() {

        String userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Conseillière', 'Leader', 'FRA_LU_DEALER_MEMBER', 'Leader 2');
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            List<lwc05_home_dashboard_Ctrl.Indicator> lIndicators = lwc05_home_dashboard_Ctrl.getCurrentContactIndicators();
            system.assert(lIndicators != null, 'ASSERT ERROR : No KPI retrieved for the Leader user');
        }
    }

    @isTest static void unittest_getCurrentContactIndicators_FRA_DivisionManager() {

        String userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Directrice de division', 'Leader', 'FRA_LU_DEALER_MEMBER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            List<lwc05_home_dashboard_Ctrl.Indicator> lIndicators = lwc05_home_dashboard_Ctrl.getCurrentContactIndicators();
            system.assert(lIndicators != null, 'ASSERT ERROR : No KPI retrieved for the Leader user');
        }
    }


    /* ITALY */
    @isTest static void unittest_getCurrentContactIndicators_ITA_Dealer() {

        String userId = AP01_TestDataFactory.createCommunityManagerWithTeam('ITA', 'SALES CONSULTANT', 'Dealer', 'ITA_LU_DEALER_MEMBER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            List<lwc05_home_dashboard_Ctrl.Indicator> lIndicators = lwc05_home_dashboard_Ctrl.getCurrentContactIndicators();
            system.assert(lIndicators != null, 'ASSERT ERROR : No KPI retrieved for the Leader user');
        }
    }

    @isTest static void unittest_getCurrentContactIndicators_ITA_Dealer_Manager() {

        String userId = AP01_TestDataFactory.createCommunityManagerWithTeam('ITA', 'Group Sales Consultant', 'Leader', 'ITA_LU_DEALER_MEMBER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            List<lwc05_home_dashboard_Ctrl.Indicator> lIndicators = lwc05_home_dashboard_Ctrl.getCurrentContactIndicators();
            system.assert(lIndicators != null, 'ASSERT ERROR : No KPI retrieved for the Leader user');
        }
    }

    @isTest static void unittest_getCurrentContactIndicators_ITA_Dealer_NewOrderTunnel() {

        String userId = AP01_TestDataFactory.createCommunityManagerWithTeamNewOrderTunnel('ITA', 'SALES CONSULTANT', 'Dealer', 'ITA_LU_DEALER_MEMBER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            List<lwc05_home_dashboard_Ctrl.Indicator> lIndicators = lwc05_home_dashboard_Ctrl.getCurrentContactIndicators();
            system.assert(lIndicators != null, 'ASSERT ERROR : No KPI retrieved for the Leader user');
        }
    }

    @isTest static void unittest_getCurrentContactIndicators_ITA_Dealer_Manager_NewOrderTunnel() {

        String userId = AP01_TestDataFactory.createCommunityManagerWithTeamNewOrderTunnel('ITA', 'Group Sales Consultant', 'Leader', 'ITA_LU_DEALER_MEMBER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            List<lwc05_home_dashboard_Ctrl.Indicator> lIndicators = lwc05_home_dashboard_Ctrl.getCurrentContactIndicators();
            system.assert(lIndicators != null, 'ASSERT ERROR : No KPI retrieved for the Leader user');
        }
    }
}