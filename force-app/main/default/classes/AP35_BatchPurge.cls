/*
----------------------------------------------------------------------
-- - Name          : AP35_BatchPurge.cls
-- - Author        : WCH
-- - Description   : Delete records on salesforce depending on customs setting BatchPurgeOptions__c
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 07-JAN-2016  WCH    1.0      Initial version

----------------------------------------------------------------------  
*/
global class  AP35_BatchPurge implements Database.Batchable<sobject> {

  global string country; 

  global string countryField; 
  
  global string queryWhereClause; 
  
  global string objectName;

  global string country_objectName; 
  
  global boolean isAutomaticDeletion;
  
  global Decimal validityPeriod;
  
  global boolean isDoNothing = false;
  
  global Datetime dateNow;
  
  global Database.QueryLocator start(Database.BatchableContext BC){
    
    system.debug('## AP35_BatchPurge>> start >> country ' + country);
    String query='';
    if(isDoNothing){
      query='select Id from Account limit 0';
    }else{
      query = 'select Id  from '+objectName+' where '+queryWhereClause+' and '+countryField+' = \''+country+'\' ';

      //if isAutomaticDeletion is not checked then check createdDate field
      if(!isAutomaticDeletion){
        Datetime theDate=(dateNow.AddDays(Integer.valueOf(validityPeriod)*-1));
        system.debug('## AP35_BatchPurge>> start >> theDate ' + theDate);
        query=query + 'and LastModifiedDate < :theDate';
      }
      //country = 'FRA';
      if(Test.isRunningTest()){
        query = 'select Id  from '+objectName+' where '+queryWhereClause+' and '+countryField+' = \''+country+'\' limit 20';
      }
      
      system.debug('## AP35_BatchPurge>> start >> query ' + query);
    }
    
    return Database.getQueryLocator(query);
   }

   global AP35_BatchPurge(String  forCountry, String theObjName ){
    
    Map<String, BatchPurgeOptions__c> mapAllPurgeOptions = BatchPurgeOptions__c.getAll();
    this.country_objectName= forCountry+'#'+theobjName;
    this.country = forCountry;

    if(Test.isRunningTest()){
      //The date now is set to 04/04/2014 when executing test case to be able to test the deletion.
      dateNow = datetime.newInstance(2014, 04, 04, 12, 30, 2);
      
    }else{
      
      dateNow = datetime.now();
    }


    if(mapAllPurgeOptions.containsKey(country_objectName)){


      isAutomaticDeletion = mapAllPurgeOptions.get(country_objectName).removeAllData__c;
     
      validityPeriod =  isAutomaticDeletion == false ? mapAllPurgeOptions.get(country_objectName).ValidityPeriod__c : 0;
  
      queryWhereClause = mapAllPurgeOptions.get(country_objectName).queryWhere__c;
  
      objectName = mapAllPurgeOptions.get(country_objectName).objectName__c;

      countryField = mapAllPurgeOptions.get(country_objectName).countryCodeField__c;
 
    }else{
      isDoNothing = true;
    }
    
    system.debug('## constructor country: ' + forCountry);

   }
  
  /**
  * Check if OrderDate has been expired and then delete them
  */
   global void execute(Database.BatchableContext BC, List<sobject> scope){
    
    system.debug('## START AP35_BatchPurge');
    
    system.debug('## execute country ' + country);
    system.debug('## execute objectName ' + objectName);

    
    if(!isDoNothing){

      List<SObject> objectListTobeDeleted = new List<SObject>();

      for (SObject SObj : scope) {
          objectListTobeDeleted.add(SObj);
      }

      if(objectListTobeDeleted.size() > 0)
          delete objectListTobeDeleted;

    }
    
    system.debug('## END AP35_BatchPurge');
   }
   
 
  global void finish(Database.BatchableContext BC){
                    
    }

}