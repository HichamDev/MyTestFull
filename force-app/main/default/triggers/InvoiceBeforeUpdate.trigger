trigger InvoiceBeforeUpdate on INV_Invoice__c (before update) {
/*
// InvoiceBeforeUpdate
----------------------------------------------------------------------
-- - Name          : InvoiceBeforeUpdate
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
	system.debug('## START Trigger InvoiceBeforeUpdate <<<<<'+UserInfo.getUserName());
	if(PAD.cantrigger('Bypass_AP09_4')){
		
		AP09_PicklistValidation picklistValidation = new AP09_PicklistValidation();
	
		picklistValidation.runValidations(new AP09_PicklistValidationModel[]{
    		new AP09_PicklistValidationModel('Status__c'),
    		new AP09_PicklistValidationModel('InvoiceType__c'),
    		new AP09_PicklistValidationModel('InvoicingCountry__c')
    		}, Trigger.new);
	}
	system.debug('## END Trigger InvoiceBeforeUpdate <<<<<'+UserInfo.getUserName());
}