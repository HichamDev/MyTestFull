global without sharing class AP1007_Batch_User_MonthlyLogin implements Database.Batchable<sobject>{

    private String country = null;

    global AP1007_Batch_User_MonthlyLogin(String countryParam){
        country = countryParam + '%';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
	 	
	 	String query = 'SELECT Id, LU_Monthly_Logins__c ' +
                         'FROM User ' +
                        'WHERE LU_Login_License_Allowed__c = true ' +
                          'AND User_Licence__c LIKE \'%Login\' ' + 
                          'AND IsActive = true ' +
                          'AND TECH_ExternalId__c LIKE \'' + country + '%\'';
	 	if (Test.isRunningTest()) {
            query += ' LIMIT 100 ';
        }
	 	return Database.getQueryLocator(query);
	}

    global void execute(Database.BatchableContext BC, List<sobject> scope){
	 	
	 	system.debug('## START AP1007_Batch_User_MonthlyLogin');
	 	system.debug('## START scope' + scope.size());
		
		/* Variables */
	 	Map<Id, User> mUsers = new Map<Id, User>();
        Map<String, Integer> m_loginCountPerUser = new Map<String, Integer>();
		Map<Id, Set<Date>> mLoginDateByUser = new Map<Id, Set<Date>>();
        
        // Get the user of the scope
		for (sobject so : scope) {
            mUsers.put(so.Id, (User) so);
        }
		
        // For each login history, associate it to a user and count only one login by day
        for (LoginHistory login : [SELECT UserId, LoginTime
                                  	FROM LoginHistory
                                  	WHERE UserId IN :mUsers.keySet()
                                  	AND LoginTime = THIS_MONTH]) {
            Id userId = login.UserId;
            Set<Date> sDateLogin = new Set<Date>();
            Date loginDate = date.newinstance(login.LoginTime.year(), login.LoginTime.month(), login.LoginTime.day());

       		// Get the user login date already managed
           	if (mLoginDateByUser.containsKey(userId)) { sDateLogin = mLoginDateByUser.get(userId); }
            
            // Check if the date of the login is not already counted
            if (sDateLogin.contains(loginDate) == false) { sDateLogin.add(loginDate); }                   
            
            // Update the MAP
            mLoginDateByUser.put(userId, sDateLogin);
                                        
        }
        
        // For each user, check the number of unique login by day
        for (Id userId : mUsers.keyset()) {
            
            User u = mUsers.get(userId);
            
            // Find the login history for this user
            if (mLoginDateByUser.containsKey(userId)) { u.LU_Monthly_Logins__c = mLoginDateByUser.get(userId).size();
            } else {
                u.LU_Monthly_Logins__c = 0;
            }
            
        }
        
        // Update the monthly login information on the user
        if (!mUsers.values().isEmpty()) {
        	update mUsers.values();
        }
        
        
 /*       for(AggregateResult ar : [SELECT UserId, COUNT(Id) 
       							    FROM LoginHistory 
                                    WHERE UserId IN :l_users
                                    AND LoginTime = THIS_MONTH     
                    		        GROUP BY UserId]) {
            m_loginCountPerUser.put( (String) ar.get('arg0'), (Integer) ar.get('arg1') );
        }

        for (User u : l_users) {
            if (m_loginCountPerUser.keyset().contains(u.Id) ) {
                u.LU_Monthly_Logins__c = m_loginCountPerUser.get(u.Id);
            }            else {
                u.LU_Monthly_Logins__c = 0;
            }
        }      

        update l_users;*/
    }

    global void finish(Database.BatchableContext BC){}
}