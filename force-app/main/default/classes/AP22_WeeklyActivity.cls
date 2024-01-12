public with sharing class AP22_WeeklyActivity {
/*
// AP30_BatchGroupBalance
----------------------------------------------------------------------
-- - Name          : AP22_WeeklyActivity
-- - Author        : YGO
-- - Description   : 
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 27-AUG-2013  YGO    1.0      Intitial version
----------------------------------------------------------------------
**********************************************************************
*/


	public static Set<String> country;

	
/**
	* Method which populate the approver of the weekly activity with 
	* the user from the field reports to of the dealer 
	*/
	public static void initialiseApprover(list<WAT_WeeklyActivity__c> weeklyActivities){
		system.debug('>>>>> Start AP22_WeeklyActivity - initialiseApprover <<<<<<<');
		
		Map<Id, User> mapContactReportsToUser = new Map<Id, User>();
		Map<Id, Id> mapDealerToReportsTo = new Map<Id, Id>();
		
		
		

		mapDealerToReportsTo = constructMapDealerToReportsTo(weeklyActivities);
		system.debug('#### mapDealerToReportsTo : ' + mapDealerToReportsTo.size());
		
		mapContactReportsToUser = constructMapContactReportsToUser(mapDealerToReportsTo.values());
		
		system.debug('#### mapContactReportsToUser.size() : ' + mapContactReportsToUser.size());
		if(mapContactReportsToUser.size() > 0 )
		{
			for(WAT_WeeklyActivity__c weeklyActivity : weeklyActivities){
				if(mapContactReportsToUser.get(mapDealerToReportsTo.get(weeklyActivity.Dealer__c)) != null )
				{
					weeklyActivity.Approver__c = mapContactReportsToUser.get(mapDealerToReportsTo.get(weeklyActivity.Dealer__c)).Id;
				}//end of check if map contain dealer			
			}//end of for
		}//end if mapContactReportsToUser.size() > 0
		system.debug('>>>>> END AP22_WeeklyActivity - initialiseApprover <<<<<<<');
	}//end of  initialiseApprover(list<WAT_WeeklyActivity__c> weeklyActivities)
	
	/*Method to extract the report to contact Id from a list of weeklyActivities
	*It returns a map of (dealerId , reportsToId)
	*/
	private static Map<Id,Id> constructMapDealerToReportsTo(list<WAT_WeeklyActivity__c> weeklyActivities){
		Map <Id,Id> mapDealerToReportsTo = new Map <Id,Id>();		
		Set<Id> dealersIds = new Set<Id>();
		
		for(WAT_WeeklyActivity__c weeklyActivity : weeklyActivities){
			dealersIds.add(weeklyActivity.Dealer__c);
		}
		system.debug('#### dealersIds.size() : ' + dealersIds.size());
		system.debug('#### dealersIds : ' + dealersIds);
		country = new Set<String>();
		//reportToIds = [Select ReportsToId From Contact Where id IN :dealersIds ];
		for(Contact con :[Select ReportsToId__c, AccountCountryCode__c From Contact Where id IN :dealersIds ] ){
			mapDealerToReportsTo.put(con.Id, con.ReportsToId__c);
			country.add(con.AccountCountryCode__c);
		}//end of loop contact
		system.debug('#### mapDealerToReportsTo.size() : ' + mapDealerToReportsTo.size());
		system.debug('#### mapDealerToReportsTo : ' + mapDealerToReportsTo);
		
		return mapDealerToReportsTo;
		
	}//end of private method constructMapDealerToReportsTo
		
	/*Method to extract the user of a contact Id from a list of reportToIds
	*It returns a map of (contactId , user)
	*/
	private static Map<Id, User>  constructMapContactReportsToUser(List<Id> reportToIds){
		Map<Id, User> mapContactReportsToUser = new Map<Id, User>();
		
		set<Id> reportToSetIds = new set<Id>(); 
		
		if(reportToIds != null){
			
			for(Id reportsTo : reportToIds){
				
				if(reportsTo != null){
					reportToSetIds.add(reportsTo);
				}
			}
		
			system.debug('### reportToIds : ' + reportToIds);
			
			
			
			
			for(String coun : country){
				
				String filtreCountry = coun+'%';
			
				for(User user1 : [Select Id, TECH_MergeContactID__c From User  where TECH_MergeContactID__c in : reportToSetIds and isActive = true and TECH_ExternalId__c like : filtreCountry]){
					if(user1 != null){
						system.debug('### user1 : ' + user1);
						mapContactReportsToUser.put(Id.ValueOF(user1.TECH_MergeContactID__c),user1);
					}
				}//end of for loop user
			}
			system.debug('### mapContactReportsToUser.size() : ' + mapContactReportsToUser.size());
		}
		return mapContactReportsToUser;
	}//end of  constructMapContactReportsToUser(list<WAT_WeeklyActivity__c> weeklyActivities)

	
	private static Map<Id, Account>  constructMapContactAccount(list<WAT_WeeklyActivity__c> weeklyActivities){
		
		Map<Id, Account> mapContactAccount = new Map<Id, Account>();
		
		Set<Id> dealersIds = new Set<Id>();
		
		for(WAT_WeeklyActivity__c weeklyActivity : weeklyActivities){
			
			dealersIds.add(weeklyActivity.Dealer__c);
		}
		
		//retrieve contact
		List<Contact> dealers = [select Id, AccountId from Contact where Id in : dealersIds];
		
		//retrieve account
		List<Account> accounts = [select Id, OwnerID from Account where Id in (select AccountId from Contact where Id in : dealersIds) ];
		
		for(Contact contact : dealers){
			
			for(Account account : accounts){
				
				if(contact.AccountId == account.id && !mapContactAccount.containsKey(contact.AccountId)){
				
					mapContactAccount.put(contact.id, account);
					
				}
			}	
		}
		
		return mapContactAccount;
		
	}
	
	/*
	* Detect if contact reports to field has been changed and update the approver accordingly.
	*/	
	public static void updateApproverOnContactChange(set<id>contacts){		
		list<WAT_WeeklyActivity__c> weeklyActivities = [select Id, Dealer__c from WAT_WeeklyActivity__c where Dealer__c in : contacts and Status__c <> 'Validated'];
		system.debug('#### weeklyActivities.size() : ' + weeklyActivities.size());
				
		Map<Id, User> mapContactReportsToUser = new Map<Id, User>();
		Map<Id, Id> mapDealerToReportsTo = new Map<Id, Id>();
		
		mapDealerToReportsTo = constructMapDealerToReportsTo(weeklyActivities);
		
		mapContactReportsToUser = constructMapContactReportsToUser(mapDealerToReportsTo.values());
		
		system.debug('#### mapContactReportsToUser.size() : ' + mapContactReportsToUser.size());
		system.debug('#### mapContactReportsToUser : ' + mapContactReportsToUser);
		if(mapContactReportsToUser.size() > 0 )/*HDU comment to set aprrover to null if no user is link to contact*/
		{
			for(WAT_WeeklyActivity__c weeklyActivity : weeklyActivities){
				//weeklyActivity.Approver__c = null;
				if(mapContactReportsToUser.get(mapDealerToReportsTo.get(weeklyActivity.Dealer__c)) != null )
				{
					weeklyActivity.Approver__c = mapContactReportsToUser.get(mapDealerToReportsTo.get(weeklyActivity.Dealer__c)).Id;
				}//end of check if map contain dealer
			}//end of for
		}//end if mapContactReportsToUser.size() > 0
		
		 
		update weeklyActivities;	
		
	}//end of method updateApproverOnContactChange
	
	
}