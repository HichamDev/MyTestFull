global class BatchContacts implements Database.Batchable<sObject> {    

    String contactId = null;

    global BatchContacts (){}

    // global BatchCases (String cId){
    //     this.contactId = cId; 
    // }

    global Database.querylocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, Tech_Pardot_Send_SMS__c FROM Contact WHERE Tech_Pardot_Send_SMS__c = true';

        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        for(Contact con : scope){
           con.Tech_Pardot_Send_SMS__c = false;
        }
        update scope;
   
    }
    global void finish(Database.BatchableContext BC) {
    }
}