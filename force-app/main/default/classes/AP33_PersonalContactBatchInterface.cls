public with sharing class AP33_PersonalContactBatchInterface {
/*
// AP33_PersonalContactBatchInterface for updating OwnerId in Account once the External Id is retrieved from User
----------------------------------------------------------------------
-- - Name          : AP33_PersonalContactBatchInterface 
-- - Author        : WCHY
-- - Description   : updating OwnerId in Personal Contact once the External Id is retrieved from User on field : PersonalContact.TECH_Owner_ExternalID__c
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  --------------------------------------
-- 22-JAN-2014  WCHY    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
    /**
    * Change owner of personal contact from Interface to the specified owner in field PersonalContact.TECH_Owner_ExternalID__c
    */
    public static void updatePersonalContact(list<PCT_PersonalContact__c> interfacePContactList, set<string>PCOwnerExternalIdSet){
        system.debug('## Class AP33_PersonalContactBatchInterface - START updatePersonalContact <<<<<'+UserInfo.getUserName()); 
        map<String,ID> IdPCOwnerIDMap = new map<String,ID>();
        list<PCT_PersonalContact__c> UpdatedPersonalContactList = new list<PCT_PersonalContact__c> ();
        
        system.debug('>>>>>>>>> : interfacePContactList' + interfacePContactList);
        system.debug('>>>>>>>> : PCOwnerExternalIdSet' + PCOwnerExternalIdSet);
        
        for (User retrieveOwnerid :[Select id,TECH_ExternalId__c from User where TECH_ExternalId__c IN :PCOwnerExternalIdSet]){
            IdPCOwnerIDMap.put( retrieveOwnerid.TECH_ExternalId__c, retrieveOwnerid.id);
            system.debug('>>>>>>>>>>>>>>IdACCOwnerID:' +IdPCOwnerIDMap);
        }
        
        if (IdPCOwnerIDMap.size() > 0 ){
            for (PCT_PersonalContact__c pc: interfacePContactList){
                if (IdPCOwnerIDMap.containsKey(pc.TECH_Owner_ExternalID__c)){
                    PCT_PersonalContact__c pc1= new PCT_PersonalContact__c(id = pc.id);
                    pc1.Ownerid = IdPCOwnerIDMap.get(pc.TECH_Owner_ExternalID__c);
                    UpdatedPersonalContactList.add(pc1);
                    system.debug('>>>>>>>>>>>>>>UpdatedPersonalContactList:' +UpdatedPersonalContactList);
                }
                
            }
        }
        //Checks if accountlist has records
        if(UpdatedPersonalContactList.size()>0){
            //Update account with new owners
            Update(UpdatedPersonalContactList);
        }
        system.debug('## Class AP33_PersonalContactBatchInterface - END updatePersonalContact <<<<<'+UserInfo.getUserName());
    }
}