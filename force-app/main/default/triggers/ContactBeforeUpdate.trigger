trigger ContactBeforeUpdate on Contact (before update) {
/*
// ContactAfterUpdate
----------------------------------------------------------------------
-- - Name          : ContactBeforeUpdate
-- - Author        : ASE
-- - Description   : Trigger before update on Contact to prevent fields "mobile phone" and "email" that have been 
					 created by interface to be updated by later batch interface upsert.
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 18-SEPT-2012  ASE    1.0      Initial version 
-- 11-OCT-2012   NGO    1.1      before update to Enforce if values is present in picklist before insert or update
---------------------------------------------------------------------
**********************************************************************
*/
	system.debug('## START Trigger ContactBeforeUpdate <<<<<'+UserInfo.getUserName());
	
	if (PAD.cantrigger('Bypass_AP09_4')) {
		
		AP09_PicklistValidation picklistValidation = new AP09_PicklistValidation();
		
		picklistValidation.runValidations(new AP09_PicklistValidationModel[]{
    		new AP09_PicklistValidationModel('AllowedPaymentMode__c', true), new AP09_PicklistValidationModel('Salutation')
    		}, Trigger.new);
		
	}	
	if(PAD.cantrigger('Bypass_AP09_6')){	
		//loop to add contacts created by batch interface with ContactOwner = Interface or TECH_ACCOwnerExternalId__c is populated
		
		if (SHW_IBZ_Utils.isInterfaceUser()) {
		
			for (integer i=0 ; i < Trigger.new.size() ; i++) { 
				if((Trigger.New[i].TECH_ExternalId__c != null && !Trigger.New[i].TECH_ExternalId__c.startsWith('ITA')) || Trigger.New[i].TECH_ExternalId__c == null){
					if (Trigger.old[i].MobilePhone != null) {
						Trigger.new[i].MobilePhone = Trigger.old[i].MobilePhone;
					}	
					
					if (Trigger.old[i].Email != null) {
						Trigger.new[i].Email = Trigger.old[i].Email;
					}
				}
			}	
		}
	}

	if (PAD.cantrigger('Bypass_ContactBeforeUpdate_Counters')) {

		AP1010_Counters_Utils.calculateCountersWithBOChanges(Trigger.new, Trigger.oldMap);

	}

	system.debug('## END Trigger ContactBeforeUpdate <<<<<'+UserInfo.getUserName());
}