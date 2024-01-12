public without sharing class lwc79_order_detail_shipment_ctrl {
	
    @AuraEnabled
    public static Order getOrder(String idOrder) {
        
        return ( [SELECT Status, LU_Shipment_Ref__c, LU_Shipment_Follow_Up_URL__c, LU_Shipping_Date__c, LU_Transporter__c,
                    ShippingStreet, LU_Shipping_Street_2__c, LU_Shipping_Street_3__c, ShippingPostalCode, ShippingCity,
                    LU_Shipping_Comment__c, BillToContact.Name
                    FROM Order
                    WHERE Id = :idOrder] );
    }
}