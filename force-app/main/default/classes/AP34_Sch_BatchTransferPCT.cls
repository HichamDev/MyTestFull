/*
----------------------------------------------------------------------
-- - Name          : AP34_Sch_BatchTransferPCT.cls 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Scheduler to assign back the personal contacts of users who changed license
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 14-JAN-2015  WCH    1.0      Initial version
----------------------------------------------------------------------  
*/
global with sharing class AP34_Sch_BatchTransferPCT implements Schedulable{
    global void execute (SchedulableContext sc)
     {       
        system.debug('## Start scheduler AP34_Sch_BatchTransferPCT<<<<<');
        AP34_BatchTransferPCT batch = new AP34_BatchTransferPCT();
        database.executebatch(batch);
        system.debug('## End scheduler AP34_Sch_BatchTransferPCT <<<<<');
     }
}