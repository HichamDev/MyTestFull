/*
----------------------------------------------------------------------
-- - Name          : AP20IAccountSharing.cls
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Implementation for sharing an Account manually in AccountShare.
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 01-MAY-2013  NGO    1.0      Initial version
-- 17-DEC-2013	NGO				This functionality has been moved to AP20_BatchAccountSharing  

----------------------------------------------------------------------	
*/	
public class AP20_AccountSharingImpl {
	
	
	/*
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
	
	

	/**
	* Share account with all its parent recursively through field parentAccount.
	* Method that would be used by trigger AfterInsertAccount.

	public void shareAcount(List<Account> accounts){
		
		system.debug('## START AP20_AccountSharingImpl shareAcount <<<<<'+UserInfo.getUserName());
		
		//map<Id, Account> allAccounts = retrieveAllAccountByCountry(accounts[0].Country_Code__c);
		
		map<Id, Account> allAccounts  = getALLParentsAccount(accounts);
		
		map<Id, List<Account>> mapsParent = getParentsAccount(accounts, allAccounts);
		
		List<AccountShare> accountShares = new List<AccountShare>(); 
		
		for(Account account : accounts){
			
			List<Account> parents = mapsParent.get(account.Id);
			
			for(Account parent : parents){
				
				if(!isAlreadyOwner(parent.OwnerId, account.OwnerId)){
					
					AccountShare accountShare = createSharing(parent.OwnerId, account.Id);
					
					accountShares.add(accountShare);
				}
			}	
		}
		
		insert accountShares;
		
		system.debug('## OUT AP20_AccountSharingImpl shareAcount  accountShares list > ' + accountShares );
		
		system.debug('## END AP20_AccountSharingImpl shareAcount <<<<<'+UserInfo.getUserName());
	}
	*/
	
	/**
	* This method is used to initialise sharing for account tha has already been created without sharing
	
	public void createShareAcountOnUpdate(Map<Id, Account> oldMap, List<Account> accounts){
		
		system.debug('## START AP20_AccountSharingImpl shareAcountbeforeUpdate <<<<<'+UserInfo.getUserName());
				
		map<Id, Account> allAccounts  = getALLParentsAccount(accounts);
		
		map<Id, List<Account>> mapsParent = getParentsAccount(accounts, allAccounts);
		
		List<AccountShare> accountShares = new List<AccountShare>(); 
		
		for(Account account : accounts){
			
			List<Account> parents = mapsParent.get(account.Id);
			
			for(Account parent : parents){
				
				if(!isAlreadyOwner(parent.OwnerId, account.OwnerId)){
					
					AccountShare accountShare = createSharing(parent.OwnerId, account.Id);
					
					accountShares.add(accountShare);
				}
			}	
		}
		
		insert accountShares;
		
		system.debug('## OUT AP20_AccountSharingImpl shareAcountbeforeUpdate  accountShares list > ' + accountShares );
		
		system.debug('## END AP20_AccountSharingImpl shareAcountbeforeUpdate <<<<<'+UserInfo.getUserName());
	}
	

	
	private List<Account> retrieveAllAccountByCountry(String country){
		
		List<Account> accounts = [select Id, OwnerId, ParentId, TECH_ParentIds__c  from Account where  Country_Code__c =: country];
		

		
		return accounts;
	}
	
	private List<Account>  getChildren(String filter, Id accountOwnerId, List<Account> allAccounts){
		
		
		//[select Id, OwnerId, ParentId  from Account where TECH_ParentIds__c like : filter and OwnerId <> : account.OwnerId ];	
				
		List<Account> children = new List<Account>();
		
		for(Account acc : allAccounts){
			
			if(acc.OwnerId != accountOwnerId && (acc.TECH_ParentIds__c).contains(filter)){
				
				children.add(acc);
			}
			
		}
		
		return children;
		
	}
	
	private List<AccountShare> retrieveAllAccountShares(){
		
		return [select Id, AccountId, UserOrGroupId, RowCause from AccountShare where RowCause <> 'Owner'];
		
	}
	
	private List<AccountShare> getAccountShares(Id oldOwnerId, List<Account> children, List<AccountShare> allAccountShares){
		
		List<AccountShare> accountShare = new List<AccountShare>();
		
		//[select Id, AccountId, UserOrGroupId, RowCause from AccountShare where 
		// UserOrGroupId =: oldOwnerId AND AccountId in : children 
		
		for(AccountShare accShare : allAccountShares){
			
			if(accShare.UserOrGroupId == oldOwnerId ){
				
				for(Account acc : children){
					
					if(accShare.AccountId == acc.Id){
						
						accountShare.add(accShare);
					}
				}	
			}
		}
		
		return accountShare;
		
	}
	*/
	/**
	* When account owner change, change sharing in children account
	
	public void updateShareAcount(Map<Id, Account> oldMap, List<Account> accounts){
		
		system.debug('## START AP20_AccountSharingImpl updateShareAcount <<<<<'+UserInfo.getUserName());
		
		List<AccountShare> accountSharesMod = new List<AccountShare>();
		
		List<AccountShare> accountSharesDel = new List<AccountShare>();
		
		List<Account> allAccounts = retrieveAllAccountByCountry(accounts[0].Country_Code__c);
		
		List<AccountShare> allAccountShares = retrieveAllAccountShares();
		
		for(Account account : accounts){
			
			Id oldOwnerId = oldMap.get(account.Id).OwnerId;
			
			if(account.OwnerId != oldOwnerId){
				
				String filter = account.Id;
				
				filter = '%' + filter.substring(0, 15) + '%';
				
				//check if account.OwnerId not equal to the account owner of the sharing
				//List<Account> children = [select Id, OwnerId, ParentId  from Account where TECH_ParentIds__c like : filter and OwnerId <> : account.OwnerId ];	
				
				List<Account> children = getChildren(filter, account.OwnerId, allAccounts);
				
				
				system.debug('## START AP20_AccountSharingImpl updateShareAcount children <<<<<'+ children);
				
				//retrieve account share corresponding to children and old account owner		
				
				//List<AccountShare>  accountShares = [select Id, AccountId, UserOrGroupId, RowCause from AccountShare where 
				//UserOrGroupId =: oldOwnerId AND AccountId in : children AND RowCause <> 'Owner'];
				
				List<AccountShare>  accountShares = getAccountShares(oldOwnerId, children, allAccountShares);
				
				system.debug('## START AP20_AccountSharingImpl updateShareAcount accountShares <<<<<'+ accountShares);
				
				for(AccountShare share : accountShares){
					
					system.debug('## START AP20_AccountSharingImpl account.OwnerId <<<<<'+ account.OwnerId);
					
					system.debug('## START AP20_AccountSharingImpl share.UserOrGroupId <<<<<'+ share.UserOrGroupId);

					AccountShare newShare = createSharing(account.OwnerId, share.AccountId);
					
					accountSharesMod.add(newShare);
					
					system.debug('## START AP20_AccountSharingImpl updateShareAcount newShare <<<<<'+ newShare);
		
				}
				
				system.debug('## START AP20_AccountSharingImpl updateShareAcount accountSharesMod <<<<<'+ accountSharesMod);
				
				accountSharesDel.addAll(accountShares);
				
			}
		}
		
		if(accountSharesDel.size() > 0 ){
		
			delete accountSharesDel;
			
		}
		if(accountSharesMod.size() > 0 ){
			
			insert accountSharesMod;
		}
		
		
		system.debug('## END AP20_AccountSharingImpl updateShareAcount <<<<<'+UserInfo.getUserName());
	}
	*/
	
	/**
	* When account owner change, change sharing in children account
	
	public void unShareAcount(List<Account> accounts){
		
		system.debug('## START AP20_AccountSharingImpl unShareAcount <<<<<'+UserInfo.getUserName());
		
		List<AccountShare> accountSharesDel = new List<AccountShare>();
		
		for(Account account : accounts){
			
			//Id oldOwnerId = oldMap.get(account.Id).OwnerId;

			String filter = account.Id;
			
			filter = '%' + filter.substring(0, 15) + '%';
			
			List<Account> children = [select Id, OwnerId, ParentId  from Account where TECH_ParentIds__c like : filter];	
			
			system.debug('## START AP20_AccountSharingImpl unShareAcount children <<<<<'+ children);
			
			//retrieve account share corresponding to children and old account owner		
			
			List<AccountShare>  accountShares = [select Id, AccountId, UserOrGroupId, RowCause from AccountShare where 
			UserOrGroupId =: account.OwnerId AND AccountId in : children AND RowCause <> 'Owner'];
			
			system.debug('## START AP20_AccountSharingImpl unShareAcount accountShares <<<<<'+ accountShares);
			
			
			accountSharesDel.addAll(accountShares);
				
		}
		
		delete accountSharesDel;
		
		system.debug('## END AP20_AccountSharingImpl unShareAcount <<<<<'+UserInfo.getUserName());
	}
	
	
	public  map<Id, Account> getALLParentsAccount(List<Account> accounts ){
		
		map<Id, Account> maps = new map<Id, Account>();
		
		List<String> parents = new List<string>();
		
		for(Account account : accounts){
			
		
			if(account.TECH_ParentIds__c != null){
				
				parents.addALL(account.TECH_ParentIds__c.split(','));
			
			}
			system.debug('## OUT getFormattedParentsIDs  >  parents :' + parents);
			
			system.debug('## OUT getFormattedParentsIDs  >  parents :' + parents);	
			
		}
		
		List<Account> lists = [select Id, OwnerId, ParentId  from Account where Id in : parents];
		
		system.debug('## OUT ' +account.name + '  getParentsAccount list > ' + lists );
		
		for(Account acc : lists){
			
			maps.put(acc.Id, acc);
		}
			
		return maps;
	}
	*/
	/**
	* Get parentAccount recursively until no parentAccount.
	
	public  map<Id, List<Account>> getParentsAccount(List<Account> accounts, map<Id,Account> allAccounts){
		
		map<Id, List<Account>> maps = new map<Id, List<Account>>();
		
		for(Account account : accounts){
			
			List<String> parents = new List<string>();
		
			if(account.TECH_ParentIds__c != null){
				
				parents = account.TECH_ParentIds__c.split(',');
			
			}
			system.debug('## OUT getFormattedParentsIDs  >  parents :' + parents);
			
			//List<Account> lists = [select Id, OwnerId, ParentId  from Account where Id in : parents];
			
			List<Account> lists = new List<Account>();
			
			for(String parent : parents){
				
				lists.add(allAccounts.get(parent));
			}
			
			system.debug('## OUT getFormattedParentsIDs  >  parents :' + parents);

			system.debug('## OUT ' +account.name + '  getParentsAccount list > ' + lists );
				
			maps.put(account.Id, lists);
		}
			
		return maps;
			
	}
	*/	

	/**
	* Create share by adding a ligne in AccountShare table.
	
	public  AccountShare createSharing(Id ownerId, Id accountId){
		
		system.debug('## OUT createSharing  >  ownerID :' + ownerId + ' account Id :' + accountId);
			
		AccountShare accountShare = new AccountShare();
		accountShare.UserOrGroupId = ownerId;
		accountShare.AccountId = accountId;
		accountShare.AccountAccessLevel = 'Read';
		accountShare.OpportunityAccessLevel = 'None';
		
		return accountShare;
	}
	*/
	
	/**
	* Check whether the sharing exist.
		
	private  boolean isAlreadyOwner(Id ParentOwnerId, Id accountOwnerId){
		
		return ParentOwnerId == accountOwnerId ? true : false ;
	}
	*/
}