global without sharing class AP1020_BatchAccountSharing_Step1 implements Database.Batchable<sobject> {
    
    /* VARIABLES */
    global string country; 

    /* CONSTRUCTOR */
    /* Parameter : 
        - country : country for which the batch creates the sharing */
    global AP1020_BatchAccountSharing_Step1(String  forCountry) {
        this.country = forCountry;
    }


    /* BATCH METHOD : START */
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('>> AP1020_BatchAccountSharing_Step1 - Country : ' + country);

        String query = 'SELECT Id, Type, OwnerId, ParentId, TECH_ParentIds__c, name, TECH_IsActiveOwner__c, Country_Code__c  FROM Account WHERE  Country_Code__c = \'' + country + '\' AND LU_Out_Of_Business__c = false '; 
        if (Label.LU_TECH_AP20_SOQL_Condition_Added != 'None') {
            query += ' ' + Label.LU_TECH_AP20_SOQL_Condition_Added;
        }
        if(Test.isRunningTest()){
            query = 'SELECT Id, Type, OwnerId, ParentId, TECH_ParentIds__c, name, TECH_IsActiveOwner__c, Country_Code__c FROM Account WHERE  Country_Code__c =: country LIMIT 30';
        }
        
        return Database.getQueryLocator(query);
    }


    /* BATCH METHOD : EXECUTE */
    global void execute(Database.BatchableContext BC, List<sobject> scope){
	 	
        System.debug('>> START AP1020_BatchAccountSharing_Step1');
        System.debug('>>> scope : ' + scope.size());
        
        /* Variables */
        List<Account> accounts = new list<Account>();
        
        // 1 - Go through the list to get the accounts to share
        for (sobject so : scope) {
            accounts.add((Account) so);
        }	

        // 2 - Delete the sharing of the accounts managed
        if (!accounts.isEmpty()) {
            AP1009_AccountShare_Utils.deleteAllAccountShare(accounts);
        }
             
        System.debug('## END AP1020_BatchAccountSharing_Step1');
    }

    /* BATCH METHOD : FINISH */
    global void finish(Database.BatchableContext BC){
        System.debug('>> FINISH OF AP1020_BatchAccountSharing_Step1');
        Database.executeBatch(new AP1020_BatchAccountSharing_Step2(country));
    }


}