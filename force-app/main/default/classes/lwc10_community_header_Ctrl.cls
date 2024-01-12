public with sharing class lwc10_community_header_Ctrl {
	
    @AuraEnabled(cacheable=true)
    public static User getUserInfo(Id userId) {
        return [SELECT FirstName, SmallPhotoUrl FROM User WHERE Id = :userId];
    }
}