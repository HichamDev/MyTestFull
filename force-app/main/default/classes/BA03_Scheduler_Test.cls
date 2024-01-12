@isTest
private class BA03_Scheduler_Test {
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void testScheduledJob() {
        Test.startTest();
        
        Integer numberOfContact = 25;
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numberOfContact; i++ ){
            
            contacts.add(createContact('0'+i));
        }
        insert contacts;
        
        List<Contact> updatedContact = [select Id, TECH_ExternalId__c From Contact where TECH_ExternalId__c like '%ITA%'];
        
        Set<Id> ContactIds = new Set<Id>();
        
        system.AssertEquals(numberOfContact, updatedContact.size());
        
        for(Contact c : contacts){
            ContactIds.add(c.Id);
        }
        
        BA03_Scheduler BA03_sched = new BA03_Scheduler ();
        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing BA03_SendSMS_Birthday', sch, BA03_sched);
        /*
        BA03_SendSMS_Birthday BA03_batch = new BA03_SendSMS_Birthday();
        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(BA03_batch, 149);
        
        Test.StopTest(); 
        
        AsyncApexJob apexJob = [Select  Status, NumberOfErrors, ExtendedStatus 
        from AsyncApexJob
        where Id =:batchprocessid];                                   
        
        system.debug('>>> Error during batch processing: ' + apexJob.ExtendedStatus);
        
        system.AssertEquals('Completed', apexJob.status);
        
        system.AssertEquals(0, apexJob.NumberOfErrors);
        
        List<Contact> updatedcontactsBatch = [select Id,name, TECH_ExternalId__c From Contact where Id in :ContactIds];
        
        
        System.debug('updatedcontactsBatch '+updatedcontactsBatch);
        
        
        
        for(Contact Contact : updatedcontactsBatch){
            
            system.debug('Contact.TECH_ExternalId__c '+Contact.name+' ' + Contact.TECH_ExternalId__c);
            
            //System.assert(!Contact.TECH_ExternalId__c);
            
        }*/
    }
    
    static public Contact createContact(String sthId){
        Contact c = new Contact( 
        firstname= 'BRT' + sthId,
        lastname='XXXX' + sthId,
        TECH_ExternalId__c = 'ITA_pour_test' + sthId
        );
        
        return c;
    }
}