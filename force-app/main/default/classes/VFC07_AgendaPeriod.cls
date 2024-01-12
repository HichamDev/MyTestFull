public with sharing class VFC07_AgendaPeriod {
    
    /* 
------------------------------------------------------------
-- - Name          : VFC07_AgendaPeriod
-- - Author        : ASE
-- - Description   : Class used to retrive period information.  Controller for Component C07_AgendaPeriod.component
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 05-SEPT-2012  ASE    1.0    Initial version
------------------------------------------------------------
*/
	
	public list<PER_Period__c> periodList{get;set;}
    public VFC07_AgendaPeriod(){
    system.debug('>>>>>>>>>>>>>>>>>>>>> Start of VFC07_AgendaPeriod');	
    
        Id recTypeBusinessPeriod = [select Id from RecordType 
                                    where DeveloperName =: system.label.PER00001
                                    and SobjectType=: SHW_IBZ_Constants.PER].Id;
                                    
        // select all business period
        periodList =  [ select  StartDate__c, Name, Id, EndDate__c, ColourCode__c, RecordTypeId 
                        From PER_Period__c
                        where RecordTypeId  = :recTypeBusinessPeriod]; 
   }

}