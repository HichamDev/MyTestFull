@IsTest
public class LWC14_Contact_Switch_Ctrl_Test {
    
    @IsTest
    static void getCurrentContactTest() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;

        System.RunAs(u){
            Contact c = LWC14_Contact_Switch_Ctrl.getCurrentContact();
        }
    }

}