global with sharing class AP1020_SC_BatchAccountSharing_ITA implements Schedulable {
    
    global void execute (SchedulableContext sc) {       
        system.debug('## Start scheduler AP1020_SC_BatchAccountSharing_ITA <<<<<');
        AP1020_BatchAccountSharing_Step1 batch = new AP1020_BatchAccountSharing_Step1('ITA');
        database.executebatch(batch);
        system.debug('## End scheduler AP1020_SC_BatchAccountSharing_ITA <<<<<');
     }

}