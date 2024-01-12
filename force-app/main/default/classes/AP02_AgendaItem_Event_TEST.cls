@isTest
private class AP02_AgendaItem_Event_TEST {
/* 
------------------------------------------------------------
-- - Name          : AP02_AgendaItem_Event_TEST 
-- - Author        : ASE
-- - Description   : Test Class used to check date format based on Start and 
                     End DateTime of events and meetings on the AgendaItem 
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 23-AUG-2012  ASE    1.0    Initial version
------------------------------------------------------------
*/
		/*public List<Week> weeks;
		
	//static Id recTypeAgenda;
		static testMethod void createTestEvent() {
		
		Id recTypeAgenda = [select Id from RecordType where DeveloperName =: system.label.AGI00001
                                    			       and SobjectType=: SHW_IBZ_Constants.AGI].Id;
                                    			       
		AGI_AgendaItem__c agenda1 = new AGI_AgendaItem__c(	RecordTypeId= recTypeAgenda, TaskType__c='Event',Name='Event 1',
	    													Start__c= datetime.newInstance(2012, 08, 1, 12, 30, 2), 
	    													End__c=datetime.newInstance(2012, 08, 1, 13, 30, 2));
	    insert agenda1;
	    system.debug('>>>>>>>>>agenda1 inserted: '+agenda1);
	    													
	    AGI_AgendaItem__c agenda2 = new AGI_AgendaItem__c(	RecordTypeId= recTypeAgenda, TaskType__c='Event',Name='All day Event 2', 
	    													Start__c= datetime.newInstance(2012, 08, 1, 12, 30, 2), 
	    													End__c=datetime.newInstance(2012, 08, 1, 13, 30, 2), AllDayEvent__c= true);															
	    insert agenda2;
	    system.debug('>>>>>>>>>agenda2 inserted: '+agenda2);
	    
	    test.startTest();
	    test.stopTest();
	    
	}
	
	public static testMethod void testAP02_AgendaItem_Month() {
		
		
		AP02_AgendaItem_Month m = new AP02_AgendaItem_Month( Date.newInstance(2007,11,1) );
		system.assert(m!=null);	
		test.startTest();
		
		
		List<Week> l = m.getWeeks(); 
		
		AP02_AgendaItem_repeatCon r = new AP02_AgendaItem_repeatCon(); 
		system.debug(m.getMonthName());
		
		Month mm = r.getMonth();
		//system.debug(mm); 
		system.debug(m.getFirstDate());
		system.debug(m.getWeekdayNames());
		for(Week w:r.getWeeks()) { 
			for(Day c:w.days) {   
				if (c.eventsToday.size() > 0 ) { 
					String ss = String.valueOf(c.eventsToday[0].ev.Start__c);
					
					//system.debug(ss);
					//system.debug(c.eventsToday[0].ev);
				} 
			} 
		} 
	}*/
}