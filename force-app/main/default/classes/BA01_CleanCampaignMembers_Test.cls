@isTest(SeeAllData=false)
public with sharing class BA01_CleanCampaignMembers_Test {
    public TestMethod static void BA01_CleanCampaignMembers_Test_Method()
    {
        Campaign campaign = new Campaign();
        campaign.Name = 'Campaign Name';
        campaign.Type = 'Cycle push';
        insert campaign;

        Contact contact = new Contact();
        contact.LastName = 'Contact LastName_';
        contact.TECH_ExternalId__c = 'ITA_for_Test';
        insert contact;

        CampaignMember cm = new CampaignMember();
        cm.CampaignId = campaign.id;
        cm.ContactId = contact.id;
        insert cm;

        Commercial_Periods__mdt cpmdt = new Commercial_Periods__mdt();
        cpmdt.Type__c = 'Cycle';
        cpmdt.Startdate__c = Date.today();
        cpmdt.Enddate__c = Date.today() + 10;
        

        AP49_ReadCustomMetadatas rcmd = new AP49_ReadCustomMetadatas('Cycle');
        BA01_CleanCampaignMembers ba01 = New BA01_CleanCampaignMembers();
        ba01.commPeriodBeginning = new Commercial_Periods__mdt();
        ba01.commPeriodBeginning.label = 'Test';
        ba01.commPeriodBeginning.Type__c = 'Cycle';
        ba01.commPeriodBeginning.Startdate__c = Date.today();
        ba01.commPeriodBeginning.Enddate__c = Date.today() + 10;            
        
        Test.startTest();
        Database.executeBatch(ba01);
        Test.stopTest();
    }
   
}