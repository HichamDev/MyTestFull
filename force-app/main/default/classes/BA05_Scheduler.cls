global with sharing class BA05_Scheduler implements Schedulable {
    global void execute (SchedulableContext sc)
    {       
        System.debug('## Start scheduler BA05Scheduler<<<<<');
            BA05_OrderOwnerManagement batch = new BA05_OrderOwnerManagement();
            database.executeBatch(batch, 500);

            //Attention lance les autres Batch Case & Order à la fin du BA05

        System.debug('## End scheduler BA05_OrderOwnerManagement <<<<<');
    }
}