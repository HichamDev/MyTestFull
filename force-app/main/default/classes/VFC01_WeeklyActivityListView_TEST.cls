@isTest
private class VFC01_WeeklyActivityListView_TEST {
/*
----------------------------------------------------------------------
-- - Name          : VFC01_WeeklyActivityListView_TEST 
-- - Author        : AMU
-- - Description   : This class contains unit tests for validating the 
--                   behavior of controller VFP01_WeeklyActivityListView
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 14-DEC-2012  AMU    1.0      Initial version                           
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
    }
      	
    static testMethod void weeklyActListTest() {
        System.Debug('## >>>>> Start VFC01_WeeklyActivityListView_TEST - weeklyActListTest <<<<<'+UserInfo.getUserName());
    	
       	system.runAs(userList[0]){
       		system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
	       	List<WAT_WeeklyActivity__c> watList = new List<WAT_WeeklyActivity__c>{
	       		new WAT_WeeklyActivity__c(dealer__c = contactList[0].id
	       								  , Name = 'Test'
	       								  , NbrOfMeetings__c = 1
	       								  , AvgNbrAttendees__c = 1
	       								  , AvgSales__c = 100
	       						 		  , Status__c = 'Draft')
	       	};
		    insert(watList);
		    
		    
		    test.startTest();
	        	PageReference watListPage = Page.VFP01_WeeklyActivityListView;
	        	Test.setCurrentPage( watListPage );
	        	
	        	ApexPages.StandardSetController ssc = new ApexPages.Standardsetcontroller(watList);
	        	VFC01_WeeklyActivityListView ord = new VFC01_WeeklyActivityListView();
	        	ord.wkActSet = null;
	        	
	        	ord.getWeeklyAct();
		   	test.stopTest();
       	}
    }
}