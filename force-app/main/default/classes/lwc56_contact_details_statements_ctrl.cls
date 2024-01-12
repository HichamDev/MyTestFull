public without sharing class lwc56_contact_details_statements_ctrl {
    
    @AuraEnabled
    public static List<STA_Statement__c> getStatements(String idContact){

        //String idContact = AP1002_Utils_User.getContactFromUser(UserInfo.getUserId()).Id;

        return [SELECT Name 
                      ,TransDate__c 
                      ,TransType__c
                      ,TransDesc__c 
                      ,TransDebit__c
                      ,LU_Url_Detail_Community__c
                      ,TransCredit__c
                      ,RecordType.Name
                FROM STA_Statement__c
                WHERE Contact__c = :idContact
                AND RecordType.DeveloperName = 'Statement'
               ORDER BY TransDate__c DESC
               LIMIT 2000];
    }

    @AuraEnabled
    public static Contact getContact(){
        return AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());
    }

    @AuraEnabled
    public static String getUserType(String idContact){
        return [SELECT RecordType.DeveloperName FROM Contact WHERE Id = :idContact].RecordType.DeveloperName;
    }
}