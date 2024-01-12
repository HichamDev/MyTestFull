/*
----------------------------------------------------------------------
-- - Name          : AP32_SchVEN_BatchInitWeeklyActivity.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Scheduler AP32_BatchInitWeeklyActivity for country Italy
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 04-APR-2014  WCH    1.0      Initial version
----------------------------------------------------------------------  
*/
global with sharing class AP32_SchVEN_BatchInitWeeklyActivity implements Schedulable{
    global void execute (SchedulableContext sc)
     {       
        system.debug('## Start scheduler AP32_SchVEN_BatchInitWeeklyActivity<<<<<');
        AP32_BatchInitWeeklyActivity batch = new AP32_BatchInitWeeklyActivity('VEN');
        database.executebatch(batch);
        system.debug('## End scheduler AP32_SchVEN_BatchInitWeeklyActivity<<<<<');
     }
}