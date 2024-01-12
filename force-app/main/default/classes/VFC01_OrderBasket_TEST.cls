@isTest
private class VFC01_OrderBasket_TEST {
/*
// VFC01_OrderBasket_Test_HDU
----------------------------------------------------------------------
-- - Name          : VFC01_OrderBasket_Test_HDU
-- - Author        : Spoon Consulting
-- - Description   : Test method for VFC01_OrderBasket
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 04-OCT-2013  HDU    1.0      Initial version 
---------------------------------------------------------------------
**********************************************************************
*/      

    static List<Account> accountList;
     static List<Contact> contactList;
     static List<User> userList;
     static List<ART_Article__c> articleList;
     static List<KIT_Kit__c> kitList;
     static List<CAT_Catalog__c> catalogueList;
     static List<CTA_CatalogArticle__c> catArticleList;
     static List<CAC_CatalogContact__c> catContactList;
     static List<ORL_OrderLine__c> orderLineList;
     static List<ORD_Order__c> orderList;
     static Id contactDealerRecordTypeID, DealerProfileId, offerRecordTypeID, bundleRecordTypeID, productRecordTypeID;
     
    static VFC01_OrderBasket globalController;
    
    static {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST >>> Inserting Data for Tests <<<<<'+UserInfo.getUserName());
        
        //Retrieving Record Type related to Contact
        contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = 'Dealer' and SObjectType = 'Contact' Limit 1].id;
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
        system.debug('>>>>>> DealerProfileId : ' + DealerProfileId);
        
        //Creating new accounts
        accountList = new List<Account>{
            new Account(Name='AccountTest1'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test1'
                        , Country_Code__c = 'FRA'
                        , WebServiceAvailability__c = true),
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
                        , MinOrder__c=10
                        , MinOrderFreeTransportFees__c=50
                        , LoyaltyProgramToBeDisplayed__c = 'LP1;LP2;lp3;lp4;lp5;lp6;lp7;lp8;lp9;lp10;lp11;lp12;lp13;lp14;lp15;lp16;lp17;lp18;lp19;lp20;Adm;Com'
                        ),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest2'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test2.com'
                        , STHID__c = 'test2'
                        , AccountId = accountList[1].id
                        , CurrentBalance__c = -5
                        , MinOrder__c=10
                        , MinOrderFreeTransportFees__c=50
                        , LoyaltyProgramToBeDisplayed__c = 'LP1;LP2;lp3;lp4;lp5;lp6;lp7;lp8;lp9;lp10;lp11;lp12;lp13;lp14;lp15;lp16;lp17;lp18;lp19;lp20;Adm;Com'
                        ),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTestmodifyTest'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , STHID__c = 'test1'
                        , AccountId = accountList[0].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , LoyaltyProgramToBeDisplayed__c = 'LP1;LP2;lp3;lp4;lp5;lp6;lp7;lp8;lp9;lp10;lp11;lp12;lp13;lp14;lp15;lp16;lp17;lp18;lp19;lp20;Adm;Com'
                        ),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest1'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , STHID__c = 'test1'
                        , AccountId = accountList[0].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=10
                        , MinOrderFreeTransportFees__c=50
                        ,TransportFeesApplicable__c =true
                        , ActivityStatus__c=true
                        , LoyaltyProgramToBeDisplayed__c = 'LP1;LP2;lp3;lp4;lp5;lp6;lp7;lp8;lp9;lp10;lp11;lp12;lp13;lp14;lp15;lp16;lp17;lp18;lp19;lp20;Adm;Com'
                        )           
        };
        insert (contactList);
        system.debug('>>>>>> contactList : ' + contactList);        
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
                     , Localesidkey='en_US'
                     , ContactId = contactList[0].Id),
            new User(Username ='testemail2@test.com'
                     , LastName = 'TestLastName1'
                     , Email = 'TestEmail2@test.com'
                     , alias = 'testAl2'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , ContactId = contactList[1].Id),  
            new User(Username ='testemail3@test.com'
                     , LastName = 'TestLastName3'
                     , Email = 'TestEmail3@test.com'
                     , alias = 'testAl3'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , ContactId = contactList[3].Id)
        };
        insert (userList);
        system.debug('>>>>>> userList : ' + userList);
        
        //Creating new articles
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
            new ART_Article__c (RecordTypeId = offerRecordTypeID //articleList[3]
                                , Name = 'Gel2'
                                , LocalName__c = 'Gel2'),
            new ART_Article__c (RecordTypeId = offerRecordTypeID //articleList[4]
                                , Name = 'Deo1'
                                , LocalName__c = 'Deo1'),
            new ART_Article__c (//Bundle
                                RecordTypeId = bundleRecordTypeID  //articleList[5]
                                , Name = 'ShampooBundle'
                                , LocalName__c = 'ShampooBundle'
                                , Number_of_Articles__c = 2),
            new ART_Article__c (RecordTypeId = bundleRecordTypeID  //articleList[6]
                                , Name = 'GelBundle'
                                , LocalName__c = 'GelBundle'
                                , Number_of_Articles__c = 2),
            new ART_Article__c (//Offer
                                RecordTypeId = bundleRecordTypeID   //articleList[7] 
                                , Name = 'ShampooGelBundle'
                                , LocalName__c = 'ShampooGelBundle'
                                , Number_of_Articles__c = 3),
           new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[8] out of stock
                               , Name = 'Apple'
                               , LocalName__c = 'Apple'
                               , LocalCode__c='134'
                               , OnhandStockStatus__c='Out-of-stock'
                               , ActiveProduct__c=true),
           new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[9] perim?
                               , Name = 'Orange'
                               , LocalName__c = 'Orange'
                               , LocalCode__c='136'
                               , OnhandStockStatus__c='Available'
                               , ActiveProduct__c=true),
          new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[10] OK
                               , Name = 'Banana'
                               , LocalName__c = 'Banana'
                               , LocalCode__c='125'
                               , OnhandStockStatus__c='Available'
                               , ActiveProduct__c=true),
          new ART_Article__c(//Product
                               RecordTypeId = offerRecordTypeID  //articleList[11] OFFER
                               , Name = 'Cherry'
                               , LocalName__c = 'Cherry'
                               , LocalCode__c='707'
                               , OnhandStockStatus__c='Available'
                               , ActiveProduct__c=true),
          new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[12] PRODUCT INACTIVE
                               , Name = 'Grapefruit'
                               , LocalName__c = 'Grapefruit'
                               , LocalCode__c='777'
                               , OnhandStockStatus__c='Available'
                               , ActiveProduct__c=false),
          new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[13] PRODUCT MAX QUANTITY
                               , Name = 'Bitter'
                               , LocalName__c = 'Bitter'
                               , LocalCode__c='902'
                               , OnhandStockStatus__c='Available'
                               , ActiveProduct__c=true)
        }; 
        insert(articleList);
        system.debug('>>>>>> articleList : ' + articleList);
        
        //Creating new catalogue
        catalogueList = new List<CAT_Catalog__c>{
            new CAT_Catalog__c(Account__c = accountList[0].id
                               , Name = 'CatalogueTest1'
                               ,StartDate__c = Date.today().addDays(-20)
                               ,EndDate__c= Date.today().addDays(20))
        };
        insert (catalogueList);
         system.debug('>>>>>> articleList : ' + articleList);
        //Creating new kits
        kitList = new List<KIT_Kit__c>{
            new KIT_Kit__c (ParentArticle__c = articleList[5].Id
                            , Article__c = articleList[0].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 0
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[5].Id
                            , Article__c = articleList[1].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 0
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[6].Id
                            , Article__c = articleList[2].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 1
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[6].Id
                            , Article__c = articleList[3].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 0
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[3].Id
                            , Article__c = articleList[6].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 0
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[4].Id
                            , Article__c = articleList[3].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 0
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[7].Id
                            , Article__c = articleList[5].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 1
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[7].Id
                            , Article__c = articleList[6].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 1
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[4].Id
                            , Article__c = articleList[7].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 1
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[4].Id
                            , Article__c = articleList[0].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 1
                            , MaxQtyOrderable__c = 1)
        };
        insert(kitList);
        system.debug('>>>>>> kitList : ' + kitList);
        //Creating new catalogue
        catalogueList = new List<CAT_Catalog__c>{
            new CAT_Catalog__c(Account__c = accountList[0].id
                               , Name = 'CatalogueTest1'
                               , Active__c = true
                               ,StartDate__c = Date.today().addDays(-20)
                               ,EndDate__c= Date.today().addDays(20))
        };
        insert (catalogueList);
        system.debug('>>>>>> catalogueList : ' + catalogueList);
        
         catArticleList = new List<CTA_CatalogArticle__c>{
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test1'
                                      , Active__c = true
                                      , PublicPrice__c = 1000
                                      , Article__c = articleList[7].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ), 
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test2'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[6].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
           new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test3'
                                      , Active__c = true
                                      , PublicPrice__c = 1000
                                      , Article__c = articleList[5].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ), 
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test4'
                                      , Active__c = true
                                      , PublicPrice__c = 1000
                                      , Article__c = articleList[4].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test5'
                                      , Active__c = true
                                      , PublicPrice__c = 1000
                                      , Article__c = articleList[3].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ), 
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test6'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[2].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test7'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[1].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ), 
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test8'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[0].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
                                      ///MASS ORDER PRODUCTS - OUT OF STOCK
           new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test9'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[8].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
                                      ///MASS ORDER PRODUCTS - PREMIME
           new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test10'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[9].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(-10)
                                      ),
                                      ///MASS ORDER PRODUCTS - OK
           new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test11'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[10].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
                                      ///MASS ORDER PRODUCTS - OFFER
           new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test11'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[11].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
                                      ///MASS ORDER PRODUCTS - PRODUCT INACTIVE
           new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test12'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[12].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      )
                                      ,
                                      ///MASS ORDER PRODUCTS - PRODUCT MAX QUANTITY EXCEEDED
           new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test13'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[13].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,MaximumQuantity__c=1
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20))
        };
        insert(catArticleList);
        system.debug('>>>>>> catArticleList : ' + catArticleList);
        
        catContactList = new List<CAC_CatalogContact__c>{
            new CAC_CatalogContact__c(Catalog__c = catalogueList[0].Id
                                      //, Name = contactList[0].Id
                                      , Active__c = true
                                      , Dealer__c = contactList[0].Id
                                       ),
            new CAC_CatalogContact__c(Catalog__c = catalogueList[0].Id
                                      //, Name = contactList[0].Id
                                      , Active__c = true
                                      , Dealer__c = contactList[3].Id
                                       )
        };
        insert(catContactList);
        system.debug('>>>>>> catContactList : ' + catContactList);
        
        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
                
        ORD_Order__c globalOrderTest = new ORD_Order__c();
        system.runAs(userList[0]){
            //select a product for an order
            PageReference orderPage = Page.VFP01_OrderBasket;
            Test.setCurrentPage( orderPage );
            
            //Instantiate Controller
            ApexPages.StandardController scGlobal = new ApexPages.StandardController(globalOrderTest);
           globalController = new VFC01_OrderBasket(scGlobal);
            
             //Assigning a value to articleName
            globalController.globalArticleNameSearch = updatedCatArticleList[5].Name;//index 1 contain article 'articleList[6]' 
            
            //Calling method ShowArticleDetails
           globalController.ShowArticleDetails();
           
            
            //Calling method AddToBasket
            globalController.AddToBasket();
            globalController.row_index = '1';      
        }//end of system run as
        
         orderList = new List<ORD_Order__c>{
                new ORD_Order__c(dealer__c = contactList[0].id
                                 , Status__c = 'Pending'
                                 , OrderDate__c = system.TODAY())
            };
            insert(orderList);
            
            orderLineList = new List<ORL_OrderLine__c>{
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[3].Id
                                     , PublicPrice__c = 100
                                     , Qty__c = 1
                                     , Amount__c = 200
                                     , TECH_ArticleType__c = 'Master'
                                     , TECH_OrderStatus__c = 'Pending'),
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[0].Id
                                     , PublicPrice__c = 0
                                     , Qty__c = 1
                                     , Amount__c = 200
                                     , TECH_ArticleType__c = 'Child'
                                     , TECH_OrderStatus__c = 'Pending'),
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[1].Id
                                     , PublicPrice__c = 0
                                     , Qty__c = 1
                                     , Amount__c = 200
                                     , TECH_ArticleType__c = 'Child'
                                     , TECH_OrderStatus__c = 'Pending'),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[2].Id
                                     , PublicPrice__c = 0
                                     , Qty__c = 1
                                     , Amount__c = 200
                                     , TECH_ArticleType__c = 'Child'
                                     , TECH_OrderStatus__c = 'Pending'),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[3].Id
                                     , PublicPrice__c = 0
                                     , Qty__c = 1
                                     , Amount__c = 200
                                     , TECH_ArticleType__c = 'Child'
                                     , TECH_OrderStatus__c = 'Pending'),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[4].Id
                                     , PublicPrice__c = 0
                                     , Qty__c = 1
                                     , Amount__c = 200
                                     , TECH_ArticleType__c = 'Child'
                                     , TECH_OrderStatus__c = 'Pending')
            };
            insert(orderLineList);   

                
    }//end of static
    
   //test search for product
    static testMethod void showArticleDetailsTest() {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - showArticleDetailsTest <<<<<'+UserInfo.getUserName());
        
        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        system.runAs(userList[0]){
            system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
            ORD_Order__c newOrder1 = new ORD_Order__c();
            test.startTest();
                PageReference orderPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderPage );
                
                //Instantiate Controller
                ApexPages.StandardController sc1 = new ApexPages.StandardController(newOrder1);
                VFC01_OrderBasket controller = new VFC01_OrderBasket(sc1);
                
                //Assigning a value to articleName
                controller.globalArticleNameSearch = updatedCatArticleList[0].Name;//index 0 contain article 'articleList[7]'
                
                //Calling method ShowArticleDetails
                controller.ShowArticleDetails();
           
                //test.stopTest();
                controller.productDetail.quantity = '10';
                controller.UpdateArticleDetails();
                
                //Calling method AddToBasket
                controller.AddToBasket();         
            
            
            test.stopTest();
                        
       }//end of system.runAs(userList[0])
    }//end of static testMethod void showArticleDetailsTest()
    
    static testMethod void searchAddArticleTest() {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - searchProductTest <<<<<'+UserInfo.getUserName());
        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        system.runAs(userList[0]){
            system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
            ORD_Order__c newOrder1 = new ORD_Order__c();
            test.startTest();
                PageReference orderPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderPage );
                
                //Instantiate Controller
                ApexPages.StandardController sc1 = new ApexPages.StandardController(newOrder1);
                VFC01_OrderBasket controller = new VFC01_OrderBasket(sc1);
                /**************************************/
                /*          article type bundle      */
                /*************************************/
                //Assigning a value to articleName
                controller.globalArticleNameSearch = updatedCatArticleList[7].Name;
                
                //Calling method ShowArticleDetails
                controller.ShowArticleDetails();
                
                //Calling method AddToBasket
                controller.AddToBasket(); 
                /***|---------------------------------|***/
                /***|       article type product      |**/ 
                /***|---------------------------------|*/
                //Assigning a value to articleName
                controller.globalArticleNameSearch = updatedCatArticleList[0].Name;
                
                //Calling method ShowArticleDetails
                controller.ShowArticleDetails();
                
                //Calling method AddToBasket
                controller.AddToBasket();
                
                  /************************************/
                 /*         article type Offer       */
                /************************************/
                //Assigning a value to articleName
                controller.globalArticleNameSearch = updatedCatArticleList[3].Name;//index 0 contain article 'articleList[7]'
                
                //Calling method ShowArticleDetails
                controller.ShowArticleDetails();
                
                //Calling method AddToBasket
                controller.AddToBasket();
                controller.SaveOrderTemp();
                test.stopTest();
                
                
            system.assertEquals(controller.basketDetail.basketDetails.get(0).localName, articleList[0].Name);   
            
        }//end of run as
    System.Debug('## >>>>> End VFC01_OrderBasket_TEST - searchProductTest <<<<<'+UserInfo.getUserName());
    }//end of   searchAddProductTest()
    
    //test search for checkIfHasCatalogueTest
    static testMethod void checkIfHasCatalogueTest() {
        system.runAs(userList[0]){
            test.startTest();
            globalController.checkIfHasCatalogue();
            test.stopTest();
        }//end of run as
    }//end of checkIfHasCatalogueTest
    
     //test search for decrement quantity
    static testMethod void decrementItemTest() {
        system.runAs(userList[0]){
            test.startTest();
            globalController.basketDetail.basketDetails[0].quantity = '5';
            //decrement
            globalController.DecrementItem();
            test.stopTest();
        }//end of run as
    }//end of decrementItemTest()
    
     //test search for increment quantity
    static testMethod void incrementItemTest() {
        system.runAs(userList[0]){
            test.startTest();
            //test for increment
            globalController.IncrementItem();
            test.stopTest();
        }//end of run as
    }//end of incrementItemTest()
    
    //test search for save order
    static testMethod void saveOrderTest() {
        system.runAs(userList[0]){
            test.startTest();
            //test for save
            globalController.SaveOrderTemp();
            test.stopTest();
        }//end of run as
    }//end of saveOrderTest()
   
   //test search for delete save order next step
    static testMethod void saveOrderNextStepTest() {
        system.runAs(userList[0]){
            test.startTest();
            //test for save
            globalController.SaveOrderNextStep();
            test.stopTest();
        }//end of run as
    }//end of saveOrderNextStepTest()
    
    //test search for delete save order next step
    static testMethod void saveOrderNextStepTest2() {
        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        system.runAs(userList[0]){
            system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
            ORD_Order__c newOrder1 = new ORD_Order__c();
            test.startTest();
                PageReference orderPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderPage );
                
                //Instantiate Controller
                ApexPages.StandardController sc1 = new ApexPages.StandardController(newOrder1);
                VFC01_OrderBasket controller = new VFC01_OrderBasket(sc1);
                 
            
                //Assigning a value to articleName
                controller.globalArticleNameSearch = updatedCatArticleList[5].Name;//index 0 contain article 'articleList[7]'
                
                //Calling method ShowArticleDetails
                controller.ShowArticleDetails();
                                
                //Calling method AddToBasket
                controller.AddToBasket();
            controller.basketDetail.totalPriceForValidBase = 50;
           controller.SaveOrderNextStep();
                        
            test.stopTest();
                        
       }//end of system.runAs(userList[0])
    }//end of saveOrderNextStepTest()
    
    
    
    //test search for changeItemNumberTest
    static testMethod void changeItemNumberTest() {
        system.runAs(userList[0]){
            test.startTest();
            //test for save
            globalController.row_index = '50';
            globalController.ChangeItemNumber();
            
            globalController.row_index = '1';
            globalController.basketDetail.basketDetails[0].quantity = '5';
            globalController.ChangeItemNumber();
            
                        
            test.stopTest();
        }//end of run as
    }//end of changeItemNumberTest()
    
    //test search for changeDealerDetailsTest
    static testMethod void changeDealerDetailsTest() {
        system.runAs(userList[0]){
            test.startTest();
            //test for save
            globalController.globalOrder.Dealer__c = contactList[0].Id;
            globalController.ChangeDealerDetails();
            test.stopTest();
        }//end of run as
    }//end of changeDealerDetailsTest(
    
    //test search for changeDealerDetailsTest
    static testMethod void ZonePromoTest() {
        system.runAs(userList[0]){
            test.startTest();
            //test for save
            globalController.globalContact = contactList[0];
            globalController.getZonePromoUrl();
            
            globalController.globalContact = null;
            globalController.getZonePromoUrl();
            
            test.stopTest();
        }//end of run as
    }//end of changeDealerDetailsTest(
    
    //test search for changeDealerDetailsTest
    static testMethod void deleteTest() {
        system.runAs(userList[0]){
            test.startTest();
            //test for delete
            globalController.DeleteOrderLine();
            
            test.stopTest();
        }//end of run as
    }//end of deleteTest(
    /*
     static testMethod void modifyExistingOrderTest() {
          
            
                    
            List <Contact> contactList1 = new List<Contact>{
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTestmodifyTest'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , STHID__c = 'test1'
                        , AccountId = accountList[0].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , LoyaltyProgramToBeDisplayed__c = 'LP1;LP2;lp3;lp4;lp5;lp6;lp7;lp8;lp9;lp10;lp11;lp12;lp13;lp14;lp15;lp16;lp17;lp18;lp19;lp20;Adm;Com'
                        )};
            insert contactList1;
            system.debug('>>>>>>contactList1 ' +contactList1);
            List<ORD_Order__c> orderList = new List<ORD_Order__c>{
                new ORD_Order__c(dealer__c = contactList1[0].id
                                 , Status__c = 'Pending'
                                 , OrderDate__c = system.TODAY())
            };
            insert(orderList);
            
            List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[7].Id
                                     , PublicPrice__c = 100
                                     , Amount__c = 200
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Master'
                                     , TECH_OrderStatus__c = 'Pending'),
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[0].Id
                                     , PublicPrice__c = 0
                                     , Amount__c = 200
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , TECH_OrderStatus__c = 'Pending'),
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[1].Id
                                     , PublicPrice__c = 0
                                     , Amount__c = 200
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , TECH_OrderStatus__c = 'Pending'),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[2].Id
                                     , PublicPrice__c = 0
                                     , Amount__c = 200
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , TECH_OrderStatus__c = 'Pending'),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[3].Id
                                     , PublicPrice__c = 0
                                     , Amount__c = 200
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , TECH_OrderStatus__c = 'Pending'),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[4].Id
                                     , PublicPrice__c = 0
                                     , Amount__c = 200
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , TECH_OrderStatus__c = 'Pending')
            };
            insert(orderLineList);
            system.runAs(userList[0]){
            test.startTest();
                PageReference orderBasketPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderBasketPage );
                
                //Add parameters to page URL
                ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
                ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
                
                //Instantiate Controller
                ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
                VFC01_OrderBasket controller2 = new VFC01_OrderBasket(sc2);
                
                //Call method GetOrderLines
                controller2.SaveOrderNextStep();
                                
                //globalContact.Id
                controller2.globalContact.Id = contactList1[0].Id;
                controller2.ChangeDealerDetails();              
            test.stopTest();
       }//end of system.runAs(userList[0])
    
    
     }
    */
     static testMethod void productTypeOfferTest() {
    //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        system.runAs(userList[0]){
            system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
            ORD_Order__c newOrder1 = new ORD_Order__c();
            test.startTest();
                PageReference orderPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderPage );
                
                //Instantiate Controller
                ApexPages.StandardController sc1 = new ApexPages.StandardController(newOrder1);
                VFC01_OrderBasket controller = new VFC01_OrderBasket(sc1);
                
                //Assigning a value to articleName
                controller.globalArticleNameSearch = updatedCatArticleList[6].Name;//index 0 contain article 'articleList[7]'
                
                //Calling method ShowArticleDetails
                controller.ShowArticleDetails();
                
                
                
                //Calling method AddToBasket
                controller.AddToBasket();
                controller.SaveOrderNextStep();
            test.stopTest();
                        
       }//end of system.runAs(userList[0])
    
    
     }
    static testMethod void productTypeOfferTestandSave() {
   //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        system.runAs(userList[0]){
            system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
            ORD_Order__c newOrder1 = new ORD_Order__c();
            test.startTest();
                PageReference orderPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderPage );
                
                //Instantiate Controller
                ApexPages.StandardController sc1 = new ApexPages.StandardController(newOrder1);
                VFC01_OrderBasket controller2 = new VFC01_OrderBasket(sc1);
                
                //Assigning a value to articleName
                controller2.globalArticleNameSearch = updatedCatArticleList[4].Name;
                System.Debug('## >>>>>VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveTemp() <<<updatedCatArticleList[6].TECH_ArticleRecordType__c<<'+updatedCatArticleList[6].Name);
                
                //Calling method ShowArticleDetails
                controller2.ShowArticleDetails();
                System.Debug('## >>>>>VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveTemp() <<<updatedCatArticleList[6].TECH_ArticleRecordType__c<<'+updatedCatArticleList[6].Name);
                
                //Calling method AddToBasket
                controller2.AddToBasket();
                controller2.globalContact.ActivityStatus__c=true;
                controller2.basketDetail.totalPrice=7;
                controller2.globalContact.MinOrderFreeTransportFees__c=12;
                List<TransportFees__c> transportFeesList = new List<TransportFees__c>{
                  new TransportFees__c(Name = controller2.globalContact.Account.Country_Code__c,  Amount__c=100)
                };
                insert transportFeesList;
                controller2.SaveOrderNextStep();
                System.Debug('## >>>>>VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveTemp() <<<basketDetail.errMsg<<'+controller2.basketDetail.errMsg);
                
            test.stopTest();
                        
       }//end of system.runAs(userList[0])
      }//endOf productTypeOfferTestandSave
    static testMethod void modifyExistingOrderTest() {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - modifyExistingOrderTest() <<<<<'+UserInfo.getUserName());
        List<LP_Reset_Per_Country__c> lpResetList = new List<LP_Reset_Per_Country__c>{
          new LP_Reset_Per_Country__c(Name = 'LP1_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP2_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP3_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP4_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP5_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP6_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP7_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP8_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP9_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP10_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP11_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP12_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP13_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP14_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP15_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP16_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP17_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP18_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP19_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'LP20_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'ADM_FRA',LP_Country__c='FRA',LP_isReset__c=true),
          new LP_Reset_Per_Country__c(Name = 'COM_FRA',LP_Country__c='FRA',LP_isReset__c=true)
        };
        
        insert lpResetList; 

        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        
        system.runAs(userList[0]){
            test.startTest();
                PageReference orderBasketPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderBasketPage );
                
                //Add parameters to page URL
                ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
                ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
                
                //Instantiate Controller
                ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
                VFC01_OrderBasket controller2 = new VFC01_OrderBasket(sc2);
                /**************************************/
                /*          article type bundle      */
                /*************************************/
                //Assigning a value to articleName
                controller2.globalArticleNameSearch = updatedCatArticleList[7].Name;
                
                //Calling method ShowArticleDetails
                controller2.ShowArticleDetails();
                
                //Calling method AddToBasket
                controller2.AddToBasket(); 
                //Call method GetOrderLines
            //  controller2.SaveOrderNextStep();    
                //display currency
                controller2.getNumberCurrencyFormat();
                controller2.row_index='1';
                controller2.DeleteOrderLine();

            test.stopTest();
         }//end of run as
        System.Debug('## >>>>> End VFC01_OrderBasket_TEST - modifyExistingOrderTest() <<<<<'+UserInfo.getUserName());
    }//end of   modifyExistingOrderTest()
    
static testMethod void modifyExistingOrderTestSaveTemp() {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveTemp() <<<<<'+UserInfo.getUserName());

        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        
        system.runAs(userList[0]){
            test.startTest();
                PageReference orderBasketPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderBasketPage );
                
                //Add parameters to page URL
                ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
                ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
                
                //Instantiate Controller
                ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
                VFC01_OrderBasket controller2 = new VFC01_OrderBasket(sc2);
                /**************************************/
                /*          article type bundle      */
                /*************************************/
                //Assigning a value to articleName
                controller2.globalArticleNameSearch = updatedCatArticleList[7].Name;
                
                //Calling method ShowArticleDetails
                controller2.ShowArticleDetails();
                
                //Calling method AddToBasket
                controller2.AddToBasket(); 
                //Call method GetOrderLines
            //  controller2.SaveOrderNextStep();    
                //display currency
                controller2.getNumberCurrencyFormat();
                /*controller2.row_index='1';
                controller2.IncrementItem();*/
                controller2.basketDetail.basketDetails[0].isModified =true;
                controller2.basketDetail.basketDetails[0].loyaltyProgramDTO = new AP16_LoyaltyProgram('LP1;LP2;LP3;ADM;COM', '6.35;19.0;19.0;9.53;-53.99');
                /*controller2.DeleteOrderLine();*/
                controller2.SaveOrderNextStep();

                controller2.globalContact.MinOrder__c=10;
                controller2.basketDetail.totalPriceForValidBase =9;
                controller2.basketDetail.isOnlineOrder =false;
                controller2.SaveOrderNextStep();


                controller2.basketDetail.isOnlineOrder =true;
                controller2.globalOrderLastModifiedDate=System.now().addHours(1);
                controller2.SaveOrderNextStep();


                System.Debug('## >>>>>VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveTemp() <<<basketDetail.errMsg<<'+controller2.basketDetail.errMsg);

                List<ORD_Order__c> theOrder = [Select id,LastModifiedDate From ORD_Order__c
                                                              Where id = :orderList[0].Id];
                controller2.globalOrderLastModifiedDate=theOrder[0].LastModifiedDate;
                List<OrderValidation__c> ordervalidationList = new List<OrderValidation__c>{
                  new OrderValidation__c(Name = UserInfo.getProfileId(),maxNumberArticles__c=10)
                };
                insert ordervalidationList;
                controller2.basketDetail.totalArticle=100;
                controller2.globalContact.ActivityStatus__c=true;
                controller2.SaveOrderNextStep();

                controller2.basketDetail.totalArticle=9;
                controller2.globalContact.BadDebt__c=true;
                controller2.SaveOrderNextStep();

                controller2.globalContact.BadDebt__c=false;
                controller2.globalContact.LastDateToOrder__c=Date.today().addDays(-7);
                controller2.SaveOrderNextStep();

                controller2.basketDetail.totalArticle=0;
                controller2.globalContact.LastDateToOrder__c=Date.today().addDays(7);
                controller2.SaveOrderNextStep();

                controller2.basketDetail.totalArticle=1;
                controller2.basketDetail.basketDetails[0].stockStatus='Out-of-stock';
                controller2.SaveOrderNextStep();

                controller2.basketDetail.basketDetails[0].stockStatus='Available';
                controller2.basketDetail.basketDetails[0].CTA.Active__c = false;
                controller2.SaveOrderNextStep();

                controller2.basketDetail.basketDetails[0].CTA.Active__c = true;
                controller2.basketDetail.basketDetails[0].CTA.Catalog__r.Active__c = false;
                controller2.SaveOrderNextStep();
                System.Debug('## >>>>>VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveNextStep() <<<basketDetail.errMsg<<'+controller2.basketDetail.errMsg);

                controller2.basketDetail.basketDetails[0].CTA.Catalog__r.Active__c = true;
                controller2.basketDetail.basketDetails[0].activeProduct = false;
                controller2.SaveOrderNextStep();
                System.Debug('## >>>>>VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveNextStep() <<<basketDetail.errMsg<<'+controller2.basketDetail.errMsg);
                
                controller2.basketDetail.basketDetails[0].activeProduct = true;
                controller2.loyaltyProgramListRecap[0].pointCredited=15;
                controller2.loyaltyProgramListRecap[0].totalPoint=5;
                controller2.loyaltyProgramListRecap[0].lowerLimit=10;
                controller2.SaveOrderNextStep();
                System.Debug('## >>>>>VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveNextStep() <<<basketDetail.errMsg<<'+controller2.basketDetail.errMsg);

                controller2.loyaltyProgramListRecap[0].pointCredited=15;
                controller2.loyaltyProgramListRecap[0].totalPoint=50;
                controller2.loyaltyProgramListRecap[0].lowerLimit=10;
                controller2.basketDetail.basketDetails[0].CTA.MaximumQuantity__c=-1;
                controller2.SaveOrderNextStep();
                System.Debug('## >>>>>VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveNextStep() <<<basketDetail.errMsg<<'+controller2.basketDetail.errMsg);
                ordervalidationList[0].maxNumberArticles__c=9999;
                update ordervalidationList;
                controller2.basketDetail.basketDetails[0].CTA.MaximumQuantity__c=999;
                controller2.basketDetail.totalArticle=1000;
                controller2.basketDetail.isOnlineOrder=true;
                controller2.SaveOrderNextStep();
                System.Debug('## >>>>>VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveNextStep() <<<basketDetail.errMsg<<'+controller2.basketDetail.errMsg);
                controller2.basketDetail.totalArticle=10;
                controller2.basketDetail.basketDetails[0].isModified =true;
                controller2.basketDetail.basketDetails[0].getAmountWithOutTax();
                controller2.basketDetail.basketDetails[0].getOldPrice();
                controller2.basketDetail.basketDetails[0].getNumberOfArticlesOrderable();
                controller2.basketDetail.basketDetails[0].stockStatus='Temporarily out-of-stock';
                controller2.basketDetail.basketDetails[0].getStockCSS();
                controller2.basketDetail.basketDetails[0].stockStatus='Limited quantity';
                controller2.basketDetail.basketDetails[0].getStockCSS();
                controller2.basketDetail.basketDetails[0].stockStatus='get in else part';
                controller2.basketDetail.basketDetails[0].getStockCSS();
                controller2.basketDetail.basketDetails[0].getHasDebit();
                controller2.basketDetail.basketDetails[0].CTASubstitution='DUMMY';
                controller2.basketDetail.basketDetails[0].meansOfPayment='DUMMY';
                controller2.basketDetail.basketDetails[0].errorMsg='DUMMY';
                controller2.basketDetail.basketDetails[0].infoMsg='DUMMY';
                controller2.basketDetail.basketDetails[0].loyaltyProgramDTO = new AP16_LoyaltyProgram('LP1;LP2;LP3;ADM;COM', '6.35;19.0;19.0;9.53;-53.99');
                orderLineList[0].TECH_ArticleType__c='Product';
                orderLineList[1].TECH_ArticleType__c='Product';
                orderLineList[2].TECH_ArticleType__c='Product';
                orderLineList[3].TECH_ArticleType__c='Product';
                orderLineList[4].TECH_ArticleType__c='Product';
                orderLineList[5].TECH_ArticleType__c='Product';

                for(VFC01_ProductDetailDTO detail : controller2.basketDetail.basketDetails){
                  detail.offers=new List<VFC01_ProductOfferDTO>();
                  detail.loyaltyProgramDTO=new AP16_LoyaltyProgram('LP1;LP2;LP3;ADM;COM', '6.35;19.0;19.0;9.53;-53.99');
                }

                controller2.SaveOrderNextStep();
                System.Debug('## >>>>>VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTestSaveNextStep() <<<basketDetail.errMsg<<'+controller2.basketDetail.errMsg);
             
            test.stopTest();
         }//end of run as
        System.Debug('## >>>>> End VFC01_OrderBasket_TEST_DUMMY - modifyExistingOrderTest() <<<<<'+UserInfo.getUserName());
    }//end of   modifyExistingOrderTestSaveTemp()

    static testMethod void modifyExistingOrderTestSaveTemp2() {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - modifyExistingOrderTestSaveTemp2() <<<<<'+UserInfo.getUserName());

        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        
        system.runAs(userList[0]){
            test.startTest();
                PageReference orderBasketPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderBasketPage );
                
                //Add parameters to page URL
                ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
                ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
                
                //Instantiate Controller
                ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
                VFC01_OrderBasket controller2 = new VFC01_OrderBasket(sc2);
                /**************************************/
                /*          article type bundle      */
                /*************************************/
                //Assigning a value to articleName
                controller2.globalArticleNameSearch = updatedCatArticleList[7].Name;
                
                //Calling method ShowArticleDetails
                controller2.ShowArticleDetails();
                
                //Calling method AddToBasket
                controller2.AddToBasket(); 
                //Call method GetOrderLines
            //  controller2.SaveOrderTemp();    
                //display currency
                controller2.getNumberCurrencyFormat();
                controller2.row_index='1';
                controller2.DeleteOrderLine();

                controller2.globalContact.MinOrder__c=10;
                controller2.basketDetail.totalPriceForValidBase =9;
                controller2.basketDetail.isOnlineOrder =false;
                controller2.SaveOrderTemp();


                controller2.basketDetail.isOnlineOrder =true;
                controller2.globalOrderLastModifiedDate=System.now().addHours(1);
                controller2.SaveOrderTemp();


                System.Debug('## >>>>>VFC01_OrderBasket_TEST - modifyExistingOrderTestSaveTemp2() <<<basketDetail.errMsg<<'+controller2.basketDetail.errMsg);

                List<ORD_Order__c> theOrder = [Select id,LastModifiedDate From ORD_Order__c
                                                              Where id = :orderList[0].Id];
                controller2.globalOrderLastModifiedDate=theOrder[0].LastModifiedDate;
                List<OrderValidation__c> ordervalidationList = new List<OrderValidation__c>{
                  new OrderValidation__c(Name = UserInfo.getProfileId(),maxNumberArticles__c=10)
                };
                insert ordervalidationList;
                controller2.basketDetail.totalArticle=100;
                controller2.globalContact.ActivityStatus__c=true;
                controller2.SaveOrderTemp();

                controller2.basketDetail.totalArticle=9;
                controller2.globalContact.BadDebt__c=true;
                controller2.SaveOrderTemp();

                controller2.globalContact.BadDebt__c=false;
                controller2.globalContact.LastDateToOrder__c=Date.today().addDays(-7);
                controller2.SaveOrderTemp();

                controller2.basketDetail.totalArticle=0;
                controller2.globalContact.LastDateToOrder__c=Date.today().addDays(7);
                controller2.SaveOrderTemp();

                controller2.basketDetail.totalArticle=1;
                controller2.basketDetail.basketDetails[0].stockStatus='Out-of-stock';
                controller2.SaveOrderTemp();

                controller2.basketDetail.basketDetails[0].stockStatus='Available';
                controller2.basketDetail.basketDetails[0].CTA.Active__c = false;
                controller2.SaveOrderTemp();

                controller2.basketDetail.basketDetails[0].CTA.Active__c = true;
                controller2.basketDetail.basketDetails[0].CTA.Catalog__r.Active__c = false;
                controller2.SaveOrderTemp();

                controller2.basketDetail.basketDetails[0].CTA.Catalog__r.Active__c = true;
                controller2.basketDetail.basketDetails[0].activeProduct = false;
                controller2.SaveOrderTemp();

                
                controller2.basketDetail.basketDetails[0].activeProduct = true;
                controller2.loyaltyProgramListRecap[0].pointCredited=15;
                controller2.loyaltyProgramListRecap[0].totalPoint=5;
                controller2.loyaltyProgramListRecap[0].lowerLimit=10;
                controller2.SaveOrderTemp();


                controller2.loyaltyProgramListRecap[0].pointCredited=15;
                controller2.loyaltyProgramListRecap[0].totalPoint=50;
                controller2.loyaltyProgramListRecap[0].lowerLimit=10;
                controller2.basketDetail.basketDetails[0].CTA.MaximumQuantity__c=0;
                controller2.SaveOrderTemp();

                controller2.basketDetail.basketDetails[0].CTA.MaximumQuantity__c=999;
                controller2.basketDetail.totalArticle=1000;
                controller2.basketDetail.isOnlineOrder=true;
                controller2.SaveOrderTemp();

                controller2.globalContact.BadDebt__c=true;
                controller2.basketDetail.isOnlineOrder=true;
                controller2.checkCanDelegateCloseOrder();
                controller2.delegateOrder();
                controller2.closeOrder();
               
                System.Debug('## >>>>>VFC01_OrderBasket_TEST - modifyExistingOrderTestSaveTemp2() <<<basketDetail.errMsg<<'+controller2.basketDetail.errMsg);
            test.stopTest();
         }//end of run as
        System.Debug('## >>>>> End VFC01_OrderBasket_TEST - modifyExistingOrderTest() <<<<<'+UserInfo.getUserName());
    }//end of   modifyExistingOrderTestSaveTemp2()

    static testMethod void pushZoneTest() {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - modifyExistingOrderTest() <<<<<'+UserInfo.getUserName());
        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        
        system.runAs(userList[0]){
            test.startTest();
                PageReference orderBasketPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderBasketPage );
                
                //Add parameters to page URL
                ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
                ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
                
                //Instantiate Controller
                ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
                                
                VFC01_PushZone pushZone = new VFC01_PushZone();
                
                pushZone.getCatalogArticles();
                            
            test.stopTest();
         }//end of run as
        System.Debug('## >>>>> End VFC01_OrderBasket_TEST - modifyExistingOrderTest() <<<<<'+UserInfo.getUserName());
    }//end of   modifyExistingOrderTest()
    //test search for product
    
     static testMethod void addToBasketMassOrder() {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - addToBasketMassOrder <<<<<'+UserInfo.getUserName());
        
        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        system.runAs(userList[0]){
            system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
            ORD_Order__c newOrder1 = new ORD_Order__c();
            test.startTest();
                PageReference orderPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderPage );
                
                //Instantiate Controller
                ApexPages.StandardController sc1 = new ApexPages.StandardController(newOrder1);
                VFC01_OrderBasket controller = new VFC01_OrderBasket(sc1);
                
                //initialising massInputs
                //List<VFC01_ProductMassInputDTO> massInputs;
                //controller.massInputs=VFC01_ProductMassInputDTO.initialiseList();
                controller.massInputs[0].productName='134';
                controller.massInputs[0].quantity='10';
                controller.massInputs[1].productName='136';
                controller.massInputs[1].quantity='10';
                controller.massInputs[2].productName='125';
                controller.massInputs[2].quantity='10';
                controller.massInputs[3].productName='707';
                controller.massInputs[3].quantity='10';
                controller.massInputs[4].productName='';
                controller.massInputs[4].quantity='10';
                controller.massInputs[5].productName='125';
                controller.massInputs[5].quantity='';
                controller.massInputs[6].productName='1111111111';
                controller.massInputs[6].quantity='10';
                controller.massInputs[7].productName='777';
                controller.massInputs[7].quantity='10';
                controller.massInputs[8].productName='902';
                controller.massInputs[8].quantity='2';
                controller.massInputs[9].productName='';
                controller.massInputs[9].quantity='';
                controller.massInputs[10].productName='';
                controller.massInputs[10].quantity='';
                controller.massInputs[11].productName='';
                controller.massInputs[11].quantity='';
                controller.massInputs[12].productName='';
                controller.massInputs[12].quantity='';
                controller.massInputs[13].productName='';
                controller.massInputs[13].quantity='';
                controller.massInputs[14].productName='';
                controller.massInputs[14].quantity='';
                controller.massInputs[15].productName='';
                controller.massInputs[15].quantity='';
                controller.massInputs[16].productName='';
                controller.massInputs[16].quantity='';
                controller.massInputs[17].productName='';
                controller.massInputs[17].quantity='';
                controller.massInputs[18].productName='';
                controller.massInputs[18].quantity='';
                controller.massInputs[19].productName='';
                controller.massInputs[19].quantity='';
                integer counter=0;
                for(VFC01_ProductMassInputDTO dto : controller.massInputs){
                    system.debug('MassInput['+counter+']=' + dto.productName+','+dto.quantity);
                }
                controller.refs = new List<String>();
                controller.dCats=catalogueList[0].Id;
                
                //Calling method AddToBasketMass
                controller.AddToBasketMass();
                
                //list containing all possible error messsages
                List<string> errorMsgs=new List<string>();
                errorMsgs.add(system.label.ORD00148+' '+system.label.ORD00151+' '+system.label.ORD00037);
                errorMsgs.add(system.label.ORD00154+' '+system.label.ORD00037);
                errorMsgs.add(system.label.ORD00147);
                errorMsgs.add(system.label.ORD00158);
                errorMsgs.add(system.label.ORD00162);
                errorMsgs.add(system.label.ORD00138);
                errorMsgs.add(system.label.ORD00006);
                errorMsgs.add(system.label.ORD00157);
                errorMsgs.add(system.label.ORD00169+'.'+system.label.ORD00172+'1');
                
                //test client side validation
                system.assertEquals(controller.massInputs[4].errMsg, errorMsgs[0]);
                system.assertEquals(controller.massInputs[5].errMsg, errorMsgs[1]);
                
                //correcting client side invalid inputs
                controller.massInputs[4].productName='125';
                controller.massInputs[4].quantity='10';
                controller.massInputs[5].productName='125';
                controller.massInputs[5].quantity='10';
                
                //Calling method AddToBasketMass
                controller.AddToBasketMass();
                
                //test server side validation
                system.assertEquals(controller.massInputs[0].errMsg, errorMsgs[2]);
                system.assertEquals(controller.massInputs[1].errMsg, errorMsgs[3]);
                system.assertEquals(controller.massInputs[2].errMsg, null);
                system.assertEquals(controller.massInputs[3].errMsg, errorMsgs[4]);
                system.assertEquals(controller.massInputs[4].errMsg, null);
                system.assertEquals(controller.massInputs[5].errMsg, null);
                system.assertEquals(controller.massInputs[6].errMsg, errorMsgs[5]);
                //system.assertEquals(controller.massInputs[7].errMsg, 'One or more product from your basket is inactive');
                system.assertEquals(controller.massInputs[8].errMsg, errorMsgs[8]);
                
                //correcting server side invalid inputs
                controller.massInputs[0].productName='125';
                controller.massInputs[0].quantity='2';
                controller.massInputs[1].productName='125';
                controller.massInputs[1].quantity='2';
                controller.massInputs[2].productName='125';
                controller.massInputs[2].quantity='2';
                controller.massInputs[3].productName='125';
                controller.massInputs[3].quantity='2';
                controller.massInputs[4].productName='125';
                controller.massInputs[4].quantity='2';
                controller.massInputs[5].productName='125';
                controller.massInputs[5].quantity='2';
                controller.massInputs[6].productName='';
                controller.massInputs[6].quantity='';
                controller.massInputs[7].productName='';
                controller.massInputs[7].quantity='';
                controller.massInputs[8].productName='';
                controller.massInputs[8].quantity='';
                
                //Calling method AddToBasketMass
                controller.AddToBasketMass();
                
                //test server side validation
                system.assertEquals(controller.massInputs[0].errMsg, null);
                system.assertEquals(controller.massInputs[1].errMsg, null);
                system.assertEquals(controller.massInputs[2].errMsg, null);
                system.assertEquals(controller.massInputs[3].errMsg, null);
                system.assertEquals(controller.massInputs[4].errMsg, null);
                system.assertEquals(controller.massInputs[5].errMsg, null);
                system.assertEquals(controller.massInputs[6].errMsg, null);
                system.assertEquals(controller.massInputs[7].errMsg, null);
                system.assertEquals(controller.massInputs[8].errMsg, null);
                
                //clicking on addtobasket without filling any inputs
                controller.massInputs[0].productName='';
                controller.massInputs[0].quantity='';
                controller.massInputs[1].productName='';
                controller.massInputs[1].quantity='';
                controller.massInputs[2].productName='';
                controller.massInputs[2].quantity='';
                controller.massInputs[3].productName='';
                controller.massInputs[3].quantity='';
                controller.massInputs[4].productName='';
                controller.massInputs[4].quantity='';
                controller.massInputs[5].productName='';
                controller.massInputs[5].quantity='';
                controller.massInputs[6].productName='';
                controller.massInputs[6].quantity='';
                controller.massInputs[7].productName='';
                controller.massInputs[7].quantity='';
                controller.massInputs[8].productName='';
                controller.massInputs[8].quantity='';
                controller.massInputs[9].productName='';
                controller.massInputs[9].quantity='';
                controller.massInputs[10].productName='';
                controller.massInputs[10].quantity='';
                controller.massInputs[11].productName='';
                controller.massInputs[11].quantity='';
                controller.massInputs[12].productName='';
                controller.massInputs[12].quantity='';
                controller.massInputs[13].productName='';
                controller.massInputs[13].quantity='';
                controller.massInputs[14].productName='';
                controller.massInputs[14].quantity='';
                controller.massInputs[15].productName='';
                controller.massInputs[15].quantity='';
                controller.massInputs[16].productName='';
                controller.massInputs[16].quantity='';
                controller.massInputs[17].productName='';
                controller.massInputs[17].quantity='';
                controller.massInputs[18].productName='';
                controller.massInputs[18].quantity='';
                controller.massInputs[19].productName='';
                controller.massInputs[19].quantity='';
                
                //Calling method AddToBasketMass
                controller.AddToBasketMass();
                
                //requires at least one product
                system.assertEquals(controller.massInputs[0].errMsg, errorMsgs[6]);
                
                //all inputs valid but none are found in the catalog
                controller.massInputs[0].productName='1111111111';
                controller.massInputs[0].quantity='1';
                controller.massInputs[1].productName='1111111111';
                controller.massInputs[1].quantity='1';
                controller.massInputs[2].productName='1111111111';
                controller.massInputs[2].quantity='1';
                
                //Calling method AddToBasketMass
                controller.AddToBasketMass();
                
                //none found
                system.assertEquals(controller.massInputs[0].errMsg, errorMsgs[5]);
                system.assertEquals(controller.massInputs[1].errMsg, errorMsgs[5]);
                system.assertEquals(controller.massInputs[2].errMsg, errorMsgs[5]);
                
                //change catalog
                controller.changeCatMO();
                controller.validateMassOrderCatalog();
                controller.getDealerCatalogs();
                controller.validateMassOrderCatalog();
                controller.getDocumentAdvertUrl();
                controller.clearInfoErrMsg();
                controller.refreshInterface();
                controller.isMO='true';
                controller.refreshInterface();
                controller.retrieveContactFromUser();
                //no catalogs found
                controller.refs = new List<String>();
                controller.dCats= 'NO_VALUE';
                //run functions
                //controller.getDealerCatalogs();
                controller.validateMassOrderCatalog();
                controller.blockAddToBasketMassOrder();
                controller.refreshInterface();
                controller.retrieveContactFromUser();
                //deactivate dealer
                controller.globalContact.ActivityStatus__c=false;
                //change catalog with dealer inactive
                controller.changeCatMO();
                controller.validateMassOrderCatalog();
                controller.getDealerCatalogs();
                controller.validateMassOrderCatalog();
                controller.getDocumentAdvertUrl();
                controller.clearInfoErrMsg();
                controller.refreshInterface();
                controller.isMO='true';
                controller.refreshInterface();
                controller.retrieveContactFromUser();
                controller.initializeMassOrderInterface();
                controller.globalContact.ActivityStatus__c=true;
                controller.globalContact.BadDebt__c=true;
                controller.isBadDedtAndExpired();controller.globalContact.BadDebt__c=false;
                controller.globalContact.ActivityStatus__c=false;
                controller.isBadDedtAndExpired();controller.globalContact.ActivityStatus__c=true;controller.STH_ID='test1';
                controller.ChangeDealerDetailsBySTH();
                //remove dealer
                controller.globalContact=null;
                //change catalog without dealer
                controller.checkIfHasCatalogue();
                controller.changeCatMO();
                controller.validateMassOrderCatalog();
                controller.validateMassOrderCatalog();
                controller.getDocumentAdvertUrl();
                controller.clearInfoErrMsg();
                controller.refreshInterface();
                controller.isMO='true';
                controller.refreshInterface();
                controller.retrieveContactFromUser();
                controller.msgDeleteWarning='msgDeleteWarning';
                controller.errorMsgLP='errorMsgLP';     
                controller.CronJobDetailList=null;
                controller.CronTriggerList=null;
                //run function checkisCanChangeDealer
                controller.isCanChooseDealer=true;controller.isPortalUser=true;
                controller.checkisCanChangeDealer();
                controller.isCanChooseDealer=false;controller.isPortalUser=true;
                controller.checkisCanChangeDealer();
                controller.isCanChooseDealer=true;controller.isPortalUser=false;
                controller.checkisCanChangeDealer();
                controller.isCanChooseDealer=false;controller.isPortalUser=false;
                controller.checkisCanChangeDealer();
                BatchOrderDeletionOptions__c batchFRA = new BatchOrderDeletionOptions__c(Name='FRA',batchName__c='FRA',IsAutomaticDeletion__c=true,ValidityPeriod__c=10);
                insert batchFRA;
                controller.reachCommercialTarget=true;
                controller.initializeMsgDeleteWarning('FRA');

                VFC01_ProductOfferDetailDTO testOfferDetail= new VFC01_ProductOfferDetailDTO();
                    testOfferDetail.name ='test';
                    testOfferDetail.smartCode ='123';
                    testOfferDetail.localCode ='123';
                    testOfferDetail.isRequired =false;
                    testOfferDetail.quantity ='2';
                    testOfferDetail.minQtyOrderable =1;
                    testOfferDetail.maxQtyOrderable =7;
                    testOfferDetail.isClosedSet =false;
                    testOfferDetail.article = articleList[7].Id;
                    testOfferDetail.orderline = null;
                VFC01_ProductOfferDTO testOfferDTO = new VFC01_ProductOfferDTO('offer');
                    testOfferDTO.addOfferDetails(testOfferDetail);
                    testOfferDTO.name = 'testOfferDto';
                    testOfferDTO.total = 100;
                    testOfferDTO.minQtyOrderable = 1;
                    testOfferDTO.maxQtyOrderable = 100;
                    testOfferDTO.actualQtyOrdered = 2;
                    testOfferDTO.article = null;
                List<VFC01_ProductOfferDTO> testListOfferDTO = new List<VFC01_ProductOfferDTO>();
                testListOfferDTO.add(testOfferDTO);
                VFC01_ProductDetailDTO productDetail = new VFC01_ProductDetailDTO();
                    productDetail.name ='Test';
                    productDetail.localCode ='123';
                    productDetail.quantity ='10';
                    productDetail.isClosedSet =false;
                    productDetail.article =null;
                    productDetail.orderline =null;
                    productDetail.offers=testListOfferDTO;
                controller.updateOfferDetailsQuantity('+',productDetail);
                controller.validateLoyaltyProgram();
                //test.stopTest();
                test.stopTest();
       
       }//end of system.runAs(userList[0])
    }//end of static testMethod void addToBasketMassOrder()
   //test search for delete save order cal transport fees
    static testMethod void saveOrderTempCalcTransaportFees() {
        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                                    , TECH_CatalogArticleDateInRange__c
                                                                    , TECH_ArticleRecordType__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
        system.runAs(userList[2]){
            system.debug('>>>>>> userList[2].LastName: ' + userList[2].LastName);
            system.debug('>>>>>> updatedCatArticleList: ' + updatedCatArticleList[4]);
            ORD_Order__c newOrder1 = new ORD_Order__c();
            test.startTest();
                PageReference orderPage = Page.VFP01_OrderBasket;
                Test.setCurrentPage( orderPage );
                
                //Instantiate Controller
                ApexPages.StandardController sc1 = new ApexPages.StandardController(newOrder1);
                VFC01_OrderBasket controller = new VFC01_OrderBasket(sc1);
                 controller.globalContact=contactList[3];
                system.debug('>>>>>> updatedCatArticleList[5].Name: ' + updatedCatArticleList[4].Name);
                system.debug('>>>>>> updatedCatArticleList[5].TECH_CatalogArticleDateInRange__c: ' + updatedCatArticleList[4].TECH_CatalogArticleDateInRange__c);
                system.debug('>>>>>> updatedCatArticleList[5].Active__c: ' + updatedCatArticleList[4].Active__c);
                system.debug('>>>>>> updatedCatArticleList[5].TECH_ArticleRecordType__c: ' + updatedCatArticleList[4].TECH_ArticleRecordType__c);
                system.debug('>>>>>> updatedCatArticleList[5].Catalog__c: ' + updatedCatArticleList[4].Catalog__c);

                //Assigning a value to articleName
                controller.globalArticleNameSearch = updatedCatArticleList[4].Name;//index 0 contain article 'articleList[7]'
                
                //Calling method ShowArticleDetails
                controller.ShowArticleDetails();
                                
                //Calling method AddToBasket
                controller.AddToBasket();
            controller.basketDetail.totalPriceForValidBase = 50;
            system.debug('>>>>>> basketDetail.totalPrice: ' + controller.basketDetail.totalPrice);
           controller.SaveOrderTemp();
            TransportFees__c testTransportFRA = new TransportFees__c(Name='FRA', Amount__c=100);
            insert testTransportFRA;
            controller.basketDetail.totalPrice=10;
            system.debug('>>>>>> basketDetail.totalPrice: ' + controller.basketDetail.totalPrice);
            controller.SaveOrderTemp();
            test.stopTest();
                        
       }//end of system.runAs(userList[0])
    }//end of saveOrderTempCalcTrasnportFees()
}//end of test class