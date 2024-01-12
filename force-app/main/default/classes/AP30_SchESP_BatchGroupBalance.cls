global with sharing class AP30_SchESP_BatchGroupBalance implements Schedulable{

     global void execute (SchedulableContext sc)
     {       
        System.debug('## execute of Class AP30_SchBatchGroupBalance implements Schedulable - Start');
        AP30_BatchGroupBalance batch = new AP30_BatchGroupBalance('ESP');
        database.executebatch(batch, 40000);
     }
}