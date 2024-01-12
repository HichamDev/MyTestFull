@isTest
private class AP30_BatchGroupBalanceTEST {
/*
// AP30_BatchGroupBalanceTEST
----------------------------------------------------------------------
-- - Name          : AP30_BatchGroupBalanceTEST 
-- - Author        : YGO
-- - Description   : Test class to test the batch class to update balance
                     and delete validated statements 
--                    
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 24-MAY-2013  YGO    1.0      Intitial version
----------------------------------------------------------------------
**********************************************************************
*/


    static testMethod void testScheduler(){
        
        Test.startTest();
        
        AP30_SchFRA_BatchGroupBalance  TestFRASchedule = new AP30_SchFRA_BatchGroupBalance();
        
        AP30_SchITA_BatchGroupBalance  TestITASchedule = new AP30_SchITA_BatchGroupBalance();
        
        AP30_SchMEX_BatchGroupBalance  TestMEXSchedule = new AP30_SchMEX_BatchGroupBalance();
        
        AP30_SchVEN_BatchGroupBalance  TestVENSchedule = new AP30_SchVEN_BatchGroupBalance();
        
        AP30_SchESP_BatchGroupBalance  TestESPSchedule = new AP30_SchESP_BatchGroupBalance();
        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing FRA AP30_BatchGroupBalance', sch, TestFRASchedule);
        
        system.schedule('Testing ITA AP30_BatchGroupBalance', sch, TestITASchedule);
        
        system.schedule('Testing MEX AP30_BatchGroupBalance', sch, TestMEXSchedule);
        
        system.schedule('Testing VEN AP30_BatchGroupBalance', sch, TestVENSchedule);
        
        system.schedule('Testing ESP AP30_BatchGroupBalance', sch, TestESPSchedule);
        
        Test.stopTest();
        
    }

    static testMethod void testBatchGroupBalance() 
    {
        id contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
        system.debug('>>>>>> contactDealerRecordTypeID : ' + contactDealerRecordTypeID);
       
        //Retrieving Profile Ids
        id DealerProfileId = [select id from Profile where Name= :system.label.CON00001].Id;
        system.debug('>>>>>> DealerProfileId : ' + DealerProfileId);
        
        id productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
                
        list<Account> accountList = new List<Account>{
            new Account(Name='AccountTest1'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test1'
                        , Country_Code__c='FRA'),
            new Account(Name='AccountTest2'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test2'
                        , Country_Code__c='FRA')
        };
        insert (accountList);
        
        system.debug('>>>>>> accountList : ' + accountList);
        
        //Creating new contacts
        list<Contact> contactList = new List<Contact>{
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest1'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , STHID__c = 'test1'
                        , AccountId = accountList[0].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , OrderAmountLimitForLp2__c = 500),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest2'
                        , Birthdate = system.Today() - 7300
                        , email = 'a@test2.com'
                        , STHID__c = 'test2'
                        , AccountId = accountList[1].id
                        , CurrentBalance__c = -5
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50)
        };
        insert (contactList);
        system.debug('>>>>>> contactList : ' + contactList);
        
        list<ART_Article__c> articleList = new List<ART_Article__c>{
            new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[0]
                               , Name = 'Shampoo1'
                               , LocalName__c = 'Shampoo1'
                               , CurrencyIsoCode='EUR'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[1]
                                , Name = 'Shampoo2'
                                , LocalName__c = 'Shampoo2'
                               , CurrencyIsoCode='EUR'),
            new ART_Article__c(RecordTypeId = productRecordTypeID  //articleList[2]
                               , Name = 'Gel1'
                               , LocalName__c = 'Gel1'
                               , CurrencyIsoCode='EUR'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[3]
                                , Name = 'Gel2'
                                , LocalName__c = 'Gel2'
                               , CurrencyIsoCode='EUR'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[4]
                                , Name = 'Deo1'
                                , LocalName__c = 'Deo1'
                               , CurrencyIsoCode='EUR')
        }; 
        insert(articleList);
        
        list<ORD_Order__c> orderList = new list<ORD_Order__c>{
                            new ORD_Order__c(Dealer__c = contactList[0].id,
                                             Status__c = 'Draft'),
                            new ORD_Order__c(Dealer__c = contactList[1].id,
                                             Status__c = 'Draft')
                                           };
        insert (orderList);
        
        system.debug('#### orderList[0].Status__c : ' + orderList[0].Status__c);
        system.debug('#### orderList[1].Status__c : ' + orderList[1].Status__c);
        
        //TODO Multi LP.
        list<ORL_OrderLine__c> orderLineList = new list<ORL_OrderLine__c>{
                            new ORL_OrderLine__c(Article__c = articleList[0].id,
                                                 LPAmount__c = '16.2',
                                                 LPCode__c = 'LP1',
                                                 Order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP2',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '20',
                                                 LPCode__c = 'LP3',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '20.2',
                                                 LPCode__c = 'LP4',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP5',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP7',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP8',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP9',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP10',
                                                 order__c = orderList[1].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP11',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP12',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP13',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP14',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP15',
                                                 order__c = orderList[1].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP16',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP17',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP18',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP19',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP20',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'COM',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'LP6',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft'),
                            new ORL_OrderLine__c(Article__c = articleList[1].id,
                                                 LPAmount__c = '18.2',
                                                 LPCode__c = 'ADM',
                                                 order__c = orderList[0].id,
                                                 TECH_OrderStatus__c = 'Draft')
                                           };
        insert orderLineList;
        
        for(integer a=0; a<orderLineList.size(); a++)
        {
            orderLineList[a].TECH_OrderStatus__c = 'Pending';
        }
        system.debug('### updating orderlines to generate statements : ');
        update orderLineList;
        
        //testing if statement correctly created
        set<id> statementIdSet = new set<id>();
        for(integer i=0 ; i<orderLineList.size(); i++)
        {
            statementIdSet.add(orderLineList[i].id);
        }
        
        system.debug('### statementIdSet.size() : ' + statementIdSet.size());
             
        /*list <STA_Statement__c> teststatementList = [select id, Type__c,LpCode__c, Status__c, Contact__c,Contact__r.Name from STA_Statement__c where OrderLine__c IN:statementIdSet];
        system.debug('#### teststatementList.size() : ' + teststatementList.size());
        
        for(integer j=0; j<teststatementList.size(); j++)
        {
            system.debug('#### Type of statement '+ j +': ' + teststatementList[j].Type__c);
            system.debug('#### Status of statement ' + j +': ' + teststatementList[j].Status__c);   
            system.debug('#### LP CODE of statement ' + j +': ' + teststatementList[j].LpCode__c);  
            system.debug('#### LContact__c of statement ' + j +': ' + teststatementList[j].Contact__r.Name);  
        }
                
        list<STA_Statement__c> validateStatement = [select id, Type__c, Status__c,LpCode__c, Contact__c from STA_Statement__c where Type__c = 'Transaction' and OrderLine__c IN:statementIdSet];
        
        system.debug('#### validateStatement.size() : ' + validateStatement.size());
        
        for(integer j=0; j<validateStatement.size(); j++ )
        {
            validateStatement[j].Status__c = 'Validated';
            system.debug('#### Type of statement j '+ j +': ' + teststatementList[j].Type__c);
            system.debug('#### Status of statement j' + j +': ' + teststatementList[j].Status__c);   
            system.debug('#### LP CODE of statement j' + j +': ' + teststatementList[j].LpCode__c);  
            system.debug('#### LContact__c of statement j' + j +': ' + teststatementList[j].Contact__r.Name);  
        }
        
        update validateStatement;*/
        
        //Start Test
        Test.StartTest();
        
         AP30_BatchGroupBalance testBatchGroupBalance = new AP30_BatchGroupBalance('FRA');
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(testBatchGroupBalance);
        Test.StopTest(); 
        
        AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
                                from AsyncApexJob
                                where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        system.AssertEquals(apexJob.status,'Completed');
        system.AssertEquals(apexJob.NumberOfErrors,0);
         
        list<STA_Statement__c> balanceStatement = [select Id, AmountLP1__c,AmountLP2__c From STA_Statement__c where Contact__c =: contactList[0].id and Type__c = 'Balance' order by LastModifiedDate desc limit 1];
        if(balanceStatement != null && balanceStatement.size()>0){
            system.AssertEquals(balanceStatement[0].AmountLP1__c, 16.2);
        
            //system.AssertEquals(balanceStatement[0].AmountLP2__c, 18.2);
            /* Happy project */
            system.AssertEquals(balanceStatement[0].AmountLP2__c, 0);
            system.debug('###balanceStatement[0].AmountLP2__c : ' +balanceStatement[0].AmountLP2__c);
        }
        list<STA_Statement__c> statementList = [select Id From STA_Statement__c where Contact__c =: contactList[0].id and Type__c = 'Transaction'];
        system.debug('### statementList.size(): ' + statementList.size());
        //system.AssertEquals(statementList.size(), 0);
        
         
    }
}