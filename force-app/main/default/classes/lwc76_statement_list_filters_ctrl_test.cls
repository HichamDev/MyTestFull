@IsTest
public class lwc76_statement_list_filters_ctrl_test {
	
    @IsTest
    public static void getUserCountryTest(){

        User u = AP01_TestDataFactory.createPortalUser();

        System.runAs(u){
            lwc76_statement_list_filters_ctrl.getUserCountry();
        }
    }
    
    @IsTest
    public static void getcurrentContactTest(){

        User u = AP01_TestDataFactory.createPortalUser();

        System.runAs(u){
            lwc76_statement_list_filters_ctrl.getCurrentContact();
        }
    }
}