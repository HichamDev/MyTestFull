global with sharing class BatchCases_Scheduler implements Schedulable {
    global void execute (SchedulableContext sc)
    {       
        System.debug('## Start scheduler BA05Scheduler<<<<<');
            BatchCases batch = new BatchCases();
            database.executeBatch(batch, 500);

            //Attention lance les autres Batch Case & Order à la fin du BA05

        System.debug('## End scheduler BatchCases <<<<<');
    }
}