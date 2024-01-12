global without sharing class AP1020_BatchAccountSharing implements Database.Batchable<sobject> {
    
    /* VARIABLES */
    global string country; 

    /* CONSTRUCTOR */
    /* Parameter : 
        - country : country for which the batch creates the sharing */
    global AP1020_BatchAccountSharing(String  forCountry) {
        this.country = forCountry;
    }


    /* BATCH METHOD : START */
    global Database.QueryLocator start(Database.BatchableContext BC){
	 	
        system.debug('>> AP1020_BatchAccountSharing - Country : ' + country);

        String query = 'SELECT Id, Type, OwnerId, ParentId, TECH_ParentIds__c, name, TECH_IsActiveOwner__c, Country_Code__c  FROM Account WHERE  Country_Code__c = \'' + country + '\' AND LU_Out_Of_Business__c = false '; //  AND LU_Out_Of_Business__c = false
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
	 	
        system.debug('>> START AP1020_BatchAccountSharing');
        system.debug('>>> scope : ' + scope.size());
        
        /* Variables */
        List<Account> accounts = new list<Account>();
        List<Account> lShareManagerWithCommunityLicenses = new List<Account>();
        List<Account> lShareManagerOneLevelWithCommunityLicenses = new List<Account>();
        Set<String> sManagerAccounts = new Set<String>();
        Set<String> sManagerOneLevelAccounts = new Set<String>();
        List<AccountShare> accountShares = new List<AccountShare>(); 

        
        // 1 - Go through the list to get the accounts to share
        for (sobject so : scope) {
            
            Account acc = (Account) so;

            // For the owner sharing
            accounts.add((Account) so);

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

            // FRA : Identify the Level 3 accounts (Animatrice)
            if (acc.Country_Code__c == 'FRA' && acc.Type != null && acc.Type.contains('3')) {
                lShareManagerOneLevelWithCommunityLicenses.add(acc);
                String accId = acc.Id;
                sManagerOneLevelAccounts.add((accId.length() > 15 ? accId.substring(0, 15) : accId));
            }

        }	


        // 2 - Prepare the sharing of the accounts based on the Ownership
        Map<Id, Account> allAccounts  = getALLParentsAccount(accounts);	
        Map<Id, List<Account>> mapsParent = getParentsAccount(accounts, allAccounts);	
        for (Account account : accounts) {
            
            List<Account> parents = mapsParent.get(account.Id);
            
            for (Account parent : parents) {

                // check if is already owner
                if(parent.OwnerId != account.OwnerId && parent.TECH_IsActiveOwner__c){
                    AccountShare accountShare = createSharing(parent.OwnerId, account.Id);
                    system.debug('>>>> accountShare : ' + accountShare);
                    accountShares.add(accountShare);
                }

            }	
        }
        

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

        Map<Id, Id> mManagerByParent = getManagerOfParentAccounts(lShareManagerWithCommunityLicenses, mAccountChildOfManager);
        
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
                AccountShare shParent = createSharing(userManagerId, parentAccount.Id);
                accountShares.add(shParent);
                system.debug('>>>> shParent : ' + shParent);

                // Get the parent account Id in 15 characters
                String parentAccountId = ((String)(parentAccount.Id)).substring(0, 15);

                // Share the child accounts to its manager
                for (Id childAccountId : mAccountChildOfManager.keySet()) {
                    Account child = mAccountChildOfManager.get(childAccountId);
                    if (child.TECH_ParentIds__c.contains(parentAccountId) && child.OwnerId != userManagerId) {
                        AccountShare sh = createSharing(userManagerId, child.Id);
                        system.debug('>>>> sh : ' + sh);
                        accountShares.add(sh);
                    }
                }
            }
        }

        // 4 - Prepare the sharing of manager of one level (old license)
        if (!lShareManagerOneLevelWithCommunityLicenses.isEmpty()) {

            Map<Id, Id> mManagerOneLevelByParent = getManagerOfOneLevelAccounts(lShareManagerOneLevelWithCommunityLicenses, sManagerOneLevelAccounts);
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
                    AccountShare shParent = createSharing(userManagerId, parentAccount.Id);
                    accountShares.add(shParent);
                    system.debug('>>>> shParentOneLevel : ' + shParent);

                }
            }
        }

        system.debug('>> accountShares ' + accountShares.size() );

        // 5 - Operate DML operations (delete, insert)
        if(accountShares.size() > 0) {

            deleteAllAccountShare(accounts);
            // insert accountShares;

            List<Database.SaveResult> lsr = Database.insert(accountShares, false);
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
                    }
                }
            }

            // DEBUG
            for (AccountShare sh : accountShares) {
                system.debug('>> Share : ' + sh);
            } 
        }
                
        
        system.debug('## OUT AP1020_AccountSharingImpl shareAcountbeforeUpdate  accountShares list > ' + accountShares.size() );        
        system.debug('## END AP1020_BatchAccountSharing');
    }

    /* BATCH METHOD : FINISH */
    global void finish(Database.BatchableContext BC){
                    
    }



    /* BUSINESS METHODS */
    private Map<Id, Id> getManagerOfOneLevelAccounts(List<Account> lShareManagerOneLevelWithCommunityLicenses, Set<String> sManagerOneLevelAccounts) {

		/* Variables */
		Map<Id, Id> mManagerByParent = new Map<Id, Id>();	

		Set<String> sTitleManager = new Set<String>();
		for (String title : Label.LU_TECH_AP20_Title_Manager_OneLevel.split(',')) {
			sTitleManager.add(title);
		}
		system.debug('>>> sTitleManager: ' + sTitleManager);
		system.debug('>>> sManagerOneLevelAccounts: ' + sManagerOneLevelAccounts);

		/* Retrieve the contacts managers on the accounts */
		Map<Id, Contact> mContactManagerByAccount = new Map<Id, Contact>([SELECT Id, Title, AccountId, Account.TECH_ParentIds__c
																			FROM Contact
																			WHERE Title LIKE: sTitleManager
																			AND ActivityStatus__c = true
																			AND (AccountId in: sManagerOneLevelAccounts)]);

		/* For each account manager, get the manager contact */
		for (Account acc : lShareManagerOneLevelWithCommunityLicenses) {

			String accId = ((String)acc.Id).substring(0, 15);
			for (Contact con : mContactManagerByAccount.values()) {

				if (con.AccountId == acc.Id) {
					mManagerByParent.put(acc.Id, con.Id);
				}
			}
		}

		return (mManagerByParent);
    }
    
    private Map<Id, Id> getManagerOfParentAccounts(List<Account> lShareManagerWithCommunityLicenses, Map<Id, Account> mAccountChildOfManager) {

		/* Variables */
		Map<Id, Id> mManagerByParent = new Map<Id, Id>();	

		Set<String> sTitleManager = new Set<String>();
		for (String title : Label.LU_TECH_AP20_Title_Manager.split(',')) {
			sTitleManager.add(title);
		}

		/* Retrieve the contacts managers on the accounts */
		Map<Id, Contact> mContactManagerByAccount = new Map<Id, Contact>([SELECT Id, Title, AccountId, Account.TECH_ParentIds__c
																			FROM Contact
																			WHERE Title LIKE: sTitleManager
																			AND ActivityStatus__c = true
																			AND (AccountId in: lShareManagerWithCommunityLicenses OR AccountId in: mAccountChildOfManager.keyset())]);

		/* For each account manager, get the manager contact */
		for (Account acc : lShareManagerWithCommunityLicenses) {

			String accId = ((String)acc.Id).substring(0, 15);
			for (Contact con : mContactManagerByAccount.values()) {

				if (con.AccountId == acc.Id || con.Account.TECH_ParentIds__c.contains(accId)) {
					mManagerByParent.put(acc.Id, con.Id);
				}
			}
		}

		return (mManagerByParent);
    }
    
    /**
	 * Retrieve all parents account that will be used for this chunk.
	 */
	 private  map<Id, Account> getALLParentsAccount(List<Account> accounts ){
		
		map<Id, Account> maps = new map<Id, Account>();
		
		List<String> parents = new List<string>();
		
		for(Account account : accounts){

			if(account.TECH_ParentIds__c != null){
				
				parents.addALL(account.TECH_ParentIds__c.split(','));
			
			}
			// system.debug('## OUT getFormattedParentsIDs  >  parents :' + parents);

			
		}
		//TODO 274683 check if owner if active here
		List<Account> lists = [select Id, OwnerId, ParentId,TECH_IsActiveOwner__c  from Account where Id in : parents];
		
		
		// system.debug('## OUT ' +account.name + '  getParentsAccount list > ' + lists );
		
		for(Account acc : lists){
			
			maps.put(acc.Id, acc);
		}
			
		return maps;
    }
    
    /**
	* Get parentAccount recursively until no parentAccount.
	*/
	public  map<Id, List<Account>> getParentsAccount(List<Account> accounts, map<Id,Account> allAccounts){
		
		map<Id, List<Account>> maps = new map<Id, List<Account>>();
		
		for(Account account : accounts){
			
			List<String> parents = new List<string>();
		
			if(account.TECH_ParentIds__c != null){
				
				parents = account.TECH_ParentIds__c.split(',');
			
			}
			// system.debug('## OUT getFormattedParentsIDs  >  parents :' + parents);
			
			//List<Account> lists = [select Id, OwnerId, ParentId  from Account where Id in : parents];
			
			List<Account> lists = new List<Account>();
			
			for(String parent : parents){
				
				//TODO 274683 check if map contain the parent before adding to list
				
				lists.add(allAccounts.get(parent));
			}
			
			// system.debug('## OUT getFormattedParentsIDs  >  parents :' + parents);

				
			maps.put(account.Id, lists);
		}
			
		return maps;
			
    }
    
    /**
	* Delete all accountSharing excluding the role sharing.
	*/
	public  void deleteAllAccountShare(List<Account> accounts){
		
		List<AccountShare> accountShares = new List<AccountShare>();
		
		Set<Id> accountIds = new Set<Id>();
		
		for(Account account : accounts){
			
			accountIds.add(account.Id);
		}
		
		String userId;
		
		for(AccountShare share : [Select UserOrGroupId, Id From AccountShare where RowCause = : AccountShare.RowCause.Manual and AccountId in : accountIds]){
			
			userId = share.UserOrGroupId;
			
			if(userId.startsWith('005')){
				accountShares.add(share);
			}
			
		}
			
		delete accountShares;
			
    }
    
    /**
	* Create share by adding a ligne in AccountShare table.
	*
	* AccountShare Structure
	*
	* UserOrGroupId -> user with whom to share
	* RowCause -> 'Manuel' will be updated automatically 
	* OpportunityAccessLevel -> 'None'
	* CaseAccessLevel -> 'None'
	* ContactAccessLevel -> not writeable controlled by parent
	* AccountId -> Account to be shared
	* AccountAccessLevel -> 'Edit'
	*/
	public  AccountShare createSharing(Id userId, Id accountId){
		
		// system.debug('## OUT createSharing  >  ownerID :' + ownerId + ' account Id :' + accountId);
        
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId  = accountId;
        accountShare.UserOrGroupId = userId;
        accountShare.AccountAccessLevel = 'Read';
        accountShare.OpportunityAccessLevel = 'None';

		// AccountShare accountShare = new AccountShare();
		// accountShare.UserOrGroupId = userId;
		// accountShare.AccountId = accountId;
		// accountShare.AccountAccessLevel = 'Read';
        // accountShare.OpportunityAccessLevel = 'None';
        
		
		return accountShare;
	}

}