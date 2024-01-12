global with sharing class AP41_SchFra_BatchAllLogin implements Schedulable {

    global void execute (SchedulableContext sc){       
        system.debug('## Start scheduler AP41_SchFra_BatchAllLogin<<<<<');
        AP41_BatchAllLogin batch = new AP41_BatchAllLogin('FRA');
        database.executebatch(batch);
        system.debug('## End scheduler AP41_SchFra_BatchAllLogin <<<<<');
    }
}