trigger EventBeforeDelete on Event (before delete) {
/*
----------------------------------------------------------------------
-- - Name          : EventBeforeDelete 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : before delete Trigger for Event
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 19-SEP-2012  NGO    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/

	System.Debug('## >>>EventBeforeDelete after insert START <<< run by ' + UserInfo.getName());
	   
    if (Pad.canTrigger('Bypass_AP10')){
    	
    	System.Debug('## >>>EventBeforeDelete after insert >>> START AP10 ' + UserInfo.getName());
    	
		AP10_EventSynchronize.deleteAgendaItemByEvent(Trigger.old);
		
		System.Debug('## >>>EventBeforeDelete after insert >>> END AP10 ' + UserInfo.getName());
    }
   
	System.debug('## >>>EventBeforeDelete after insert END <<< run by ' + UserInfo.getName());
    	
}