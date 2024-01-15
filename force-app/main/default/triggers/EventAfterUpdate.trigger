trigger EventAfterUpdate on Event (after update) {
/*
----------------------------------------------------------------------
-- - Name          : EventAfterInsert 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : after update Trigger for Event
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 19-SEP-2012  NGO    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/

	System.Debug('## >>>EventAfterUpdate after insert START <<< run by ' + UserInfo.getName());
	   
    if (Pad.canTrigger('Bypass_AP10')){
    	
    	System.Debug('## >>>EventAfterUpdate after insert >>> START AP10 ' + UserInfo.getName());
    	
		AP10_EventSynchronize.updateAgendaItemByEvent(Trigger.new);
		
		System.Debug('## >>>EventAfterUpdate after insert >>> END AP10 ' + UserInfo.getName());
    }
   
	System.debug('## >>>EventAfterUpdate after insert END <<< run by ' + UserInfo.getName());
    	
}