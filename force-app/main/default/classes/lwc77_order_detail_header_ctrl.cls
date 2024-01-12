public without sharing class lwc77_order_detail_header_ctrl {
    
    @AuraEnabled
    public static Order getOrder(String idOrder){
        
        return [SELECT Name, toLabel(Status), EffectiveDate, BillToContactId, BillToContact.FirstName, BillToContact.LastName, Type, LU_Online_Customer__r.Name, LU_TECH_Order_Date__c  
                FROM Order
                WHERE Id = :idOrder];
    }
}