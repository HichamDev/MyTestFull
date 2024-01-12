@isTest(SeeAllData=false)
public with sharing class BA01_CreateCampaignMembers_Test {
    public TestMethod static void BA01_CreateCampaignMembers_Test_Method()
    {
        Campaign campaign = new Campaign();
        campaign.Name = 'OroTest';
        campaign.Type = 'Cycle push';
        insert campaign;

        Contact contact = new Contact();
        contact.LastName = 'Contact LastName_';
        contact.DealerSenioritySegment__c = 'OroTest';
        contact.TECH_ExternalId__c = 'Test_ITA_Contact';
        insert contact;

        AP49_ReadCustomMetadatas rcmd = new AP49_ReadCustomMetadatas('Cycle');
        BA01_CreateCampaignMembers ba01 = New BA01_CreateCampaignMembers();
        
        Test.startTest();
        Database.executeBatch(ba01);
        Test.stopTest();
    }
}