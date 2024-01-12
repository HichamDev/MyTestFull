@IsTest
public class lwc41_Order_New_Ctrl_Test {

    @IsTest
    static void getOrderPageCurrentUserTest() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        u.LU_Use_New_Order_v2__c = true;
        insert u;

        System.RunAs(u){
            String s = lwc41_Order_New_Ctrl.getOrderPageCurrentUser();
            Boolean b = lwc41_Order_New_Ctrl.getIsContentieux();
        }
    }
}