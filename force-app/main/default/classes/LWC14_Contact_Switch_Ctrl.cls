public without sharing class LWC14_Contact_Switch_Ctrl {
    
    @AuraEnabled
    public static Contact getCurrentContact() {
        
        return (AP1002_Utils_User.getConnectedUserContact());

    }

}