trigger CatalogBeforeInsert on CAT_Catalog__c (before insert) {
/*
// CatalogBeforeInsert
----------------------------------------------------------------------
-- - Name          : CatalogBeforeInsert
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
	system.debug('## START Trigger CatalogBeforeInsert <<<<<'+UserInfo.getUserName());
	if(PAD.cantrigger('Bypass_AP09_4')){
		
		AP09_PicklistValidation picklistValidation = new AP09_PicklistValidation();
	
    	picklistValidation.runValidations(new AP09_PicklistValidationModel[]{
    		new AP09_PicklistValidationModel('CatalogueType__c')
    		}, Trigger.new);
	}
	system.debug('## END Trigger CatalogBeforeInsert <<<<<'+UserInfo.getUserName());
}