trigger AgendaItemContactAfterUpdate on AIC_AgendaItemContact__c (after update) {
/*
----------------------------------------------------------------------
-- - Name          : AgendaItemContactAfterUpdate 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : After Update Trigger for object AGI_AgendaItem__c
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 29-AUG-2012  NGO    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/
	System.Debug('## >>>AgendaItemContact after update START <<< run by ' + UserInfo.getName());
	   
    if (Pad.canTrigger('Bypass_AP04')){
    	
    	System.Debug('## >>>AgendaItemContact after update >>> START AP04 ' + UserInfo.getName());
    	
    	AP04_AgendaItemContact.updateAgendaItemContact(Trigger.oldMap, Trigger.new);
		
		System.Debug('## >>>AgendaItemContact after update >>> END AP04 ' + UserInfo.getName());
    }
   
	System.debug('## >>>AgendaItemContact after update END <<< run by ' + UserInfo.getName());


}