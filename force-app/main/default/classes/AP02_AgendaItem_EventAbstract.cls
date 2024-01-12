/*
----------------------------------------------------------------------
-- - Name          : AP02_AgendaItem_EventAbstract 
-- - Author        : NGO
-- - Description   : Abstract class used to display agenda.
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
public virtual  class AP02_AgendaItem_EventAbstract {
	
	public AGI_AgendaItem__c ev {set; get;}
    
	public String formatedDate {set; get;}
    
	
	public AP02_AgendaItem_EventAbstract(AGI_AgendaItem__c event) {
		
		system.debug('>>>>>>>>>>>>>>>>>>>>>>>12. Start of AP02_AgendaItem_Event: ');
	  
	    this.ev = event;
	  
	    // build formated date eg 9:00 AM - 1:00 PM
	    if(!event.AllDayEvent__c){
	    	
	        formatedDate = event.Start__c.format(SHW_IBZ_Constants.AGENDA_DATE_FORMAT_PATTERN) + ' - ' + event.End__c.format(SHW_IBZ_Constants.AGENDA_DATE_FORMAT_PATTERN);
	        
	        system.debug('Formatted date: ' +formatedDate);
	    }
	    else{
	    	
	    	formatedDate = 'All Day';       
	    }
	    
	   system.debug('>>>>>>>>>>>>>>>>>>>>>>>End of AP02_AgendaItem_Event: ');
	   
	}

}