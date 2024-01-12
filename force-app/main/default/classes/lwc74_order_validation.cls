public class lwc74_order_validation {
    
    @AuraEnabled
    public static Order getOrderById(Id orderId) {
        Order ord = [SELECT Id, LU_Country_Code__c, (SELECT Id, LU_Stock_Message__c, LU_Child_Product__c, Product2.LU_Local_code__c, Product2.Name, Product2.LU_Bundle_Type__c FROM OrderItems)
                        FROM Order
                        WHERE Id =: orderId];
        return (ord);
    }

}