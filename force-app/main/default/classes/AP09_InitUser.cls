/* 
------------------------------------------------------------
-- - Name          : AP09_InitUser 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Class used to enforce picklist values when importing data to salesforce 
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 17-OCT-2012  NGO    1.0    Initial version
-- 10-DEC-2012  NGO    1.1    Set Contact Id
-- 08-FEV-2013  NGO    1.2    Bug coreection when insert without contact
-- 28-FEV-2014  NGO    1.3    Enable AP09_5 by profile userSettings.canEditMailOrPhone__c
------------------------------------------------------------
*/
public with sharing class AP09_InitUser {
    
    /**
    * Initialize user with 
    * DefaultValue -         user.DefaultGroupNotificationFrequency = 'N';
    *                        user.DigestFrequency = 'D';
    *                        user.ForecastEnabled = false;
    * CommunityNickname -    first 40 letters of username
    * CurrencyIsoCode   -    user.CurrencyIsoCode = user.DefaultCurrencyIsoCode;
    * Alias  -               first letter of first name + first 7 letters of last name
    * EmailEncodingKey  -    user.EmailEncodingKey =    ISO-8859-1 system.label.USR00002;
    * ContactId     -        Associate a contact to the user, contactId for customer portal or else TECH_ContactId
    */
    static public void initializeUser(List<user> users){
        
        if(SHW_IBZ_Utils.isInterfaceUser()){
            
            Map<Id, Profile> profileMap = getProfileMap();
            
            Map<String, Id> contactMapId = getUserIdBySTHIDs(getListExternalId(users));
            
            
            for(User user : users){
            
                setDefaultValue(user);
                setCommunityNickname(user);
                setCurrencyIsoCode(user);
                setAlias(user);
                setEmailEncodingKey(user);
                setContactId(user, profileMap, contactMapId);
            
            }       
        }
    }
    
    static private boolean isChangedProfile(User user, Map<Id,User> mapOld){
        return user.ProfileId != mapOld.get(user.Id).ProfileId;
    }
    
    /**
    * Update User with the associated contact for non customer portal user in the field TECH_ContactId.
    */
    static public void updateUserContact(List<user> users, Map<Id, User> oldMap){
        
        if(SHW_IBZ_Utils.isInterfaceUser()){
            
            Map<String, Id> contactMapId = getUserIdBySTHIDs(getListExternalId(users));
            
            Map<Id, Profile> profileMap = getProfileMap();
            
            for(User user : users){
                
                // if(!isChangedProfile(user, oldMap)){
                //if(isChangedProfile(user, oldMap)){

                    updateContactId(user, profileMap, contactMapId);
                //} 
            }       
        }
    
    }
    
    static public void updateUserContact(List<user> users){
        
        if(SHW_IBZ_Utils.isInterfaceUser()){
            
            Map<String, Id> contactMapId = getUserIdBySTHIDs(getListExternalId(users));
            
            Map<Id, Profile> profileMap = getProfileMap();
            
            for(User user : users){
            
                updateContactId(user, profileMap, contactMapId);
            
            }       
        }
    
    }
    
    
    static public void restrictChangeForInterface(List<String> fieldToRestricts, List<User> users, Map<Id,User> oldMap){
        System.debug('>>>>>>>>>> START restrictChangeForInterface: ');
        String listProfiles = getListOfProfile();
        boolean canEditEmailPhone = canEditEmailPhone();
        boolean isInterface = SHW_IBZ_Utils.isInterfaceUser();
        
        List <User> interfaceUpdateUsers=new list<User>();
        System.debug('>>>>>>>>>> Enter Interface change 1st level ' +!((listProfiles!=null ? listProfiles.equals('*') : false) && canEditEmailPhone));
             
        if(!((listProfiles!=null ? listProfiles.equals('*') : false) && canEditEmailPhone)){      
            
            for(User user:users){
                System.debug('>>>>>>>>>> user.Id: ' +user.Id);
                System.debug('>>>>>>>>>> user.TECH_ProfileName__c ' +user.TECH_ProfileName__c);
                System.debug('>>>>>>>>>> listProfiles ' +listProfiles);
                System.debug('>>>>>>>>>> Enter Interface change 2nd level ' + !canEditEmailPhoneByProfile(canEditEmailPhone, listProfiles, user.TECH_ProfileName__c));
                
                boolean restrictChange=true;
                
                if(canEditEmailPhoneByProfile(canEditEmailPhone, listProfiles, user.TECH_ProfileName__c)){
                    if(isInterface){
                        if(oldMap.get(User.id).isActive){
                            restrictChange=true;
                        }else{
                            restrictChange=false;
                        }
                    }else{
                        restrictChange=false;
                    }
                }
                
                System.debug('>> restrictChange : ' + restrictChange);

                if(restrictChange){ 
                    for(String fieldToRestrict : fieldToRestricts){
                        if(oldMap.get(user.Id).get(fieldToRestrict) != null){
                            user.put(fieldToRestrict, oldMap.get(user.Id).get(fieldToRestrict));
                            System.debug('>>>>>>>>>> user '+ fieldToRestrict +' : '+ user.get(fieldToRestrict));
                        }
                    }
                }else{
                    System.debug('>>>>>>>>>>1 email/phone changed for user.Id: ' +user.Id);
                    updateUserIsEdit(user, oldMap, isInterface);
                    interfaceUpdateUsers.add(user);
                }
            }   
        }else{
            boolean restrictChange=true;
            for(User user:users){
                restrictChange=true;
                if(isInterface){
                        if(oldMap.get(User.id).isActive){
                            restrictChange=true;
                        }else{
                            restrictChange=false;
                        }
                }else{
                    restrictChange=false;
                }
                
                if(restrictChange){ 
                    
                    for(String fieldToRestrict : fieldToRestricts){
                        
                        if(oldMap.get(user.Id).get(fieldToRestrict) != null){
                            
                            user.put(fieldToRestrict, oldMap.get(user.Id).get(fieldToRestrict));
                            system.debug('>>>>>>>>>> user '+ fieldToRestrict +' : '+ user.get(fieldToRestrict));
                        }
                    }
                }else{
                    
                    system.debug('>>>>>>>>>>1 email/phone changed for user.Id: ' +user.Id);
                    updateUserIsEdit(user, oldMap, isInterface);
                    interfaceUpdateUsers.add(user);
                }
            }
            
            
        }
        //synchroniseContactEmailInterface(interfaceUpdateUsers,  oldMap);
        system.debug('>>>>>>>>>> END restrictChangeForInterface: ');
    }
    
    
    static private void updateUserIsEdit(User user,  Map<Id,User> oldMap, Boolean isInterface){
        boolean isEdit=false;
        if(isInterface){//if interface and user is inactive then email and phone can be changed
            if(user.IsActive==false){
                isEdit=true;
            }
        }else{
            isEdit=true;
        }
        if(isEdit){
            if(user.Email != oldMap.get(user.Id).Email){
                    user.TECH_IsUserChangedEmail__c = true;
            }
            
            if(user.MobilePhone !=oldMap.get(user.Id).MobilePhone ){
                user.TECH_IsUserChangedPhone__c =true;
            }
        }
    }
    
    
    static public void restrictChangeForEditedEmailPhone( List<User> users, Map<Id,User> oldMap){
            for(User user:users){
                system.debug('>>>>>>>>>> user.Id: ' +user.Id);
                system.debug('>>>>>>>>>> SHW_IBZ_Utils.isInterfaceUser(): ' +SHW_IBZ_Utils.isInterfaceUser()+',user.IsActive:'+user.IsActive+'.WCHY');
                
                if(SHW_IBZ_Utils.isInterfaceUser() && user.IsActive==true){//If interface and user active, restrict change.

                    if(user.TECH_IsUserChangedEmail__c && oldMap.get(user.Id).get('Email') != null){
                        user.email = oldMap.get(user.Id).Email;
                    }
                    
                    if(user.TECH_IsUserChangedPhone__c && oldMap.get(user.Id).get('MobilePhone') != null){
                        user.MobilePhone = oldMap.get(user.Id).MobilePhone;
                    }
                }
            }   
    }
    
    static private boolean canEditEmailPhoneByProfile(boolean canEditEmailPhone, String listProfiles, String profileName){
        system.debug(listProfiles +':xx:'+profileName);
        boolean containProfile = listProfiles!=null ? (listProfiles.indexOf(profileName) >= 0) : false;
        System.debug('***contain profile '+ containProfile);
        boolean isInterface = SHW_IBZ_Utils.isInterfaceUser();

        return containProfile && canEditEmailPhone;
    }
    
    static private string getListOfProfile(){
        User__c userSettings = User__c.getInstance(UserInfo.getUserId());
        System.debug('***userSettings.listEditableProfile__c '+ userSettings.listEditableProfile__c);
        return userSettings.listEditableProfile__c;
    }
    
    
    
    static private boolean canEditEmailPhone(){
        
        //retrieve custom settings 
        User__c userSettings = User__c.getInstance(UserInfo.getUserId());
        
        System.debug('***userSettings.canEditEmailPhone '+ userSettings.canEditMailOrPhone__c);
        
        return userSettings.canEditMailOrPhone__c;
    }
    
    
    /**
    * first 40 letters of username
    */
    static private void setCommunityNickname(User user){
        
        Integer length = user.Username.length();
        
        if( length > 40){
            length = 40;
        }
    
        user.CommunityNickname = user.Username.substring(0, length);
        
    }

    static private void setCurrencyIsoCode(User user){
        
        user.CurrencyIsoCode = user.DefaultCurrencyIsoCode;
        
    }


    static private void setDefaultValue(User user){
        
        user.DefaultGroupNotificationFrequency = 'N';
        user.DigestFrequency = 'D';
        user.ForecastEnabled = false;
            
    }
    
    /**
    * first letter of first name + first 7 letters of last name
    */
    static private void setAlias(User user){
        
        if(user.FirstName != null && user.FirstName.length() > 0){
        
            String name = user.FirstName.substring(0, 1);
            
            Integer length = user.LastName.length();
            
            if(length > 7){
                
                length = 7;
            }
            
            name += user.LastName.substring(0, length);
            
            user.Alias = name.toLowerCase();
            
        } else{
            
            Integer length = user.LastName.length();
            
            if(length > 8){
                
                length = 8;
            }
            
            String name = user.LastName.substring(0, length);
            
            user.Alias = name.toLowerCase();
        }
    }
    
    static private void setEmailEncodingKey(User user){
        
        user.EmailEncodingKey = system.label.USR00002;
        
    }

    
    static private void setContactId(User user, Map<Id, Profile> profileMap, Map<String, Id> contactMapId){

        if(user.TECH_ContactID__c != null){
            
            Id STHID = getUserIdBySTHID(user.TECH_ContactID__c, contactMapId);

            /*if(STHID == null){
                
                user.addError('There is no matching contact for contactId :' + user.TECH_ContactID__c);
            }*/
            system.debug(user);
            system.debug(user.TECH_ContactID__c);
            if(isCustomerProfile(user.ProfileId, profileMap)){
                system.debug('########yes: '+STHID);
                user.ContactId = STHID;
                
                user.TECH_ContactID__c = null;
    
            }else{
                
                user.TECH_ContactID__c = STHID;
            }
            
        }

    }
    
    static private void updateContactId(User user, Map<Id, Profile> profileMap, Map<String, Id> contactMapId){

        Id STHID = getUserIdBySTHID(user.TECH_ContactID__c, contactMapId);

        /*if(STHID == null){
            
            user.addError('There is no matching contact for contactId : ' + user.TECH_ContactID__c);
        }*/
        
        if(isCustomerProfile(user.ProfileId, profileMap)){
            user.TECH_ContactID__c = null;
        }else{
            String  sthContactId = user.TECH_ContactID__c;
            
            if(String.isNotBlank(sthContactId) &&  !isContactId(sthContactId) ){
                
                user.TECH_ContactID__c = STHID;   
            }            
        }
    }
    
    /**
    * check if user profile is dealer or high volume portal customer
    * updated by NAP 02/03/2017
    */
    private static boolean isCustomerProfile(Id userProfile, Map<Id, Profile> profileMap){
        
        Profile profile = profileMap.get(userProfile);

        boolean isHighVolumeUser = false;   
        
        if(profile.UserType == 'CSPLitePortal' || profile.UserType == 'PowerCustomerSuccess'){
            isHighVolumeUser = true;
        }
        
        //String profileCustom = system.label.userProfileDealer;
        
        //List<string> profiles = profileCustom.split(';');
        /*
        for(String profileName : profiles){
            
            if(profile.Name.equalsIgnoreCase(profileName)){
                
                isHighVolumeUser = true;
                
                break;
            }
        }*/
        
        return isHighVolumeUser;
    }
    
    
    static private Map<Id, Profile> getProfileMap(){
        
        return new Map<Id, Profile>([select Id, Name, UserType from Profile]);
    }
    
   /* public static void resetUserPassword(List<User> users){
        
        if(SHW_IBZ_Utils.isInterfaceUser()){
            
            for(User user : users){
                if(user.IsActive){
                    System.resetPassword(user.Id, true);
                }
            }   
        }
    }
    @future
    public static void resetUserPassword(List<String> users){

        List<Id> userIds = new List<Id>();
       
        for(String userSerial : users){
            
            userIds.add((Id) JSON.deserialize(userSerial, Id.class));
            
        }
        
        List<User> retrievedUser = [select Id, IsActive from user where Id in :  userIds];
       
        for(User user : retrievedUser){
       
            if(user.IsActive){
                System.resetPassword(user.Id, true);
            }   
        }   
    }*/
    
    static public void synchroniseContactEmail(List<User> users, Map<Id,User> oldMap){
        
        if(!SHW_IBZ_Utils.isInterfaceUser()){
            
            Set<Id> userTechContactIdSet = new Set<Id>();
            
            Map<Id,string> contactIdEmailMap = new Map<Id,string>();

            for(User user : users){
                
                system.debug('>>>>>>>>>> synchroniseContactEmail user.Email'+ user.Email);
                
                system.debug('>>>>>>>>>> synchroniseContactEmail oldMap.get(user.Id).Email'+ oldMap.get(user.Id).Email);
                
                if(user.Email==null ? true : !user.Email.equals(oldMap.get(user.Id).Email)){
                    
                    if(user.TECH_MergeContactID__c != null){
                        system.debug('>>>>>>>>>> user.TECH_MergeContactID__c'+ user.TECH_MergeContactID__c);
                        userTechContactIdSet.add(user.TECH_MergeContactID__c);
                        contactIdEmailMap.put(user.TECH_MergeContactID__c, user.Email);
                    }
                }   
            }
            
            //Retrieve contact 
            List<Contact> contacts = [select Id, Email from Contact where Id in : userTechContactIdSet];
            
            system.debug('>>>>>>>>>> synchroniseContactEmail contacts'+ contacts);
            
            if(contacts != null && contacts.size() > 0){
            
                List<Contact> contactsToBeUpdated = new List<Contact>();
            
                for(Contact contact : contacts){
                    
                    system.debug('>>>>>>>>>> contactIdEmailMap.get(contact.Id)'+ contactIdEmailMap.get(contact.Id));
                    
                    contact.Email = contactIdEmailMap.get(contact.Id);
                    
                    contactsToBeUpdated.add(contact);
                    
                }   
                
                if(contactsToBeUpdated.size() > 0){
                    update contactsToBeUpdated;
                }   
            }
        }
    }
    
    
    private static Id getUserIdBySTHID(String sthContactId, Map<String, Id> contactMapId){
        
        return contactMapId.get(sthContactId);
    }
    
    private static Map<String, Id> getUserIdBySTHIDs(Set<String> sthContactIds){
        
        system.debug('>>>>>>>>>> getUserIdBySTHID: '+ sthContactIds);
        
        Map<String, Id> contactMapIds = new Map<string, Id>();
        
        Contact[] contacts = new List<Contact>();
        
        //if(/*sthContactIds != null && sthContactIds.size() == 1*/false){ //TODO uncheck for normal user
            
            //contacts = [Select Id, TECH_ExternalId__c from Contact where TECH_ExternalId__c = : sthContactIds[0]];
            
        //}else{
            
            //String country_code = retrieveCountryCode(sthContactIds);
            
            //if(country_code != null){
                
            //  contacts = [Select Id, TECH_ExternalId__c from Contact where TECH_ExternalId__c in : sthContactIds and AccountCountryCode__c =: country_code];
            //}else{
                
            contacts = [Select Id, TECH_ExternalId__c from Contact where TECH_ExternalId__c in : sthContactIds];
            //}
        
        //}

        for(Contact contact : contacts){
            
            contactMapIds.put(contact.TECH_ExternalId__c, contact.Id);
            
        }
    
        return contactMapIds;
    }
    /*
    private static string retrieveCountryCode(List<String> sthContactIds){
        
        Contact[] contacts = new List<Contact>();
        
        if(sthContactIds != null && sthContactIds.size() > 0){
             
            contacts = [Select Id, AccountCountryCode__c from Contact where TECH_ExternalId__c = : sthContactIds[0] limit 1];
       
        }
        if(contacts != null && contacts.size() > 0){
            
            return contacts[0].AccountCountryCode__c;
        }
        
        return null;
    }*/
    
    private static Set<String> getListExternalId(List<User> users){
        
        Set<String> userExternalTechContacts = new Set<string>();
        
        for(User user : users){
            if(user.TECH_ContactID__c != null && !String.isEmpty(user.TECH_ContactID__c)){
                userExternalTechContacts.add(user.TECH_ContactID__c);
            }
        }
        
        return userExternalTechContacts;
        
    }
    
    private static Boolean isContactId(String id){
        
        return id.startsWith('003');
        
    }
    
     static public void synchroniseContactEmailInterface(List<User> users, Map<Id,User> oldMap){
        
        //if(!SHW_IBZ_Utils.isInterfaceUser()){
            
            Set<Id> userTechContactIdSet = new Set<Id>();
            
            Map<Id,string> contactIdEmailMap = new Map<Id,string>();

            for(User user : users){
                
                system.debug('>>>>>>>>>> synchroniseContactEmail user.Email'+ user.Email);
                
                system.debug('>>>>>>>>>> synchroniseContactEmail oldMap.get(user.Id).Email'+ oldMap.get(user.Id).Email);
                
                if(!user.Email.equals(oldMap.get(user.Id).Email)){
                    
                    if(user.TECH_MergeContactID__c != null){
                        system.debug('>>>>>>>>>> user.TECH_MergeContactID__c'+ user.TECH_MergeContactID__c);
                        userTechContactIdSet.add(user.TECH_MergeContactID__c);
                        contactIdEmailMap.put(user.TECH_MergeContactID__c, user.Email);
                    }
                }   
            }
            
            //Retrieve contact 
            List<Contact> contacts = [select Id, Email from Contact where Id in : userTechContactIdSet];
            
            system.debug('>>>>>>>>>> synchroniseContactEmail contacts'+ contacts);
            
            if(contacts != null && contacts.size() > 0){
            
                List<Contact> contactsToBeUpdated = new List<Contact>();
            
                for(Contact contact : contacts){
                    
                    system.debug('>>>>>>>>>> contactIdEmailMap.get(contact.Id)'+ contactIdEmailMap.get(contact.Id));
                    
                    contact.Email = contactIdEmailMap.get(contact.Id);
                    
                    contactsToBeUpdated.add(contact);
                    
                }   
                
                if(contactsToBeUpdated.size() > 0){
                    update contactsToBeUpdated;
                }   
            }
        //}
    }

}