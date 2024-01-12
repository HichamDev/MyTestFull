/******************************************************************************
*   @author Simon Gourreau
*   @date 05/01/2021
*   @description AP45_OrderItemHandler test class
*
*/
@isTest
public with sharing class AP45_OrderItemHandler_Test {
    private final static String PROD_EXT_ID = 'Prod_ext_id';
    private final static String PBE_EXT_ID = 'PBE_ext_id';

    @testSetup 
    static void dataCreation() {
        User__c customSettings = new User__c();
        customSettings.isInterfaceUser__c = true;
        customSettings.SetupOwnerId = Userinfo.getProfileId();
        
        insert customSettings;
    }

    @isTest
    public static void setIdsWithExternalIdInfo() {
        Account vAcc = new Account();
        vAcc.Name = 'Account Name';
        Database.insert(vAcc);

        AP1000_Utils_Test.generateOffers();
        
        PriceBook2 pb = [SELECT Id FROM PriceBook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1'];
        string pbeId = [SELECT Id FROM PriceBookEntry WHERE PriceBook2Id = :pb.Id LIMIT 1].Id;
        
        Product2 prod = new Product2(
            Name = 'prod',
            Lu_Country__c = 'FRA',
            isActive = true,
            LU_TECH_External_Id__c = PROD_EXT_ID
        );
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1.00, isActive = true, LU_TECH_External_Id__c = PBE_EXT_ID);
        insert pbe;
        
        Order ord = new Order(
            AccountId = vAcc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft',
            PriceBook2Id = pb.Id
        );
        insert ord;

        Test.startTest();
        OrderItem vOrderIt = new OrderItem(Quantity = 5,
                                            PriceBookEntryId = pbe.Id,
                                            OrderId = ord.Id,
                                            UnitPrice = 5.00,
                                            LU_Child_Product_TECH_ID__c = PROD_EXT_ID,
                                            Product2Id_TECH_ID__c = PROD_EXT_ID,
                                            PricebookEntryId_TECH_ID__c = PBE_EXT_ID);
        insert vOrderIt;
        Test.stopTest();
        OrderItem vOrdItResult = [Select Id, LU_Child_Product__c, LU_Child_Product__r.LU_TECH_External_Id__c,
                                        Product2Id, Product2.LU_TECH_External_Id__c, PricebookEntry.LU_TECH_External_Id__c
                                    From OrderItem
                                    Where Id = :vOrderIt.Id 
                                    Limit 1];
        System.assertEquals(PROD_EXT_ID, vOrdItResult.LU_Child_Product__r.LU_TECH_External_Id__c);
        System.assertEquals(PBE_EXT_ID, vOrdItResult.PricebookEntry.LU_TECH_External_Id__c);
    }
}