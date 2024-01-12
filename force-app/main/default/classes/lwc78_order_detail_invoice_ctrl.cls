public without sharing class lwc78_order_detail_invoice_ctrl {
	
    @AuraEnabled
    public static Order getOrder(String idOrder){
        
        return [SELECT Status, toLabel(LU_Invoice_Status__c), LU_Invoice_Date__c, LU_Invoice_Number__c, LU_Invoice_URL1__c
                  FROM Order
                 WHERE Id = :idOrder];
    }
}