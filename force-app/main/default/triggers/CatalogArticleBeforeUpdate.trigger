trigger CatalogArticleBeforeUpdate on CTA_CatalogArticle__c (before update) {
/*
// CatalogArticleBeforeUpdate
----------------------------------------------------------------------
-- - Name          : CatalogArticleBeforeUpdate
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
	system.debug('## START Trigger CatalogArticleBeforeUpdate <<<<<'+UserInfo.getUserName());
	if(PAD.cantrigger('Bypass_AP09_4')){
		
		AP09_PicklistValidation picklistValidation = new AP09_PicklistValidation();
	
    	picklistValidation.runValidations(new AP09_PicklistValidationModel[]{
    		new AP09_PicklistValidationModel('CatalogArticlesType__c'),
    		new AP09_PicklistValidationModel('LoyaltyPrgUnit1__c'),
    		new AP09_PicklistValidationModel('LoyaltyPrgUnit2__c'),
    		new AP09_PicklistValidationModel('LoyaltyPrgUnit3__c')
    		}, Trigger.new);
	}
	system.debug('## END Trigger CatalogArticleBeforeUpdate <<<<<'+UserInfo.getUserName());
	
}