/*
----------------------------------------------------------------------
-- - Name          : AP09_SchBatchResetPassword.cls
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
global with sharing class AP09_SchBatchResetPassword implements Schedulable{
    global void execute (SchedulableContext sc)
     {       
        system.debug('## Start scheduler AP09_BatchResetPassword<<<<<');
        AP09_BatchResetPassword batch = new AP09_BatchResetPassword();
        database.executebatch(batch, 149);
        system.debug('## End scheduler AP09_BatchResetPassword <<<<<');
     }
}