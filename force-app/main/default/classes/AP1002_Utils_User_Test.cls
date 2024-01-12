@IsTest
public class AP1002_Utils_User_Test {

    @IsTest
    static void testGetFiltersInactiveITA() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;

        System.RunAs(u){
            String country = AP1002_Utils_User.getUserCountry(u.Id);
            country = AP1002_Utils_User.getUserCountry(u);
            
            Contact c = AP1002_Utils_User.getContactFromUser(u.Id);
            c = AP1002_Utils_User.getConnectedUserContact();

            AP1002_Utils_User.getUserProfileName();
        }
    }
}