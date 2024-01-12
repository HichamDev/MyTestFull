@isTest
private class AP09_UserBatchInterface_TEST {

/*
// AP09_UserBatchInterface_TEST for trigger UserBeforeUpdate
----------------------------------------------------------------------
-- - Name          : AP09_UserBatchInterface_TEST
-- - Author        : ASE
-- - Description   : test class for trigger UserBeforeUpdate
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 14-SEPT-2012  ASE    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/

    static testMethod void updateUserMobileEmail() {
        
         // Retrieving User Profile
        Profile profileInterface = [Select Id From Profile Where name in ( 'Interface','System Interface') limit 1];
        
        
    	User user = [select id, ProfileId from User where name = : system.label.USR00001 limit 1];
    	
    	//Test with iterface user
        System.runAs(user){
        
	        //Insert new user
	        User user1 =new User(alias = 'dealer', email='user1@sth.com', emailencodingkey='UTF-8', 
	                                                    lastname='testUser1',languagelocalekey='fr', localesidkey='fr_FR_EURO', 
	                                                    profileid = profileInterface.Id,timezonesidkey='Europe/Paris', 
	                                                    username='user1@sth.com',   MobilePhone= '34567', TECH_ExternalId__c= 'zyx');       
	        insert user1;
	        
	        system.debug('>>>>>>>>>>>>>>>> user1 inserted:' +user1);
	        system.debug('>>>>>>>>>>>>>>>> CreatedById:' +user1.CreatedById);
	        
	        test.startTest();   
	        
	        user1.MobilePhone = '23456';
	        user1.Email= 'newuser1@sth.com';
	        
	        update user1; 
	    
	        test.stopTest();  
	        User updatedUser = [select id, MobilePhone, Email  from User where id = :+user1.Id];
	        system.debug('>>>>>>>>>>>>>>>>  id, MobilePhone, Email:' +updatedUser);
	        
	        system.assertEquals(updatedUser.MobilePhone,'34567' );     
	        system.assertEquals(updatedUser.Email,'user1@sth.com' ); 
        }
        
    }
}