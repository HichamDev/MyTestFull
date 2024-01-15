trigger PeriodAfterDelete on PER_Period__c (after delete) {
/*
----------------------------------------------------------------------
-- - Name          : PeriodAfterInsert 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : After Insert Trigger for object Period
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 30-JAN-2013  NGO    1.0      Initial version                  
         
----------------------------------------------------------------------
**********************************************************************
*/ 
	System.Debug('## >>>Period After delete START <<< run by ' + UserInfo.getName());

	if(PAD.cantrigger('Bypass_AP28')){

	 	AP28_CreatePeriodEvent.deleteEvent(Trigger.old);
	 	
	}

	System.Debug('## >>>Period After delete END <<< run by ' + UserInfo.getName());
}