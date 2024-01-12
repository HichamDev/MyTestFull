global class AP41_BatchAllLogin implements Database.Batchable<sobject>{
    
    private String country = null;

    //global AP41_BatchAllLogin(){}

    global AP41_BatchAllLogin(String countryParam){
        country = countryParam + '%';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        String query = 'SELECT Id, Title, ProfileId, Profile.Name, LU_Monthly_Logins__c, TECH_ExternalId__c, TECH_MergeContactID__c FROM User ' +
                        'WHERE LU_Login_License_Allowed__c = true ' + 
                        ' AND LU_Member_License_Force__c = false ' +
                        ' AND IsActive = true ' + 
            			' AND Profile.Name LIKE \'%_MEMBER\'  ' +
                        ' AND TECH_ExternalId__c LIKE \'' + country + '%\' ';
        if (Test.isRunningTest()) {
            query += ' LIMIT 50';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sobject> scope){

        List<User> l_users = new List<User>();

        Map<String, Id> m_profileIdPerName = new Map<String, Id>();
        for(Profile p : [SELECT Id, Name FROM Profile WHERE Name LIKE '%_LOGIN']){
            m_profileIdPerName.put(p.Name, p.Id);
        }

        

        for(sobject so : scope) {
    	    User us = (User) so;

            if (us.TECH_ExternalId__c.left(3) == 'FRA'){
                us.ProfileId = m_profileIdPerName.get('FRA_LU_DEALER_LOGIN');
            }
            else if(us.Title == 'Smile' || us.Title == AP1000_Utils.REBATE_JOB_TITLE){
                us.ProfileId = m_profileIdPerName.get('ITA_LU_SMILE_LOGIN');
            }
            else{
                us.ProfileId = m_profileIdPerName.get('ITA_LU_DEALER_LOGIN');
            }

            us.LU_Monthly_Logins__c = 0;

            l_users.add(us);

        }

        update l_users;
    }

    global void finish(Database.BatchableContext BC){}
}