@isTest
private class VFC01_OrderAddress_Italy_TEST {
/*
----------------------------------------------------------------------
-- - Name          : VFC01_OrderAddress_TEST 
-- - Author        : AMU
-- - Description   : This class contains unit tests for validating the 
--                   behavior of controller VFC01_OrderAddress
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 14-NOV-2012  AMU    1.0      Initial version                           
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
     static Id contactDealerRecordTypeID, DealerProfileId, offerRecordTypeID, bundleRecordTypeID, productRecordTypeID, artFeeRecordTypeID;
    
    static {
    	System.Debug('## >>>>> Start VFC01_OrderBasket_TEST >>> Inserting Data for Tests <<<<<'+UserInfo.getUserName());
    	
    	//Retrieving Record Type related to Contact
	   	contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
     	system.debug('>>>>>> contactDealerRecordTypeID : ' + contactDealerRecordTypeID);
     	
     	//Retrieving Record Type related to Article
 		//Offer
	 	offerRecordTypeID   = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00001 and SObjectType = 'ART_Article__c' Limit 1].id;
	 	
	 	//Bundle
	 	bundleRecordTypeID  = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00002 and SObjectType = 'ART_Article__c' Limit 1].id;
	 	
	 	//Product
	 	productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
     	
     	//Fee
	 	artFeeRecordTypeID  = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00004 and SObjectType = 'ART_Article__c' Limit 1].id;
     	
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
     					, MailingStreet = 'Street1'
 						, MailingState = 'State1'
 						, MailingPostalCode = 'PC1'
 						, MailingCountry = 'France'
 						, MailingCity = 'City1'
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
     				 , Localesidkey='fr_FR_EURO'
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
								, Number_of_Articles__c = 3),
			new ART_Article__c (//Fee
								RecordTypeId = artFeeRecordTypeID   //articleList[8]
								, Name = 'ArticleFee'
								, LocalName__c = 'ArticleFee')						
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
        							  , Article__c = articleList[7].Id),
        	new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
        							  , Name = 'Fee1'
        							  , Active__c = true
        							  , RegularPrice__c = 10
        							  , Article__c = articleList[8].Id)
        };
        insert(catArticleList);
        system.debug('>>>>>> catArticleList : ' + catArticleList);


        // IK - Add with Colissimo project

        Shipping_Mode__c modeStandardFR = new Shipping_Mode__c();
        modeStandardFR.Name = 'ModeStandardFR';
        modeStandardFR.Active__c = true;
        modeStandardFR.Country__c = 'FR';
        modeStandardFR.Default_selected__c = true;
        modeStandardFR.Label__c = 'Standard';
        modeStandardFR.Mode__c = 'Standard';
        modeStandardFR.Order__c = 1;
        modeStandardFR.Picture_URL__c = null;
        modeStandardFR.PickUpStation_Type__c = null;
        modeStandardFR.Service_URL__c = null;
        modeStandardFR.Service_Login__c = null;
        modeStandardFR.Service_Password__c = null;
        modeStandardFR.Service_Param_Text_1__c = null;
        modeStandardFR.Service_Param_Text_2__c = null;
        modeStandardFR.Timeout__c = 10000;
        modeStandardFR.Profile_Applicable_for__c = '*';
        modeStandardFR.UID__c = 'FR_Standard';
        insert modeStandardFR;
        Shipping_Mode__c modeColissimoFR = new Shipping_Mode__c();
        modeColissimoFR.Name = 'modeColissimoFR';
        modeColissimoFR.Active__c = true;
        modeColissimoFR.Country__c = 'FR';
        modeColissimoFR.Default_selected__c = false;
        modeColissimoFR.Label__c = 'Colissimo';
        modeColissimoFR.Mode__c = 'Externe_Colissimo';
        modeColissimoFR.Order__c = 2;
        modeColissimoFR.Picture_URL__c = null;
        modeColissimoFR.PickUpStation_Type__c = 'A2P;CMT';
        modeColissimoFR.Service_URL__c = 'https://ws.colissimo.fr/pointretrait-ws-cxf/PointRetraitServiceWS/2.0';
        modeColissimoFR.Service_Login__c = 'login';
        modeColissimoFR.Service_Password__c = 'password';
        modeColissimoFR.Service_Param_Text_1__c = '1';
        modeColissimoFR.Service_Param_Text_2__c = '1';
        modeColissimoFR.Timeout__c = 10000;
        modeColissimoFR.Profile_Applicable_for__c = '*';
        modeColissimoFR.UID__c = 'FR_Colissimo';
        modeColissimoFR.Param_Text_1__c = '1';
        insert modeColissimoFR;

        Shipping_Fees__c modeStandardFRFee1 = new Shipping_Fees__c();
        modeStandardFRFee1.Name = '1';
        modeStandardFRFee1.Amount_operator__c = '>';
        modeStandardFRFee1.Amount_value__c = 0;
        modeStandardFRFee1.Order_type__c = 'BtoBtoC';
        modeStandardFRFee1.Shipping_Mode__c = 'FR_Standard';
        modeStandardFRFee1.Weight_Operator__c = '<';
        modeStandardFRFee1.Weight_value__c = 25;
        insert modeStandardFRFee1;
        Shipping_Fees__c modeStandardFRFee2 = new Shipping_Fees__c();
        modeStandardFRFee2.Name = '2';
        modeStandardFRFee2.Amount_operator__c = '>';
        modeStandardFRFee2.Amount_value__c = 0;
        modeStandardFRFee2.Order_type__c = 'BtoBtoC';
        modeStandardFRFee2.Shipping_Mode__c = 'FR_Standard';
        modeStandardFRFee2.Weight_Operator__c = '>=';
        modeStandardFRFee2.Weight_value__c = 25;
        insert modeStandardFRFee2;
        Shipping_Fees__c modeColissimoFRFee1 = new Shipping_Fees__c();
        modeColissimoFRFee1.Name = '3';
        modeColissimoFRFee1.Amount_operator__c = '>';
        modeColissimoFRFee1.Amount_value__c = 0;
        modeColissimoFRFee1.Order_type__c = 'BtoBtoC';
        modeColissimoFRFee1.Shipping_Mode__c = 'FR_Colissimo';
        modeColissimoFRFee1.Weight_Operator__c = '<';
        modeColissimoFRFee1.Weight_value__c = 25;
        insert modeColissimoFRFee1;
        Shipping_Fees__c modeColissimoFRFee2 = new Shipping_Fees__c();
        modeColissimoFRFee2.Name = '4';
        modeColissimoFRFee2.Amount_operator__c = '>';
        modeColissimoFRFee2.Amount_value__c = 0;
        modeColissimoFRFee2.Order_type__c = 'BtoBtoC';
        modeColissimoFRFee2.Shipping_Mode__c = 'FR_Colissimo';
        modeColissimoFRFee2.Weight_Operator__c = '>=';
        modeColissimoFRFee2.Weight_value__c = 25;
        insert modeColissimoFRFee2;

        Shipping_Mode_Excluded__c modeColissimoExcluded1 = new Shipping_Mode_Excluded__c();
        modeColissimoExcluded1.Name = '1';
        modeColissimoExcluded1.Shipping_Mode__c = 'FR_Colissimo';
        modeColissimoExcluded1.Zip_code__c = '44*';
        insert modeColissimoExcluded1;
        Shipping_Mode_Excluded__c modeColissimoExcluded2 = new Shipping_Mode_Excluded__c();
        modeColissimoExcluded2.Name = '2';
        modeColissimoExcluded2.Shipping_Mode__c = 'FR_Colissimo';
        modeColissimoExcluded2.Zip_code__c = '95000';
        insert modeColissimoExcluded2;


        CountryCode_Name__c fr = new CountryCode_Name__c();
        fr.Name = 'FRA';
        fr.CountryName__c = 'France';
        fr.Iso_Code__c = 'FR';
        insert fr;

        STHEndpoints__c endFr = new STHEndpoints__c();
        endFr.Name = 'FRA';
        endFr.Google_Timeout__c = 10000;
        endFr.Google_Endpoint__c = 'http://google.fr';
        endFr.Google_Crypto_Key__c = 'crypto';
        endFr.Google_Client_Id__c = 'clientID';
        endFr.Google_Channel_Id__c = 'channel';
        insert endFr;
        // \ IK
    }
    
    static testMethod void orderAddressTest() {
    	System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - orderAddressTest <<<<<'+UserInfo.getUserName());
    	
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
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 200),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[0].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[1].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 0
	        						 , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[2].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[3].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 0
	        						 , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[4].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1)
	        };
	        insert(orderLineList);
	        
	        test.startTest();
	        	PageReference orderAddressPage = Page.VFP01_OrderAddress_Italy;
	        	Test.setCurrentPage( orderAddressPage );
	        	        	
	        	//Add parameters to page URL
 				ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
 				ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
	        	
	        	//Instantiate Controller
	       	 	ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
        		VFC01_OrderAddress_Italy controller2 = new VFC01_OrderAddress_Italy(sc2);
        		
        		//List<selectOption> getItems = controller2.getItems();
        		
        		controller2.exceptionalCountry = 'France';
				//List<selectOption> getDeliveryCountry = controller2.getDeliveryCountry();
				//List<selectOption> getDeliveryMode = controller2.getDeliveryMode();
				
				//Assign delMode
				//controller2.delMode = catArticleList[1].Id;
				
				//Assing value to deliveryStreet and call method CheckAddress
				controller2.deliveryStreet = 'ExceptionalAdd';
				controller2.CheckAddress();
				
				controller2.deliveryStreet = 'ExistingAdd';
				controller2.CheckAddress();
				
				//Call method ValidateAddress
				//controller2.ValidateAddress();
				
				//Call method CancelOrder
				controller2.CancelOrder();
		   	test.stopTest();
		   	 
  		  /* 	system.debug('>>>>>> controller2.existingStreet :' + controller2.existingStreet + ' >>>>>>> contactList[0].MailingStreet: ' + contactList[0].MailingStreet);
            system.assertEquals(controller2.existingStreet, contactList[0].MailingStreet);
            
            system.debug('>>>>>> controller2.existingCity :' + controller2.existingCity + ' >>>>>>> contactList[0].MailingCity: ' + contactList[0].MailingCity);
            system.assertEquals(controller2.existingCity, contactList[0].MailingCity);
            
            system.debug('>>>>>> controller2.existingState :' + controller2.existingState + ' >>>>>>> contactList[0].MailingState: ' + contactList[0].MailingState);
            system.assertEquals(controller2.existingState, contactList[0].MailingState);
            
            system.debug('>>>>>> controller2.existingPostalCode :' + controller2.existingPostalCode + ' >>>>>>> contactList[0].MailingPostalCode: ' + contactList[0].MailingPostalCode);
            system.assertEquals(controller2.existingPostalCode, contactList[0].MailingPostalCode);
            
            system.debug('>>>>>> controller2.exceptionalCountry :' + controller2.exceptionalCountry + ' >>>>>>> contactList[0].MailingCountry: ' + contactList[0].MailingCountry);
            system.assertEquals(controller2.exceptionalCountry, contactList[0].MailingCountry);*/
       }
    }
    

    static testMethod void orderAddressTest1() {
    	System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - orderAddressTest <<<<<'+UserInfo.getUserName());
    	
       	system.runAs(userList[1]){
	       	system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
	       	List<ORD_Order__c> orderList = new List<ORD_Order__c>{
	       		new ORD_Order__c(dealer__c = contactList[1].id
	       						 , Status__c = 'Draft'
	       						 , OrderDate__c = system.TODAY())
	       	};
		    insert(orderList);
		      
	        List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[7].Id
	        						 , RegularPrice__c = 100
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[0].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[1].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 0
	        						 , TECH_ArticleType__c = 'Child'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[2].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[3].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 0
	        						 , TECH_ArticleType__c = 'Child'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[4].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child')
	        };
	        insert(orderLineList);
	        
	        test.startTest();
	        	PageReference orderAddressPage = Page.VFP01_OrderAddress_Italy;
	        	Test.setCurrentPage( orderAddressPage );
	        	        	
	        	//Add parameters to page URL
 				ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
 				ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
	        	
	        	//Instantiate Controller
	       	 	ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
        		VFC01_OrderAddress_Italy controller2 = new VFC01_OrderAddress_Italy(sc2);
        		
        		//List<selectOption> getItems = controller2.getItems();
        		
        		controller2.exceptionalCountry = 'France';
				//List<selectOption> getDeliveryCountry = controller2.getDeliveryCountry();
				//List<selectOption> getDeliveryMode = controller2.getDeliveryMode();
				
				//Assign delMode
				//controller2.delMode = catArticleList[1].Id;
				
				//Assing value to deliveryStreet and call method CheckAddress
				controller2.deliveryStreet = 'EXC';
				controller2.CheckAddress();
				
				controller2.deliveryStreet = 'HAB';
				controller2.CheckAddress();
				
				controller2.modifyOrder();
				controller2.getZonePromoUrl();
				controller2.getAreaEmbededUrl();
				controller2.getNumberCurrencyFormat();
				//controller2.getDeliveryMode();
				controller2.CheckDeliveryMode();
				controller2.getItemss();
				controller2.getDocumentAdvertUrl();
				List<string> theFieldNames=new List<string>();
				theFieldNames.add('Status__c');
				controller2.getFieldLabel(theFieldNames);
				controller2.callAllPrivateFunctionForTestClass();
		   	test.stopTest();
       }
    }

    static testMethod void orderAddressTest3() {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - orderAddressTest3 <<<<<'+UserInfo.getUserName());
        
        system.runAs(userList[0]){
            system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
            List<ORD_Order__c> orderList = new List<ORD_Order__c>{
                new ORD_Order__c(dealer__c = contactList[0].id
                                 , Status__c = 'Draft'
                                 , OrderDate__c = system.TODAY()
                                 , CustomerMobile__c = '0677887766')
            };
            insert(orderList);
              
            List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[7].Id
                                     , RegularPrice__c = 100
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Master'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 200),
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[0].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[1].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 0
                                     , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[2].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[3].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 0
                                     , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[4].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1)
            };
            insert(orderLineList);
            
            Test.setMock(WebServiceMock.class, new ColissimoService_HttpMock());
            Test.setMock(HttpCalloutMock.class, new ColissimoService_HttpMock());

            test.startTest();
                PageReference orderAddressPage = Page.VFP01_OrderAddress_Italy;
                Test.setCurrentPage( orderAddressPage );
                            
                //Add parameters to page URL
                ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
                ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
                
                //Instantiate Controller
                ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
                VFC01_OrderAddress_Italy controller2 = new VFC01_OrderAddress_Italy(sc2);
                
                //List<selectOption> getItems = controller2.getItems();
                
                system.debug('>>>> before searchPointsAround');
                
                ApexPages.currentPage().getParameters().put('searchType','Usual');
                controller2.searchPointsAround();  

                ApexPages.currentPage().getParameters().put('identifiant','19199284');
                controller2.updateSelectedPickUpStation();


                controller2.checkBeforeValidate();

                controller2.colissimoSelectAddress();
                controller2.CheckAddress();
                controller2.standardSelectAddress();
                ApexPages.currentPage().getParameters().put('mode','Standard');
                controller2.updateSelectedMode();


                controller2.getNumberCurrencyFormat();


                controller2.modifyOrder();
                
            test.stopTest();
             
        }
    }

    static testMethod void orderAddressTest4() {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - orderAddressTest4 <<<<<'+UserInfo.getUserName());
        
        system.runAs(userList[0]){
            system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
            List<ORD_Order__c> orderList = new List<ORD_Order__c>{
                new ORD_Order__c(dealer__c = contactList[0].id
                                 , Status__c = 'Draft'
                                 , OrderDate__c = system.TODAY()
                                 , PickUpStation_Street1__c = '24 mail pablo picasso'
                                 , PickUpStation_PostalCode__c = '44000'
                                 , PickUpStation_City__c = 'Nantes'
                                 , PickUpStation_Country__c = 'France')
            };
            insert(orderList);
              
            List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[7].Id
                                     , RegularPrice__c = 100
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Master'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 200),
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[0].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[1].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 0
                                     , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[2].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[3].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 0
                                     , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1),                
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[4].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'
                                     , ValidTotalAmountBase__c = true
                                     , AmountWihtoutTax__c = 1)
            };
            insert(orderLineList);
            
            Test.setMock(WebServiceMock.class, new ColissimoService_HttpMock());
            Test.setMock(HttpCalloutMock.class, new ColissimoService_HttpMock());

            test.startTest();
                PageReference orderAddressPage = Page.VFP01_OrderAddress_Italy;
                Test.setCurrentPage( orderAddressPage );
                            
                //Add parameters to page URL
                ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
                ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
                
                //Instantiate Controller
                ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
                VFC01_OrderAddress_Italy controller2 = new VFC01_OrderAddress_Italy(sc2);
                
                //List<selectOption> getItems = controller2.getItems();
                
                system.debug('>>>> before searchPointsAround');
                
                ApexPages.currentPage().getParameters().put('searchType','Usual');
                controller2.searchPointsAround();  



                controller2.colissimoSelectAddress();
                controller2.CheckAddress();
                controller2.colissimoSelectAddress();
                ApexPages.currentPage().getParameters().put('mode','Standard');
                controller2.updateSelectedMode();


                controller2.getNumberCurrencyFormat();


                controller2.modifyOrder();
                
            test.stopTest();
             
        }
    }

    static testMethod void orderAddressTest5() {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - orderAddressTest5 <<<<<'+UserInfo.getUserName());
        
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
                                     , TECH_ArticleType__c = 'Master')
            };
            insert(orderLineList);
            
            test.startTest();
                PageReference orderAddressPage = Page.VFP01_OrderAddress_Italy;
                Test.setCurrentPage( orderAddressPage );
                            
                //Add parameters to page URL
                ApexPages.currentPage().getParameters().put('orderId',orderList[0].Id);
                ApexPages.currentPage().getParameters().put('dealerId',orderList[0].Dealer__c);
                
                //Instantiate Controller
                ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
                VFC01_OrderAddress_Italy controller2 = new VFC01_OrderAddress_Italy(sc2);
                
                system.debug('>>> test controller2.lShippingModeDisplayed: ' + controller2.lShippingModeDisplayed);
                // Select standard mode + usual address
                for (VFC01_OrderAddress_Italy.ShippingModeDisplayed mode : controller2.lShippingModeDisplayed) {
                    if (mode.mode.UID__c == 'FR_Standard') {
                        controller2.selectedShippingMode = mode.mode; break;
                    }
                }
                ApexPages.currentPage().getParameters().put('mode','HAB');
                controller2.standardSelectAddress();

                controller2.checkBeforeValidate();
                
            test.stopTest();
       }
    }
}