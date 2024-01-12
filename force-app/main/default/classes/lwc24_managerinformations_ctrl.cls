public without sharing class lwc24_managerinformations_ctrl {
	
    @AuraEnabled(cacheable=true)
    public static Contact getManager() {

        String userCountry = lwc24_managerinformations_ctrl.getUserCountry();

        Contact con = AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());

        String idManager = null;

        // If the connected user is french and in a central group, his manager is  the "parent sth id"
        if (userCountry == 'FRA' && (con.Account.Name.contains('CENTRAL') || con.Account.Name.contains('CTL'))) {
            idManager = con.Parent_STH_Id__c; //con.LU_Parent_STH_Id_N_1__c;
        }
        else { // Otherwise, it is the ReportsToId
            idManager = con.ReportsToId;
        }

        if(idManager == null){
            return null;
        }

        return [SELECT Id, Email, LastName, FirstName, MobilePhone, MailingStreet, 
                       MailingState, MailingPostalCode, MailingCountry, MailingCity, LU_Facebook_URL__c, Title 
                FROM Contact 
                WHERE Id = :idManager LIMIT 1];
    }
    
    @AuraEnabled
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }
}