global class AP32_BatchCleanData implements Database.Batchable<sObject>, Schedulable {
    
/* ATTRIBUTES */
    global final String query;

/* CONSTRUCTOR */
    public AP32_BatchCleanData() {

        query = Label.Clean_Query + ' LIMIT ' + Label.Clean_Limit;
        system.debug('>>> Query : ' + query);
        
    }

/* SCHEDULE METHODS */
    public void execute(SchedulableContext ctx) 
    {
        AP32_BatchCleanData b = new AP32_BatchCleanData();
        database.executebatch(b, Integer.valueOf(Label.Clean_BulkSize));
    }
    
    
/* BATCH METHODS */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ORD_Order__c> scope) {
        
        system.debug('>> Items to delete : ' + scope.size());
        delete scope;
        
    }

    global void finish(Database.BatchableContext BC) { }
}