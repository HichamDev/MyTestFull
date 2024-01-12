global class BA06_UpdatePermissionSetUsers implements Database.Batchable<SObject>, Database.Stateful {
    private List<String> koListUser = new List<String>();
    private String usersDelete = '';
    private List<User> allUserInsertPermission = new List<User>();
    private Integer usableLicenseCC = 0;
    private Integer usableLicenseSF = 0;
    private String addOnOk = '';
    private String addOnKo = '';
    Private String a = '';
    Private Integer numberUsersCC = 0;
    Private Integer numberUsersSF = 0;
    
    public BA06_UpdatePermissionSetUsers(String usersDelete){
        this.usersDelete = usersDelete;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Start - Assegnazione licenze Analytics');
        String query = 'SELECT ID,Name, LastLoginDate, profile.Name, Profile.UserLicense.Name,Username, (SELECT ID, PermissionSet.Name FROM PermissionSetAssignments WHERE PermissionSet.Name = \'EinsteinAnalyticsUser\' OR PermissionSet.Name = \'Analytics_for_Community_Members\') FROM User WHERE isActive = true AND (profile.Name = \'ITA_LU_MANAGER\' OR profile.Name = \'ITA_LU_SALES_MANAGER\')' +(Test.isRunningTest()?' LIMIT 50':'');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User> allUsers){
        Set<User> userCCInsertPermission = new Set<User>();
    	Set<User> userSFInsertPermission = new Set<User>();
        List<PermissionSetAssignment> permissionSetCCList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> permissionSetSFList = new List<PermissionSetAssignment>();
        List<User> userCCPermissionEND = new List<User>();
        List<User> userSFPermissionEND = new List<User>();
        PermissionSet psaSF;
        PermissionSet psaCC;
       	
        try {
            List<PermissionSet> permissionSetList = [SELECT id, label, Name  FROM PermissionSet WHERE Name  = 'EinsteinAnalyticsUser' or Name  = 'Analytics_for_Community_Members'];
            for(PermissionSet psa : permissionSetList){
                if(psa.Name == 'EinsteinAnalyticsUser')  psaSF = psa;
                if(psa.Name == 'Analytics_for_Community_Members')  psaCC = psa;
            }
            
            for(User user : allUsers){
                if(user.LastLoginDate > datetime.now().addDays(-2) &&  user.PermissionSetAssignments.size() == 0 && user.Profile.UserLicense.Name.contains('Customer Community')) userCCInsertPermission.add(user);
               	if(user.LastLoginDate > datetime.now().addDays(-2) && user.PermissionSetAssignments.size() == 0 && user.Profile.UserLicense.Name.equals('Salesforce')) userSFInsertPermission.add(user);
            }

            PermissionSetLicense totalLicenseCC = [SELECT ID, DeveloperName, UsedLicenses, TotalLicenses FROM PermissionSetLicense WHERE  DeveloperName = 'WaveCommunitiesPsl' LIMIT 1];
            PermissionSetLicense totalLicenseSF = [SELECT ID, DeveloperName, UsedLicenses, TotalLicenses FROM PermissionSetLicense WHERE DeveloperName = 'InsightsBuilderPsl' LIMIT 1];
            usableLicenseCC = totalLicenseCC.TotalLicenses - totalLicenseCC.UsedLicenses;
            usableLicenseSF = totalLicenseSF.TotalLicenses - totalLicenseSF.UsedLicenses;
            
            
            numberUsersCC += userCCInsertPermission.size();
            numberUsersSF += userSFInsertPermission.size();
            
            if(userSFInsertPermission.size() > 0){ 
                for(User u : userSFInsertPermission){
                    if(permissionSetSFList.size() >= usableLicenseSF ){
                       	this.addOnKo += u.Username + ' - Esito: Non aggiunto (controllare Add-on disponibili) \n';
                        userSFPermissionEND.add(u);
                    } else {
                        String b = u.Username + ' - Esito: aggiunto \n';
                        this.addOnOk += b;
                        PermissionSetAssignment permissionSetSF = new PermissionSetAssignment(Assigneeid = u.id, PermissionSetId = psaSF.id);
                        permissionSetSFList.add(permissionSetSF);
                    }
                }
            }
            if(userCCInsertPermission.size() > 0){
                for(User u : userCCInsertPermission){
                    if(permissionSetCCList.size() >= usableLicenseCC){
                    	this.addOnKo += u.Username + ' - Esito: Non aggiunto (controllare Add-on disponibili) \n';
                       	userCCPermissionEND.add(u);
                    } else{
                        String  a = u.Username + ' - Esito: aggiunto \n';
                        this.addOnOk += a;
                        PermissionSetAssignment permissionSetCC = new PermissionSetAssignment(Assigneeid = u.id, PermissionSetId = psaCC.id);
                        permissionSetCCList.add(permissionSetCC);
                        }
                }
            }
            System.debug('Assegnazione Add-on Analytics per i seguenti utenti :');
            System.debug('Totale Add-on CustomerCommunity / Add-on da assegnare : ' + usableLicenseCC + ' / ' + userCCInsertPermission.size());
            System.debug('Utenti Customer Community :'+ permissionSetCCList);
            System.debug('Totale Add-on Salesforce / Add-on da assegnare : ' + usableLicenseSF + ' / ' + userSFInsertPermission.size());
            System.debug('Utenti Salesforce :'+ permissionSetSFList);
            
            insert permissionSetCCList;
            insert permissionSetSFList;
        }
        catch (Exception exc) {
            throw new EXC_LU_Test_Licence_Exceeded_Exception('BA06_UpdatePermissionSetUsers - ' + exc.getMessage() + ' - ' + exc.getLineNumber());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        Recap_Email__c mailToSend = [select id, AddressEmail__c FROM Recap_Email__c limit 1];
        System.debug('utenti non andati a buon fine : ' + this.addOnKo);
        System.debug('utenti non andati a buon fine : ' + this.addOnOk);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String bodyEmail;
        bodyEmail = 'Add-on Analytics per utenti SF da assegnare / Add-on Analytics disponibili per utenti SF : ' + numberUsersSF  + ' / ' + usableLicenseSF + '\n';
        bodyEmail += 'Add-on Analytics per utenti CC da assegnare / Add-on Analytics disponibili per utenti CC : ' + numberUsersCC  + ' / ' + usableLicenseCC + '\n';
        bodyEmail += '\n';
        String[] toAddresses = new String[]{mailToSend.AddressEmail__c};
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        bodyEmail += 'Utenti a cui aggiungere l\'Add-on Analytics:\n';
        bodyEmail += addOnKo + '\n';
        bodyEmail += addOnOk + '\n';
       	
        bodyEmail += 'Utenti a cui è stato rimosso l\'Add-on Analytics:\n';
        bodyEmail += usersDelete + '\n';
        
        if(String.isBlank(addOnKo)){
            mail.setSubject('Recap Assegnazione Add-on Analytics');
        } else{
            mail.setSubject('ERROR! Recap Assegnazione Add-on Analytics');
        }
        
        mail.setPlainTextBody(bodyEmail);
        mail.setToAddresses(toAddresses);
        mailList.add(mail);
        if(!mailList.isEmpty()){
                Messaging.sendEmail(mailList);
            }
        System.debug('Finish - assegnazione licenze Analytics');
        
    }
}