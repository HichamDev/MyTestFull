public without sharing class LWC01_ListView_Ctrl {
    
    /* AURA METHODS */

    @AuraEnabled
    public static List<Contact> getContactList(Id userId, String typeContact, String filters, 
                                                String sortedBy, String sortedDirection, String altPP) {

        //verification of recieved filtres
        System.debug('Sysdeb ==> filters : '+filters); // added by Amine 
        
        // Get contact of the current User
        User u = [SELECT Id, STHID__c, TECH_MergeContactID__c, TECH_ContactTechExternalId__c FROM User WHERE Id =: UserInfo.getUserId()];
        Contact c = AP1002_Utils_User.getContactFromUser(u.Id);

        List<Contact> lContacts = null;

        if (typeContact == 'My Team') {
            lContacts = LWC01_ListView_Ctrl.searchMyTeam(u, filters, sortedBy, sortedDirection, AP1003_Utils_Contact.searchManagerTeamAccount(u, c));

            Map<Id, String> m_photoUrlPerIdContact = new Map<Id, String>();
            for(User us : [SELECT Id, ContactId, SmallPhotoUrl FROM User WHERE ContactId IN :lContacts]){
                m_photoUrlPerIdContact.put(us.ContactId, us.SmallPhotoUrl);
            }

            for(Contact co : lContacts){
                if(m_photoUrlPerIdContact.containsKey(co.Id) && !String.IsBlank( m_photoUrlPerIdContact.get(co.Id) )  ){
                    co.LU_TECH_ProfilePicture__c = m_photoUrlPerIdContact.get(co.Id);
                }
                else{
                    co.LU_TECH_ProfilePicture__c = altPP;
                }
            }
        } else {
            lContacts = LWC01_ListView_Ctrl.searchMyCustomers(u, filters, sortedBy, sortedDirection);
            Map<Id, Date> vMapConIdLastOrderDate = AP1003_Utils_Contact.getContactsLastOrderDate(lContacts);
            if(vMapConIdLastOrderDate != null){
                for(Contact vCon : lContacts){
                    Date vLastOrderDate = vMapConIdLastOrderDate.get(vCon.Id);
                    if(vLastOrderDate != null){
                        vCon.LastDateToOrder__c = vLastOrderDate;
                    }
                }
            }
        }

        return (lContacts);
    }

    /* GET USER COUNTRY */
    @AuraEnabled
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    @AuraEnabled
    public static Contact getContactConnected() {
        return AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());
    }

    /* BUSINESS METHODS */

        /* Get My Customers list with filters */
    public static List<Contact> searchMyCustomers(User u, String filters, String sortedBy, String sortedDirection) {

        // Set the query fields and object
        String soqlQuery = 'SELECT Id, LU_Id_Online__c, LU_New_Online__c, HasOptedOutOfEmail, LU_Sum_My_OrderItems_Last_Order__c, LU_Sum_My_OrderItems_With_Tax_Last_Order__c, LU_Consent_Resend_Email_Date__c, LU_GDPR_Customer_Informed__c, Link_To_Record__c, Name, FirstName, LastName, Email, MobilePhone, LU_Nickname__c, MailingStreet, MailingCity, MailingPostalCode, LU_Typologie__c, LU_Consent_Answer_Date__c ' + 
                            ' FROM Contact '+ 
                            ' WHERE RecordType.DeveloperName = \'LU_Personal_Contact\' AND LU_Is_Deleted__c = false AND OwnerId = \'' + u.Id + '\' ';
        
        // Manage filters
        if (filters != null && filters != '' && filters != '""') {

        }

        // Manager sort
        if(sortedBy != null){
            soqlQuery += ' ORDER BY ' + sortedBy + ' ' + sortedDirection;
        }

        // Manage limit query
        soqlQuery += ' LIMIT 10000';
        
        // Return the query run results
        System.Debug(soqlQuery);
        return (Database.query(soqlQuery));
    }


    /* Get My Team list with filters */
    public static List<Contact> searchMyTeam(User u, String filters, String sortedBy, String sortedDirection, List<Account> lAccountIds) {
        Boolean isActif = false;
        //system.assert(false, filters);
        //List<String> l_segTitle = new List<String>{'Incaricata', 'Smile', 'Sales Consultant'};
        List<String> l_segActivitySegment = new List<String>{'Topazio', 'Zaffiro', 'Rubino', 'Diamante', 'Incaricata', 'Smile', AP1000_Utils.REBATE_JOB_TITLE, 'Sales Consultant'};
        List<Commercial_Periods__mdt> l_cycles = AP1001_Cycle_Utils.getUserPreviousCycles(u.Id);

        // Get contact of connected user
        Contact connectedContact = AP1002_Utils_User.getContactFromUser(u.Id);

        // Set the query fields and object
        String soqlQuery = 'SELECT Id, LU_Id_Online__c, LU_New_Online__c, Link_To_Record__c, AccountId, AccountName__c, STHID__c, Title, LastName, FirstName' +
                            ', Birthdate, SalesSegment__c, Email, MobilePhone, LastOrderDate__c, Last_Order_Total_Amount__c, LU_Nickname__c' +
                            ', MailingStreet, MailingCity, MailingPostalCode, ActivitySegment__c, ReportsToName__c, LU_TECH_Job__c' +
                            ', LU_Typologie__c, Turnover_Current_Period__c, Turnover_Previous_Period__c, DealerSenioritySegment__c' +
                            ', LU_Tech_Sales_Segment__c, LU_LastOrderDate__c, Success_Bearing__c, Parent_STH_Id__c,Parent_STH_Name__c, Start_date__c  ' + 
                            ', LU_Sponsor_Level_1_Name__c, DirectCommissionRate__c, LU_Number_Of_Inactive_Weeks__c, LoyaltyProgram1Balance__c, LoyaltyProgram2Balance__c, LoyaltyProgram3Balance__c  ' +
                            ', LU_Counter_1__c, LU_Counter_2__c, LU_Counter_3__c ' +
                            ', LocalAttribute1__c, LocalAttribute2__c, LocalAttribute4__c, LU_Life_Cycle__c, SalesMgtSegment__c ' + 
                            ', LU_Sleep_Status__c, LU_Sleep_Nb_Period_No_Activity__c, LU_Cumulated_Turnover_Year__c ' + 
                            ', Tech_DR__c, Tech_ZMDD__c, Tech_Secteur__c, LU_Reactivation_Date__c, LocalAttribute3__c, LU_Last_Order_Period__c ' + 
							', (SELECT Id, LU_Use_New_Order_v2__c FROM Contact.Users) '+ 
                            ' FROM Contact '+ 
                            ' WHERE LastModifiedDate = LAST_N_DAYS:2'+
                            ' AND RecordType.DeveloperName != \'LU_Personal_Contact\'  '; // AND LU_Out_Of_Business__c = false

        List<String> l_postalCode = new List<String>();
        Integer valueLastCycleRevenue = null;
        Decimal valueSearchedAmountMin = null;
        Decimal valueSearchedAmountMax = null;
        
        
		String strAttivitaIn = '';
        List<String> l_attivitaInValues = new List<String>();

        // Manage filters
        if (filters != null && filters != '' && filters != '""') {
            
            Map<String, List<String>> lFilters = (Map<String, List<String>>)JSON.deserialize(filters, Map<String, List<String>>.class);
            Set<Integer> sCycleInactive = new Set<Integer>();
            List<String> l_accountId = null;

            // Get the current cycle dates
            AP1001_Cycle_Utils.CycleInfo currentCycle = AP1001_Cycle_Utils.getCurrentCycleByUser(u.Id);

            // Start preparing the filters of the soql request
            String whereStr = '';
            String strActive = '';
            String strInactiveSince = '';
            String strEffectifDormant = '';
            String strBadDept = '';
            String strSegmentatiion = '';
            String strNewCoach = '';
            String strSeniorSegmentatiion = '';
            String strSegmentatiion2 = '';
            string strActivPan = '';
            string strTypo = '';
            string strContactType = '';
            string strFocusOnNewUser = '';
            string strInactiveSince6weeks = '';
            string strInactiveITA = '';
            string strLatePayment = '';
            string strPotential = '';
            String strDealerSegmentationITA = '';
            String strLastCycleRevenuesMin = '';
            String strLastCycleRevenuesMax = '';
            String strResigned = '';
            String strSource = '';
            String StrOwnsEshop = ''; //added by Amine

            for (String filter : lFilters.keyset()) {

                List<String> values = lFilters.get(filter);
                
                if(values.size() < 1){
                    continue;
                }

                // Deprecated ?
                // if(connectedContact.AccountCountryCode__c != 'FRA'){
                //     if(!values.isempty() && values.get(0) != null){
                //         List<String> valueParts = values.get(0).split('zzzzz');
                //         if(valueParts.size() > 1) {
                //             isActif = (valueParts.get(0) == 'Actif');
                //             values[0] = valueParts.get(1);
                //         }
                //     }
                // }
                
                Datetime vStartDate = currentCycle.startdate;
                Datetime vEndDate = currentCycle.enddate;
                //system.assert(false, filter + '***' + values.get(0));
                if ((filter == 'active' || isActif) && vStartDate != null && vEndDate != null) {
                    //system.assert(false, vStartDate + '***' + vEndDate);
                    for(String s : values){
                        if (s == 'active') {
                            strActive += (strActive != '' ? ' OR ' : '');
                            strActive += ' ( LU_LastOrderDate__c >= ' + vStartDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND LU_LastOrderDate__c < ' + vEndDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' ) '; //\'T\'HH:mm:ss\'Z\'
                        } else if (s == 'inactive') {
                            strActive += (strActive != '' ? ' OR ' : '');
                            strActive += ' ( LU_LastOrderDate__c = null OR LU_LastOrderDate__c < ' + vStartDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' ) ';
                        } else {
                            if(values.get(0) != null && values.get(0) != ''){
                                List<String> l_startEndCycle = values.get(0).split(';');
                                if(l_startEndCycle.size() > 1) {
                                    strActive += (strActive != '' ? ' OR ' : '');
                                    strActive += '( LU_LastOrderDate__c >= ' + l_startEndCycle.get(0) + ' AND LU_LastOrderDate__c <= ' + l_startEndCycle.get(1) + ') ';
                                } 
                            }
                        }
                    }
                    if (strActive != '' && (!strActive.startsWith('(') || strActive.startsWith('( LU_LastOrderDate__c >='))) {
                        strActive = ' ( ' + strActive + ' ) ';
                    }
                    
                } else if (filter == 'inactive') {
                    if(strInactiveSince == ''){
                        for(String value : values){
                            if(value != null && value != ''){
                                System.debug(value);
                                strInactiveSince += (strInactiveSince != '' ? ' OR ' : '');
                                if(value.contains('Actif')) strInactiveSince += ' LU_Sleep_Nb_Period_No_Activity__c = 0 ';
                                else strInactiveSince += ' LU_Sleep_Nb_Period_No_Activity__c = ' + value.substring(15, 16) + ' ';
                            }
                        }
                        if (strInactiveSince != '' && strInactiveSince.contains('OR')) {
                            strInactiveSince = ' ( ' + strInactiveSince + ' ) ';
                        }
                    }
                    else{
                        strInactiveSince = '';
                    }

                } else if (filter == 'effectifDormant') {
                    if(strEffectifDormant == ''){
                        if(values.get(0) != null && values.get(0) != ''){
                            for(String value : values){
                                if(strEffectifDormant != '') strEffectifDormant += ' OR ';
                                if(value == 'oneY'){
                                    strEffectifDormant += ' LU_Sleep_Nb_Period_No_Activity__c  >= 12 ' ;
                                }
                                else if(value != null && value != ''){
                                    strEffectifDormant += '( LU_Sleep_Nb_Period_No_Activity__c >= ' + value.left(value.indexOf(';')) + ' AND LU_Sleep_Nb_Period_No_Activity__c <= ' + value.substring(value.indexOf(';')+1, value.length()) + ' ) ';
                                }
                            }
                        }
                        if (strEffectifDormant != '' && strEffectifDormant.contains('OR')) {
                            strEffectifDormant = ' ( ' + strEffectifDormant + ' ) ';
                        }
                    }
                    else{
                        strEffectifDormant = '';
                    }
                }
                else if (filter == 'inactive6weeks') {
                    if(values.get(0) != null && values.get(0) != ''){
                        for(String s : values){
                            if(strInactiveSince6weeks != ''){
                                strInactiveSince6weeks += ' OR ';
                            }
                            List<String> l_startEndCycle = s.split(';');
                            strInactiveSince6weeks += '( LU_LastOrderDate__c >= ' + l_startEndCycle.get(0) + ' AND LU_LastOrderDate__c <= ' + l_startEndCycle.get(1) + ') ';
                            //strInactiveSince6weeks += ' LU_LastOrderDate__c <= ' + l_startEndCycle.get(1) + ' ';
                        }
                    }
                    if (strInactiveSince6weeks != '' && strInactiveSince6weeks.contains('OR')) {
                        strInactiveSince6weeks = ' ( ' + strInactiveSince6weeks + ' ) ';
                    }

                }
                else if (filter == 'inactiveITA') {

                    if(values.get(0) != null && values.get(0) != ''){
                        //strInactiveITA += ' LU_LastOrderDate__c <= ' + values.get(0) + ' ';
                        List<String> l_startEndCycle = values.get(0).split(';');
                        strInactiveITA += '( LU_LastOrderDate__c <= ' + l_startEndCycle.get(0) + ' OR LU_LastOrderDate__c >= ' + l_startEndCycle.get(1) + ') ';
                    }
                }
                else if (filter == 'attivitaIn') {
                    if(values.get(0) != null && values.get(0) != ''){
                        l_attivitaInValues = values;
                        for(String s : values){
                            if(strAttivitaIn != ''){
                                strAttivitaIn += ' OR ';
                            }
                            List<String> l_startEndCycle = s.split(';');
                            strAttivitaIn += '( CreatedDate >= ' + l_startEndCycle.get(0) + ' AND CreatedDate <= ' + l_startEndCycle.get(1) + ') ';
                        }
                    }
                    if (strAttivitaIn != '' && !strAttivitaIn.startsWith('(')) {
                        strAttivitaIn = ' ( ' + strAttivitaIn + ' ) ';
                    }
                }
                else if (filter == 'baddept'){ //1714
                    //system.assert(false, values + '**' + values.size());
                    if(strBadDept == ''){
                        if(values.contains('CONTENTIEUX') && values.contains('IMPAYE')) {
                            strBadDept += '(Bad_Card_Status__c = \'BadDebit\' or Bad_Card_Status__c = \'Block\' or Bad_Card_Status__c = \'Notpayed\')';
                        } else if(values.contains('CONTENTIEUX')) {
                            strBadDept += '(Bad_Card_Status__c = \'BadDebit\' or Bad_Card_Status__c = \'Block\')';
                        } else if(values.contains('IMPAYE')) {
                            strBadDept += '(Bad_Card_Status__c = \'Notpayed\')';
                        }
                        //strBadDept += ' BadDebt__c = ' + values.get(0) + ' ';
                    }
                    else{
                        strBadDept = '';
                    }
                }
                else if(filter == 'segmentation'){

                    for(String s : values){
                        if(!String.IsBlank(strSegmentatiion)){
                            strSegmentatiion += ' OR';
                        }
                        
                        if(l_segActivitySegment.contains(s)){
                            strSegmentatiion += ' ActivitySegment__c = \'' + s + '\'';
                        }
                        // else if(l_segTitle.contains(s)){
                        //     strSegmentatiion += ' Title = \'' + s + '\''; 
                        // }
                        else if(s.contains('Nouveau') && s.contains('<')) {

                            Date dt = null;
                            if (s.contains('1 an')) {
                                dt = Date.today() - 365;
                            } else if (s.contains('6 mois')) {
                                dt = Date.today() - 181;
                            } else {
                                dt = Date.today() - 31;
                            }
                            strSegmentatiion += ' Start_date__c >= ' + dt.year() + '-' + 
                                                                    (dt.month() < 10 ? '0' + dt.month() : '' + dt.month()) + '-' + 
                                                                    (dt.day() < 10 ? '0' + dt.day() : '' + dt.day()) + ' ';
                        }
                        else{
                            strSegmentatiion += ' LU_Tech_Sales_Segment__c = \'' + s + '\'';
                        }
                    }
                    if(strSegmentatiion != '' && !strSegmentatiion.startsWith('(')){
                        strSegmentatiion = ' (' + strSegmentatiion + ') ';
                    }
                }
                else if(filter == 'newCoach'){
                    for(String s : values){
                        if(!String.IsBlank(strNewCoach)){
                            strNewCoach += ' OR';
                        }

                        if(s == 'AUTO ENREGISTREMENT'){
                            strNewCoach += ' LocalAttribute5__c = \'AUTO ENREGISTREMENT\'';
                        }
                        else{
                            strNewCoach += ' LocalAttribute5__c != \'AUTO ENREGISTREMENT\'';
                        }
                    }
                    if(strNewCoach != '' && !strNewCoach.startsWith('(')){
                        strNewCoach = ' (' + strNewCoach + ') AND LocalAttribute5__c != \'\' ';
                    }
                }
                else if(filter == 'seniorSegmentation'){

                    for(String s : values){
                        if(!String.IsBlank(strSeniorSegmentatiion)){
                            strSeniorSegmentatiion += ' OR';
                        }
                        strSeniorSegmentatiion += ' DealerSenioritySegment__c = \'' + s + '\'';
                    }
                    if(strSeniorSegmentatiion != '' && !strSeniorSegmentatiion.startsWith('(')){
                        strSeniorSegmentatiion = ' (' + strSeniorSegmentatiion + ') ';
                    }

                }
                else if(filter == 'source'){
                    Boolean vPerso = false;
                    Boolean vSthFr = false;
                    Boolean vBoth = false;
                    for(String s : values){
                        if(!vPerso && s == 'Personnel') {
                            vPerso = true;
                        }

                        if(!vSthFr && s == 'Stanhome.fr') {
                            vSthFr = true;
                        }
                    }

                    if(vPerso && vSthFr) {
                        vBoth = true;
                    } else {
                        if(vPerso) {
                            strSource = ' LU_Id_Online__c = \'\'';
                        }
    
                        if(vSthFr) {
                            strSource = ' LU_Id_Online__c != \'\'';
                        }
                    }

                    if(strSource != '' && !vBoth && !strSource.startsWith('(')){
                        strSource = ' (' + strSource + ') ';
                    }

                }
                else if(filter == 'focusOnNewUsers'){

                    for(String s : values){
                        if(!String.IsBlank(strFocusOnNewUser)){
                            strFocusOnNewUser += ' OR';
                        }
                        
                        if(s == 'Codificate'){
                            strFocusOnNewUser += ' Title = \'Smile\' AND LU_LastOrderDate__c = null AND';
                            if(l_cycles.size() > 5){
                                // strFocusOnNewUser += ' Start_date__c < ' + l_cycles.get(5).Startdate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' '; 
                                strFocusOnNewUser += ' Start_date__c >= ' + l_cycles.get(5).Startdate__c.format('yyyy-MM-dd') + ' '; 
                            }
                            else{
                                //strFocusOnNewUser += ' Start_date__c < ' + l_cycles.get(l_cycles.size() - 1).Startdate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' '; 
                                strFocusOnNewUser += ' Start_date__c >= ' + l_cycles.get(l_cycles.size() - 1).Startdate__c.format('yyyy-MM-dd') + ' '; 
                            }
                        }
                        else if(s == 'Nuova'){
                            if(l_cycles.size() > 5){
                                // strFocusOnNewUser += ' Start_date__c < ' + l_cycles.get(5).Startdate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' '; 
                                strFocusOnNewUser += ' Start_date__c >= ' + l_cycles.get(5).Startdate__c.format('yyyy-MM-dd') + ' '; 
                            }
                            else{
                                //strFocusOnNewUser += ' Start_date__c < ' + l_cycles.get(l_cycles.size() - 1).Startdate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' '; 
                                strFocusOnNewUser += ' Start_date__c >= ' + l_cycles.get(l_cycles.size() - 1).Startdate__c.format('yyyy-MM-dd') + ' '; 
                            }

                            strFocusOnNewUser += ' AND Title = \'Smile\' AND LU_LastOrderDate__c != null ';
                        }
                    }
                    if(strFocusOnNewUser != ' OR' && strFocusOnNewUser != ' OR' && !strFocusOnNewUser.startsWith('(')){
                        strFocusOnNewUser = ' (' + strFocusOnNewUser + ') ';
                    }
                }
                else if(filter == 'latePayment'){
                    strLatePayment = ' LocalAttribute4__c = \'' + values.get(0) + '\' ' ;
                }
                else if(filter == 'potential'){
                    strPotential = ' SalesMgtSegment__c = \'' + values.get(0) + '\' ' ;
                }
                else if(filter == 'segmentation2'){

                    for(String s : values){
                        if(!String.IsBlank(strSegmentatiion2)){
                            strSegmentatiion2 += ' OR';
                        }
                        
                        if(s == 'DF'){
                            strSegmentatiion2 += ' Title = \'Direttore di Filiale\'';
                        }
                        else if(s == 'Capogruppo'){
                            strSegmentatiion2 += ' (Title = \'Incaricata con Gruppo\' OR Title = \'Group Sales Consultant\')'; 
                        }
                    }
                    if(strSegmentatiion2 != '' && !strSegmentatiion2.startsWith('(')){
                        strSegmentatiion2 = ' (' + strSegmentatiion2 + ') ';
                    }

                }
                // else if(filter == 'activpan' && values[0] != null){
                //     System.debug('activpan');
                //     strActivPan += 'activ pan = \'' += values[0] + '\'';
                // }
                else if(filter == 'typo'){

                    for(String s : values){
                        if(!String.IsBlank(strTypo)){
                            strTypo += ' OR';
                        }
                        if(s == 'Leader 00'){
                            strTypo += ' Success_Bearing__c = \'Coach\'';
                        }
                        else{
                            strTypo += ' Success_Bearing__c = \'' + s + '\'';
                        }
                    }
                    if(strTypo != '' && !strTypo.startsWith('(')){
                        strTypo = ' (' + strTypo + ') ';
                    }

                }
                else if(filter == 'contacttype' && values[0] != 'Tous'){

                    if (values[0] == 'DR') {
                        strContactType += ' Title = \'Direction de Région\' ';
                    } 
                    else if(values[0] == 'ZM,DD'){
                        strContactType += '( Title = \'Zone Manager\' OR Title = \'Directrice de Division\' )';
                    }
                    else if(values[0] == 'LDS'){
                        strContactType += 'Title = \'Animatrice de secteur\'';
                    }
                    else if(values[0] == 'Leader'){
                        strContactType += 'Title = \'Conseillère\' AND Contact_Type__c = \'Leader\'';
                    }
                    else if(values[0] == 'AA'){
                        strContactType += 'Title = \'Animatrice\'';
                    }
                    else if(values[0] == 'Coach'){
                        strContactType += 'Title = \'Conseillère\' AND Contact_Type__c != \'Leader\'';
                    }
                    else if(values[0] == 'Central'){
                        //strContactType += 'Title = \'Conseillère\' AND Contact_Type__c LIKE \'%Central%\'';
                        strContactType += 'Account.name LIKE \'%-CTL%\' and TECH_ExternalId__c LIKE \'FRA%\' ';
                    }
                    else if(values[0] == 'Nouveau Coach < 1 an'){
                        strContactType += 'Title = \'Conseillère\' AND DealerSenioritySegment__c = \'Nouvelle - 1 an\' AND Contact_Type__c != \'Leader\'';
                    }
                    else if(values[0] == 'Inactif du cycle' && vStartDate != null && vEndDate != null){
                        strContactType += '( LU_LastOrderDate__c <= ' + vStartDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' OR LU_LastOrderDate__c >= ' + vEndDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' )';
                    }

                } else if (filter == 'dealerManagerSermentation') {

                    List<Account> lAccountIdsFilter = new List<Account>();
                    Set<String> s_idAccount = new Set<String>();

                    for (String s : values) { 
                        if (s != null && s != 'null' && s.length() >= 15) {
                            s_idAccount.add('%' + s.substring(0, 15) + '%');
                        }
                    }

                    if (!s_idAccount.isEmpty()) {
                        // Check if the accounts selected have some childs
                        lAccountIdsFilter = [SELECT Id, Name, TECH_ParentIds__c, ParentId, OwnerId FROM Account WHERE TECH_ParentIds__c LIKE :s_idAccount ORDER BY Name ASC];
                        if (!lAccountIdsFilter.isEmpty()) {
                            lAccountIdsFilter = AP1003_Utils_Contact.checkParentIdOnChildCaseSensitive(lAccountIdsFilter, s_idAccount);
                        }

                        // add the selected accounts
                        for (String s : values) {
                            lAccountIdsFilter.add(new Account(Id = s.substring(0, 15)));
                        }
                    }

                    if (!lAccountIdsFilter.isEmpty()) {
                        lAccountIds = lAccountIdsFilter;
                    }
                } else if (filter == 'dealerManagerSermentationITA') {

                    for(String s : values){
                        if(!String.IsBlank(strTypo)){
                            //strDealerSegmentationITA += ' OR';
                            strTypo += ' OR';
                        }
                        strTypo += ' SalesMgtSegment__c = \'' + s + '\'';
                    }
                    if(strTypo != '' && !strTypo.startsWith('(')){
                        strTypo = ' (' + strTypo + ') ';
                    }
                }
                // else if (filter == 'lastCycleRevenues') {
                //     if(!String.IsBlank(values.get(0)) != null && Integer.valueOf(values.get(0)) > 0){
                //         valueLastCycleRevenue = Integer.valueOf(values.get(0));
                //     }
                // }
                else if (filter == 'searchedAmountMin') {
                    if(!values.isEmpty()){
                        try{
                            if(!String.IsBlank(values.get(0)) && Decimal.valueOf(values.get(0)) > 0){
                                valueSearchedAmountMin = Decimal.valueOf(values.get(0));
                            }
                        } catch (Exception e) {}
                    }
                }
                else if (filter == 'searchedAmountMax') {
                    if(!values.isEmpty()){
                        try{
                            if(!String.IsBlank(values.get(0)) && Decimal.valueOf(values.get(0)) > 0){
                                valueSearchedAmountMax = Decimal.valueOf(values.get(0));
                            }
                        } catch (Exception e) {}
                    }
                }
                // part added by Amine
                else if(filter == 'OwnsEshop'){
                    System.debug('Sysdeb ==> filter' + filter);
                    if(values.get(0) == 'OUI'){
                        StrOwnsEshop = 'Ecommerce_Role__c = \'e-dealer\' ';
                    }else{
                        StrOwnsEshop = 'Ecommerce_Role__c != \'e-dealer\' ';
                    }
                }
                
                else if(filter == 'postalCode'){
                    for(String s : values){
                        l_postalCode.add(s + '%');
                    }
                }
                else if(filter == 'resigned'){
                    if(values.get(0) == Label.LU_ListViewFilters_Resigned){
                        strResigned = ' Lu_Out_Of_business__c = true ';
                    }
                    else if(values.get(0) == Label.LU_ListViewFilters_NonResigned){
                        strResigned = ' Lu_Out_Of_business__c = false ';
                    }
                }
            }

            whereStr += (!String.isBlank(strActive) || !String.isBlank(strInactiveSince) ? ' AND ' : '') + 
                        strActive + (!String.isBlank(strActive) && !String.isBlank(strInactiveSince) ? ' AND ' : '') + strInactiveSince;

            if (!String.isBlank(strBadDept)) {
                whereStr += ' AND ' + strBadDept;
            } 
            if (!String.isBlank(strInactiveSince6weeks)) {
                whereStr += ' AND ' + strInactiveSince6weeks;
            } 
            if (!String.isBlank(strEffectifDormant)) {
                whereStr += ' AND ' + strEffectifDormant;
            } 
            if (!String.isBlank(strInactiveITA)) {
                whereStr += ' AND ' + strInactiveITA;
            } 
            if (!String.isBlank(strSegmentatiion)) {
                whereStr += ' AND ' + strSegmentatiion;
            } 
            if (!String.isBlank(strNewCoach)) {
                whereStr += ' AND ' + strNewCoach;
            } 
            if (!String.isBlank(strSource)) {
                whereStr += ' AND ' + strSource;
            } 
            if (!String.isBlank(strSeniorSegmentatiion)) {
                whereStr += ' AND ' + strSeniorSegmentatiion;
            }
            if (!String.isBlank(strSegmentatiion2)) {
                whereStr += ' AND ' + strSegmentatiion2;
            }
            // if (!String.isBlank(strActivPan)) {
            //     whereStr += ' AND ' + strActivPan;
            // } 
            if (!String.isBlank(strTypo)) {
                whereStr += ' AND ' + strTypo;
            } 
            if (!String.isBlank(strContactType) ) {
                whereStr += ' AND ' + strContactType;
            } 
            if (!String.isBlank(strFocusOnNewUser) ) {
                whereStr += ' AND ' + strFocusOnNewUser;
            } 
            if (!String.isBlank(strLatePayment) ) {
                whereStr += ' AND ' + strLatePayment;
            } 
            if (!String.isBlank(strPotential) ) {
                whereStr += ' AND ' + strPotential;
            } 
            if (!String.isBlank(strDealerSegmentationITA) ) {
                whereStr += ' AND ' + strDealerSegmentationITA;
            } 
            if (!String.isBlank(strLastCycleRevenuesMin) ) {
                whereStr += ' AND ' + strLastCycleRevenuesMin;
            } 
            if (!String.isBlank(strLastCycleRevenuesMax) ) {
                whereStr += ' AND ' + strLastCycleRevenuesMax;
            } 
            if(!l_postalCode.isEmpty()){
                whereStr += ' AND MailingPostalCode LIKE :l_postalCode ';
            }
            if(!String.isEmpty(StrOwnsEshop)){
                whereStr += ' AND ' +StrOwnsEshop;
                System.debug('Sysdeb ==> whereStr ==> '+ whereStr);
            }

            System.Debug('strResigned : ' + strResigned);
            
            if (!String.isBlank(strResigned) ) {
                whereStr += ' AND ' + strResigned;
            }
            else{
                whereStr += 'AND LU_Out_Of_business__c = false ';
            }

            if (whereStr != '') {
                soqlQuery += whereStr;
            } 
        }
        else{
            // Filter inactive
            soqlQuery += ' AND LU_Out_Of_business__c = false ';
        }


        // Manage the accounts where to search the contacts
        if (lAccountIds != null && !lAccountIds.isEmpty()) {
            String ids = '';
            for (Account acc : lAccountIds) {
                ids += (ids != '' ? ', ' + '\'' + acc.Id + '\'' : '\'' + acc.Id + '\'');
            }
            if(ids.length() > 0){
                soqlQuery += ' AND AccountId in ( ' + ids + ' ) ';
            }
        } else {
            if (connectedContact.AccountCountryCode__c == 'FRA' && connectedContact.Contact_Type__c == 'Leader') {
                soqlQuery += ' AND ( Parent_STH_Id__c = \'' + u.TECH_MergeContactID__c + '\' OR Parent_STH_Id__r.Parent_STH_Id__c = \'' + u.TECH_MergeContactID__c + '\' OR Id = \'' + u.TECH_MergeContactID__c + '\' ) ' ;
            } else {
                soqlQuery += ' AND ( Parent_STH_Id__c = \'' + u.TECH_MergeContactID__c + '\' OR ReportsToId = \'' + u.TECH_MergeContactID__c + '\' ) ' ;
            }
        }

        // Manager sort
        if(sortedBy != null){ 
            soqlQuery += ' ORDER BY ' + sortedBy + ' ' + sortedDirection;
        }

        // Manage limit query
        soqlQuery += ' LIMIT 50000 ';
        
        //system.assert(false, soqlQuery);
        System.debug(soqlQuery.substring(soqlQuery.indexOf('WHERE')));
        
        System.debug('SysDeb - requete SQL ==>' + soqlQuery);

        // Return the query run results
        List<Contact> l_contacts = Database.query(soqlQuery);
        System.debug('SysDeb - Contact List geted with query ==> '+ l_contacts);
        System.debug('SysDeb - Size ==>' + l_contacts.size());
        
        // Attivita In Filter
        if(!l_attivitaInValues.isEmpty() && !l_contacts.isEmpty()){
            String idContacts = '';
            Map<String, List<Order>> m_orderPerContact = new Map<String, List<Order>>();
            for (Contact con : l_contacts) {
                idContacts += (idContacts != '' ? ', ' + '\'' + con.Id + '\'' : '\'' + con.Id + '\'');
                m_orderPerContact.put(con.Id, new List<Order>());
            }

            String excludedOrderStatus = '\'' + Label.LU_Order_Filter_Order_Status_Block + '\',\'' +
                                                Label.LU_Order_Filter_Order_Status_Draft_Api + '\',\'' +
                                                Label.LU_Order_Filter_Order_Status_Delegated + '\',\'' +
                                                Label.LU_Order_Filter_Order_Status_Cancelled_Api + '\'';

            String soqlQueryOrders = 'SELECT Id, BillToContactId, CreatedDate ' + 
                                    'FROM Order ' +
                                    'WHERE ' + strAttivitaIn +
                                    ' AND BillToContactId IN (' + idContacts + ') ' +
                                    ' AND Status NOT IN (' + excludedOrderStatus + ') ORDER BY BillToContactId, CreatedDate';
            System.Debug(soqlQueryOrders);

            for(Order ord : Database.query(soqlQueryOrders)){
                m_orderPerContact.get(ord.BillToContactId).add(ord);
            }

            List<Contact> l_attivitaInContact = new List<Contact>();
            for(Contact con : l_contacts){
                
                for(String s : l_attivitaInValues){
                    List<String> l_startEndCycle = s.split(';');
                    for(Order ord : m_orderPerContact.get(con.Id)){
                        if(ord.CreatedDate > DateTime.valueOfGmt(l_startEndCycle.get(0).replace('T', ' ').replace('Z', '')) && ord.CreatedDate < DateTime.valueOfGmt(l_startEndCycle.get(1).replace('T', ' ').replace('Z', ''))){
                            l_attivitaInContact.add(con);
                            break;
                        }
                    }
                }
            }

            l_contacts = l_attivitaInContact;
        }

        if(sortedBy == 'ActivitySegment__c'){
            List<String> l_termOrders = new List<String>{'Topazio', 'Zaffiro', 'Rubino', 'Diamante'};

            List<Contact> l_orderedContacts = new List<Contact>();

            for(Contact con : l_contacts){
                if(!l_termOrders.contains(con.ActivitySegment__c)){
                    l_orderedContacts.add(con);
                }
            }
            l_contacts = l_orderedContacts;
        }

        // If filter last invoice revenue is on:
        if (valueLastCycleRevenue != null) {
            List<Contact> l_orderedContacts = new List<Contact>();

            for(Contact con : l_contacts){
                if( con.Turnover_Current_Period__c + con.Turnover_Previous_Period__c <= valueLastCycleRevenue ){
                    l_orderedContacts.add(con);
                }
            }
            l_contacts = l_orderedContacts;
        }

        //If search max or min revenue is on:
        if (valueSearchedAmountMin != null && valueSearchedAmountMin >= 0 || valueSearchedAmountMax != null && valueSearchedAmountMax >= 0) {
            List<Contact> l_orderedContacts = new List<Contact>();

            for(Contact con : l_contacts){
                Double totalTurnover = 0;
                totalTurnover += con.Turnover_Previous_Period__c != null ? con.Turnover_Previous_Period__c : 0;
                totalTurnover += con.Turnover_Current_Period__c != null ? con.Turnover_Current_Period__c : 0;
                if( valueSearchedAmountMin != null && valueSearchedAmountMin > 0){
                    if( valueSearchedAmountMax != null && valueSearchedAmountMax > 0 ){
                        if(totalTurnover >= valueSearchedAmountMin && totalTurnover <= valueSearchedAmountMax){
                            l_orderedContacts.add(con);
                        }
                    }
                    else if(totalTurnover >= valueSearchedAmountMin){
                        l_orderedContacts.add(con);
                    }
                }
                else if( valueSearchedAmountMax != null && valueSearchedAmountMax > 0 ){
                    if(totalTurnover <=  valueSearchedAmountMax){
                        l_orderedContacts.add(con);
                    }
                }
            }
            l_contacts = l_orderedContacts;
        }

        List<String> vListConLevel1Ids = new List<String>();
        for(Contact vCon : l_contacts) {
            String vParentId = vCon.Parent_STH_Id__c;
            if(String.isNotBlank(vParentId) && vParentId == connectedContact.Id) {
                vCon.TECH_Level__c = Label.LU_Level1;
                vListConLevel1Ids.add(vCon.Id);
            }
        }

        for(Contact vCon : l_contacts) {
            String vParentId = vCon.Parent_STH_Id__c;
            if(String.isNotBlank(vParentId) && vListConLevel1Ids.contains(vParentId)) {
                vCon.TECH_Level__c = Label.LU_Level2;
            }
        }

        return l_contacts;
    }
    
    public static List<Contact> removeContacts(List<Contact> l_contacts, List<String> l_contactIdsToRemove){
        for(Integer index = l_contacts.size() - 1; index >= 0; index--){
            if(l_contactIdsToRemove.contains(l_contacts.get(index).Id)){
                l_contacts.remove(index);
            }
            index--;
        }
        
        return l_contacts;
    }
}