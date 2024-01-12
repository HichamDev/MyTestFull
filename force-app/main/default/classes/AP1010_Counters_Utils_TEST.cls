@isTest
private class AP1010_Counters_Utils_TEST {

    @testSetup static void test_setup() {
        // Generate Data
        AP1000_Utils_Test.generateOffers();
        List<RecordType> lRT = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'LU_Order_Rule__c' AND DeveloperName = 'Order_Counter_Start_At'];
        LU_Order_Rule__c oRule = new LU_Order_Rule__c(LU_Country__c = 'FRA', LU_NAME__c = '1', RecordtypeId = lRT[0].Id);
        Database.insert(oRule);

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');
    }

    @isTest static void test_unit_1_order_counters_ok() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('50001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            // Get order and put a quantity to 15 : price in point is -1 by unit. Contact balance is 10.
            List<OrderItem> lItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :resultAddToBasket AND Product2.LU_Local_Code__c = '50001'];
            if (!lItems.isEmpty()) {
                OrderItem item = lItems[0];
                item.Quantity = 6;
                update item;
            } else {
                system.assert(false, 'ERROR COUNTERS NOT ON ORDERITEMS');
            }

            AP1010_Counters_Utils.ValidationReturn res = AP1010_Counters_Utils.validateUpdateCounters((Id)resultAddToBasket);
            system.assert(res != null && res.msg == 'OK', 'ERROR COUNTERS COUNTERS NOT RESPECTED');
        }
    }

    @isTest static void test_unit_2_order_counters_bo_changes() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        
        // Set the counter 1 balance to 10
        con = new Contact(Id = con.Id, LU_Counter_1__c = 10);
        update con;

        // Set the bo changes of counter 1 to 2
        con = new Contact(Id = con.Id, LU_Counter_1_BO_Changes__c = 2);
        update con;
        
        // Check that the balance of the counters are 10 + 2 = 12
        con = [SELECT Id, LU_Counter_1__c, LU_Counter_1_BO_Changes__c FROM Contact WHERE Id = :con.Id];
        system.debug('>>>> contact');
        system.debug(con);
        system.assert(con.LU_Counter_1__c == 12, 'ERROR BALANCE NOT UPDATE AFTER BO CHANGES');
        system.assert(con.LU_Counter_1_BO_Changes__c == 0, 'ERROR BO CHANGE NOT UPDATED BACK TO 0');

    }

    @isTest static void test_unit_3_order_counters_putback() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        String resultAddToBasket = '';
        system.runAs(u) {
            // GENERATE AN ORDER AND VALIDATE IT
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('50001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            // Get order and put a quantity to 15 : price in point is -1 by unit. Contact balance is 10.
            List<OrderItem> lItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :resultAddToBasket AND Product2.LU_Local_Code__c = '50001'];
            if (!lItems.isEmpty()) {
                OrderItem item = lItems[0];
                item.Quantity = 6;
                update item;
            } else {
                system.assert(false, 'ERROR COUNTERS NOT ON ORDERITEMS');
            }

            LWC27_Checkout_Validate_Ctrl.ValidationResult res2 = LWC27_Checkout_Validate_Ctrl.validateOrderOnValidation((Id)resultAddToBasket, true);
            system.assert(res2 != null && res2.success == true, 'ERROR VALIDATEORDERONVALIDATION COUNTERS NOT RESPECTED');
        }

        // PUT BACK THE COUNTERS AFTER ORDER DE-VALIDATION
        AP1010_Counters_Utils.updateCountersBackToDraft(resultAddToBasket);

    }

    @isTest static void test_unit_4_order_counters_basket_and_order() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            // GEt the pricebookentry id
            List<String> lIds = new List<String>();
            for (AP1002_LookupSearchResult line : lLines) {
                lIds.add(line.id);
            }
            Map<Integer, AP1010_Counters_Utils.Counter> mCounters = AP1010_Counters_Utils.getCounters(resultAddToBasket, lLines, lIds);

            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('50001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lIds = new List<String>();
            for (AP1002_LookupSearchResult line : lLines) {
                lIds.add(line.id);
            }
            mCounters = AP1010_Counters_Utils.getCounters(resultAddToBasket, lLines, lIds);
        }
    }

}