trigger UserAfterUpdate on User (after update) {
/*
----------------------------------------------------------------------
-- - Name          : UserAfterUpdate 
-- - Author        : NGO
-- - Description   : After Insert Trigger for object User
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 25-JUN-2013  NGO    1.0      Initial version                  
         
----------------------------------------------------------------------
**********************************************************************
*/ 
	
	//This fucntionality is an evolution 235944 
	System.Debug('## >>>User After update START <<< run by ' + UserInfo.getName());
	
	if(PAD.cantrigger('Bypass_AP21')){
		
		AP21_UserConversion userConversion = new AP21_UserConversion();

	 	//userConversion.convertUser(Trigger.new, Trigger.oldMap);
	}
	
	System.Debug('## >>>User After update END <<< run by ' + UserInfo.getName());
}