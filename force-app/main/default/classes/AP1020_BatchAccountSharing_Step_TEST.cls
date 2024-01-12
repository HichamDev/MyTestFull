@isTest
public class AP1020_BatchAccountSharing_Step_TEST {
    
    @testSetup static void init() {

        // Create owner user (top manager)        
        User userOwner = new User( //STHUniqueID__c= sthId,
                                    firstname= 'BR04',
                                    lastname='XXXXOwner',
                                    Alias='ownerA',
                                    email = 'owner@XXXXX.com',
                                    username= 'owner@XXXXX.com', 
                                    profileId = [SELECT id, Name FROM Profile where name = 'FRA_Dealers Manager' LIMIT 1].Id, 
                                    emailencodingkey='UTF-8',
                                    languagelocalekey='en_US',
                                    localesidkey='en_US',
                                    timezonesidkey='America/Los_Angeles',
                                    phone = '123456789',
                                    UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRANCE' LIMIT 1].Id
        );
        insert userOwner;

        
        
    }
        


    static testMethod void createSharingUnitTest_FRA_1() {
    	
        Test.startTest();
        
        Id ownerId = [SELECT Id FROM User WHERE LastName = 'XXXXOwner' LIMIT 1].Id;

        // Create Accounts
    	Account top1 = createAccount('top1', 'FRA', '5');
    	
    	Account top1_middle1 = createAccountWithParent('top1_middle1', 'FRA', '4', top1.Id, ownerId);
 		Account top1_middle2 = createAccountWithParent('top1_middle2', 'FRA', '4', top1.Id, ownerId); 

        Account top1_middle1_child1 = createAccountWithParent('top1_middle1_child1', 'FRA', '3', top1_middle1.Id, ownerId);
 		Account top1_middle2_child2 = createAccountWithParent('top1_middle2_child2', 'FRA', '3', top1_middle2.Id, ownerId); 

        
        Test.stopTest();


        // Add contact / User middle manager 1
        Contact contact_middlemanager1 = new Contact(
            LastName = 'Middle manager 1'
            ,firstName = 'Test'
            ,Birthdate = system.today()
            ,email = 'middlemanager1@mail.com'
            ,Contact_Type__c= 'Leader'
            ,accountid = top1_middle1.id
            ,TECH_ExternalId__c = 'FRA_123456'
            ,MinOrderFreeTransportFees__c = 10.50
            ,STHID__c = '9898'
            ,ActivityStatus__c = true
            ,Title = 'Animatrice de Secteur'
        );
        Database.insert(contact_middlemanager1); 
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'FRA_LU_Dealer_Manager' Limit 1];
        User user1 = new User(
            Username = 'middlemanager1@test.com',
            ContactId = contact_middlemanager1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'contact_middlemanager1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'contact_middlemanager1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TECH_ExternalId__c = 'FRA_1234567890'
        );
        Database.insert(user1); 

        // Add contact / User middle manager 2
        Contact contact_middlemanager2 = new Contact(
            LastName = 'Middle manager 2'
            ,firstName = 'Test'
            ,Birthdate = system.today()
            ,email = 'middlemanager2@mail.com'
            ,Contact_Type__c= 'Leader'
            ,accountid = top1_middle2.id
            ,TECH_ExternalId__c = 'FRA_1234561'
            ,MinOrderFreeTransportFees__c = 10.50
            ,STHID__c = '98981'
            ,ActivityStatus__c = true
            ,Title = 'Animatrice de Secteur'
        );
        Database.insert(contact_middlemanager2); 
        Profile portalProfile1 = [SELECT Id FROM Profile WHERE Name = 'FRA_LU_Dealer_Manager' Limit 1];
        User user2 = new User(
            Username = 'middlemanager2@test.com',
            ContactId = contact_middlemanager2.Id,
            ProfileId = portalProfile1.Id,
            Alias = 'test1231',
            Email = 'contact_middlemanager2@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'contact_middlemanager2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TECH_ExternalId__c = 'FRA_1234567891'
        );
        Database.insert(user2); 

        // Add contact / User child manager 1
        Contact contact_childmanager1 = new Contact(
            LastName = 'Manager 1'
            ,firstName = 'Test'
            ,Birthdate = system.today()
            ,email = 'contact_childmanager1@mail.com'
            ,Contact_Type__c= 'Leader'
            ,accountid = top1_middle1_child1.id
            ,TECH_ExternalId__c = 'FRA_1234562'
            ,MinOrderFreeTransportFees__c = 10.50
            ,STHID__c = '98982'
            ,ActivityStatus__c = true
            ,Title = 'Animatrice'
        );
        Database.insert(contact_childmanager1); 
        Profile portalProfile3 = [SELECT Id FROM Profile WHERE Name = 'FRA_LU_Dealer_Member' Limit 1];
        User user3 = new User(
            Username = 'contact_childmanager1@test.com',
            ContactId = contact_childmanager1.Id,
            ProfileId = portalProfile3.Id,
            Alias = 'test1231',
            Email = 'contact_childmanager1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'contact_childmanager1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TECH_ExternalId__c = 'FRA_1234567892'
        );
        Database.insert(user3);


        // Execute the batch 
        AP1020_BatchAccountSharing_Step1 batchAccountSharing = new AP1020_BatchAccountSharing_Step1('FRA');
        system.AssertEquals('FRA', batchAccountSharing.country);
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(batchAccountSharing);


        // Test.stopTest();


    }

    static testMethod void createSharingUnitTest_ITA_1() {
    	
        Test.startTest();
        
        Id ownerId = [SELECT Id FROM User WHERE LastName = 'XXXXOwner' LIMIT 1].Id;

        // Create Accounts
    	Account top1 = createAccount('top1', 'ITA', '6');
    	
    	Account top1_middle1 = createAccountWithParent('top1_middle1', 'ITA', '5', top1.Id, ownerId);
 		Account top1_middle2 = createAccountWithParent('top1_middle2', 'ITA', '5', top1.Id, ownerId); 

        Account top1_middle1_child1 = createAccountWithParent('top1_middle1_child1', 'ITA', '3', top1_middle1.Id, ownerId);
 		Account top1_middle2_child2 = createAccountWithParent('top1_middle2_child2', 'ITA', '3', top1_middle2.Id, ownerId); 

        
        Test.stopTest();


        // Add contact / User middle manager 1
        Contact contact_middlemanager1 = new Contact(
            LastName = 'Middle manager 1'
            ,firstName = 'Test'
            ,Birthdate = system.today()
            ,email = 'middlemanager1@mail.com'
            ,Contact_Type__c= 'Leader'
            ,accountid = top1_middle1.id
            ,TECH_ExternalId__c = 'ITA_123456'
            ,MinOrderFreeTransportFees__c = 10.50
            ,STHID__c = '9898'
            ,ActivityStatus__c = true
            ,Title = 'Animatrice de Secteur'
        );
        Database.insert(contact_middlemanager1); 
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'ITA_LU_Dealer_Manager' Limit 1];
        User user1 = new User(
            Username = 'middlemanager1@test.com',
            ContactId = contact_middlemanager1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'contact_middlemanager1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'contact_middlemanager1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TECH_ExternalId__c = 'ITA_1234567890'
        );
        Database.insert(user1); 

        // Add contact / User middle manager 2
        Contact contact_middlemanager2 = new Contact(
            LastName = 'Middle manager 2'
            ,firstName = 'Test'
            ,Birthdate = system.today()
            ,email = 'middlemanager2@mail.com'
            ,Contact_Type__c= 'Leader'
            ,accountid = top1_middle2.id
            ,TECH_ExternalId__c = 'ITA_1234561'
            ,MinOrderFreeTransportFees__c = 10.50
            ,STHID__c = '98981'
            ,ActivityStatus__c = true
            ,Title = 'Animatrice de Secteur'
        );
        Database.insert(contact_middlemanager2); 
        Profile portalProfile1 = [SELECT Id FROM Profile WHERE Name = 'ITA_LU_Dealer_Manager' Limit 1];
        User user2 = new User(
            Username = 'middlemanager2@test.com',
            ContactId = contact_middlemanager2.Id,
            ProfileId = portalProfile1.Id,
            Alias = 'test1231',
            Email = 'contact_middlemanager2@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'contact_middlemanager2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TECH_ExternalId__c = 'ITA_1234567891'
        );
        Database.insert(user2); 

        // Add contact / User child manager 1
        Contact contact_childmanager1 = new Contact(
            LastName = 'Manager 1'
            ,firstName = 'Test'
            ,Birthdate = system.today()
            ,email = 'contact_childmanager1@mail.com'
            ,Contact_Type__c= 'Leader'
            ,accountid = top1_middle1_child1.id
            ,TECH_ExternalId__c = 'ITA_1234562'
            ,MinOrderFreeTransportFees__c = 10.50
            ,STHID__c = '98982'
            ,ActivityStatus__c = true
            ,Title = 'Animatrice'
        );
        Database.insert(contact_childmanager1); 
        Profile portalProfile3 = [SELECT Id FROM Profile WHERE Name = 'ITA_LU_Dealer_Member' Limit 1];
        User user3 = new User(
            Username = 'contact_childmanager1@test.com',
            ContactId = contact_childmanager1.Id,
            ProfileId = portalProfile3.Id,
            Alias = 'test1231',
            Email = 'contact_childmanager1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'contact_childmanager1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TECH_ExternalId__c = 'ITA_1234567892'
        );
        Database.insert(user3);


        // Execute the batch 
        AP1020_BatchAccountSharing_Step1 batchAccountSharing = new AP1020_BatchAccountSharing_Step1('ITA');
        system.AssertEquals('ITA', batchAccountSharing.country);
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(batchAccountSharing);


        // Test.stopTest();


    }


    static testMethod void createSharingUnitTest_Scheduler() {
        
        AP1020_SC_BatchAccountSharing_FRA SchFRA = new AP1020_SC_BatchAccountSharing_FRA();
        AP1020_SC_BatchAccountSharing_ITA SchITA = new AP1020_SC_BatchAccountSharing_ITA();

        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        // Schedule the batch process using the scheduler sch
        system.schedule('Testing AP1020_SC_BatchAccountSharing_FRA FRA', sch, SchFRA);
        system.schedule('Testing AP1020_SC_BatchAccountSharing_ITA ITA', sch, SchITA);

    }







    /* UTILITY METHODS */
    
    static Integer getShare(Id owner, Id account){
    	
    	List<AccountShare> lists = [select UserOrGroupId from AccountShare where UserOrGroupId =: owner and AccountId =: account];

    	return lists.size();

   
    }
    
     static  User createUser(String sthId){
        
        Profile p = [SELECT id, Name FROM Profile where name = 'FRA_Dealers Manager'].get(0);  
        
        User u = new User( //STHUniqueID__c= sthId,
                          firstname= 'BR04',
                          lastname='XXXX',
                          Alias='BR04',
                          email = 'BR04@XXXXX.com',
                          username= sthId+'BR04@XXXXX.com', 
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles',
                          phone = '123456789'
                         
                          );
        insert u;
                
        return u;
    }
    
    static Account createAccount(String name, String countryCode, String type){
    
        String acc_name = name;
        
        Account acct = new Account(
            name=acc_name, 
            Country_Code__c = countryCode,
            Type = type);
        insert acct;
        
        return acct;
    }

    static Account createAccountWithParent(String name, String countryCode, String type, Id parentId, Id ownerId) {
    
        String acc_name = name;
        
        Account acct = new Account(
            name=acc_name, 
            Country_Code__c = countryCode,
            Type = type,
            ParentId = parentId,
            OwnerId = ownerId);
        insert acct;
        
        return acct;
    }


}