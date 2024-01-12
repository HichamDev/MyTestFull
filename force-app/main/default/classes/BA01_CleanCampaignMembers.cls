global class BA01_CleanCampaignMembers implements Database.Batchable<sObject>{
    
    AP49_ReadCustomMetadatas rcmdt = new AP49_ReadCustomMetadatas('Cycle');
    public Commercial_Periods__mdt commPeriodBeginning = AP49_ReadCustomMetadatas.isPeriodBeginning(AP49_ReadCustomMetadatas.getDelay('ManageCampaignMembers'));
    global List<sObject> campaignMemberstoDelete = new List<sObject>();
    global Integer nbCampaignMembersDeleted = 0;

    public Database.QueryLocator start(Database.BatchableContext BC){
        if(commPeriodBeginning != null){
            System.debug('BA01_CleanCampaignMembers start with this beginning period : ' + commPeriodBeginning);
            List<Id> lccpIds = BA01_CleanCampaignMembers_Helper.getCampaignCyclePushIds();
            
            //filter to get only contacts from ITA, as we don't want to delete campaignMembers with contacts from other countries
            // List<id> listContactsFromITA = new List<id>();
            // for(Contact c : [select id, TECH_ExternalId__c from contact where TECH_ExternalId__c like '%ITA%']){
            //     listContactsFromITA.add(c.id);
            // }
            // System.debug('listContactsFromITA ' + listContactsFromITA.size() + ' ' + listContactsFromITA);
            
            String query = 'SELECT Id, Name FROM CampaignMember WHERE CampaignId IN :lccpIds AND contact.TECH_ExternalId__c like \'%ITA%\'';
            if(Test.isRunningTest()){
                query += ' LIMIT 10';
            }
            return Database.getQueryLocator(query);
        }
        else{
            System.debug('BA01_CleanCampaignMembers start with no beginning period');
            return Database.getQueryLocator([
            Select Id, Name 
            From CampaignMember 
            where CampaignId = '' AND CampaignId != ''  //we are sure that there will be no CampaignMember in scope as there is no beginning period
            ]);
        }
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> campaignMemberstoDelete){
        try{
            System.debug('BA01_CleanCampaignMembers number of campaign members to delete ' + campaignMemberstoDelete.size());
            nbCampaignMembersDeleted += campaignMemberstoDelete.size();
            delete campaignMemberstoDelete;
        }
        catch(Exception error){
            System.debug('An error occured in batch BA01_CleanCampaignMembers ' + error);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('BA01_CleanCampaignMembers is finished, nbCampaignMembersDeleted ' + nbCampaignMembersDeleted);  
        //appeler 2eme batch pour la création des campaignmembers 
        if(!Test.isRunningTest()){
            System.debug('BA01_CleanCampaignMembers finish ');
            if(commPeriodBeginning != null){
                Id batchJobId = Database.executeBatch(new BA01_CreateCampaignMembers(), 200);
            }
        }
    }
}