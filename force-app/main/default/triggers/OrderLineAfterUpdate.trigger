trigger OrderLineAfterUpdate on ORL_OrderLine__c (after update) {
/*
// OrderAfterInsert
----------------------------------------------------------------------
-- - Name          : OrderLineAfterUpdate
-- - Author        : YGO
-- - Description   : Trigger after update 
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 07-MAY-2013  YGO    1.0      Initial version 
-- 05-SEP-2014  NGO	   2.0      Remove logic in AP29
---------------------------------------------------------------------
**********************************************************************
*/
   if(PAD.cantrigger('Bypass_AP29')){
   	
   		AP29_STWStatements.updateStatementFromOrderLine(trigger.old, trigger.new);
		
	}
		
}