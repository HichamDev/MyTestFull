global without sharing class AP1020_BatchAccountSharing_Step3 implements Database.Batchable<sobject> {
    
    /* VARIABLES */
    global string country; 

    /* CONSTRUCTOR */
    /* Parameter : 
        - country : country for which the batch creates the sharing */
    global AP1020_BatchAccountSharing_Step3(String  forCountry) {
        this.country = forCountry;
    }

    /* BATCH METHOD : START */
    global Database.QueryLocator start(Database.BatchableContext BC){
	 	
        system.debug('>> AP1020_BatchAccountSharing_Step3 - Country : ' + country);

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
	 	
        system.debug('>> START AP1020_BatchAccountSharing_Step3');
        system.debug('>>> scope : ' + scope.size());
        
        /* Variables */
        List<Account> lShareManagerWithCommunityLicenses = new List<Account>();
        List<AccountShare> lAccountShares = new List<AccountShare>();
        Set<String> sManagerAccounts = new Set<String>(); 

        // 1 - Go through the list to get the accounts to share
        for (sobject so : scope) {

            Account acc = (Account) so;

            // ITA : Identify Level 5 Accounts (DF accounts)
            if (acc.Country_Code__c == 'ITA' && acc.Type != null && acc.Type.contains('5')) {
                lShareManagerWithCommunityLicenses.add(acc);
                String accId = acc.Id;
                sManagerAccounts.add('%' + (accId.length() > 15 ? accId.substring(0, 15) : accId) + '%');
            }

            // FRA : Identify the Level 4 accounts (Animatrice de secteur)
            if (acc.Country_Code__c == 'FRA' && acc.Type != null && acc.Type.contains('4')) {
                lShareManagerWithCommunityLicenses.add(acc);
                String accId = acc.Id;
                sManagerAccounts.add('%' + (accId.length() > 15 ? accId.substring(0, 15) : accId) + '%');
            }

        }	

        if (!lShareManagerWithCommunityLicenses.isEmpty()) {

            // 3 - Prepare the sharing of the accounts for Manager with Community license
            Map<Id, Account> mAccountChildOfManagerSrc = new Map<Id, Account>([SELECT Id, TECH_ParentIds__c, OwnerId
                                                                                FROM Account 
                                                                                WHERE TECH_ParentIds__c LIKE: sManagerAccounts]);
            Map<Id, Account> mAccountChildOfManager = new Map<Id, Account>();
            for (Account accChild : mAccountChildOfManagerSrc.values()) {
                for (String accParent : sManagerAccounts) {
                    String parentId = accParent.remove('%');

                    if (accChild.TECH_ParentIds__c.contains(parentId)) {
                        mAccountChildOfManager.put(accChild.Id, accChild);
                        break;
                    }
                }
            }

            Map<Id, Id> mManagerByParent = AP1009_AccountShare_Utils.getManagerOfParentAccounts(lShareManagerWithCommunityLicenses, mAccountChildOfManager);
            
            Map<Id, User> lUsersForEachManager = new Map<Id, User>([SELECT Id, TECH_MergeContactID__c 
                                                                    FROM User 
                                                                    WHERE IsActive = true 
                                                                    AND (UserType = 'Standard' OR UserType = 'PowerCustomerSuccess')
                                                                    AND TECH_MergeContactID__c in: mManagerByParent.values()]);

            for (Account parentAccount : lShareManagerWithCommunityLicenses) {

                // Get the manager of the account
                Id contactManagerId = mManagerByParent.get(parentAccount.Id);
                Id userManagerId = null;
                for (User user : lUsersForEachManager.values()) {
                    if (user.TECH_MergeContactID__c == contactManagerId) {
                        userManagerId = user.Id; break;
                    }
                }

                // Share the child accounts to the manager
                if (userManagerId != null) {

                    // Share the parent account to the manager
                    AccountShare shParent = AP1009_AccountShare_Utils.createSharing(userManagerId, parentAccount.Id);
                    lAccountShares.add(shParent);
                    system.debug('>>>> shParent : ' + shParent);

                    // Get the parent account Id in 15 characters
                    String parentAccountId = ((String)(parentAccount.Id)).substring(0, 15);

                    // Share the child accounts to its manager
                    for (Id childAccountId : mAccountChildOfManager.keySet()) {
                        Account child = mAccountChildOfManager.get(childAccountId);
                        if (child.TECH_ParentIds__c.contains(parentAccountId) && child.OwnerId != userManagerId) {
                            AccountShare sh = AP1009_AccountShare_Utils.createSharing(userManagerId, child.Id);
                            system.debug('>>>> sh : ' + sh);
                            lAccountShares.add(sh);
                        }
                    }
                }
            }


        }
        
        
        
        // 3 - Insert AccountShare
        List<Database.SaveResult> lsr = Database.insert(lAccountShares, false);
        List<Error_log__c> lErrors = new List<Error_log__c>();
        system.debug('>>> DATABASE.SAVERESULT :');
        Integer cptItem = 0;
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
            cptItem++;
        }

        // If errors
        if (!lErrors.isEmpty()) {
            insert lErrors;
        }
        
        system.debug('## END AP1020_BatchAccountSharing_Step3');
    }

    /* BATCH METHOD : FINISH */
    global void finish(Database.BatchableContext BC){
        system.debug('>> FINISH OF AP1020_BatchAccountSharing_Step3');
        Database.executeBatch(new AP1020_BatchAccountSharing_Step4(country));
    }
}