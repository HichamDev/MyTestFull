@IsTest
public class AP1006_Reminder_Test {

    @IsTest
    static void testAP1006_Reminder() {

        AP1006_Reminder rem = new AP1006_Reminder();

        rem = new AP1006_Reminder('title', 'message');

        rem = new AP1006_Reminder('title', 'message message message message message message message message message message message message message message message message');

        rem = new AP1006_Reminder('url', 'title', 'message');

        rem = new AP1006_Reminder('url', 'title', 'message message message message message message message message message message message message message message message message');
    }
}