/*
----------------------------------------------------------------------
-- - Name          : AP31_BatchDeleteOrder.cls
-- - Author        : NGO
-- - Description   : Delete Orders on salesforce
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 04-APR-2014  NGO    1.0      Initial version

----------------------------------------------------------------------	
*/
global class  AP31_BatchDeleteOrder implements Database.Batchable<sobject> {

	global string country; 
	
	global boolean isAutomaticDeletion;
	
	global Decimal validityPeriod;
	
	global boolean isActivatePurge;
	
	global Decimal purgeValidityPeriod;
	
	global boolean isDoNothing = false;
	
	global Datetime dateNow;
	 
	global Database.QueryLocator start(Database.BatchableContext BC){
	 	
	 	system.debug('## start country ' + country);
	 	
	 	String query = 'select Id, OrderDate__c, Status__c  from ORD_Order__c where  Country_Code__c = \''+country+'\' and OrderType__c<>\'Online\' AND Status__c = \'Draft\' AND Payment_Transaction_Token__c = \'\' ';
	 	
	 	//country = 'FRA';
	 	if(Test.isRunningTest()){
	 		query = 'select Id, OrderDate__c, Status__c  from ORD_Order__c where  Country_Code__c = \''+country+'\' and OrderType__c<>\'Online\' ';
	 	}
	 	
	 	return Database.getQueryLocator(query);
	 }

	 global AP31_BatchDeleteOrder(String  forCountry){
	 	
	 	
	 	map <string, BatchOrderDeletionOptions__c> mapBatchOrderDeletionOptions =  BatchOrderDeletionOptions__c.getAll();
	 	 
	 	if(Test.isRunningTest()){
	 		//The date now is set to 04/04/2014 when executing test case to be able to test the deletion.
	 		dateNow = datetime.newInstance(2014, 04, 04, 12, 30, 2);
	 		
	 	}else{
	 		
	 		dateNow = datetime.now();
	 	}

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
	* Check if OrderDate has been expired and then delete them
	*/
	 global void execute(Database.BatchableContext BC, List<sobject> scope){
	 	
	 	system.debug('## START AP31_BatchDeleteOrder');
	 	
	 	system.debug('## execute country ' + country);
	 	system.debug('>> scope : ' + scope.size());
	 	
	 	if(!isDoNothing){
	 	
		 	List<ORD_Order__c> ordersTobedeleted = new List<ORD_Order__c>();
		 	
		 	List<ORD_Order__c> ordersTobePurged = new List<ORD_Order__c>();
		 	
		 	Set<Id> ordersSet = new Set<Id>();
		 	
		 	if(isAutomaticDeletion){
		 		
		 		for(SObject so: scope){
		 		
		 			ORD_Order__c ord = (ORD_Order__c)so;
		 			
		 			if(ord.status__c.equals('Draft')){
		 			
		 				ordersTobedeleted.add(ord);
		 			}
		 		
		 		}
		 		
		 	} else {
		 		
		 		for(SObject so: scope){
		 		
		 			ORD_Order__c ord = (ORD_Order__c)so;
		 			
		 			if(!checkValidity(ord.OrderDate__c, validityPeriod) && ord.status__c.equals('Draft')){
		 			
		 				ordersTobedeleted.add((ORD_Order__c)so);
		 			}
		 		}
		 	}
		 	
		 	if(ordersTobedeleted.size() > 0)
		    	delete ordersTobedeleted;
		    
		    //if purge is activate purge all Order except Draft as it has already been taken care in the draft deletion mode
		    /*if(isActivatePurge){
		    	
		    	for(SObject so: scope){
		 		
		 			ORD_Order__c ord = (ORD_Order__c)so;
		 			
		 			if(!checkValidity(ord.OrderDate__c, purgeValidityPeriod) && !ord.status__c.equals('Draft')){
		 			
		 				ordersTobePurged.add(ord);
		 				ordersSet.add(ord.Id);
		 			}
		 		}
		    }
		    //get invoiceOrder
		    
		    List<INO_InvoiceOrder__c> invoiceOrders = [select Id from INO_InvoiceOrder__c where Order__c in : ordersSet];
		    
		    if(ordersTobePurged.size() > 0)
		    	delete ordersTobePurged;
		    	
		    if(invoiceOrders.size() > 0)
		   		delete invoiceOrders;*/
	 	}
		
		system.debug('## END AP31_BatchDeleteOrder');
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