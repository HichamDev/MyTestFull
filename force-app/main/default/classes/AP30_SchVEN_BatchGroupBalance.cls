global with sharing class AP30_SchVEN_BatchGroupBalance implements Schedulable{

     global void execute (SchedulableContext sc)
     {       
        System.debug('## execute of Class AP30_SchBatchGroupBalance implements Schedulable - Start');
        AP30_BatchGroupBalance batch = new AP30_BatchGroupBalance('VEN');
        database.executebatch(batch, 40000);
     }

}