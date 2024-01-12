public without sharing class lwc71_statement_list_ctrl{
	
    @AuraEnabled
    public static List<STA_Statement__c> getStatements(String filters){

        String country = getUserCountry();
        Map<String, List<String>> m_filters = null;
        Contact con = AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());
        String contactId = con.Id;
        User us = [SELECT TECH_MergeContactID__c FROM User WHERE Id = :UserInfo.getUserId()];
        String whereStr = '';
        String strStatementsType = '';
        String strForWho = '';
        List<String> l_directoreTitle = new List<String>{'Direttore di Filiale', 'Direttore di Zona', 'Direttore di Regione'};
        List<String> l_salesTitle = new List<String>{'Sales Consultant', 'Group Sales Consultant', 'Incaricata', 'Incaricata con Gruppo'};


        if(filters != null){
            m_filters = (Map<String, List<String>>)JSON.deserialize(filters, Map<String, List<String>>.class);
        }

        // Get team if manager
        List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(us, con);
        List<Contact> l_myTeam = null;
        if (l_teamAccounts != null) {
            l_myTeam = [SELECT Id FROM Contact WHERE AccountId IN :l_teamAccounts AND LU_Out_Of_Business__c = false];
        } else {
            l_myTeam = [SELECT Id FROM Contact WHERE LU_Out_Of_Business__c = false AND (ReportsToId =: con.Id AND Parent_STH_Id__c =: con.Id)];
        }

    
        if(m_filters != null){
            for (String filter : m_filters.keyset()) {
                List<String> values = m_filters.get(filter);

                if (filter == 'statementType') {
                    for(String s : values){
                        if(strStatementsType != ''){
                            strStatementsType += ' OR ';
                        }
                        
                        if(s == Label.LU_Statement_Filter_Type_Order){
                            strStatementsType += ' TransDesc__c = \'COMMANDE MYSTAN\' ';
                        }
                        else if(s == Label.LU_Statement_Filter_Type_Regularisation){
                            strStatementsType += ' TransDesc__c = \'REGULARISATION\' ';
                        }
                        else if(s == Label.LU_Statement_Filter_Type_Credit){
                            strStatementsType += ' TransDesc__c = \'PAIEMENT\' OR TransDesc__c = \'AVOIR SUR FACTURE\'';
                        }
                        else if(s == Label.LU_Statement_Filter_Type_Pup){
                            strStatementsType += ' TransDesc__c LIKE \'%PUP%\' ';
                        }
                    }

                    if (strStatementsType != '') {
                        strStatementsType = ' ( ' + strStatementsType + ' ) ';
                    }
                }
                else if (filter == 'forWho') {
                    for(String s : values){
                        if(strForWho != ''){
                            strForWho += ' OR ';
                        }
                        
                        if(s == Label.LU_Order_Filter_For_Who_me){
                            strForWho += 'Contact__c = :contactId';
                        }
                        else if(s == Label.LU_Order_Filter_For_Who_my_team){
                            if(l_myTeam != null){
                                strForWho += ' ( Contact__c IN :l_myTeam AND Contact__c <> :contactId ) ';
                            }
                        }
                        else if(s == Label.LU_Order_Filter_For_Who_all){
                            if(l_myTeam != null){
                                strForWho = ' ( Contact__c = :contactId OR Contact__c IN :l_myTeam )';
                            }
                            else{
                                strForWho = 'Contact__c = :contactId';
                            }
                        }
                    }

                    if (strForWho != '') {
                        strForWho = ' ( ' + strForWho + ' ) ';
                    }
                }
            }

            if(strStatementsType != ''){
                whereStr += strStatementsType;
            }
            if(strForWho != ''){
                if(whereStr != ''){
                    whereStr += ' AND ';
                }
                whereStr += strForWho;
            }  
        }

        
        
        // User u = [SELECT Id, STHID__c, TECH_MergeContactID__c, TECH_ContactTechExternalId__c FROM User WHERE Id =: UserInfo.getUserId()];
        // Contact c = AP1002_Utils_User.getContactFromUser(u.Id);

        

        if(country == 'ITA') {
            
            if(whereStr != '') {
                whereStr += ' AND ';
            }

            if (l_directoreTitle.contains(con.Title)) {

                // Get manager team
                // List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(u, c);
                // List<Contact> lTeam = null;
                // if (l_teamAccounts != null) {
                //     lTeam = [SELECT Id FROM Contact WHERE AccountId IN :l_teamAccounts AND LU_Out_Of_Business__c = false];
                // } else {
                //     lTeam = [SELECT Id FROM Contact WHERE LU_Out_Of_Business__c = false AND (ReportsToId =: c.Id AND Parent_STH_Id__c =: c.Id)];
                // }

                String query = 'SELECT Name ' +
                            ',TransDate__c  ' +
                            ',TransType__c ' +
                            ',TransRefID__c  ' +
                            ',TransDebit__c ' +
                            ',LU_Url_Detail_Community__c ' +
                            ',TransAmount__c ' +
                            ',TransDueDate__c ' +
                            ',TransCredit__c ' +
                            ',TransDesc__c ' +
                            ',Contact__r.FirstName ' +
                            ',Contact__r.LastName ' +
                            ',Contact__r.Account.Name ' +
                            ',Contact__r.ReportsToName__c ' +
                            ',Contact__r.Name ' +
                            ',Contact__r.STHId__c ' +
                            ',Status__c ' +
                        'FROM STA_Statement__c ' +
                        'WHERE ' + whereStr +
                        ' ( Contact__c = :contactId OR Contact__c IN :l_myTeam ) AND ' +
                        ' RecordType.DeveloperName = \'Statement\' ' +
                    'ORDER BY TransDate__c DESC ' +
                    'LIMIT 2000';

                System.debug('wherestr : ' + whereStr);
                System.debug('query : ' + query);

                return Database.query(query);
            }
            else if (l_salesTitle.contains(con.Title)) {

                String query = 'SELECT Name ' +
                            ',TransDate__c ' +
                            ',TransType__c ' +
                            ',TransDebit__c ' +
                            ',LU_Url_Detail_Community__c ' +
                            ',TransCredit__c ' +
                        'FROM STA_Statement__c ' +
                        'WHERE ' + whereStr +
                        'Contact__c = :contactId ' +
                        'AND RecordType.DeveloperName = \'Statement\' ' +
                    'ORDER BY TransDate__c DESC ' +
                    'LIMIT 2000';

                System.debug('wherestr : ' + whereStr);
                System.debug('query : ' + query);

                return Database.query(query);
            }
        }
        else if(country == 'FRA') {

            if (strForWho == '') {
                if (whereStr != '') {
                    whereStr += ' AND ';
                }
                whereStr += ' ( Contact__c = :contactId OR Contact__c IN :l_myTeam ) AND ';
            } else {
                if (whereStr != '') {
                    whereStr += ' AND ';
                }
            }

            String query = 'SELECT Name ' +
                            ',TransDate__c ' +
                            ', TransDesc__c ' + 
                            ',TransType__c ' +
                            ',TransDebit__c ' +
                            ', TransRefID__c ' + 
                            ', TransDueDate__c ' +
                            ',LU_Url_Detail_Community__c ' +
                            ',TransCredit__c ' +
                            ', Contact__r.AccountName__c ' +
                            ',Contact__r.FirstName ' +
                            ',Contact__r.LastName ' +
                            ', Contact__r.Name ' +
                            ', Contact__r.STHId__c ' +
                            ', TECH_Account_Name__c ' +
                        'FROM STA_Statement__c ' +
                        'WHERE ' + whereStr +
                        ' RecordType.DeveloperName = \'Statement\' ' +
                    'ORDER BY TransDate__c DESC ' +
                    'LIMIT 2000';

            System.debug('wherestr : ' + whereStr);
            System.debug('query : ' + query);

            return Database.query(query);
        }
        
        return null;
    }

    @AuraEnabled
    public static Contact getContact(){
        return AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());
    }

    @AuraEnabled
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }
}