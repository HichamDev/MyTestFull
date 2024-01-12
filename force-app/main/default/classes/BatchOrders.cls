global class BatchOrders implements Database.Batchable<sObject> { 

    String contactId = null;
    global BatchOrders (){}

    global BatchOrders (String cId){
        this.contactId = cId; 
    }

    global Database.querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT ID, BillToContactId, Status FROM Order WHERE Tech_is_Account_different__c = true');
    }
        
    global void execute(Database.BatchableContext bc, List<Order> scope) {
        Map<Id, String> m_OrdersToDesactivate = new Map<Id, String>();
        List<Id> contactsId = new List<Id>();
        Map<Id, Contact> contactsToModify = new Map<Id, Contact>();
        for(Order ord : scope){
            m_OrdersToDesactivate.put(ord.Id, ord.Status);
            contactsId.add(ord.BillToContactId);
            ord.Status = 'Draft';
            ord.LU_Tech_Update_For__c = 'BatchOrders';
        }
        update scope;
        
        Map<Id, Contact> m_contactToChangeSharing = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN:contactsId]);
        for(Order ord : scope){
            ord.AccountId = m_contactToChangeSharing.get(ord.BillToContactId).AccountId;
            ord.Status = m_OrdersToDesactivate.get(ord.Id);
            ord.LU_Tech_Update_For__c = '';
        }
        update scope;
   
    }
    global void finish(Database.BatchableContext bc) {
    }
}