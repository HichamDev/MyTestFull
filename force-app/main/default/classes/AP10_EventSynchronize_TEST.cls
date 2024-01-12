public with sharing class AP10_EventSynchronize_TEST {
/*
----------------------------------------------------------------------
-- - Name          : AP10_EventSynchronize_TEST 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Class Test for Triggers insert,update,delete on objects
--                   Event for Event synchronization BR 10.
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 18-SEP-2012  NGO    1.0      Initial version
	        
----------------------------------------------------------------------	
*/	
	 static testMethod void testAP10() {
	 	
	 	Test.startTest();
	 	
	 	string description = 'testtest01'; 
	 	
	 	Event event = createEvent();
	 	
	 	insert event;
	 	
	 	system.assert([select Id from AGI_AgendaItem__c where TECH_Event_ID__c = :event.Id].size() == 1);
	 	//addAttendee(event, createDealer('123'));
	 	//addAttendee(event, createDealer('456'));
	 	
	 	event.Description = description;
	 	
	 	update event;
	 	
	 	AGI_AgendaItem__c agi = [select Id, Description__c from AGI_AgendaItem__c where TECH_Event_ID__c = :event.Id][0];
	 	
	 	system.assert(agi.Description__c == description);
	 	
	 	delete event;
	 	
	 	system.assert([select Id from AGI_AgendaItem__c where TECH_Event_ID__c = :event.Id].size() == 0);
	 	
	 	test.stopTest();
	 	
	 }
	 /*
	 static EventAttendee addAttendee(Event event, Contact dealer){
	
		 EventAttendee att = new EventAttendee();	
		 
		 return att;
	 	
	 }
	 
	 
	 static  Contact createDealer(String sthId){

        Contact contact = new Contact(STHUniqueID__c=sthId, AccountId=createAccount(), lastname='br10Contact',firstname='br10Contact');
        
        insert contact;
       
        return contact;
    }
    
    static Id createAccount(){
    
        String acc_name = 'Test Account BR10';
        
        Account acct = new Account(name=acc_name);
        insert acct;
        
        return acct.Id;
    }
    
    static  Id createUser(String sthId){
        
        Profile p = [SELECT id, Name FROM Profile where name = 'Dealer Manager'].get(0);  
        
        User u = new User( STHUniqueID__c= sthId,
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
    
    */
	
	 private static Event createEvent(){
		
		Event event = new Event();
		
		event.Subject = 'subject';
		
		event.IsAllDayEvent = false;
		
		event.StartDateTime = System.now();
		
		event.EndDateTime = System.now();
		
		event.IsPrivate = true;
		
		event.Location = 'here and there';
		
		event.ShowAs = 'Free';
		
		//event.GroupEventType;
		
		event.Description = 'Description';
		
		return event;
		
	}
	 
	 
	 
  

}