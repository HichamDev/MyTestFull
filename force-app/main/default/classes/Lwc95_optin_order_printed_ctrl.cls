public without sharing class Lwc95_optin_order_printed_ctrl {
    public static String getContactIdFromUser(){
        User u = [SELECT Id, ContactId, Contact.OptinNewsletter3__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId() LIMIT 1];
                  return u.ContactId;
    }

    @AuraEnabled(cacheable=true)
    public static Contact getContactInfo() {
        // Check if there is a Contact associated with the User
        if (getContactIdFromUser() != null) {
            Contact associatedContact = [SELECT Id, OptinNewsletter3__c
                                         FROM Contact
                                         WHERE Id = :getContactIdFromUser() LIMIT 1];
            System.debug(associatedContact);
            return associatedContact;
        }
        return null; // Or return an appropriate response if there's no associated Contact
    }

    @AuraEnabled
    public static void updateContactOptin(String contactId, Boolean isChecked) {
        if (getContactIdFromUser() != null) {
            Contact associatedContact = [SELECT Id, OptinNewsletter3__c FROM Contact WHERE Id = :getContactIdFromUser() LIMIT 1];
            associatedContact.OptinNewsletter3__c = isChecked;
            update associatedContact;
        }
    }

    @AuraEnabled
    public static Contact getContactInformations() {
        return AP1002_Utils_User.getConnectedUserContact();
    }

    @AuraEnabled
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }
}