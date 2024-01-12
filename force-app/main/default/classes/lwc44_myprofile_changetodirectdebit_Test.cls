@IsTest
public class lwc44_myprofile_changetodirectdebit_Test {
	
    @IsTest
    static void getUserCountryTest() {
        User u = AP01_TestDataFactory.createPortalUser();
        insert u;

        System.RunAs(u){
            Boolean b = lwc44_myprofile_changetodirectdebit_ctrl.getIsItalianDirettore();
        }
    }
}