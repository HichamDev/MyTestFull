global class BA05_OrderOwnerManagement implements Database.Batchable<sObject> {   

    String contactId = null;

    global BA05_OrderOwnerManagement (){}

    global BA05_OrderOwnerManagement (String cId){
        this.contactId = cId; 
    }

    global Database.querylocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID, BillToContactId FROM Order WHERE Tech_is_OWNER_different__c = true';

        if(this.contactId != null){
            query += ' AND BillToContactId = \'' + this.contactId + '\'';
        }

        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext bc, List<Order> scope) {

        Set<Id> s_contactsId = new Set<Id>();

        for(Order ord : scope){
            s_contactsId.add(ord.BillToContactId);
        }
        
        Map<Id, Contact> m_contacts = new Map<Id, Contact>([SELECT Id, Account.OwnerId, Account.Owner.IsActive FROM Contact WHERE Id IN :s_contactsId]);
        for(Order ord : scope){
            if(ord.BillToContactId != null && m_contacts.get(ord.BillToContactId).Account != null && m_contacts.get(ord.BillToContactId).Account.Owner.IsActive){
                ord.OwnerId = m_contacts.get(ord.BillToContactId).Account.OwnerId;
            }
        }
        update scope;
   
    }
    global void finish(Database.BatchableContext bc) {
        // Lancement de l'autre Batch Order
        BatchOrders batch = new BatchOrders();
        database.executeBatch(batch, 500);
    }
}