global with sharing class AP35_SchBatchPurge implements Schedulable{ 
/* 
--------------------------------------------------------------------------------------------------
-- - Name          : AP35_SchBatchPurge 
-- - Author        : WCH
-- - Description   : Class to schedule batch class to delete records according to the parameters defined in the custom setting BatchPurgeOptions
--                   
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------------------
-- 24-DEC-2015  WCH    1.0      Initial version
--------------------------------------------------------------------------------------------------
*/
    
    global void execute (SchedulableContext sc)
    {
        System.debug('## execute of Class AP35_SchBatchPurge implements Schedulable - Start');
        
        Map<String, BatchPurgeOptions__c> allPurgeOptions = BatchPurgeOptions__c.getAll();
        String country='';
        String objName='';
        Set<String> allObjectNames=new Set<String>();

        //get list of all available objects and check whether object name specified is valid
        for ( Schema.SObjectType typ : Schema.getGlobalDescribe().values() ) {
          String sobjName = String.valueOf(typ);
            allObjectNames.add(sobjName);
        }

        System.debug('allObjectNames: ' + allObjectNames);

        system.debug('## Start all scheduling AP35_BatchPurge<<<<<');

        for(String country_objName : allPurgeOptions.keySet()){
            if(allPurgeOptions.get(country_objName).isActive__c){
                objName=allPurgeOptions.get(country_objName).objectName__c;
                System.debug('## AP35_SchBatchPurge : Object to purge>>'+objName);
                System.debug('## AP35_SchBatchPurge : parameters:');
                System.debug('## AP35_SchBatchPurge : batchName__c:'+allPurgeOptions.get(country_objName).batchName__c);
                country=allPurgeOptions.get(country_objName).countryCode__c;
                System.debug('## AP35_SchBatchPurge : countryCode__c:'+country);
                System.debug('## AP35_SchBatchPurge : removeAllData__c:'+allPurgeOptions.get(country_objName).removeAllData__c);
                System.debug('## AP35_SchBatchPurge : queryWhere__c:'+allPurgeOptions.get(country_objName).queryWhere__c);
                System.debug('## AP35_SchBatchPurge : ValidityPeriod__c:'+allPurgeOptions.get(country_objName).ValidityPeriod__c);
                if(allObjectNames.contains(objName)){
                    
                    AP35_BatchPurge batch1 = new AP35_BatchPurge(country,objName);
                    database.executebatch(batch1);
                }else{
                    system.debug('## scheduling AP35_BatchPurge for object :'+objName+' failed because object does not exist');
                }
                
                
            }
         }

        system.debug('## End all scheduling AP35_BatchPurge<<<<<');
        
        /*
        AP35_SchBatchPurge testSch = new AP35_SchBatchPurge();
        String sch = '0 0 13 * * ?';
        
        system.schedule('AP35_SchBatchPurge', sch, testSch);
        
        AP35_BatchPurge batch = new AP35_BatchPurge();
        database.executebatch(batch);
        */
        System.debug('## execute of Class AP07_BatchDeleteAgendaPeriod implements Schedulable - End');
    }
}