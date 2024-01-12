/******************************************************************************
*   @author Simon Gourreau
*   @date 29/09/2020
*   @description AP44_OrderHandler test class
*
*/
@isTest
public with sharing class AP44_OrderHandler_Test {
    private final static String ORDER_NAME = 'Test ord';
    private final static String ACCOUNT_NAME = 'Test acc';
    private final static String ACCOUNT_NAME_FAKE = 'Test acc fake';
    private final static String ACCOUNT_EXT_ID = 'Acc_ext_id';
    private final static String CONTACT_EXT_ID = 'Con_ext_id';
    private final static String PRICEBOOK_EXT_ID = 'Pb_ext_id';
    private final static String USER_EXT_ID = 'Us_ext_id';
    private final static String USERNAME_ADMIN = 'SAdmin@sth.com';
    private final static String PROD_EXT_ID = 'Prod_ext_id';
    private final static String PBE_EXT_ID = 'PBE_ext_id';
    private final static String CONTACT_NAME = 'Test Rebate';
    private final static String CONTACT_EMAIL = 'email@test.com';
    private final static String CONTACT_Title = 'Smile';
    private final static String ORDER_RULE_NAME = 'Test REBATE';

    @testSetup 
    static void dataCreation() {
        User__c customSettings = new User__c();
        customSettings.isInterfaceUser__c = true;
        customSettings.SetupOwnerId = Userinfo.getProfileId();
        
        insert customSettings;

        List<Account> vListAccs = new List<Account>();
        
        Account vFakeAcc = new Account();
        vFakeAcc.Name = ACCOUNT_NAME_FAKE;
        vListAccs.add(vFakeAcc);

        Account vAcc = new Account();
        vAcc.Name = ACCOUNT_NAME;
        vAcc.TECH_ExternalId__c = ACCOUNT_EXT_ID;
        vListAccs.add(vAcc);
        Database.insert(vListAccs);

        Order vOrder = new Order();
        vOrder.Status = AppConstants.ORDER_STATUS_DRAFT;
        vOrder.AccountId = vAcc.Id;
        vOrder.Name = ORDER_NAME;
        vOrder.EffectiveDate = Date.today();
        Database.insert(vOrder);

        Contact vCon = new Contact(AccountId = vAcc.Id,
                                        Lastname = 'Con Name',
                                        TECH_ExternalId__c = CONTACT_EXT_ID);
        Database.insert(vCon);

        Datetime startDate = Datetime.now().addDays(-1);
        Datetime endDate = Datetime.now().addDays(10);

        Pricebook2 vPb = new Pricebook2(Name = 'Catalogue_standard', 
                                        isActive = true,
                                        LU_Tech_External_Id__c = PRICEBOOK_EXT_ID,
                                        LU_Start_Date__c = startDate, 
                                        LU_End_date__c = endDate);
        insert vPb;

        Id vProfileAdmin = [Select Id 
                            From Profile 
                            Where Name in ('System Administrator', 'Administrateur Système') 
                            limit 1].Id;

        User vUser = new User(alias = 'SAdmin', email = USERNAME_ADMIN, emailencodingkey = 'UTF-8', 
                                lastname = 'system Admin', languagelocalekey = 'fr', localesidkey = 'fr_FR_EURO', 
                                profileid = vProfileAdmin, timezonesidkey = 'Europe/Paris', 
                                username = USERNAME_ADMIN, MobilePhone = '34567', TECH_ExternalId__c = USER_EXT_ID);

        Database.insert(vUser);

        // Pricebook
        Pricebook2 pb = new Pricebook2(Name = 'Catalogue_standard', isActive = true, LU_Country__c = 'ITA', LU_Start_Date__c = startDate, LU_End_date__c = endDate,
        LU_Tech_External_Id__c = 'ITA_Pricebook_1');
        insert pb;

        AP1000_Utils_Test.generateProducts('ITA');

        AP1000_Utils_Test.generatePricebookEntries('ITA', pb.Id);

        Contact c = new Contact();
        Id dealer=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        c.RecordtypeId=dealer;
        c.AccountId=vAcc.Id;
        c.email='rebate.test@example.com';
        c.birthDate=System.today();
        c.STHID__c='457811';
        c.MinOrder__c = 50;
        c.title=CONTACT_Title;
        c.LastName='Test Rebate';
        Database.insert(c);

        User u = AP01_TestDataFactory.createPortalUser();
        u.ContactId = c.Id;
        u.email = CONTACT_EMAIL;
        insert u;

        LU_Order_Rule__c rule = new LU_Order_Rule__c();
        Id discount=Schema.SObjectType.LU_Order_Rule__c.getRecordTypeInfosByName().get('Order - Discount').getRecordTypeId();
        rule.RecordtypeId=discount;
        rule.LU_Name__c=ORDER_RULE_NAME;
        rule.LU_Criteria_Value_2__c=100.00;
        rule.Title__c=CONTACT_Title;
        rule.LU_Country__c='ITA';
        rule.Discount__c=18;
        insert rule;
    }

    @isTest
    public static void setOrderNumberWhenValidated(){
        List<Order> vListOrders = [Select Id, Name 
                                    From Order 
                                    Where Name = :ORDER_NAME Limit 1];
        if(vListOrders.size() > 0) {
            Order vOrder = vListOrders[0];
            vOrder.Status = AppConstants.ORDER_STATUS_PENDING;

            Test.startTest();
            Database.update(vOrder);
            Test.stopTest();

            User vUs = [Select Id, TECH_LU_LastValidatedOrderNb__c 
                        From User 
                        Where Id = :UserInfo.getUserId()];
            System.assertEquals(vOrder.Name, vUs.TECH_LU_LastValidatedOrderNb__c);
        }
    }

    @isTest
    public static void setIdsWithExternalIdInfo() {
        Account vAcc = [Select Id From Account Where Name = :ACCOUNT_NAME_FAKE];
        Test.startTest();
        Order vOrder = new Order(AccountId = vAcc.Id,
                                Name = 'TestSGO', 
                                EffectiveDate = Date.today(), 
                                Status = AppConstants.ORDER_STATUS_DRAFT,
                                AccountId_TECH_ID__c = ACCOUNT_EXT_ID,
                                BillToContactId_TECH_ID__c = CONTACT_EXT_ID,
                                OwnerId_TECH_ID__c = USER_EXT_ID,
                                PriceBook2Id_TECH_ID__c = PRICEBOOK_EXT_ID);
        insert vOrder;
        Test.stopTest();
        Order vOrdResult = [Select Id, AccountId, Account.TECH_ExternalId__c,
                                BillToContactId, BillToContact.TECH_ExternalId__c,
                                Pricebook2Id, Pricebook2.LU_Tech_External_Id__c
                            From Order
                            Where Id = :vOrder.Id 
                            Limit 1];
        System.assertEquals(ACCOUNT_EXT_ID, vOrdResult.Account.TECH_ExternalId__c);
        System.assertEquals(CONTACT_EXT_ID, vOrdResult.BillToContact.TECH_ExternalId__c);
        System.assertEquals(PRICEBOOK_EXT_ID, vOrdResult.Pricebook2.LU_Tech_External_Id__c);
    }

    @isTest
    public static void setCommercialPeriodTest(){
        Account vAcc = new Account();
        vAcc.Name = 'Account Name';
        Database.insert(vAcc);

        AP1000_Utils_Test.generateOffers();
        
        PriceBook2 pb = [SELECT Id FROM PriceBook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1'];
        string pbeId = [SELECT Id FROM PriceBookEntry WHERE PriceBook2Id = :pb.Id LIMIT 1].Id;
        
        Product2 prod = new Product2(
            Name = 'prod',
            Lu_Country__c = 'FRA',
            isActive = true
        );
        insert prod; 
        
        Order ord = new Order(
            AccountId = vAcc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft',
            PriceBook2Id = pb.Id
        );
        insert ord;

        Test.startTest();
        ord.Status = 'Pending';
        update ord;

        Test.stopTest();
    }

    @isTest
    public static void setRebateDiscountOnPersonalUseTest(){
        Account vAcc = [Select Id
        From Account 
        Where Name =: ACCOUNT_NAME limit 1];

        User u =[Select Id, Email, Title
        From User 
        Where email = :CONTACT_EMAIL limit 1];

        System.runAs(u){
            List<PriceBook2> pbs = [SELECT Id FROM PriceBook2 WHERE LU_Tech_External_Id__c = 'ITA_Pricebook_1'];
            PriceBook2 pb;
            System.debug(pbs.size());
            if(pbs.size()>0) {
                pb = pbs[0];
            }
            string pbeId = [SELECT Id FROM PriceBookEntry WHERE LU_TECH_External_Id__c = 'ITA_96992_0' LIMIT 1].Id;
            
            
            Product2 prod = new Product2(
                Name = 'prod',
                Lu_Country__c = 'ITA',
                isActive = true
            );
            insert prod;
            
            Order ord = new Order(
                Name='TEST_REBATE',
                AccountId = vAcc.Id,
                EffectiveDate = System.today(),
                Status = 'Draft',
                PriceBook2Id = pb.Id,
                BillToContactId = [SELECT Id FROM CONTACT WHERE Email = 'rebate.test@example.com' LIMIT 1].Id
            );

        
            insert ord;
            OrderItem vOrderIt = new OrderItem(Quantity = 5,
            PriceBookEntryId = pbeId,
            OrderId = ord.Id,
            UnitPrice = 20.00,
            LU_TECH_External_Id__c = 'ITA_REBETE',
            LU_Valid_For_Total_Amount_Base__c = true,
            LU_Child_Product_TECH_ID__c = PROD_EXT_ID,
            Product2Id_TECH_ID__c = PROD_EXT_ID,
            LU_Discount_Type__c = 'Personal Use',
            LU_Offer_Type__c='Personal Use',
            PricebookEntryId_TECH_ID__c = 'ITA_96992_0');
            vOrderIt.LU_Dealer_Price__c = 20.00;

            insert vOrderIt;
            // AP44_OrderHandler.firstRun = true;
            update ord;
            ord = [SELECT Id, name, Total_Amount_Total_Personal_Use__c, Rebate_Discount_Personal_Use__c, Discount__c from order where Name='TEST_REBATE'];
            System.assertEquals(18, ord.Rebate_Discount_Personal_Use__c);
            System.assertEquals(18, ord.Discount__c);
        }
        
    
    }


    @isTest
    public static void rebateDiscountOnPersonalUseTest(){
        Account vAcc = [Select Id
        From Account 
        Where Name =: ACCOUNT_NAME limit 1];

        User u =[Select Id, Email, Title
        From User 
        Where email = :CONTACT_EMAIL limit 1];

        System.runAs(u){
            List<PriceBook2> pbs = [SELECT Id FROM PriceBook2 WHERE LU_Tech_External_Id__c = 'ITA_Pricebook_1'];
            PriceBook2 pb;
            System.debug(pbs.size());
            if(pbs.size()>0) {
                pb = pbs[0];
            }
            string pbeId = [SELECT Id FROM PriceBookEntry WHERE LU_TECH_External_Id__c = 'ITA_96992_0' LIMIT 1].Id;
            
            
            Product2 prod = new Product2(
                Name = 'prod',
                Lu_Country__c = 'ITA',
                isActive = true
            );
            insert prod;
            
            Order ord = new Order(
                Name='TEST_REBATE_INSERT',
                AccountId = vAcc.Id,
                EffectiveDate = System.today(),
                Status = 'Draft',
                PriceBook2Id = pb.Id,
                BillToContactId = [SELECT Id FROM CONTACT WHERE Email = 'rebate.test@example.com' LIMIT 1].Id
            );

        
            insert ord;
            OrderItem vOrderIt = new OrderItem(Quantity = 5,
            PriceBookEntryId = pbeId,
            OrderId = ord.Id,
            UnitPrice = 20.00,
            LU_TECH_External_Id__c = 'ITA_REBETE',
            LU_Valid_For_Total_Amount_Base__c = true,
            LU_Child_Product_TECH_ID__c = PROD_EXT_ID,
            Product2Id_TECH_ID__c = PROD_EXT_ID,
            LU_Discount_Type__c = 'Personal Use',
            LU_Offer_Type__c='Personal Use',
            PricebookEntryId_TECH_ID__c = 'ITA_96992_0');
            vOrderIt.LU_Dealer_Price__c = 20.00;

            insert vOrderIt;
            AP44_OrderHandler.firstRun = true;

            ord = [SELECT Id, name, LU_TECH_AmountForMinimumOrder__c, Total_Amount_Total_Personal_Use__c, Rebate_Discount_Personal_Use__c, Discount__c from order where Name='TEST_REBATE_INSERT'];

            String test = AP44_OrderHandler.rebateDiscountOnPersonalUse(ord);
            ord = [SELECT Id, name, Total_Amount_Total_Personal_Use__c, Rebate_Discount_Personal_Use__c, Discount__c from order where Name='TEST_REBATE_INSERT'];
            System.assert(test.contains('18'));
        }
        
    
    }

}