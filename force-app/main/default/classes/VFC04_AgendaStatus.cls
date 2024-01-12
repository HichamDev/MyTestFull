/*
----------------------------------------------------------------------
-- - Name          : VFC04_AgendaStatus 
-- - Author        : NGO
-- - Description   : Controller for VFC04_AgendaStatus 
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

public with sharing class VFC04_AgendaStatus {

    public VFC04_AgendaStatus(ApexPages.StandardController controller) {

    }

	public ID agendaID {get; set;}


	public VFC04_AgendaStatus(){}

	public Pagereference acceptAgenda(){
		
		agendaID   = ApexPages.currentPage().getParameters().get('Id');
		
		System.debug('Method Start acceptAgenda :' +agendaID);

		AP04_AgendaStatusModification.acceptAgenda(agendaId);
		
		return redirectToSamePage();
		
	}

	public Pagereference rejectAgenda(){
		
		agendaID   = ApexPages.currentPage().getParameters().get('Id');
		
		AP04_AgendaStatusModification.rejectAgenda(agendaId);
		
		return redirectToSamePage();
		
	}	
	
	private Pagereference redirectToSamePage(){
		
		System.debug('AgendaID'+agendaID);
		
		return new Pagereference('/'+agendaID);
		
	}

}