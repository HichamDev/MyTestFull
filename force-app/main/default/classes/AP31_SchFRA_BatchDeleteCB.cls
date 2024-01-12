global with sharing class AP31_SchFRA_BatchDeleteCB implements Schedulable {

    global void execute (SchedulableContext sc)
    {       
        system.debug('## Start scheduler AP31_SchFRA_BatchDeleteCB<<<<<');
        AP31_BatchDeleteCB batch = new AP31_BatchDeleteCB('FRA');
        database.executebatch(batch, 50);
        system.debug('## End scheduler AP31_SchFRA_BatchDeleteCB <<<<<');
    }

}