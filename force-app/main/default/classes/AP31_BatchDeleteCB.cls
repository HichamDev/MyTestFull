/*
----------------------------------------------------------------------
-- - Name          : AP31_BatchDeleteCB.cls
-- - Author        : JBO
-- - Description   : Delete CB print on orders
--

----------------------------------------------------------------------	
*/
global class AP31_BatchDeleteCB implements Database.Batchable<sobject> , Database.AllowsCallouts{
	
	global string country; 
	
	global boolean isAutomaticDeletion;
	
	global Decimal validityPeriod;
	
	global boolean isActivatePurge;
	
	global Decimal purgeValidityPeriod;
	
	global boolean isDoNothing = false;
	
	global Datetime dateNow;
	 
	global Database.QueryLocator start(Database.BatchableContext BC){
	 	
	 	system.debug('## start country ' + country);
	 	
	 	String query = 'select Id, OrderDate__c, Status__c, Payment_Transaction_Token__c, Payment_Transaction_Draft_Creation__c  from ORD_Order__c where  Country_Code__c = \''+country+'\' and OrderType__c<>\'Online\' AND Status__c = \'Draft\' AND Payment_Transaction_Token__c <> \'\' ';
	 	
	 	//country = 'FRA';
	 	if(Test.isRunningTest()){
	 		query = 'select Id, OrderDate__c, Status__c, Payment_Transaction_Token__c, Payment_Transaction_Draft_Creation__c from ORD_Order__c where  Country_Code__c = \''+country+'\' and OrderType__c<>\'Online\' AND Status__c = \'Draft\' AND Payment_Transaction_Token__c <> \'\' ';
	 	}
	 	
	 	return Database.getQueryLocator(query);
	 }

	 global AP31_BatchDeleteCB(String  forCountry){
	 	
	 	
	 	map <string, BatchOrderDeletionOptions__c> mapBatchOrderDeletionOptions =  BatchOrderDeletionOptions__c.getAll();
	 	 
	 	// if(Test.isRunningTest()){
	 	// 	//The date now is set to 04/04/2014 when executing test case to be able to test the deletion.
	 	// 	dateNow = datetime.newInstance(2014, 04, 04, 12, 30, 2);
	 		
	 	// }else{
	 		
	 		dateNow = datetime.now();
	 	// }

        if(mapBatchOrderDeletionOptions.containsKey(forCountry)){
        
         	isAutomaticDeletion = mapBatchOrderDeletionOptions.get(forCountry).IsAutomaticDeletion__c;
         
         	validityPeriod = mapBatchOrderDeletionOptions.get(forCountry).ValidityPeriod__c;
         	
         	//isActivatePurge = mapBatchOrderDeletionOptions.get(forCountry).isActivatePurge__c;
         
         	//purgeValidityPeriod = mapBatchOrderDeletionOptions.get(forCountry).PurgeValidityPeriod__c;
            isActivatePurge = false;
         
        }else{
        	
        	isDoNothing = true;
        }
	 	
	 	system.debug('## constructor country ' + forCountry);
	 	
	 	this.country = forCountry;

	 }
	
	/**
	* Check if OrderDate has been expired and then delete the cb print
	*/
	 global void execute(Database.BatchableContext BC, List<sobject> scope){
	 	
	 	system.debug('## START AP31_BatchDeleteCB');
	 	
	 	system.debug('## execute country ' + country);
	 	
	 	List<ORD_Order__c> ordersTobedeleted = new List<ORD_Order__c>();

		for(SObject so: scope) {
		 		
 			ORD_Order__c ord = (ORD_Order__c)so;

 			if ((isAutomaticDeletion || !checkValidity(ord.OrderDate__c, validityPeriod))
			 	&& ord.Payment_Transaction_Draft_Creation__c < dateNow.addHours(-1)) {
		 			
				ordersTobedeleted.add((ORD_Order__c)so);
 			}
		}
		
	 	if (ordersTobedeleted.size() > 0) {

	 		List<ORD_Order__c> ordersToUpdate = new List<ORD_Order__c>();
	 		List<Error_log__c> lLogs = new List<Error_log__c>();
	 		for (ORD_Order__c ordToManage : ordersTobedeleted) {
	 			AP36_Payline_Handler.Result res = AP36_Payline_Handler.ws_doReset(ordToManage.Id, false);
	 			if (res.isSuccess) {
	 				ordersToUpdate.add((ORD_Order__c)res.ord);
	 			} else if(res.log != null){
	 				lLogs.add(res.log);
	 			}
	 		}
			system.debug('>>> ordersToUpdate: ' + ordersToUpdate);
	 		if (!ordersToUpdate.isEmpty()) {
	 			update ordersToUpdate;
	 		}
	 		if (!lLogs.isEmpty()) {
	 			insert lLogs;
	 		}
	 	}

		
		system.debug('## END AP31_BatchDeleteCB');
	 }
	 
	 
	 private boolean checkValidity(DateTime orderDate, Decimal validity){
	 	
	 	//check if order is valid
	 	if(validityPeriod != null){
	 		return orderDate.addHours(Integer.valueOf(validity)) > dateNow ;
	 	}else{
	 		return true;
	 	}
	 }
	
	global void finish(Database.BatchableContext BC){
                    
    }


}