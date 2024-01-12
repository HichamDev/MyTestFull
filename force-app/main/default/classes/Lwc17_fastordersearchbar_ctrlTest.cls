@IsTest
private class Lwc17_fastordersearchbar_ctrlTest{

    @testSetup static void test_setup() {
        // Generate Data
        AP1000_Utils_Test.generateOffers();

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');
    }
        

    @isTest static void test_unit_1_search() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        system.runAs(u) {
            // Search simple product : STANDARD
            List<AP1002_LookupSearchResult> lRes = Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            system.assert(lRes.size() == 3, 'ERROR SEARCH 9699');
            // Search offers with counters : STANDARD
            List<AP1002_LookupSearchResult> lRes1 = Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            system.assert(lRes1.size() == 1, 'ERROR SEARCH 9700');
            List<AP1002_LookupSearchResult> lRes2 = Lwc17_fastordersearchbar_ctrl.searchProduct('50001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            system.assert(lRes2.size() == 1, 'ERROR SEARCH 50001');
            // Search offers PUP
            List<AP1002_LookupSearchResult> lRes3 = Lwc17_fastordersearchbar_ctrl.searchProduct('40001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_PUP, null);
            system.assert(lRes3.size() == 1, 'ERROR SEARCH 40001');
            // Search Bundle close / open
            List<AP1002_LookupSearchResult> lRes4 = Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            system.assert(lRes4.size() == 2, 'ERROR SEARCH 3000');
            // Stock
            List<AP1002_LookupSearchResult> lRes5 = Lwc17_fastordersearchbar_ctrl.searchProduct('100', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            system.assert(lRes5.size() == 4, 'ERROR SEARCH 100');
        }
    }

    @isTest static void test_unit_2_bundle() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        system.runAs(u) {

            // Closed
            List<AP1002_LookupSearchResult> lBundleClose = Lwc17_fastordersearchbar_ctrl.searchProduct('30001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            String bundleRes = Lwc17_fastordersearchbar_ctrl.getPorductListOfBundle(lBundleClose[0].productId, lBundleClose[0].id, lBundleClose[0].priceBook);
            system.assert(bundleRes != 'ko', 'ERROR GET BUNDLE 30001');
            // Open
            List<AP1002_LookupSearchResult> lBundleOpen = Lwc17_fastordersearchbar_ctrl.searchProduct('30002', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            String bundleRes2 = Lwc17_fastordersearchbar_ctrl.getPorductListOfBundle(lBundleOpen[0].productId, lBundleOpen[0].id, lBundleOpen[0].priceBook);
            system.assert(bundleRes2 != 'ko', 'ERROR GET BUNDLE 30002');
        }
    }

    @isTest static void test_unit_3_order() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // Get Order : no order
            Id orderId = Lwc17_fastordersearchbar_ctrl.getOrder(pb.Id, null);
            system.assert(orderId != null, 'ERROR GETORDER CREATION');
            // GEt ORder : existing
            Id orderId2 = Lwc17_fastordersearchbar_ctrl.getOrder(pb.Id, con.Id);
            system.assert(orderId == orderId2, 'ERROR GETORDER RETRIEVE SAME ORDER');
        }
    }

    @isTest static void test_unit_4_order() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // Get Order : existing
            Id orderId3 = Lwc17_fastordersearchbar_ctrl.getOrderIdWithoutPricebook(con.Id);
            system.assert(orderId3 != null, 'ERROR GETORDER RETRIEVE SAME ORDER');
            Id orderId4 = Lwc17_fastordersearchbar_ctrl.getOrderIdWithoutPricebook(null);
            system.assert(orderId3 == orderId4, 'ERROR GETORDER RETRIEVE SAME ORDER');
        }
    }

    @isTest static void test_unit_5_country() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // Get Order : no order
            String country = Lwc17_fastordersearchbar_ctrl.getUserCountry();
            system.assert(country == 'FRA', 'ERROR COUNTRY');
        }
    }

    @isTest static void test_unit_6_addToBasket() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // Get Offers to put in basket
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            // Add to basket with null order
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            String resultAddToBasketSameLines = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasketSameLines != 'ko', 'ERROR ADDTOBASKET');
        }
    }
    

    @isTest static void test_getPriceBookEntry() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        PricebookEntry pbe = [SELECT Id, LU_TECH_External_Id__c FROM PricebookEntry LIMIT 1];
        pbe.LU_TECH_External_Id__c = 'FRA_test';
        update pbe;

        system.runAs(u) {
            Lwc17_fastordersearchbar_ctrl.getPriceBookEntry(pbe.LU_TECH_External_Id__c, con);
        }
    }

}