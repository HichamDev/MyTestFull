public without sharing class AP1003_Utils_Contact {
     
    /* GET CONTACT INFO */
    public static Contact getContactInfo(Id contactId) {

        return( [SELECT    ID 
                ,Name
                ,ActivityStatus__c
                ,Contact_Type__c
                ,STHID__c 
                ,Parent_STH_Id__c 
                ,TECH_campaign__c
                ,CurrentBalance__c
                ,CurrencyIsoCode
                ,BadDebt__c
                ,LastDateToOrder__c
                ,MinOrder__c
                ,TECH_WSAvailability__c
                ,AccountId
                ,Account.Type
                ,Account.Owner.Name
                ,Account.ParentId
                ,CommissionRateRange__c
                ,PersonalMessage__c 
                ,TECH_ApplicationDateSent__c
                ,TECH_ApplicationAcessUrl__c
                ,FirstName
                ,LastName
                ,Is_Manager_Order_View__c
                ,MailingAddressComment__c
                ,CurrentCommercialCycle__c
                ,MailingStreet
                ,MailingState
                ,MailingPostalCode
                ,MailingCountry
                ,MailingCity
                ,ReportsToId
                ,NbOrderForCurrentComCycle__c
                ,AccountCountryCode__c
                ,Start_date__c
                ,SalesSegment__c
                ,DirectCommissionRate__c
                ,MobilePhone
                ,Phone
                ,Email
                ,Birthdate
                ,Turnover_Current_Period__c
                ,CommissionsAmount__c
                ,LU_Current_Balance_Total__c
                ,LastOrderDate__c
                ,Last_Order_Total_Amount__c
                ,MinOrderFreeTransportFees__c
                //,AllowedPaymentMode__c
                ,toLabel(AllowedPaymentMode__c) // For profile page display the translation
                ,LU_Nickname__c 
                ,TECH_ExternalId__c
                ,LU_Is_Manager__c 
                ,LU_Current_Cycle_Target__c
                ,LU_TECH_ITA_IsSmile__c
                ,LU_TECH_ITA_IsDealer__c
                ,LU_Tech_Sales_Segment__c
                ,LU_TECH_Contact_Segment__c
                ,Success_Bearing__c
                ,Title
                ,JobTitle_Function__c
                ,NbDaysForCreditLine__c
                ,ReportsToName__c
                ,CurrentBusinessPeriod__c
                ,TransportFeesApplicable__c
                ,ActivitySegment__c
                ,LU_TECH_Top_Manager__c
                ,LU_Facebook_URL__c
                ,LocalAttribute1__c
                ,LocalAttribute2__c
                ,LocalAttribute4__c
                ,Account.Name
                ,LU_Parent_STH_Id_N_1__c
                ,LU_Eligibility_Groups__c
                ,AccountName__c
                ,NB_Recruits_Level1__c
                ,TECH_Wishlist_Open__c
                ,RecordType.DeveloperName 
                ,LU_LastOrderDate__c
                ,OptinNewsletter1__c
                ,HasOptedOutOfEmail
                ,HasOptedOutOfFax
                ,LU_Cumulated_Turnover_Year__c
            FROM Contact WHERE id = : contactId LIMIT 1]);

    }

    /* GET CONTACT USER ASSOCIATED */
    public static User getContactUserAssociated(String contactId) {

        // if(contactId.length() == 18){
        //     contactId = contactId.left(contactid.length() - 3);
        // }
        Id conId = contactId;
        
        User userDealer = [SELECT Id, Profile.Name, TECH_ExternalId__c
                           FROM User 
                           WHERE TECH_MergeContactID__c =: conId
                           AND isActive = true
                           LIMIT 1];
        
        return (userDealer);
    }

    /* Get Direct manager of user */
    public static Id getDirectManagerContactid(Contact con) {
        
        // Variables
        Id contactId = null;

        // If the contact is FRENCH and member of a central account
        if (con.AccountCountryCode__c == 'FRA' && (con.Account.Name.contains('CENTRAL') || con.Account.Name.contains('CTL'))) {
            contactId = con.Parent_STH_Id__c;
        } else { // Otherwise
            contactId = con.ReportsToId;
        }

        return (contactId);

    }


    /* MANAGERS : get their team accounts */
    public static List<Account> searchManagerTeamAccount(User u, Contact c) {

        List<Account> lAcc = null;

        // If the current user is in the Italian hierarchy
        if (c.AccountCountryCode__c == 'ITA') {

            // Get the contacts on the accounts below the current user in the hierarchy
            if (c.Account.Type != 'LEVEL3' && c.Account.Type != 'LEVEL2' && c.Account.Type != 'LEVEL 3') {

                String accId = c.AccountId;
                String likeAcc = '%' + (accId.length() > 15 ? accId.substring(0, 15) : accId) + '%';

                lAcc = [SELECT Id, Name, TECH_ParentIds__c, ParentId, OwnerId, Country_Code__c, Parent.ParentId, Type FROM Account WHERE TECH_ParentIds__c LIKE: likeAcc AND LU_Out_Of_Business__c = false ORDER BY Name ASC];
                Set<String> lStrAccIds = new Set<String>();
                lStrAccIds.add(likeAcc);
                lAcc = checkParentIdOnChildCaseSensitive(lAcc, lStrAccIds);
            } 

        } else if (c.AccountCountryCode__c == 'FRA') {

            // Get account owned by the connected user
            List<Account> lAccOwned = [SELECT Id, Name, ParentId, OwnerId, TECH_ParentIds__c, Country_Code__c, Parent.ParentId, Type FROM Account WHERE OwnerId =: u.Id AND LU_Out_Of_Business__c = false  ORDER BY Name ASC];

            // If the contact is an Animatrice de secteur (can be attached to level 3 or level 4)
            if (c.Title.capitalize() == 'ANIMATRICE DE SECTEUR') {

                String accId1 = c.AccountId;
                String likeAcc = '%' + (accId1.length() > 15 ? accId1.substring(0, 15) : accId1) + '%';

                // If the contact of the 'Animatrice de secteur' is attached to an account on a level 3, get the account Level 4 above in the hierarchy
                if (c.Account.Type == 'LEVEL3') {
                    List<Account> lAccLevel4 = [SELECT ParentId, OwnerId, TECH_ParentIds__c, Country_Code__c, Parent.ParentId, Type FROM Account WHERE Id =: c.AccountId AND LU_Out_Of_Business__c = false ORDER BY Name ASC];
                    if (!lAccLevel4.isEmpty()) {
                        String accid = lAccLevel4[0].ParentId;
                        likeAcc = (accid.length() > 15 ? '%' + accid.substring(0, 15) + '%' : '%' + accid + '%');
                    }
                }

                // Get the contacts if the accounts below
                lAcc = [SELECT Id, Name, TECH_ParentIds__c, ParentId, OwnerId, Country_Code__c, Parent.ParentId, Type 
                        FROM Account
                        WHERE TECH_ParentIds__c LIKE: likeAcc 
                        AND LU_Out_Of_Business__c = false 
                        ORDER BY Name ASC];
                Set<String> lStrAccIds = new Set<String>();
                lStrAccIds.add(likeAcc);
                lAcc = checkParentIdOnChildCaseSensitive(lAcc, lStrAccIds);

            } else if (!lAccOwned.isEmpty()) { // If the connected user owned some accounts (DN, DR, DD)

                Set<String> sIds = new Set<String>();
                for (Account acc : lAccOwned) {
                    String accid = acc.Id;
                    sIds.add((accid.length() > 15 ? '%' + accid.substring(0, 15) + '%' : '%' + accid + '%'));
                } 

                lAcc = [SELECT Id, Name, TECH_ParentIds__c, ParentId, OwnerId, Country_Code__c, Parent.ParentId, Type FROM Account WHERE TECH_ParentIds__c LIKE : sIds AND LU_Out_Of_Business__c = false ORDER BY Name ASC];
                lAcc = checkParentIdOnChildCaseSensitive(lAcc, sIds);
                lAcc.addAll(lAccOwned);

            } else if (c.Account.Type != 'LEVEL3' && c.Account.Type != 'LEVEL2' && c.Account.Type != 'LEVEL 3') {
                // If the contact is on the country, or level 6, or level5 or level 4
                
                // Get the contacts on the accounts below the current user in the hierarchy
                String likeAcc = '%' + String.valueOf(c.AccountId).substring(0, 15) + '%';
                lAcc = [SELECT Id, Name, TECH_ParentIds__c, ParentId, OwnerId, Country_Code__c, Parent.ParentId, Type FROM Account WHERE TECH_ParentIds__c LIKE: likeAcc AND LU_Out_Of_Business__c = false ORDER BY Name ASC];
                Set<String> lStrAccIds = new Set<String>();
                lStrAccIds.add(likeAcc);
                lAcc = checkParentIdOnChildCaseSensitive(lAcc, lStrAccIds);
            } 

        }

        return (lAcc);

    }

    /* Check the child and account Id based on case sensitivity */
    public static List<Account> checkParentIdOnChildCaseSensitive(List<Account> lChildsFound, Set<String> lParentAccountId) {

        List<Account> lAccChecked = new List<Account>();
        
        List<String> lParentIds = new List<String>();
        for (String parentId : lParentAccountId) {
            lParentIds.add(parentId.remove('%'));
        }

        for (Account child : lChildsFound) {
            for (String parentId : lParentIds) {
                if (child.TECH_ParentIds__c.contains(parentId)) {
                    lAccChecked.add(child); break;
                }
            }
        }

        return (lAccChecked);

    }


    /* Get My Customers list with filters */
    public static List<Contact> searchMyCustomers(User u, String filters, String sortedBy, String sortedDirection) {

        // Set the query fields and object
        String soqlQuery = 'SELECT LocalAttribute4__c, PersonalMessage__c, Id, RecordType.DeveloperName, Link_To_Record__c, Name, FirstName, LastName, Email, Phone, LU_Nickname__c, MobilePhone ' + 
                            ' FROM Contact '+ 
                            ' WHERE RecordType.DeveloperName = \'LU_Personal_Contact\' AND OwnerId = \'' + u.Id + '\' AND LU_Is_Deleted__c = false ';
        
        // Manage filters
        if (filters != null && filters != '' && filters != '""') {


        }

        // Manager sort
        soqlQuery += ' ORDER BY ' + sortedBy + ' ' + sortedDirection;

        // Manage limit query
        soqlQuery += ' LIMIT 10000 ';
        
        // Return the query run results
        return (Database.query(soqlQuery));
    }

    /* Get My Team list with filters */
    public static List<Contact> searchMyTeam(User u, String filters, String sortedBy, String sortedDirection) {

        system.debug('>>> searchMyTeam');
        // Get contact of connected user
        Contact connectedContact = AP1002_Utils_User.getContactFromUser(u.Id);

        // Set the query fields and object
        String soqlQuery = 'SELECT LocalAttribute4__c, PersonalMessage__c, Id, Link_To_Record__c, RecordType.DeveloperName, STHID__c, Title, LastName, FirstName, SalesSegment__c, Email, LastOrderDate__c, Last_Order_Total_Amount__c, LU_Nickname__c, AllowedPaymentMode__c ' + 
                            ' FROM Contact '+ 
                            ' WHERE RecordType.DeveloperName != \'LU_Personal_Contact\' AND LU_Out_Of_Business__c = false AND ActivityStatus__c = true ';
        
        // Filter on the team
        List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(u, connectedContact);
        if (l_teamAccounts != null && l_teamAccounts.size() > 0) {

            String accIds = '';
            for (Account acc : l_teamAccounts) {
                accIds += (accIds != '' ? ', \'' + acc.Id + '\'' : '\'' + acc.Id + '\'');
            }
            soqlQuery += ' AND AccountId in ( ' + accIds + ' ) ';
        } else {
            if (connectedContact.AccountCountryCode__c == 'FRA' && connectedContact.Contact_Type__c == 'Leader') {
                soqlQuery += ' AND ( Parent_STH_Id__c = \'' + connectedContact.Id + '\' OR Parent_STH_Id__r.Parent_STH_Id__c = \'' + connectedContact.Id + '\' ) ';
            } else {
                soqlQuery += ' AND ( ReportsToId = \'' + connectedContact.Id + '\' OR Parent_STH_Id__c = \'' + connectedContact.Id + '\' ) ';
            }
        }

        // Sort
        soqlQuery += ' ORDER BY ' + sortedBy + ' ' + sortedDirection;

        // Manage limit query
        soqlQuery += ' LIMIT 50000 ';
        
        system.debug('>>>>> soqlQuery : ' + soqlQuery);
        return (Database.query(soqlQuery));
    }

    /**
    * @description Get last order date for each contact
    * @param List<Contact>
    * @return Map<Id, Date>
    *
    */
    public static Map<Id, Date> getContactsLastOrderDate(List<Contact> pListCons) {
        Map<Id, Date> vMapConIdLastOrderDate = new Map<Id, Date>();
        List<AggregateResult> vARListOrderI = [Select LU_Contact_For__c, MAX(Order.EffectiveDate)lastODate
                                                From OrderItem 
                                                Where LU_Contact_For__c In :pListCons
                                                Group by LU_Contact_For__c];

        for(AggregateResult vAr : vARListOrderI) {
            vMapConIdLastOrderDate.put((Id)vAr.get('LU_Contact_For__c'), (Date)vAr.get('lastODate'));
        }

        return vMapConIdLastOrderDate;
    }

}