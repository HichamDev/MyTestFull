trigger PeriodAfterUpdate on PER_Period__c (after update) {
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
	System.Debug('## >>>Period After update START <<< run by ' + UserInfo.getName());
	
	if(PAD.cantrigger('Bypass_AP28')){

	 	AP28_CreatePeriodEvent.updateEvent(Trigger.new);
	 	
	}

	System.Debug('## >>>Period After update END <<< run by ' + UserInfo.getName());
}