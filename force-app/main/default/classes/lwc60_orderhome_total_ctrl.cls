public without sharing class lwc60_orderhome_total_ctrl {
	
    @AuraEnabled
    public static List<PriceBookEntry> getProducts(List<String> l_idPbe) {

        System.debug(l_idPbe);
        
        return [SELECT Id, UnitPrice, LU_Public_Price__c, 
                    LU_Valid_For_Total_Amount_Base__c, 
                    Product2.LU_Brand__c, Product2.LU_Brand_Territory__c,
                    Product2.LU_Type__c, Discount_Type__c, LU_Dealer_Price__c, LU_Offer_type__c
                    FROM PricebookEntry 
                    WHERE Id IN :l_idPbe];
    }
    
    @AuraEnabled
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    @AuraEnabled
    public static Contact getCurrentContact() {
        return AP1002_Utils_User.getConnectedUserContact();
    }

}