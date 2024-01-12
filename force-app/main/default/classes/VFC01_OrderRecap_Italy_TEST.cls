@isTest
private class VFC01_OrderRecap_Italy_TEST {
/*
----------------------------------------------------------------------
-- - Name          : VFC01_OrderRecap_TEST 
-- - Author        : AMU
-- - Description   : This class contains unit tests for validating the 
--                   behavior of controller VFC01_OrderRecap
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 14-NOV-2012  AMU    1.0      Initial version    
-- 30-SEP-2013	YGO	   1.2		New version to accomodate changes in page                      
----------------------------------------------------------------------
**********************************************************************
*/
	 static List<Account> accountList;
     static List<Contact> contactList;
     static List<Contact> contactList1;
     static List<User> userList;
     static List<ART_Article__c> articleList;
     static List<KIT_Kit__c> kitList;
     static List<CAT_Catalog__c> catalogueList;
     static List<CTA_CatalogArticle__c> catArticleList;
     static Id contactDealerRecordTypeID, DealerProfileId, offerRecordTypeID, bundleRecordTypeID, productRecordTypeID;
    
    static {
		System.Debug('## >>>>> Start VFC01_OrderBasket_TEST >>> Inserting Data for Tests <<<<<'+UserInfo.getUserName());
		
		STHEndpoints__c endIta = new STHEndpoints__c();
        endIta.Name = 'ITA';
        endIta.Google_Timeout__c = 10000;
        endIta.Google_Endpoint__c = 'http://google.fr';
        endIta.Google_Crypto_Key__c = 'crypto';
        endIta.Google_Client_Id__c = 'clientID';
        endIta.Google_Channel_Id__c = 'channel';
        endIta.Card_Payment_Shop_Id__c = 'ShopId';
        endIta.Card_Payment_Merchant_Id__c = 'merchantId';
        endIta.Card_Payment_Coef__c = 1.01;
        endIta.Card_Payment_Endpoint__c = 'endpoint';
        endIta.Card_Payment_API_Key__c  = 'apikey';
        insert endIta;
    	
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
 						, MinOrderFreeTransportFees__c=50),
     		new Contact(RecordTypeId = contactDealerRecordTypeID
     					, LastName = 'ContactTest2'
     					, Birthdate = system.Today() - 3650
     					, email = 'a@test2.com'
     					, STHID__c = 'test2'
     					, AccountId = accountList[1].id
     					, CurrentBalance__c = -5
     					, MinOrder__c=50
 						, MinOrderFreeTransportFees__c=50)			
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
     				 , ContactId = contactList[1].Id)		 
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
			new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[3]
								, Name = 'Gel2'
								, LocalName__c = 'Gel2'),
			new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[4]
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
								RecordTypeId = offerRecordTypeID   //articleList[7]
								, Name = 'ShampooGelBundle'
								, LocalName__c = 'ShampooGelBundle'
								, Number_of_Articles__c = 3)
		}; 
        insert(articleList);
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
        					, MinQtyOrderable__c = 0
        					, MaxQtyOrderable__c = 1),
        	new KIT_Kit__c (ParentArticle__c = articleList[6].Id
        					, Article__c = articleList[3].id
        					, KitType__c = 'Closed set'
        					, MinQtyOrderable__c = 0
        					, MaxQtyOrderable__c = 1),
        	new KIT_Kit__c (ParentArticle__c = articleList[7].Id
        					, Article__c = articleList[5].id
        					, KitType__c = 'Closed set'),
        	new KIT_Kit__c (ParentArticle__c = articleList[7].Id
        					, Article__c = articleList[6].id
        					, KitType__c = 'Closed set'),
        	new KIT_Kit__c (ParentArticle__c = articleList[7].Id
        					, Article__c = articleList[4].id
        					, KitType__c = 'Closed set'
        					, MinQtyOrderable__c = 1
        					, MaxQtyOrderable__c = 1)
        };
        insert(kitList);
        system.debug('>>>>>> kitList : ' + kitList);
        
        //Creating new catalogue
        catalogueList = new List<CAT_Catalog__c>{
        	new CAT_Catalog__c(Account__c = accountList[0].id
        					   , Name = 'CatalogueTest1')
        };
        insert (catalogueList);
        system.debug('>>>>>> catalogueList : ' + catalogueList);
        
        //Creating new catalogue articles
        catArticleList = new List<CTA_CatalogArticle__c>{
        	new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
        							  , Name = 'Test1'
        							  , Active__c = true
        							  , RegularPrice__c = 100
        							  , Article__c = articleList[7].Id)
        };
        insert(catArticleList);
        system.debug('>>>>>> catArticleList : ' + catArticleList);
	} // Static
	
	static testMethod void orderRecapPayment() {
        
        Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());

        system.runAs(userList[0]){
	       	system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
	       	List<ORD_Order__c> orderList = new List<ORD_Order__c>{
	       		new ORD_Order__c(dealer__c = contactList[0].id
	       						 , Status__c = 'Draft'
	       						 , OrderDate__c = system.TODAY())
	       	};
		    insert(orderList);
		    
		    List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[7].Id
	        						 , RegularPrice__c = 100
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[0].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[1].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[2].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[3].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[4].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending')
	        };
	        insert(orderLineList);
	        
	        test.startTest();
	        	PageReference orderRecapPage = Page.VFP01_OrderRecap_Italy;
	        	Test.setCurrentPage( orderRecapPage );
	        	
	        	//Add parameters to page URL
 				ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
 				ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
	        	
	        	//Instantiate Controller
	       	 	ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
        		VFC01_OrderRecap_Italy controller2 = new VFC01_OrderRecap_Italy(sc2);
				
				// Call reset function
				controller2.resetCard();	
            	// Call refresh button
            	controller2.refreshBtnZone();	
            
		   	test.stopTest();

	        
       	}//system.runAs(userList[0])
		    
        
    }
    
    static testMethod void orderRecapTest()
    {
    	System.Debug('## >>>>> Start VFC01_OrderRecap_TEST - orderRecapTest <<<<<'+UserInfo.getUserName());
    	
       	system.runAs(userList[0]){
	       	system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
	       	List<ORD_Order__c> orderList = new List<ORD_Order__c>{
	       		new ORD_Order__c(dealer__c = contactList[0].id
	       						 , Status__c = 'Draft'
	       						 , OrderDate__c = system.TODAY())
	       	};
		    insert(orderList);
		    
		    List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[7].Id
	        						 , RegularPrice__c = 100
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[0].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[1].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[2].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[3].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[4].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending')
	        };
	        insert(orderLineList);
	        
	        test.startTest();
	        	PageReference orderRecapPage = Page.VFP01_OrderRecap_Italy;
	        	Test.setCurrentPage( orderRecapPage );
	        	
	        	//Add parameters to page URL
 				ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
 				ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
	        	
	        	//Instantiate Controller
	       	 	ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
        		VFC01_OrderRecap_Italy controller2 = new VFC01_OrderRecap_Italy(sc2);
				
				//Call method GetOrderLines
				controller2.GetOrderLines();
				Integer listSize = controller2.orderLineList.size();
				
				//Call method CancelOrder
				//controller2.CancelOrder();
				
				//Call method SendOrder
				controller2.SendOrder();
		   	test.stopTest();
		   	
            List<ORD_Order__c> orderListUpdated = [Select id, Status__c, TECH_NumberOfArticles__c from ORD_Order__c where id in :orderList];
            system.debug('>>>>>> orderListUpdated[0].Status :' + orderListUpdated[0].Status__c + ' >>>>>>> Pending ');
            system.assertEquals(orderListUpdated[0].Status__c, 'Pending');
            system.assertEquals(orderListUpdated[0].TECH_NumberOfArticles__c, 6);
	        
       	}//system.runAs(userList[0])
		    
    }// testMethod orderRecapTest
    
    static testMethod void orderRecapPendingStatusTest()
    {
    	System.Debug('## >>>>> Start VFC01_OrderRecap_TEST - orderRecapTest <<<<<'+UserInfo.getUserName());
    	
       	system.runAs(userList[0]){
	       	system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
	       	List<ORD_Order__c> orderList = new List<ORD_Order__c>{
	       		new ORD_Order__c(dealer__c = contactList[0].id
	       						 , Status__c = 'Pending'
	       						 , OrderDate__c = system.TODAY())
	       	};
		    insert(orderList);
		    
		    List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[7].Id
	        						 , RegularPrice__c = 100
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[0].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[1].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[2].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[3].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[4].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
	        						 , TECH_OrderStatus__c = 'Pending')
	        };
	        insert(orderLineList);
	        
	        test.startTest();
	        	PageReference orderRecapPage = Page.VFP01_OrderRecap_Italy;
	        	Test.setCurrentPage( orderRecapPage );
	        	
	        	//Add parameters to page URL
 				ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
 				ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
	        	
	        	//Instantiate Controller
	       	 	ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
        		VFC01_OrderRecap_Italy controller2 = new VFC01_OrderRecap_Italy(sc2);
				
				//Call method GetOrderLines
				controller2.GetOrderLines();
				boolean displayMsg = controller2.confMessage;
				controller2.getNumberCurrencyFormat();
				controller2.getZonePromoUrl();
				controller2.getAreaEmbededUrl();
				controller2.modifyOrder();
		   	test.stopTest();
		   	           
            List<ORD_Order__c> orderListUpdated = [Select id, Status__c, TECH_NumberOfArticles__c from ORD_Order__c where id in :orderList];
            system.debug('>>>>>> orderListUpdated[0].Status :' + orderListUpdated[0].Status__c + ' >>>>>>> Pending ');
            system.assertEquals(orderListUpdated[0].Status__c, 'Pending');
            //system.assertEquals(orderListUpdated[0].TECH_NumberOfArticles__c, 6);
            system.assertEquals(displayMsg, true);
	        
       	}//system.runAs(userList[0])
    }
       	
       	static testMethod void loyaltyProgramRecapTest()
    	{
    		System.Debug('## >>>>> Start VFC01_OrderRecap_TEST - orderRecapTest <<<<<'+UserInfo.getUserName());
    	
       		//system.runAs(userList[0]){
	       	//system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
	       		    
		    contactList1 = new List<Contact>{
     		new Contact(RecordTypeId = contactDealerRecordTypeID
     					, LastName = 'ContactTest1'
     					, Birthdate = system.Today() - 3650
     					, email = 'a@test1.com'
     					, STHID__c = 'test1'
     					, AccountId = accountList[0].id
     					, CurrentBalance__c = 100
     					, MinOrder__c=50
 						, MinOrderFreeTransportFees__c=50
 						, LoyaltyProgramToBeDisplayed__c = 'LP1;LP2;lp3;lp4;lp5;lp6;lp7;lp8;lp9;lp10;lp11;lp12;lp13;lp14;lp15;lp16;lp17;lp18;lp19;lp20;Adm;Com'
 						/*, LoyaltyProgram1Balance__c = 10
                        , LoyaltyProgram2Balance__c = 20
                        , LoyaltyProgram3Balance__c = 30
                        , LoyaltyProgram4Balance__c = 40
                        , LoyaltyProgram5Balance__c = 50
                        , LoyaltyProgram6Balance__c = 60
                        , LoyaltyProgram7Balance__c = 70
                        , LoyaltyProgram8Balance__c = 80
                        , LoyaltyProgram9Balance__c = 90
                        , LoyaltyProgram10Balance__c = 100
                        , LoyaltyProgram11Balance__c = 110
                        , LoyaltyProgram12Balance__c = 120
                        , LoyaltyProgram13Balance__c = 130
                        , LoyaltyProgram14Balance__c = 140
                        , LoyaltyProgram15Balance__c = 150
                        , LoyaltyProgram16Balance__c = 160
                        , LoyaltyProgram17Balance__c = 170
                        , LoyaltyProgram18Balance__c = 180
                        , LoyaltyProgram19Balance__c = 190
                        , LoyaltyProgram20Balance__c = 200
                        , AdminFeesAmount__c = 210
                        , CommissionsAmount__c = 220*/)};
        	insert contactList1;
        	
        	List<ORD_Order__c> orderList = new List<ORD_Order__c>{
	       		new ORD_Order__c(dealer__c = contactList1[0].id
	       						 , Status__c = 'Pending'
	       						 , OrderDate__c = system.TODAY())
	       	};
		    insert(orderList);
        	
        	List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[7].Id
	        						 , RegularPrice__c = 100
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[0].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
	        						 , TECH_OrderStatus__c = 'Pending'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[1].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[2].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[3].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
	        						 , TECH_OrderStatus__c = 'Pending'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[4].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
	        						 , TECH_OrderStatus__c = 'Pending')
	        };
	        insert(orderLineList);
	        
	        test.startTest();
	        	PageReference orderRecapPage = Page.VFP01_OrderRecap_Italy;
	        	Test.setCurrentPage( orderRecapPage );
	        	
	        	//Add parameters to page URL
 				ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
 				ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
	        	
	        	//Instantiate Controller
	       	 	ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
        		VFC01_OrderRecap_Italy controller2 = new VFC01_OrderRecap_Italy(sc2);
				
				//Call method GetOrderLines
				controller2.GetOrderLines();
				boolean displayMsg = controller2.confMessage;
				controller2.getDocumentAdvertUrl();
				
		   	test.stopTest();
		   	           
            List<ORD_Order__c> orderListUpdated = [Select id, Status__c, TECH_NumberOfArticles__c from ORD_Order__c where id in :orderList];
            system.debug('>>>>>> orderListUpdated[0].Status :' + orderListUpdated[0].Status__c + ' >>>>>>> Pending ');
            system.assertEquals(orderListUpdated[0].Status__c, 'Pending');
            system.assertEquals(displayMsg, true);
            
            
            	controller2.isDisplayButton=false;
				controller2.isOnlineOrder=true;
				controller2.reachCT();
            
            
            
    	//}		    
    }// testMethod orderRecapPendingStatusTest
}