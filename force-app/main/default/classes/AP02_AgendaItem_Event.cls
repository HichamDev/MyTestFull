public with sharing class AP02_AgendaItem_Event extends AP02_AgendaItem_EventAbstract{
/* 
------------------------------------------------------------
-- - Name          : AP02AgendaItem_Event 
-- - Author        : ASE
-- - Description   : Class used to create build formated date based on Start and 
                     End DateTime of events and meetings on the AgendaItem 
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 23-AUG-2012  ASE    1.0    Initial version
-- 26-NOV-2012  NGO	   1.2	  Categorize agenda in three section 	
------------------------------------------------------------
*/
    
	public String toDealer {get; set;}
	
	public String fromDealer {get; set;}
	
	public boolean getShowLink(){
		
		return (fromDealer == 'Me' && String.isBlank(toDealer));
	}
	
	
	public AP02_AgendaItem_Event(AGI_AgendaItem__c event, String owner){
		
		super(event);
		
		this.toDealer = ev.TECH_RecipientName__c;
		
		this.fromDealer = owner;
	}

 }