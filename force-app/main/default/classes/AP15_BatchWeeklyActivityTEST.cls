@isTest
private class AP15_BatchWeeklyActivityTEST {
/*
// AP15_BatchWeeklyActivityTEST
----------------------------------------------------------------------
-- - Name          : AP15_BatchWeeklyActivityTEST 
-- - Author        : YGO
-- - Description   : Test class to test the batch class to create new
					 weekly activity
--                    
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 02-JUL-2013  YGO    1.0      Intitial version
----------------------------------------------------------------------
**********************************************************************
*/ 

	static testMethod void testBatchWeeklyActivity() 
    {
    	id contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
        system.debug('>>>>>> contactDealerRecordTypeID : ' + contactDealerRecordTypeID);
        
        id periodRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.PeriodWeekRecType and SObjectType = 'PER_Period__c' Limit 1].id;
        system.debug('>>>>>> periodRecordTypeID : ' + periodRecordTypeID);
        
        id watRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.WATReadWriteRecType and SObjectType = 'WAT_WeeklyActivity__c' Limit 1].id;
               
        //Retrieving Profile Ids
        id DealerProfileId = [select id from Profile where Name= :system.label.CON00001].Id;
        system.debug('>>>>>> DealerProfileId : ' + DealerProfileId);
        
        ID profileAdmin = userInfo.getprofileId();
        //[Select Id From Profile Where Name =: system.label.SystemAdministratorID].id;
        system.debug('>>>>>>> profileAdmin: ' + profileAdmin);
        
        ID profileInterface = [Select Id From Profile Where name in ( 'Interface','System Interface') limit 1].id;
        system.debug('>>>>>>> profileInterface: ' + profileInterface);
    	
    	/*Create Accounts */
    	list<Account> accountList = new List<Account>{
								            new Account(Name='AccountTest1'
								                        , AccountType__c = 'Level 2'
								                        , Country_Code__c = 'ESP'
								                        , TypeLabel__c = 'Test1'),
								            new Account(Name='AccountTest2'
								                        , AccountType__c = 'Level 2'
								                        , Country_Code__c = 'ITA'
								                        , TypeLabel__c = 'Test2'),
								            new Account(Name='AccountTest3'
								                        , AccountType__c = 'Level 2'
								                        , Country_Code__c = 'FRA'
								                        , TypeLabel__c = 'Test2')
        };
        insert (accountList);
        set<id> accId = new set<id>();
        for(integer i=0 ; i<accountList.size() ; i++)
        {
        	accId.add(accountList[i].id);
        }
        
    	/*Create Dealers/Contacts */
    	list<Contact> contactList = new List<Contact>{
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest1'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , STHID__c = 'test1'
                        , AccountId = accountList[0].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        , ActivityStatus__c = true
 						, MinOrderFreeTransportFees__c=50
 						, TECH_ExternalId__c = '123'),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest2'
                        , Birthdate = system.Today() - 7300
                        , email = 'a@test2.com'
                        , STHID__c = 'test2'
                        , AccountId = accountList[1].id
                        , CurrentBalance__c = -5
                        , MinOrder__c=50
                        , ActivityStatus__c = true
 						, MinOrderFreeTransportFees__c=50
 						, TECH_ExternalId__c = '456')
        };
        insert contactList;
        DateTime d1 = datetime.now();
    	/*Create Periods */
    	list<PER_Period__c> previousPeriodList = new List<PER_Period__c>{
    		new PER_Period__c(RecordTypeId = periodRecordTypeID
            				, Account__c = accountList[0].id
            				, EndDate__c = d1.addDays(-9)
            				, StartDate__c = d1.addDays(-15)
            				, ColourCode__c = 'White'
            				, TECH_ExternalId__c = 'xyz'
                       		)
    	};
    	insert previousPeriodList;
    	
    	list<PER_Period__c> periodList = new List<PER_Period__c>{
            new PER_Period__c(RecordTypeId = periodRecordTypeID
            				, Account__c = accountList[0].id
            				, EndDate__c = d1.addDays(7)
            				, StartDate__c = d1.addDays(-1)
            				, ColourCode__c = 'Red'
            				, TECH_ExternalId__c = 'abc'
                       		),
            new PER_Period__c(RecordTypeId = periodRecordTypeID
            				, Account__c = accountList[0].id
            				, EndDate__c = d1.addDays(-2)
            				, StartDate__c = d1.addDays(-8)
            				, ParentPeriod__c = previousPeriodList[0].id
            				, ColourCode__c = 'Blue'
            				, TECH_ExternalId__c = 'def'
                       		),
            new PER_Period__c(RecordTypeId = periodRecordTypeID
            				, Account__c = accountList[1].id
            				, EndDate__c = d1.addDays(7)
            				, StartDate__c = d1.addDays(-1)
            				, ColourCode__c = 'Yellow'
            				, TECH_ExternalId__c = 'ghi'
                      		),
            new PER_Period__c(RecordTypeId = periodRecordTypeID
            				, Account__c = accountList[1].id
            				, EndDate__c = d1.addDays(-2)
            				, StartDate__c = d1.addDays(-8)
            				, ColourCode__c = 'Green'
            				, TECH_ExternalId__c = 'jkl'
                       		)
        };
        insert periodList;
        
        periodList[0].ParentPeriod__c = periodList[1].id;
        periodList[2].ParentPeriod__c = periodList[3].id;
        update periodList;
        
        system.debug('## periodList: '+periodList);
        
        /*Create users to add as approver in weekly activity*/
        list<User> userList = new list<User> {
        	new User (alias = 'app1'
        			, email='approver1@sth.com'
        			, emailencodingkey='UTF-8'
        			, lastname='Approver1'
        			, languagelocalekey='fr'
        			, localesidkey='fr_FR_EURO'
        			, profileid = profileAdmin
        			, timezonesidkey='Europe/Paris'
        			, username='app1@sth.com'
        			, MobilePhone= '34567'
        			, Phone = '7897567'
        			, TECH_ExternalId__c= 'xyz'
        			  ),
        	new User (alias = 'app2'
        			, email='approver2@sth.com'
        			, emailencodingkey='UTF-8'
        			, lastname='Approver2'
        			, languagelocalekey='fr'
        			, localesidkey='fr_FR_EURO'
        			, profileid = profileAdmin
        			, timezonesidkey='Europe/Paris'
        			, username='app2@sth.com'
        			, MobilePhone= '34567'
        			, Phone = '7897565'
        			, TECH_ExternalId__c= 'abc'
        			  )
        };
        
        insert userList;
    	
    	/*Create previous weekly activities for several dealers. */
    	list<WAT_WeeklyActivity__c> watList = new List<WAT_WeeklyActivity__c>{
            new WAT_WeeklyActivity__c(RecordTypeId = watRecordTypeID
            				, Name = 'Abc'
            				, Approver__c = userList[0].id
            				, Dealer__c = contactList[0].id
            				, Status__c = 'Validated'
            				, Period__c = periodList[1].id
            				, PotentialNewHostesses__c = 1
            				, PotentialNewDealers__c = 2
            				, Comments__c = 'Test class comments '
            				, AvgExpectedNbrAttendeesW_9__c = 9
            				, AvgExpectedNbrAttendeesW_8__c = 8
            				, AvgExpectedNbrAttendeesW_7__c = 7
            				, AvgExpectedNbrAttendeesW_6__c = 6
            				, AvgExpectedNbrAttendeesW_5__c = 5
            				, AvgExpectedNbrAttendeesW_4__c = 4
            				, AvgExpectedNbrAttendeesW_3__c = 3
            				, AvgExpectedNbrAttendees_W_2__c = 2
            				, AvgExpectedNbrAttendeesW_1__c = 1
            				, AvgNbrAttendees__c = 10
            				, AvgExpectedSalesW9__c = 90
            				, AvgExpectedSalesW8__c = 80
            				, AvgExpectedSalesW7__c = 70
            				, AvgExpectedSalesW6__c = 60
            				, AvgExpectedSalesW5__c = 50
            				, AvgExpectedSalesW4__c = 40
            				, AvgExpectedSalesW3__c = 30
            				, AvgExpectedSales_W2__c = 20
            				, AvgExpectedSalesW1__c = 10
            				, AvgSales__c = 100
            				, NbrMeetingsPlannedW_9__c = 100
            				, NbrMeetingsPlannedW_8__c = 110
            				, NbrMeetingsPlannedW_7__c = 120
            				, NbrMeetingsPlannedW_6__c = 130
            				, NbrMeetingsPlannedW_5__c = 140
            				, NbrMeetingsPlannedW_4__c = 150
            				, NbrMeetingsPlannedW_3__c = 160
            				, NbrOfMeetingsPlannedW_2__c = 170
            				, NbrMeetingsPlannedW_1__c = 180
            				, NbrOfMeetings__c = 190
                       ),
            new WAT_WeeklyActivity__c(RecordTypeId = watRecordTypeID
            				, Name = 'PQR'
            				, Approver__c = userList[1].id
            				, Dealer__c = contactList[1].id
            				, Status__c = 'Draft'
            				, Period__c = periodList[3].id
            				, PotentialNewHostesses__c = 1
            				, PotentialNewDealers__c = 2
            				, Comments__c = 'Test class comments '
            				, AvgExpectedNbrAttendeesW_9__c = 9
            				, AvgExpectedNbrAttendeesW_8__c = 8
            				, AvgExpectedNbrAttendeesW_7__c = 7
            				, AvgExpectedNbrAttendeesW_6__c = 6
            				, AvgExpectedNbrAttendeesW_5__c = 5
            				, AvgExpectedNbrAttendeesW_4__c = 4
            				, AvgExpectedNbrAttendeesW_3__c = 3
            				, AvgExpectedNbrAttendees_W_2__c = 2
            				, AvgExpectedNbrAttendeesW_1__c = 1
            				, AvgNbrAttendees__c = 10
            				, AvgExpectedSalesW9__c = 90
            				, AvgExpectedSalesW8__c = 80
            				, AvgExpectedSalesW7__c = 70
            				, AvgExpectedSalesW6__c = 60
            				, AvgExpectedSalesW5__c = 50
            				, AvgExpectedSalesW4__c = 40
            				, AvgExpectedSalesW3__c = 30
            				, AvgExpectedSales_W2__c = 20
            				, AvgExpectedSalesW1__c = 10
            				, AvgSales__c = 100
            				, NbrMeetingsPlannedW_9__c = 100
            				, NbrMeetingsPlannedW_8__c = 110
            				, NbrMeetingsPlannedW_7__c = 120
            				, NbrMeetingsPlannedW_6__c = 130
            				, NbrMeetingsPlannedW_5__c = 140
            				, NbrMeetingsPlannedW_4__c = 150
            				, NbrMeetingsPlannedW_3__c = 160
            				, NbrOfMeetingsPlannedW_2__c = 170
            				, NbrMeetingsPlannedW_1__c = 180
            				, NbrOfMeetings__c = 190
                       )
  	    };
  	     
  	    insert watList;
  	     
  	     
  	    //Start Test
        Test.StartTest();
        
        AP15_SchBatchWeeklyActivity  TestSchedule = new AP15_SchBatchWeeklyActivity ();
        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing AP15_BatchWeeklyActivity', sch, TestSchedule);
        
        AP15_BatchWeeklyActivity testBatchGroupBalance = new AP15_BatchWeeklyActivity();
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(testBatchGroupBalance);
        Test.StopTest(); 
      	
      	AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        system.AssertEquals(apexJob.status,'Completed');
        system.AssertEquals(apexJob.NumberOfErrors,0);
        
        WAT_WeeklyActivity__c w1 = new WAT_WeeklyActivity__c();
        w1 = [Select  Status__c
        			, Period__c
        			, Dealer__c
        			, NbrOfMeetings__c
        			, NbrOfMeetingsPlannedW_2__c
        			, NbrOfMeetingsInLastWeekForecast__c
        			, NbrMeetingsPlannedW_9__c
        			, NbrMeetingsPlannedW_8__c
        			, NbrMeetingsPlannedW_7__c
        			, NbrMeetingsPlannedW_6__c
        			, NbrMeetingsPlannedW_5__c
        			, NbrMeetingsPlannedW_4__c
        			, NbrMeetingsPlannedW_3__c
        			, NbrMeetingsPlannedW_1__c
        			, Name
        			, Id
        			, Comments__c
        			, AvgSales__c
        			, AvgSalesInLastWeekForecast__c
        			, AvgNbrOfAttendeesInLastWeek__c
        			, AvgNbrAttendees__c
        			, AvgExpectedSales_W2__c
        			, AvgExpectedSalesW9__c
        			, AvgExpectedSalesW8__c
        			, AvgExpectedSalesW7__c
        			, AvgExpectedSalesW6__c
        			, AvgExpectedSalesW5__c
        			, AvgExpectedSalesW4__c
        			, AvgExpectedSalesW3__c
        			, AvgExpectedSalesW1__c
        			, AvgExpectedNbrAttendees_W_2__c
        			, AvgExpectedNbrAttendeesW_9__c
        			, AvgExpectedNbrAttendeesW_8__c
        			, AvgExpectedNbrAttendeesW_7__c
        			, AvgExpectedNbrAttendeesW_6__c
        			, AvgExpectedNbrAttendeesW_5__c
        			, AvgExpectedNbrAttendeesW_4__c
        			, AvgExpectedNbrAttendeesW_3__c
        			, AvgExpectedNbrAttendeesW_1__c
        			, Approver__c 
        			From WAT_WeeklyActivity__c
        			where Period__c =: periodList[0].id
        			limit 1]; 
        			
        system.assertequals(w1.NbrMeetingsPlannedW_1__c, 170);
        system.assertequals(w1.Dealer__c, contactList[0].id);
    }//testBatchGroupBalance
}