/* 
------------------------------------------------------------
-- - Name          : AP21_UserConversion_TEST 
-- - Author        : NGO
-- - Description   : Test class to test user profile conversion
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 03-JUL-2013  NGO    1.0    Initial version
------------------------------------------------------------
*/
@isTest(SeeAllData = true)
private class AP21_UserConversion_TEST {

    static testMethod void myUnitTest() {
    	
        User user = [select id, ProfileId from User where name = : system.label.USR00001 limit 1];
    	
    	Test.startTest();
    	
    	//Test with iterface user
        System.runAs(user){	
       
	       Contact one = createContact('AP21_01');
	       
	       Contact two = createContact('AP21_02');
	       
	       Profile pDealer = [SELECT id, Name FROM Profile where name = : system.label.CON00001].get(0);
	       
	       Profile pDealerManager = [SELECT id, Name FROM Profile where name = : system.label.CON00002].get(0);
	       
	       User userOne = createUser(pDealer.Id, 'AP21_01', one);
	       
	       User userTwo = createUser(pDealerManager.Id, 'AP21_02', two);
	
		   userOne.ProfileId = 	pDealerManager.Id;
		   
		   userTwo.ProfileId = pDealer.Id;
		   
		   update userOne;
		   
		   update userTwo;
		   
		   system.debug('>>>>>>List : ' + [select Id, username from User where Id =: userOne.Id]);	
		   
		   system.assertEquals([select Id from User where username like '%ap21_01@sth.com%'].size(), 1);
		   
		   createUser(pDealerManager.Id, 'AP21_01', one);
		   
		   system.assertEquals([select Id from User where username = 'ap21_01@sth.com'].size(), 1);

		   system.assertEquals([select Id from User where username like '%ap21_02@sth.com%'].size(), 1);
		   
		   createUser(pDealer.Id, 'AP21_02', two);
		   
		   system.assertEquals([select Id from User where username = 'ap21_02@sth.com'].size(), 1);
	   
       }
       
       Test.stopTest();
		
    }
    
     static testMethod void testDealer() {
    	
        User user = [select id, ProfileId from User where name = : system.label.USR00001 limit 1];
    	
    	Test.startTest();
    	
    	//Test with iterface user
        System.runAs(user){	
       
	       Contact one = createContact('AP21_01');
	       
	       Contact two = createContact('AP21_02');
	       
	       Profile pDealer1 = [SELECT id, Name FROM Profile where name = 'FRA_Dealer'].get(0);
	       
	       Profile pDealer2 = [SELECT id, Name FROM Profile where name = 'ESP_Dealer'].get(0);
	       
	       User userOne = createUser(pDealer1.Id, 'AP21_01', one);
	       
	       User userTwo = createUser(pDealer2.Id, 'AP21_02', two);
	
		   userOne.ProfileId = pDealer2.Id;
		   
		   userTwo.ProfileId = pDealer1.Id;
		   
		   update userOne;
		   
		   update userTwo;
		   
		   system.debug('>>>>>>List : ' + [select Id, username from User where Id =: userOne.Id]);	
		   
		   system.assertEquals([select Id from User where username = 'ap21_01@sth.com'].size(), 1);
		   
		   //createUser(pDealerManager.Id, 'AP21_01', one);
		   
		   //system.assertEquals([select Id from User where username = 'ap21_01@sth.com'].size(), 1);

		   system.assertEquals([select Id from User where username = 'ap21_02@sth.com'].size(), 1);
		   
		   //createUser(pDealer.Id, 'AP21_02', two);
		   
		   //system.assertEquals([select Id from User where username = 'ap21_02@sth.com'].size(), 1);
	   
       }
       
       Test.stopTest();
		
    }
    
    
    static  User createUser(Id profile, String techExternalId, Contact contact){

        User u = new User( 
                          firstname= 'BR04',
                          lastname='XXXX',
                          Alias='BR04',
                          email = 'BR04@XXXXX.com',
                          username= techExternalId+'@sth.com', 
                          profileId= profile, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles',
                          TECH_ExternalId__c = techExternalId,
                          TECH_ContactID__c = contact.TECH_ExternalId__c
                          );
        insert u;
                
        return u;
    }
  
    
    static  Contact createContact(String sthId){

        Contact contact = new Contact(STHID__c=sthId,TECH_ExternalId__c = sthId, AccountId=createAccount(), lastname=sthId,firstname='br04Contact', MinOrder__c=50, MinOrderFreeTransportFees__c=50);
        
        insert contact;
       
        return contact;
    }
    
    static Id createAccount(){
    
        String acc_name = 'Test Account BR04';
        
        Account acct = new Account(name=acc_name, Country_Code__c='FRA');
        insert acct;
        
        return acct.Id;
    }
    
}