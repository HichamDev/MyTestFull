public with sharing class lwc76_statement_list_filters_ctrl {
    
    @AuraEnabled(cacheable=true)
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }
    
    @AuraEnabled(cacheable=true)
    public static Contact getCurrentContact() {
        return AP1002_Utils_User.getConnectedUserContact();
    }
}