@isTest
public with sharing class AP1021_Batch_GDPR_5Years_Consent_TEST {

    @isTest static void test_unit_1_fra_batch() {

        Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName = 'LU_Personal_Contact' AND Sobjecttype = 'Contact' LIMIT 1].Id;
        Datetime dt = Datetime.now().addYears(-6);

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        // Create Customers for France
        List<Contact> lContactsFRA = new List<Contact>();
        for (integer i = 0 ; i < 20 ; i++) {
            Contact c = new Contact(RecordTypeId = rtId);
            c.LastName = 'CustomerFRA' + i;
            c.LU_Consent_Answer_Date__c = dt;
            c.HasOptedOutOfEmail = false;
            c.OwnerId = userId;
            lContactsFRA.add(c);
        }
        insert lContactsFRA;

        Test.startTest();

        AP1021_Batch_GDPR_5Years_Consent batch = new AP1021_Batch_GDPR_5Years_Consent('FRA');
        database.executebatch(batch);

        Test.stopTest();

        List<Contact> lContacts = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'LU_Personal_Contact' AND HasOptedOutOfEmail = true];
        system.assert(lContacts.size() == 20, 'ERROR GDPR 5YEARS');
    }

    @isTest static void test_unit_2_fra_scheduler() {

        String chron = '0 0 23 * * ?';    
        
        Test.startTest();
        
        AP1021_SC_GDPR_5Years_Consent_FRA obj = new AP1021_SC_GDPR_5Years_Consent_FRA();     
        String jobid = System.schedule('AP1021_Batch_GDPR_5Years_Consent_FRA', chron, obj);

        Test.stopTest();

        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);
    }


    @isTest static void test_unit_3_ita_batch() {

        Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName = 'LU_Personal_Contact' AND Sobjecttype = 'Contact' LIMIT 1].Id;
        Datetime dt = Datetime.now().addYears(-6);

        // ITALY
        // Generate Contact / User
        Id userIdITA = AP01_TestDataFactory.createCommunityManagerWithTeam('ITA', 'Dirretore de filiale', 'Leader', 'ITA_LU_MANAGER', '');
        // Create Customers for France
        List<Contact> lContactsITAA = new List<Contact>();
        for (integer i = 0 ; i < 20 ; i++) {
            Contact c = new Contact(RecordTypeId = rtId);
            c.LastName = 'CustomerITA' + i;
            c.LU_Consent_Answer_Date__c = dt;
            c.HasOptedOutOfEmail = false;
            c.OwnerId = userIdITA;
            lContactsITAA.add(c);
        }
        insert lContactsITAA;

        Test.startTest();

        AP1021_Batch_GDPR_5Years_Consent batch = new AP1021_Batch_GDPR_5Years_Consent('ITA');
        database.executebatch(batch);

        Test.stopTest();

        List<Contact> lContacts = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'LU_Personal_Contact' AND HasOptedOutOfEmail = true];
        system.assert(lContacts.size() == 20, 'ERROR GDPR 5YEARS');
    }

    @isTest static void test_unit_4_ita_scheduler() {

        String chron = '0 0 23 * * ?';    
        
        Test.startTest();
        
        AP1021_SC_GDPR_5Years_Consent_ITA obj = new AP1021_SC_GDPR_5Years_Consent_ITA();     
        String jobid = System.schedule('AP1021_Batch_GDPR_5Years_Consent_ITA', chron, obj);

        Test.stopTest();

        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);
    }
}