global class AP42_BatchSuperMemberMigration implements Database.Batchable<sobject>{

    private String country = null;

    //global AP42_BatchSuperMemberMigration(){}

    global AP42_BatchSuperMemberMigration(String countryParam){
        country = countryParam + '%';
    }
	
    global Database.QueryLocator start(Database.BatchableContext BC){

        String query = 'SELECT Id, ProfileId, Profile.Name, LU_Monthly_Logins__c FROM User ' +
                        'WHERE Profile.Name LIKE \'%_LOGIN\' ' +
                        ' AND IsActive = true ' +
                        ' AND ( LU_Monthly_Logins__c >= 2 OR LU_Member_License_Force__c = true ) ';
        
        if(String.isBlank(country)){
            query += ' AND TECH_ExternalId__c LIKE :country';
        }
        if (Test.isRunningTest()) {
            query += ' LIMIT 100 ';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sobject> scope){

        List<User> l_users = new List<User>();

        Map<String, Id> m_profileIdPerName = new Map<String, Id>();
        for(Profile p : [SELECT Id, Name FROM Profile WHERE Name LIKE '%_MEMBER']){
            m_profileIdPerName.put(p.Name, p.Id);
        }

        for(sobject so : scope){
    	
    	    User us = (User) so;

            String profilePrefix = us.Profile.Name.left(us.Profile.Name.length() - 6);

            if(m_profileIdPerName.containsKey(profilePrefix + '_MEMBER')){
                us.ProfileId = m_profileIdPerName.get(profilePrefix + '_MEMBER');
                l_users.add(us);
            }
        }

        try{
            update l_users;
            if(Test.isRunningTest()){
                throw new EXC_LU_Test_Licence_Exceeded_Exception('LICENSE_LIMIT_EXCEEDED');
            }
        }
        catch(Exception e){
            if(e.getMessage().contains('LICENSE_LIMIT_EXCEEDED')){
                Profile profileSysAdm = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
                List<String> l_emailSysAdm = new List<String>();

                List<User> l_admin = [SELECT Id, Email FROM User WHERE ProfileId = :profileSysAdm.Id];
                for(User us : l_admin){
                    l_emailSysAdm.add(us.Email);
                }

                EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Super_Member_Migration_Batch_Error' LIMIT 1];
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(l_admin.get(0).Id);
                // message.toAddresses = l_emailSysAdm;
                message.setTemplateId(et.Id);
                message.setSaveAsActivity(false);
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
    }

    global void finish(Database.BatchableContext BC){}
}