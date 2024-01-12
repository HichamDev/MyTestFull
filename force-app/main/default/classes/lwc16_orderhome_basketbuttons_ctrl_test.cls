@IsTest
public class lwc16_orderhome_basketbuttons_ctrl_test {
    
    @IsTest
    private static void getUserInformation() {

        User u = AP01_TestDataFactory.createPortalUser();

        system.runAs(u){
            lwc16_orderhome_basketbuttons_ctrl.getUserInformation();
        }
    }
    
    @IsTest
    private static void getUSerProfile() {

        User u = AP01_TestDataFactory.createPortalUser();

        system.runAs(u){
            lwc16_orderhome_basketbuttons_ctrl.getUSerProfile();
        }
    }
    
    @IsTest
    private static void getAllConstants() {

        User u = AP01_TestDataFactory.createPortalUser();

        system.runAs(u){
            lwc16_orderhome_basketbuttons_ctrl.getAllConstants();
        }
    }
}