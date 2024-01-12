@IsTest
public class lwc67_checkout_shipping_ctrl_test {
    
    @testSetup static void test_setup() {
        // Generate Data
        AP1000_Utils_Test.generateOffers();

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');
    }

    @isTest static void test_unit_1_order() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            // Get Order
            Order ord = lwc67_checkout_shipping_ctrl.getOrder(resultAddToBasket);
            system.assert(ord != null, 'ERROR GETORDER');

            // Get applicable fees
            List<LU_Order_Rule__c> lRules = lwc67_checkout_shipping_ctrl.getApplicableFees(resultAddToBasket);
        }
    }
    
    // @IsTest 
    // public static void testGetOrder() {
    //     User u = AP01_TestDataFactory.createPortalUser();
    //     insert u;
        
    //     Account a = [SELECT Id FROM Account WHERE TECH_ACCOwnerExternalId__c = '123456'];
        
    //     Order o = new Order(
    //         BillToContactId = u.ContactId,
    //         Status = 'Draft',
    //         AccountId = a.Id,
    //         EffectiveDate = System.Today()
    //     );
    //     insert o;

    //     System.RunAs(u){
    //         o = lwc67_checkout_shipping_ctrl.getOrder(o.Id);
    //         lwc67_checkout_shipping_ctrl.updateOrder(o);
    //         List<LU_Order_Rule__c> l_applicableFees = lwc67_checkout_shipping_ctrl.getApplicableFees(o.Id);
    //         Double weight = lwc67_checkout_shipping_ctrl.getOrderWeight(o.Id);
    //         List<LU_Order_Rule__c> l_shippingMode = lwc67_checkout_shipping_ctrl.getAvailableShippingMode('FRA', u.Profile.Name);
    //         List<LU_Order_Rule__c> l_shippingFees = lwc67_checkout_shipping_ctrl.getShippingFees('FRA', l_shippingMode);
    //         Boolean comp = lwc67_checkout_shipping_ctrl.compare(1, '<', 5);
    //         comp = lwc67_checkout_shipping_ctrl.compare(1, '<=', 5);
    //         comp = lwc67_checkout_shipping_ctrl.compare(1, '=', 5);
    //         comp = lwc67_checkout_shipping_ctrl.compare(1, '>=', 5);
    //         comp = lwc67_checkout_shipping_ctrl.compare(1, '>', 5);
    //     }
    // }
}