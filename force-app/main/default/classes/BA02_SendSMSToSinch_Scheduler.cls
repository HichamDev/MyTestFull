global with sharing class BA02_SendSMSToSinch_Scheduler implements Schedulable{
   global void execute (SchedulableContext sc)
   {       
      system.debug('## Start scheduler BA02_SendSMSToSinch_Scheduler <<<<<');

      // vérifier qu'on est bien à J+3 du début du cycle
      Commercial_Periods__mdt cycleMdt = AP49_ReadCustomMetadatas.getStartingTodayCommercialPeriod_mdt('Cycle', 3);
      if (cycleMdt != null || Test.isRunningTest()) {

         //Edit JJE 14/04 : pas en fonction de la commercial period
         // for(DealerSeniority__mdt dsmd : AP49_ReadCustomMetadatas.getAllDealerSenioritiesAtBeginnningPeriod()){
         for(DealerSeniority__mdt dsmd : AP49_ReadCustomMetadatas.getDealerSeniorities_mdt()){
            System.debug('dsmd ' + dsmd);
            BA02_SendSMS_ToSinch batch = new BA02_SendSMS_ToSinch(new List<String>{dsmd.SegmentName__c});
            database.executebatch(batch, 100);
            system.debug('## End scheduler BA02_SendSMSToSinch_Scheduler <<<<<');
         }
      }
   }
}