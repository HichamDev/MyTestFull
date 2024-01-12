@IsTest
private class AP1011_Stock_Utils_TEST {
    
    @testSetup static void test_setup() {
        // Generate Data
        AP1000_Utils_Test.generateOffers();

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');
    }

    @isTest static void test_unit_1_stock_of_order_ok() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('1001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            // Get order and put a qquantity to 15 : stock is 10, and substitute stock is 10
            List<OrderItem> lItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :resultAddToBasket AND Product2.LU_Local_Code__c = '1001'];
            if (!lItems.isEmpty()) {
                OrderItem item = lItems[0];
                item.Quantity = 15;
                update item;
            } else {
                system.assert(false, 'ERROR STOCK NOT ON ORDERITEMS');
            }

            // CHeck the stock of for the order
            AP1011_Stock_Utils.OrderStockStatus st = AP1011_Stock_Utils.checkStockForOrder((Id)resultAddToBasket);
            system.assert(st != null, 'ERROR STOCK CHECKSTATUSFORORDER');

            // Update the stock for Order
            AP1011_Stock_Utils.updateOrderWithStockInformation((Id)resultAddToBasket, st);

            // Decrease the stock
            AP1011_Stock_Utils.decreaseTheStockForOrder((Id)resultAddToBasket, st);
        }
    }

    @isTest static void test_unit_1_stock_of_order_ko() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('1001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            // Get order and put a qquantity to 15 : stock is 10, and substitute stock is 10
            List<OrderItem> lItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :resultAddToBasket AND Product2.LU_Local_Code__c = '1001'];
            if (!lItems.isEmpty()) {
                OrderItem item = lItems[0];
                item.Quantity = 15;
                update item;
            } else {
                system.assert(false, 'ERROR STOCK NOT ON ORDERITEMS');
            }

            // CHeck the stock of for the order
            AP1011_Stock_Utils.OrderStockStatus st = AP1011_Stock_Utils.checkStockForOrder((Id)resultAddToBasket);
            system.assert(st != null, 'ERROR STOCK CHECKSTATUSFORORDER');

            // Update the stock for Order
            AP1011_Stock_Utils.updateOrderWithStockInformation((Id)resultAddToBasket, st);

            // Decrease the stock
            AP1011_Stock_Utils.decreaseTheStockForOrder((Id)resultAddToBasket, st);

            // TO avoid soql limit
            Test.startTest();

            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines2 = new List<AP1002_LookupSearchResult>();
            lLines2.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('1001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket2 = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines2, null, pb.Id, con);
            system.assert(resultAddToBasket2 != 'ko', 'ERROR ADDTOBASKET');

            // Get order and put a qquantity to 15 : stock is 10, and substitute stock is 10
            List<OrderItem> lItems2 = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :resultAddToBasket2 AND Product2.LU_Local_Code__c = '1001'];
            if (!lItems2.isEmpty()) {
                OrderItem item = lItems2[0];
                item.Quantity = 15;
                update item;
            } else {
                system.assert(false, 'ERROR STOCK NOT ON ORDERITEMS');
            }

            // CHeck the stock of for the order
            AP1011_Stock_Utils.OrderStockStatus st2 = AP1011_Stock_Utils.checkStockForOrder((Id)resultAddToBasket2);
            system.assert(st2 != null, 'ERROR STOCK CHECKSTATUSFORORDER');

            // Update the stock for Order
            AP1011_Stock_Utils.updateOrderWithStockInformation((Id)resultAddToBasket2, st2);

            Test.stopTest();
        }
    }
}