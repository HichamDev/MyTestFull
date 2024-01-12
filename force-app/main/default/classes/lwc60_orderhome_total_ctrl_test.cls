@IsTest
public class lwc60_orderhome_total_ctrl_test {
    
    @isTest 
    static void test_unit_1_search() {
        User u = AP01_TestDataFactory.createPortalUser();

        system.runAs(u) {
            lwc60_orderhome_total_ctrl.getUserCountry();
            lwc60_orderhome_total_ctrl.getCurrentContact();
            lwc60_orderhome_total_ctrl.getProducts(new List<String>());
        }
    }
}