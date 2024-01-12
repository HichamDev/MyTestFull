@isTest
private class AP09_ContactBatchInterface_TEST {
/*
// AP09_ContactBatchInterface_TEST to check if OwnerId of Contact is replaced by the corresponding User id
----------------------------------------------------------------------
-- - Name          : AP09_ContactBatchInterface_TEST
-- - Author        : ASE
-- - Description   : test class to check  AP09_ContactBatchInterface
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 17-SEPT-2012  ASE    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
        
    static testMethod void updateContactOwner() {
    	system.debug('## Class AP09_ContactBatchInterface_TEST - START updateContactOwner <<<<<'+UserInfo.getUserName());
        list<User> userlist = new list<User>();
        
        //Selecting Profile Ids
        ID profileAdmin = [Select Id From Profile Where name = 'System Administrator' limit 1].id;
        system.debug('>>>>>>> profileAdmin: ' + profileAdmin);
        ID profileInterface = [Select Id From Profile Where name in ( 'Interface','System Interface') limit 1].id;
        system.debug('>>>>>>> profileInterface: ' + profileInterface);
        
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
        insert(userlist);    	           
    	system.debug('>>>>>>> userlist: ' + userlist);
        
        //Test with interface user
        System.runAs(user){
	        Account testAccount = new Account(TypeLabel__c= 'test'
	        								  , Name= 'test Account'
	                                          , CurrencyIsoCode= 'EUR'
	                                          , AccountType__c= 'Level 2'
	                                          , TECH_ACCOwnerExternalId__c = 'xyz'
	                                          ,Country_Code__c='FRA');
	        insert testAccount;
	        test.startTest();    
		        //creating contact
		        Contact testContact = new Contact(STHID__c='123'
		        								  , AccountId=testAccount.id
		        								  , CurrencyIsoCode = 'EUR' 
		                                          , lastname='br04Contact'
		                                          , email= 'br04Contact@sth.com'
		                                          , Birthdate =date.newinstance(1986, 12, 28)
												  , TECH_CONOwnerExternalId__c = 'xyz'
		                                          , MinOrder__c=50
		                                          , MinOrderFreeTransportFees__c=50);
		        insert testContact;
		        
	        test.stopTest();
	           
	        Id retrieveOwner =[select id from User where TECH_ExternalId__c = : testContact.TECH_CONOwnerExternalId__c].id;
	        system.debug('>>>>>>>>>>>>>>>> Owner id from User:' +retrieveOwner);
	    
	        Id updatedContact = [select OwnerId from Contact where id = :+testContact.Id].OwnerId;
	        system.debug('>>>>>>>>>>>>>>>> Owner id of Contact:' +updatedContact);
	    
	       // system.assertEquals(retrieveOwner, updatedContact);
        }
        system.debug('## Class AP09_ContactBatchInterface_TEST - END updateContactOwner <<<<<'+UserInfo.getUserName());  
    }
    
    static testMethod void updateContactMobileEmail() {
    	system.debug('## Class AP09_ContactBatchInterface_TEST - START updateContactMobileEmail <<<<<'+UserInfo.getUserName());
        list<User> userlist = new list<User>();
        
        //Selecting Profile Ids
        ID profileAdmin = [Select Id From Profile Where name = 'System Administrator' limit 1].id;
        system.debug('>>>>>>> profileAdmin: ' + profileAdmin);
        ID profileInterface = [Select Id From Profile Where name in ( 'Interface','System Interface') limit 1].id;
        system.debug('>>>>>>> profileInterface: ' + profileInterface);
        
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
        insert(userlist);    	           
    	system.debug('>>>>>>> userlist: ' + userlist);
        
        //Test with interface user
        System.runAs(user){
	        Account testAccount = new Account(TypeLabel__c= 'test'
	        								  , Name= 'test Account'
	                                          , CurrencyIsoCode= 'EUR'
	                                          , AccountType__c= 'Level 2'
	                                          , TECH_ACCOwnerExternalId__c = 'xyz'
	                                          , Country_Code__c='FRA');
	        insert testAccount;
	            
	        //creating contact
	        Contact testContact = new Contact(STHID__c='123'
	        								  , AccountId=testAccount.id
	        								  , CurrencyIsoCode = 'EUR'
	                                          , lastname='br04Contact'
	                                          , email= 'br04contact@sth.com'
	                                          , Birthdate =date.newinstance(1986, 12, 28)
											  , TECH_CONOwnerExternalId__c = 'xyz'
											  , MobilePhone = '567899' 
	                                          , MinOrder__c=50
	                                          , MinOrderFreeTransportFees__c=50);
	        insert testContact;

	        test.startTest();   
		        testContact.MobilePhone = '23456';
		        testContact.Email= 'Newbr04Contact@sth.com';
		        
		        update testContact; 
	        test.stopTest();  
	        
	        Contact updatedContact = [select id, MobilePhone, Email  from Contact where id = :testContact.Id];
	        system.debug('>>>>>>>>>>>>>>>>  id, MobilePhone, Email:' + updatedContact);
	        
	       /* system.assertEquals(updatedContact.MobilePhone,'567899' );     
	        system.assertEquals(updatedContact.Email,'br04contact@sth.com' ); */
        }
        system.debug('## Class AP09_ContactBatchInterface_TEST - END updateContactMobileEmail <<<<<'+UserInfo.getUserName());  
    }
    
    
}