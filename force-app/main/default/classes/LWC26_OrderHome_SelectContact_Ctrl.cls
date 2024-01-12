public without sharing class LWC26_OrderHome_SelectContact_Ctrl {

    /* WRAPPER */
    public class CurrentUserInfo {
        @AuraEnabled
        public Contact connectedContact {get;set;}
        @AuraEnabled
        public User connectedUser {get;set;}
        @AuraEnabled
        public Boolean hasTheRightToOrderOnBehalfOf {get;set;}
    }

    @AuraEnabled
    public static List<Contact> getContacts(String type) {
        
        /* Variables */
        User u = [SELECT Id, TECH_ExternalId__c, TECH_MergeContactID__c FROM User WHERE Id =: UserInfo.getUserId()];

        Map<Id, Contact> m_contacts = null;

        // If the search type is customer
        if (type == Label.LU_TECH_Contact_Customer) {
            m_contacts = new Map<Id, Contact>(AP1003_Utils_Contact.searchMyCustomers(u, null, 'LastName', 'ASC'));
        } else { // Type is my team
            m_contacts = new Map<Id, Contact>(AP1003_Utils_Contact.searchMyTeam(u, null, 'Name', 'ASC'));
        }
        
        for(User userContact : [SELECT ContactId, SmallPhotoUrl FROM User WHERE ContactId IN :m_contacts.keyset()]){
            m_contacts.get(userContact.ContactId).LU_TECH_ProfilePicture__c = userContact.SmallPhotoUrl;
        }

        return m_contacts.values();
    }

    @AuraEnabled
    public static Contact getContactById(String idContact) {

        Contact c = [SELECT Id, LocalAttribute4__c, PersonalMessage__c, FirstName, LastName, LU_Nickname__c, LU_TECH_ProfilePicture__c, AccountCountryCode__c, AllowedPaymentMode__c FROM Contact WHERE Id = :idContact];

        User u;
        try{
            u = [SELECT SmallPhotoUrl FROM User WHERE ContactId = :idContact];
        }
        catch(Exception e){
            return c;
        }
        
        c.LU_TECH_ProfilePicture__c = u.SmallPhotoUrl;

        return c;
    }

    @AuraEnabled
    public static String isUserBillToContact() {
        try{
            User u = [SELECT TECH_MergeContactID__c FROM User WHERE Id =: UserInfo.getUserId()];
            // Order orderCUrrent = [SELECT Id, BillToContact.Id FROM Order WHERE Id =: orderId];
            return u.TECH_MergeContactID__c;
        }
        catch(Exception e){
            return null;
        }

    }


    @AuraEnabled
    public static CurrentUserInfo getCurrentUserInformation() {
        
        // Variables
        CurrentUserInfo info = new CurrentUserInfo();

        // Get connected contact information
        info.connectedContact = AP1002_Utils_User.getConnectedUserContact();
        info.connectedUser = AP1003_Utils_Contact.getContactUserAssociated(info.connectedContact.Id);

        User u = [SELECT SmallPhotoUrl FROM User WHERE Id = :UserInfo.getUserId()];

        info.connectedContact.LU_TECH_ProfilePicture__c = u.SmallPhotoUrl;

        // Get information about ordering for someone else
        List<LU_Order_Rule__c> lRule = [ SELECT Id
                                            FROM LU_Order_Rule__c
                                            WHERE RecordType.DeveloperName = 'LU_Order_Order_On_Behalf_Of'
                                            AND LU_Text__c = :info.connectedUser.Profile.Name
                                            AND LU_Active__c = true
                                            AND LU_Country__c = :info.connectedContact.AccountCountryCode__c ];
        if (!lRule.isEmpty()) {
            info.hasTheRightToOrderOnBehalfOf = true;
        } else {
            info.hasTheRightToOrderOnBehalfOf = false;
        }

        return (info);
    }


    @AuraEnabled
    public static Contact getMyContact() {
        User u = [SELECT SmallPhotoUrl FROM User WHERE Id = :UserInfo.getUserId()];
        
        Contact c = AP1002_Utils_User.getConnectedUserContact();
        if(c != null) c.LU_TECH_ProfilePicture__c = u.SmallPhotoUrl;

        return c;
    }


    
    @AuraEnabled(cacheable=true)
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    @AuraEnabled(cacheable=true)
    public static User getConnectedUser() {
        return [SELECT Id, TECH_ExternalId__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
    }

    @AuraEnabled
    public static String getUserContactTitle() {

        return AP1002_Utils_User.getConnectedUserContact().Title;
    }

    @AuraEnabled
    public Static Boolean getIsSandbox() {

        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}