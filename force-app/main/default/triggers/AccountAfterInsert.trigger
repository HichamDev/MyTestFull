trigger AccountAfterInsert on Account (after insert) {
/*
// AccountAfterInsert
----------------------------------------------------------------------
-- - Name          : AccountAfterInsert
-- - Author        : ASE
-- - Description   : Trigger after insert on Account  replace the interface owner by corresponding Salesforce ID
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 14-SEPT-2012  ASE    1.0      Initial version 
-- 03-MAY-2013	 NGO	1.1		 Add sharing for account with its parent
---------------------------------------------------------------------
**********************************************************************
*/
	system.debug('## START Trigger AccountAfterInsert <<<<<');
	
	
	
	if(PAD.cantrigger('Bypass_AP09_1')){
		
		//Test if user is Interface 
		if(SHW_IBZ_Utils.isInterfaceUser()){
			list<Account> interfaceAccList = new list<Account>();
			set<string> ACCOwnerExternalIdSet = new set<string>();
			
			//loop to add accounts created by batch interface with AccountOwner = Interface
			for(integer i=0;i<trigger.new.size();i++){
				//Checks is external if of user is populated
				if(trigger.new[i].TECH_ACCOwnerExternalId__c != null){
					interfaceAccList.add(trigger.new[i]);
					ACCOwnerExternalIdSet.add(trigger.new[i].TECH_ACCOwnerExternalId__c);
				}	
			}	
		
			if(interfaceAccList.size() >0) { 
				// call class
				AP09_AccountBatchInterface.UpdateAccount(interfaceAccList,ACCOwnerExternalIdSet); 
			}
		}
		
	}
	
	/*if(PAD.cantrigger('Bypass_AP20_1')){
		
		AP20_AccountSharingImpl accountSharing = new AP20_AccountSharingImpl();
		
		accountSharing.shareAcount(trigger.new);
	}*/
	
	system.debug('## END Trigger AccountAfterInsert <<<<<');
}