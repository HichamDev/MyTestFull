public class lwc81_personal_contact_details_order_ctr {
	
    @AuraEnabled
    public static List<Order> getOrders(String idContact){

        List<Id> l_idOrder = new List<Id>();

        for(OrderItem oi : [SELECT OrderId FROM OrderItem WHERE LU_Contact_For__c = :idContact]){
            l_idOrder.add(oi.OrderId);
        }

        return [SELECT Name 
                      ,EffectiveDate 
                      ,toLabel(Status)
                      ,LU_Transporter__c
                      ,LU_Shipping_date__c
                      ,LU_Url_Detail_Community__c
                FROM Order
                WHERE Id IN :l_idOrder
                ORDER BY EffectiveDate DESC
                LIMIT 20000];
    }

    @AuraEnabled
    public static String getUserType(String idContact){
        return [SELECT RecordType.DeveloperName FROM Contact WHERE Id = :idContact].RecordType.DeveloperName;
    }
}