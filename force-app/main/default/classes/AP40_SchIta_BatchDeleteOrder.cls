global with sharing class AP40_SchIta_BatchDeleteOrder implements Schedulable{
    global void execute (SchedulableContext sc)
     {       
        system.debug('## Start scheduler AP34_Sch_BatchTransferPCT<<<<<');
        AP40_BatchDeleteOrder batch = new AP40_BatchDeleteOrder('ITA');
        database.executebatch(batch);
        system.debug('## End scheduler AP34_Sch_BatchTransferPCT <<<<<');
     }
}