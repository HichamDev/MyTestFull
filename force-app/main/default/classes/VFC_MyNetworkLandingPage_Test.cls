@isTest
public class VFC_MyNetworkLandingPage_Test {
    
     public static testMethod void test_landing(){                
        //Create account
        Account portalAccount1 = new Account(
            Name = 'TestAccount',
            TECH_ACCOwnerExternalId__c = '123456'
        );
        Database.insert(portalAccount1);
      
        //Create contact for the account, which will enable partner portal for account
        Contact contact1 = new Contact(
            LastName = 'Jibz 1'
                           ,firstName = 'Test'
                           ,Birthdate = system.today()
                           ,email = 'jibz1@gmail.com'
                           ,Contact_Type__c='Leader'
                           ,accountid = portalAccount1.id
                           ,TECH_ExternalId__c = '123456'
                           ,MinOrderFreeTransportFees__c = 10.50
                           ,STHID__c = '9898'
            				,ActivityStatus__c = true
        );
        Database.insert(contact1); 
        
        //Create user for the contact
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'FRA_Leader' Limit 1];
        User user1 = new User(
            Username = 'test12345test@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user1); 
        
         List<Contact> childContactList = new list<contact>{
               new Contact(LastName = 'Jibz 2'
                           ,firstName = 'Test'
                           ,Birthdate = system.today()
                           ,email = 'jibz2@gmail.com'
                           ,Contact_Type__c = 'Leader'
                           ,MinOrderFreeTransportFees__c = 111.50
                           ,STHID__c = '8888'
                           ,TECH_ExternalId__c = '9879'
                           ,Parent_STH_Id__c = contact1.id
                           ,ActivityStatus__c = true
                       )

               ,new Contact(LastName = 'Jibz 3'
                           ,firstName = 'Test'
                           ,Birthdate = system.today()
                           ,email = 'jibz3@gmail.com'
                           ,Contact_Type__c = 'Leader'
                           ,MinOrderFreeTransportFees__c = 150.20
                           ,STHID__c = '7777'
                           ,TECH_ExternalId__c = '4567'
                           ,Parent_STH_Id__c = contact1.id
                           ,ActivityStatus__c = true)
            };
            insert childContactList;
         
        system.runAs(user1){
           
            Test.setCurrentPage(Page.VFP_MyNetworkLandingPage);
            test.startTest();
            	
            	VFC_MyNetworkLandingPage controller = new VFC_MyNetworkLandingPage();
            	controller.getContactCoachs();
            	controller.isPortal = true;
            	controller.techExternalIdLvl1 = contact1.TECH_ExternalId__c;
                controller.coachParentName = contact1.Name;
                controller.contactParent = contact1.Id;
                controller.contactId = contact1.id;
                controller.contactFirstName = contact1.firstName;
                controller.contactLastName = contact1.lastName;
                controller.contactName = contact1.name;
                controller.theCoachContactList  = childContactList;
                controller.reportsToId = childContactList;
            	controller.refreshPageMyNetwork();
            test.stopTest();
        }                                
    }
    
    public static testMethod void test_details(){                
        //Create account
        Account portalAccount1 = new Account(
            Name = 'TestAccount',
            TECH_ACCOwnerExternalId__c = '123456'
        );
        Database.insert(portalAccount1);
      
        //Create contact for the account, which will enable partner portal for account
        Contact contact1 = new Contact(
            LastName = 'Jibz 1'
                           ,firstName = 'Test'
                           ,Birthdate = system.today()
                           ,email = 'jibz1@gmail.com'
                           ,Contact_Type__c='Leader'
                           ,accountid = portalAccount1.id
                           ,TECH_ExternalId__c = '123456'
                           ,MinOrderFreeTransportFees__c = 10.50
                           ,STHID__c = '9898'
            				,ActivityStatus__c = true
        );
        Database.insert(contact1); 
        
        //Create user for the contact
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'FRA_Leader' Limit 1];
        User user1 = new User(
            Username = 'test12345test@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user1); 
        
         List<Contact> childContactList = new list<contact>{
               new Contact(LastName = 'Jibz 2'
                           ,firstName = 'Test'
                           ,Birthdate = system.today()
                           ,email = 'jibz2@gmail.com'
                           ,Contact_Type__c = 'Leader'
                           ,MinOrderFreeTransportFees__c = 111.50
                           ,STHID__c = '8888'
                           ,TECH_ExternalId__c = '9879'
                           ,Parent_STH_Id__c = contact1.id
                           ,ActivityStatus__c = true
                       )

               ,new Contact(LastName = 'Jibz 3'
                           ,firstName = 'Test'
                           ,Birthdate = system.today()
                           ,email = 'jibz3@gmail.com'
                           ,Contact_Type__c = 'Leader'
                           ,MinOrderFreeTransportFees__c = 150.20
                           ,STHID__c = '7777'
                           ,TECH_ExternalId__c = '4567'
                           ,Parent_STH_Id__c = contact1.id
                           ,ActivityStatus__c = true)
            };
            insert childContactList;
         
        system.runAs(user1){
           
            Test.setCurrentPage(Page.VFP_MyNetworkLandingPage);
            System.currentPageReference().getParameters().put('id', contact1.Id);
            test.startTest();
            	
            	VFC_MyNetworkContactDetails controller = new VFC_MyNetworkContactDetails();
            	controller.cancel();
            	
            test.stopTest();
        }                                
    }
 
}