/*
----------------------------------------------------------------------
-- - Name          : AP28_CreatePeriodEvent_TEST 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : class contains unit tests for validating the behavior of  creating
--					 Event based on Business Period
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 30-JAN-2013  NGO    1.0      Initial version                  
         
----------------------------------------------------------------------
**********************************************************************
*/ 
@isTest
private class AP28_CreatePeriodEvent_TEST{

    static testMethod void myUnitTestOnePeriod() {
        
		PER_Period__c period = new PER_Period__c();

		Schema.DescribeSObjectResult R = PER_Period__c.SObjectType.getDescribe();
		Map<String, Schema.RecordTypeInfo> RT = R.getRecordTypeInfosByName();
		
		period.Account__c = createAccount().Id;
		
		period.RecordTypeId = RT.get('Business').getRecordTypeId();
		
		period.Name = 'Test';
		
		period.StartDate__c = date.today();

		period.EndDate__c = date.today().addDays(2);
		
		insert period;
			
		List<Event> events = [select Id, Subject from event where TECH_PeriodId__c =: period.Id];
		
		system.assert(events.size() == 1);
		
		system.assertEquals(events[0].Subject, 'Test');
		
		period.Name = 'Test1';
		
		update period;
		
		List<Event> event1s = [select Id, Subject from event where TECH_PeriodId__c =: period.Id];
		
		system.assert(event1s.size() == 1);
		
		system.assertEquals(event1s[0].Subject, 'Test1');
		
		delete period;

		List<Event> event2s = [select Id, Subject from event where TECH_PeriodId__c =: period.Id];
		
		system.assert(event2s.size() == 0);
	
    }
    
    static testMethod void myUnitTestMultiplePeriod() {
        
		PER_Period__c period = new PER_Period__c();

		Schema.DescribeSObjectResult R = PER_Period__c.SObjectType.getDescribe();
		Map<String, Schema.RecordTypeInfo> RT = R.getRecordTypeInfosByName();
		
		period.Account__c = createAccount().Id;
		
		period.RecordTypeId = RT.get('Business').getRecordTypeId();
		
		period.Name = 'Test';
		
		period.StartDate__c = date.today();

		period.EndDate__c = date.today().addDays(15);
		
		insert period;
		
		List<Event> events = [select Id, Subject from event where TECH_PeriodId__c =: period.Id];
		
		system.assert(events.size() == 2);
		
		system.assertEquals(events[0].Subject, 'Test');
		
		period.Name = 'Test1';
		
		update period;
		
		List<Event> event1s = [select Id, Subject from event where TECH_PeriodId__c =: period.Id];
		
		system.assert(event1s.size() == 2);
		
		system.assertEquals(event1s[0].Subject, 'Test1');
		
		delete period;

		List<Event> event2s = [select Id, Subject from event where TECH_PeriodId__c =: period.Id];
		
		system.assert(event2s.size() == 0);
	
    }
    
    
     static Account createAccount(){
    
        String acc_name = 'Test Account BR04';
        
        Account acct = new Account(name=acc_name, Country_Code__c='FRA');
        insert acct;
        
        return acct;
    }
}