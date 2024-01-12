public without sharing class lwc86_contact_detail_order_history_ctrl {
    
    @AuraEnabled
    public static Contact getContact(){
        return AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());
    }

    @AuraEnabled
    public static String getUserCountry(){
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    @AuraEnabled
    public static List<Order> getOrders(String idContact){

        Contact con = lwc63_orders_history_ctrl.getContact();
        String contactId = con.Id;

        User us = [SELECT TECH_MergeContactID__c FROM User WHERE Id = :UserInfo.getUserId()];

        String userCountry = lwc63_orders_history_ctrl.getUserCountry();

        AP1001_Cycle_Utils.CycleInfo currentCycle = AP1001_Cycle_Utils.getCurrentCycleByUser(UserInfo.getUserId());
        // Get the cycle before the current one
        Commercial_Periods__mdt previousCycle = AP1001_Cycle_Utils.getUserPreviousCycles(UserInfo.getUserId()).get(1);

        String whereStr = '';
        Date t = System.today();

        if(userCountry == 'ITA') {

            if(con.Title == 'Direttore di Filiale'){
                
                whereStr += ' WHERE BillToContactId = :idContact ';
                
                String q = 'SELECT Id, BillToContact.Account.Name, BillToContact.STHID__c, BillToContact.Name, EffectiveDate, Name, toLabel(Status), LU_Shipment_Follow_Up_URL__c, TotalAmount, ' + 
                            ' LU_Number_Of_Articles__c, CreatedDate, LU_Invoice_Date__c, LU_Invoice_Number__c, LU_Amount_To_Pay__c, TECH_Formula_CSS_Status__c, LU_TECH_AmountForMinimumOrder__c FROM Order ' + 
                            whereStr + ' ORDER BY EffectiveDate DESC';

                System.Debug('whereStr :' + whereStr + ': whereStr');
                System.Debug(q);
                return Database.query(q);
            }
            else if(con.Title == 'Smile' || con.Title ==  AP1000_Utils.REBATE_JOB_TITLE || con.Title == 'Incaricata' || con.Title == 'Incaricata con Gruppo' || 
                    con.Title == 'Sales Consultant'|| con.Title == 'Group Sales Consultant'){

                //#11018 Aller chercher les order products pour ensuite récupérer les commandes concernées
                List<Id> orderToDisplay = new List<Id>();
                for(OrderItem oi : [SELECT Id, OrderId FROM OrderItem WHERE LU_Contact_For__c =: idContact]){
                    orderToDisplay.add(oi.OrderId);
                }

                // whereStr += ' WHERE BillToContactId = :idContact';
                whereStr += ' WHERE Id In: orderToDisplay'; // TEST JJE 31/03/2021 #11018
                
                String q = 'SELECT Id, Name, Type, TECH_Formula_CSS_Status__c, toLabel(Status), LU_Shipment_Follow_Up_URL__c, EffectiveDate, LU_Number_Of_Articles__c, TotalAmount, ' +
                            'LU_Invoice_Number__c, BillToContact.Name, LU_Invoice_Date__c, LU_Amount_To_Pay__c, LU_TECH_AmountForMinimumOrder__c FROM Order ' + whereStr + ' ORDER BY EffectiveDate DESC';

                System.Debug('whereStr :' + whereStr + ': whereStr');
                System.Debug(q);
                return Database.query(q);
            }
        }
        else if(userCountry == 'FRA'){

            Set<Id> s_orderId = new Set<Id>();

            for(OrderITem oi : [SELECT OrderId FROM OrderITem WHERE LU_Contact_For__c = :idContact]){
                s_orderId.add(oi.OrderId);
            }
            
            whereStr += ' BillToContactId = :idContact OR Id IN :s_orderId ';

            if(whereStr != ''){
                whereStr = ' WHERE ' + whereStr;
            }

            String q = 'SELECT Id, Name, BillToContact.Account.Name, BillToContact.Name, BillToContact.Firstname, BillToContact.Lastname, BillToContact.STHID__c, ' + 
                        'Effectivedate, Type, toLabel(Status), LU_Transporter__c, LU_Shipping_Date__c, LU_Shipment_Ref__c, LU_Total_Price_Without_Taxes__c, ' + 
                        'LU_Total_Amount_For_Valid_Base__c, LU_Invoice_Number__c, toLabel(LU_Invoice_Status__c), LU_Shipment_Follow_Up_URL__c, LU_Invoice_URL1__c, LU_Amount_To_Pay__c, TECH_Formula_CSS_Status__c ' + 
                        'FROM Order ' + whereStr + ' ORDER BY EffectiveDate DESC, Name DESC LIMIT 45000';

            System.Debug('whereStr :' + whereStr + ': whereStr');
            System.Debug(q);
            return Database.query(q);
        }

        return null;
    }

    @AuraEnabled
    public static List<Order> getOrdersForContact(String idContact){
        List<Order> ordersForCOntact =  [SELECT Id, Name, 
        BillToContact.Account.Name, BillToContact.Name, BillToContact.Firstname, BillToContact.Lastname, BillToContact.STHID__c,
        Effectivedate, Type, toLabel(Status), 
        LU_Transporter__c, LU_Shipping_Date__c, LU_Shipment_Ref__c, LU_Total_Price_Without_Taxes__c, 
        LU_Total_Amount_For_Valid_Base__c, LU_Invoice_Number__c, toLabel(LU_Invoice_Status__c), 
        LU_Shipment_Follow_Up_URL__c, LU_Invoice_URL1__c, LU_Amount_To_Pay__c, 
        TECH_Formula_CSS_Status__c,
        (SELECT ID, LU_Contact_For__c
        FROM OrderItems WHERE LU_Contact_For__c =: idContact)
        FROM Order ORDER BY EffectiveDate DESC, Name DESC LIMIT 45000];

        return ordersForCOntact;

    }
}