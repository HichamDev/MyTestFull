@isTest
private class VFC19_ApplicationAccess_TEST {
	 static List<Account> accountList;
     static List<Contact> contactList;
     static List<User> userList;
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
 						, MinOrderFreeTransportFees__c=50
 						, TECH_ApplicationDateSent__c = system.now()),
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
    }
    static testMethod void ApplicationAccessTest() {
    	AP19_ApplicationResponse appRes = new AP19_ApplicationResponse();
    	
    	list<AP19_ApplicationResponse> appResList;
    	appResList = new list<AP19_ApplicationResponse>{
    		new AP19_ApplicationResponse('YGOtest','desc 1','google.com','123.com'),
    		new AP19_ApplicationResponse('YGOtest1', 'desc 2', 'google2.com', '456.com')
    	};
    	
    	string str = JSON.serialize(appResList);
    	contactList[0].TECH_ApplicationAcessUrl__c = str;
    	
    	update contactList[0];
        
        system.runAs(userList[0])
        {
        	test.startTest();
	        	PageReference appAcc = Page.VFP19_ApplicationAccess;
	        	Test.setCurrentPage( appAcc );
	        	
	        	ApexPages.StandardSetController ssc = new ApexPages.Standardsetcontroller(contactList);
	        	VFC19_ApplicationAccess sso = new VFC19_ApplicationAccess();
	        	
	        	sso.synchronizeApps();
	     	test.stopTest();  
        }//system.runAs
    }
    
    static testMethod void ApplicationAccessTest1() {
    	AP19_ApplicationResponse appRes = new AP19_ApplicationResponse();
    	
    	list<AP19_ApplicationResponse> appResList;
    	appResList = new list<AP19_ApplicationResponse>{
    		new AP19_ApplicationResponse('YGOtest','desc 1','google.com','123.com'),
    		new AP19_ApplicationResponse('YGOtest1', 'desc 2', 'google2.com', '456.com')
    	};
    	
    	string str = JSON.serialize(appResList);
    	contactList[1].TECH_ApplicationAcessUrl__c = str;
    	
    	update contactList[1];
        
        system.runAs(userList[1])
        {
        	test.startTest();
	        	PageReference appAcc = Page.VFP19_ApplicationAccess;
	        	Test.setCurrentPage( appAcc );
	        	
	        	ApexPages.StandardSetController ssc = new ApexPages.Standardsetcontroller(contactList);
	        	VFC19_ApplicationAccess sso = new VFC19_ApplicationAccess();
	        	
	        	sso.synchronizeApps();
	     	test.stopTest();  
        }//system.runAs
    }
}