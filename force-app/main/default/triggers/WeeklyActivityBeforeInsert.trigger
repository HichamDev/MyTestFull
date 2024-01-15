trigger WeeklyActivityBeforeInsert on WAT_WeeklyActivity__c (before insert) {
/*
// WeeklyActivityBeforeInsert
----------------------------------------------------------------------
-- - Name          : WeeklyActivityBeforeInsert
-- - Author        : Yeveena Gopall
-- - Description   : Trigger before insert to complete field Approver 
					 and Status if field is blank
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 20-AUG-2013  YGO    1.0      Initial version 
---------------------------------------------------------------------
**********************************************************************
*/

	system.debug('## START Trigger WeeklyActivityBeforeInsert <<<<<'+UserInfo.getUserName());
	
	if(PAD.cantrigger('Bypass_AP22_1')){
			
		AP22_WeeklyActivity.initialiseApprover(trigger.new);
	}	
		
	system.debug('## End Trigger WeeklyActivityBeforeInsert <<<<<'+UserInfo.getUserName());	
}