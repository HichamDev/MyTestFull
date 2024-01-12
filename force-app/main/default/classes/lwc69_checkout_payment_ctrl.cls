public without sharing class lwc69_checkout_payment_ctrl {
	
    @AuraEnabled
    public static Order getOrderInfo(String orderId) {
        //SFT-1694, Added BillToContactId, CreatedById, CreatedBy.Name
        return [SELECT Id, BillToContactId, CreatedBy.ContactId, CreatedBy.Name, BillToContact.AllowedPaymentMode__c, BillToContact.AccountCountryCode__c FROM Order WHERE Id = :orderId];
    }
}