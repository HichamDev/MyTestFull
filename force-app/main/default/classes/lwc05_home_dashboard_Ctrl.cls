public without sharing class lwc05_home_dashboard_Ctrl {

/* ---------------------- WRAPPER CLASS ---------------------- */    
    public class Indicator {
        @AuraEnabled
        public Boolean isText {get;set;}
        @AuraEnabled
        public Boolean isNumber {get;set;} // If the KPI is a number
        @AuraEnabled
        public Boolean isDonught {get;set;} // If the KPI is a doughnut
        @AuraEnabled
        public String label {get;set;} // Label displayed on the KPI
        @AuraEnabled
        public String labelAPIName {get;set;} // Label displayed on the KPI
        @AuraEnabled
        public Boolean isCurrencyDecimal1 {get;set;} // If the decimal1 isCurrency
        @AuraEnabled
        public Boolean isPercentDecimal1 {get;set;} // If the decimal1 is a percent
        @AuraEnabled
        public Boolean isNbDecimal1 {get;set;} // If the decimal1 is a simple number
        @AuraEnabled
        public Decimal vDecimal1 {get;set;} // Decimal 1 value
        @AuraEnabled
        public String vDecimal1Txt {get;set;} // Decimal 1 type to display
        @AuraEnabled
        public Boolean isCurrencyDecimal2 {get;set;} // If the decimal2 isCurrency
        @AuraEnabled
        public Decimal vDecimal2 {get;set;} // Decimal 2 value
        @AuraEnabled
        public String vDecimal2Txt {get;set;} // Decimal 2 type to display
        @AuraEnabled
        public Boolean isCurrencyDecimal3 {get;set;} // If the decimal3 isCurrency
        @AuraEnabled
        public Decimal vDecimal3 {get;set;} // Decimal 3 value
        @AuraEnabled
        public String vDecimal3Txt {get;set;} // Decimal 3 type to display
        @AuraEnabled
        public Boolean isCurrencyDecimal4 {get;set;} // If the decimal4 isCurrency
        @AuraEnabled
        public String vDecimal4Txt {get;set;} // Decimal 4 type to display
        @AuraEnabled
        public Decimal vDecimal4 {get;set;} // Decimal 4 value
        @AuraEnabled
        public String vString1 {get;set;} // String 1 value
        @AuraEnabled
        public String vString2 {get;set;} // String 2 value
    }

    private static String gUsProfileName = AP1002_Utils_User.getUserProfileName();

/* ---------------------- UI METHODS ---------------------- */

    /* Get the contact of the connected user */
    @AuraEnabled
    public static Contact getCurrentContact() {
        return (AP1002_Utils_User.getConnectedUserContact());
    }

    @AuraEnabled
    public static String getUserCountry(){
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    /* Get the indicators to display for the current user */
    @AuraEnabled
    public static List<Indicator> getCurrentContactIndicators() {
        
        // Variables
        List<Indicator> lIndicators = new List<Indicator>();

        // Get the current contact
        Contact con = AP1002_Utils_User.getConnectedUserContact();
        User u = [SELECT Id, TECH_MergeContactID__c, LU_Use_New_Order_v2__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        
        // Get the current cycle of the contact
        AP1001_Cycle_Utils.CycleInfo currentCycle = AP1001_Cycle_Utils.getCountryCurrentCycle(con.AccountCountryCode__c);
        AP1001_Cycle_Utils.CycleInfo currentWeek = AP1001_Cycle_Utils.getCountryCurrentCycleWeek(con.AccountCountryCode__c);

        if(Test.isRunningTest()){
            currentCycle.startdate = Date.today().addDays(-5);
            currentCycle.enddate = Date.today().addDays(5);
        }

        // Get the indicators depending on the country, type of contact
        // For FRANCE
        if (con.AccountCountryCode__c == 'FRA') {

            if (Test.isRunningTest()) {

                // If DD, ZM, DR
                if (con.Title != null && (con.Title.contains('Zone') || con.Title.contains('division') || con.Title.contains('Région'))) {

                    // Get manager team
                    List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(u, con);
                    List<Contact> lTeam = null;
                    if (l_teamAccounts != null) {
                        lTeam = [SELECT Id FROM Contact WHERE AccountId IN :l_teamAccounts AND LU_Out_Of_Business__c = false];
                    } else {
                        lTeam = [SELECT Id FROM Contact WHERE LU_Out_Of_Business__c = false AND (ReportsToId =: con.Id AND Parent_STH_Id__c =: con.Id)];
                    }


                    // TEAM CA CURRENT WEEK
                    lIndicators.add(getManagerGetTeamTurnoverBetweenTwoDates(u, con, lTeam, currentWeek.startdate, currentWeek.enddate, Label.LU_Dashboard_CA_Team_Week));

                    // TEAM TURNOVER CURRENT CYCLE
                    lIndicators.add(getManagerGetTeamTurnoverBetweenTwoDates(u, con, lTeam, currentCycle.startdate, currentCycle.enddate, Label.LU_Dashboard_CA_Team_Cycle));

                    // TEAM MEMBER ACTIVITY RATE CURRENT WEEK
                    Indicator indNumActWeek = getManagerGetActiveMembersBetweenTwoDates(u, con, lTeam, currentWeek.startdate, currentWeek.enddate, Label.LU_Dashboard_Number_Activ_Weeks);
                    if(indNumActWeek != null){
                        Indicator ind1 = new Indicator();
                        ind1.isNumber = true;
                        ind1.label = Label.LU_Dashboard_Team_Taus_Activity;
                        if (indNumActWeek.vDecimal1 == 0) {
                            ind1.vDecimal1 = 0;
                        } else {
                            ind1.vDecimal1 = (indNumActWeek.vDecimal1 == 0 ? 1 : indNumActWeek.vDecimal1) / lTeam.size() ;
                        }
                        ind1.isPercentDecimal1 = true;
                        lIndicators.add(ind1);
                    }


                } else if (con.Title == 'Animatrice' || con.Title == 'Animatrice de Secteur' || ( con.Success_Bearing__c != null && con.Success_Bearing__c.contains('Leader') && con.Success_Bearing__c != 'Leader')) { // animatrice

                    /* Get the team members of the manager */
                    List<Contact> lTeam = AP1003_Utils_Contact.searchMyTeam(u, null, 'LastName', 'ASC');

                    // TEAM CA CURRENT WEEK
                    //Indicator indTeamCAWeek = getManagerGetTeamTurnoverBetweenTwoDates(u, con, lTeam, currentWeek.startdate, currentWeek.enddate, Label.LU_Dashboard_CA_Team_Week);
                    
                    // TEAM TURNOVER CURRENT CYCLE
                    //Indicator indTeamCACycle = getManagerGetTeamTurnoverBetweenTwoDates(u, con, lTeam, currentCycle.startdate, currentCycle.enddate, Label.LU_Dashboard_CA_Team_Cycle);

                    // PERSONAL TURNOVER CURRENT WEEK
                    Indicator indMyCAWeek = getPurchaseAmountByContactBetweenTwoDates(u, con, currentWeek.startdate, currentWeek.enddate, Label.LU_Dashboard_CA_Perso_Week);
                    
                    // PERSONAL TURNOVER CYCLE
                    Indicator indMyCACycle = getPurchaseAmountByContactBetweenTwoDates(u, con, currentCycle.startdate, currentCycle.enddate, Label.LU_Dashboard_CA_Perso_Cycle);
                    
                    // Add the Personnal KPI to the team KPI
                    // if (indTeamCAWeek != null && indTeamCAWeek.vDecimal1 != null && indMyCAWeek != null && indMyCAWeek.vDecimal1 != null) {
                    //     indTeamCAWeek.vDecimal1 += indMyCAWeek.vDecimal1;
                    // }
                    // if (indTeamCACycle != null && indTeamCACycle.vDecimal1 != null && indMyCACycle != null && indMyCACycle.vDecimal1 != null) {
                    //     indTeamCACycle.vDecimal1 += indMyCACycle.vDecimal1;
                    // }

                    // Add the KPI to the list to be displayed
                    // lIndicators.add(indTeamCAWeek);
                    // lIndicators.add(indTeamCACycle);
                    lIndicators.add(indMyCAWeek);
                    lIndicators.add(indMyCACycle);

                    // TEAM MEMBER ACTIVITY RATE CURRENT WEEK
                    Indicator indNumActWeek = getManagerGetActiveMembersBetweenTwoDates(u, con, lTeam, currentWeek.startdate, currentWeek.enddate, Label.LU_Dashboard_Number_Activ_Weeks);
                    if(indNumActWeek != null){
                        Indicator ind1 = new Indicator();
                        ind1.isNumber = true;
                        ind1.label = Label.LU_Dashboard_Team_Taus_Activity;
                        if (indNumActWeek.vDecimal1 == 0) {
                            ind1.vDecimal1 = 0;
                        } else {
                            ind1.vDecimal1 = (indNumActWeek.vDecimal1 == 0 ? 1 : indNumActWeek.vDecimal1) / lTeam.size(); //getTeamSize(con) ;
                        }
                        ind1.isPercentDecimal1 = true;
                        lIndicators.add(ind1);
                    }

                } else  { 

                    // PERSONAL TURNOVER CURRENT WEEK
                    lIndicators.add(getPurchaseAmountByContactBetweenTwoDates(u, con, currentWeek.startdate, currentWeek.enddate, Label.LU_Dashboard_CA_Perso_Week));

                    // PERSONAL TURNOVER CYCLE
                    lIndicators.add(getPurchaseAmountByContactBetweenTwoDates(u, con, currentCycle.startdate, currentCycle.enddate, Label.LU_Dashboard_CA_Perso_Cycle));
                    
                }
            }
            
        } else if (con.AccountCountryCode__c == 'ITA') { // For ITALY

            if (con.LU_TECH_ITA_IsDealer__c && !con.Is_Manager_Order_View__c) {
                lIndicators = getITADealerIndicators(u, con, currentCycle);
            } else if (con.LU_Is_Manager__c || con.Is_Manager_Order_View__c) {
                lIndicators = getITAManagerIndicators(u, con, currentCycle);
            }
        }

        return (lIndicators);
    }

/* ---------------------- BUSINESS METHODS ---------------------- */

    /* ITA DEALER KPIs */
    public static List<Indicator> getITADealerIndicators(User u, Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

        /* Variables */
        List<Indicator> lIndicators = new List<Indicator>();


        //Indicator 3 : Sales amount
        Indicator ind3 = getSalesAmount(u, con, currentCycle.startdate, currentCycle.enddate);
        if (ind3 != null) {
            lIndicators.add(ind3);
        }

        //Indicator 4 : Verified Sales amount
        Indicator ind4 = getVerifiedSalesAmount(u, con, currentCycle.startdate, currentCycle.enddate);
        if (ind4 != null) {
            lIndicators.add(ind4);
        }

        if(con.Title == 'Group Sales Consultant' || con.Title == 'Direttore di Filiale' || con.Title ==  'Direttore di Zona'){
            //lIndicators.add(getMonthTeamValidatedSalesAmount(u, con));
            //lIndicators.add(getMonthTeamInvoicedSalesAmount(u, con));
            
            Indicator ind5 = getITANewRecruitment(con);
            if (ind5 != null) {
                //JJE - 26/08/2021 - demande de fabrizio, ne plus mettre recrutement
                // lIndicators.add(ind5);
            }
        }

        return (lIndicators);
    }

    /* ITA MANAGER KPIs */
    public static List<Indicator> getITAManagerIndicators(User u, Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

        /* Variables */
        List<Indicator> lIndicators = new List<Indicator>();

        /* Get the team members of the manager */
        List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(u, con);
        List<Contact> lTeam = null;
        if (l_teamAccounts != null) {
            lTeam = [SELECT Id FROM Contact WHERE AccountId IN :l_teamAccounts AND LU_Out_Of_Business__c = false];
        } else {
            lTeam = [SELECT Id FROM Contact WHERE LU_Out_Of_Business__c = false AND (ReportsToId =: con.Id OR Parent_STH_Id__c =: con.Id)];
        }

        // Get Personnal KPI
        Indicator indPerso1 = getSalesAmount(u, con, currentCycle.startdate, currentCycle.enddate);
        Indicator indPerso2 = getVerifiedSalesAmount(u, con, currentCycle.startdate, currentCycle.enddate);
        if (!con.Title.contains('Filiale') && !con.Title.contains('Zona') ) {
            if (indPerso1 != null) {
                lIndicators.add(indPerso1);
            }
            if (indPerso2 != null) {
                lIndicators.add(indPerso2);
            }
        }

        //Indicator 5 : My Team Sales amount
        Indicator ind5 = getMyTeamSalesAmount(con, u, currentCycle.startdate, currentCycle.enddate);
        if (ind5 != null) {
            if (indPerso1 != null && indPerso1.vDecimal1 != null && ind5.vDecimal1 != null) {
                ind5.vDecimal1 += indPerso1.vDecimal1;
            }
            lIndicators.add(ind5);
        }

        //Indicator 6 : My Team Sales amount
        Indicator ind6 = getMyTeamValidatedSalesAmount(con, u, currentCycle.startdate, currentCycle.enddate);
        if (ind6 != null) {
            if (indPerso2 != null && indPerso2.vDecimal1 != null && ind6.vDecimal1 != null) {
                ind6.vDecimal1 += indPerso2.vDecimal1;
            }
            lIndicators.add(ind6);
        }

        /* ACTIVE MEMBER during the cycle */
        Indicator ind2 = getManagerGetActiveMembersBetweenTwoDates(u, con, lTeam, currentCycle.startdate, currentCycle.enddate, Label.LU_Dashboard_Title_ActiveMembers);
        if (ind2 != null) {
            lIndicators.add(ind2);
        }

        if(con.Title == 'Group Sales Consultant' || con.Title == 'Direttore di Filiale' || con.Title ==  'Direttore di Zona'){
            //Indicator 5 : Sales amount
            Indicator ind7 = getITANewRecruitment(con);
            if (ind7 != null) {
                lIndicators.add(ind7);
            }
        }

        //Aller chercher les métadatas pour voir si l'indicateur doit être affiché
        // On utilise la boucle de cette manière au cas où un indicateur n'a pas été renseigné dans le métédata (doit quand même être affiché par défaut)
        List<Indicator> lIndicatorsTKeep = new List<Indicator>();
        for(Indicator ind : lIndicators){
            Boolean toKeep = true;
            for(Affichage_KPI__mdt affichage : [SELECT Nom_du_KPI__c, Affiche__c FROM Affichage_KPI__mdt]){
                if(ind.labelAPIName == affichage.Nom_du_KPI__c && affichage.Affiche__c == false) {
                    toKeep = false;
                }
            }
            if(toKeep == true) lIndicatorsTKeep.add(ind);
        }
        return (lIndicatorsTKeep);
    }



    /* ---------------------- INDICATORS CALCULATION ---------------------- */

    public static Indicator getMonthTeamValidatedSalesAmount(User u,Contact con){
        
        List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(u, con);

        List<Contact> l_teamContacts = null;
        if (l_teamAccounts != null) {
            l_teamContacts = [SELECT Id FROM Contact WHERE AccountId IN :l_teamAccounts AND LU_Out_Of_Business__c = false];
        } else {
            l_teamContacts = [SELECT Id FROM Contact WHERE LU_Out_Of_Business__c = false AND (ReportsToId =: con.Id AND Parent_STH_Id__c =: con.Id)];
        }

        AggregateResult agr = null;
        // If the current user use the new order (line up order)
        if (u.LU_Use_New_Order_v2__c) {
            agr = [SELECT SUM(LU_Total_Amount_To_Pay__c)
                    FROM Order 
                    WHERE BillToContactId IN :l_teamContacts
                    AND LU_Invoice_Date__c = THIS_MONTH
                    AND (Status = :AppConstants.ORDER_STATUS_INVOICED
                        OR Status = :AppConstants.ORDER_STATUS_SHIPPED
                        OR Status = :AppConstants.ORDER_STATUS_PACKING)];
        } else {
            agr = [SELECT SUM(TotalPriceExclusiveOfTax__c)
                    FROM INV_Invoice__c 
                    WHERE Dealer__c IN :l_teamContacts
                    AND InvoiceDate__c = THIS_MONTH];
        }

        Decimal nb = (Decimal) agr.get('expr0');

        Indicator ind = new Indicator();
        ind.isNumber = true;
        ind.label = (gUsProfileName == AppConstants.PROFILE_ITA_SALESMANAGER || gUsProfileName == AppConstants.PROFILE_ITA_LUMANAGER) ? Label.LU_Month_team_Validated_Sales_Amount_DM : con.Title == 'Group Sales Consultant' ? Label.LU_Month_team_Validated_Sales_Amount_GSC : Label.LU_Month_team_Invoiced_Sales_Amount;
        ind.vDecimal1 = (nb != null ? nb : 0);
        ind.isCurrencyDecimal1 = true;

        return ind;
    }

    public static Indicator getMonthTeamInvoicedSalesAmount(User u, Contact con){

        List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(u, con);

        List<Contact> l_teamContacts = null;
        if (l_teamAccounts != null) {
            l_teamContacts = [SELECT Id FROM Contact WHERE AccountId IN :l_teamAccounts AND LU_Out_Of_Business__c = false];
        } else {
            l_teamContacts = [SELECT Id FROM Contact WHERE LU_Out_Of_Business__c = false AND (ReportsToId =: con.Id AND Parent_STH_Id__c =: con.Id)];
        }

        AggregateResult agr = null;

        // If the current user use the new order (line up order)
        if (u.LU_Use_New_Order_v2__c) {
            agr = [SELECT SUM(LU_TECH_UsedForMinAmount__c)
                    FROM OrderItem 
                    WHERE Order.BillToContactId IN :l_teamContacts
                    AND Order.EffectiveDate >= THIS_MONTH
                    AND LU_Child_Product__c = null
                    AND LU_Product_Type__c = 'Product'
                    AND ( Order.Status = 'Pending' OR Order.Status = 'Processing')];
        } else {
            agr = [SELECT SUM(AmountWihtoutTax__c)
                    FROM ORL_OrderLine__c 
                    WHERE Order__r.Dealer__c IN :l_teamContacts
                    AND Order__r.OrderDate__c >= THIS_MONTH
                    AND TECH_ArticleType__c != 'Child'
                    AND CatalogArticlesType__c = 'Product'
                    AND ( Order__r.Status__c = 'Pending' OR Order__r.Status__c = 'Processing')];
        }
        
        Decimal nb = (Decimal) agr.get('expr0');
        Indicator ind = new Indicator();
        ind.isNumber = true;
        ind.label = (gUsProfileName == AppConstants.PROFILE_ITA_SALESMANAGER || gUsProfileName == AppConstants.PROFILE_ITA_LUMANAGER) ? Label.LU_Month_team_Invoiced_Sales_Amount_DM : con.Title == 'Group Sales Consultant' ? Label.LU_Month_team_Invoiced_Sales_Amount_GSC : Label.LU_Month_team_Validated_Sales_Amount;
        ind.vDecimal1 = (nb != null ? nb : 0);
        ind.isCurrencyDecimal1 = true;

        return ind;
    }

    /* INDICATOR : PURCHASE AMOUNT BETWEEN TWO DATETIME BY CONTACT */
    public static Indicator getPurchaseAmountByContactBetweenTwoDates(User u, Contact con, Datetime startdate, Datetime enddate, String label) {

        /* Variables */
        Indicator ind = null;
        Decimal amount = 0;
        if(startdate == null || enddate == null){
            return ind;
        }
        Date fromDate = Date.newInstance(startdate.year(), startdate.month(), startdate.day());
        Date untilDate = Date.newInstance(enddate.year(), enddate.month(), enddate.day());
        AggregateResult[] groupedResults = null;

        // Retrieve the orders between the start date and enddate
        // If the current user use the new order (line up order)
        if (u.LU_Use_New_Order_v2__c) {
            if(con.AccountCountryCode__c == 'ITA'){
                groupedResults = [SELECT SUM(TotalAmount)
                                    FROM Order
                                    WHERE BillToContactId =: con.Id
                                    AND EffectiveDate >=: fromDate 
                                    AND EffectiveDate <=: untilDate
                                    AND Status != 'Draft' 
                                    AND Status != 'Archived'
                                    AND Status != 'Canceled'];
            }
            else if(con.AccountCountryCode__c == 'FRA'){
                groupedResults = [SELECT SUM(LU_Total_Amount_For_Valid_Base__c)
                                    FROM Order
                                    WHERE BillToContactId =: con.Id
                                    AND EffectiveDate >=: fromDate 
                                    AND EffectiveDate <=: untilDate
                                    AND Status != 'Draft' 
                                    AND Status != 'Archived'
                                    AND Status != 'Canceled'];
            }
        } else { // If the current user use the old order tunnel
            groupedResults = [SELECT SUM(TECH_TotalPrice__c)
                                FROM ORD_Order__c
                                WHERE Dealer__c = :con.Id
                                AND OrderDate__c >=: startdate 
                                AND OrderDate__c <=: enddate 
                                AND (Status__c = 'Shipped​' OR Status__c = 'Pending' OR Status__c = 'Processed')];
        }

        // Manage the results
        for (AggregateResult ar : groupedResults)  {
            Decimal calc = (Decimal)ar.get('expr0');
            amount = (calc != null ? calc : 0);
        }

        if (amount != null) {
            ind = new Indicator();
            ind.isNumber = true;
            ind.label = label;//Label.LU_Dashboard_Title_PurchaseAmount
            ind.vDecimal1 = amount;
            ind.isCurrencyDecimal1 = true;
        }

        return (ind);

    }

    /* INDICATOR : PURCHASE AMOUNT BETWEEN TWO DATETIME BY CONTACT FOR A SPECIFIC BRAND*/
    /* NOT USED ANYMORE */
    // public static Decimal getPurchaseAmountByBrandByContactBetweenTwoDates(User u, Contact con, String brand, Datetime startdate, Datetime enddate) {

    //     /* Variables */
    //     Decimal amount = 0;
    //     Date fromDate = Date.newInstance(startdate.year(), startdate.month(), startdate.day());
    //     Date untilDate = Date.newInstance(enddate.year(), enddate.month(), enddate.day());
    //     AggregateResult[] groupedResults = null;

    //     // Retrieve the orders between the start date and enddate
    //     // If the current user use the new order (line up order)
    //     if (u.LU_Use_New_Order_v2__c) {
    //         groupedResults = [SELECT SUM(TotalAmount)
    //                             FROM Order
    //                             WHERE BillToContactId =: con.Id
    //                             AND EffectiveDate >=: fromDate 
    //                             AND EffectiveDate <=: untilDate
    //                             AND Status != 'Draft' 
    //                             AND Status != 'Archived'
    //                             AND Status != 'Canceled'];
    //     } else { // If the current user use the old order
    //         groupedResults = [SELECT SUM(TECH_TotalPrice__c)
    //                             FROM ORD_Order__c
    //                             WHERE Dealer__c =: con.Id
    //                             AND OrderDate__c >=: startdate 
    //                             AND OrderDate__c <=: enddate
    //                             AND Status__c = 'Shipped​'];
    //     }

    //     // Manage the results
    //     for (AggregateResult ar : groupedResults)  {
    //         Decimal calc = (Decimal)ar.get('expr0');
    //         amount = (calc != null ? calc : 0);
    //     }

    //     return (amount);

    // }

    /* INDICATOR : TARGET REACH PROGRESS ON PURCHASE AMOUNT BY CONTACT */
    /* NOT USED ANYMORE */
    // public static Indicator getPurchaseTargetReachByContact(Contact con, Decimal purchaseAmount) {

    //     /* Variables */
    //     Indicator ind = null;

    //     // If neither the target and purchase amount is not empty 
    //     if (con.LU_Current_Cycle_Target__c != null && purchaseAmount != null) {

    //         ind = new Indicator();
    //         ind.isNumber = false;
    //         ind.isDonught = true;
    //         ind.label = Label.LU_Dashboard_Title_SalesTarget + ' ' + con.LU_Current_Cycle_Target__c + '€';
    //         ind.vDecimal1 = purchaseAmount; // Purchase amount
    //         ind.vDecimal1Txt = ' €';
    //         ind.isCurrencyDecimal1 = true;
    //         ind.vDecimal2 = con.LU_Current_Cycle_Target__c; // Target
    //         ind.vDecimal2Txt = ' €';
    //         ind.isCurrencyDecimal2 = true;
    //         ind.vDecimal3 = con.LU_Current_Cycle_Target__c - purchaseAmount; // Amount left to do
    //         ind.vDecimal3Txt = ' €';
    //         ind.isCurrencyDecimal4 = false;
    //         ind.vDecimal4 = ((purchaseAmount / con.LU_Current_Cycle_Target__c) * 100).setScale(0); // Amount left to do
    //         ind.vDecimal4Txt = '%';
    //         ind.vString1 = 'chartPurchaseTargetReached slds-m-around_medium';
    //         ind.vString2 = 'chartPurchaseTargetReached';

    //     }

    //     return (ind);

    // }


    /* INDICATOR : BY MANAGER, ACTIVE MEMBERS OF TEAM BETWEEN TWO DATES */
    public static Indicator getManagerGetActiveMembersBetweenTwoDates(User u, Contact con, List<Contact> lTeam, Datetime startdate, Datetime enddate, String label) {

        /* Variables */
        Indicator ind = null;
        Decimal nb = 0;
        if(startdate == null || enddate == null){
            return ind;
        }
        Date fromDate = Date.newInstance(startdate.year(), startdate.month(), startdate.day());
        Date untilDate = Date.newInstance(enddate.year(), enddate.month(), enddate.day());

        AggregateResult[] groupedResults = null;

        if (con.AccountCountryCode__c == 'FRA') {
            
            // If the current user use the new order (line up order)
            if (u.LU_Use_New_Order_v2__c) {
                groupedResults = [SELECT COUNT_DISTINCT(BillToContactId)
                                        FROM Order
                                        WHERE BillToContactId in: lTeam
                                        AND EffectiveDate >=: fromDate 
                                        AND EffectiveDate <=: untilDate
                                        AND Status != 'Draft' 
                                        AND Status != 'Archived'
                                        AND Status != 'Canceled'];
            } else { // If the current user use the old order
                groupedResults = [SELECT COUNT_DISTINCT(Dealer__c)
                                    FROM ORD_Order__c
                                    WHERE Dealer__c in: lTeam
                                    AND OrderDate__c >=: startdate
                                    AND OrderDate__c <=: enddate
                                    AND (Status__c = 'Shipped' OR Status__c = 'Pending' OR Status__c = 'Processing')];
            }
            
            for (AggregateResult ar : groupedResults)  {
                Decimal calc = (Decimal)ar.get('expr0');
                nb = (calc != null ? calc : 0);
            }
        } else if (con.AccountCountryCode__c == 'ITA') { // Italy

            groupedResults = [SELECT COUNT_DISTINCT(Id)
                                    FROM Contact
                                    WHERE Id in: lTeam
                                    AND Last_invoiced_order_date__c >=: fromDate
                                    AND Last_invoiced_order_date__c <=: untilDate
                                    AND LU_Out_Of_Business__c = false ];
            for (AggregateResult ar : groupedResults)  {
                Decimal calc = (Decimal)ar.get('expr0');
                nb = (calc != null ? calc : 0);
            }
        }
        
        
        // If an amount is calculated
        if (nb != null) {
            ind = new Indicator();
            ind.isText = true;
            ind.label = label; //Label.LU_Dashboard_Title_ActiveMembers;
            ind.vString1 = nb + ' / ' + lTeam.size();
            ind.vDecimal1 = (nb == null ? 0 : nb );
            ind.isNbDecimal1 = true;
        }

        return (ind);
    }

    /* INDICATOR : BY MANAGER, TURNOVER OF THE TEAM BETWEEN TWO DATES */
    public static Indicator getManagerGetTeamTurnoverBetweenTwoDates(User u, Contact con, List<Contact> lTeam, Datetime startdate, Datetime enddate, String label) {

        /* Variables */
        Indicator ind = null;
        Decimal amount = 0;
        if(startdate == null || enddate == null){
            return null;
        }
        Date fromDate = Date.newInstance(startdate.year(), startdate.month(), startdate.day());
        Date untilDate = Date.newInstance(enddate.year(), enddate.month(), enddate.day());
        AggregateResult[] groupedResults = null;

        // Retrieve the orders of the manager + his team between the start date and enddate
        // If the current user use the new order (line up order)
        if (u.LU_Use_New_Order_v2__c) {
            groupedResults = [SELECT SUM(TotalAmount) ca
                                FROM Order
                                WHERE BillToContactId in: lTeam
                                AND EffectiveDate >=: fromDate 
                                AND EffectiveDate <=: untilDate
                                AND Status != 'Draft' 
                                AND Status != 'Archived'
                                AND Status != 'Canceled'];
        } else { // If the current user use the old order
            groupedResults = [SELECT SUM(TECH_TotalPrice__c) ca
                                FROM ORD_Order__c
                                WHERE Dealer__c in: lTeam
                                AND OrderDate__c >=: startdate
                                AND OrderDate__c <=: enddate
                                AND (Status__c = 'Shipped​' OR Status__c = 'Pending' OR Status__c = 'Processed')];
        }

        // Manage the results
        for (AggregateResult ar : groupedResults)  {
            Decimal calc = (Decimal)ar.get('ca');
            amount = (calc != null ? calc : 0);
        }
        
        // If an amount is calculated
        if (amount != null) {
            ind = new Indicator();
            ind.isNumber = true;
            ind.label = label;
            ind.vDecimal1 = amount;
            ind.isCurrencyDecimal1 = true;
        }

        return (ind);
    }

    /* TEAM : GET TEAM SIZE OF THE CONTACT IN PARAMETER */
    /* NOT USED ANYMORE */
    // public static Integer getTeamSize(Contact con) {

    //     AggregateResult ar = [SELECT COUNT(Id) nb
    //                             FROM Contact
    //                            WHERE ReportsToId = :con.Id
    //                            AND LU_Out_Of_Business__c = false];
        
    //     return (Integer) ar.get('nb');
    // }


    /* INDICATOR : Sales Amount - venduto personale*/
    public static Indicator getSalesAmount(User u, Contact con, Datetime startdate, Datetime enddate) {

        Indicator ind = null;

        if(startdate == null || enddate == null){
            return null;
        }
        Date fromDate = Date.newInstance(startdate.year(), startdate.month(), startdate.day());
        Date untilDate = Date.newInstance(enddate.year(), enddate.month(), enddate.day());

        AggregateResult invoice_ar = null;
        // If the current user use the new order (line up order)
        if (u.LU_Use_New_Order_v2__c) {
            invoice_ar = [SELECT SUM(LU_TECH_AmountForMinimumOrder__c)
                            FROM Order 
                            WHERE BillToContactId = :con.Id
                            AND LU_Invoice_Date__c >= :Date.valueOf(startdate)
                            AND LU_Invoice_Date__c < :Date.valueOf(enddate)
                            AND (Status =: AppConstants.ORDER_STATUS_INVOICED 
                                OR Status =: AppConstants.ORDER_STATUS_SHIPPED 
                                OR Status =: AppConstants.ORDER_STATUS_PACKING)];
        } else {
            invoice_ar = [SELECT SUM(TotalPriceExclusiveOfTax__c)
                            FROM INV_Invoice__c 
                            WHERE Dealer__c = :con.Id
                            AND InvoiceDate__c >= :fromDate
                            AND InvoiceDate__c < :untilDate];
        }

        ind = new Indicator();
        ind.isNumber = true;
        ind.isDonught = false;
        ind.label = Label.LU_Dashboard_Sales_Amount;
        ind.labelAPIName = 'LU_Dashboard_Sales_Amount';
        ind.vDecimal1 = (invoice_ar.get('expr0') == null ? (Decimal) 0 : (Decimal) invoice_ar.get('expr0') );
        ind.vDecimal1Txt = ' €';
        ind.isCurrencyDecimal1 = true;

        return (ind);
    }

    /* INDICATOR : Verified Sales Amount - digitato personale */
    public static Indicator getVerifiedSalesAmount(User u, Contact con, Datetime startdate, Datetime enddate) {

        Indicator ind = null;

        if(startdate == null || enddate == null){
            return null;
        }

        AggregateResult orderLine_ar = null;

        // If the current user use the new order (line up order)
        if (u.LU_Use_New_Order_v2__c) {
            orderLine_ar = [SELECT SUM(LU_TECH_AmountForMinimumOrder__c)
            FROM Order 
            WHERE BillToContactId = :con.Id
            AND EffectiveDate >= :Date.valueOf(startdate)
            AND EffectiveDate < :Date.valueOf(enddate)
            AND (Status NOT IN ('Archived', 'Draft'))];
        } else {
            orderLine_ar = [SELECT SUM(AmountWihtoutTax__c)
                            FROM ORL_OrderLine__c 
                            WHERE Order__r.Dealer__c = :con.Id
                            AND Order__r.OrderDate__c >= :startdate
                            AND Order__r.OrderDate__c < :enddate
                            AND TECH_ArticleType__c != 'Child'
                            AND CatalogArticlesType__c = 'Product'
                            AND ( Order__r.Status__c = 'Pending' OR Order__r.Status__c = 'Processing') ];
        }

        ind = new Indicator();
        ind.isNumber = true;
        ind.isDonught = false;
        ind.label = Label.LU_Dashboard_Verified_Sales_Amount;
        ind.labelAPIName = 'LU_Dashboard_Verified_Sales_Amount';
        ind.vDecimal1 = (orderLine_ar.get('expr0') == null ? (Decimal) 0 : (Decimal) orderLine_ar.get('expr0') );
        ind.vDecimal1Txt = ' €';
        ind.isCurrencyDecimal1 = true;

        return (ind);
    }

    /* INDICATOR : My Team Sales Amount */
    public static Indicator getMyTeamValidatedSalesAmount(Contact con, User u, Datetime startdate, Datetime enddate) {

        Indicator ind = null;

        if(startdate == null || enddate == null){
            return null;
        }

        List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(u, con);

        List<Contact> l_teamContacts = null;
        if (l_teamAccounts != null) {
            l_teamContacts = [SELECT Id FROM Contact WHERE AccountId IN :l_teamAccounts AND LU_Out_Of_Business__c = false];
        } else {
            l_teamContacts = [SELECT Id FROM Contact WHERE LU_Out_Of_Business__c = false AND (ReportsToId =: con.Id AND Parent_STH_Id__c =: con.Id)];
        }

        AggregateResult orderLine_ar = null;

        // If the current user use the new order (line up order)
        if (u.LU_Use_New_Order_v2__c) {
            orderLine_ar = [SELECT SUM(LU_TECH_UsedForMinAmount__c)
                            FROM OrderItem 
                            WHERE Order.BillToContactId IN :l_teamContacts
                            AND Order.EffectiveDate >= :Date.valueOf(startdate)
                            AND Order.EffectiveDate < :Date.valueOf(enddate)
                            AND LU_Child_Product__c = null
                            AND LU_Product_Type__c = 'Product'
                            AND ( Order.Status = 'Pending' OR Order.Status = 'Processing' OR Order.Status = 'Invoiced')];
        } else {
            orderLine_ar = [SELECT SUM(AmountWihtoutTax__c)
                            FROM ORL_OrderLine__c 
                            WHERE Order__r.Dealer__c IN :l_teamContacts
                            AND Order__r.OrderDate__c >= :startdate
                            AND Order__r.OrderDate__c < :enddate
                            AND TECH_ArticleType__c != 'Child'
                            AND CatalogArticlesType__c = 'Product'
                            AND ( Order__r.Status__c = 'Pending' OR Order__r.Status__c = 'Processing') ];
        }

        ind = new Indicator();
        ind.isNumber = true;
        ind.isDonught = false;
        ind.label = (gUsProfileName == AppConstants.PROFILE_ITA_SALESMANAGER || gUsProfileName == AppConstants.PROFILE_ITA_LUMANAGER) ? Label.LU_Dashboard_MyTeam_VerfiiedSales_Amount_DM : con.Title == 'Group Sales Consultant' ? Label.LU_Dashboard_MyTeam_VerfiiedSales_Amount_GSC : Label.LU_Dashboard_MyTeam_VerfiiedSales_Amount;
        ind.labelAPIName = (gUsProfileName == AppConstants.PROFILE_ITA_SALESMANAGER || gUsProfileName == AppConstants.PROFILE_ITA_LUMANAGER) ? 'LU_Dashboard_MyTeam_VerfiiedSales_Amount_DM' : con.Title == 'Group Sales Consultant' ? 'LU_Dashboard_MyTeam_VerfiiedSales_Amount_GSC' : 'LU_Dashboard_MyTeam_VerfiiedSales_Amount';
        ind.vDecimal1 = (orderLine_ar.get('expr0') == null ? (Decimal) 0 : (Decimal) orderLine_ar.get('expr0') );
        ind.vDecimal1Txt = ' €';
        ind.isCurrencyDecimal1 = true;

        return (ind);
    }

    /* INDICATOR : My Team Sales Amount */
    public static Indicator getMyTeamSalesAmount(Contact con, User u, Datetime startdate, Datetime enddate) {

        Indicator ind = null;

        if(startdate == null || enddate == null){
            return null;
        }

        Date fromDate = Date.newInstance(startdate.year(), startdate.month(), startdate.day());
        Date untilDate = Date.newInstance(enddate.year(), enddate.month(), enddate.day());

        List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(u, con);

        List<Contact> l_teamContacts = null;
        if (l_teamAccounts != null) {
            l_teamContacts = [SELECT Id FROM Contact WHERE AccountId IN :l_teamAccounts AND LU_Out_Of_Business__c = false];
        } else {
            l_teamContacts = [SELECT Id FROM Contact WHERE LU_Out_Of_Business__c = false AND (ReportsToId =: con.Id AND Parent_STH_Id__c =: con.Id)];
        }

        AggregateResult orderLine_ar = null;
        // If the current user use the new order (line up order)
        if (u.LU_Use_New_Order_v2__c) {
            orderLine_ar = [SELECT SUM(LU_TECH_AmountForMinimumOrder__c)
                            FROM Order 
                            WHERE BillToContactId in :l_teamContacts
                            AND LU_Invoice_Date__c >= :fromDate
                            AND LU_Invoice_Date__c < :untilDate
                            AND (Status = :AppConstants.ORDER_STATUS_INVOICED
                                OR Status = :AppConstants.ORDER_STATUS_SHIPPED
                                OR Status = :AppConstants.ORDER_STATUS_PACKING)];
        } else {
            orderLine_ar = [SELECT SUM(TotalPriceExclusiveOfTax__c)
                            FROM INV_Invoice__c 
                            WHERE Dealer__c in :l_teamContacts
                            AND InvoiceDate__c >= :fromDate
                            AND InvoiceDate__c < :untilDate];
        }

        ind = new Indicator();
        ind.isNumber = true;
        ind.isDonught = false;
        ind.label = (gUsProfileName == AppConstants.PROFILE_ITA_SALESMANAGER || gUsProfileName == AppConstants.PROFILE_ITA_LUMANAGER) ? Label.LU_Dashboard_MyTeam_Sales_Amount_DM : con.Title == 'Group Sales Consultant' ? Label.LU_Dashboard_MyTeam_Sales_Amount_GSC : Label.LU_Dashboard_MyTeam_Sales_Amount;
        ind.labelAPIName = (gUsProfileName == AppConstants.PROFILE_ITA_SALESMANAGER || gUsProfileName == AppConstants.PROFILE_ITA_LUMANAGER) ? 'LU_Dashboard_MyTeam_Sales_Amount_DM' : con.Title == 'Group Sales Consultant' ? 'LU_Dashboard_MyTeam_Sales_Amount_GSC' : 'LU_Dashboard_MyTeam_Sales_Amount';
        ind.vDecimal1 = (orderLine_ar.get('expr0') == null ? (Decimal) 0 : (Decimal) orderLine_ar.get('expr0') );
        ind.vDecimal1Txt = ' €';
        ind.isCurrencyDecimal1 = true;

        return (ind);
    }

    public static Indicator getITANewRecruitment(Contact con){
        
        Indicator ind = new Indicator();
        ind.isNumber = false;
        ind.isText = true;
        ind.isDonught = false;
        ind.label = Label.LU_Dashboard_New_Recruitment;
        ind.labelAPIName = 'LU_Dashboard_New_Recruitment';
        ind.vString1 = con.NB_Recruits_Level1__c == null ? '0' : con.NB_Recruits_Level1__c + '';
        ind.vDecimal1 = con.NB_Recruits_Level1__c == null ? 0 : con.NB_Recruits_Level1__c;
        ind.vDecimal1Txt = '';
        ind.isNbDecimal1 = true;

        return (ind);
    }
}


/* BACKUP OF INDICATORS DONE, BUT NOT USED ANYMORE */
    // public static Indicator getFRACaPersoCurrentCycle(Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

    //     AggregateResult ar = [SELECT SUM(TECH_TotalPrice__c) ca
    //                             FROM ORD_Order__c
    //                            WHERE Dealer__c = :con.Id
    //                              AND OrderDate__c >= :currentCycle.startdate
    //                              AND OrderDate__c <= :currentCycle.enddate
    //                              AND Status__c = 'Shipped​'];
        
    //     Indicator ind1 = new Indicator();
    //     ind1.isNumber = true;
    //     ind1.label = Label.LU_Dashboard_CA_Perso_Cycle;
    //     ind1.vDecimal1 = (ar.get('ca') == null ? 0 : (Decimal) ar.get('ca') );
    //     ind1.isCurrencyDecimal1 = true;

    //     return ind1;
    // }

    // public static Indicator getFRACaHomeCare(Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

    //     AggregateResult ar = [SELECT SUM(Amount__c) ca
    //                             FROM ORL_OrderLine__c
    //                            WHERE Order__r.Dealer__c = :con.Id
    //                              AND Order__r.OrderDate__c >= :currentCycle.startdate
    //                              AND Order__r.OrderDate__c <= :currentCycle.enddate
    //                              AND Article__r.BrandTerritory__c = 'Home Care'
    //                              AND Order__r.Status__c = 'Shipped​'];
        
    //     Indicator ind1 = new Indicator();
    //     ind1.isNumber = true;
    //     ind1.label = Label.LU_Dashboard_CA_HomeCare;
    //     ind1.vDecimal1 = (ar.get('ca') == null ? 0 : (Decimal) ar.get('ca') );
    //     ind1.isCurrencyDecimal1 = true;

    //     return ind1;
    // }

    // public static Indicator getFRACaCosmetique(Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

    //     AggregateResult ar = [SELECT SUM(Amount__c) ca
    //                             FROM ORL_OrderLine__c
    //                            WHERE Order__r.Dealer__c = :con.Id
    //                              AND Order__r.OrderDate__c >= :currentCycle.startdate
    //                              AND Order__r.OrderDate__c <= :currentCycle.enddate
    //                              AND Article__r.BrandTerritory__c = 'Beauty Care'
    //                              AND Order__r.Status__c = 'Shipped​'];
        
    //     Indicator ind1 = new Indicator();
    //     ind1.isNumber = true;
    //     ind1.label = Label.LU_Dashboard_CA_Cosmetique;
    //     ind1.vDecimal1 = (ar.get('ca') == null ? 0 : (Decimal) ar.get('ca') );
    //     ind1.isCurrencyDecimal1 = true;

    //     return ind1;
    // }

    // public static Indicator getFRACaPersoCurrentWeek(Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

    //     AggregateResult ar = [SELECT SUM(TECH_TotalPrice__c) ca
    //                             FROM ORD_Order__c
    //                            WHERE Dealer__c = :con.Id
    //                              AND OrderDate__c = THIS_WEEK
    //                              AND Status__c = 'Shipped​'];
        
    //     Indicator ind1 = new Indicator();
    //     ind1.isNumber = true;
    //     ind1.label = Label.LU_Dashboard_CA_Perso_Week;
    //     ind1.vDecimal1 = (ar.get('ca') == null ? 0 : (Decimal) ar.get('ca') );
    //     ind1.isCurrencyDecimal1 = true;

    //     return ind1;
    // }

    // public static Indicator getFRAOrderAmountCurrentCycle(Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

    //     AggregateResult ar = [SELECT count(Id) nb
    //                             FROM ORD_Order__c
    //                            WHERE Dealer__c = :con.Id
    //                              AND OrderDate__c >= :currentCycle.startdate
    //                              AND OrderDate__c <= :currentCycle.enddate
    //                              AND Status__c = 'Shipped​'];
        
    //     Indicator ind1 = new Indicator();
    //     ind1.isNumber = true;
    //     ind1.label = Label.LU_Dashboard_Amount_Order_Cycle;
    //     ind1.vDecimal1 = (ar.get('nb') == null ? 0 : (Decimal) ar.get('nb') );
    //     ind1.isCurrencyDecimal1 = true;

    //     return ind1;
    // }

    // public static Indicator getFRACaEquipeCurrentDay(Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

    //     AggregateResult ar = [SELECT SUM(TECH_TotalPrice__c) ca
    //                             FROM ORD_Order__c
    //                            WHERE Dealer__r.ReportsToId = :con.Id
    //                              AND OrderDate__c = TODAY
    //                              AND Status__c = 'Shipped​'];
        
    //     Indicator ind1 = new Indicator();
    //     ind1.isNumber = true;
    //     ind1.label = Label.LU_Dashboard_CA_Team_Day;
    //     ind1.vDecimal1 = (ar.get('ca') == null ? 0 : (Decimal) ar.get('ca') );
    //     ind1.isCurrencyDecimal1 = true;

    //     return ind1;
    // }

    // public static Indicator getFRAAmountOrderEquipeCurrentDay(Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

    //     AggregateResult ar = [SELECT Count(Id) ca
    //                             FROM ORD_Order__c
    //                            WHERE Dealer__r.ReportsToId = :con.Id
    //                              AND OrderDate__c = TODAY
    //                              AND Status__c = 'Shipped​'];
        
    //     Indicator ind1 = new Indicator();
    //     ind1.isNumber = true;
    //     ind1.label = Label.LU_Dashboard_Amount_Order_Team_Day;
    //     ind1.vDecimal1 = (ar.get('ca') == null ? 0 : (Decimal) ar.get('ca') );
    //     ind1.isNbDecimal1 = true;

    //     return ind1;
    // }

    // public static Indicator getFRANumberActivWeeks(Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

    //     AggregateResult ar = [SELECT COUNT(Dealer__c) nb
    //                             FROM ORD_Order__c
    //                            WHERE Dealer__r.ReportsToId = :con.Id
    //                              AND OrderDate__c = THIS_WEEK
    //                              AND Status__c = 'Shipped​'];
        
    //     Indicator ind1 = new Indicator();
    //     ind1.isNumber = true;
    //     ind1.label = Label.LU_Dashboard_Number_Activ_Weeks;
    //     ind1.vDecimal1 = (ar.get('nb') == null ? 0 : (Decimal) ar.get('nb') );
    //     ind1.isNbDecimal1 = true;

    //     return ind1;
    // }

    // public static Indicator getFRACaEquipeCurrentWeek(User u, Contact con, AP1001_Cycle_Utils.CycleInfo currentCycle) {

    //     AggregateResult ar = [SELECT SUM(TECH_TotalPrice__c) ca
    //                             FROM ORD_Order__c
    //                            WHERE Dealer__r.ReportsToId = :con.Id
    //                              AND OrderDate__c = THIS_WEEK
    //                              AND Status__c = 'Shipped​'];
        
    //     Indicator ind1 = new Indicator();
    //     ind1.isNumber = true;
    //     ind1.label = Label.LU_Dashboard_CA_Team_Week;
    //     ind1.vDecimal1 = (ar.get('ca') == null ? 0 : (Decimal) ar.get('ca') );
    //     ind1.isCurrencyDecimal1 = true;

    //     return ind1;
    // }