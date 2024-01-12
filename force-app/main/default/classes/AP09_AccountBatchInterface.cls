public with sharing class AP09_AccountBatchInterface {
/*
// AP09_AccountBatchInterface for updating OwnerId in Account once the External Id is retrieved from User
----------------------------------------------------------------------
-- - Name          : AP09_AccountBatchInterface
-- - Author        : ASE
-- - Description   : updating OwnerId in Account once the External Id is retrieved from User
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 14-SEPT-2012  ASE    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/

	public static void updateAccount(list<Account> interfaceAccList, set<string>ACCOwnerExternalIdSet){
		system.debug('## Class AP09_AccountBatchInterface - START UpdateAccount <<<<<'+UserInfo.getUserName());	
		map<String,ID> IdACCOwnerIDMap = new map<String,ID>();
		list<Account> UpdatedAccountList = new list<Account> ();
		
		system.debug('>>>>>>>>> : interfaceAccList' + interfaceAccList);
		system.debug('>>>>>>>>> : ACCOwnerExternalIdSet' + ACCOwnerExternalIdSet);
		
		for (User retrieveOwnerid :[Select id,TECH_ExternalId__c from User where TECH_ExternalId__c IN :ACCOwnerExternalIdSet]){
			IdACCOwnerIDMap.put( retrieveOwnerid.TECH_ExternalId__c, retrieveOwnerid.id);
			system.debug('>>>>>>>>>>>>>>IdACCOwnerID:' +IdACCOwnerIDMap);
		}
		
		if (IdACCOwnerIDMap.size() > 0 ){
			for (Account a: interfaceAccList){
				if (IdACCOwnerIDMap.containsKey(a.TECH_ACCOwnerExternalId__c)){
					Account a1= new Account(id = a.id);
					a1.Ownerid = IdACCOwnerIDMap.get(a.TECH_ACCOwnerExternalId__c);
					UpdatedAccountList.add(a1);
					system.debug('>>>>>>>>>>>>>>UpdatedAccountList:' +UpdatedAccountList);
				}
				
			}
		}
		//Checks if accountlist has records
		if(UpdatedAccountList.size()>0){
			//Update account with new owners
			Update(UpdatedAccountList);
		}
		system.debug('## Class AP09_AccountBatchInterface - END UpdateAccount <<<<<'+UserInfo.getUserName());
	}
}