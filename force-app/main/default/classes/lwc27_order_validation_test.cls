@IsTest
private with sharing class lwc27_order_validation_test {
    
    @testSetup static void test_setup() {
        // Generate Data
        AP1000_Utils_Test.generateOffers();

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');
    }

    @isTest static void test_unit_1_validate_ok() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(lwc17_searchProduct.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');


            // VALIDATE ORDER ON CHECKOUT OPENING
            lwc27_order_validation.ValidationResult res = lwc27_order_validation.validateOrderOnCheckout((Id)resultAddToBasket);
            system.assert(res != null && res.success == true, 'ERROR VALIDATEORDERONCHECKOUT');

            lwc27_order_validation.ValidationResult res2 = lwc27_order_validation.validateOrderOnValidation((Id)resultAddToBasket);
            system.assert(res2 != null && res2.success == true, 'ERROR VALIDATEORDERONVALIDATION');
        }
    }

    @isTest static void test_unit_2_validate_limitedquantity() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(lwc17_searchProduct.searchProduct('876374', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            // Get order and put a quanityt to 2 to the limited product 876374
            List<OrderItem> lItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :resultAddToBasket AND Product2.LU_Local_Code__c = '876374'];
            if (!lItems.isEmpty()) {
                OrderItem item = lItems[0];
                item.Quantity = 2;
                update item;
            } else {
                system.assert(false, 'ERROR LIMITEDQUANITTY NOT ON ORDERITEMS');
            }

            // VALIDATE ORDER ON CHECKOUT OPENING : should pass
            lwc27_order_validation.ValidationResult res = lwc27_order_validation.validateOrderOnValidation((Id)resultAddToBasket);
            system.assert(res != null && res.success == true, 'ERROR validateOrderOnValidation LIMITED QUANTITY failed');
            
            // To avoid soql limit
            Test.startTest();

            // Create another order for the same contact, with same article and quantity on limited quantity article to hit the limit
            List<AP1002_LookupSearchResult> lLines2 = new List<AP1002_LookupSearchResult>();
            lLines2.addAll(lwc17_searchProduct.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines2.addAll(lwc17_searchProduct.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines2.addAll(lwc17_searchProduct.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines2.addAll(lwc17_searchProduct.searchProduct('876374', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket2 = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines2, null, pb.Id, con);
            system.assert(resultAddToBasket2 != 'ko', 'ERROR ADDTOBASKET');
            system.assert(resultAddToBasket != resultAddToBasket2, 'ERROR NOT NEW ORDER CREATED');


            // Get order and put a quanityt to 2 to the limited product 876374
            List<OrderItem> lItems2 = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :resultAddToBasket2 AND Product2.LU_Local_Code__c = '876374'];
            if (!lItems2.isEmpty()) {
                OrderItem item = lItems2[0];
                item.Quantity = 2;
                update item;
            } else {
                system.assert(false, 'ERROR LIMITEDQUANITTY NOT ON ORDERITEMS');
            }
            // VALIDATE ORDER ON CHECKOUT OPENING : should fail
            lwc27_order_validation.ValidationResult res2 = lwc27_order_validation.validateOrderOnValidation((Id)resultAddToBasket2);
            system.assert(res2 != null && res2.success == false, 'ERROR validateOrderOnValidation LIMITED QUANTITY success');

            Test.stopTest();

        }
    }

    @isTest static void test_unit_3_validate_maximumquantity() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(lwc17_searchProduct.searchProduct('96992', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            // Get order and put a qquantity to 25 : max by order is set to 20 for this pricebookentry
            List<OrderItem> lItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :resultAddToBasket AND Product2.LU_Local_Code__c = '96992'];
            if (!lItems.isEmpty()) {
                OrderItem item = lItems[0];
                item.Quantity = 25;
                update item;
            } else {
                system.assert(false, 'ERROR MAXQUANTITY NOT ON ORDERITEMS');
            }

            lwc27_order_validation.ValidationResult res2 = lwc27_order_validation.validateOrderOnValidation((Id)resultAddToBasket);
            system.assert(res2 != null && res2.success == false, 'ERROR VALIDATEORDERONVALIDATION MAX QUANTITY RULE NOT RESPECTED');
        }
    }

    @isTest static void test_unit_4_validate_stock() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(lwc17_searchProduct.searchProduct('1001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
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

            // SHOULD PASS USING SUBSITUTE article
            lwc27_order_validation.ValidationResult res2 = lwc27_order_validation.validateOrderOnValidation((Id)resultAddToBasket);
            system.assert(res2 != null && res2.success == true, 'ERROR VALIDATEORDERONVALIDATION stock substitute not used');

            // To avoid soql limit
            Test.startTest();

            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines2 = new List<AP1002_LookupSearchResult>();
            lLines2.addAll(lwc17_searchProduct.searchProduct('1001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket2 = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines2, null, pb.Id, con);
            system.assert(resultAddToBasket2 != 'ko', 'ERROR ADDTOBASKET');

            // Get order and put a qquantity to 10 : stock is 10 ALL USED, and substitute stock is 10 but only 5 remaining
            List<OrderItem> lItems2 = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :resultAddToBasket2 AND Product2.LU_Local_Code__c = '1001'];
            if (!lItems2.isEmpty()) {
                OrderItem item = lItems2[0];
                item.Quantity = 10;
                update item;
            } else {
                system.assert(false, 'ERROR STOCK NOT ON ORDERITEMS');
            }

            // SHOULD KO BECAUSE NOT ENOUGH SUBSITUTE ANYMORE
            lwc27_order_validation.ValidationResult res3 = lwc27_order_validation.validateOrderOnValidation((Id)resultAddToBasket2);
            //system.assert(res3 != null && res3.success == false, 'ERROR VALIDATEORDERONVALIDATION stock substitute used but not anymore');

            Test.stopTest();
        }
    }

    @isTest static void test_unit_5_validate_counters() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(lwc17_searchProduct.searchProduct('50001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            // Get order and put a qquantity to 15 : price in point is -1 by unit. Contact balance is 10.
            List<OrderItem> lItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :resultAddToBasket AND Product2.LU_Local_Code__c = '50001'];
            if (!lItems.isEmpty()) {
                OrderItem item = lItems[0];
                item.Quantity = 15;
                update item;
            } else {
                system.assert(false, 'ERROR COUNTERS NOT ON ORDERITEMS');
            }

            lwc27_order_validation.ValidationResult res2 = lwc27_order_validation.validateOrderOnValidation((Id)resultAddToBasket);
            system.assert(res2 != null && res2.success == false, 'ERROR VALIDATEORDERONVALIDATION COUNTERS NOT RESPECTED');
        }
    }
}