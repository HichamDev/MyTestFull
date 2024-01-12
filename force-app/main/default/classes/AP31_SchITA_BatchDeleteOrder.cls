/*
----------------------------------------------------------------------
-- - Name          : AP31_SchITA_BatchDeleteOrder.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Scheduler delete Order for county Spain 
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 04-Avril-2014  NGO    1.0      Initial version
----------------------------------------------------------------------  
*/
global with sharing class AP31_SchITA_BatchDeleteOrder implements Schedulable{

    global void execute (SchedulableContext sc)
     {       
        system.debug('## Start scheduler AP31_SchITA_BatchDeleteOrder<<<<<');
        AP31_BatchDeleteOrder batch = new AP31_BatchDeleteOrder('ITA');
        database.executebatch(batch);
        system.debug('## End scheduler AP31_SchITA_BatchDeleteOrder <<<<<');
     }
}