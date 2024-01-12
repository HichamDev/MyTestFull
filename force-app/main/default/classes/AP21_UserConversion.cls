/* 
------------------------------------------------------------
-- - Name          : AP21_UserConversion
-- - Author        : NGO
-- - Description   : Class to change user profile conversion.
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 27-JUN-2013  NGO    1.0    Initial version
------------------------------------------------------------
*/
public with sharing class AP21_UserConversion {

    public void convertUser(List<User> users, Map<Id,User> mapOld,Set<Id> setProfileId){
            
                
        Map<Id,Profile> profileIds = new Map<id,profile>([SELECT Id, UserLicenseId, UserLicense.Name FROM Profile WHERE Id in : setProfileId]);

        for (User user : users) {
            
            Id newProfile = user.ProfileId;
                        
            Id oldProfile = mapOld.get(user.Id).ProfileId;
                        
            if (profileIds.get(newProfile).UserLicenseId != profileIds.get(oldProfile).UserLicenseId) {
                
                // Line Up - Bypass user conversion in case :
                // - change from High Volume Customer Portal to Customer Community Plus license
                // - change from One App to Customer Community Plus license
                Boolean bypassConversion = false;
                if (    // HV => CC+
                    	(profileIds.get(oldProfile).UserLicense.Name == 'High Volume Customer Portal' && 
                        profileIds.get(newProfile).UserLicense.Name.contains('Customer Community Plus')) ||
                    	// One App => CC+ : not bypassed
                        //(profileIds.get(oldProfile).UserLicense.Name == 'Force.com - One App' && 
                        //profileIds.get(newProfile).UserLicense.Name.contains('Customer Community Plus')) ||
                    	// CC+ => HV
                    	(profileIds.get(oldProfile).UserLicense.Name.contains('Customer Community Plus') && 
                        profileIds.get(newProfile).UserLicense.Name == 'High Volume Customer Portal') ||
                    	// Force.com APP => Salesforce
                    	(profileIds.get(oldProfile).UserLicense.Name.contains('Force.com - One App') && 
                        profileIds.get(newProfile).UserLicense.Name == 'Salesforce') ||
                    	// Salesforce => Force.com APP
                    	(profileIds.get(oldProfile).UserLicense.Name.contains('Salesforce') && 
                        profileIds.get(newProfile).UserLicense.Name == 'Force.com - One App') ||
                        // Customer Community Plus Login/Member => Customer Community Plus Login/Member
                        (profileIds.get(oldProfile).UserLicense.Name.contains('Customer Community Plus') && 
                        profileIds.get(newProfile).UserLicense.Name.contains('Customer Community Plus')) 
                    ) {
                    bypassConversion = true;
                }

                if (bypassConversion == false) {
                    //desactivate user
                    renameUserInfo(user, mapOld);
                    if (user.TECH_ContactID__c != null) {
                        user.TECH_ContactID__c = null;
                    }
                    if (user.userRoleID != null) {
                        user.userRoleID = null;
                    } 
                }
            } 
        }
    }
    
    private void renameUserInfo(User user, Map<Id,User> mapOld){
        system.debug('#### >>> Licence change');
        user.IsActive = false;
        
        user.TECH_OLD_External_id__c = user.TECH_ExternalId__c;
        
        user.IsPortalEnabled = false;
        
        user.TECH_ExternalId__c = '';
        
        user.username = prependUnderScoreAndTimeStamp(user.username, 80);
        
        user.CommunityNickname = prependUnderScoreAndTimeStamp(user.username, 40);
        
        user.ProfileId = mapOld.get(user.Id).ProfileId;
        
        //TODO userRoleID;
    }

    
    private String prependUnderScoreAndTimeStamp(String value, integer limitRange){
        
        String timestamp = String.valueOf(Datetime.now().getTime()).right(4);
        
        String result = '_' + timestamp + value;
    
        return result.left(limitRange);
    }
    
}