/*
 AccountAfterUpdate
----------------------------------------------------------------------
-- - Name          : AccountAfterInsert
-- - Author        : NGO
-- - Description   : Trigger after insert on Account  replace the interface owner by corresponding Salesforce ID
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 22-JAN-2013  NGO    1.0      Initial version 
-- 03-MAY-2013	NGO	   1.1		Add sharing for account with its parent
-- 27-NOV-2014	NGO	   1.2		Change rules for changing owner
---------------------------------------------------------------------
**********************************************************************
*/
trigger AccountAfterUpdate on Account (after update) {
	
	system.debug('## Start Trigger AccountAfterUpdate <<<<<');
	
	
	if(PAD.cantrigger('Bypass_AP09_1')){
		
		//Test if user is Interface 
		if(SHW_IBZ_Utils.isInterfaceUser()){
			
			list<Account> interfaceAccList = new list<Account>();
			
			set<string> ACCOwnerExternalIdSet = new set<string>();
			system.debug('## trigger.new <<<<<' + trigger.new);
			
			//loop to add accounts created by batch interface with AccountOwner = Interface
			for(integer i=0;i<trigger.new.size();i++){
				
				//Check if owner is the same as in the field TECH_ACCOwnerExternalId__c
				if(trigger.new[i].TECH_ACCOwnerExternalId__c != null && trigger.new[i].TECH_ACCOwnerExternalId__c != trigger.new[i].TECH_OwnerUserExternalID__c){
					
					interfaceAccList.add(trigger.new[i]);
					ACCOwnerExternalIdSet.add(trigger.new[i].TECH_ACCOwnerExternalId__c);
				}	
			}	
			system.debug('## interfaceAccList <<<<<' + interfaceAccList);
			if(interfaceAccList.size() >0) { 
				// call class
				AP09_AccountBatchInterface.UpdateAccount(interfaceAccList,ACCOwnerExternalIdSet);
			}
		}
		
	}
	/*
	AP20_AccountSharingImpl accountSharing = new AP20_AccountSharingImpl();
	
	
	if(PAD.cantrigger('Bypass_AP20_2')){
	
		accountSharing.createShareAcountOnUpdate(Trigger.oldMap, trigger.new);
		
	}
	
	if(PAD.cantrigger('Bypass_AP20_3')){
		
		accountSharing.updateShareAcount(Trigger.oldMap, trigger.new);
		
	}
	*/
	
	system.debug('## END Trigger AccountAfterUpdate <<<<<');

}