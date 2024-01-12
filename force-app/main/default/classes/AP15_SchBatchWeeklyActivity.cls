global with sharing class AP15_SchBatchWeeklyActivity implements Schedulable{
    global void execute (SchedulableContext sc)
     {       
        System.debug('## execute of Class AP15_BatchWeeklyActivity implements Schedulable - Start');
        AP15_BatchWeeklyActivity batch = new AP15_BatchWeeklyActivity();
        database.executebatch(batch);
        
     }
}