trigger UserAfterInsert on User (after insert) {
/*
----------------------------------------------------------------------
-- - Name          : UserAfterInsert 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : After Insert Trigger for object User
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 07-JAN-2013  NGO    1.0      Initial version                  
         
----------------------------------------------------------------------
**********************************************************************
*/ 
	
	//This fucntionality is an evolution 235944
	System.Debug('## >>>User After insert START <<< run by ' + UserInfo.getName());
	
	/*if(PAD.cantrigger('Bypass_AP09_7')){
		
		List<String> users = new List<string>();
		// serialize User Id to pass to the @future method
		for(User user : Trigger.new){
			if(user.IsActive){
				users.add(JSON.serialize(user.Id));
			}
		}
		//Call asynchronous method resetPassword 
		//to overcome the governor limit
	 	AP09_InitUser.resetUserPassword(users);
		 		
	}*/
	
	System.Debug('## >>>User After insert END <<< run by ' + UserInfo.getName());
}