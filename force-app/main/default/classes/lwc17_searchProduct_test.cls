@IsTest
private  class lwc17_searchProduct_test {
    
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
        
        PriceBookEntry pbe = [SELECT Id, Product2Id, PriceBook2Id FROM PriceBookEntry WHERE Product2.LU_Local_Code__c = '30002' LIMIT 1];
        
        system.runAs(u) {
            // Search simple product : STANDARD
            List<AP1002_LookupSearchResult> lRes = lwc17_searchProduct.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            system.assert(lRes.size() == 3, 'ERROR SEARCH 9699');
            // Search offers with counters : STANDARD
            List<AP1002_LookupSearchResult> lRes1 = lwc17_searchProduct.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            system.assert(lRes1.size() == 1, 'ERROR SEARCH 9700');
            List<AP1002_LookupSearchResult> lRes2 = lwc17_searchProduct.searchProduct('50001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            system.assert(lRes2.size() == 1, 'ERROR SEARCH 50001');
            // Search offers PUP
            List<AP1002_LookupSearchResult> lRes3 = lwc17_searchProduct.searchProduct('40001', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_PUP, null);
            system.assert(lRes3.size() == 1, 'ERROR SEARCH 40001');
            // Search Bundle close / open
            List<AP1002_LookupSearchResult> lRes4 = lwc17_searchProduct.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            system.assert(lRes4.size() == 2, 'ERROR SEARCH 3000');
            // Stock
            List<AP1002_LookupSearchResult> lRes5 = lwc17_searchProduct.searchProduct('100', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null);
            system.assert(lRes5.size() == 4, 'ERROR SEARCH 100');
            
            String test = lwc17_searchProduct.getPorductListOfBundle(pbe.Product2Id, pbe.Id, pbe.PriceBook2Id);
        }
    }
}