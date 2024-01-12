global without sharing class AP1020_BatchAccountSharing_Step4 implements Database.Batchable<sobject> {
    
    /* VARIABLES */
    global string country; 

    /* CONSTRUCTOR */
    /* Parameter : 
        - country : country for which the batch creates the sharing */
    global AP1020_BatchAccountSharing_Step4(String  forCountry) {
        this.country = forCountry;
    }

    /* BATCH METHOD : START */
    global Database.QueryLocator start(Database.BatchableContext BC){
	 	
        system.debug('>> AP1020_BatchAccountSharing_Step4 - Country : ' + country);

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
    global void execute(Database.BatchableContext BC, List<sobject> scope) {

        // Variables
        List<Account> lShareManagerOneLevelWithCommunityLicenses = new List<Account>();
        Set<String> sManagerOneLevelAccounts = new Set<String>();
        List<AccountShare> lAccountShares = new List<AccountShare>(); 

        // 1 - Go through the list to get the accounts to share
        for (sobject so : scope) {
            
            Account acc = (Account) so;

            // FRA : Identify the Level 3 accounts (Animatrice)
            if (acc.Country_Code__c == 'FRA' && acc.Type != null && acc.Type.contains('3')) {
                lShareManagerOneLevelWithCommunityLicenses.add(acc);
                String accId = acc.Id;
                sManagerOneLevelAccounts.add((accId.length() > 15 ? accId.substring(0, 15) : accId));
            }

            // ITA : Identify the Level 4 accounts (Group Sales Consultant)
            if (acc.Country_Code__c == 'ITA' && acc.Type != null && acc.Type.contains('3')) {
                lShareManagerOneLevelWithCommunityLicenses.add(acc);
                String accId = acc.Id;
                sManagerOneLevelAccounts.add((accId.length() > 15 ? accId.substring(0, 15) : accId));
            }
        }

        // 2 - Prepare the sharing of manager of one level (old license)
        if (!lShareManagerOneLevelWithCommunityLicenses.isEmpty()) {

            Map<Id, Id> mManagerOneLevelByParent = AP1009_AccountShare_Utils.getManagerOfOneLevelAccounts(lShareManagerOneLevelWithCommunityLicenses, sManagerOneLevelAccounts);
            Map<Id, User> lUsersForEachManagerOneLevel = new Map<Id, User>([SELECT Id, TECH_MergeContactID__c 
                                                                            FROM User 
                                                                            WHERE IsActive = true 
                                                                            AND (UserType = 'Standard' OR UserType = 'PowerCustomerSuccess')
                                                                            AND TECH_MergeContactID__c in: mManagerOneLevelByParent.values()]);
            for (Account parentAccount : lShareManagerOneLevelWithCommunityLicenses) {

                // Get the manager of the account
                Id contactManagerId = mManagerOneLevelByParent.get(parentAccount.Id);
                Id userManagerId = null;
                for (User user : lUsersForEachManagerOneLevel.values()) {
                    if (user.TECH_MergeContactID__c == contactManagerId) {
                        userManagerId = user.Id; break;
                    }
                }

                // Share the child accounts to the manager
                if (userManagerId != null && userManagerId != parentAccount.OwnerId) {

                    // Share the parent account to the manager
                    AccountShare shParent = AP1009_AccountShare_Utils.createSharing(userManagerId, parentAccount.Id);
                    lAccountShares.add(shParent);
                    system.debug('>>>> shParentOneLevel : ' + shParent);

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
                    log.Feature__c = 'BatchSharing_Step3';
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

        system.debug('## END AP1020_BatchAccountSharing_Step4');

    }


    /* BATCH METHOD : FINISH */
    global void finish(Database.BatchableContext BC){
        system.debug('>> FINISH OF AP1020_BatchAccountSharing_Step4');
    }

}