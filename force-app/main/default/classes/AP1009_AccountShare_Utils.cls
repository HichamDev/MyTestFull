global without sharing class AP1009_AccountShare_Utils {

    /**
	* Create share by adding a line in AccountShare table.
	* UserOrGroupId -> user with whom to share
	* AccountId -> Account to be shared
	*/
	public static AccountShare createSharing(Id userId, Id accountId){

        AccountShare accountShare = new AccountShare();
        accountShare.AccountId  = accountId;
        accountShare.UserOrGroupId = userId;
        accountShare.AccountAccessLevel = 'Read';
        accountShare.OpportunityAccessLevel = 'None';       
		
		return accountShare;
	}


    /**
	* Delete all accountSharing excluding the role sharing.
	*/
	public static void deleteAllAccountShare(List<Account> accounts){
		
		List<AccountShare> accountShares = new List<AccountShare>();
		
		Set<Id> accountIds = new Set<Id>();
		
		for (Account account : accounts){
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
	* Get parentAccount recursively until no parentAccount.
	*/
	public static map<Id, List<Account>> getParentsAccount(List<Account> accounts, map<Id,Account> allAccounts){
		
		map<Id, List<Account>> maps = new map<Id, List<Account>>();
		
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
	 * Retrieve all parents account that will be used for this chunk.
	 */
	 public static  map<Id, Account> getALLParentsAccount(List<Account> accounts ){
		
		map<Id, Account> maps = new map<Id, Account>();
		
		List<String> parents = new List<string>();
		
		for(Account account : accounts) {
			if(account.TECH_ParentIds__c != null) {
				parents.addALL(account.TECH_ParentIds__c.split(','));
			}			
		}
		//TODO 274683 check if owner if active here
		List<Account> lists = [select Id, OwnerId, ParentId, TECH_IsActiveOwner__c  from Account where Id in : parents];

		for(Account acc : lists) {			
			maps.put(acc.Id, acc);
		}
			
		return maps;
    }

    public static Map<Id, Id> getManagerOfParentAccounts(List<Account> lShareManagerWithCommunityLicenses, Map<Id, Account> mAccountChildOfManager) {

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

    public static Map<Id, Id> getManagerOfOneLevelAccounts(List<Account> lShareManagerOneLevelWithCommunityLicenses, Set<String> sManagerOneLevelAccounts) {

		/* Variables */
		Map<Id, Id> mManagerByParent = new Map<Id, Id>();	

		Set<String> sTitleManager = new Set<String>();
		for (String title : Label.LU_TECH_AP20_Title_Manager_OneLevel.split(',')) {
			sTitleManager.add(title);
		}

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

}