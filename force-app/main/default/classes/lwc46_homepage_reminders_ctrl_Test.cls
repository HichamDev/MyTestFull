@IsTest
public class lwc46_homepage_reminders_ctrl_Test {

    @IsTest
    static void getReminders() {

        Id userId = AP01_TestDataFactory.createPortalUserWithClients();

        User u = [SELECT Id FROM User WHERE Id = :userId];

        System.RunAs(u){
            List<AP1006_Reminder> l_reminders = lwc46_homepage_reminders_ctrl.getReminders();
        }
    }
    @IsTest
    static void getNextEventTest() {

        Id userId = AP01_TestDataFactory.createPortalUserWithClients();

        User u = [SELECT Id FROM User WHERE Id = :userId];

        System.RunAs(u){
            List<AP1006_Reminder> l_reminders = lwc46_homepage_reminders_ctrl.getNextEvent();
        }
    }
    @IsTest
    static void getImpayeTest() {

        Id userId = AP01_TestDataFactory.createPortalUserWithClients();

        User u = [SELECT Id FROM User WHERE Id = :userId];

        System.RunAs(u){
            List<AP1006_Reminder> l_reminders = lwc46_homepage_reminders_ctrl.getImpaye();
        }
    }

    @IsTest
    static void getInactivTeamMembersTest() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.LU_Use_New_Order_v2__c = true;
        insert u;

        System.RunAs(u){
            List<AP1006_Reminder> l_reminders = lwc46_homepage_reminders_ctrl.getInactivTeamMembers(u);
            l_reminders = lwc46_homepage_reminders_ctrl.getBadDept();
            l_reminders = lwc46_homepage_reminders_ctrl.getCommunication();
        }
    }
}