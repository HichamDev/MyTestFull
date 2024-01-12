@isTest
private class AP38_StockManagement_Test {
    
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
    
    static  ORD_Order__c globalOrderTest;
    
    static VFC01_OrderBasket_Italy globalController;
    
    static {
        System.Debug('## >>>>> Start AP38_StockManagement_Test >>> Inserting Data for Tests <<<<<'+UserInfo.getUserName());
        
        STHEndpoints__c endITA = new STHEndpoints__c();
        endITA.Name = 'ITA';
        endITA.Google_Timeout__c = 10000;
        endITA.Google_Endpoint__c = 'http://google.fr';
        endITA.Google_Crypto_Key__c = 'crypto';
        endITA.Google_Client_Id__c = 'clientID';
        endITA.Google_Channel_Id__c = 'channel';
        endITA.Card_Payment_Shop_Id__c = 'ShopId';
        endITA.Card_Payment_Merchant_Id__c = 'merchantId';
        endITA.Card_Payment_Coef__c = 1.01;
        endITA.Card_Payment_Endpoint__c = 'endpoint';
        endITA.Card_Payment_API_Key__c  = 'apikey';
        endITA.stock_lower_indicator__c = 10;
        insert endITA;
        
        //Retrieving Record Type related to Contact
        contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = 'Dealer' and SObjectType = 'Contact' Limit 1].id;
        
        //Retrieving Record Type related to Article
        //Offer
        offerRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00001 and SObjectType = 'ART_Article__c' Limit 1].id;
        //Bundle
        bundleRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00002 and SObjectType = 'ART_Article__c' Limit 1].id;
        //Product
        productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        
        //Retrieving Profile Ids
        DealerProfileId = [select id from Profile where Name= :system.label.CON00001].Id;
        
        //Creating new accounts
        accountList = new List<Account>{
            new Account(Name='AccountTest1'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test1'
                        , Country_Code__c = 'ITA'
                        , WebServiceAvailability__c = true),
            new Account(Name='AccountTest2'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test2'
                        , Country_Code__c = 'ITA')
        };
        insert (accountList);
        
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
        
        //Creating new articles
        articleList = new List<ART_Article__c>{
            new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[0] available
                               , Name = 'Shampoo1'
                               , LocalName__c = 'Shampoo1'
                				, LocalCode__c='1347'
                               , StockStatusMessage__c = 'Test'
                				, AvailableInStock__c = 100
            					, OnhandStockStatus__c = 'Available'),
           new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[1] out of stock
                               , Name = 'Apple'
                               , LocalName__c = 'Apple'
                               , LocalCode__c='134'
               				   , AvailableInStock__c = 100
                               , OnhandStockStatus__c='Out-of-stock'
                               , ActiveProduct__c=true),
           new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[2] limited quantity
                               , Name = 'Orange'
                               , LocalName__c = 'Orange'
                               , LocalCode__c='136'
               					, AvailableInStock__c = 100
                               , OnhandStockStatus__c = 'Limited quantity'
                               , ActiveProduct__c=true),
          new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[3] dynamic
                               , Name = 'Banana'
                               , LocalName__c = 'Banana'
                               , LocalCode__c='125'
                               , OnhandStockStatus__c = 'Dynamic Stock'
              					, AvailableInStock__c = 100
                               , ActiveProduct__c=true),
          new ART_Article__c(//Product
                               RecordTypeId = offerRecordTypeID  //articleList[4] dynamic
                               , Name = 'Cherry'
                               , LocalName__c = 'Cherry'
                               , LocalCode__c='707'
                               , OnhandStockStatus__c='Dynamic Stock'
              					, AvailableInStock__c = 100
                               , ActiveProduct__c=true
          						, TECH_ExternalId__c = 'ITA_JSDHO'),
          new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[5] dynamic
                               , Name = 'Grapefruit'
                               , LocalName__c = 'Grapefruit'
                               , LocalCode__c='777'
                               , OnhandStockStatus__c='Dynamic Stock'
              					, AvailableInStock__c = 100
                               , ActiveProduct__c=false
          						, TECH_ExternalId__c = 'ITA_JSDHJ'),
          new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[6] dynamic with children
                               , Name = 'Bitter'
                               , LocalName__c = 'Bitter'
                               , LocalCode__c='902'
                               , OnhandStockStatus__c='Dynamic Stock'
              					, AvailableInStock__c = 100
                               , ActiveProduct__c=true
          						, TECH_offer_children__c = 'ITA_JSDHJ,ITA_JSDHO'),
          new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[7] dynamic out
                               , Name = 'Grapefruitout'
                               , LocalName__c = 'Grapefruitout'
                               , LocalCode__c='7777'
                               , OnhandStockStatus__c='Dynamic Stock'
              					, AvailableInStock__c = 10
                               , ActiveProduct__c=false
          						, TECH_ExternalId__c = 'ITA_JSDHP'),
          new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[8] dynamic with sub
                               , Name = 'Grapefruitwithsub'
                               , LocalName__c = 'Grapefruitwithsub'
                               , LocalCode__c='7789'
                               , OnhandStockStatus__c='Dynamic Stock'
              					, StockStatusMessage__c = 'ITA_JSDHP'
              					, AvailableInStock__c = 10
                               , ActiveProduct__c=false
          						, TECH_ExternalId__c = 'ITA_JSDHP1')
        }; 
        insert(articleList);
        for (ART_Article__c art : articleList) {
            system.debug('>> art : ' + art.id + ' - ' + art.LocalCode__c + ' : ' + art.OnhandStockStatus__c + ', ' + art.AvailableInStock__c);
        }
        
        //Creating new catalogue
        catalogueList = new List<CAT_Catalog__c>{
            new CAT_Catalog__c(Account__c = accountList[0].id
                               , Name = 'CatalogueTest1'
                               ,StartDate__c = Date.today().addDays(-20)
                               ,EndDate__c= Date.today().addDays(20))
        };
        insert (catalogueList);

        //Creating new catalogue
        catalogueList = new List<CAT_Catalog__c>{
            new CAT_Catalog__c(Account__c = accountList[0].id
                               , Name = 'CatalogueTest1'
                               , Active__c = true
                               ,StartDate__c = Date.today().addDays(-20)
                               ,EndDate__c= Date.today().addDays(20))
        };
        insert (catalogueList);
        
         catArticleList = new List<CTA_CatalogArticle__c>{
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id // catArticleList[0] - articleList[6] dynamic with children
                                      , Name = 'Test2'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[6].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
           new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id // catArticleList[1] - articleList[5] dynamic
                                      , Name = 'Test3'
                                      , Active__c = true
                                      , PublicPrice__c = 1000
                                      , Article__c = articleList[5].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ), 
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id // catArticleList[2] - articleList[4] dynamic 
                                      , Name = 'Test4'
                                      , Active__c = true
                                      , PublicPrice__c = 1000
                                      , Article__c = articleList[4].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id // catArticleList[3] - articleList[3] dynamic
                                      , Name = 'Test5'
                                      , Active__c = true
                                      , PublicPrice__c = 1000
                                      , Article__c = articleList[3].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ), 
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id // catArticleList[4] - articleList[2] dynamic
                                      , Name = 'Test6'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[2].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id // catArticleList[5] - articleList[1] out of  stock
                                      , Name = 'Test7'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[1].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ), 
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id // catArticleList[6] - articleList[0] available
                                      , Name = 'Test8'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[0].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id // catArticleList[0] - articleList[7] dynamic out
                                      , Name = 'Test2'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[7].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      ),
             new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id // catArticleList[0] - articleList[8] dynamic out
                                      , Name = 'Test2'
                                      , Active__c = true
                                      , PublicPrice__c = 100
                                      , Article__c = articleList[8].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      )
        };
        insert(catArticleList);
        
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
        
        //Retrieve catalogue Article
        List<CTA_CatalogArticle__c> updatedCatArticleList = [Select id
                                                                    , Catalog__c
                                                                    , Name
                                                                    , Active__c
                                                                    , PublicPrice__c
                                                                    , Article__c
                                                               From CTA_CatalogArticle__c
                                                              Where id IN :catArticleList];
                
        globalOrderTest = new ORD_Order__c();
        
        system.runAs(userList[0]){

			globalOrderTest = new ORD_Order__c(dealer__c = contactList[0].id
	       						 , Status__c = 'Draft'
	       						 , OrderDate__c = system.TODAY());
		    insert(globalOrderTest);
		    
		    List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
	        	new ORL_OrderLine__c(Order__c = globalOrderTest.id
	        						 , Article__c = articleList[6].Id
	        						 , RegularPrice__c = 100
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = globalOrderTest.id
	        						 , Article__c = articleList[2].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = globalOrderTest.id
	        						 , Article__c = articleList[4].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending')
	        };
	        insert(orderLineList);
        }//end of system run as

                
    }//end of static
    
    static testMethod void testLimitedQuantity_Ok() {
        
        CTA_CatalogArticle__c cat2 = [SELECT Id, Article__r.AvailableInStock__c, Article__r.stock_remaining__c, Article__r.OnhandStockStatus__c
                                     	FROM CTA_CatalogArticle__c
                                     	WHERE Id =: catArticleList[2].Id];
        
        AP38_StockManagement.checkIfLimitedStock(cat2, 'ITA', '1');
        
    }
    
    static testMethod void testLimitedQuantity_Limited() {
        CTA_CatalogArticle__c cat4 = [SELECT Id, Article__r.AvailableInStock__c, Article__r.stock_remaining__c, Article__r.OnhandStockStatus__c
                                     	FROM CTA_CatalogArticle__c
                                     	WHERE Id =: catArticleList[4].Id];
        
        AP38_StockManagement.checkIfLimitedStock(cat4, 'ITA', '1');
    }

    static testMethod void sendOrderWithStock_Ok() {
        
        AP38_StockManagement.checkIfAllInStock(globalOrderTest.Id);
        
    }
    
    static testMethod void sendOrderWithStock_Ko() {
        
        ORD_Order__c orderTestKo;
        
        system.runAs(userList[0]){

			orderTestKo = new ORD_Order__c(dealer__c = contactList[0].id
	       						 , Status__c = 'Draft'
	       						 , OrderDate__c = system.TODAY());
		    insert(orderTestKo);
		    
		    List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
	        	new ORL_OrderLine__c(Order__c = orderTestKo.id
	        						 , Article__c = articleList[7].Id
	        						 , RegularPrice__c = 100
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = orderTestKo.id
	        						 , Article__c = articleList[2].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending')
	        };
	        insert(orderLineList);
            
        } //end of system run as
        
        Stock_use__c thisStockUse = new Stock_use__c();
        thisStockUse.article__c = articleList[7].Id;
        thisStockUse.order__c = orderTestKo.Id;
        thisStockUse.quantity_use__c = 10;
        insert thisStockUse;
        
        AP38_StockManagement.checkIfAllInStock(orderTestKo.Id);
        
    }
    
    static testMethod void sendOrderWithStock_substitute() {
        
        ORD_Order__c orderTestSub;
        
        system.runAs(userList[0]){

			orderTestSub = new ORD_Order__c(dealer__c = contactList[0].id
	       						 , Status__c = 'Draft'
	       						 , OrderDate__c = system.TODAY());
		    insert(orderTestSub);
		    
		    List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
	        	new ORL_OrderLine__c(Order__c = orderTestSub.id
	        						 , Article__c = articleList[8].Id
	        						 , RegularPrice__c = 100
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = orderTestSub.id
	        						 , Article__c = articleList[2].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending')
	        };
	        insert(orderLineList);
            
        } //end of system run as
        
        Stock_use__c thisStockUse = new Stock_use__c();
        thisStockUse.article__c = articleList[8].Id;
        thisStockUse.order__c = orderTestSub.Id;
        thisStockUse.quantity_use__c = 10;
        insert thisStockUse;
        
        AP38_StockManagement.checkIfAllInStock(orderTestSub.Id);
        
    }
    
}