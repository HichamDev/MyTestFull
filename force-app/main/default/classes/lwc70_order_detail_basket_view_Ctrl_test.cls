@IsTest
public class lwc70_order_detail_basket_view_Ctrl_test {
    
    @IsTest
    static void test_getOrderById_FRA_Catalog() {
        
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA';
        insert u;
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Contact con = [SELECT Id, LU_Counters_To_Be_Displayed__c, LU_Counters_Unit__c, LU_Counter_1_Name__c, LU_Counter_2_Name__c, 
                       LU_Counter_3_Name__c, LU_Counter_4_Name__c, LU_Counter_5_Name__c, LU_Counter_6_Name__c, LU_Counter_7_Name__c, 
                       LU_Counter_8_Name__c, LU_Counter_9_Name__c, LU_Counter_10_Name__c, LU_Counter_11_Name__c, LU_Counter_12_Name__c, 
                       LU_Counter_13_Name__c, LU_Counter_14_Name__c, LU_Counter_15_Name__c, LU_Counter_16_Name__c, LU_Counter_17_Name__c, 
                       LU_Counter_18_Name__c, LU_Counter_19_Name__c, LU_Counter_20_Name__c, CommissionRateRange__c
                       FROM Contact WHERE Id = :u.ContactId];
        con.LU_Counters_To_Be_Displayed__c = '1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#30';
        con.LU_Counters_Unit__c = 'EURO#POINT#POINT#EURO#EURO#EURO#EURO#EURO#EURO#NONE#POINT#POINT#NONE#EURO#EURO#EURO#EURO#EURO#NONE#NONE';
        con.LU_Counter_1_Name__c = 'counter name';
        con.LU_Counter_2_Name__c = 'counter name';
        con.LU_Counter_3_Name__c = 'counter name';
        con.LU_Counter_4_Name__c = 'counter name';
        con.LU_Counter_5_Name__c = 'counter name';
        con.LU_Counter_6_Name__c = 'counter name';
        con.LU_Counter_7_Name__c = 'counter name';
        con.LU_Counter_8_Name__c = 'counter name';
        con.LU_Counter_9_Name__c = 'counter name';
        con.LU_Counter_10_Name__c = 'counter name';
        con.LU_Counter_11_Name__c = 'counter name';
        con.LU_Counter_12_Name__c = 'counter name';
        con.LU_Counter_13_Name__c = 'counter name';
        con.LU_Counter_14_Name__c = 'counter name';
        con.LU_Counter_15_Name__c = 'counter name';
        con.LU_Counter_16_Name__c = 'counter name';
        con.LU_Counter_17_Name__c = 'counter name';
        con.LU_Counter_18_Name__c = 'counter name';
        con.LU_Counter_19_Name__c = 'counter name';
        con.LU_Counter_20_Name__c = 'counter name';
        con.LU_Counter_21_Name__c = 'counter name';
        con.LU_Counter_22_Name__c = 'counter name';
        con.LU_Counter_23_Name__c = 'counter name';
        con.LU_Counter_24_Name__c = 'counter name';
        con.LU_Counter_25_Name__c = 'counter name';
        con.LU_Counter_26_Name__c = 'counter name';
        con.LU_Counter_27_Name__c = 'counter name';
        con.LU_Counter_28_Name__c = 'counter name';
        con.LU_Counter_29_Name__c = 'counter name';
        con.LU_Counter_30_Name__c = 'counter name';
        con.LU_Counter_1_High_Limit__c = 10;
        con.LU_Counter_2_High_Limit__c = 10;
        con.LU_Counter_3_High_Limit__c = 10;
        con.LU_Counter_4_High_Limit__c = 10;
        con.LU_Counter_5_High_Limit__c = 10;
        con.LU_Counter_6_High_Limit__c = 10;
        con.LU_Counter_7_High_Limit__c = 10;
        con.LU_Counter_8_High_Limit__c = 10;
        con.LU_Counter_9_High_Limit__c = 10;
        con.LU_Counter_10_High_Limit__c = 10;
        con.LU_Counter_11_High_Limit__c = 10;
        con.LU_Counter_12_High_Limit__c = 10;
        con.LU_Counter_13_High_Limit__c = 10;
        con.LU_Counter_14_High_Limit__c = 10;
        con.LU_Counter_15_High_Limit__c = 10;
        con.LU_Counter_16_High_Limit__c = 10;
        con.LU_Counter_17_High_Limit__c = 10;
        con.LU_Counter_18_High_Limit__c = 10;
        con.LU_Counter_19_High_Limit__c = 10;
        con.LU_Counter_20_High_Limit__c = 10;
        con.LU_Counter_21_High_Limit__c = 10;
        con.LU_Counter_22_High_Limit__c = 10;
        con.LU_Counter_23_High_Limit__c = 10;
        con.LU_Counter_24_High_Limit__c = 10;
        con.LU_Counter_25_High_Limit__c = 10;
        con.LU_Counter_26_High_Limit__c = 10;
        con.LU_Counter_27_High_Limit__c = 10;
        con.LU_Counter_28_High_Limit__c = 10;
        con.LU_Counter_29_High_Limit__c = 10;
        con.LU_Counter_30_High_Limit__c = 10;
        con.LU_Counter_1_Lower_Limit__c = 1;
        con.LU_Counter_2_Lower_Limit__c = 1;
        con.LU_Counter_3_Lower_Limit__c = 1;
        con.LU_Counter_4_Lower_Limit__c = 1;
        con.LU_Counter_5_Lower_Limit__c = 1;
        con.LU_Counter_6_Lower_Limit__c = 1;
        con.LU_Counter_7_Lower_Limit__c = 1;
        con.LU_Counter_8_Lower_Limit__c = 1;
        con.LU_Counter_9_Lower_Limit__c = 1;
        con.LU_Counter_10_Lower_Limit__c = 1;
        con.LU_Counter_11_Lower_Limit__c = 1;
        con.LU_Counter_12_Lower_Limit__c = 1;
        con.LU_Counter_13_Lower_Limit__c = 1;
        con.LU_Counter_14_Lower_Limit__c = 1;
        con.LU_Counter_15_Lower_Limit__c = 1;
        con.LU_Counter_16_Lower_Limit__c = 1;
        con.LU_Counter_17_Lower_Limit__c = 1;
        con.LU_Counter_18_Lower_Limit__c = 1;
        con.LU_Counter_19_Lower_Limit__c = 1;
        con.LU_Counter_20_Lower_Limit__c = 1;
        con.LU_Counter_21_Lower_Limit__c = 1;
        con.LU_Counter_22_Lower_Limit__c = 1;
        con.LU_Counter_23_Lower_Limit__c = 1;
        con.LU_Counter_24_Lower_Limit__c = 1;
        con.LU_Counter_25_Lower_Limit__c = 1;
        con.LU_Counter_26_Lower_Limit__c = 1;
        con.LU_Counter_27_Lower_Limit__c = 1;
        con.LU_Counter_28_Lower_Limit__c = 1;
        con.LU_Counter_29_Lower_Limit__c = 1;
        con.LU_Counter_30_Lower_Limit__c = 1;
        con.CommissionRateRange__c = 'com';
        update con;
        
        AP1000_Utils_Test.generateOffers();
        
        PriceBook2 pb = [SELECT Id FROM PriceBook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1'];
        
        Product2 prod = new Product2(
            Name = 'prod',
            Lu_Country__c = 'FRA',
            isActive = true
        );
        insert prod;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1.00,
            isActive = true, LU_Counter_Value__c = '-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2'
        );
        insert pbe;
        
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft',
            BillToContactId = u.ContactId,
            PriceBook2Id = pbe.PriceBook2Id
        );
        insert ord;
        
        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            PriceBookEntryId = pbe.Id,
            Product2Id = pbe.Product2Id,
            UnitPrice = 1.00,
            Quantity = 4,
            LU_Contact_For__c = con.Id
        );
        insert oi;

        OrderItem oi2 = new OrderItem(
            OrderId = ord.Id,
            PriceBookEntryId = pbe.Id,
            Product2Id = pbe.Product2Id,
            UnitPrice = 1.00,
            Quantity = 3,
            LU_Contact_For__c = con.Id
        );
        insert oi2;
        
        System.runAs(u){
            lwc70_order_detail_basket_view_Ctrl.Baskets b1 = lwc70_order_detail_basket_view_Ctrl.getOrderById(ord.Id, '');
            lwc70_order_detail_basket_view_Ctrl.Baskets b2 = lwc70_order_detail_basket_view_Ctrl.getOrderById(ord.Id, LABEL.LU_0rder_Detail_By_Customer);
            lwc70_order_detail_basket_view_Ctrl.updateLineQuantityById(oi.Id, 6);
            lwc70_order_detail_basket_view_Ctrl.UserConnected uc = lwc70_order_detail_basket_view_Ctrl.getUserConnectedRights();
            String country = lwc70_order_detail_basket_view_Ctrl.getUserCountry();
            //lwc70_order_detail_basket_view_Ctrl.updateStatusDeleteStockUsed(ord.Id);
            String bundleProducts = lwc70_order_detail_basket_view_Ctrl.getProductListOfBundle(oi.Id);
            List<OrderItem> l_bundleProducts = lwc70_order_detail_basket_view_Ctrl.getExistingOrderItemsOfBundle(oi.Id);
            lwc70_order_detail_basket_view_Ctrl.updateBundleProduct(oi.Id, new List<AP1002_LookupSearchResult>());
            lwc70_order_detail_basket_view_Ctrl.getOrderSortedByCustomerFRA(ord.Id);
            lwc70_order_detail_basket_view_Ctrl.updateStatusDeleteStockUsed(ord.Id);
            lwc70_order_detail_basket_view_Ctrl.deleteLineById(oi.Id);
            lwc70_order_detail_basket_view_Ctrl.deleteLinesAssociatedToContactId(con.Id, 'test', ord.Id);
            lwc70_order_detail_basket_view_Ctrl.deleteLinesAssociatedToContactId(con.Id, '', ord.Id);
            lwc70_order_detail_basket_view_Ctrl.deleteOrderById(ord.Id);
        }
    }
    
    @IsTest
    static void test_getOrderById_ITA_Catalog() {
        
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA';
        insert u;
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Contact con = [SELECT Id, LU_Counters_To_Be_Displayed__c, LU_Counters_Unit__c, LU_Counter_1_Name__c, LU_Counter_2_Name__c, LU_Counter_3_Name__c, LU_Counter_4_Name__c, 
                       LU_Counter_5_Name__c, LU_Counter_6_Name__c, LU_Counter_7_Name__c, LU_Counter_8_Name__c, LU_Counter_9_Name__c, LU_Counter_10_Name__c, 
                       LU_Counter_11_Name__c, LU_Counter_12_Name__c, LU_Counter_13_Name__c, LU_Counter_14_Name__c, LU_Counter_15_Name__c, 
                       LU_Counter_16_Name__c, LU_Counter_17_Name__c, LU_Counter_18_Name__c, LU_Counter_19_Name__c, LU_Counter_20_Name__c, CommissionRateRange__c
                       FROM Contact WHERE Id = :u.ContactId];
        con.LU_Counters_To_Be_Displayed__c = '1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20';
        con.LU_Counters_Unit__c = 'EURO#POINT#POINT#EURO#EURO#EURO#EURO#EURO#EURO#NONE#POINT#POINT#NONE#EURO#EURO#EURO#EURO#EURO#NONE#NONE';
        con.LU_Counter_1_Name__c = 'counter name';
        con.LU_Counter_2_Name__c = 'counter name';
        con.LU_Counter_3_Name__c = 'counter name';
        con.LU_Counter_4_Name__c = 'counter name';
        con.LU_Counter_5_Name__c = 'counter name';
        con.LU_Counter_6_Name__c = 'counter name';
        con.LU_Counter_7_Name__c = 'counter name';
        con.LU_Counter_8_Name__c = 'counter name';
        con.LU_Counter_9_Name__c = 'counter name';
        con.LU_Counter_10_Name__c = 'counter name';
        con.LU_Counter_11_Name__c = 'counter name';
        con.LU_Counter_12_Name__c = 'counter name';
        con.LU_Counter_13_Name__c = 'counter name';
        con.LU_Counter_14_Name__c = 'counter name';
        con.LU_Counter_15_Name__c = 'counter name';
        con.LU_Counter_16_Name__c = 'counter name';
        con.LU_Counter_17_Name__c = 'counter name';
        con.LU_Counter_18_Name__c = 'counter name';
        con.LU_Counter_19_Name__c = 'counter name';
        con.LU_Counter_20_Name__c = 'counter name';
        con.LU_Counter_21_Name__c = 'counter name';
        con.LU_Counter_22_Name__c = 'counter name';
        con.LU_Counter_23_Name__c = 'counter name';
        con.LU_Counter_24_Name__c = 'counter name';
        con.LU_Counter_25_Name__c = 'counter name';
        con.LU_Counter_26_Name__c = 'counter name';
        con.LU_Counter_27_Name__c = 'counter name';
        con.LU_Counter_28_Name__c = 'counter name';
        con.LU_Counter_29_Name__c = 'counter name';
        con.LU_Counter_30_Name__c = 'counter name';
        con.LU_Counter_1_High_Limit__c = 10;
        con.LU_Counter_2_High_Limit__c = 10;
        con.LU_Counter_3_High_Limit__c = 10;
        con.LU_Counter_4_High_Limit__c = 10;
        con.LU_Counter_5_High_Limit__c = 10;
        con.LU_Counter_6_High_Limit__c = 10;
        con.LU_Counter_7_High_Limit__c = 10;
        con.LU_Counter_8_High_Limit__c = 10;
        con.LU_Counter_9_High_Limit__c = 10;
        con.LU_Counter_10_High_Limit__c = 10;
        con.LU_Counter_11_High_Limit__c = 10;
        con.LU_Counter_12_High_Limit__c = 10;
        con.LU_Counter_13_High_Limit__c = 10;
        con.LU_Counter_14_High_Limit__c = 10;
        con.LU_Counter_15_High_Limit__c = 10;
        con.LU_Counter_16_High_Limit__c = 10;
        con.LU_Counter_17_High_Limit__c = 10;
        con.LU_Counter_18_High_Limit__c = 10;
        con.LU_Counter_19_High_Limit__c = 10;
        con.LU_Counter_20_High_Limit__c = 10;
        con.LU_Counter_21_High_Limit__c = 10;
        con.LU_Counter_22_High_Limit__c = 10;
        con.LU_Counter_23_High_Limit__c = 10;
        con.LU_Counter_24_High_Limit__c = 10;
        con.LU_Counter_25_High_Limit__c = 10;
        con.LU_Counter_26_High_Limit__c = 10;
        con.LU_Counter_27_High_Limit__c = 10;
        con.LU_Counter_28_High_Limit__c = 10;
        con.LU_Counter_29_High_Limit__c = 10;
        con.LU_Counter_30_High_Limit__c = 10;
        con.LU_Counter_1_Lower_Limit__c = 1;
        con.LU_Counter_2_Lower_Limit__c = 1;
        con.LU_Counter_3_Lower_Limit__c = 1;
        con.LU_Counter_4_Lower_Limit__c = 1;
        con.LU_Counter_5_Lower_Limit__c = 1;
        con.LU_Counter_6_Lower_Limit__c = 1;
        con.LU_Counter_7_Lower_Limit__c = 1;
        con.LU_Counter_8_Lower_Limit__c = 1;
        con.LU_Counter_9_Lower_Limit__c = 1;
        con.LU_Counter_10_Lower_Limit__c = 1;
        con.LU_Counter_11_Lower_Limit__c = 1;
        con.LU_Counter_12_Lower_Limit__c = 1;
        con.LU_Counter_13_Lower_Limit__c = 1;
        con.LU_Counter_14_Lower_Limit__c = 1;
        con.LU_Counter_15_Lower_Limit__c = 1;
        con.LU_Counter_16_Lower_Limit__c = 1;
        con.LU_Counter_17_Lower_Limit__c = 1;
        con.LU_Counter_18_Lower_Limit__c = 1;
        con.LU_Counter_19_Lower_Limit__c = 1;
        con.LU_Counter_20_Lower_Limit__c = 1;
        con.LU_Counter_21_Lower_Limit__c = 1;
        con.LU_Counter_22_Lower_Limit__c = 1;
        con.LU_Counter_23_Lower_Limit__c = 1;
        con.LU_Counter_24_Lower_Limit__c = 1;
        con.LU_Counter_25_Lower_Limit__c = 1;
        con.LU_Counter_26_Lower_Limit__c = 1;
        con.LU_Counter_27_Lower_Limit__c = 1;
        con.LU_Counter_28_Lower_Limit__c = 1;
        con.LU_Counter_29_Lower_Limit__c = 1;
        con.LU_Counter_30_Lower_Limit__c = 1;
        con.CommissionRateRange__c = 'com';
        update con;
        
        AP1000_Utils_Test.generateOffers();
        
        PriceBook2 pb = [SELECT Id FROM PriceBook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1'];
        
        Product2 prod = new Product2(
            Name = 'prod',
            Lu_Country__c = 'ITA',
            isActive = true
        );
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1.00,
            isActive = true, LU_Counter_Value__c = '-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2'
        );
        insert pbe;
        
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft',
            BillToContactId = u.ContactId,
            PriceBook2Id = pbe.PriceBook2Id
        );
        insert ord;
        
        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            PriceBookEntryId = pbe.Id,
            Product2Id = pbe.Product2Id,
            UnitPrice = 1.00,
            Quantity = 4,
            LU_Contact_For__c = con.Id
        );
        insert oi;

        OrderItem oi2 = new OrderItem(
            OrderId = ord.Id,
            PriceBookEntryId = pbe.Id,
            Product2Id = pbe.Product2Id,
            UnitPrice = 1.00,
            Quantity = 3,
            LU_Contact_For__c = con.Id
        );
        insert oi2;
        
        System.runAs(u){
            lwc70_order_detail_basket_view_Ctrl.controlBundle(ord.Id);
            lwc70_order_detail_basket_view_Ctrl.getOrderStatusFromOrderItem(oi2.Id);
            lwc70_order_detail_basket_view_Ctrl.Baskets b2 = lwc70_order_detail_basket_view_Ctrl.getOrderById(ord.Id, LABEL.LU_0rder_Detail_By_Customer);
            String retourn = lwc70_order_detail_basket_view_Ctrl.putOrderOnNewCase(ord.Id);
        }
    }
}