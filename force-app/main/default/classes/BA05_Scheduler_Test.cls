@isTest
public class BA05_Scheduler_Test {
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    @isTest
    static void testScheduledJob() {
        Integer numberOfContact = 25;
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numberOfContact; i++ ){
            
            contacts.add(createContact('0'+i));
        }
        insert contacts;
        
        List<Contact> updatedContact = [select Id, TECH_ExternalId__c From Contact where TECH_ExternalId__c like '%ITA%'];
        
        Set<Id> ContactIds = new Set<Id>();
        
        System.assertEquals(numberOfContact, updatedContact.size());
        
        for(Contact c : contacts){
            ContactIds.add(c.Id);
        }
        
        BA05_Scheduler BA05_sched = new BA05_Scheduler();
        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        Test.startTest();
        //Schedule the batch process using the scheduler sch
        System.schedule('Testing BA05_SendSMS_Anniversary', sch, BA05_sched);
        
        Test.stopTest();

    }
    
    public static Contact createContact(String sthId){
        Contact c = new Contact( 
            firstname= 'BRT' + sthId,
            lastname='XXXX' + sthId,
            TECH_ExternalId__c = 'ITA_pour_test' + sthId
        );
        
        return c;
    }
}