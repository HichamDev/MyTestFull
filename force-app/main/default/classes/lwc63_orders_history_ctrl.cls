public without sharing class lwc63_orders_history_ctrl {

    @AuraEnabled
    public static void updateOrderStatus(Id orderId, String status){
        List<Order> orders = [SELECT Id, Status FROM Order WHERE Id = :orderId];
        if(orders.size() > 0){
            orders[0].Status = status;
            update orders[0];
        }
    }
	
    @AuraEnabled
    public static List<Order> getOrders(String filters){

        Map<String, List<String>> m_filters = null;
        
        if(filters != null){
            m_filters = (Map<String, List<String>>)JSON.deserialize(filters, Map<String, List<String>>.class);
        }

        User us = [SELECT Id, TECH_MergeContactID__c FROM User WHERE Id = :UserInfo.getUserId()];
        String idContact = us.TECH_MergeContactID__c;

        String userCountry = lwc63_orders_history_ctrl.getUserCountry();

        Contact con = lwc63_orders_history_ctrl.getContact();
        String contactId = con.Id;

        List<Contact> l_myTeam = null;
        if(userCountry == 'ITA' && con.LU_Is_Manager__c){
            l_myTeam = [SELECT Id FROM Contact WHERE Parent_STH_Id__c = :us.TECH_MergeContactID__c OR ReportsToId = :us.TECH_MergeContactID__c];
        }
        else if(userCountry == 'FRA' && con.LU_Is_Manager__c){
            List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(us, con);
            
            if(l_teamAccounts != null && !l_teamAccounts.isEmpty()){
                l_myTeam = [SELECT Id FROM Contact WHERE AccountId IN :l_teamAccounts];
            }
            else {
                if (con.AccountCountryCode__c == 'FRA' && con.Contact_Type__c == 'Leader') {
                    l_myTeam = [SELECT Id FROM Contact WHERE Parent_STH_Id__c = :us.TECH_MergeContactID__c OR Parent_STH_Id__r.Parent_STH_Id__c = :us.TECH_MergeContactID__c OR Id = :us.TECH_MergeContactID__c];
                } 
                else {
                    l_myTeam = [SELECT Id FROM Contact WHERE Parent_STH_Id__c = :us.TECH_MergeContactID__c OR ReportsToId = :us.TECH_MergeContactID__c];
                }
            }
        }

        AP1001_Cycle_Utils.CycleInfo currentCycle = AP1001_Cycle_Utils.getCurrentCycleByUser(UserInfo.getUserId());
        // Get the cycle before the current one
        Commercial_Periods__mdt previousCycle = AP1001_Cycle_Utils.getUserPreviousCycles(UserInfo.getUserId()).get(1);

        Date currentCycleStartDate;
        Date currentCycleEndDate;
        Date previousCycleStartDate;
        Date previousCycleEndDate;
        if(currentCycle != null && currentCycle.startdate != null){
            currentCycleStartDate = Date.newinstance(currentCycle.startdate.year(), currentCycle.startdate.month(), currentCycle.startdate.day());
        }
        if(currentCycle != null && currentCycle.enddate != null){
            currentCycleEndDate = Date.newinstance(currentCycle.enddate.year(), currentCycle.enddate.month(), currentCycle.enddate.day());
        }
        if(previousCycle != null && previousCycle.Startdate__c != null){
            previousCycleStartDate = Date.newinstance(previousCycle.Startdate__c.year(), previousCycle.Startdate__c.month(), previousCycle.Startdate__c.day());
        }
        if(previousCycle != null && previousCycle.Enddate__c != null){
            previousCycleEndDate = Date.newinstance(previousCycle.Enddate__c.year(), previousCycle.Enddate__c.month(), previousCycle.Enddate__c.day());
        }
        
        String whereStr = '';
        String strTimePeriod = '';
        String strOrderStatus = '';
        String strOrderType = '';
        String strForWho = '';
        String strInvoiceStatus = '';
        Date t = System.today();
        List<Account> laccountIds = new List<Account>();
        List<String> lcontactIds = new List<String>();

        if(m_filters != null){
            for (String filter : m_filters.keyset()) {
                List<String> values = m_filters.get(filter);

                if (filter == 'timePeriod') {
                    for(String s : values){
                        System.debug('date demandée : ' + s);
                        if(strTimePeriod != ''){
                            strTimePeriod += ' OR ';
                        }
                        
                        if(s == Label.LU_Order_Filter_Time_This_Day){
                            strTimePeriod += 'EffectiveDate = TODAY';
                        }
                        else if(s == Label.LU_Order_Filter_Time_This_Two_Days){
                            strTimePeriod += '(EffectiveDate = TODAY OR EffectiveDate = YESTERDAY)';
                        }
                        else if(s == Label.LU_Order_Filter_Time_Period_this_week){
                            strTimePeriod += 'EffectiveDate = THIS_WEEK';
                        }
                        else if(s == Label.LU_Order_Filter_Time_Period_this_month){
                            strTimePeriod += 'EffectiveDate = THIS_MONTH';
                        }
                        else if(s == Label.LU_Order_Filter_Time_Period_this_cycle){
                            strTimePeriod += '( EffectiveDate >= :currentCycleStartDate AND EffectiveDate < :currentCycleEndDate )';
                        }
                        else if(s == Label.LU_Order_Filter_Time_Period_last_week){
                            strTimePeriod += 'EffectiveDate = LAST_WEEK';
                        }
                        else if(s == Label.LU_Order_Filter_Time_Period_last_month){
                            strTimePeriod += 'EffectiveDate = LAST_MONTH';
                        }
                        else if(s == Label.LU_Order_Filter_Time_Period_last_cycle){
                            strTimePeriod += '( EffectiveDate >= :previousCycleStartDate AND EffectiveDate < :previousCycleEndDate )';
                        }
                        else if(s != null && s.contains('week')){ // T1680 récupérer la date courante si filtre custom sélectionné
                            String endperiod = s.substring(14, 24);
                            strTimePeriod += '( EffectiveDate >= ' ;
                            strTimePeriod += s.substring(6, 10) + '-' + s.substring(3, 5) + '-' + s.substring(0, 2) ;
                            strTimePeriod += ' AND EffectiveDate <= ' ;
                            strTimePeriod += endperiod.substring(6, 10) + '-' + endperiod.substring(3, 5) + '-' + endperiod.substring(0, 2) + ' )';
                        }
                        else if(s != null && s.contains('month')){ // T1680 récupérer la date courante si filtre custom sélectionné
                            String endperiod = s.substring(15, 25);
                            strTimePeriod += '( EffectiveDate >= ' ;
                            strTimePeriod += s.substring(6, 10) + '-' + s.substring(3, 5) + '-' + s.substring(0, 2) ;
                            strTimePeriod += ' AND EffectiveDate <= ' ;
                            strTimePeriod += endperiod.substring(6, 10) + '-' + endperiod.substring(3, 5) + '-' + endperiod.substring(0, 2) + ' )';
                        }
                        else if(s != null && s.contains('cycle')){ // T1680 récupérer la date courante si filtre custom sélectionné
                            String endperiod = s.substring(15, 25);
                            strTimePeriod += '( EffectiveDate >= ' ;
                            strTimePeriod += s.substring(6, 10) + '-' + s.substring(3, 5) + '-' + s.substring(0, 2) ;
                            strTimePeriod += ' AND EffectiveDate <= ' ;
                            strTimePeriod += endperiod.substring(6, 10) + '-' + endperiod.substring(3, 5) + '-' + endperiod.substring(0, 2) + ' )';
                        }
                        else if(strTimePeriod != ''){
                            strTimePeriod = strTimePeriod.substring(0,strTimePeriod.length() - 4);
                        }
                    }

                    if (strTimePeriod != '') {
                        strTimePeriod = ' ( ' + strTimePeriod + ' ) ';
                    }
                }
                else if (filter == 'orderStatus') {
                    for(String s : values){
                        if(strOrderStatus != ''){
                            strOrderStatus += ' OR ';
                        }
                        if(s == Label.LU_Order_Filter_Order_Type_day_order) {
                            
                            strOrderStatus += '( LU_TECH_Order_Date__c >= :t)';
                        } else if(s == Label.LU_Order_Filter_Order_Status_Draft){
                            strOrderStatus += 'Status = \'Draft\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Status_Invoiced){
                            strOrderStatus += 'Status = \'Invoiced\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Status_Sent_Orders){
                            strOrderStatus += 'Status = \'Pending\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Status_Processing_Orders){
                            strOrderStatus += 'Status = \'Invoicing\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Status_Pending){
                            strOrderStatus += 'Status = \'Pending\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Status_Processing){
                            strOrderStatus += 'Status = \'Processing\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Status_Shipped){
                            strOrderStatus += 'Status = \'Shipped\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Status_Blocked){
                            strOrderStatus += 'Status = \'Blocked\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Type_draft){
                            strOrderStatus += 'Status = \'Draft\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Type_validated){
                            strOrderStatus += 'Status = \'Pending\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Status_Cancelled){
                            strOrderStatus += 'Status = \'Cancelled\'';
                        } else if(s == Label.LU_Order_Filter_Order_Status_Packing) {
                            strOrderStatus += 'Status = \'Packing\'';
                        }
                        else if(strOrderStatus != ''){
                            strOrderStatus = strOrderStatus.substring(0,strOrderStatus.length() - 4);
                        }
                    }

                    if (strOrderStatus != '') {
                        strOrderStatus = ' ( ' + strOrderStatus + ' ) ';
                    }
                }
                else if (filter == 'orderType') {
                    for(String s : values){
                        if(strOrderType != ''){
                            strOrderType += ' OR ';
                        }
                        
                        if(s == Label.LU_Order_Filter_Order_Type_stanhomefr){
                            strOrderType += 'Type = \'Offline\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Type_ipaper){
                            strOrderType += 'Type = \'Wishlist\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Type_day_order){
                            if(strOrderStatus != ''){
                                strOrderStatus += ' OR ';
                            }
                            strOrderStatus += '( LU_TECH_Order_Date__c >= :t AND (Status = \'Pending\' OR Status = \'Invoicing\') )';
                        }
                        if(s == Label.LU_Order_Filter_Order_Type_myStan){
                            strOrderType += 'Type = \'LineUp\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Type_whishlist){
                            strOrderType += 'Type = \'Wishlist\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Type_B2B2C){
                            strOrderType += 'Type = \'B2B2C\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Type_B2C){
                            strOrderType += 'Type = \'B2C\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Type_cbStanhome){
                            strOrderType += 'Type = \'Commande CB\'';
                        }
                        else if(s == Label.LU_Order_Filter_Order_Type_nouveauClient){
                            strOrderType += 'Type = \'Commande CB\' AND LU_Online_Customer__c != null AND LU_Online_Customer__r.LU_New_Online__c = true';
                        }
                        
                        else if(strOrderType != ''){
                            //strOrderType = strOrderType.substring(0,strOrderType.length() - 4);
                        }
                    }

                    if (strOrderType != '') {
                        strOrderType = ' ( ' + strOrderType + ' ) ';
                        System.debug('strOrderType : ' + strOrderType);
                    }
                }
                else if (filter == 'forWho') {
                    for(String s : values){
                        if(strForWho != ''){
                            strForWho += ' OR ';
                        }
                        
                        if(s == Label.LU_Order_Filter_For_Who_me){
                            strForWho += ' BillToContactId = :contactId ';
                        }
                        else if(s == Label.LU_Order_Filter_For_Who_my_team){
                            strForWho += ' BillToContactId IN :l_myTeam ';
                        }
                        else if(s == Label.LU_Order_Filter_For_Who_all){
                            strForWho += ' ( BillToContactId = :contactId OR BillToContactId IN :l_myTeam ) ';
                        }
                        else if(s == Label.LU_Order_Filter_For_Who_clientStanhome){
                            strForWho += ' ( BillToContactId = :contactId AND (Type = \'B2B2C\' OR Type = \'B2C\')) ';
                        }
                        else if(s == Label.LU_Order_Filter_For_Who_nouveauClient){
                            strForWho += ' ( BillToContactId = :contactId AND (Type = \'B2C\' AND LU_Online_Customer__c != null AND LU_Online_Customer__r.LU_New_Online__c = true)) ';
                        }
                        else if(strForWho != ''){
                            strForWho = strForWho.substring(0,strForWho.length() - 4);
                        }
                    }

                    if (strForWho != '') {
                        strForWho = ' ( ' + strForWho + ' ) ';
                    }
                }
                else if (filter == 'invoiceStatus') {
                    for(String s : values){
                        if(strInvoiceStatus != ''){
                            strInvoiceStatus += ' OR ';
                        }
                        
                        if(s == Label.LU_Order_Filter_Invoice_Status_Paid){
                            strInvoiceStatus += 'LU_Invoice_Status__c = \'PAID\' ';
                        }
                        else if(s == Label.LU_Order_Filter_Invoice_Status_Unpaid){
                            strInvoiceStatus += 'LU_Invoice_Status__c = \'DUEDBYCHEQUE\' ';
                            strInvoiceStatus += 'OR LU_Invoice_Status__c = \'DUEDBYCB\' ';
                            strInvoiceStatus += 'OR LU_Invoice_Status__c = \'DUEDBYDEBIT\' ';
                            strInvoiceStatus += 'OR LU_Invoice_Status__c = \'LATE PAYMENT\' ';
                        }
                        else if(strInvoiceStatus != ''){
                            strInvoiceStatus = strInvoiceStatus.substring(0,strInvoiceStatus.length() - 4);
                        }
                    }

                    if (strInvoiceStatus != '') {
                        strInvoiceStatus = ' ( ' + strInvoiceStatus + ' ) ';
                    }
                }
                else if(filter == 'dealerManagerSegmentation'){
                    List<Account> lAccountIdsFilter = new List<Account>();
                    Set<String> s_idAccount = new Set<String>();

                    for (String s : values) { 
                        if (s != null && s != 'null') {
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
                            if (s != null && s != 'null') {
                                lAccountIdsFilter.add(new Account(Id = s.substring(0, 15)));
                            }
                        }
                    }

                    if (!lAccountIdsFilter.isEmpty()) {
                        lAccountIds = lAccountIdsFilter;
                    }

                    for(Contact c : [SELECT Id FROM Contact WHERE AccountId IN :lAccountIds]){
                        lcontactIds.add(c.Id);
                    }

                    System.Debug(laccountIds);
                    System.debug(lcontactIds);
                }
            }

            if(strTimePeriod != ''){
                whereStr += strTimePeriod;
            }
            if(strOrderStatus != ''){
                if(whereStr != ''){
                    whereStr += ' AND ';
                }
                whereStr += strOrderStatus;
            }
            if(strOrderType != ''){
                if(whereStr != ''){
                    whereStr += ' AND ';
                }
                whereStr += strOrderType;
            }
            if(strForWho != ''){
                if(whereStr != ''){
                    whereStr += ' AND ';
                }
                whereStr += strForWho;
            }  
            if(strInvoiceStatus != ''){
                if(whereStr != ''){
                    whereStr += ' AND ';
                }
                whereStr += strInvoiceStatus;
            }
        }

        if(userCountry == 'ITA') {

            if(con.Title == 'Direttore di Filiale' || con.Title == 'Star Leader' || con.Title == 'Direttore di Zona' || con.Title == 'Direttore di Regione' || con.Title == 'Sales Area'){
                List<Account> l_teamAccounts = AP1003_Utils_Contact.searchManagerTeamAccount(us, con);
 
                List<Contact> l_userTeamContacts = null;
                if (l_teamAccounts != null) {
                    l_userTeamContacts = [SELECT Id FROM Contact WHERE AccountId IN :l_teamAccounts AND LU_Out_Of_Business__c = false];
                } else {
                    l_userTeamContacts = [SELECT Id FROM Contact WHERE LU_Out_Of_Business__c = false AND (ReportsToId =: con.Id AND Parent_STH_Id__c =: con.Id)];
                }

                if(whereStr != ''){
                    whereStr += ' AND ';
                }
                whereStr += ' ( BillToContactId IN :l_userTeamContacts OR BillToContactId = :idContact )'; //Status != \'Draft\' AND 

                if(whereStr != ''){
                    whereStr = ' WHERE ' + whereStr;
                }
                
                String q = 'SELECT Id, LU_TECH_Order_Date__c, BillToContact.Account.Name, BillToContact.STHID__c, BillToContact.Name, EffectiveDate, Name, toLabel(Status), LU_Shipment_Follow_Up_URL__c, TotalAmount, ' + 
                            ' LU_Number_Of_Articles__c, CreatedDate, LU_Invoice_Date__c, LU_Invoice_Number__c, LU_Amount_To_Pay__c, TECH_Formula_CSS_Status__c, LU_TECH_AmountForMinimumOrder__c, CreatedById, CreatedBy.Name, LU_Invoice_URL1__c, Tech_Invoice_URL_filled__c FROM Order ' + 
                            whereStr + ' ORDER BY LU_TECH_Order_Date__c DESC NULLS LAST, CreatedDate DESC LIMIT 5000';

                System.Debug('whereStr :' + whereStr + ': whereStr');
                System.Debug(q);
                return Database.query(q);
            }
            else if(con.Title == 'Smile' || con.Title == AP1000_Utils.REBATE_JOB_TITLE || con.Title == 'Incaricata' || con.Title == 'Incaricata con Gruppo' || 
                    con.Title == 'Sales Consultant'|| con.Title == 'Group Sales Consultant'){
                
                if(whereStr != ''){
                    whereStr += ' AND ';
                }
                whereStr += ' BillToContactId = :idContact'; //Status != \'Draft\' AND 

                if(whereStr != ''){
                    whereStr = ' WHERE ' + whereStr;
                }
                
                String q = 'SELECT Id, Name, Type, LU_TECH_Order_Date__c, TECH_Formula_CSS_Status__c, toLabel(Status), LU_Shipment_Follow_Up_URL__c, EffectiveDate, LU_Number_Of_Articles__c, TotalAmount, LU_Invoice_Number__c, BillToContact.Name, LU_Invoice_Date__c, LU_Amount_To_Pay__c, LU_TECH_AmountForMinimumOrder__c, LU_Invoice_URL1__c, Tech_Invoice_URL_filled__c FROM Order ' + whereStr + ' ORDER BY LU_TECH_Order_Date__c DESC NULLS LAST, CreatedDate DESC';

                System.Debug('whereStr :' + whereStr + ': whereStr');
                System.Debug(q);
                return Database.query(q);
            }
        }
        else if(userCountry == 'FRA'){

            if(!lcontactIds.isEmpty()){
                if(whereStr != ''){
                    whereStr += ' AND ';
                }
                whereStr += ' BillToContactId IN :lcontactIds ';

                lcontactIds.add(con.Id);
            }
            else if(strForWho == '') {

                if(l_myTeam != null){
                    for(Contact teamMember : l_myTeam){
                        lcontactIds.add(teamMember.Id);
                    }
                }

                if(whereStr != ''){
                    whereStr += ' AND ';
                }

                if(!lcontactIds.isEmpty()){ 
                    whereStr += ' BillToContactId IN :lcontactIds ';
                    lcontactIds.add(con.Id);
                }
                else{ 
                    whereStr += ' BillToContactId = :contactId ';
                }
            }

            if(whereStr != ''){
                whereStr = ' WHERE ' + whereStr;
            }

            String q = 'SELECT Id, LU_Total_Amount_To_Pay__c, LU_Invoice_Date__c, LU_Invoice_Payment_Date__c, Name, LU_TECH_Order_Date__c, BillToContact.Account.Name, BillToContact.Name, BillToContact.Firstname, BillToContact.Lastname, BillToContact.STHID__c, ' + 
                    'Effectivedate, toLabel(Type), toLabel(Status), LU_Transporter__c, LU_Shipping_Date__c, LU_Shipment_Ref__c, LU_Total_Price_Without_Taxes__c, ' + 
                    'LU_Total_Amount_For_Valid_Base__c, LU_Invoice_Number__c, toLabel(LU_Invoice_Status__c), LU_Shipment_Follow_Up_URL__c, LU_Invoice_URL1__c, Tech_Invoice_URL_filled__c, LU_Amount_To_Pay__c, TECH_Formula_CSS_Status__c, ' + 
                    'LU_CUSTOMER_LASTNAME__c, LU_CUSTOMER_FIRSTNAME__c, BO_TOTAL_WITHOUT_TAXES__c, BO_TAXES__c, BO_TOTAL_WITH_TAXES__c, BO_TOTAL_AMOUNT_TO_PAY__c ' +
                    'FROM Order ' + whereStr + ' ORDER BY EffectiveDate DESC, Name DESC LIMIT 45000';

            System.Debug('whereStr :' + whereStr + ': whereStr');
            System.Debug(q);
            return Database.query(q);
        }

        return null;
    }

    @AuraEnabled
    public static Contact getContact(){
        return AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());
    }

    @AuraEnabled
    public static String getUserCountry(){
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }
}