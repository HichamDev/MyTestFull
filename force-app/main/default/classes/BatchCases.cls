global class BatchCases implements Database.Batchable<sObject> {    

    String contactId = null;

    global BatchCases (){}

    // global BatchCases (String cId){
    //     this.contactId = cId; 
    // }

    global Database.querylocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID, ContactId, Status FROM Case WHERE Tech_is_Account_different__c = true';

        // if(this.contactId != null){
        //     query += ' AND ContactId = \'' + this.contactId + '\'';
        // }

        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext bc, List<Case> scope) {
        Map<Id, String> m_CasesToDesactivate = new Map<Id, String>();
        List<Id> contactsId = new List<Id>();
        Map<Id, Contact> contactsToModify = new Map<Id, Contact>();
        for(Case cas : scope){
            if(cas.ContactId != null)contactsId.add(cas.ContactId);
        }
        
        Map<Id, Contact> m_contactToChangeSharing = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN:contactsId]);
        for(Case cas : scope){
            if(cas.ContactId != null) cas.AccountId = m_contactToChangeSharing.get(cas.ContactId).AccountId;
        }
        update scope;
   
    }
    global void finish(Database.BatchableContext bc) {
    }
}