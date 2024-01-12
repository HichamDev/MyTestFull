@isTest
private class AP04_AgendaItemContact_TEST {
/*
----------------------------------------------------------------------
-- - Name          : AP04AgendaItemContactTEST 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : This class contains unit tests for validating 
--                  the behavior of AP04AgendaItemContact
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 21-AUG-2012  NGO    1.0      Initial version         
----------------------------------------------------------------------  
**********************************************************************
*/

     /** 
    * Test BR04 - Case 01 
    * Share agenda with different owner
    */
    static testMethod void shareAgendaWithDifferentOwner() {
        
        Test.startTest();
       
        //create
        AGI_AgendaItem__c agendaItem = createAgendaItem('Test BR04 - Case 01', false);
        
        System.assert(agendaItem.Id != null);
        
        system.assert(getAgendaItemChildrenNumber(agendaItem.Id) == 0);
        
        Contact contact = createDealer('124233');
        
        contact.ReportsToId = createDealer('25666').Id;
        
        update contact;
        
        system.assert(contact.Id != null);
        
        //create agenda Item Contact with dealer which has a different owner
        AIC_AgendaItemContact__c agendaItemContact = createAgendaItemContact(contact.Id, agendaItem.Id);
        
        system.assert(agendaItemContact.Id != null);
        
        system.assert(getAgendaItemChildrenNumber(agendaItem.Id) == 2);
        
        //update
        agendaItem.Private__c = true;
        update agendaItem;
        
        system.assert(getAgendaItemChildrenNumber(agendaItem.Id) == 1);
        
        agendaItem.Private__c = false;
        update agendaItem;
        
        system.assert(getAgendaItemChildrenNumber(agendaItem.Id) == 2);
        
        agendaItemContact.Dealer__c = createDealer('1242344').Id;
        
        update agendaItemContact;
        
        system.assert(getAgendaItemChildrenNumber(agendaItem.Id) == 1);
        
        //delete
        delete agendaItemContact;
        
        system.assert(getAgendaItemChildrenNumber(agendaItem.Id) == 0);
        
        delete agendaItem;
        
        Test.stopTest();
            
    }


    

    static  AGI_AgendaItem__c createAgendaItem(String name, Boolean private_c){
        
        AGI_AgendaItem__c agendaItem = new AGI_AgendaItem__c(RecordTypeId=Schema.SObjectType.AGI_AgendaItem__c.getRecordTypeInfosByName().get('Meeting').getRecordTypeId(),
                                        Name = name, TaskType__c='Meeting', Private__c = private_c,
                                        Start__c = System.now() , End__c = System.now());
        
        insert agendaItem;
        
        return agendaItem;
    }
    
    static  AIC_AgendaItemContact__c createAgendaItemContact(Id dealer, Id agendaItem){
        
        AIC_AgendaItemContact__c agendaContact = new AIC_AgendaItemContact__c(Dealer__c = dealer, AgendaItem__c=agendaItem);
        
        insert agendaContact;
        
        return agendaContact;
    }
    
    static  Id createUser(String sthId){
        
        Profile p = [SELECT id, Name FROM Profile where name = 'Dealer Manager'].get(0);  
        
        User u = new User( //STHUniqueID__c= sthId,
                          firstname= 'BR04',
                          lastname='XXXX',
                          Alias='BR04',
                          email = 'BR04@XXXXX.com',
                          username= 'BR04@XXXXX.com', 
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles'
                         
                          );
        insert u;
                
        return u.Id;
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
    
    
   private static Integer getAgendaItemChildrenNumber(Id agi){
                                            
        AGI_AgendaItem__c[] shares = [select id from AGI_AgendaItem__c a 
                                where a.TECH_Parent_AGI__c = :agi ];
                                                                                
        return shares.size();                   
        
    }
}