@IsTest
public class AP1001_Cycle_Utils_Test {

    @IsTest
    static void testGetFiltersInactiveITA() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;

        List<Commercial_Periods__mdt> l_commPer = AP1001_Cycle_Utils.getUserPreviousCycles(u.Id);

        AP1001_Cycle_Utils.CycleInfo ci = AP1001_Cycle_Utils.getCurrentCycleByUser(u.Id);
        
        AP1001_Cycle_Utils.CycleInfo ciWeek = AP1001_Cycle_Utils.getCountryCurrentCycleWeek('ITA');
    }
}