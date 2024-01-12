global with sharing class AP1020_SC_BatchAccountSharing_FRA implements Schedulable {
    
    global void execute (SchedulableContext sc) {       
       system.debug('## Start scheduler AP1020_SC_BatchAccountSharing_FRA<<<<<');
       AP1020_BatchAccountSharing_Step1 batch = new AP1020_BatchAccountSharing_Step1('FRA');
       database.executebatch(batch);
       system.debug('## End scheduler AP1020_SC_BatchAccountSharing_FRA <<<<<');
    }

}