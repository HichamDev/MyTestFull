/*
----------------------------------------------------------------------
-- - Name          : AP20_BatchAccountSharing_TEST.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Test class for account sharing.
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 17-DEC-2013  NGO    1.0      Initial version

----------------------------------------------------------------------	
*/

@isTest
private class AP20_BatchAccountSharing_TEST {

    static testMethod void createSharingUnitTest() {
    	
        Test.startTest();
    	
    	Account root = createAccount('root', 'FRA', '4');
    	
    	Account parent = createAccount('parent', 'FRA', '4');
    
 		Account child = createAccount('child', 'FRA', '4'); 

        Account child2 = createAccount('child', 'FRA', '3'); 

        Account rootITA = createAccount('root', 'ITA', '5');
    	
    	Account parentITA = createAccount('parent', 'ITA', '5');
    
 		Account childITA = createAccount('child', 'ITA', '5'); 
 		
 		User userRoot = createUser('root');  
    
    	User userParent = createUser('parent');
    	
    	User userChild= createUser('child');
    	
    	root.OwnerId = userRoot.Id;
    	
    	parent.OwnerId = userParent.Id;
    	
        child.OwnerId = userChild.Id;
        child2.OwnerId = userChild.Id;
    	
    	parent.ParentId = root.Id;
    	
        child.ParentId = parent.Id;
        child2.OwnerId = child.Id;

    	update parent;
    	
    	update child;    

        AP20_SchFRA_BatchAccountSharing  SchFRA = new AP20_SchFRA_BatchAccountSharing ();
        
        AP20_SchESP_BatchAccountSharing  SchESP = new AP20_SchESP_BatchAccountSharing ();
         
        AP20_SchITA_BatchAccountSharing  SchITA = new AP20_SchITA_BatchAccountSharing ();
         
        AP20_SchMEX_BatchAccountSharing  SchMEX = new AP20_SchMEX_BatchAccountSharing ();
          
        AP20_SchVEN_BatchAccountSharing  SchVEN = new AP20_SchVEN_BatchAccountSharing ();
        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing AP15_BatchWeeklyActivity FRA', sch, SchFRA);
        
        system.schedule('Testing AP15_BatchWeeklyActivity ESP', sch, SchESP);
        
        system.schedule('Testing AP15_BatchWeeklyActivity ITA', sch, SchITA);
        
        system.schedule('Testing AP15_BatchWeeklyActivity MEX', sch, SchMEX);
        
        system.schedule('Testing AP15_BatchWeeklyActivity VEN', sch, SchVEN);
        
        AP20_BatchAccountSharing batchAccountSharing = new AP20_BatchAccountSharing('FRA');
        
        system.AssertEquals('FRA', batchAccountSharing.country);
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(batchAccountSharing);

        AP20_BatchAccountSharing batchAccountSharingITA = new AP20_BatchAccountSharing('ITA');

        Id batchprocessidITA = Database.executeBatch(batchAccountSharing);
        
        Test.StopTest(); 
      	
      	AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        
        system.AssertEquals('Completed', apexJob.status);
        
        system.AssertEquals(0, apexJob.NumberOfErrors);

    	system.AssertEquals(1, getShare(parent.OwnerId, child.Id));	
    	
    	//delete parent;
    	
    	//system.AssertEquals(0, getShare(userParent.Id, child.Id));
    			
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
    
    static Account createAccount(String name, String countryCode, String type){
    
        String acc_name = name;
        
        Account acct = new Account(
            name=acc_name, 
            Country_Code__c = countryCode,
            Type = type);
        insert acct;
        
        return acct;
    }
}