global class BA07_DeletePermissionSetUsers implements Database.Batchable<SObject> , Database.Stateful{
    
    private String allUsersDeletePermission = '';
    
	public Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Start - cancellazione licenze Analytics');
        String query = 'SELECT ID,Name, LastLoginDate, profile.Name, Profile.UserLicense.Name, Username, isActive, (SELECT ID, PermissionSet.Name FROM PermissionSetAssignments WHERE PermissionSet.Name = \'EinsteinAnalyticsUser\' OR PermissionSet.Name = \'Analytics_for_Community_Members\') FROM User WHERE (profile.Name = \'ITA_LU_MANAGER\' OR profile.Name = \'ITA_LU_SALES_MANAGER\')' +(Test.isRunningTest()?' LIMIT 50':'');
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> allUsers){
        List<User> userCCDeletePermission = new List<User>();
        List<User> userSFDeletePermission = new List<User>();
        List<User> allUsersDeletePermissionsList = new List<User>();
        
        try{
            for(User user : allUsers){
                if((user.LastLoginDate < datetime.now().addDays(-60)  || user.LastLoginDate == NULL || user.isActive == false) &&  user.PermissionSetAssignments.size() != 0 && user.Profile.UserLicense.Name.contains('Customer Community')) userCCDeletePermission.add(user);
                if((user.LastLoginDate < datetime.now().addDays(-60) || user.LastLoginDate == NULL || user.isActive == false) &&  user.PermissionSetAssignments.size() != 0 && user.Profile.UserLicense.Name.equals('Salesforce')) userSFDeletePermission.add(user);
            }
            System.debug('Cancellazione licenza Analytics per i seguenti utenti :');
            System.debug('Utenti Customer Community :'+ userCCDeletePermission);
            System.debug('Utenti Salesforce :'+ userSFDeletePermission);
            
            delete [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN : userSFDeletePermission AND PermissionSet.Name = 'EinsteinAnalyticsUser'];
            delete [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN : userCCDeletePermission AND PermissionSet.Name = 'Analytics_for_Community_Members'];
            delete [SELECT Id FROM PermissionSetLicenseAssign  WHERE AssigneeId IN : userSFDeletePermission AND PermissionSetLicense.DeveloperName = 'InsightsBuilderPsl'];
            delete [SELECT Id FROM PermissionSetLicenseAssign  WHERE AssigneeId IN : userCCDeletePermission AND PermissionSetLicense.DeveloperName = 'WaveCommunitiesPsl'];
            
            allUsersDeletePermissionsList.addAll(userCCDeletePermission);
            allUsersDeletePermissionsList.addAll(userSFDeletePermission);
            System.debug('Lista da ciclare : ' + allUsersDeletePermissionsList);
            
            for(user u : allUsersDeletePermissionsList){
                allUsersDeletePermission += u.Username + '\n';
            }
            System.debug('Lista utenti da cancellare : ' + allUsersDeletePermission);
        }
        catch (Exception exc) {
            throw new EXC_LU_Test_Licence_Exceeded_Exception('BA07_DeletePermissionSetUsers - ' + exc.getMessage() + ' - ' + exc.getLineNumber());
        }
    }
    global void finish(Database.BatchableContext BC){
        System.debug('Finish - cancellazione licenze Analytics');
        BA06_UpdatePermissionSetUsers b = new BA06_UpdatePermissionSetUsers(allUsersDeletePermission);
        database.executeBatch(b); 
    }
}