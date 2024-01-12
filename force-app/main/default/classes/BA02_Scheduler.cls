public with sharing class BA02_Scheduler implements Schedulable{
    public void execute (SchedulableContext sc)
    {       
        system.debug('## Start scheduler BA02_Scheduler<<<<<');
        AP49_ReadCustomMetadatas rcmd = new AP49_ReadCustomMetadatas('Cycle');
        List<DealerSeniority__mdt> lDSMD = new List<DealerSeniority__mdt> ();
        if(!Test.isRunningTest()){
            lDSMD = AP49_ReadCustomMetadatas.getAllDealerSenioritiesAtBeginnningPeriod();
        }
        else{
            lDSMD= [SELECT Id, SegmentName__c FROM DealerSeniority__mdt];
        }

        // vérifier qu'on est bien à J+3 du début du cycle
        Commercial_Periods__mdt cycleMdt = AP49_ReadCustomMetadatas.getStartingTodayCommercialPeriod_mdt('Cycle', 3);
        if (cycleMdt != null || Test.isRunningTest()) {
            for(DealerSeniority__mdt dsmd : lDSMD){
                BA02_SendSMS_ToSinch batch = new BA02_SendSMS_ToSinch(new List<String>{dsmd.SegmentName__c});
                database.executebatch(batch, 1000);
            }
        }
        system.debug('## End scheduler BA02_Scheduler <<<<<');
    }
}