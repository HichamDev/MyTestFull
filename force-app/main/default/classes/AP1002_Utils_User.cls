public without sharing class AP1002_Utils_User {
    
    /* GET COUNTRY OF A USER BASED ON HIS TEXHEXTERNALID */
    public static String getUserCountry(Id userId) {
        
        String country = '';
        User currentUser = [SELECT Id, TECH_ExternalId__c FROM User WHERE Id =: userId];
        System.debug('USERID : ' + currentUser);
        System.debug(currentUser.TECH_ExternalId__c);
        if (currentUser != null && currentUser.TECH_ExternalId__c != null && currentUser.TECH_ExternalId__c != '') {
            country = currentUser.TECH_ExternalId__c.left(3);
        }

        return (country);
    }

    /* GET COUNTRY OF A USER BASED ON A USER OBJECT : must have the tech_external_id queried*/
    public static String getUserCountry(User u) {
        
        String country = '';

        if (u != null && u.TECH_ExternalId__c != null && u.TECH_ExternalId__c != '') {
            country = u.TECH_ExternalId__c.left(3);
        }

        return (country);
    }



    /* GET CURRENT USER LINKED CONTACT */
    public static Contact getContactFromUser(Id userid){
        User user = [SELECT Id, TECH_MergeContactID__c FROM User WHERE Id =: userid LIMIT 1];
        System.debug('>>> user : ' + user);
        if (user.TECH_MergeContactID__c  != null) {
            Contact contact = AP1003_Utils_Contact.getContactInfo(user.TECH_MergeContactID__c);                    
            return (contact);
        } else {
            return null;
        }
        
    }

    // Get current user
    public static Contact getConnectedUserContact() {
        return (getContactFromUser(Userinfo.getUserId()));
    }

    // Get current user profile name
    public static String getUserProfileName() {
        Profile vProf = [Select Name 
                        From Profile 
                        Where Id =: Userinfo.getProfileid()];
        
        return vProf.Name;
    }

}