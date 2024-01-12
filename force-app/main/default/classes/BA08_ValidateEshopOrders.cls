global class BA08_ValidateEshopOrders implements Database.Batchable<sObject> {

    String orderId = null;

    global BA08_ValidateEshopOrders (){}

    global BA08_ValidateEshopOrders (String orderId){
        this.orderId = orderId;
    }

    global Database.querylocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID, Status, OwnerId, ';
        query += 'BillToContactId, Tech_External_Id__c, BillToContact.TECH_ExternalId__c '; 
        query += 'FROM Order WHERE Tech_External_Id__c LIKE \'ITA%\' AND Status = \'Draft\' ';
        query += 'AND Type = \'B2C\'';

        if(this.orderId != null){
            query += ' AND Id = \'' + this.orderId + '\'';
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Order> scope) {

        String sthItUsername = Label.LU_SthItUsername + '%';
        User u = [SELECT Id FROM User WHERE Username LIKE :sthItUsername LIMIT 1];

        Set<Id> s_contactsId = new Set<Id>();

        Set<Id> l_oldOwnerId = new Set<Id>();

        for(Order ord : scope){
            ord.LU_Local_Attribute_7__c = ord.BillToContact.TECH_ExternalId__c;
            ord.Status = 'Pending';
            l_oldOwnerId.add(ord.OwnerId);
            ord.OwnerId = u.Id;
            ord.BillToContactId = null;
        }

        update scope;

        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'LU_ITA_ORDER_AutoChangeOwner' LIMIT 1];

        Messaging.SingleEmailMessage[] l_messages = new List<Messaging.SingleEmailMessage>();

        for(Id oldOwner : l_oldOwnerId){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            message.setTargetObjectId(oldOwner);
            message.setTemplateId(et.Id);
            message.setSaveAsActivity(false);

            l_messages.add(message);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(l_messages);
    }

    global void finish(Database.BatchableContext BC){}
}