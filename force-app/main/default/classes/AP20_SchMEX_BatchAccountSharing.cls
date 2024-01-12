/*
----------------------------------------------------------------------
-- - Name          : AP20_SchMEX_BatchAccountSharing.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Scheduler to refresh account sharing for county Mexique 
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 17-DEC-2013  NGO    1.0      Initial version
----------------------------------------------------------------------  
*/
global with sharing class AP20_SchMEX_BatchAccountSharing implements Schedulable{
    global void execute (SchedulableContext sc)
     {       
        system.debug('## Start scheduler AP20_SchMEX_BatchAccountSharing<<<<<');
        AP20_BatchAccountSharing batch = new AP20_BatchAccountSharing('MEX');
        database.executebatch(batch);
        system.debug('## End scheduler AP20_SchMEX_BatchAccountSharing <<<<<');
     }
}