public without sharing class lwc02_Timeline_Ctrl {
    
    @AuraEnabled(cacheable=true)
    public static AP1001_Cycle_Utils.CycleInfo getTimelineInformation(Id userId) {
        
        /* Get User country */
        User currentUser = [SELECT Id, TECH_ExternalId__c, User_Country__c FROM User WHERE Id =: userId];

        // If the user is french
        if (currentUser.User_Country__c == 'FRA') {
            return (AP1001_Cycle_Utils.getCountryCurrentCycleWeek('FRA'));
        } else if (currentUser.User_Country__c == 'ITA') { // Else if the user is Italian
            return (AP1001_Cycle_Utils.getCountryCurrentCycle('ITA'));
        }

        return (null);
    }

}