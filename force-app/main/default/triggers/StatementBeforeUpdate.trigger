trigger StatementBeforeUpdate on STA_Statement__c (before update) {
/*
// OrderAfterInsert
----------------------------------------------------------------------
-- - Name          : StatementBeforeUpdate
-- - Author        : NGO
-- - Description   : Trigger after update to update statement from BO, delete all transaction and update balance
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 07-AUG-2013  NGO    1.0      Initial version 
----------------------------------------------------------------------
**********************************************************************
*/
    system.debug('## START Trigger StatementBeforeUpdate <<<<<'+UserInfo.getUserName());
        
    if(PAD.cantrigger('Bypass_AP29') && !system.isBatch()){
        
           AP29_STWStatements.updateStatementFromBO(Trigger.new, Trigger.oldMap);
        
    }
    
    system.debug('## END Trigger StatementBeforeUpdate <<<<<'+UserInfo.getUserName());
}