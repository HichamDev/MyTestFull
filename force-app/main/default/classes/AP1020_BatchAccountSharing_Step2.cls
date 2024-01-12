global without sharing class AP1020_BatchAccountSharing_Step2 implements Database.Batchable<sobject> {
    
    /* VARIABLES */
    global string country; 

    /* CONSTRUCTOR */
    /* Parameter : 
        - country : country for which the batch creates the sharing */
    global AP1020_BatchAccountSharing_Step2(String  forCountry) {
        this.country = forCountry;
    }

    /* BATCH METHOD : START */
    global Database.QueryLocator start(Database.BatchableContext BC){
	 	
        system.debug('>> AP1020_BatchAccountSharing_Step2 - Country : ' + country);

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
	 	
        system.debug('>> START AP1020_BatchAccountSharing_Step2');
        system.debug('>>> scope : ' + scope.size());
        
        /* Variables */
        List<Account> accounts = new list<Account>();
        List<AccountShare> lAccountShares = new List<AccountShare>(); 

        // 1 - Go through the list to get the accounts to share
        for (sobject so : scope) {
            accounts.add((Account) so);
        }	

        // 2 - Prepare the sharing of the accounts based on the Ownership
        Map<Id, Account> allAccounts  = AP1009_AccountShare_Utils.getALLParentsAccount(accounts);	
        Map<Id, List<Account>> mapsParent = AP1009_AccountShare_Utils.getParentsAccount(accounts, allAccounts);	
        for (Account account : accounts) {
            
            List<Account> parents = mapsParent.get(account.Id);
            
            for (Account parent : parents) {

                // check if is already owner
                if(parent.OwnerId != account.OwnerId && parent.TECH_IsActiveOwner__c){
                    AccountShare accountShare = AP1009_AccountShare_Utils.createSharing(parent.OwnerId, account.Id);
                    System.debug('>>>> accountShare : ' + accountShare);
                    lAccountShares.add(accountShare);
                }

            }	
        }
        
        // 3 - Insert AccountShare
        List<Database.SaveResult> lsr = Database.insert(lAccountShares, false);
        List<Error_log__c> lErrors = new List<Error_log__c>();
        Integer cptItem = 0;
        system.debug('>>> DATABASE.SAVERESULT :');
        // Process the save results.
        for (Database.SaveResult sr : lsr) {
            if (sr.isSuccess()){
                system.debug('>>>> SUCCESS : ' + sr.getId());
            }
            else {
                // Displays the errors hapening
                for (Database.Error err : sr.getErrors()) {
                    system.debug('>>>> ERROR - Status code : ' + err.getStatusCode() + ' / Message : ' + err.getMessage() + ' / Fields : ' + err.getFields());
                    Error_log__c log = new Error_log__c();
                    log.Where__c = 'SharingBatch';
                    log.Feature__c = 'BatchSharing_Step2';
                    log.Request__c = '' + lAccountShares[cptItem];
                    log.Message__c = 'STATUS CODE : ' + err.getStatusCode() + ' ///// Message : ' + err.getMessage() + ' ///// Fields : ' + err.getFields();
                    lErrors.add(log);
                }
            }
        }

        // If errors
        if (!lErrors.isEmpty()) {
            insert lErrors;
        }

        system.debug('## END AP1020_BatchAccountSharing_Step2');
    }

    /* BATCH METHOD : FINISH */
    global void finish(Database.BatchableContext BC){
        system.debug('>> FINISH OF AP1020_BatchAccountSharing_Step2');
        Database.executeBatch(new AP1020_BatchAccountSharing_Step3(country));
    }
    
}