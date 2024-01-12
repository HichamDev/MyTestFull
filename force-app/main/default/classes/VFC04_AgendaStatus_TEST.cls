/*
----------------------------------------------------------------------
-- - Name          : VFC04_AgendaStatus 
-- - Author        : NGO
-- - Description   : Controller for VFC04_AgendaStatus_TEST
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 26-NOV-2012  NGO    1.0      Initial version   
----------------------------------------------------------------------
**********************************************************************
*/

@isTest
private class VFC04_AgendaStatus_TEST {

    static testMethod void acceptAgendaTest() {
       
       AGI_AgendaItem__c agendaItem = createAgendaItem('Test', false);
       
       PageReference agendaItemPage = Page.VFP04_AgendaAccept;
       
       agendaItemPage.getParameters().put('Id', agendaItem.Id);
       
       Test.setCurrentPage( agendaItemPage );
       
       VFC04_AgendaStatus controller = new VFC04_AgendaStatus();
      
       Test.startTest();
       
       controller.acceptAgenda();
       
       AGI_AgendaItem__c agendaItemUpdated = [select TECH_InvitationStatus__c from AGI_AgendaItem__c where id =: agendaItem.Id];
       
       system.debug('***************'+agendaItemUpdated.TECH_InvitationStatus__c);
       
       system.assert(agendaItemUpdated.TECH_InvitationStatus__c == 'Accepted');
       
       Test.stopTest();
    }
    
    static testMethod void rejectAgendaTest() {
    	
       AGI_AgendaItem__c agendaItem = createAgendaItem('Test', false);
       
       PageReference agendaItemPage = Page.VFP04_AgendaReject;
       
       agendaItemPage.getParameters().put('Id', agendaItem.Id);
       
       Test.setCurrentPage(agendaItemPage );
       
       VFC04_AgendaStatus controller = new VFC04_AgendaStatus();
      
       Test.startTest();
       
       controller.rejectAgenda();
       
       AGI_AgendaItem__c agendaItemUpdated = [select TECH_InvitationStatus__c from AGI_AgendaItem__c where id =: agendaItem.Id];
       
       system.debug('***************'+agendaItemUpdated.TECH_InvitationStatus__c);
       
       system.assert(agendaItemUpdated.TECH_InvitationStatus__c == 'Rejected');
       
       Test.stopTest();
    }
    
    
    
    
    static  AGI_AgendaItem__c createAgendaItem(String name, Boolean private_c){
        
        AGI_AgendaItem__c agendaItem = new AGI_AgendaItem__c(RecordTypeId=Schema.SObjectType.AGI_AgendaItem__c.getRecordTypeInfosByName().get('Meeting').getRecordTypeId(),
                                        Name = name, TaskType__c='Meeting', Private__c = private_c,
                                        Start__c = System.now() , End__c = System.now());
        
        insert agendaItem;
        
        return agendaItem;
    }
    
   
    
}