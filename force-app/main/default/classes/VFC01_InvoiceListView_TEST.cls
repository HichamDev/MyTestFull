@isTest
private class VFC01_InvoiceListView_TEST {
/*
----------------------------------------------------------------------
-- - Name          : VFC01_InvoiceListView_TEST 
-- - Author        : 
-- - Description   : This class contains unit tests for validating the 
--                   behavior of controller VFC31_PaymentByChequeListView_TEST
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 24-APR-2014         1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/
 static List<Account> accountList;
     static List<Contact> contactList;
     static List<User> userList;
     static List<ART_Article__c> articleList;
     static List<KIT_Kit__c> kitList;
     static List<CAT_Catalog__c> catalogueList;
     static List<CTA_CatalogArticle__c> catArticleList;
     static Id contactDealerRecordTypeID, DealerProfileId, offerRecordTypeID, bundleRecordTypeID, productRecordTypeID;
     static Id chequeRecordTypeID;
    
     static {
        System.Debug('## >>>>> Start VFC01_WeeklyActivityListView_TEST >>> Inserting Data for Tests <<<<<'+UserInfo.getUserName());
        
        //Retrieving Record Type related to Contact
        contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
        system.debug('>>>>>> contactDealerRecordTypeID : ' + contactDealerRecordTypeID);
        
        //Retrieving Record Type related to Article
        
        //Statement of Type=Cheque
         chequeRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = 'Cheque' and SObjectType = 'STA_Statement__c' Limit 1].id;
        //Offer
        offerRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00001 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Bundle
        bundleRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00002 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Product
        productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        
        //Retrieving Profile Ids
        DealerProfileId = [select id from Profile where Name= :system.label.CON00001].Id;
        system.debug('>>>>>> DealerProfileId : ' + DealerProfileId);
        
        //Creating new accounts
        accountList = new List<Account>{
            new Account(Name='AccountTest1'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test1'
                        , Country_Code__c = 'FRA'),
            new Account(Name='AccountTest2'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test2'
                        , Country_Code__c = 'FRA')
        };
        insert (accountList);
        system.debug('>>>>>> accountList : ' + accountList);
        
        //Creating new contacts
        contactList = new List<Contact>{
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest1'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , AccountId = accountList[0].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , ActivityStatus__c = true
                        , AllowedPaymentMode__c='Cheque'
                        ,STHID__c = 'Test12234'),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest2'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test2.com'
                        , AccountId = accountList[1].id
                        , CurrentBalance__c = -5
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , ActivityStatus__c = true
                        ,STHID__c = 'Test12235'
                        )         
        };
        insert (contactList);
        system.debug('>>>>>> contactList : ' + contactList);
        
        //Creating new users
        userList = new List<User>{
            new User(Username ='testemail1@test.com'
                     , LastName = 'TestLastName1'
                     , Email = 'TestEmail1@test.com'
                     , alias = 'testAl1'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , ContactId = contactList[0].Id),
            new User(Username ='testemail2@test.com'
                     , LastName = 'TestLastName1'
                     , Email = 'TestEmail2@test.com'
                     , alias = 'testAl2'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , ContactId = contactList[1].Id)        
        };
        insert (userList);
        system.debug('>>>>>> userList : ' + userList);
    }
        
    static testMethod void invoiceListView() {
        System.Debug('## >>>>> Start VFC31_PaymentByChequeListView_TEST - paymentByChequeTest <<<<<'+UserInfo.getUserName());
      
         system.runAs(userList[0]){
           system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
           List<STA_Statement__c> statList = new List<STA_Statement__c>{
             new STA_Statement__c(
          Label_1__c='TEST_STATEMENT2'
            , Status__c='Validated'
            , TECH_ExternalId__c='TEST_STATEMENT2'
            , Contact__c=contactList[0].Id
            , Cheque_Date__c= system.Today()
            , Cheque_Number__c='1234567'
            , Cheque_Amount__c=200
            , Comments__c='TEST_STATEMENT2'
            ,recordTypeId=chequeRecordTypeID)
           };
        insert(statList);
        
        
        test.startTest();
            PageReference statListPage = Page.VFP01_InvoiceListView;
            Test.setCurrentPage( statListPage );
            
            ApexPages.StandardSetController ssc = new ApexPages.Standardsetcontroller(statList);
            VFC01_InvoiceListView ord = new VFC01_InvoiceListView();
            ord.invoiceSet = null;
            
            ord.getInvoice();
            ord.isPortal=false;
            ord.invoiceSet=null;
            ord.getInvoice();
            ord.getVenInvoice();
            ord.getNumberCurrencyFormat();
            ord.RedirectInvoiceDetail();
         test.stopTest();
         }
    }
}