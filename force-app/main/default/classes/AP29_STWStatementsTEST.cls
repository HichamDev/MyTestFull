@isTest
private class AP29_STWStatementsTEST{
/*
// AP29_STWStatements
---------------------------------------------------------------------
-- - Name          : AP29_STWStatementsTEST
-- - Author        : YGO
-- - Description   : Test class to create and update statements
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  --------------------------------------
-- 13-MAY-2013  YGO    1.0      Initial version 
---------------------------------------------------------------------
**********************************************************************
*/
  static list<Account> accountList;
    static list<Contact> contactList;
    static list<User> userList;
    static list<ORD_Order__c> orderList;
    static list<ORL_OrderLine__c> orderLineList;
    static list<ART_Article__c> articleList;
    static ORL_OrderLine__c orderLine;
    
    static Id contactDealerRecordTypeID, DealerProfileId, offerRecordTypeID, bundleRecordTypeID, productRecordTypeID;
    
    static {
        System.Debug('## >>>>> Start AP29_STWStatementsTEST >>> Inserting Data for Tests <<<<<'+UserInfo.getUserName());
        
        //Retrieving Record Type related to Contact
        contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
        system.debug('>>>>>> contactDealerRecordTypeID : ' + contactDealerRecordTypeID);
       
        //Retrieving Profile Ids
        DealerProfileId = [select id from Profile where Name= :system.label.CON00001].Id;
        system.debug('>>>>>> DealerProfileId : ' + DealerProfileId);
        
        productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Bundle
        bundleRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00002 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Creating new accounts
        accountList = new List<Account>{
            new Account(Name='AccountTest1'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test1'
                        , Country_Code__c ='FRA'
                        ),
            new Account(Name='AccountTest2'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test2'
                        , Country_Code__c = 'FRA'
                        )
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
             , MinOrderFreeTransportFees__c=50),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest2'
                        , Birthdate = system.Today() - 7300
                        , email = 'a@test2.com'
                        , STHID__c = 'test2'
                        , AccountId = accountList[1].id
                        , CurrentBalance__c = -5
                        , MinOrder__c=50
             , MinOrderFreeTransportFees__c=50),
       new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest2'
                        , Birthdate = system.Today() - 7300
                        , email = 'a@test3.com'
                        , STHID__c = 'test3'
                        , AccountId = accountList[1].id
                        , CurrentBalance__c = -5
                        , MinOrder__c=50
             , MinOrderFreeTransportFees__c=50) 
             
                     
        };
        insert (contactList);
        system.debug('>>>>>> contactList : ' + contactList);
        
        articleList = new List<ART_Article__c>{
            new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[0]
                               , Name = 'Shampoo1'
                               , LocalName__c = 'Shampoo1'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[1]
                                , Name = 'Shampoo2'
                                , LocalName__c = 'Shampoo2'),
            new ART_Article__c(RecordTypeId = productRecordTypeID  //articleList[2]
                               , Name = 'Gel1'
                               , LocalName__c = 'Gel1'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[3]
                                , Name = 'Gel2'
                                , LocalName__c = 'Gel2'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[4]
                                , Name = 'Deo1'
                                , LocalName__c = 'Deo1'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[4]
                                , Name = 'Deo1'
                                , LocalName__c = 'Deo1'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[4]
                                , Name = 'Deo1'
                                , LocalName__c = 'Deo1')                               
                                
        }; 
        insert(articleList);
        
        /*
        //Creating new users
        userList = new List<User>{
            new User(Username ='testemail1@test.com'
                     , LastName = 'TestLastName1'
                     , Email = 'TestEmail1@test.com'
                     , alias = 'testAl1'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Phone = '123456860'
                     , Localesidkey='en_US'
                     , ContactId = contactList[0].Id),
            new User(Username ='testemail2@test.com'
                     , LastName = 'TestLastName1'
                     , Email = 'TestEmail2@test.com'
                     , alias = 'testAl2'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerProfileId
                     , Phone = '123456860'
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , ContactId = contactList[1].Id)        
        };
        insert (userList);
        system.debug('>>>>>> userList : ' + userList);*/
        
        orderList = new list<ORD_Order__c>{
                  new ORD_Order__c(Dealer__c = contactList[0].id,
                           Status__c = 'Draft'),
                  new ORD_Order__c(Dealer__c = contactList[1].id,
                           Status__c = 'Draft'),
                  new ORD_Order__c(Dealer__c = contactList[2].id,
                           Status__c = 'Draft')
                           };
        insert (orderList);
        // TODO Multi LP
       orderLineList = new list<ORL_OrderLine__c>{
                  new ORL_OrderLine__c(Article__c = articleList[0].id,
                             LPAmount__c = '16.2',
                             LPCode__c = 'LP1',
                             Order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2;20',
                             LPCode__c = 'LP2;LP6',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '20.2;10.0',
                             LPCode__c = 'LP4',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '20.2;10.0',
                             LPCode__c = 'LP3',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '20.2;10.0',
                             LPCode__c = 'LP4,LP2',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP5',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP7',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP8',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP9',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP10',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP11',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP12',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP13',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP14',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP15',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP16',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP17',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP18',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP19',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[1].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP20',
                             order__c = orderList[0].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[5].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP20',
                             order__c = orderList[2].id,
                             TECH_OrderStatus__c = 'Draft'),
                             new ORL_OrderLine__c(Article__c = articleList[5].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'Com',
                             order__c = orderList[2].id,
                             TECH_OrderStatus__c = 'Draft'),
                             new ORL_OrderLine__c(Article__c = articleList[5].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'Adm',
                             order__c = orderList[2].id,
                             TECH_OrderStatus__c = 'Draft'),
                  new ORL_OrderLine__c(Article__c = articleList[6].id,
                             LPAmount__c = '18.2',
                             LPCode__c = 'LP20',
                             order__c = orderList[2].id,
                             TECH_OrderStatus__c = 'Draft')
                           };
    }// static
  
    static testMethod void insertNewStatementTest()
    {
      system.debug('>>>>Start insertNewStatementTest<<<<<<');
      insert orderLineList;
      for (integer i=0; i<orderLineList.size(); i++)
      {
        orderLineList[i].TECH_OrderStatus__c = 'Pending';
      }
      
      test.startTest();
      update orderLineList;
      test.stopTest();
      
      STA_Statement__c statement1 = new STA_Statement__c();
      statement1 = [select AmountLP1__c, OrderLine__c from STA_Statement__c where OrderLine__c =: orderLineList[0].id limit 1];
      
      STA_Statement__c statement2 = new STA_Statement__c();
      //statement2 = [select AmountLP2__c, OrderLine__c from STA_Statement__c where OrderLine__c =: orderLineList[1].id limit 1];
      
      list<STA_Statement__c> stmList = new list<STA_Statement__c>();
      stmList = [select OrderLine__c from STA_Statement__c where OrderLine__c =: orderLineList[1].id];
                                 
      system.assertequals(statement1.AmountLP1__c, 16.2);
      //system.assertequals(statement2.AmountLP2__c, 18.2);
      
      system.assertequals(stmList.size(), 2);
      
      system.debug('>>>>End insertNewStatementTest<<<<<<');
    }
   
    static testMethod void deleteStatementTest()
    {
      // TODO Multi LP
      insert orderLineList;
      
      orderLineList[0].LPCode__c = null;
      orderLineList[0].LPAmount__c = null;
      
      test.startTest();
      update orderLineList[0];
      test.stopTest();
      
      list<STA_Statement__c> statementListTest1 = new list<STA_Statement__c>();
      statementListTest1 = [select AmountLP1__c, OrderLine__c from STA_Statement__c where OrderLine__c =: orderLineList[0].id];
        
      system.assertEquals(statementListTest1.size(), 0);
      
    }
   
    static testMethod void deleteOrderLineTest()
    {  
      
      insert orderLineList;
      
      list<STA_Statement__c> statementList = new list<STA_Statement__c>{
              new STA_Statement__c (
                            Type__c =  'Balance' ,
                            Contact__c= contactList[0].Id,
                            OrderLine__c = orderLineList[2].Id,
                            TECH_ExternalId__c = orderLineList[2].Id
              ),    
                        new STA_Statement__c (
                            Type__c =  'Balance' ,
                            Contact__c= contactList[0].Id,
                            OrderLine__c = orderLineList[2].Id,
                            TECH_ExternalId__c = orderLineList[2].Id
              ) 
      
      };
        insert statementList;
      
      
      test.startTest();
      delete orderLineList[2];
      test.stopTest();
      
      list<STA_Statement__c> statementListTest = new list<STA_Statement__c>();
      statementListTest = [select AmountLP1__c, OrderLine__c from STA_Statement__c where OrderLine__c =: orderLineList[2].id];
      
      system.assertEquals(statementListTest.size(), 0);
    }
    
    /*
    static testMethod void updateStatementTest()
    {
      system.debug('>>>>Start updateStatement<<<<<<');
      insert orderLineList;
      
      //orderLineList[0].LPCode__c = 'LP3';
      // TODO Multi LP
      orderLineList[1].LPAmount__c = '10.05;20';
      orderLineList[1].TECH_OrderStatus__c = 'Pending'; 
      
      test.startTest();
      update orderLineList[1];
      test.stopTest();
      
      for(integer a=0; a<orderLineList.size(); a++)
      {
        system.debug('### orderLineList ' + a + orderLineList[a]);
      }

      STA_Statement__c statement1 = new STA_Statement__c();
      //statement1 = [select AmountLP3__c, OrderLine__c from STA_Statement__c where OrderLine__c =: orderLineList[0].id limit 1];
      
      //system.debug('### Statement1 : '+ statement1);
      
      list<STA_Statement__c> statement2 = new list<STA_Statement__c>();
      statement2 = [select AmountLP2__c, OrderLine__c from STA_Statement__c where OrderLine__c =: orderLineList[1].id and AmountLP2__c != null  limit 1];
      system.debug('### Statement2 : '+ statement2.size());
      for(integer a=0; a<statement2.size(); a++)
      {
        system.debug('### statement2 ' + a + statement2[a]);
      }
                         
      //system.assertequals(statement1.AmountLP3__c, 16.2);
      system.assertequals(statement2[0].AmountLP2__c, 10.05);
      
      system.debug('>>>>End updateStatement<<<<<<');
    }
    */
    static testMethod void updateStatementOrderTest()
    {
      insert orderLineList;
      for(integer i=0; i<orderLineList.size(); i++)
      {
        //orderLineList[i].TECH_OrderStatus__c = 'Pending';
      }
      
      update orderLineList;
      orderList[0].Status__c = 'Pending';
      
      test.startTest();
      update orderList[0];
      system.debug('### Order updated: ' + orderList[0].Status__c);
      test.stopTest();
      
      list<STA_Statement__c> statementList = new list<STA_Statement__c>();
      statementList = [select Status__c, OrderLine__c from STA_Statement__c where  OrderLine__c=: orderLineList[0].id limit 1];
      
      system.debug('#### statement1.Status__c: '+ statementList[0].status__c);
      
      //system.assertEquals(statementList[0].status__c, 'Pending');
    } 
    
    static testMethod void updateStatementTest()
    {
      string sta_LoyaltyProgRecTypeId =  [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.STA_LoyaltyProgramRecType and SObjectType = 'STA_Statement__c' Limit 1].id;
      
      
      
      list<STA_Statement__c> statementList = new list<STA_Statement__c>{
              new STA_Statement__c (
                            Type__c =  'Balance' ,
                            Contact__c= contactList[0].Id,
                            RecordTypeId = sta_LoyaltyProgRecTypeId,
                            Amount__c =  1 ,
                            AmountLP9__c =  1  ,
                            AmountLP8__c = 1  ,
                            AmountLP7__c =1,
                            AmountLP6__c = 1,
                            AmountLP5__c = 1,
                            AmountLP4__c =1,
                            AmountLP3__c = 1 ,
                            AmountLP2__c = 1,
                            AmountLP20__c = 1 ,
                            AmountLP1__c =  1,
                            AmountLP19__c =1 ,
                            AmountLP18__c = 1 ,
                            AmountLP17__c = 1 ,
                            AmountLP16__c = 1 ,
                            AmountLP15__c = 1 ,
                            AmountLP14__c =  1,
                            AmountLP13__c =  1,
                            AmountLP12__c =  1,
                            AmountLP11__c =  1 ,
                            AmountLP10__c = 1 ,
                            AmountCommissions__c =  1,
                            AmountAdminFees__c =  1
              ),    
                        new STA_Statement__c (
                            Type__c =  'Balance' ,
                            Contact__c= contactList[0].Id,
                            RecordTypeId = sta_LoyaltyProgRecTypeId,
                            Amount__c =  2 ,
                            AmountLP9__c =  2  ,
                            AmountLP8__c = 2  ,
                            AmountLP7__c =2,
                            AmountLP6__c = 2,
                            AmountLP5__c = 2,
                            AmountLP4__c =2,
                            AmountLP3__c = 2 ,
                            AmountLP2__c = 2,
                            AmountLP20__c = 2 ,
                            AmountLP1__c =  2,
                            AmountLP19__c =2 ,
                            AmountLP18__c = 2 ,
                            AmountLP17__c = 2 ,
                            AmountLP16__c = 2 ,
                            AmountLP15__c = 2 ,
                            AmountLP14__c =  2,
                            AmountLP13__c =  2,
                            AmountLP12__c =  2,
                            AmountLP11__c =  2 ,
                            AmountLP10__c = 2 ,
                            AmountCommissions__c =  2,
                            AmountAdminFees__c =  2
              ),    
                        new STA_Statement__c (
                            Type__c =  'Transaction' ,
                            Contact__c= contactList[0].Id,
                            RecordTypeId = sta_LoyaltyProgRecTypeId,
                            Amount__c =  2 ,
                            AmountLP9__c =  2  ,
                            AmountLP8__c = 2  ,
                            AmountLP7__c =2,
                            AmountLP6__c = 2,
                            AmountLP5__c = 2,
                            AmountLP4__c =2,
                            AmountLP3__c = 2 ,
                            AmountLP2__c = 2,
                            AmountLP20__c = 2 ,
                            AmountLP1__c =  2,
                            AmountLP19__c =2 ,
                            AmountLP18__c = 2 ,
                            AmountLP17__c = 2 ,
                            AmountLP16__c = 2 ,
                            AmountLP15__c = 2 ,
                            AmountLP14__c =  2,
                            AmountLP13__c =  2,
                            AmountLP12__c =  2,
                            AmountLP11__c =  2 ,
                            AmountLP10__c = 2 ,
                            AmountCommissions__c =  2,
                            AmountAdminFees__c =  2
              ) 
      
      
      
      
      };
        insert statementList;
      system.debug('### statementList : ' + statementList);
      
      test.startTest();
          statementList[0].Amount__c =  null;
            statementList[0].AmountLP9__c =  null;
            statementList[0].AmountLP8__c = null;
            statementList[0].AmountLP7__c =null;
            statementList[0].AmountLP6__c = null;
            statementList[0].AmountLP5__c = null;
            statementList[0].AmountLP4__c =null;
            statementList[0].AmountLP3__c = null;
            statementList[0].AmountLP2__c = null;
            statementList[0].AmountLP20__c = null;
            statementList[0].AmountLP1__c =  null;
            statementList[0].AmountLP19__c =null;
            statementList[0].AmountLP18__c = null;
            statementList[0].AmountLP17__c = null;
            statementList[0].AmountLP16__c = null;
            statementList[0].AmountLP15__c = null;
            statementList[0].AmountLP14__c =  null;
            statementList[0].AmountLP13__c =  null;
            statementList[0].AmountLP12__c =  null;
            statementList[0].AmountLP11__c =  null;
            statementList[0].AmountLP10__c = null;
            statementList[0].AmountCommissions__c =  null;
            statementList[0].AmountAdminFees__c =null;
        
          //second statement
           statementList[1].Amount__c =  10;
            statementList[1].AmountLP9__c =  10;
            statementList[1].AmountLP8__c = 10;
            statementList[1].AmountLP7__c =50;
            statementList[1].AmountLP6__c = 10;
            statementList[1].AmountLP5__c = 10;
            statementList[1].AmountLP4__c =10;
            statementList[1].AmountLP3__c = 10;
            statementList[1].AmountLP2__c = 10;
            statementList[1].AmountLP20__c = 10;
            statementList[1].AmountLP1__c =  10;
            statementList[1].AmountLP19__c =10;
            statementList[1].AmountLP18__c = 10;
            statementList[1].AmountLP17__c = 10;
            statementList[1].AmountLP16__c = 10;
            statementList[1].AmountLP15__c = 10;
            statementList[1].AmountLP14__c =  10;
            statementList[1].AmountLP13__c =  10;
            statementList[1].AmountLP12__c =  10;
            statementList[1].AmountLP11__c =  10;
            statementList[1].AmountLP10__c = 10;
            statementList[1].AmountCommissions__c =  10;
            statementList[1].AmountAdminFees__c =10;
        
      update statementList;
      system.debug('### statementList updated: ' + statementList);
      test.stopTest();
      
      list<STA_Statement__c> statementListResult = new list<STA_Statement__c>();
      statementListResult = [select AmountLP7__c from STA_Statement__c where  Id IN : statementList];
      
      //system.assertEquals(statementListResult[0].AmountLP7__c, 1);      
      //system.assertEquals(statementListResult[1].AmountLP7__c, 50);
    } 
}