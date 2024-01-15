trigger AgendaItemContactAfterInsert on AIC_AgendaItemContact__c (after insert) {
/*
----------------------------------------------------------------------
-- - Name          : AgendaItemContactAfterInsert 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : After Insert Trigger for object AgendaItemContact__c
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 21-AUG-2012  NGO    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/ 		
	System.Debug('## >>>AgendaItemContact after insert START <<< run by ' + UserInfo.getName());
	   
    if (Pad.canTrigger('Bypass_AP04')){
    	
    	System.Debug('## >>>AgendaItemContact after insert >>> START AP04 ' + UserInfo.getName());
    	
		AP04_AgendaItemContact.shareAgendaWithContact(Trigger.new);
		
		AP04_AgendaItemContact.shareAgendaWithContactReportsTo(Trigger.new);
		
		System.Debug('## >>>AgendaItemContact after insert >>> END AP04 ' + UserInfo.getName());
    }
   
	System.debug('## >>>AgendaItemContact after insert END <<< run by ' + UserInfo.getName());
    	
    	
}