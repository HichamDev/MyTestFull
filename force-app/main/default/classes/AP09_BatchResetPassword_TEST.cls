/*
----------------------------------------------------------------------
-- - Name          : AP09_SchBatchResetPassword_TEST.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Scheduler to reset newly created user's password
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 08-APR-2014  NGO    1.0      Initial version
----------------------------------------------------------------------  
*/
@isTest
private class AP09_BatchResetPassword_TEST {

    static testMethod void myUnitTest() {
        
        Test.startTest();
        
        Integer numberOfuser = 250;
        
        List<User> users = new List<User>();
        
        Profile p = [SELECT id, Name FROM Profile where name = 'FRA_Dealers Manager'].get(0);
        
        for(Integer i = 0; i < numberOfUser; i++ ){
        
            users.add(createUser('0'+i, p));
        }
        
        insert users;
        
        List<User> updatedUser = [select Id, TECH_IsResetPassword__c From User where TECH_IsResetPassword__c = true];
        
        Set<Id> userIds = new Set<Id>();
        
        //system.AssertEquals(numberOfuser, updatedUser.size());
        
        for(User user : users){
            
            system.debug('user.TECH_IsResetPassword__c '+user.Id+' ' + user.TECH_IsResetPassword__c);
            System.assert(user.TECH_IsResetPassword__c);
            userIds.add(user.Id);
            
        }
        
        AP09_SchBatchResetPassword  SchFRA = new AP09_SchBatchResetPassword ();

        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing AP15_BatchWeeklyActivity FRA', sch, SchFRA);
        
        AP09_BatchResetPassword batchResetPassword = new AP09_BatchResetPassword();
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(batchResetPassword, 149);
        
        Test.StopTest(); 
        
        AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        
        system.AssertEquals('Completed', apexJob.status);
        
        system.AssertEquals(0, apexJob.NumberOfErrors);
        
        List<User> updatedUsersBatch = [select Id,name, TECH_IsResetPassword__c From User where Id in :userIds];
        
        
        System.debug('updatedUsersBatch '+updatedUsersBatch);
        
        
        
        for(User user : updatedUsersBatch){
            
            system.debug('user.TECH_IsResetPassword__c '+user.name+' ' + user.TECH_IsResetPassword__c);
            
            //System.assert(!user.TECH_IsResetPassword__c);
            
        }
    }
    
    
     static public User createUser(String sthId, Profile p){
        
        User u = new User( //STHUniqueID__c= sthId,
                          firstname= 'BRT'+sthId,
                          lastname='XXXX',
                          Alias='BRT'+sthId,
                          email = 'BRT'+sthId+'@XXXXX.com',
                          username= 'BRT'+sthId+'@XXXXX.com', 
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles',
                          TECH_IsResetPassword__c = true
                          );
       
        return u;
    }
}