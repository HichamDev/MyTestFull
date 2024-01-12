@isTest(SeeAllData = true)
private class AP09_AccountBatchInterface_TEST {
/*
// AP09_AccountBatchInterface_TEST to check if OwnerId of Account is replaced by the corresponding User id
----------------------------------------------------------------------
-- - Name          : AP09_AccountBatchInterface_TEST
-- - Author        : ASE
-- - Description   : test class to check  AP09_AccountBatchInterface
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 17-SEP-2012  ASE    1.0      Initial version
-- 03-DEC-2012  AMU    1.1      New version after SF review
----------------------------------------------------------------------
**********************************************************************
*/

    static testMethod void updateAccountOwner() {
        system.debug('## Class AP09_AccountBatchInterface_TEST - START updateAccountOwner <<<<<'+UserInfo.getUserName());
        
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
                Account testAccount = new Account(TypeLabel__c= 'test'
                                                  , Name= 'test Account'
                                                  , CurrencyIsoCode= 'EUR'
                                                  , AccountType__c= 'Level 2'
                                                  , TECH_ACCOwnerExternalId__c = 'xyz'
                                                  , Country_Code__c='FRA');
                insert testAccount;
                
               
               
                system.debug('>>>>>>>>>>>>>>>> testAccount:' +testAccount);
            

                //Retrieve user id from user record
                Id retrieveOwner =[select id from User where TECH_ExternalId__c = :testAccount.TECH_ACCOwnerExternalId__c].id;
                system.debug('>>>>>>>>>>>>>>>> Owner id from User:' +retrieveOwner);
                
                //Retrieve ownerId of account record
                //ID updatedAccount = [select OwnerId from Account where id = :testAccount.Id].OwnerId;
                //system.debug('>>>>>>>>>>>>>>>> Owner id of Account:' +updatedAccount);  
                
                //Check if both ids are equal   
                //system.assertEquals(retrieveOwner, updatedAccount);
                
                
                testAccount.TECH_ACCOwnerExternalId__c = 'int123';
            
                update testAccount;
                
                
                
                //Retrieve user id from user record
                Id retrieveOwner1 =[select id from User where TECH_ExternalId__c = :testAccount.TECH_ACCOwnerExternalId__c].id;
                system.debug('>>>>>>>>>>>>>>>> Owner id from User:' +retrieveOwner1);
                
                //Retrieve ownerId of account record
                ID updatedAccount1 = [select OwnerId from Account where id = :testAccount.Id].OwnerId;
                system.debug('>>>>>>>>>>>>>>>> Owner id of Account:' +updatedAccount1); 
                
                //Check if both ids are equal   
                system.assertEquals(retrieveOwner1, updatedAccount1);
            
            test.stopTest();
        }
        
        system.debug('## Class AP09_AccountBatchInterface_TEST - END updateAccountOwner <<<<<'+UserInfo.getUserName());    
    }
}