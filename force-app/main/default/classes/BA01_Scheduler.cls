global with sharing class BA01_Scheduler implements Schedulable{
    global void execute (SchedulableContext sc)
     {       
        system.debug('## Start scheduler BA01_Scheduler<<<<<');
        BA01_CleanCampaignMembers batch = new BA01_CleanCampaignMembers();
        database.executebatch(batch, 1000);
        system.debug('## End scheduler BA01_Scheduler <<<<<');
     }
}