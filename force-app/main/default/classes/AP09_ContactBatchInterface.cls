public with sharing class AP09_ContactBatchInterface {
/*
// AP09_ContactBatchInterface for updating OwnerId in Contact once the External Id is retrieved from User
----------------------------------------------------------------------
-- - Name          : AP09_ContactBatchInterface
-- - Author        : ASE
-- - Description   : updating OwnerId in Contact once the External Id is retrieved from User
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 17-SEPT-2012  ASE    1.0      Initial version
-- 22-JUL-2013   NGO	2.0		 Refractoring and optimization to avoid object lock.
----------------------------------------------------------------------
**********************************************************************
*/
	
	/**
	* Get the user externalId from TECH_CONOwnerExternalId__c to replace the owner of the contact.
	*/
	public static void updateContact(list<Contact> interfaceContactList,set<string> ownerTechExternalIdSet){
		
		system.debug('## Class AP09_ContactBatchInterface - START interfaceContactList <<<<<'+UserInfo.getUserName());
		
		map<String,ID> idVsTechExternalIdMap = getUserIdFromTechExternalId(ownerTechExternalIdSet);

		for(Contact contact: interfaceContactList){
			
			if (idVsTechExternalIdMap.containsKey(contact.TECH_CONOwnerExternalId__c)){
				
				contact.Ownerid = idVsTechExternalIdMap.get(contact.TECH_CONOwnerExternalId__c);
				
			}
		}

		system.debug('## Class AP09_ContactBatchInterface - START interfaceContactList <<<<<'+UserInfo.getUserName());
	}
	
	/**
	* Create a map of user id and external id.
	*/
	private static map<String,ID> getUserIdFromTechExternalId(set<string> ownerTechExternalIdSet){
		
		map<String,ID> idVsTechExternalIdMap = new map<String,ID>();
		
		List<User> users = [Select id,TECH_ExternalId__c from User where TECH_ExternalId__c IN :ownerTechExternalIdSet];
		
		for(User retrieveOwnerid : users){
			
			idVsTechExternalIdMap.put( retrieveOwnerid.TECH_ExternalId__c, retrieveOwnerid.id);
			
		}
		
		return idVsTechExternalIdMap;
		
	}
	
}