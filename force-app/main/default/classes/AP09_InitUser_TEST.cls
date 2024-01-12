/* 
------------------------------------------------------------
-- - Name          : AP09_InitUser_TEST 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Class used to enforce picklist values when importing data to salesforce 
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 19-OCT-2012  NGO    1.0    Initial version
------------------------------------------------------------
*/

@isTest
private class AP09_InitUser_TEST {
    
    
     static testMethod void synchroniseEmail() {
        
        Test.startTest();
        
        //create custom settings
        
        User__c customSettings = new User__c();
        
        customSettings.canEditMailOrPhone__c = true;
        customSettings.isInterfaceUser__c = false;
        customSettings.listEditableProfile__c = '*';
        customSettings.SetupOwnerId = Userinfo.getProfileId();
        
        insert customSettings;
        
        
        //Test with normal user admin
        Contact contact1 =createDealer('ESP_1000');
        
        User user = [select id, ProfileId from User where name = : system.label.USR00001 limit 1];
        
        User userCreated;
        
        //Test with iterface user
        //System.runAs(user){
        
        
            userCreated  = createUserfromAdmin('admin', 'system', 'admin1@businessdecision.com', 'FRA_Dealers Manager', contact1);
        
            insert userCreated;
        //}
        
        userCreated = [select Id, Email from user where Id =: userCreated.Id limit 1][0];
        
        //changeEmail
        userCreated.Email = 'test@businessdecision.com' ;
        userCreated.MobilePhone = '01456789';
        system.debug('Update user with new email '+userCreated.Id);
        update userCreated;
        
        Contact contactUpdated = [Select Id, Email from Contact where Id =: contact1.Id limit 1][0];
     
        System.assertEquals( 'test@businessdecision.com', contactUpdated.Email);
        
        userCreated = [Select Id, TECH_IsUserChangedEmail__c, TECH_IsUserChangedPhone__c from User where Id =: userCreated.Id limit 1][0];
        
        System.assert(userCreated.TECH_IsUserChangedEmail__c);
        
        System.assert(userCreated.TECH_IsUserChangedPhone__c);
        
        Test.stopTest();
        
     }
     
     static testMethod void testInterface() {
        
        Test.startTest();
        
        //create custom settings
        
        User__c customSettings = new User__c();
        List<User> lisOfUsers= new List<User>();
        customSettings.canEditMailOrPhone__c = true;
        customSettings.isInterfaceUser__c = true;
        customSettings.listEditableProfile__c = '*';
        
        customSettings.SetupOwnerId = Userinfo.getProfileId();
        insert customSettings;
        
        
        //Test with normal user admin
        Contact contact1 =createDealer('ESP_1000');
        
        User user = [select id, ProfileId from User where name = : system.label.USR00001 limit 1];
        
        User userCreated;
        
        //Test with iterface user
        //System.runAs(user){
        
        
            userCreated  = createUserfromAdmin('admin', 'system', 'admin1@businessdecision.com', 'FRA_Dealers Manager', contact1);
            userCreated.IsActive=false;
            insert userCreated;
        //}
        
        userCreated = [select Id, Email from user where Id =: userCreated.Id limit 1][0];
        
        
        //changeEmail
        userCreated.Email = 'test@businessdecision.com' ;
        userCreated.MobilePhone = '01456789';
        system.debug('Update user with new email '+userCreated.Id);
        update userCreated;
        
        Contact contactUpdated = [Select Id, Email from Contact where Id =: contact1.Id limit 1][0];
     
        //System.assertEquals( 'test@businessdecision.com', contactUpdated.Email);
        
        userCreated = [Select Id, TECH_IsUserChangedEmail__c, TECH_IsUserChangedPhone__c from User where Id =: userCreated.Id limit 1][0];
        
        System.assert(userCreated.TECH_IsUserChangedEmail__c);
        
        System.assert(userCreated.TECH_IsUserChangedPhone__c);
        
        //FRA_Dealers Manager
        customSettings.listEditableProfile__c = 'FRA_Dealers Manager';
        customSettings.SetupOwnerId = Userinfo.getProfileId();
        update customSettings;
        
        userCreated.Email = 'test1@businessdecision.com'    ;
        userCreated.MobilePhone = '014567891';
        system.debug('Update user with new email '+userCreated.Id);
        update userCreated;
        userCreated = [Select Id, TECH_IsUserChangedEmail__c, TECH_IsUserChangedPhone__c from User where Id =: userCreated.Id limit 1][0];
        
        System.assert(userCreated.TECH_IsUserChangedEmail__c);
        
        System.assert(userCreated.TECH_IsUserChangedPhone__c);
        Test.stopTest();
        
     }

    static testMethod void myUnitTest() {
    
    
        Test.startTest();
        
        
        //Test with normal user admin
        User userCreated  = createUser('admin', 'system', 'admin@businessdecision.com', 'FRA_Dealers Manager', createDealer('ESP_1000'));
        
        try{
            insert userCreated;
        } catch (DMLException e){
            
            System.assert(e.getMessage().contains('REQUIRED_FIELD_MISSING'));
             System.debug(e);
        }
        
        User user = [select id, ProfileId from User where name = : system.label.USR00001 limit 1];
        
        //Test with iterface user
        System.runAs(user){
            
            User__c customSettings = new User__c();
            List<User> lisOfUsers= new List<User>();
            customSettings.canEditMailOrPhone__c = false;
            customSettings.isInterfaceUser__c = true;
            
            customSettings.SetupOwnerId = Userinfo.getProfileId();
            
            insert customSettings;
            

             Contact contact1 = createDealer('ESP_2030');
             
             User userCreated1  = createUser('Noor', 'Goolamnabee', 'noor1.goolamnabee@businessdecision.com', 'FRA_Dealers Manager', contact1);
             
             insert userCreated1;
             
             userCreated1 = getUser(userCreated1.Id);
             
             System.debug(userCreated1.alias);
             
             System.assert(userCreated1.alias.equals('ngoolamn'));
             
             System.assert(userCreated1.CommunityNickname.equals('noor1.goolamnabee@businessdecision.com'));
             
             System.assert(userCreated1.EmailEncodingKey.equals('ISO-8859-1'));
             
             System.assert(userCreated1.DefaultGroupNotificationFrequency.equals('N'));
              
             System.assert(userCreated1.DigestFrequency.equals('D'));
             
             System.assert(!userCreated1.ForecastEnabled); //check if false
          
             
             Contact contact2 = createDealer('ESP_2031');
             
             User userCreated2  = createUser('', 'Goolamnabee', 'noor1.goolamnabee@businessdecision.com123', 'FRA_Dealers Manager', contact2);
             
             insert userCreated2;
             
             userCreated2 = getUser(userCreated2.Id);
             
             System.debug(userCreated2.alias);
             
             System.assert(userCreated2.alias.equals('goolamna'));
             
             System.assertEquals(userCreated2.TECH_ContactID__c , contact2.Id);
             
             userCreated2.alias = 'goolamn1';
             
             update userCreated2;
             
             System.assertEquals(userCreated2.TECH_ContactID__c , contact2.Id);
             
             //System.assert(userCreated2.CommunityNickname.equals('noor1.goolamnabee@businessdecision.com123'));
             
             Contact contact3 = createDealer('ESP_2033');
             
             User userCreated3  = createUser('Noor', 'Goola', '123456noor.goolamnabee@businessdecision.com', 'FRA_Dealers Manager', contact3);
             
             insert userCreated3;
             
             userCreated3 = getUser(userCreated3.Id);
             
             System.debug('***** '+userCreated3.username);
             
             System.assert(userCreated3.alias.equals('ngoola'));
             
             System.assert(userCreated3.CommunityNickname.equals('123456noor.goolamnabee@businessdecision.'));
             
             System.debug('***** TECH_ContactID__c '+ userCreated3.TECH_ContactID__c);
             
             System.assertEquals(userCreated3.TECH_ContactID__c , contact3.Id);
             
             System.assert(userCreated3.ContactID == null);
             
             Contact contact5 = createDealer('ESP_2035');
             
             userCreated3.TECH_ContactID__c = contact5.ID;
             
             update userCreated3;
             
              System.debug('***** TECH_ContactID__c '+ userCreated3.TECH_ContactID__c);
             
             
             System.assertEquals(userCreated3.TECH_ContactID__c , contact5.Id);
             
             System.assert(userCreated3.ContactID == null);
             
             
             Contact contact4 = createDealer('ESP_2034');
             
             User userCreated4  = createUser('Dealer', 'Dealer', 'dealer.dealer@businessdecision.com', 'FRA_Dealer', contact4);
             
             insert userCreated4;
             
             userCreated4 = getUser(userCreated4.Id);
             
             System.debug('***** '+userCreated4.username);
             
             System.assert(userCreated4.TECH_ContactID__c == null);
             
             System.assert(userCreated4.ContactID == contact4.Id);
             
             System.assert(!userCreated4.UserPermissionsChatterAnswersUser);
             
             
             List<System.ResetPasswordResult> passwords = new list<System.ResetPasswordResult>();
             
             System.debug('***** passwords '+passwords);
             
             lisOfUsers.add(userCreated1);
             //lisOfUsers.add(userCreated2);
             //lisOfUsers.add(userCreated3);
             //lisOfUsers.add(userCreated4);
             AP09_InitUser.updateUserContact(lisOfUsers);
        }
        
        Test.stopTest();
        
    }
    
    private static User getUser(Id userId){
        
        return [select id, alias,ProfileId, username, EmailEncodingKey, DefaultGroupNotificationFrequency,
                                        DigestFrequency, ForecastEnabled, CommunityNickname, TECH_ContactID__c, ContactID, UserPermissionsChatterAnswersUser  from User where id = :userId limit 1];
    }
    
    
    
    static User createUser(String firstName, String lastName, String username, String profile, Contact contact){
        system.debug('## profile : '+profile);
         Profile profileDealer = [Select Id From Profile Where name = :profile];
        
          //Insert new user
         User user1 = new User( 
                                email=firstName+lastName+'@sth.com', 
                                firstname = firstName,
                                lastname = lastName,
                                languagelocalekey='fr', 
                                localesidkey='fr_FR_EURO', 
                                profileid = profileDealer.Id,
                                timezonesidkey='Europe/Paris', 
                                username=username,
                                MobilePhone= '34567', 
                                TECH_ExternalId__c= firstName+lastName, 
                                TECH_ContactID__c = contact.TECH_ExternalId__c
                               );       
        return user1;
        
    }
    
    
     static User createUserFromAdmin(String firstName, String lastName, String username, String profile, Contact contact){
        system.debug('## profile : '+profile);
         Profile profileDealer = [Select Id From Profile Where name = :profile];
        
          //Insert new user
         User user1 = new User( 
                                email=firstName+lastName+'@sth.com', 
                                firstname = firstName,
                                lastname = lastName,
                                languagelocalekey='fr', 
                                localesidkey='fr_FR_EURO', 
                                profileid = profileDealer.Id,
                                timezonesidkey='Europe/Paris', 
                                username=username,
                                MobilePhone= '34567', 
                                TECH_ExternalId__c= firstName+lastName, 
                                TECH_ContactID__c = contact.Id,
                                alias = firstName,
                                EmailEncodingKey = system.label.USR00002
                               );       
        return user1;
        
    }
    
    static  Contact createDealer(String sthId){

        Contact contact = new Contact(STHID__c=sthId,TECH_ExternalId__c=sthId, AccountId=createAccount(), lastname='br09Contact',firstname='br09Contact', MinOrder__c=50, MinOrderFreeTransportFees__c=50);
        
        insert contact;
       
        return contact;
    }
    
    static Id createAccount(){
    
        String acc_name = 'Test Account BR04';
        
        Account acct = new Account(name=acc_name, Country_Code__c='FRA');
        insert acct;
        
        return acct.Id;
    }
}