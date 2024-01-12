/*
----------------------------------------------------------------------
-- - Name          : AP04_AgendaStatusModification 
-- - Author        : NGO
-- - Description   : Service used to change status of agendaItem.
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
public with sharing class AP04_AgendaStatusModification {
	
	/**
	* Change the status of TECH_InvitationStatus to Accepted
	*/
	public static void acceptAgenda(ID agendaId){
		
		System.debug('>>>>>>>>>>>>>>>>>>>>>>> acceptAgenda()  agendaId :' + agendaId);
		
		changeAgendaStatus(system.label.AgendaItemContactAccepted, agendaId);
	}
	
	/**
	* Change the status of TECH_InvitationStatus to Rejected
	*/
	public static void rejectAgenda(ID agendaId){
		
		System.debug('>>>>>>>>>>>>>>>>>>>>>>> rejectAgenda()  agendaId :' + agendaId);
		
		changeAgendaStatus(system.label.AgendaItemContactRejected, agendaId);
		
	}
	
	
	private static void changeAgendaStatus(String status, ID agendaId){
		
		changeAgendaItemsStatus(status, agendaId);
		
		//changeAgendaContactStatus(status, agendaId);
		
	}
	
	private static void changeAgendaItemsStatus(String status, ID agendaId){
		
		List<AGI_AgendaItem__c> aics = retrieveAgendaItems(agendaId);
		
		List<AGI_AgendaItem__c> updatedList = new List<AGI_AgendaItem__c>();
		
		for(AGI_AgendaItem__c aic : aics){
			
			aic.TECH_InvitationStatus__c = status;
			
			updatedList.add(aic);
		
		}
		
		update updatedList;
		
	}
	
	
	private static List<AGI_AgendaItem__c> retrieveAgendaItems( ID agendaId){
		
		AGI_AgendaItem__c agi = [select  Id, TECH_Agenda_Item_Contact__c from AGI_AgendaItem__c where id =: agendaId];
		
		List<AGI_AgendaItem__c> agis = [ select Id, TECH_InvitationStatus__c, TECH_Contact__c from AGI_AgendaItem__c where TECH_Agenda_Item_Contact__c = : agi.TECH_Agenda_Item_Contact__c  ];
		
		return agis;
		
	}
	/*
	private static void changeAgendaContactStatus(String status, ID agendaId){
		
		List<AIC_AgendaItemContact__c> aics = retrieveAgendaItemContactFromAgenda(agendaId);

		List<AIC_AgendaItemContact__c> updatedList = new List<AIC_AgendaItemContact__c>();

		for(AIC_AgendaItemContact__c aic : aics){
			
			aic.Invitation_status__c = status;
			
			updatedList.add(aic);

		}
		
		update updatedList;
		
	}
	
	
	private static List<AIC_AgendaItemContact__c> retrieveAgendaItemContactFromAgenda( ID agendaId){
		
		List<AIC_AgendaItemContact__c> aic = [select ID, Invitation_status__c from AIC_AgendaItemContact__c where id in (select  TECH_Agenda_Item_Contact__c from AGI_AgendaItem__c where id =: agendaId) ];
		
		return aic; 
		
	}
	*/

}