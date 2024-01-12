public without sharing class LWC27_Checkout_Payment_Ctrl {
    
    @AuraEnabled
    public static Order initPayment(String orderId) {
        
        Order ord = null;
        try {

            // Get the order
            ord = [SELECT Id, BillToContactId, TotalAmount, LU_Payment_Transaction_Id__c
                    FROM Order
                    WHERE Id =: orderId];

            STHEndpoints__c serviceConfig = [SELECT Id, Card_Payment_Endpoint__c, Card_Payment_Merchant_Id__c, Card_Payment_API_Key__c, Card_Payment_Shop_Id__c, Card_Payment_Coef__c,
							                    Card_Payment_Max_Amount_Allowed__c 
	                       	                    FROM STHEndpoints__c
	                                             WHERE Name = 'FRA' ];

        } catch (Exception e) {
            system.debug('>>> exception: ' + e.getMessage());
        }    

        return (ord);

    }

}