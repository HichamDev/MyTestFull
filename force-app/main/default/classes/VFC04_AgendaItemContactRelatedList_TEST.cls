/*
----------------------------------------------------------------------
-- - Name          : VFC04_AgendaStatus 
-- - Author        : NGO
-- - Description   : Controller for VFC04_AgendaItemContactRelatedList_TEST
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 12-DEC-2012  NGO    1.0      Initial version   
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class VFC04_AgendaItemContactRelatedList_TEST {

    static testMethod void getList() {
       
       AGI_AgendaItem__c agendaItem = createAgendaItem('Test', false);
       
       //create agenda Item Contact with dealer which has a different owner
       AIC_AgendaItemContact__c agendaItemContact = createAgendaItemContact(createDealer('test').Id, agendaItem.Id);
       
       PageReference agendaItemPage = Page.VFP04_AgendaItemContactRelatedList;
       
       agendaItemPage.getParameters().put('Id', agendaItem.Id);
       
       Test.setCurrentPage( agendaItemPage );
       
       VFC04_AgendaItemContactRelatedList controller = new VFC04_AgendaItemContactRelatedList();
      
       Test.startTest();
       
       List<VFC04_AgendaItemContactRelatedList.AttendeeStatus> attendeeStatus = controller.getListAttendees();
       
       system.debug('***************'+attendeeStatus);
       
       system.assert(attendeeStatus.size() == 1);
       
       Test.stopTest();
    }
    
    
     static  AGI_AgendaItem__c createAgendaItem(String name, Boolean private_c){
        
        AGI_AgendaItem__c agendaItem = new AGI_AgendaItem__c(RecordTypeId=Schema.SObjectType.AGI_AgendaItem__c.getRecordTypeInfosByName().get('Meeting').getRecordTypeId(),
                                        Name = name, TaskType__c='Meeting', Private__c = private_c,
                                        Start__c = System.now() , End__c = System.now());
        
        insert agendaItem;
        
        return agendaItem;
    }
    
     static  Contact createDealer(String sthId){

        Contact contact = new Contact(STHID__c=sthId, AccountId=createAccount(), lastname='br04Contact',firstname='br04Contact', MinOrder__c=50, MinOrderFreeTransportFees__c=50);
        
        insert contact;
       
        return contact;
    }
    
    static Id createAccount(){
    
        String acc_name = 'Test Account BR04';
        
        Account acct = new Account(name=acc_name, Country_Code__c='FRA');
        insert acct;
        
        return acct.Id;
    }
    
    static  AIC_AgendaItemContact__c createAgendaItemContact(Id dealer, Id agendaItem){
        
        AIC_AgendaItemContact__c agendaContact = new AIC_AgendaItemContact__c(Dealer__c = dealer, AgendaItem__c=agendaItem);
        
        insert agendaContact;
        
        return agendaContact;
    }
}