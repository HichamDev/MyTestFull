public without sharing class lwc28_myprofile_contactinfo_ctrl {

    @AuraEnabled(cacheable=true)
    public static String getContactInfo() {

        User u = null;

        if([SELECT ContactId FROM User  WHERE Id = :UserInfo.getUserId()].ContactId != null){
            u = [SELECT Contact.FirstName, Contact.LastName, Contact.STHID__c, Contact.Email, SmallPhotoUrl, Contact.LU_Personal_URL__c, Contact.Ecommerce_Role__c
                   FROM User
                  WHERE Id = :UserInfo.getUserId()];
        }
        else{
            u = [SELECT FirstName, LastName, STHID__c, Email
                FROM User
                WHERE Id = :UserInfo.getUserId()];
        }
        
        return JSON.serialize(u);
    }

    @AuraEnabled(cacheable=true)
    public static Contact getContactInformations() {
        return AP1002_Utils_User.getConnectedUserContact();
    }

    @AuraEnabled(cacheable=true)
    public static AP1001_Cycle_Utils.CycleInfo getCurrentCycle() {
        return AP1001_Cycle_Utils.getCurrentCycleByUser(UserInfo.getUserId());
    }

    @AuraEnabled
    public static void updateContact(Contact con) {

        Contact contactToUpdate = new Contact(Id = con.Id, LU_Facebook_URL__c = con.LU_Facebook_URL__c, Phone = con.Phone, MobilePhone = con.MobilePhone, Email = con.Email, MailingStreet = con.MailingStreet,
                                                MailingPostalCode = con.MailingPostalCode, MailingCity = con.MailingCity, OptinNewsletter1__c = con.OptinNewsletter1__c, HasOptedOutOfEmail = con.HasOptedOutOfEmail, HasOptedOutOfFax = con.HasOptedOutOfFax);
        system.debug('>>> contactToUpdate :' + contactToUpdate);
        update contactToUpdate;
    }

    @AuraEnabled
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    @AuraEnabled
    public static User getUserInfo() {
        return [SELECT Id, LU_Use_New_Order_v2__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
    }
}