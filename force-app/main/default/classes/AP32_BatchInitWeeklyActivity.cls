/*
----------------------------------------------------------------------
-- - Name          : AP32_BatchInitWeeklyActivity.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Weekly activities are initialized manually and then an automatic job creates the next one.
-- -                 Each country will be able to choose between the manual and the automatic initialization.

-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 04-APR-2014  WCH    1.0      Initial version

----------------------------------------------------------------------  
*/
global class AP32_BatchInitWeeklyActivity implements Database.Batchable<sobject>{

   global string country;
   
   global Date dt;
   
   global Id thePeriod;
   
   global Map<Id, User> mapContactReportsToUser = new Map<Id, User>();
   
   global Database.QueryLocator start(Database.BatchableContext BC){
     
     system.debug('## start country ' + country);
     
     String query = 'select Id, ReportsToId__c,NumberOfWeeklyActivity__c from Contact where  ActivityStatus__c=true and NumberOfWeeklyActivity__c=0 and AccountCountryCode__c = \''+country+'\'';
     
     //country = 'FRA';
     if(Test.isRunningTest()){
       query = 'select Id, ReportsToId__c,NumberOfWeeklyActivity__c from Contact where  ActivityStatus__c=true and NumberOfWeeklyActivity__c=0 and AccountCountryCode__c = \''+country+'\' limit 30';
     }
     
     return Database.getQueryLocator(query);
   }

   global AP32_BatchInitWeeklyActivity(String  forCountry){
   
     
     
     system.debug('## constructor country ' + forCountry);
     
     this.country = forCountry;
     
     dt=date.today();
     
     Id periodRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.PeriodWeekRecType and SObjectType = 'PER_Period__c' Limit 1].id;
       
     List<PER_Period__c> periods = [SELECT r.id FROM PER_Period__c r WHERE CountryCode__c =: forCountry and StartDate__c <=: dt and EndDate__c >: dt  and RecordTypeId = : periodRecordTypeID Limit 1];

        
     if(periods != null && periods.size() >0){
        system.debug('period found ' );
        thePeriod = periods[0].Id;
     }else{
        
        thePeriod = null;
     }

   }
  
  /**
  * Share all account for country with all its parent recursively through field parentAccount.
  * Method that would be used by trigger AfterInsertAccount.
  */
   global void execute(Database.BatchableContext BC, List<sobject> scope){
     
     system.debug('## START AP32_BatchInitWeeklyActivity');
     
     system.debug('## execute country ' + country);
     
     if(thePeriod != null){
    
         Set<Id> contactIds = new Set<Id>();
         for(sobject so : scope){
             Contact contact = (Contact) so;
              system.debug('## contact retrived' + contact);
             if(contact.ReportsToId__c!=null){
                 contactIds.add(contact.ReportsToId__c);
             }
         }
         mapContactReportsToUser = constructMapContactReportsToUser(contactIds);
         system.debug('## START scope' + scope.size());
         
         List<WAT_WeeklyActivity__c> weeklyActivityCreated = new List<WAT_WeeklyActivity__c>(); 
          
         for(sobject so : scope){
            Contact contact = (Contact) so;
            if(mapContactReportsToUser.size() > 0)
            {
                if(mapContactReportsToUser.get(contact.ReportsToId__c) != null ){
                    WAT_WeeklyActivity__c weeklyActivityContact = createweeklyActivity(mapContactReportsToUser.get(contact.ReportsToId__c).Id,contact.Id,thePeriod);
                    weeklyActivityCreated.add(weeklyActivityContact);
                }
            }
         }
        
         system.debug('## AP32_BatchInitWeeklyActivity weeklyActivityCreated list > ' + weeklyActivityCreated );
        
        if(weeklyActivityCreated.size() > 0 ){
          insert weeklyActivityCreated;
        }
     }
    
    system.debug('## END AP32_BatchInitWeeklyActivity');
   }
   
  /**
  * Create WAT_WeeklyActivity__c object.
  *
  * AccountShare Structure
  *
  * UserOrGroupId -> user with whom to share
  * RowCause -> 'Manuel' will be updated automatically 
  * OpportunityAccessLevel -> 'None'
  * CaseAccessLevel -> 'None'
  * ContactAccessLevel -> not writeable controlled by parent
  * AccountId -> Account to be shared
  * AccountAccessLevel -> 'Edit'
  */
  public  WAT_WeeklyActivity__c createweeklyActivity(Id approver, Id dealer, Id thePeriod){
    
    system.debug('## OUT createweeklyActivity  >  approver :' + approver + ' dealer :' + dealer + 'thePeriod:' + thePeriod);
      
    WAT_WeeklyActivity__c wkActContact = new WAT_WeeklyActivity__c();
    wkActContact.Approver__c = approver;
    wkActContact.Dealer__c = dealer;
    wkActContact.Status__c = 'Draft';
    wkActContact.Period__c = thePeriod;
    
    return wkActContact;
  }
  private static Map<Id, User>  constructMapContactReportsToUser(Set<Id> reportToIds){
    Map<Id, User> mapContactReportsToUser = new Map<Id, User>();
    
   
    
    if(reportToIds != null){

      system.debug('### reportToIds : ' + reportToIds);
      
      for(User user1 : [Select Id, TECH_MergeContactID__c From User  where TECH_MergeContactID__c in : reportToIds]){
        if(user1 != null){
          system.debug('### user1 : ' + user1);
          mapContactReportsToUser.put(Id.ValueOF(user1.TECH_MergeContactID__c),user1);
        }
      }//end of for loop user
      
      system.debug('### mapContactReportsToUser.size() : ' + mapContactReportsToUser.size());
    }
    return mapContactReportsToUser;
  }//end of  constructMapContactReportsToUser
  global void finish(Database.BatchableContext BC){
                    
    }
    
}