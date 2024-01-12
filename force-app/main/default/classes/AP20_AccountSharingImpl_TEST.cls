/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AP20_AccountSharingImpl_TEST{
/*
    static testMethod void myUnitTest() {
       
    	Test.startTest();
    	
    	Account parent = createAccount('parent');
    
 		Account child = createAccount('child');   
    
    	User userParent = createUser('parent');
    	
    	User userChild= createUser('child');
    	
    	parent.OwnerId = userParent.Id;
    	
    	child.OwnerId = userChild.Id;
    	
    	child.ParentId = parent.Id;
    	
    	
    	update parent;
    	
    	update child;
    	
    	system.assert(getShare(parent.OwnerId, child.Id) == 1);
    	
    	
    	delete parent;
    	
    	//system.assert(getShare(userParent.Id, child.Id) == 0);
    	
  		Test.stopTest();
    
    }
    
    static Integer getShare(Id owner, Id account){
    	
    	List<AccountShare> lists = [select UserOrGroupId from AccountShare where UserOrGroupId =: owner and AccountId =: account];

    	return lists.size();

   
    }
    
     static  User createUser(String sthId){
        
        Profile p = [SELECT id, Name FROM Profile where name = 'FRA_Dealers Manager'].get(0);  
        
        User u = new User( //STHUniqueID__c= sthId,
                          firstname= 'BR04',
                          lastname='XXXX',
                          Alias='BR04',
                          email = 'BR04@XXXXX.com',
                          username= sthId+'BR04@XXXXX.com', 
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles',
                          phone = '123456789'
                         
                          );
        insert u;
                
        return u;
    }
  
    

    
    static Account createAccount(String name){
    
        String acc_name = name;
        
        Account acct = new Account(name=acc_name, Country_Code__c='FRA');
        insert acct;
        
        return acct;
    }
    
    
 */   
}