global class AP43_BatchClearStockUsed implements Database.Batchable<sobject>{
	
    private String country = null;

    global AP43_BatchClearStockUsed(String countryParam){
        country = countryParam + '%';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){

        String query = 'SELECT Id FROM LU_Stock_Used__c WHERE LU_Product__r.LU_Tech_External_Id__c LIKE :country';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){}
}