trigger AccountBeforeUpdate on Account (before update) {
/*
// AccountBeforeUpdate
----------------------------------------------------------------------
-- - Name          : AccountBeforeUpdate
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Trigger before update to Enforce if values is present in picklist before insert or update
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 11-OCT-2012  NGO    1.0      Initial version 
---------------------------------------------------------------------
**********************************************************************
*/
	system.debug('## START Trigger AccountBeforeUpdate <<<<<'+UserInfo.getUserName());
	if(PAD.cantrigger('Bypass_AP09_4')){
	
		AP09_PicklistValidation picklistValidation = new AP09_PicklistValidation();
	
		picklistValidation.runValidations(new AP09_PicklistValidationModel[]
		{new AP09_PicklistValidationModel('AccountType__c')}, Trigger.new);
	}
	system.debug('## END Trigger AccountBeforeUpdate <<<<<'+UserInfo.getUserName());
	
}