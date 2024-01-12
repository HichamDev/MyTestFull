/*
----------------------------------------------------------------------
-- - Name          : AP28_CreatePeriodEvent 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Class to create Event based on Business Period
--
-- MaIntegerenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 30-JAN-2013  NGO    1.0      Initial version                  
         
----------------------------------------------------------------------
**********************************************************************

*/
public with sharing class AP28_CreatePeriodEvent{

	public static Integer MAX_INTERVAL_EVENT = 14;
	
	public static void createEvent(List<PER_Period__c> periods){
		
		List<Event> events = new List<Event>();

		Schema.DescribeSObjectResult R = PER_Period__c.SObjectType.getDescribe();
		
		Map<String, Schema.RecordTypeInfo> RT = R.getRecordTypeInfosByName();
		
		Id recordTypeBusiness = RT.get(system.label.PER00004).getRecordTypeId();
		
		
		
		for(PER_Period__c period : periods){
			
			// filter for business period record types only
			if(period.RecordTypeId == recordTypeBusiness){
				
				
				//since and event duration can be only 14 days, several event must be reated for period greater than 14
				List<Event> eventsToCreate = getEventsBasedOnPeriod(period);
				
				system.debug('********** createEvent' + eventsToCreate);
				
				//Event event = new Event();
			
				//initialiseEvent(period, event);
			
				events.addAll(eventsToCreate);
			}
	
		}
		
		insert events;
		
	}
	
	private static Date convertDateTimeToDate(DateTime datetimeToConvert){
		
		return  Date.newInstance(datetimeToConvert.year(), datetimeToConvert.month(), datetimeToConvert.day());
	}
	
	private static List<Event> getEventsBasedOnPeriod(PER_Period__c period){
		
		List<Event> events = new List<Event>();
		
		Date startdate_c = convertDateTimeToDate(period.StartDate__c);
		
		Date endDate_c = convertDateTimeToDate(period.EndDate__c);
		
		Integer interval = startdate_c.daysBetween(endDate_c)+1;
		
		Integer numOfEvent = interval / MAX_INTERVAL_EVENT;
		
		Integer modNum = math.mod(interval, MAX_INTERVAL_EVENT);
		
		Date startDate = startdate_c + MAX_INTERVAL_EVENT;
		
		system.debug('********** interval : ' + interval);
		
		system.debug('********** numOfEvent : ' + numOfEvent);
		
		system.debug('********** modNum : ' + modNum);
		
		if(interval < MAX_INTERVAL_EVENT){
			
			system.debug('********** in first if : ');
			
			Event event = new Event();
			
			initialiseEvent(period, event);
			
			events.add(event);
			
		}else{
			
			startDate = startdate_c;
			
			Date endDate = startDate + MAX_INTERVAL_EVENT - 1;
			
			for(Integer i = 0; i < numOfEvent; i++){
				
				system.debug('*********in loop : '+ i + ' startDate'+ startDate + ' endDate ' +endDate);
				
				Event event = new Event();
				
				initialiseEvent(period, event, startDate, endDate);
				
				events.add(event);
				
				startDate = endDate + 1;
				
				endDate = startDate + MAX_INTERVAL_EVENT -1;
			}
			
			
			if(modNum > 0 && interval > MAX_INTERVAL_EVENT){
				
				system.debug('********* last if  startDate'+ startDate + ' endDate ' +endDate);
				
				Event event = new Event();
				
				startDate = (endDate - MAX_INTERVAL_EVENT)+1;
				
				initialiseEvent(period, event, startDate, endDate_c);
				
				events.add(event);
				
			}		
		}	
		
		return events;		
	}
	
	/*public static void updateEvent(List<PER_Period__c> periods){
	
		List<Event> events = new List<Event>();

		Schema.DescribeSObjectResult R = PER_Period__c.SObjectType.getDescribe();
		
		Map<String, Schema.RecordTypeInfo> RT = R.getRecordTypeInfosByName();
		
		Id recordTypeBusiness = RT.get(system.label.PER00004).getRecordTypeId();
		
		Map<Id, Event> idPeriodEvent = getEventFromPeriod(periods);
		
		for(PER_Period__c period : periods){
			
			// filter for business period record types only
			if(period.RecordTypeId == recordTypeBusiness){
			
				Event event = idPeriodEvent.get(period.Id);
					
				initialiseEvent(period, event);

				events.add(event);
			}
		}
		
		update events;	
	}*/
	
	public static void updateEvent(List<PER_Period__c> periods){
	
		deleteEvent(periods);
		
		createEvent(periods);
		
	}
	
	public static void deleteEvent(List<PER_Period__c> periods){
		
		Set<String> periodIdsSet = getPeriodSet(periods);
		
		List<Event> events = [select Id, TECH_PeriodId__c from Event where TECH_PeriodId__c in :periodIdsSet];
		
		delete events;
		
	}
	
	static private Map<Id, Event> getEventFromPeriod(List<PER_Period__c> periods){
		
		Map<Id, Event> idPeriodEvent = new Map<Id, Event>();
		
		Set<String> periodIdsSet = getPeriodSet(periods);
		
		List<Event> events = [select Id, TECH_PeriodId__c from Event where TECH_PeriodId__c in :periodIdsSet];
		
		for(Event event : events){
			
			idPeriodEvent.put(event.TECH_PeriodId__c, event);
			
		}
		
		return idPeriodEvent;
	}

	static private void initialiseEvent(PER_Period__c period, Event event){
		
		event.StartDateTime = period.StartDate__c;
		
		event.EndDateTime = period.EndDate__c;
		
		event.Subject = period.Name;
		
		event.IsReminderSet = false;
		
		event.TECH_PeriodId__c = period.Id;
		
		event.IsAllDayEvent = true;
		
	}
	
	static private void initialiseEvent(PER_Period__c period, Event event, Date startDate, Date endDate){
		
		event.StartDateTime = startDate;
		
		event.EndDateTime = endDate;
		
		event.Subject = period.Name;
		
		event.IsReminderSet = false;
		
		event.TECH_PeriodId__c = period.Id;
		
		event.IsAllDayEvent = true;
		
	}
	
	static private Set<String> getPeriodSet(List<PER_Period__c> periods){
		
		Set<String> periodIdsSet = new Set<string>();
		
		for(PER_Period__c period : periods){
			
			periodIdsSet.add(period.Id);
		}
		
		return periodIdsSet;
	}

}