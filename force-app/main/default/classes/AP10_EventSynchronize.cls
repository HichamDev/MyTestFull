public class AP10_EventSynchronize {
/*
----------------------------------------------------------------------
-- - Name          : AP10_EventSynchronize 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Class for Triggers insert,update,delete on objects
--                   Event for Event synchronization BR 10.
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 18-SEP-2012  NGO    1.0      Initial version
	        
----------------------------------------------------------------------	
*/

	
	/**
	* Create an object AgendaItem when we create an Event 
	* agendaItemContacts are being created in the afterInsertAgendaItem trigger
	*/
	public static void createAgendaItemForEvent(List<Event> events){
		
		System.Debug('## >>> createAgendaItemForEvent >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> createAgendaItemForEvent >>> list events ' + events);
		
		List<AGI_AgendaItem__c> agendaItems = new List<AGI_AgendaItem__c>();
	 	
		for(Event event : events){
	
			AGI_AgendaItem__c agi = convertEventToAGI(event); 
			
			agendaItems.add(agi);	
			
			//agendaItemContacts are being created in the afterInsertAgendaItem trigger
		}
		
	    insert(agendaItems);
	    
	    System.Debug('## >>> createAgendaItemForEvent >>> list agendaItems ' + agendaItems);
	    
	 	System.Debug('## >>> createAgendaItemForEvent >>> END ' + UserInfo.getName());
		
	}
	
	/**
	* Delete the agendaItem that has been created with the event 
	*/
	public static void deleteAgendaItemByEvent(List<Event> events){
		
		System.Debug('## >>> deleteAgendaItemByEvent >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> deleteAgendaItemByEvent >>> list agendaItemContacts ' + events);
		
		List<AGI_AgendaItem__c> agendaItems = new List<AGI_AgendaItem__c>();
		
		agendaItems = getAGIByEvents(events);	
		
		if(agendaItems.size() > 0){
		
			delete(agendaItems);
		}
	    
	    System.Debug('## >>> deleteAgendaItemByEvent >>> list agendaItems ' + agendaItems);
	 
	 	System.Debug('## >>> deleteAgendaItemByEvent >>> END ' + UserInfo.getName());
		
	}
	
	
	/**
	* Update the agendaItem when there is a change in the corresponding event
	* We delete the agenda and create a new one to keep the agendaItemContact synchronized with the EventAttendee
	* This solution has been choosed because of the restriction to the object EventAttendee. 
	* With the next released of api 26 we can optimized this part
	* http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_objects_eventattendee.htm
	* 
	*/
	public static void updateAgendaItemByEvent(List<Event> events){
		
		System.Debug('## >>> updateAgendaItemByEvent >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> updateAgendaItemByEvent >>> list agendaItemContacts ' + events);
		
		deleteAgendaItemByEvent(events);
		
		createAgendaItemForEvent(events);
	    
	 	System.Debug('## >>> updateAgendaItemByEvent >>> END ' + UserInfo.getName());
	}
	
	
	
	
	private static List<AGI_AgendaItem__c> getAGIByEvents(List<Event> events){
		
		List<Id> ids = new List<Id>();
		
		for(Event event : events){
			
			ids.add(event.Id);		
		}
		
		List<AGI_AgendaItem__c> agis = new List<AGI_AgendaItem__c>();
		
		if(ids.size() > 0 ){
			
			agis = [Select Id from AGI_AgendaItem__c where 	TECH_Event_ID__c in :ids and TECH_Parent_AGI__c = null];
		}
		
		return agis;
	}
	
	

	private static AGI_AgendaItem__c convertEventToAGI(Event event){
		
		AGI_AgendaItem__c agi = new AGI_AgendaItem__c();
		
		return transferEventToAGI(event, agi);	
	}
	
	
	private static AGI_AgendaItem__c transferEventToAGI(Event event, AGI_AgendaItem__c agi){
		
		agi.OwnerId = event.OwnerId;
		
		agi.Name = event.Subject;
		
		agi.AllDayEvent__c = event.IsAllDayEvent;
		
		agi.Start__c = event.StartDateTime;
		
		agi.End__c = event.EndDateTime;
		
		agi.Private__c = event.IsPrivate;
		
		agi.Location__c = event.Location;
		
		agi.ShowTimeAs__c = event.ShowAs;
				
		agi.Description__c = event.Description;
		
		agi.TECH_Event_Id__c = event.Id;
		
		return agi;	
	}
	
	
	
}