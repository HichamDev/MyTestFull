public without sharing class lwc41_Order_New_Ctrl {
    
    /* Retrieve the new order page depending of the version of the order tunnel used by the current user */
    @AuraEnabled
    public static String getOrderPageCurrentUser() {
        
        String pageOrder = 'new-order';

        // Get current user
        User u = [SELECT Id, TECH_ExternalId__c, LU_Use_New_Order_v2__c 
                    FROM User 
                    WHERE Id =: UserInfo.getUserId()];

        if (u != null) {
            if (u.LU_Use_New_Order_v2__c) {
                pageOrder = 'order-home';
            }
        }

        return (pageOrder);
    }

    @AuraEnabled
    public static Boolean getIsContentieux() {

        Contact con = AP1002_Utils_User.getConnectedUserContact();

        List<String> l_contentieux = new List<String>{'CONTENTIEUX', 'Contentieux', 'Bloqué', 'BLOQUE'};

        if(con.AccountCountryCode__c == 'FRA' && l_contentieux.contains(con.LocalAttribute4__c)){
            return true;
        }
        return false;
    }

}