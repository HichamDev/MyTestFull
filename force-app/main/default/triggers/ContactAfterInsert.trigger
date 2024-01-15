trigger ContactAfterInsert on Contact (after insert) {
/*
// ContactAfterInsert
----------------------------------------------------------------------
-- - Name          : ContactAfterInsert
-- - Author        : ASE
-- - Description   : Trigger after insert on Contact replace the Contact Owner from interface owner to the corresponding Salesforce ID
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 17-SEPT-2012  ASE    1.0      Initial version 
-- 22-JUL-2013	 NGO    deleted	 Transfer this trigger to beforeInsert
---------------------------------------------------------------------
**********************************************************************
*/
/*
	system.debug('## START Trigger ContactAfterInsert <<<<<'+UserInfo.getUserName());
	if(PAD.canTrigger('AP09')){
		//Test if user is Interface 
		if(SHW_IBZ_Utils.isInterfaceUser()){
			list<Contact> interfaceContactList = new list<Contact>();
			set<string> CONOwnerExternalIdSet = new set<string>();
			
			//loop to add contacts created by batch interface with contact Owner = Interface
			for(integer i=0;i<trigger.new.size();i++){
				if(trigger.new[i].TECH_CONOwnerExternalId__c != null){
					interfaceContactList.add(trigger.new[i]);
					CONOwnerExternalIdSet.add(trigger.new[i].TECH_CONOwnerExternalId__c);
				}
			}	
		
			system.debug('>>>>>>>>>>>>>>>>>>>>interfaceContactList:'+ interfaceContactList);
			system.debug('>>>>>>>>>>>>>>>>>>>CONOwnerExternalIdSet:'+CONOwnerExternalIdSet);
		
			if(interfaceContactList.size() >0) { 
				// call class 
				AP09_ContactBatchInterface.UpdateContact(interfaceContactList,CONOwnerExternalIdSet); 
			} 
		}
	}
	system.debug('## END Trigger ContactAfterInsert <<<<<'+UserInfo.getUserName());
	*/
}