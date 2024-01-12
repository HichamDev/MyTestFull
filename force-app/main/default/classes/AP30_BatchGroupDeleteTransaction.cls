global class AP30_BatchGroupDeleteTransaction implements Database.Batchable<sobject>{
/*
// AP30_BatchGroupDeleteTransaction
----------------------------------------------------------------------
-- - Name          : AP30_BatchGroupDeleteTransaction
-- - Author        : WCHY
-- - Description   : Batch class to group all Transactions that have been aggregated and delete them
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 25-MAY-201   WCHY    1.0      Intitial version
----------------------------------------------------------------------
**********************************************************************
*/
  public set<id> contactIdSet = new set<id>();
  public list<STA_Statement__c> statementList = new list<STA_Statement__c>();
  
  public string country;
  public list<Id> transactionListing;
  public dateTime TimeStartToDelete;
  
  public static final String STA_STATUS_VALIDATED = 'Validated'; 
  
  public static final String STA_TYPE_BALANCE = 'Balance';
  
  public static final String STA_TYPE_TRANSACTION = 'Transaction';
  
  public string sta_LoyaltyProgRecTypeId =  [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.STA_LoyaltyProgramRecType and SObjectType = 'STA_Statement__c' Limit 1].id;
  
  global AP30_BatchGroupDeleteTransaction(String forCountry,list<Id> transactionIds,dateTime theTime){
    
    country = forCountry;
    //contactListing 
    transactionListing = transactionIds;
    TimeStartToDelete = theTime;
    
  }
  
  global Database.QueryLocator start(Database.batchableContext info)
  {
    
    system.debug('## start country AP30_BatchGroupDeleteTransaction ' + country);
     
    // String query = 'select Id  from STA_Statement__c where  Country_code__c = \''+country+'\' and ';//Contact__c
     
     
     if(Test.isRunningTest()){
       //query = 'select Id  from STA_Statement__c  where  Country_code__c = \''+country+'\' limit 20';
       return Database.getQueryLocator([select Id  from STA_Statement__c  where  Country_code__c = : country limit 20]);
     }
     
     return Database.getQueryLocator([select Id  from STA_Statement__c where  Country_code__c =: country and Type__c=: STA_TYPE_TRANSACTION and Id IN : transactionListing and RecordTypeId = :sta_LoyaltyProgRecTypeId and CreatedDate < : TimeStartToDelete]);
    }
 
    global void execute(Database.BatchableContext BC, List<Sobject> scope)
    {
      system.debug('>>>> start Execute AP30_BatchGroupDeleteTransaction<<<<<<');
      // Retrieving statements ID to proccess delete
      
      Set<Id> statementScope = new Set<Id>();
      
      for (Sobject so : scope)
      {
        statementScope.add(((STA_Statement__c) so).Id);
      }
        
      system.debug('#### statementScope.size() '+ statementScope.size());
       
      deleteTransaction(statementScope);
    }
    
    /*
    * Delete statements of type Transaction which have been processed
    */
    private void deleteTransaction(Set<Id> statementList){
      
       List<STA_Statement__c> statementTBDList = [SELECT id
                                          FROM STA_Statement__c
                                          WHERE Id = :statementList
                                          ];
        if(statementTBDList.size() > 0){ 
           delete statementTBDList; 
        }
    }
    
    
 
    global void finish(Database.BatchableContext BC){}

}