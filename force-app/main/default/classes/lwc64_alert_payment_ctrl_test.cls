@IsTest
public class lwc64_alert_payment_ctrl_test {
	
    @IsTest 
    public static void getContactTest() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_1234';
        insert u;

        System.RunAs(u){
            Contact c = lwc64_alert_payment_ctrl.getContact();
            String userCountry = lwc64_alert_payment_ctrl.getUserCountry();
        }
    }
}