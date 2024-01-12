/*
----------------------------------------------------------------------
-- - Name          : AP09_SchBatchResetPassword.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Batch to reset newly created user's password
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 08-APR-2014  NGO    1.0      Initial version
----------------------------------------------------------------------  
*/
global class  AP09_BatchResetPassword implements Database.Batchable<sobject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
       
        String query = 'select Id from User where IsActive = true and TECH_IsResetPassword__c = true and Profile.UserLicenseId!=\'100D0000000IejYIAS\'';// users with profile license=guest are excluded
        
        if(Test.isRunningTest()){
            query = 'select Id from User where IsActive = true and TECH_IsResetPassword__c = true and Profile.UserLicenseId!=\'100D0000000IejYIAS\' limit 30';// users with profile license=guest are excluded
        }
        
        
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        
        System.debug('AP09_ResetPasswordBatch size ' + scope.size() ); 
        
        List<User> usersToBeUpdated = new List<User>();
        
        for (Sobject so : scope)
        {
             User user = (user)so;
             
             System.resetPassword(user.Id, true);
             
             user.TECH_IsResetPassword__c = false;
             
             usersToBeUpdated.add(user);
             
             System.debug('AP09_ResetPasswordBatch reset user ' + user.Id );    
             
        }
        
        if(usersToBeUpdated.size() > 0)
            update usersToBeUpdated;
    }
    
    global void finish(Database.BatchableContext BC){
                    
    }
    
    
}