public with sharing class BA08_ValidateEshopOrders_Scheduler implements Schedulable{
    
    public void execute (SchedulableContext sc) {

        system.debug('## Start scheduler BA08_ValidateEshopOrders_Scheduler <<<<<');

        BA08_ValidateEshopOrders batch = new BA08_ValidateEshopOrders();
        Database.executebatch(batch, 100);

        system.debug('## End scheduler BA08_ValidateEshopOrders_Scheduler <<<<<');
    }
}