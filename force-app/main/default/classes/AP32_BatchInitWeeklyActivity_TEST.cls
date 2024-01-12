/*
----------------------------------------------------------------------
-- - Name          : AP32_BatchInitWeeklyActivity_TEST.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Test class for account sharing.
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 04-APR-2014  WCH    1.0      Initial version

----------------------------------------------------------------------  
*/

@isTest
private class AP32_BatchInitWeeklyActivity_TEST {

    static testMethod void initWeeklyActivityTest() {
        
        
        Test.startTest();
        
        Account root = createAccount('root');
        Account master = createAccount('master');
        
        
        Contact contactMaster = createContact('Master',master.Id);
        //Contact contactSlave = createContactReports('root',root.Id, contactMaster);
        //contactSlave.ReportsTo=contactMaster;
        //update contactSlave;
        
        
         Contact contactSlave = new Contact( LastName = 'root'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , AccountId = root.Id
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , ActivityStatus__c = true
                        , AllowedPaymentMode__c='Cheque'
                        , ReportsToId = contactMaster.Id
                        ,STHID__c = 'Test12234');
        insert contactSlave;
        
        contactSlave = [select Id, ReportsToId__c, ReportsToId from Contact where LastName= 'root'][0];
        
        
        system.debug('## contactSlave ' + contactSlave.ReportsToId__c);
         system.debug('## contactSlave ReportsTo' + contactSlave.ReportsToId);
        system.debug('## contactMaster ' + contactMaster.ReportsToId__c);
        
        User userRoot = createUser('root',contactMaster.Id);
        
        Id periodType = [Select r.id From RecordType r Where DeveloperName = :system.label.PeriodWeekRecType and SObjectType = 'PER_Period__c' Limit 1].id;  
        PER_Period__c periodTest=new PER_Period__c();
        periodTest.Account__c=root.Id;
        periodTest.CountryCode__c='FRA';
        periodTest.EndDate__c=datetime.now().addDays(3);
        //periodTest.EndOfWeek__c=datetime.now();
        periodTest.StartDate__c=datetime.now().addDays(-1);
        periodTest.RecordTypeId = periodType;
       
        insert periodTest;
        
        AP32_SchFRA_BatchInitWeeklyActivity  SchFRA = new AP32_SchFRA_BatchInitWeeklyActivity ();
        
        AP32_SchESP_BatchInitWeeklyActivity  SchESP = new AP32_SchESP_BatchInitWeeklyActivity ();
         
        AP32_SchITA_BatchInitWeeklyActivity  SchITA = new AP32_SchITA_BatchInitWeeklyActivity ();
         
        AP32_SchMEX_BatchInitWeeklyActivity  SchMEX = new AP32_SchMEX_BatchInitWeeklyActivity ();
          
        AP32_SchVEN_BatchInitWeeklyActivity  SchVEN = new AP32_SchVEN_BatchInitWeeklyActivity ();
        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing AP32_BatchInitWeeklyActivity FRA', sch, SchFRA);
        
        system.schedule('Testing AP32_BatchInitWeeklyActivity ESP', sch, SchESP);
        
        system.schedule('Testing AP32_BatchInitWeeklyActivity ITA', sch, SchITA);
        
        system.schedule('Testing AP32_BatchInitWeeklyActivity MEX', sch, SchMEX);
        
        system.schedule('Testing AP32_BatchInitWeeklyActivity VEN', sch, SchVEN);
        
        system.AssertEquals(0, getWeeklyActivityCreated(contactSlave.ReportsToId__c, contactSlave.Id)); 
        
        
        AP32_BatchInitWeeklyActivity batchInitWA = new AP32_BatchInitWeeklyActivity('FRA');
        
        system.AssertEquals('FRA', batchInitWA.country);
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(batchInitWA);
        
        Test.StopTest(); 
        
        AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        
        system.AssertEquals('Completed', apexJob.status);
        
        system.AssertEquals(0, apexJob.NumberOfErrors);

        //system.AssertEquals(1, getWeeklyActivityCreated(contactSlave.ReportsToId__c, contactSlave.Id)); 
        
        
                
    }
    
    static Integer getWeeklyActivityCreated(Id approver, Id dealer){
        
        List<WAT_WeeklyActivity__c> lists = [select Id from WAT_WeeklyActivity__c where Approver__c =: approver and Dealer__c =: dealer];

        return lists.size();

   
    }
    
     static  User createUser(String sthId, Id cntId){
        Id DealerProfileId = [select id from Profile where Name= :system.label.CON00001].Id;
        //Profile p = [SELECT id, Name FROM Profile where name = 'FRA_Dealers Manager'].get(0);  
        
        User u = new User( //STHUniqueID__c= sthId,
                          firstname= 'BR04',
                          lastname='XXXX',
                          Alias='BR04',
                          email = 'BR04@XXXXX.com',
                          username= sthId+'BR04@XXXXX.com', 
                          profileId= DealerProfileId, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles',
                          phone = '123456789',
                          ContactId = cntId
                          );
        insert u;
                
        return u;
    }
  
    

    
    static Account createAccount(String name){
    
        String acc_name = name;
        
        Account acct = new Account(name=acc_name, Country_Code__c='FRA');
        insert acct;
        
        return acct;
    }
    static Contact createContact(String name,Id acctId){
    	Id contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
        String contact_name = name;
        
        Contact cnt = new Contact(/*RecordTypeId = contactDealerRecordTypeID
                        ,*/ LastName = contact_name
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , AccountId = acctId
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , ActivityStatus__c = true
                        , AllowedPaymentMode__c='Cheque'
                        ,STHID__c = 'Test12234');
        insert cnt;
        
        return [select Id, ReportsToId__c from Contact where LastName= :contact_name][0];
    }
     static Contact createContactReports(String name,Id acctId, Contact contactMaster){
    	Id contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
        String contact_name = name;
        
        Contact cnt = new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = contact_name
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , AccountId = acctId
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , ActivityStatus__c = true
                        , AllowedPaymentMode__c='Cheque'
                        , ReportsTo = contactMaster
                        ,STHID__c = 'Test12234');
        insert cnt;
        
        return [select Id, ReportsToId__c from Contact where LastName= :contact_name][0];
    }
    
    
}