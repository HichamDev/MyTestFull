trigger ContactBeforeInsert on Contact (before insert) {
/*
// ContactBeforeInsert
----------------------------------------------------------------------
-- - Name          : ContactBeforeInsert
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Trigger before update to Enforce if values is present in picklist before insert or update
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 11-OCT-2012  NGO    1.0      Initial version 
-- 22-JUL-2013	NGO    2.0	 	Transfer the trigger beforeInsert to this one.
---------------------------------------------------------------------
**********************************************************************
*/
	system.debug('## START Trigger ContactBeforeInsert <<<<<'+UserInfo.getUserName());
	
	if(PAD.cantrigger('Bypass_AP09_4')){
		
		AP09_PicklistValidation picklistValidation = new AP09_PicklistValidation();
	
		picklistValidation.runValidations(new AP09_PicklistValidationModel[]{
    		new AP09_PicklistValidationModel('AllowedPaymentMode__c', true), new AP09_PicklistValidationModel('Salutation')
    		}, Trigger.new);
	}
	
	
	if(PAD.canTrigger('Bypass_AP09_2')){
		//Test if user is Interface 
		if(SHW_IBZ_Utils.isInterfaceUser()){
			
			list<Contact> contactUpdatedList = new list<Contact>();
			
			set<string> ownerTechExternalIdSet = new set<string>();
			
			//loop to add contacts created by batch interface with contact Owner = Interface
			for(Contact contact : Trigger.new){
				
				if(contact.TECH_CONOwnerExternalId__c != null){
					
					contactUpdatedList.add(contact);
					
					ownerTechExternalIdSet.add(contact.TECH_CONOwnerExternalId__c);
				}
			}	
		
			system.debug('>>>>>>>>>>>>>>>>>>>>interfaceContactList:'+ contactUpdatedList);
			system.debug('>>>>>>>>>>>>>>>>>>>CONOwnerExternalIdSet:'+ownerTechExternalIdSet);
		
			if(contactUpdatedList.size() > 0) { 
				// call class 
				AP09_ContactBatchInterface.updateContact(contactUpdatedList,ownerTechExternalIdSet); 
			} 
		}
	}
	system.debug('## END Trigger ContactBeforeInsert <<<<<'+UserInfo.getUserName());
}