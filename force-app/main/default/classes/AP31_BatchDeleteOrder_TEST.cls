/*
----------------------------------------------------------------------
-- - Name          : AP31_BatchDeleteOrder_TEST.cls
-- - Author        : NGO
-- - Description   : Delete Orders on salesforce Test class
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 04-APR-2014  NGO    1.0      Initial version

----------------------------------------------------------------------  
*/
@isTest
private class AP31_BatchDeleteOrder_TEST {
    
    
    static testMethod void testScheduler() {
        
        Test.startTest();
        
        AP31_SchESP_BatchDeleteOrder  SchESP = new AP31_SchESP_BatchDeleteOrder ();
        
        AP31_SchFRA_BatchDeleteOrder  SchFRA = new AP31_SchFRA_BatchDeleteOrder ();
         
        AP31_SchITA_BatchDeleteOrder  SchITA = new AP31_SchITA_BatchDeleteOrder ();
         
        AP31_SchMEX_BatchDeleteOrder  SchMEX = new AP31_SchMEX_BatchDeleteOrder ();
          
        AP31_SchVEN_BatchDeleteOrder  SchVEN = new AP31_SchVEN_BatchDeleteOrder ();
        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing AP31_BatchDeleteOrder FRA', sch, SchFRA);
        
        system.schedule('Testing AP31_BatchDeleteOrder ESP', sch, SchESP);
        
        system.schedule('Testing AP31_BatchDeleteOrder ITA', sch, SchITA);
        
        system.schedule('Testing AP31_BatchDeleteOrder MEX', sch, SchMEX);
        
        system.schedule('Testing AP31_BatchDeleteOrder VEN', sch, SchVEN);
        
        Test.stopTest();
    }

    static testMethod void automatiqueDelete() {
        
        Test.startTest();
        
        system.assertEquals(0, countOrder('FRA'));
        
        createCustomSettingAutomatique();
        
        createOrders(4, datetime.newInstance(2014, 04, 1, 12, 30, 2), 'xxxx');
        
        createOrdersPending(2, datetime.newInstance(2013, 04, 1, 12, 30, 2), 'xxxx2');
        
        system.assertEquals(6, countOrder('FRA'));
        
        system.assertEquals(4, countOrderline());
        
        
        AP31_BatchDeleteOrder deleteOrder = new AP31_BatchDeleteOrder('FRA');
        
        system.AssertEquals('FRA', deleteOrder.country);
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(deleteOrder);

        Test.StopTest(); 
                
        system.assertEquals(2, countOrder('FRA'));
        
        system.assertEquals(0, countOrderline());
        
        AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        
        system.AssertEquals('Completed', apexJob.status);
        
        system.AssertEquals(0, apexJob.NumberOfErrors);
       
    }
    
    /* static testMethod void purgeDelete() {
        
        Test.startTest();
        
        system.assertEquals(0, countOrder('FRA'));
        
        createCustomSettingPurge();
        
        createOrders(4, datetime.newInstance(2014, 04, 3, 12, 30, 2), 'xxxx');
        
        createOrdersPending(2, datetime.newInstance(2012, 04, 1, 12, 30, 2), 'xxxx2');
        
        system.assertEquals(6, countOrder('FRA'));
        
        AP31_BatchDeleteOrder deleteOrder = new AP31_BatchDeleteOrder('FRA');
        
        system.AssertEquals('FRA', deleteOrder.country);
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(deleteOrder);

        Test.StopTest(); 
        system.debug('List of Order' +  [select Id,  Status__c from ORD_Order__c where  Country_Code__c = 'FRA' ]);         
        system.assertEquals(4, countOrder('FRA'));
        AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        
        system.AssertEquals('Completed', apexJob.status);
        
        system.AssertEquals(0, apexJob.NumberOfErrors);
       
    }*/
    
     static testMethod void validityDelete() {
        
        Test.startTest();
        
        system.assertEquals(0, countOrder('FRA'));
        
        createCustomValildity();
        
        createOrders(2, system.Today() - 3650, 'xxxx1');
        
        createOrders(2, system.Today() - 3650, 'xxxx2');
        
        createOrders(2, system.Today() + 3650, 'xxxx3');
        
        system.assertEquals(6, countOrder('FRA'));
        
        AP31_BatchDeleteOrder deleteOrder = new AP31_BatchDeleteOrder('FRA');
        
        system.AssertEquals('FRA', deleteOrder.country);
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(deleteOrder);
        
        Test.StopTest(); 
        
        system.assertEquals(2, countOrder('FRA'));
        
        AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        
        system.AssertEquals('Completed', apexJob.status);
        
        system.AssertEquals(0, apexJob.NumberOfErrors);
       
    }
    
    static private void createOrders(Integer numberOfOrder, DateTime orderDate, String dealer){
        
        List<ORD_Order__c> orders = new List<ORD_Order__c>();
        
        Contact contact = new Contact(STHID__c=dealer,TECH_ExternalId__c=dealer, AccountId=createAccount(), lastname='br09Contact',firstname='br09Contact', MinOrder__c=50, MinOrderFreeTransportFees__c=50);
        
        insert contact;
        
        for(integer i = 0;i<numberOfOrder; i++){
            
            ORD_Order__c orderC = new ORD_Order__c();
            
            orderC.OrderDate__c = orderDate;
            
            orderC.Dealer__c = contact.Id;
            
            orders.add(orderC);
        }
        
        insert orders;
        
        orders = [select id from ORD_Order__c where  Country_Code__c = 'FRA' ];
        
        List<ORL_OrderLine__c> orderlines = new List<ORL_OrderLine__c>(); 
        
        for(ORD_Order__c ord : orders){
            
            ORL_OrderLine__c orderline = new ORL_OrderLine__c(Order__c = ord.id,
                                                        //Article__c = articleID,
                                                        RegularPrice__c = 100,
                                                        Qty__c = 10,
                                                        Amount__c = 1000,
                                                        AmountWihtoutTax__c = 1000,
                                                        Commission__c = 0);
            
            orderlines.add(orderline);
        }
        insert orderlines;
    }
    
    static private void createOrdersPending(Integer numberOfOrder, DateTime orderDate, String dealer){
        
        List<ORD_Order__c> orders = new List<ORD_Order__c>();
        
        Contact contact = new Contact(STHID__c=dealer,TECH_ExternalId__c=dealer, AccountId=createAccount(), lastname='br09Contact',firstname='br09Contact', MinOrder__c=50, MinOrderFreeTransportFees__c=50);
        
        insert contact;
        
        for(integer i = 0;i<numberOfOrder; i++){
            
            ORD_Order__c orderC = new ORD_Order__c();
            
            orderC.OrderDate__c = orderDate;
            
            orderC.Dealer__c = contact.Id;
            
            orderC.Status__c = 'Pending';
            
            orders.add(orderC);
        }
        
        insert orders;
    }
    
    static private void createCustomValildity(){
        
        BatchOrderDeletionOptions__c options = new BatchOrderDeletionOptions__c();
        
        options.Name = 'FRA';
        
        options.IsAutomaticDeletion__c = false;
        
        options.ValidityPeriod__c = 3;
        
        insert options;
    }
    
     static private void createCustomSettingAutomatique(){
        
        BatchOrderDeletionOptions__c options = new BatchOrderDeletionOptions__c();
        
        options.Name = 'FRA';
        
        options.IsAutomaticDeletion__c = true;
        
        //options.isActivatePurge__c = false;
        
        insert options;
    }
    
    /*static private void createCustomSettingPurge(){
        
        BatchOrderDeletionOptions__c options = new BatchOrderDeletionOptions__c();
        
        options.Name = 'FRA';
        
        options.IsAutomaticDeletion__c = false;
        
        options.ValidityPeriod__c = 3;
        
        options.isActivatePurge__c = true;
        
        options.PurgeValidityPeriod__c = 365;
        
        insert options;
    }*/
    
    static private Integer countOrder(String country){
        
        Integer num = [select count() from ORD_Order__c where  Country_Code__c = : country ];
        
        return num;
        
    }
    
     static private Integer countOrderline(){
        
        Integer num = [select count() from ORL_OrderLine__c ];
        
        return num;
        
    }
    
    static Id createAccount(){
    
        String acc_name = 'Test Account BR04';
        
        Account acct = new Account(name=acc_name, Country_Code__c='FRA');
        
        insert acct;
        
        return acct.Id;
    }
}