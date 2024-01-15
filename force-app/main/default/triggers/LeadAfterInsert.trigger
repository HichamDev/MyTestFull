trigger LeadAfterInsert on Lead (after insert) {

    system.debug('## START Trigger LeadAfterInsert <<<<<' + UserInfo.getUserName());
    
    if(PAD.cantrigger('Bypass_AP053')){
        List<Id> l_idLeadForQuickContract = new List<Id>();
        
        for(Lead l : Trigger.new){
            if(l.SubscribeMode__c == 'Online'){
                l_idLeadForQuickContract.add(l.Id);
            }
        }
        
        if(!l_idLeadForQuickContract.isEmpty()){
            AP54_LeadHandler.handleQuickContract(l_idLeadForQuickContract);
        }
    }
    
    system.debug('## END Trigger LeadAfterInsert <<<<<' + UserInfo.getUserName());
}