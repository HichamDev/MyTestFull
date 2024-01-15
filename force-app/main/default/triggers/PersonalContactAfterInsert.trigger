trigger PersonalContactAfterInsert on PCT_PersonalContact__c (after insert) {
/*
// PersonalContactAfterInsert 
----------------------------------------------------------------------
-- - Name          : PersonalContactAfterInsert 
-- - Author        : WCHY
-- - Description   : Trigger after insert on personal Contact replace the interface owner by corresponding Salesforce ID
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 22-DEC-2014  WCHY    1.0      Initial version 
---------------------------------------------------------------------
**********************************************************************
*/
    system.debug('## START Trigger PersonalContactAfterInsert <<<<<');
    
  
    if(PAD.cantrigger('Bypass_AP33')){

        list<PCT_PersonalContact__c> interfacePCList = new list<PCT_PersonalContact__c>();
        
        set<string> PCOwnerExternalIdSet = new set<string>();
        
        //loop to add personal contacts created by batch interface with Owner = Interface
        for(integer i=0;i<trigger.new.size();i++){
            //Checks is external if of user is populated
            if( String.isNotBlank(trigger.new[i].TECH_Owner_ExternalID__c) ){
            	
                interfacePCList.add(trigger.new[i]);
                
                PCOwnerExternalIdSet.add(trigger.new[i].TECH_Owner_ExternalID__c);
                
            }   
        }   
    
        if(interfacePCList.size() >0) { 
            // call class
            AP33_PersonalContactBatchInterface.updatePersonalContact(interfacePCList,PCOwnerExternalIdSet); 
        }

        
    }
    
    system.debug('## END Trigger PersonalContactAfterInsert <<<<<');
}