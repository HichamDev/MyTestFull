trigger ArticleBeforeInsert on ART_Article__c (before insert) {
/*
// ArticleBeforeInsert
----------------------------------------------------------------------
-- - Name          : ArticleBeforeInsert
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
	system.debug('## START Trigger ArticleBeforeInsert <<<<<'+UserInfo.getUserName());
	if(PAD.cantrigger('Bypass_AP09_4')){
		
		AP09_PicklistValidation picklistValidation = new AP09_PicklistValidation();
	
    	picklistValidation.runValidations(new AP09_PicklistValidationModel[]{
    		new AP09_PicklistValidationModel('Type__c'),
    		new AP09_PicklistValidationModel('Brand__c'),
    		new AP09_PicklistValidationModel('BrandTerritory__c'),
    		new AP09_PicklistValidationModel('Family__c'),
    		new AP09_PicklistValidationModel('Category__c'),
    		new AP09_PicklistValidationModel('OnhandStockStatus__c'),
    		new AP09_PicklistValidationModel('CapacityUnit__c')
    		}, Trigger.new);
	}
	system.debug('## END Trigger ArticleBeforeInsert <<<<<'+UserInfo.getUserName());
}