global with sharing class BA03_Scheduler implements Schedulable{
    global void execute (SchedulableContext sc)
     {       
        system.debug('## Start scheduler BA03Scheduler<<<<<');
        BA03_SendSMS_Birthday batch = new BA03_SendSMS_Birthday();
        database.executebatch(batch, 1000);
        system.debug('## End scheduler BA03_SendSMS_Birthday <<<<<');
     }
}