/*
----------------------------------------------------------------------
-- - Name          : AP20_BatchAccountSharing.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Implementation for sharing an Account manually in AccountShare.
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 17-DEC-2013  NGO    1.0      Initial version

----------------------------------------------------------------------	
*/
global without sharing class AP20_BatchAccountSharing implements Database.Batchable<sobject>{

	 global string country; 
	 
	 global Database.QueryLocator start(Database.BatchableContext BC){
	 	System.debug('## start country ' + country);

	 	String query = 'SELECT Id, Type, OwnerId, ParentId, TECH_ParentIds__c, name, TECH_IsActiveOwner__c, Country_Code__c  FROM Account WHERE  Country_Code__c = \'' + country + '\'  '; //  AND LU_Out_Of_Business__c = false
	 	if (Label.LU_TECH_AP20_SOQL_Condition_Added != 'None') {
			 query += ' ' + Label.LU_TECH_AP20_SOQL_Condition_Added;
		 }
	 	//country = 'FRA';
	 	if(Test.isRunningTest()){
	 		query = 'SELECT Id, Type, OwnerId, ParentId, TECH_ParentIds__c, name, TECH_IsActiveOwner__c, Country_Code__c FROM Account WHERE  Country_Code__c =: country LIMIT 30';
	 	}
	 	
	 	return Database.getQueryLocator(query);
	 }

	 global AP20_BatchAccountSharing(String  forCountry) {
	 	this.country = forCountry;
	 }
	

	/**
	* Share all account for country with all its parent recursively through field parentAccount.
	* Method that would be used by trigger AfterInsertAccount.
	*/
	 global void execute(Database.BatchableContext BC, List<sobject> scope){
	 	
	 	System.debug('## START AP20_BatchAccountSharing');
	 	System.debug('## START scope' + scope.size());
		
		/* Variables */
	 	List<Account> accounts = new list<Account>();
		List<Account> lShareManagerWithCommunityLicenses = new List<Account>();
		List<Account> lShareManagerOneLevelWithCommunityLicenses = new List<Account>();
		Set<String> sManagerAccounts = new Set<String>();
		Set<String> sManagerOneLevelAccounts = new Set<String>();
		List<AccountShare> accountShares = new List<AccountShare>(); 
		List<AccountShare> accountSharesManagerCommunity = new List<AccountShare>(); 
		List<AccountShare> accountSharesManagerOneLevel = new List<AccountShare>(); 

		
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
				accountSharesManagerCommunity.add(shParent);
				system.debug('>>>> shParent : ' + shParent);

				// Get the parent account Id in 15 characters
				String parentAccountId = ((String)(parentAccount.Id)).substring(0, 15);

				// Share the child accounts to its manager
				for (Id childAccountId : mAccountChildOfManager.keySet()) {
					Account child = mAccountChildOfManager.get(childAccountId);
					if (child.TECH_ParentIds__c.contains(parentAccountId) && child.OwnerId != userManagerId) {
						AccountShare sh = createSharing(userManagerId, child.Id);
						system.debug('>>>> sh : ' + sh);
						accountSharesManagerCommunity.add(sh);
					}
				}
			}
		}

		// 4 - Prepare the sharing of manager of one level (old license)
		if (!lShareManagerOneLevelWithCommunityLicenses.isEmpty()) {
			System.debug('>>> MANAGE ONE LEVEL ACCOUNTS');

			Map<Id, Id> mManagerOneLevelByParent = getManagerOfOneLevelAccounts(lShareManagerOneLevelWithCommunityLicenses, sManagerOneLevelAccounts);
			System.debug('>>> mManagerOneLevelByParent : ' + mManagerOneLevelByParent);
			Map<Id, User> lUsersForEachManagerOneLevel = new Map<Id, User>([SELECT Id, TECH_MergeContactID__c 
																			FROM User 
																			WHERE IsActive = true 
																			AND (UserType = 'Standard' OR UserType = 'PowerCustomerSuccess')
																			AND TECH_MergeContactID__c in: mManagerOneLevelByParent.values()]);
			System.debug('>>> lUsersForEachManagerOneLevel : ' + lUsersForEachManagerOneLevel);
			for (Account parentAccount : lShareManagerOneLevelWithCommunityLicenses) {

				// Get the manager of the account
				Id contactManagerId = mManagerOneLevelByParent.get(parentAccount.Id);
				Id userManagerId = null;
				for (User user : lUsersForEachManagerOneLevel.values()) {
					if (user.TECH_MergeContactID__c == contactManagerId) {
						userManagerId = user.Id; break;
					}
				}
				System.debug('>>> contactManagerId : ' + contactManagerId);
				System.debug('>>> userManagerId : ' + userManagerId);

				// Share the child accounts to the manager
				if (userManagerId != null && userManagerId != parentAccount.OwnerId) {
	
					// Share the parent account to the manager
					AccountShare shParent = createSharing(userManagerId, parentAccount.Id);
					accountSharesManagerOneLevel.add(shParent);
					System.debug('>>>> shParentOneLevel : ' + shParent);
	
				}
			}
		}

		System.debug('## accountShares ' + accountShares.size() );
		System.debug('## accountSharesManagerCommunity ' + accountSharesManagerCommunity.size() );
		System.debug('## accountSharesManagerOneLevel ' + accountSharesManagerOneLevel.size() );

		// 5 - Operate DML operations (delete, insert)
		if(accountShares.size() > 0 || accountSharesManagerCommunity.size() > 0 || accountSharesManagerOneLevel.size() > 0) {
			deleteAllAccountShare(accounts);
			insert accountShares;
			insert accountSharesManagerCommunity;
			insert accountSharesManagerOneLevel;

			for (AccountShare sh : accountShares) {
				system.debug('>>> Inserted accountShares : ' + sh);
			}
			for (AccountShare sh : accountSharesManagerCommunity) {
				system.debug('>>> Inserted accountSharesManagerCommunity : ' + sh);
			}
			for (AccountShare sh : accountSharesManagerOneLevel) {
				system.debug('>>> Inserted accountSharesManagerOneLevel : ' + sh);
			}

		}
		System.debug('## OUT AP20_AccountSharingImpl shareAcountbeforeUpdate  accountShares list > ' + accountShares.size() );
		System.debug(accountShares);
		System.debug('## END AP20_BatchAccountSharing');
	}
	
	private Map<Id, Id> getManagerOfOneLevelAccounts(List<Account> lShareManagerOneLevelWithCommunityLicenses, Set<String> sManagerOneLevelAccounts) {

		/* Variables */
		Map<Id, Id> mManagerByParent = new Map<Id, Id>();	

		Set<String> sTitleManager = new Set<String>();
		for (String title : Label.LU_TECH_AP20_Title_Manager_OneLevel.split(',')) {
			sTitleManager.add(title);
		}
		System.debug('>>> sTitleManager: ' + sTitleManager);
		System.debug('>>> sManagerOneLevelAccounts: ' + sManagerOneLevelAccounts);

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
		}
		//TODO 274683 check if owner if active here
		List<Account> lists = [select Id, OwnerId, ParentId,TECH_IsActiveOwner__c  from Account where Id in : parents];
		for(Account acc : lists){
			maps.put(acc.Id, acc);
		}
			
		return maps;
	}
	 
	/**
	* Get parentAccount recursively until no parentAccount.
	*/
	public  map<Id, List<Account>> getParentsAccount(List<Account> accounts, map<Id,Account> allAccounts){
		Map<Id, List<Account>> maps = new Map<Id, List<Account>>();
		
		for(Account account : accounts){
			List<String> parents = new List<string>();
			if(account.TECH_ParentIds__c != null){
				parents = account.TECH_ParentIds__c.split(',');
			}
			List<Account> lists = new List<Account>();
			for(String parent : parents){
				lists.add(allAccounts.get(parent));
			}
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
		for(AccountShare share : [SELECT UserOrGroupId, Id, LastModifiedBy.Profile.Name 
									FROM AccountShare 
									WHERE RowCause = : AccountShare.RowCause.Manual 
									AND AccountId in : accountIds]){
			userId = share.UserOrGroupId;
			if(userId.startsWith('005') && share.LastModifiedBy.Profile.Name == 'System Administrator with hardDelete'){
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
	public  AccountShare createSharing(Id ownerId, Id accountId){
		AccountShare accountShare = new AccountShare();
		accountShare.UserOrGroupId = ownerId;
		accountShare.AccountId = accountId;
		accountShare.AccountAccessLevel = 'Read';
		accountShare.OpportunityAccessLevel = 'None';
		return accountShare;
	}
	
	global void finish(Database.BatchableContext BC){
                    
    }
    
}