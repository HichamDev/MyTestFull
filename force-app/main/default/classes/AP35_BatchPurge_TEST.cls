/*
----------------------------------------------------------------------
-- - Name          : AP35_BatchPurge_TEST.cls
-- - Author        : WCH
-- - Description   : AP35_BatchPurge TEST class on salesforce
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 18-JAN-2016  WCH    1.0      Initial version

----------------------------------------------------------------------  
*/
@isTest
private class AP35_BatchPurge_TEST {

    static List<Account> accountList;
    static List<Contact> contactList;
    static List<ART_Article__c> articleList;
    static List<ORD_Order__c> orderList;
    static List<ORL_OrderLine__c> orderLineList;
    static List<BatchPurgeOptions__c> purgeObjectOptions;     
    static Id contactDealerRecordTypeID, productRecordTypeID;

    static{
        //Retrieving Record Type related to Contact
        contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = 'Dealer' and SObjectType = 'Contact' Limit 1].id;
        system.debug('>>>>>> contactDealerRecordTypeID : ' + contactDealerRecordTypeID);

        //Product
        productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        
        //create new accounts
        accountList = new List<Account>{
            new Account(Name='AccountTest1'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test1'
                        , Country_Code__c = 'FRA'
                        , WebServiceAvailability__c = true),
            new Account(Name='AccountTest1'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test1'
                        , Country_Code__c = 'ITA'
                        , WebServiceAvailability__c = true)
        };
        insert (accountList);
        //Creating new contacts
        contactList = new List<Contact>{
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest1'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , STHID__c = 'test1'
                        , AccountId = accountList[0].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=10
                        , MinOrderFreeTransportFees__c=50
                        , LoyaltyProgramToBeDisplayed__c = 'LP1;LP2;lp3;lp4;lp5;lp6;lp7;lp8;lp9;lp10;lp11;lp12;lp13;lp14;lp15;lp16;lp17;lp18;lp19;lp20;Adm;Com'
                        ),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest2'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test2.com'
                        , STHID__c = 'test2'
                        , AccountId = accountList[1].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=10
                        , MinOrderFreeTransportFees__c=50
                        , LoyaltyProgramToBeDisplayed__c = 'LP1;LP2;lp3;lp4;lp5;lp6;lp7;lp8;lp9;lp10;lp11;lp12;lp13;lp14;lp15;lp16;lp17;lp18;lp19;lp20;Adm;Com'
                        )
        };
        insert(contactList);
        //create new articles
        articleList = new List<ART_Article__c>{
            new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[0]
                               , Name = 'Shampoo1'
                               , LocalName__c = 'Shampoo1'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[1]
                                , Name = 'Shampoo2'
                                , LocalName__c = 'Shampoo2'),
            new ART_Article__c(RecordTypeId = productRecordTypeID  //articleList[2]
                               , Name = 'Gel1'
                               , LocalName__c = 'Gel1')
        };
        insert(articleList);
        //create new order
        orderList = new List<ORD_Order__c>{
                new ORD_Order__c(dealer__c = contactList[0].id
                                 , Status__c = 'Cancelled'
                                 , OrderDate__c = system.TODAY()),
                new ORD_Order__c(dealer__c = contactList[1].id
                                 , Status__c = 'Cancelled'
                                 , OrderDate__c = system.TODAY())
        };
        insert(orderList);
        //create new orderlines
        orderLineList = new List<ORL_OrderLine__c>{
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[0].Id
                                     , PublicPrice__c = 100
                                     , Qty__c = 1
                                     , Amount__c = 2
                                     , TECH_ArticleType__c = 'Master'
                                     , TECH_OrderStatus__c = 'Pending'),
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[1].Id
                                     , PublicPrice__c = 100
                                     , Qty__c = 1
                                     , Amount__c = 3
                                     , TECH_ArticleType__c = 'Master'
                                     , TECH_OrderStatus__c = 'Pending'),
                new ORL_OrderLine__c(Order__c = orderList[1].id
                                     , Article__c = articleList[2].Id
                                     , PublicPrice__c = 100
                                     , Qty__c = 1
                                     , Amount__c = 3
                                     , TECH_ArticleType__c = 'Master'
                                     , TECH_OrderStatus__c = 'Pending')
        };
        insert(orderLineList); 

        //populate custom setting with parameters
        purgeObjectOptions = new List<BatchPurgeOptions__c>{
            new BatchPurgeOptions__c(Name='FRA#ORD_Order__c',
                                        batchName__c='FRA_OrderPurge_StatusCancelled',
                                        countryCode__c='FRA',
                                        countryCodeField__c='Country_Code__c',
                                        isActive__c=true,
                                        removeAllData__c=true,
                                        objectName__c='ORD_Order__c',
                                        queryWhere__c='Status__c = \'Cancelled\'',
                                        ValidityPeriod__c=0), 
            new BatchPurgeOptions__c(Name='ITA#ORD_Order__c',
                                        batchName__c='ITA_OrderPurge_StatusCancelled',
                                        countryCode__c='ITA',
                                        countryCodeField__c='Country_Code__c',
                                        isActive__c=true,
                                        removeAllData__c=false,
                                        objectName__c='ORD_Order__c',
                                        queryWhere__c='Status__c = \'Cancelled\'',
                                        ValidityPeriod__c=20)
        };
        insert purgeObjectOptions;

        //insert orders
   }

    static testMethod void testScheduler() {
        
        Test.startTest();
        
        AP35_SchBatchPurge  SchALLOptions = new AP35_SchBatchPurge ();
        
       
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing AP35_SchBatchPurge', sch, SchALLOptions);
        
        Test.stopTest();
    }

    static testMethod void purgeNotFound() {
        
        Test.startTest();
        
        system.assertEquals(1, countOrder('FRA'));

        system.assertEquals(1, countOrder('ITA'));

        AP35_BatchPurge batchPurge = new AP35_BatchPurge('FRA_X','ORD_Order__c');
        
        system.AssertEquals('FRA_X', batchPurge.country);
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(batchPurge);

        Test.StopTest(); 
        
        system.assertEquals(1, countOrder('FRA'));

        system.assertEquals(1, countOrder('ITA'));

       

        
        AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        
        system.AssertEquals('Completed', apexJob.status);
        
        system.AssertEquals(0, apexJob.NumberOfErrors);

    }

    static testMethod void automatiqueDelete() {
        
        Test.startTest();
        
        system.assertEquals(1, countOrder('FRA'));

        system.assertEquals(1, countOrder('ITA'));

        AP35_BatchPurge batchPurge = new AP35_BatchPurge('FRA','ORD_Order__c');
        
        system.AssertEquals('FRA', batchPurge.country);
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(batchPurge);

        Test.StopTest(); 
        
        system.assertEquals(0, countOrder('FRA'));

        system.assertEquals(1, countOrder('ITA'));

       

        
        AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        
        system.AssertEquals('Completed', apexJob.status);
        
        system.AssertEquals(0, apexJob.NumberOfErrors);

    }
    static testMethod void validityPeriodDelete() {
        
        Test.startTest();
        
        system.assertEquals(1, countOrder('FRA'));

        system.assertEquals(1, countOrder('ITA'));

        AP35_BatchPurge batchPurge = new AP35_BatchPurge('ITA','ORD_Order__c');
        
        system.AssertEquals('ITA', batchPurge.country);
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(batchPurge);

        Test.StopTest(); 
        
        system.assertEquals(1, countOrder('FRA'));

        system.assertEquals(0, countOrder('ITA'));

       

        
        AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        
        system.AssertEquals('Completed', apexJob.status);
        
        system.AssertEquals(0, apexJob.NumberOfErrors);

    }
    static private Integer countOrder(String country){
        
        Integer num = [select count() from ORD_Order__c where  Country_Code__c = : country ];
        
        return num;
        
    }
    
    
}