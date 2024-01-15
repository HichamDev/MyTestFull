trigger AgendaItemContactBeforeDelete on AIC_AgendaItemContact__c (before delete) {
/*
----------------------------------------------------------------------
-- - Name          : AgendaItemContactBeforeDelete 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : before Delete Trigger for object AgendaItemContact__c
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 21-AUG-2012  NGO    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/ 		
	System.Debug('## >>>AgendaItemContact before delete START <<< run by ' + UserInfo.getName());
	   
    if (Pad.canTrigger('Bypass_AP04')){
    	
    	System.Debug('## >>>AgendaItemContact before delete >>> START AP04 ' + UserInfo.getName());
    	
		AP04_AgendaItemContact.unShareAgendaWithContact(Trigger.old);
		
		AP04_AgendaItemContact.unShareAgendaWithContactReportsTo(Trigger.old);
		
		System.Debug('## >>>AgendaItemContact before delete >>> END AP04 ' + UserInfo.getName());
    }
   
	System.debug('## >>>AgendaItemContact before delete END <<< run by ' + UserInfo.getName());
    	
}