global with sharing class AP43_SchFra_BatchClearStockUsed implements Schedulable{
    
    global void execute (SchedulableContext sc){       
        system.debug('## Start scheduler AP43_SchFra_BatchClearStockUsed<<<<<');
        AP43_BatchClearStockUsed batch = new AP43_BatchClearStockUsed('FRA');
        database.executebatch(batch);
        system.debug('## End scheduler AP43_SchFra_BatchClearStockUsed <<<<<');
    }
}