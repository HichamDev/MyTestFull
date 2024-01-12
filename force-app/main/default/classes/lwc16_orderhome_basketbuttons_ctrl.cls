public class lwc16_orderhome_basketbuttons_ctrl {
    
    @AuraEnabled
    public static Contact getUserInformation() {
        return (AP1002_Utils_User.getConnectedUserContact());
    }

    @AuraEnabled
    public static String getUSerProfile(){
        return AP1002_Utils_User.getUserProfileName();
    }

    @AuraEnabled(cacheable=true)
    public static AppConstants getAllConstants() {
        return new AppConstants();
    }
}