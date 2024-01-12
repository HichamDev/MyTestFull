public without sharing class lwc64_alert_payment_ctrl {

    @AuraEnabled
    public static Contact getContact() {

        return AP1002_Utils_User.getContactFromUser(Userinfo.getUserId());
    }

    @AuraEnabled
    public static String getUserCountry() {

        return AP1002_Utils_User.getUserCountry(Userinfo.getUserId());
    }
}