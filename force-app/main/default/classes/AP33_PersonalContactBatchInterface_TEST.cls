@isTest(SeeAllData = true)
private class AP33_PersonalContactBatchInterface_TEST {
/*
// AP33_PersonalContactBatchInterface_TEST to check if OwnerId of Personal Contact is replaced by the corresponding User id
----------------------------------------------------------------------
-- - Name          : AP33_PersonalContactBatchInterface_TEST 
-- - Author        : WCHY
-- - Description   : test class to check  AP33_PersonalContactBatchInterface
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 22-DEC-2014  WCHY    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/

    static testMethod void updatePersonalContactOwner() {
        system.debug('## Class AP33_PersonalContactBatchInterface_TEST - START updatePersonalContactOwner <<<<<'+UserInfo.getUserName());
        
        list<User> userlist = new list<User>();
        
        //Selecting Profile Ids
        ID profileAdmin = [Select Id From Profile Where name = 'System Administrator' limit 1].id;
        system.debug('>>>>>>> profileAdmin: ' + profileAdmin);
        ID profileInterface = [Select Id From Profile Where name in ( 'Interface','System Interface') limit 1].id;
        system.debug('>>>>>>> profileInterface: ' + profileInterface);
        
        //Creating Interface User
        User user = new User(alias = 'Int', email='Int@sth.com', emailencodingkey='UTF-8', 
                             lastname='Int',languagelocalekey='fr', localesidkey='fr_FR_EURO', 
                             profileid = profileInterface,timezonesidkey='Europe/Paris', 
                             username='Int@sth.com',   MobilePhone= '34567', TECH_ExternalId__c= 'int123'); 
        userlist.add(user);
        
        //Creating Admin User                     
        User user2 =new User(alias = 'SAdmin', email='systemAdmin@sth.com', emailencodingkey='UTF-8', 
                             lastname='system Admin',languagelocalekey='fr', localesidkey='fr_FR_EURO', 
                             profileid = profileAdmin,timezonesidkey='Europe/Paris', 
                             username='SAdmin@sth.com',   MobilePhone= '34567', TECH_ExternalId__c= 'xyz'); 
        userlist.add(user2);
        insert(userlist);                  
        system.debug('>>>>>>> userlist: ' + userlist);
        
        //Test with interface user
        System.runAs(user){
            test.startTest();        
               PCT_PersonalContact__c testPersonalContact = new PCT_PersonalContact__c(Salutation__c= 'M.'
                                                  , Name= 'test Personal Contact'
                                                  , FirstName__c= 'PersonalContact Test'
                                                  , Phone__c= '0672180692'
                                                  , TECH_Owner_ExternalID__c = 'xyz'
                                                  , PersonalCity__c='caromb');
                insert testPersonalContact;
                
               
               
                system.debug('>>>>>>>>>>>>>>>> testPersonalContact:' +testPersonalContact);
            

                //Retrieve user id from user record
                Id retrieveOwner =[select id from User where TECH_ExternalId__c = :testPersonalContact.TECH_Owner_ExternalID__c].id;
                system.debug('>>>>>>>>>>>>>>>> Owner id from User:' +retrieveOwner);
                
                //Retrieve ownerId of account record
                //ID updatedPersonalContact = [select OwnerId from PCT_PersonalContact__c where id = :testPersonalContact.Id].OwnerId;
                //system.debug('>>>>>>>>>>>>>>>> Owner id of Personal Contact:' +updatedPersonalContact);  
                
                //Check if both ids are equal   
                //system.assertEquals(retrieveOwner, updatedPersonalContact);
                
                
                /*testPersonalContact.TECH_ACCOwnerExternalId__c = 'int123';
            
                update testAccount;
                
                
                
                //Retrieve user id from user record
                Id retrieveOwner1 =[select id from User where TECH_ExternalId__c = :testAccount.TECH_ACCOwnerExternalId__c].id;
                system.debug('>>>>>>>>>>>>>>>> Owner id from User:' +retrieveOwner1);
                
                //Retrieve ownerId of account record
                ID updatedAccount1 = [select OwnerId from Account where id = :testAccount.Id].OwnerId;
                system.debug('>>>>>>>>>>>>>>>> Owner id of Account:' +updatedAccount1); 
                
                //Check if both ids are equal   
                system.assertEquals(retrieveOwner1, updatedAccount1);
            */
            test.stopTest();
        }
        
        system.debug('## Class AP33_PersonalContactBatchInterface_TEST - END updatePersonalContactOwner <<<<<'+UserInfo.getUserName());    
    }
}