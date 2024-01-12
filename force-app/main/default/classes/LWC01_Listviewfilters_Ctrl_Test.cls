@IsTest
public class LWC01_Listviewfilters_Ctrl_Test {

    @IsTest
    static void testGetUserCountry() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        System.RunAs(u){
            LWC01_Listviewfilters_Ctrl.getUserCountry();
        }
    }

    @IsTest
    static void testGetContact() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        System.RunAs(u){
            LWC01_Listviewfilters_Ctrl.getCurrentContact();
        }
    }

    @IsTest
    static void testGetPicklistValues() {
        List<LWC01_Listviewfilters_Ctrl.Filters> l_segmentation = LWC01_Listviewfilters_Ctrl.getSegmentationPicklistValue();

        List<LWC01_Listviewfilters_Ctrl.Filters> l_typo = LWC01_Listviewfilters_Ctrl.getTypoPicklistValue();
        
        List<LWC01_Listviewfilters_Ctrl.Filters> l_newCoach = LWC01_Listviewfilters_Ctrl.getNewCoachPicklistValue();
    }

    @IsTest
    static void testGetFiltersInactiveFRA() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        System.RunAs(u){
            Map<String, List<LWC01_Listviewfilters_Ctrl.Filters>> mFilters = LWC01_Listviewfilters_Ctrl.getFilterInactiveSince();
        }
    }

    @IsTest
    static void testGetFiltersInactiveITA() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;

        System.RunAs(u){
            Map<String, List<LWC01_Listviewfilters_Ctrl.Filters>> mFilters = LWC01_Listviewfilters_Ctrl.getFilterInactiveSince();
        }
    }

    @IsTest
    static void testGetContactTypePicklistValue() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        // LU_Contact_Equipe_Filter__mdt meta = new LU_Contact_Equipe_Filter__mdt(
        //     MasterLabel = 'Leader',
        //     Contact_List__c = 'abc;def'
        // );
        // insert meta;

        System.RunAs(u){
            List<LWC01_Listviewfilters_Ctrl.Filters> l_previousCycles = LWC01_Listviewfilters_Ctrl.getContactTypePicklistValue();
        }
    }
    @IsTest
    static void testgetEffectifDormantValues() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        System.RunAs(u){
            List<LWC01_Listviewfilters_Ctrl.Filters> l_previousCycles = LWC01_Listviewfilters_Ctrl.getEffectifDormantValues();
        }
    }

    @IsTest
    static void testGetDealerManagerSegmentationOptions() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        System.RunAs(u){
            String serializedFilters = LWC01_Listviewfilters_Ctrl.getDealerManagerSegmentationOptions();
        }
    }
}