trigger AgendaItemAfterUpdate on AGI_AgendaItem__c (after update) {
/*
----------------------------------------------------------------------
-- - Name          : AgendaItemAfterUpdate 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : After Update Trigger for object AGI_AgendaItem__c
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 29-AUG-2012  NGO    1.0      Initial version 
-- 05-DEC-2012	 NGO   1.1		 Correction according to code review by salesforce                           
----------------------------------------------------------------------
**********************************************************************
*/
	System.Debug('## >>>AgendaItem after update START <<< run by ' + UserInfo.getName());
	   
    if (Pad.canTrigger('Bypass_AP04')){
    	
    	System.Debug('## >>>AgendaItem after update >>> START AP04 ' + UserInfo.getName());
    	
    	AP04_AgendaItemContact.updatePrivatePublicAgendaItem(Trigger.oldMap, Trigger.new);
		
		AP04_AgendaItemContact.updateAgendaItemChildren(Trigger.new);
		
		System.Debug('## >>>AgendaItem after update >>> END AP04 ' + UserInfo.getName());
    }
   
	System.debug('## >>>AgendaItem after update END <<< run by ' + UserInfo.getName());


}