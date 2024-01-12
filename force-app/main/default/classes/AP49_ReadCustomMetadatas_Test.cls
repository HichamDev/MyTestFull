@isTest(SeeAllData=false)
public with sharing class AP49_ReadCustomMetadatas_Test {

    public TestMethod static void AP49_ReadCustomMetadatas_Test_Method(){
        AP49_ReadCustomMetadatas.getDelay('ManageCampaignMembers');
        AP49_ReadCustomMetadatas.getAllDealerSenioritiesAtBeginnningPeriod();
        AP49_ReadCustomMetadatas.isPeriodBeginning(1);
        AP49_ReadCustomMetadatas.get_m_dealerSeniority_commercialPeriodFieldsValues(true);
        AP49_ReadCustomMetadatas.getStartingTodayCommercialPeriod_mdt('Cycle', null);
        AP49_ReadCustomMetadatas.getStartingTodayCommercialPeriod_mdt('Cycle', 3);
        AP49_ReadCustomMetadatas.getStartingTodayCommercialPeriod_mdt('Cycle', 1);
        AP49_ReadCustomMetadatas.getCurrentBirthdayMdt();
    }
        
}