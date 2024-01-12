global class AP15_BatchWeeklyActivity implements Database.Batchable<sobject>{
/*
// AP15_WeeklyActivity
----------------------------------------------------------------------
-- - Name          : AP15_BatchWeeklyActivity
-- - Author        : YGO
-- - Description   : Batch to create new weekly activity
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 25-JUN-2013  YGO    1.0      Intitial version
-- 17-JUN-2014  NGO    2.0      Modify to cater for governor limit  
----------------------------------------------------------------------
**********************************************************************
*/

    
    public Datetime d = system.now();
    
    public map<id,  PER_Period__c> periodMap = new map <id,  PER_Period__c>();
    
    global map <id, id> previousActualPeriodMap;
    
    global set<Id> previousPeriodSet;
    
    global map <id, String> previousActualTECHExternalIDMap;
    
    public list <WAT_WeeklyActivity__c> watList = new list<WAT_WeeklyActivity__c>();
    
    global AP15_BatchWeeklyActivity(){
        
        previousActualPeriodMap = new map<id, id>();
    
        previousPeriodSet = new set<Id>();
    
        previousActualTECHExternalIDMap = new map<id, string>();
        
        Id periodRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.PeriodWeekRecType and SObjectType = 'PER_Period__c' Limit 1].id;
        
        system.debug('### periodRecordTypeID: ' + periodRecordTypeID);
          
        system.debug('### datetime ' + d);

        for (PER_Period__c p : [Select TECH_ExternalId__c, ParentPeriod__c, Name, Id From PER_Period__c where StartDate__c <: d and EndDate__c >: d and RecordTypeId = : periodRecordTypeID]){
           
            previousActualPeriodMap.put(p.ParentPeriod__c, p.id);
            previousActualTECHExternalIDMap.put(p.ParentPeriod__c, p.TECH_ExternalId__c);
            previousPeriodSet.add(p.ParentPeriod__c);     
        }
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        system.debug('previousActualPeriodMap '+previousActualPeriodMap);
        system.debug('previousPeriodSet '+previousPeriodSet);

        String query = 'Select Status__c,'+
                       'PreviousForecastFactsheet__c,'+ 
                       'PotentialNewHostesses__c,'+ 
                       'PotentialNewDealers__c,'+ 
                       'Period__c,'+ 
                       'NbrOfMeetings__c,'+ 
                       'NbrOfMeetingsPlannedW_2__c,'+ 
                       'NbrOfMeetingsInLastWeekForecast__c,'+ 
                       'NbrMeetingsPlannedW_9__c,'+ 
                       'NbrMeetingsPlannedW_8__c,'+ 
                       'NbrMeetingsPlannedW_7__c,'+ 
                       'NbrMeetingsPlannedW_6__c,'+ 
                       'NbrMeetingsPlannedW_5__c,'+ 
                       'NbrMeetingsPlannedW_4__c,'+ 
                       'NbrMeetingsPlannedW_3__c,'+ 
                       'NbrMeetingsPlannedW_1__c,'+ 
                       'Id,'+ 
                       'EndWeek__c,'+ 
                       'Dealer__c,'+ 
                       'CurrencyIsoCode,'+ 
                       'AvgSales__c,'+ 
                       'AvgSalesInLastWeekForecast__c,'+ 
                       'AvgNbrOfAttendeesInLastWeek__c,'+ 
                       'AvgNbrAttendees__c,'+ 
                       'AvgExpectedSales_W2__c,'+ 
                       'AvgExpectedSalesW9__c,'+ 
                       'AvgExpectedSalesW8__c,'+ 
                       'AvgExpectedSalesW7__c,'+ 
                       'AvgExpectedSalesW6__c,'+ 
                       'AvgExpectedSalesW5__c,'+ 
                       'AvgExpectedSalesW4__c,'+ 
                       'AvgExpectedSalesW3__c,'+ 
                       'AvgExpectedSalesW1__c,'+ 
                       'AvgExpectedNbrAttendees_W_2__c,'+ 
                       'AvgExpectedNbrAttendeesW_9__c,'+ 
                       'AvgExpectedNbrAttendeesW_8__c,'+ 
                       'AvgExpectedNbrAttendeesW_7__c,'+ 
                       'AvgExpectedNbrAttendeesW_6__c,'+ 
                       'AvgExpectedNbrAttendeesW_5__c,'+ 
                       'AvgExpectedNbrAttendeesW_4__c,'+ 
                       'AvgExpectedNbrAttendeesW_3__c,'+ 
                       'AvgExpectedNbrAttendeesW_1__c,'+ 
                       'Approver__c'+ 
                       ' From WAT_WeeklyActivity__c'+  
                       ' where Period__c  IN : previousPeriodSet';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        for (Sobject so : scope){
            
            watList.add(createNewWeeklyActivity((WAT_WeeklyActivity__c)so));
        }

        system.debug('### watList.size() : '+ watList.size());
        
        
        if(watList.size()>0){
            upsert watList;
        }
    }
    
    
    global WAT_WeeklyActivity__c createNewWeeklyActivity(WAT_WeeklyActivity__c wat){
        
        WAT_WeeklyActivity__c watToCreate = new WAT_WeeklyActivity__c();
            
        watToCreate.Approver__c = wat.Approver__c;
        watToCreate.Dealer__c = wat.Dealer__c;
        
        system.debug('### createNewWeeklyActivity prev : '+ wat.Period__c);
         
        system.debug('### createNewWeeklyActivity actual: '+ previousActualPeriodMap.get(wat.Period__c));
        
        system.debug('### createNewWeeklyActivity previousActualPeriodMap : '+ previousActualPeriodMap);
          
        watToCreate.Period__c = previousActualPeriodMap.get(wat.Period__c);
        watToCreate.Status__c = 'Draft';
        watToCreate.PreviousForecastFactsheet__c = wat.ID;
        
        watToCreate.AvgNbrAttendees__c = wat.AvgExpectedNbrAttendeesW_1__c;
        watToCreate.AvgExpectedNbrAttendeesW_1__c = wat.AvgExpectedNbrAttendees_W_2__c;
        watToCreate.AvgExpectedNbrAttendees_W_2__c = wat.AvgExpectedNbrAttendeesW_3__c;
        watToCreate.AvgExpectedNbrAttendeesW_3__c = wat.AvgExpectedNbrAttendeesW_4__c;
        watToCreate.AvgExpectedNbrAttendeesW_4__c = wat.AvgExpectedNbrAttendeesW_5__c;
        watToCreate.AvgExpectedNbrAttendeesW_5__c = wat.AvgExpectedNbrAttendeesW_6__c;
        watToCreate.AvgExpectedNbrAttendeesW_6__c = wat.AvgExpectedNbrAttendeesW_7__c;
        watToCreate.AvgExpectedNbrAttendeesW_7__c = wat.AvgExpectedNbrAttendeesW_8__c;
        watToCreate.AvgExpectedNbrAttendeesW_8__c = wat.AvgExpectedNbrAttendeesW_9__c;
        
        watToCreate.AvgSales__c = wat.AvgExpectedSalesW1__c;
        watToCreate.AvgExpectedSalesW1__c = wat.AvgExpectedSales_W2__c;
        watToCreate.AvgExpectedSales_W2__c = wat.AvgExpectedSalesW3__c;
        watToCreate.AvgExpectedSalesW3__c = wat.AvgExpectedSalesW4__c;
        watToCreate.AvgExpectedSalesW4__c = wat.AvgExpectedSalesW5__c;
        watToCreate.AvgExpectedSalesW5__c = wat.AvgExpectedSalesW6__c;
        watToCreate.AvgExpectedSalesW6__c = wat.AvgExpectedSalesW7__c;
        watToCreate.AvgExpectedSalesW7__c = wat.AvgExpectedSalesW8__c;
        watToCreate.AvgExpectedSalesW8__c = wat.AvgExpectedSalesW9__c;
        
        //watToCreate.NbrOfMeetings__c = wat.NbrMeetingsPlannedW_1__c;
        watToCreate.NbrOfMeetings__c = 0;
        watToCreate.NbrMeetingsPlannedW_1__c = wat.NbrOfMeetingsPlannedW_2__c;
        watToCreate.NbrOfMeetingsPlannedW_2__c = wat.NbrMeetingsPlannedW_3__c;
        watToCreate.NbrMeetingsPlannedW_3__c = wat.NbrMeetingsPlannedW_4__c;
        watToCreate.NbrMeetingsPlannedW_4__c = wat.NbrMeetingsPlannedW_5__c;
        watToCreate.NbrMeetingsPlannedW_5__c = wat.NbrMeetingsPlannedW_6__c;
        watToCreate.NbrMeetingsPlannedW_6__c = wat.NbrMeetingsPlannedW_7__c;
        watToCreate.NbrMeetingsPlannedW_7__c = wat.NbrMeetingsPlannedW_8__c;
        watToCreate.NbrMeetingsPlannedW_8__c = wat.NbrMeetingsPlannedW_9__c;
        
        return watToCreate;
        
    }
    
    global void finish(Database.BatchableContext BC){
                    
    }
}