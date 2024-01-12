public class lwc59_orderhome_order_ctrl {
	
    @AuraEnabled
    public static String getPersonalMessage() {
        
        Contact con = AP1002_Utils_User.getConnectedUserContact();
        
        if(!String.isBlank(con.PersonalMessage__c)){
            return con.PersonalMessage__c;
        }
        
        return null;
    }
}