/*
----------------------------------------------------------------------
-- - Name          : AP34_BatchTransferPCT.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Batch to transfer personal contact from inactive user to its corresponding active user
-- -                 .

-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 24-DEC-2014  WCH    1.0      Initial version

----------------------------------------------------------------------  
*/
global with sharing class AP34_BatchTransferPCT implements Database.Batchable<sobject>{
	
   global Set<Id> modifiedUserIds {get; set;}
	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	
   	
     
     String query = 'select Id, TECH_OLD_External_id__c from User where IsActive = false and TECH_HasBeenTransfered__c = false';
     system.debug('## Test.isRunningTest() ' + Test.isRunningTest());
    
     if(Test.isRunningTest()){
       query = 'select Id, TECH_OLD_External_id__c from User where IsActive = false and TECH_HasBeenTransfered__c = false order by CreatedDate desc limit 30';
     }
     
     system.debug('## query= ' + query);
     
     return Database.getQueryLocator(query);
   }


  
  /**
  * Transfer personal contact from inactive user to its corresponding active user
  */
   global void execute(Database.BatchableContext BC, List<sobject> scope){
     
    system.debug('## START AP34_BatchTransferPCT');
    
    map<String, Id> userExternalMapUserOld = new map<String, Id>();
    
    map<Id,Id> oldUserMapNewUser = new map<Id, Id>();
    
    set<String> externalIds = new Set<String>();
    
    modifiedUserIds  = new Set<Id>();
    
    system.debug('## scope' + scope.size());
     
    for(sobject so : scope){
    	
    	User user = (User) so;
    	
    	if(String.isNotBlank(user.TECH_OLD_External_id__c)){
    	
	        externalIds.add(user.TECH_OLD_External_id__c);
	        
	        userExternalMapUserOld.put(user.TECH_OLD_External_id__c, user.Id);
        
    	}
	  	
    }
    
    system.debug('## externalIds' + externalIds);
    
    system.debug('## userExternalMapUserOld' + userExternalMapUserOld);
    
    List<User> newUsers = [select Id, TECH_ExternalId__c from User where IsActive = true and TECH_ExternalId__c in : externalIds];
    
    
    for(User user : newUsers){
    	
    	if(userExternalMapUserOld.containsKey(user.TECH_ExternalId__c)){
    		
    		oldUserMapNewUser.put(userExternalMapUserOld.get(user.TECH_ExternalId__c), user.Id);
    		
    	}    	
    }
    
    
    List<PCT_PersonalContact__c> pcts = [select Id, OwnerId from PCT_PersonalContact__c where ownerId in : oldUserMapNewUser.keySet()];
    
    
    for(PCT_PersonalContact__c pct : pcts){
    	
    	if(oldUserMapNewUser.containsKey(pct.OwnerId)){
    	
    		modifiedUserIds.add(pct.OwnerId);
    		
    		pct.OwnerId = oldUserMapNewUser.get(pct.OwnerId);

    	}
    }
    
    update pcts;
    
    
    if(modifiedUserIds.size() > 0){
  	
  		List<User> users = [select Id, TECH_HasBeenTransfered__c from user where Id in : modifiedUserIds];   
  		
  		for(User user : users){
  			
  			user.TECH_HasBeenTransfered__c = true;
  		}    
 		
 		update users; 	
  	}           
    
    system.debug('## END AP34_BatchTransferPCT');
   }
   

  
  global void finish(Database.BatchableContext BC){
  	
  	
                    
                    
  }

}