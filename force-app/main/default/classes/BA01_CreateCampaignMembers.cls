global class BA01_CreateCampaignMembers implements Database.Batchable<sObject>, Database.Stateful{

    global Map<String, Id> mCampaigns = new Map<String, Id>();
    global Integer nbCampaignMembersCreated = 0;
    public Database.QueryLocator start(Database.BatchableContext BC){

        // récupérer toutes les campagnes 'Cycle Push' et créer Map
        List<campaign> lCampaignsCyclePush = [Select Name, Id From campaign where type='Cycle Push'];
        List<String> lCampaignName = new List<String>();
        for(campaign camp : lCampaignsCyclePush){
            mCampaigns.put(camp.name, camp.Id);
            lCampaignName.add(camp.Name);
        }

        return Database.getQueryLocator([
            SELECT Id, DealerSenioritySegment__c
            FROM contact 
            WHERE TECH_ExternalId__c like '%ITA%'
            AND DealerSenioritySegment__c in :lCampaignName
            ]);        
    }

    public void execute(Database.BatchableContext BC, List<Contact> lContacts){
        List<CampaignMember> lCampaignMembersToCreate = new List<CampaignMember>();
        // pour chaque élément de la Map créer campaignMember avec les Ids contactId et campaignId
        for(Contact c : lContacts){
            // System.debug('contact c ' + c);
            if(mCampaigns.containsKey(c.DealerSenioritySegment__c)){
                // System.debug('contact c - mCampaigns.get(c.DealerSenioritySegment__c) ' + c.Id + ' ' + c + ' ' + mCampaigns.get(c.DealerSenioritySegment__c));
                CampaignMember cm = new CampaignMember();
                cm.contactId = c.Id;
                cm.campaignId = mCampaigns.get(c.DealerSenioritySegment__c);
                lCampaignMembersToCreate.add(cm);

            }
        }
        System.debug('lCampaignMembersToCreate ' + lCampaignMembersToCreate.size() + ' ' + lCampaignMembersToCreate);  
        try{
            insert lCampaignMembersToCreate;
            nbCampaignMembersCreated += lCampaignMembersToCreate.size();
        }      
        catch(Exception error){
            System.debug('BA01_CreateCampaignMembers campaignMembers insert error ' + error);        
        }
        System.debug('create lCampaignMembersToCreate OK nbCampaignMembersCreated ' + nbCampaignMembersCreated);        
    }

    public void finish(Database.BatchableContext BC){
        System.debug('BA01_CreateCampaignMembers is finished, nbCampaignMembersCreated ' + nbCampaignMembersCreated);   
    }
}