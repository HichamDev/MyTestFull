public with sharing class BA01_CleanCampaignMembers_Helper {
    public BA01_CleanCampaignMembers_Helper() {
        
    }
    
    public static List<Id> getCampaignCyclePushIds(){
        List<id> lccpid = new List<id>();
        for(campaign c : [SELECT Id FROM Campaign where type='Cycle Push']){
            lccpid.add(c.id);
        }
        return lccpid;
    }
}