global with sharing class AP31_SchITA_BatchDeleteCB implements Schedulable {

    global void execute (SchedulableContext sc)
    {       
        system.debug('## Start scheduler AP31_SchITA_BatchDeleteCB<<<<<');
        AP31_BatchDeleteCB batch = new AP31_BatchDeleteCB('ITA');
        database.executebatch(batch, 50);
        system.debug('## End scheduler AP31_SchITA_BatchDeleteCB <<<<<');
    }

}