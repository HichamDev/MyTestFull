@isTest
private class VFC01_OrderView_France_TEST {
/*
----------------------------------------------------------------------
-- - Name          : VFC01_OrderView_TEST 
-- - Author        : AMU
-- - Description   : This class contains unit tests for validating the 
--                   behavior of controller VFC01_OrderView
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 27-NOV-2012  AMU    1.0      Initial version                           
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
     static Id contactDealerRecordTypeID, DealerProfileId, offerRecordTypeID, bundleRecordTypeID, productRecordTypeID;
    
    static {
    	System.Debug('## >>>>> Start VFC01_OrderBasket_TEST >>> Inserting Data for Tests <<<<<'+UserInfo.getUserName());
    	
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
    }
    
    static testMethod void orderViewTest() {
    	System.Debug('## >>>>> Start VFC01_OrderBasket_TEST - orderAddressTest <<<<<'+UserInfo.getUserName());
    	
       	system.runAs(userList[0]){
	       	system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
	       	List<ORD_Order__c> orderList = new List<ORD_Order__c>{
	       		new ORD_Order__c(dealer__c = contactList[0].id
	       						 , Status__c = 'Draft'
	       						 , OrderDate__c = system.TODAY()),
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
	        						 , TECH_ArticleType__c = 'Child'),
	        	new ORL_OrderLine__c(Order__c = orderList[0].id
	        						 , Article__c = articleList[7].Id
	        						 , RegularPrice__c = 100
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Master'),
	        	new ORL_OrderLine__c(Order__c = orderList[1].id
	        						 , Article__c = articleList[0].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'),
	        	new ORL_OrderLine__c(Order__c = orderList[1].id
	        						 , Article__c = articleList[1].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 0
	        						 , TECH_ArticleType__c = 'Child'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[1].id
	        						 , Article__c = articleList[2].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[1].id
	        						 , Article__c = articleList[3].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 0
	        						 , TECH_ArticleType__c = 'Child'),	        	
	        	new ORL_OrderLine__c(Order__c = orderList[1].id
	        						 , Article__c = articleList[4].Id
	        						 , RegularPrice__c = 0
	        						 , Qty__c = 1
	        						 , TECH_ArticleType__c = 'Child')
	        };
	        insert(orderLineList);
	        
	        test.startTest();
	        	PageReference orderViewPage = Page.VFP01_OrderView_France;
	        	Test.setCurrentPage( orderViewPage );
	        	
	        	//Add parameters to page URL
	        	system.debug('>>>>>> orderList[0].Id: ' + orderList[0].Id);
 				ApexPages.currentPage().getParameters().put('Id',orderList[0].Id);
	        	
	        	//Instantiate Controller
	       	 	ApexPages.StandardController sc2 = new ApexPages.StandardController(orderList[0]);
        		VFC01_OrderView_France controller2 = new VFC01_OrderView_France(sc2);
				
				//Call method RedirectOrder
				controller2.RedirectOrder();
				String nextPage = controller2.RedirectOrder().getUrl();
				system.debug('>>>>>> nextPage' + nextPage);
				
				//Instantiate new page
				PageReference orderViewPage1 = Page.VFP01_OrderView_France;
	        	Test.setCurrentPage( orderViewPage1 );
	        	
	        	//Add parameters to page URL
	        	system.debug('>>>>>> orderList[1].Id: ' + orderList[1].Id);
 				ApexPages.currentPage().getParameters().put('Id',orderList[1].Id);
	        	ApexPages.currentPage().getParameters().put('ojv','t');
	        	//Instantiate Controller
	       	 	ApexPages.StandardController sc3 = new ApexPages.StandardController(orderList[1]);
        		VFC01_OrderView_France controller3 = new VFC01_OrderView_France(sc3);
				
				//Call method RedirectOrder
				controller3.RedirectOrder();
				String nextPage1 = controller3.RedirectOrder().getUrl();
				system.debug('>>>>>> nextPage1' + nextPage1);
		   	test.stopTest();
		   		   	
		/*   	system.debug('>>>>>> nextPage :' + nextPage + ' >>>>>>> /apex/vfp01_orderbasket?orderId=orderList[0].id&dealerId=orderList[0].dealer__c');
            system.assertEquals(nextPage, '/apex/vfp01_orderbasket?dealerId='+orderList[0].dealer__c+'&orderId='+orderList[0].id);
            
            system.debug('>>>>>> nextPage1 :' + nextPage1 + ' >>>>>>> /apex/vfp01_orderrecap?orderId=orderList[1].id&dealerId=orderList[1].dealer__c');
            system.assertEquals(nextPage1, '/apex/vfp01_orderrecap?dealerId='+orderList[1].dealer__c+'&orderId='+orderList[1].id);
            */
       }
    }
}