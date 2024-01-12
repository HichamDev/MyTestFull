@isTest
public class BA06_Scheduler_Test {
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    @isTest
    static void testScheduledJob() {
        insert new Recap_Email__c(AddressEmail__c = 'Test@email.com');
        
         BA06_Scheduler schedule = new BA06_Scheduler();
        String sch = '0 0 12 * * ?';
        
        Test.startTest();
        //Schedule the batch process using the scheduler sch
        System.schedule('Testing BA06_', sch, schedule);
        
        Test.stopTest();

    }
}