public with sharing class VFC01_WeeklyActivityListView {
/* 
----------------------------------------------------------------------
-- - Name          : VFC01_WeeklyActivityListView 
-- - Author        : AMU
-- - Description   : Controller for VFP01_OrderListView Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 13-DEC-2012  AMU    1.0      Initial version   
----------------------------------------------------------------------
**********************************************************************
*/
	/*****************************************************************/
	/***************** Instantiating Global Variable *****************/
	/*****************************************************************/
	//Global Boolean
	public Boolean isPortal {get;set;}
	//Global Id
	public Id contactId {get;set;}
	//Global String
    public String userId {get;set;}
    public String userType {get;set;}
    
	/*****************************************************************/
	/******************** Page Constructor ***************************/
	/*****************************************************************/
	public VFC01_WeeklyActivityListView (){
		system.debug('## Class VFC01_WeeklyActivityListView - START VFC01_WeeklyActivityListView <<<<<'+UserInfo.getUserName()); 
	
		//Retrieving User ID, USer Type
		userId = UserInfo.getUserId();
		userType = UserInfo.getUserType();
		
		//Checks if Portal User
		CheckUser(userType, userId);
		
		system.debug('## Class VFC01_WeeklyActivityListView - END VFC01_WeeklyActivityListView <<<<<'+UserInfo.getUserName());
    }
    
    /*****************************************************************/
	/*********************** CheckUser *******************************/
	/*****************************************************************/
    public void CheckUser(String userType, String userId){
    	system.debug('## Class VFC01_OrderRecipient - START CheckUser <<<<<'+UserInfo.getUserName());
    	
    	//Checks if Portal User
		if (userType == 'CspLitePortal'){
			isPortal = true;
			
			//Retrieving Contact ID related to user
	    	contactId = [Select contactID
	    			   	   From User
	    			      Where id = :userId
	    			      limit 1].contactID;
		}
		else{
			isPortal = false;
		}
    }
    
    /*****************************************************************/
	/******************** ControllerSet Init *************************/
	/*****************************************************************/
	public ApexPages.StandardSetController wkActSet { 	
	 	get {
	    	if(wkActSet == null) {
	    		if (isPortal){
		    		wkActSet = new  ApexPages.StandardSetController(Database.getQueryLocator(
									  [SELECT Id, Name, RecordType.Name, Dealer__c, EndWeek__c, Status__c, PreviousForecastFactsheet__r.Name, Dealer__r.Name
									  	 FROM WAT_WeeklyActivity__c
									  	WHERE Dealer__c = :contactId
									  	order by CreatedDate desc]));
	    		}
	    		else {
    				wkActSet = new  ApexPages.StandardSetController(Database.getQueryLocator(
									  [SELECT Id, Name, RecordType.Name, Dealer__c, EndWeek__c, Status__c, PreviousForecastFactsheet__r.Name, Dealer__r.Name
									  	 FROM WAT_WeeklyActivity__c
									  	 order by CreatedDate desc]));
	    		}
			}
		wkActSet.setPageSize(1000);	
		return wkActSet;
		}
		set;
	}
	
	public List<WAT_WeeklyActivity__c> getWeeklyAct() {
		return (List<WAT_WeeklyActivity__c>) wkActSet.getRecords();
	}
}