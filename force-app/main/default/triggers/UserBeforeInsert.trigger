trigger UserBeforeInsert on User (before insert) {
/*
----------------------------------------------------------------------
-- - Name          : UserBeforeInsert 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : After Insert Trigger for object User
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 11-OCT-2012  NGO    1.0      Initial version                  
-- 05-DEC-2012	 NGO   1.1		 Correction according to code review by salesforce         
----------------------------------------------------------------------
**********************************************************************
*/ 	

	System.Debug('## >>>User before insert START <<< run by ' + UserInfo.getName());
	
	if(PAD.cantrigger('Bypass_AP09_4')){
		
		AP09_PicklistValidation picklistValidation = new AP09_PicklistValidation();
		
    	picklistValidation.runValidations(new AP09_PicklistValidationModel[]{
    		new AP09_PicklistValidationModel('Civility__c'),
    		new AP09_PicklistValidationModel('BypassApexTriggers__c', true)
    		}, Trigger.new);
	}
	if(PAD.cantrigger('Bypass_AP09_3')){
    		
    	AP09_InitUser.initializeUser(Trigger.new);
	}
	
    
    System.Debug('## >>>User before insert END <<< run by ' + UserInfo.getName());
	

}