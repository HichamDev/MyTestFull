@isTest
public with sharing class lwc02_Timeline_Ctrl_TEST {
   
   @isTest static void unittest_getTimelineInformation_FRA() {

        String userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Conseillière', 'Dealer', 'FRA_LU_DEALER_MEMBER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            AP1001_Cycle_Utils.CycleInfo info = lwc02_Timeline_Ctrl.getTimelineInformation(userId);
            system.assert(info != null, 'ASSERT ERROR : Cycle Info is null');
        }
    }

    @isTest static void unittest_getTimelineInformation_ITA() {

        String userId = AP01_TestDataFactory.createCommunityManagerWithTeam('ITA', 'Sales Consultant', 'Dealer', 'ITA_LU_DEALER_MEMBER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            AP1001_Cycle_Utils.CycleInfo info  = lwc02_Timeline_Ctrl.getTimelineInformation(userId);
            system.assert(info != null, 'ASSERT ERROR : Cycle info is null');
        }
    }

}