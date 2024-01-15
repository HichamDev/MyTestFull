trigger AgendaItemAfterInsert on AGI_AgendaItem__c (after insert) {
/*
----------------------------------------------------------------------
-- - Name          : AgendaItemAfterInsert 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : After Insert Trigger for object AGI_AgendaItem__c
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 29-AUG-2012  NGO    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/ 
	System.Debug('## >>>AgendaItem after insert START <<< run by ' + UserInfo.getName());
	   
    if (Pad.canTrigger('Bypass_AP04')){
    	
    	System.Debug('## >>>AgendaItem after insert >>> START AP04 ' + UserInfo.getName());
		
		AP04_AgendaItemContact.shareAgendaWithContactReportsTo(Trigger.new);
		
		System.Debug('## >>>AgendaItem after insert >>> END AP04 ' + UserInfo.getName());
    }
    
    if (Pad.canTrigger('Bypass_AP10')){
    	
    	System.Debug('## >>>AgendaItem after insert >>> START AP10 ' + UserInfo.getName());
		
		//AP10_EventSynchronize.createAICByEventAttendee(Trigger.new);
		
		AP04_AgendaItemContact.createAICByEventAttendee(Trigger.new);
		
		System.Debug('## >>>AgendaItem after insert >>> END AP10 ' + UserInfo.getName());
    }
    
    
   
	System.debug('## >>>AgendaItem after insert END <<< run by ' + UserInfo.getName());

}