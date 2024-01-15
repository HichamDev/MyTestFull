trigger UserBeforeUpdate on User (before update) {
/*
// UserBeforeUpdate 
----------------------------------------------------------------------
-- - Name          : UserBeforeUpdate
-- - Author        : ASE
-- - Description   : Trigger before update on User to prevent fields "mobile phone" and "email" that have been 
					 created by interface to be updated by later batch interface upsert.
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 18-SEPT-2012  ASE    1.0      Initial version 
-- 11-OCT-2012	 NGO	1.1		 Enforce if values is present in picklist before insert or update 	
-- 05-DEC-2012	 NGO	1.2		 Correction according to code review by salesforce
---------------------------------------------------------------------
**********************************************************************
*/
    
    set<Id> setProfileId =new Set<Id>();
    for(integer i=0; i<trigger.new.size(); i++){
        setProfileId.add(trigger.new[i].ProfileId);
        setProfileId.add(trigger.old[i].ProfileId);
    }
	System.debug('## START Trigger UserBeforeUpdate <<<<<'+UserInfo.getUserName());
	if(PAD.cantrigger('Bypass_AP09_4')){
		
		AP09_PicklistValidation picklistValidation = new AP09_PicklistValidation();
		
		picklistValidation.runValidations(new AP09_PicklistValidationModel[]{
    		new AP09_PicklistValidationModel('Civility__c'),
    		new AP09_PicklistValidationModel('BypassApexTriggers__c', true)
    		}, Trigger.new);
    		
	}
	if(PAD.cantrigger('Bypass_AP09_3')){
    	AP09_InitUser.updateUserContact(trigger.new, trigger.oldMap);
	}
	if(PAD.cantrigger('Bypass_AP09_5')){
    	AP09_InitUser.restrictChangeForInterface(new List<string>{'Email', 'MobilePhone'}, trigger.new, trigger.oldMap);
		
	}else{
		//In case Bypass_AP09_5 is manually disabled
		//restrict the change for email and phone for email or phone that has been changed by User manually
		AP09_InitUser.restrictChangeForEditedEmailPhone(trigger.new, trigger.oldMap);
	}
	
	if(PAD.cantrigger('Bypass_AP09_8')){
		
    	AP09_InitUser.synchroniseContactEmail(trigger.new, trigger.oldMap);
		
	}
	
	if(PAD.cantrigger('Bypass_AP21')){
		system.debug('## Bypass_AP21');
		if(SHW_IBZ_Utils.isInterfaceUser()){
			system.debug('## SHW_IBZ_Utils');
			AP21_UserConversion userConversion = new AP21_UserConversion();
	
		 	userConversion.convertUser(Trigger.new, Trigger.oldMap,setProfileId);
		}
	}
	
	system.debug('## END Trigger UserBeforeUpdate <<<<<'+UserInfo.getUserName());
}