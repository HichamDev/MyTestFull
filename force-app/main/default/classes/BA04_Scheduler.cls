global with sharing class BA04_Scheduler implements Schedulable {
    global void execute (SchedulableContext sc)
    {       
        System.debug('## Start scheduler BA04Scheduler<<<<<');
        Commercial_Periods__mdt cycleMdt = AP49_ReadCustomMetadatas.getStartingTodayCommercialPeriod_mdt('Cycle', 1);
        if (cycleMdt != null || Test.isRunningTest()) {
            BA04_SendSMS_Anniversary batch = new BA04_SendSMS_Anniversary();
            database.executeBatch(batch, 1000);
        }
        System.debug('## End scheduler BA04_SendSMS_Anniversary <<<<<');
    }
}