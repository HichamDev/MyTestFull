trigger AgendaItemBeforeDelete on AGI_AgendaItem__c (before delete) {
/*
----------------------------------------------------------------------
-- - Name          : AgendaItemBeforeDelete 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Before delete Trigger for object AGI_AgendaItem__c
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 29-AUG-2012  NGO    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/ 
	System.Debug('## >>>AgendaItem before delete START <<< run by ' + UserInfo.getName());
	   
    if (Pad.canTrigger('Bypass_AP04')){
    	
    	System.Debug('## >>>AgendaItem before delete >>> START AP04 ' + UserInfo.getName());
		
		AP04_AgendaItemContact.unShareAgendaWithAllContacts(Trigger.old);
		
		System.Debug('## >>>AgendaItem before delete >>> END AP04 ' + UserInfo.getName());
    }
   
	System.debug('## >>>AgendaItem before delete END <<< run by ' + UserInfo.getName());

}