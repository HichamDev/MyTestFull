@isTest
public class lwc67_checkout_shipping_relaiscolis_TEST {
    
    @testSetup static void test_setup() {
        // Generate Data
        AP1000_Utils_Test.generateOffers();

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');
    }


    @isTest static void test_unit_1_info_point_relais() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Lu_Order_Rule__c shippingMode = [SELECT Id FROM LU_Order_Rule__c WHERE LU_External_Id__c = 'FRA_EXTERNAL' LIMIT 1];
        system.runAs(u) {
            Test.startTest();
            // Get point relais list
            List<lwc67_checkout_shipping_relaiscolis_Ctrl.wrapRelai> listRelais = lwc67_checkout_shipping_relaiscolis_Ctrl.getInfoRelai('44000', shippingMode.Id);
            system.assert(listRelais != null, 'ERROR RELAIS POINT');

            // Get point relais selected
            lwc67_checkout_shipping_relaiscolis_Ctrl.wrapperPointRelaiSelec pointSelected = lwc67_checkout_shipping_relaiscolis_Ctrl.createPointSelected('5 rue Geroges Labeyrie', 'nantes', '44200', 'Maison Test', 'FRA', 'Maison Test', 'Chez Test');
            System.assert(pointSelected.nom == 'Maison Test');

            Test.stopTest();
        }
    }

}