trigger EventAfterInsert on Event (after insert) {
/*
----------------------------------------------------------------------
-- - Name          : EventAfterInsert 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : after insert Trigger for Event
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 18-SEP-2012  NGO    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/

	System.Debug('## >>>EventAfterInsert after insert START <<< run by ' + UserInfo.getName());
	   
    if (Pad.canTrigger('Bypass_AP10')){
    	
    	System.Debug('## >>>EventAfterInsert after insert >>> START AP10 ' + UserInfo.getName());
    	
		AP10_EventSynchronize.createAgendaItemForEvent(Trigger.new);
		
		System.Debug('## >>>EventAfterInsert after insert >>> END AP10 ' + UserInfo.getName());
    }
   
	System.debug('## >>>EventAfterInsert after insert END <<< run by ' + UserInfo.getName());
    	
	
}