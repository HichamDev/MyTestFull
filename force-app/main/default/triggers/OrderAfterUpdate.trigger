trigger OrderAfterUpdate on ORD_Order__c (after update) {
/*
// OrderAfterUpdate
----------------------------------------------------------------------
-- - Name          : OrderAfterUpdate
-- - Author        : YGO
-- - Description   : Trigger after update 
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 07-MAY-2013  YGO    1.0      Initial version 
---------------------------------------------------------------------
**********************************************************************
*/

    if(PAD.cantrigger('Bypass_AP29')){
    map<id, string> orderMap = new map<id, string>();

    for(integer i=0; i<trigger.new.size(); i++)
    {
        if(trigger.new[i].Status__c == SHW_IBZ_Constants.ORDER_STATUS_DRAFT ||  trigger.new[i].Status__c == SHW_IBZ_Constants.ORDER_STATUS_PENDING)
        {
            orderMap.put(trigger.new[i].id, trigger.new[i].Status__c);
            
            system.debug('#### old value status: ' + trigger.old[i].Status__c);
            system.debug('#### new value status: ' + trigger.new[i].Status__c);
        }
    }
    
    system.debug('#### orderMap.size() in trigger : '+ orderMap.size());
    
    if(orderMap.size()>0)
        AP29_STWStatements.updateStatementFromOrder(orderMap);
    }

}