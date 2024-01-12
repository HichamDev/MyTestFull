@isTest
public with sharing class BA02_SendSMS_ToSinch_TEST {
    public TestMethod static void BA02_SendSMS_ToSinch_TEST_Method()
    {
        List<Contact> lContacts = New List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact contact = new Contact();
            contact.LastName = 'LastName_' + i;
            contact.birthdate = Date.today();
            contact.TECH_ExternalId__c = 'Test_ITA_' + i;
            contact.MobilePhone = '33360123456' + i;
            contact.LU_Available_for_Pardot__c = 1;
            contact.OptinNewsletter1__c = true;
            contact.HasOptedOutOfFax = false;
            contact.DealerSenioritySegment__c = 'Argento';
            contact.Tech_Pardot_Send_SMS__c = true;
            lContacts.add(contact);
        }
        insert lContacts;
        system.assertEquals(10, lContacts.size());

        // DealerSeniority__mdt ds = new DealerSeniority__mdt();
        // ds.SegmentName__c = 'Argento';
        // ds.Delay__c = 0;
        // ds.Mapping__c = '{FirstName} = {C}, {CurrentCommercialCycle__c} = {D},{Enddate__c}={E}';
        // ds.SinchTemplateId__c = '12345';
        // insert(ds);
        
        BA02_SendSMS_ToSinch ba02 = New BA02_SendSMS_ToSinch(new List<String>{'Argento'});
        
        Test.startTest();
        Database.executeBatch(ba02);
        Test.stopTest();
    }

}