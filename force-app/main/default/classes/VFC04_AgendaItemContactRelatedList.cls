/*
----------------------------------------------------------------------
-- - Name          : VFC04_AgendaStatus 
-- - Author        : NGO
-- - Description   : Controller for VFC04_AgendaItemContactRelatedList 
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

public  class VFC04_AgendaItemContactRelatedList {
	
	private List<AIC_AgendaItemContact__c> aics;
	
	public Id agendaItemId {get; set;}
	
	
	public VFC04_AgendaItemContactRelatedList(){
		
		this.agendaItemId   = ApexPages.currentPage().getParameters().get('Id');
		
	}
	
	public List<AIC_AgendaItemContact__c> getAgendaItemContacts(){
		
		return [select Dealer__c, TECH_DealerNameFormula__c,  AgendaItem__c from AIC_AgendaItemContact__c where AgendaItem__c = : agendaItemId];
		
	}
	
	public List<AttendeeStatus> getListAttendees(){
		
		List<AttendeeStatus> attendeeStatus = new List<AttendeeStatus>(); 
		
		List<AIC_AgendaItemContact__c> aics = getAgendaItemContacts();
		
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>aics :' +aics);
		
		List<AGI_AgendaItem__c> agis = [select Id, TECH_InvitationStatus__c, TECH_Agenda_Item_Contact__c  from AGI_AgendaItem__c where TECH_Agenda_Item_Contact__c in :getListIds(aics) AND  TECH_IsReportsTo__c = false ];
		
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>agis :' +agis);
		
		Map<Id,AGI_AgendaItem__c> mapAGI = new Map<Id,AGI_AgendaItem__c>();
		
		for(AGI_AgendaItem__c agi : agis){
			
			mapAGI.put(agi.TECH_Agenda_Item_Contact__c, agi);
			
		}
		
		for(AIC_AgendaItemContact__c aic : aics){
			
			System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>aic.AgendaItem__c :' +aic.AgendaItem__c);
			if (mapAGI.get(aic.Id) != null) {
				attendeeStatus.add(new AttendeeStatus(aic.TECH_DealerNameFormula__c, mapAGI.get(aic.Id).TECH_InvitationStatus__c));
			}			
						
		}
		
		return attendeeStatus;
	}
	
	private List<Id> getListIds(List<AIC_AgendaItemContact__c> aics){
		
		List<Id> ids = new List<Id>();
		
		for(AIC_AgendaItemContact__c aic : aics){
			
			ids.add(aic.Id);
		}
		
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>getListIds :' +ids);
		
		return ids;
		
	}
	
	public class AttendeeStatus{
		
		public AttendeeStatus(String attendeeName, String attendeeStatus){
			
			this.attendeeName = attendeeName;
			this.attendeeStatus = attendeeStatus;
		}
		
		public String attendeeName{get; set;}
		
		public String attendeeStatus{get; set;}
		
		
	}

}