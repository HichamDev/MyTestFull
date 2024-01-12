@IsTest
public class lwc18_Contact_Details_Ctrl_Test {

    @IsTest
    static void getContactInfosTest() {

        Contact c = new Contact(
            LastName = 'ln'
        );
        insert c;

        c = lwc18_Contact_Details_Ctrl.getContactInfos(c.Id);
    }

    @IsTest
    static void getContactIndicatorTest() {

        User u = AP01_TestDataFactory.createPortalUser();

        System.RunAs(u){
            List<lwc05_home_dashboard_Ctrl.Indicator> l_indic = lwc18_Contact_Details_Ctrl.getContactIndicator(u.ContactId);
        }
    }
}