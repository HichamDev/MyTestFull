@isTest
private class AP22_WeeklyActivity_Test {
/*
// AP22_WeeklyActivity_Test
----------------------------------------------------------------------
-- - Name          : AP22_WeeklyActivity_Test
-- - Author        : YGO
-- - Description   : 
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 04-OCT-2013  YGO    1.0      Intitial version
----------------------------------------------------------------------
**********************************************************************
*/
     static List<Account> accountList;
     static List<Contact> contactList;
     static List<User> userList;
     static List<ART_Article__c> articleList;
     static List<KIT_Kit__c> kitList;
     static List<CAT_Catalog__c> catalogueList;
     static List<CTA_CatalogArticle__c> catArticleList;
     static List<WAT_WeeklyActivity__c> weeklyActList;
     static Id contactDealerRecordTypeID, DealerProfileId, offerRecordTypeID, bundleRecordTypeID, productRecordTypeID, DealerManagerProfileId, RoleUser;
    
     static
     {
        System.Debug('## >>>>> Start VFC01_WeeklyActivityListView_TEST >>> Inserting Data for Tests <<<<<'+UserInfo.getUserName());
        
        //Retrieving Record Type related to Contact
        contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
        system.debug('>>>>>> contactDealerRecordTypeID : ' + contactDealerRecordTypeID);
        
        //Retrieving Record Type related to Article
        //Offer
        offerRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00001 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Bundle
        bundleRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00002 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Product
        productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        
        //Retrieving Profile Ids
        DealerProfileId = [select id from Profile where Name= :system.label.CON00001].Id;
        DealerManagerProfileId = [select id from Profile where Name= :'FRA_Dealers Manager'].Id;
        
        system.debug('>>>>>> DealerProfileId : ' + DealerProfileId);
        
        //Creating new accounts
        accountList = new List<Account>{
            new Account(Name='AccountTest1'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test1'
                        , Country_Code__c = 'FRA'),
            new Account(Name='AccountTest2'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test2'
                        , Country_Code__c = 'FRA')
        };
        insert (accountList);
        system.debug('>>>>>> accountList : ' + accountList);
        
        //Creating new contacts
        contactList = new List<Contact>{
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest1'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , STHID__c = 'test1'
                        , AccountId = accountList[0].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , ActivityStatus__c = true),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest2'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test2.com'
                        , STHID__c = 'test2'
                        , AccountId = accountList[1].id
                        , CurrentBalance__c = -5
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , ActivityStatus__c = true)         
        };
        insert (contactList);
        system.debug('>>>>>> contactList : ' + contactList);
        
        //Creating new users
        userList = new List<User>{
            new User(Username ='testemail1111@test.com'
                     , LastName = 'TestLastName1'
                     , Email = 'TestEmail1@test.com'
                     , alias = 'testAl1'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerManagerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , Phone = '123456789'),
            new User(Username ='testemail22222@test.com'
                     , LastName = 'TestLastName2'
                     , Email = 'TestEmail2@test.com'
                     , alias = 'testAl2'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerManagerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , Phone = '123456789')      
        };
        
        insert (userList);
        system.debug('>>>>>> userList : ' + userList);
        
        accountList[1].OwnerId = userList[1].id;
        update accountList[1];
        
        weeklyActList = new List<WAT_WeeklyActivity__c>{
            new WAT_WeeklyActivity__c(dealer__c = contactList[0].id
                                      , Name = 'Test0'
                                      , NbrOfMeetings__c = 1
                                      , AvgNbrAttendees__c = 1
                                      , AvgSales__c = 100)
            ,new WAT_WeeklyActivity__c(dealer__c = contactList[1].id
                                      , Name = 'Test1'
                                      , NbrOfMeetings__c = 1
                                      , AvgNbrAttendees__c = 1
                                      , AvgSales__c = 100)
            ,new WAT_WeeklyActivity__c(dealer__c = contactList[0].id
                                      , Name = 'Test2'
                                      , NbrOfMeetings__c = 1
                                      , AvgNbrAttendees__c = 1
                                      , AvgSales__c = 100)
        };
        insert (weeklyActList);
        system.debug('>>>>>> weeklyActList : ' + weeklyActList);
    } // static

    static testMethod void InitialiseApproverAndStatusTest() 
    {
        system.debug('>>>>>> Start Test method InitialiseApproverAndStatus <<<<<<');
       // insert (userList);
      //  system.runAs(userList[1]){
            /*insert (accountList);
            insert (contactList);
            
            accountList[1].OwnerId = userList[1].id;
            update accountList[1];*/
            
            
            system.debug('>>>>>> InitialiseApproverAndStatusTest - accountList : ' + accountList);
            list<WAT_WeeklyActivity__c> selectedWatList = new list<WAT_WeeklyActivity__c>();
            List<WAT_WeeklyActivity__c> watList = new List<WAT_WeeklyActivity__c>{
            new WAT_WeeklyActivity__c(dealer__c = contactList[0].id
                                      , Name = 'Test'
                                      , NbrOfMeetings__c = 1
                                      , AvgNbrAttendees__c = 1
                                      , AvgSales__c = 100)
            };
            
            test.startTest();
                 insert(watList);
            test.stopTest();
        
        
        
        selectedWatList = [select Approver__c, Status__c, id, Name from WAT_WeeklyActivity__c where id=: watList[0].id limit 1];
        //system.assertequals(userInfo.getUserId(), selectedWatList[0].Approver__c);
        system.assertequals('Draft', selectedWatList[0].Status__c);
       //   } // system.runAs(userList[1])
    } // InitialiseApproverAndStatus
    
   static testMethod void updateApproverOnContactChangeTest() 
    {
        system.debug('>>>>>> Start Test method updateApproverOnContactChangeTest <<<<<<');
        
        contactList[0].AccountId = accountList[1].id;
        contactList[1].AccountId = accountList[0].id;
        
        test.startTest();
            update contactList;
        test.stopTest();
        
        system.debug('>>>>>>### updateApproverOnContactChangeTest - contactList '+contactList);
        //system.assertEquals(pANY, )
        system.debug('>>>>>> new  weeklyActList : ' + weeklyActList);
        system.debug('>>>>>> End Test method updateApproverOnContactChangeTest <<<<<<');
     } // end of  InitialiseApproverAndStatusTest
}