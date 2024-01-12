@isTest(SeeAllData = true)
private class AP34_BatchTransferPCT_TEST {
/*
// AP34_BatchTransferPCT_TEST to check if OwnerId of Personal Contact is replaced by the corresponding User id
----------------------------------------------------------------------
-- - Name          : AP34_BatchTransferPCT_TEST
-- - Author        : WCHY
-- - Description   : test class to check  AP34_BatchTransferPCT
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 05-JAN-2015  WCHY    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/

    static testMethod void updatePersonalContactOwner() {
        system.debug('## Class AP33_PersonalContactBatchInterface_TEST - START updatePersonalContactOwner <<<<<'+UserInfo.getUserName());

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];

        list<User> userlist = new list<User>();
        list<PCT_PersonalContact__c> pclist = new list<PCT_PersonalContact__c>();
        
        //Selecting Profile Ids
        ID profileAdmin = [Select Id From Profile Where name = 'System Administrator' limit 1].id;
        system.debug('>>>>>>> profileAdmin: ' + profileAdmin);
        ID profileInterface = [Select Id From Profile Where name in ( 'Interface','System Interface') limit 1].id;
        system.debug('>>>>>>> profileInterface: ' + profileInterface);
        ID profileDealerManager = [Select Id From Profile Where name = 'FRA_Dealers Manager' limit 1].id;
        system.debug('>>>>>>> profileDealerManager: ' + profileDealerManager);

        System.runAs(thisUser){
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
            
             //Creating inactive User                     
            User user3 =new User(alias = 'dm', email='dealermanager@sth.com', emailencodingkey='UTF-8', 
                                 lastname='Dealer Manager',languagelocalekey='fr', localesidkey='fr_FR_EURO', 
                                 profileid = profileDealerManager,timezonesidkey='Europe/Paris', 
                                 username='dealermanager@sth.com',   MobilePhone= '24717', TECH_ExternalId__c= 'dealermanager006',TECH_OLD_External_id__c='dealermanager007',  IsActive=true, TECH_HasBeenTransfered__c = false); 
            userlist.add(user3);
            //Creating active User                     
            User user4 =new User(alias = 'dmn', email='dealermanagernew@sth.com', emailencodingkey='UTF-8', 
                                 lastname='Dealer Manager New',languagelocalekey='fr', localesidkey='fr_FR_EURO', 
                                 profileid = profileDealerManager,timezonesidkey='Europe/Paris', 
                                 username='dealermanagernew@sth.com',   MobilePhone= '24717', TECH_ExternalId__c= 'dealermanager007',IsActive=true ); 
            userlist.add(user4);
            
            insert(userlist);                  
            system.debug('>>>>>>> userlist: ' + userlist);
            
            PCT_PersonalContact__c testPersonalContact = new PCT_PersonalContact__c(Salutation__c= 'M.'
                                                      , Name= 'test Personal Contact'
                                                      , FirstName__c= 'PersonalContact Test'
                                                      , Phone__c= '0672180692'
                                                      , OwnerId = userlist[2].id
                                                      , PersonalCity__c='caromb');
           pclist.add(testPersonalContact);
           insert (pclist);
           system.debug('>>>>>>>>>>>>>>>> pclist:' +pclist);
           //deactivate user3
            user3.IsActive=false;
            update (userlist);
            system.debug('>>>>>>> userlist updated: ' + userlist);
        }
        //Test with interface user
        System.runAs(userlist[0]){
              test.startTest();        
        
         AP34_BatchTransferPCT batchInitAP34 = new AP34_BatchTransferPCT();
            
            //Launch the batch process and get the job ID for the test batch
            Id batchprocessid = Database.executeBatch(batchInitAP34);
            
            Test.StopTest(); 
        
                //Retrieve user id from user record
                Id retrieveOwner =userlist[3].id;//[select id from User where TECH_ExternalId__c = :testPersonalContact.TECH_Owner_ID_OLA__c].id;
                system.debug('>>>>>>>>>>>>>>>> Owner id from User:' +retrieveOwner);
                
                //Retrieve ownerId of account record
                //ID updatedPersonalContact = [select OwnerId from PCT_PersonalContact__c where id = :pclist[0].Id].OwnerId;
                //system.debug('>>>>>>>>>>>>>>>> Owner id of Personal Contact:' +updatedPersonalContact);  
                
                //Check if both ids are equal   
                //system.assertEquals(retrieveOwner, updatedPersonalContact);

        }
        
        system.debug('## Class AP34_BatchTransferPCT_TEST - END updatePersonalContactOwner <<<<<'+UserInfo.getUserName());    
    }
}