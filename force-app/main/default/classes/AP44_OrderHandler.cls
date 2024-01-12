/******************************************************************************
*   @author Simon Gourreau
*   @date 29/09/2020
*   @description Order trigger handler
*
*/
public without sharing class AP44_OrderHandler {
    public static boolean firstRun = true;
    
    /**
    * @description Set the order number on linked user when the status change to "validated"
    * @param List<Order>
    * @param Map<Id, Order>
    *
    */
    public static void setOrderNumberWhenValidated(List<Order> pListNewOrders, Map<Id, Order> pMapOldOrders) {
        List<Id> vListOrderOwnerIds = new List<Id>();
        for(Order lNewOrder : pListNewOrders){
            if(lNewOrder.Status == AppConstants.ORDER_STATUS_PENDING && lNewOrder.Status != pMapOldOrders.get(lNewOrder.Id).Status){
                vListOrderOwnerIds.add(lNewOrder.OwnerId);
            }
        }

        if(vListOrderOwnerIds.size() > 0){
            Map<Id, User> vMapIdOrderOwners = new Map<Id, User>([SELECT Id, TECH_LU_LastValidatedOrderNb__c 
                                                                 FROM User 
                                                                 WHERE Id In :vListOrderOwnerIds]);
            
            Map<Id, User> vMapUsersToUpd = new Map<Id, User>();
            for(Order lNewOrder : pListNewOrders) {
                String vNewOrderStatus = lNewOrder.Status;
                Order vOldOrder = pMapOldOrders.get(lNewOrder.Id);
                if(vOldOrder != null) {
                    String vOldOrderStatus = vOldOrder.Status;
                    // If order status changes to "validated" so put in technical field the order name
                    if(vNewOrderStatus != vOldOrderStatus && vNewOrderStatus == AppConstants.ORDER_STATUS_PENDING) {
                        User vUser = vMapIdOrderOwners.get(lNewOrder.OwnerId);
                        if(vUser != null){
                            vUser.TECH_LU_LastValidatedOrderNb__c = lNewOrder.Name;
                            vMapUsersToUpd.put(vUser.Id, vUser);
                        }
                    }
                }
            }
            
            Database.update(vMapUsersToUpd.values());

        }
        
    }
    
    /**
    * @description Set the order fields ids with tech external ids when interface user create them
    * @param List<Order>
    *
    */
    public static void setIdsWithExternalIdInfo(List<Order> pListOrders) {
        if(SHW_IBZ_Utils.isInterfaceUser()){
            Map<String, String> vExtMap = new Map<String, String>();
            Set<String> vAccExtIdSet = new Set<String>();
            Set<String> vConExtIdSet = new Set<String>();
            Set<String> vUserExtIdSet = new Set<String>();
            Set<String> vPbExtIdSet = new Set<String>();
            for(Order vOrder : pListOrders){
                String vTechAccId = vOrder.AccountId_TECH_ID__c;
                String vTechBillToConId = vOrder.BillToContactId_TECH_ID__c;
                String vTechOwnerId = vOrder.OwnerId_TECH_ID__c;
                String vTechPbId = vOrder.Pricebook2Id_TECH_ID__c;
                if(String.isNotBlank(vTechAccId)) {
                    vAccExtIdSet.add(vTechAccId);
                }
                
                if(String.isNotBlank(vTechBillToConId)) {
                    vConExtIdSet.add(vTechBillToConId);
                }
                
                if(String.isNotBlank(vTechOwnerId)) {
                    vUserExtIdSet.add(vTechOwnerId);
                }
                
                if(String.isNotBlank(vTechPbId)) {
                    vPbExtIdSet.add(vTechPbId);
                }
            }
            
            for(Account vAcc : [Select Id, TECH_ExternalId__c From Account Where TECH_ExternalId__c IN :vAccExtIdSet]){
                vExtMap.put(vAcc.TECH_ExternalId__c, vAcc.Id);
            }
            
            for(Contact vCon : [Select Id, TECH_ExternalId__c From Contact Where TECH_ExternalId__c IN :vConExtIdSet]){
                vExtMap.put(vCon.TECH_ExternalId__c, vCon.Id);
            }
            
            for(User vUser : [Select Id, TECH_ExternalId__c From User Where TECH_ExternalId__c IN :vUserExtIdSet]){
                vExtMap.put(vUser.TECH_ExternalId__c, vUser.Id);
            }
            
            for(PriceBook2 vPb : [Select Id, LU_Tech_External_Id__c From PriceBook2 Where LU_Tech_External_Id__c IN :vPbExtIdSet]){
                vExtMap.put(vPb.LU_Tech_External_Id__c, vPb.Id);
            }
            
            for(Order vOrder : pListOrders) {
                String vTechAccId = vOrder.AccountId_TECH_ID__c;
                String vTechBillToConId = vOrder.BillToContactId_TECH_ID__c;
                String vTechOwnerId = vOrder.OwnerId_TECH_ID__c;
                String vTechPbId = vOrder.Pricebook2Id_TECH_ID__c;
                String vMapTechAccId = vExtMap.get(vTechAccId);
                String vMapTechBillToConId = vExtMap.get(vTechBillToConId);
                String vMapTechOwnerId = vExtMap.get(vTechOwnerId);
                String vMapTechPbId = vExtMap.get(vTechPbId);
                if(String.isNotBlank(vTechAccId) && vMapTechAccId != null) {
                    vOrder.AccountId = vMapTechAccId;
                }
                
                if(String.isNotBlank(vTechBillToConId) && vMapTechBillToConId != null) {
                    vOrder.BillToContactId = vMapTechBillToConId;
                }
                
                if(String.isNotBlank(vTechOwnerId) && vMapTechOwnerId != null) {
                    vOrder.OwnerId = vMapTechOwnerId;
                }
                
                if(String.isNotBlank(vTechPbId) && vMapTechPbId != null) {
                    vOrder.Pricebook2Id = vMapTechPbId;
                }
            }
        }
    }
    
    
    /**
    * @description Set the LU_TECH_Order_Date__c when the status change to "validated"
    * @param List<Order>
    * @param Map<Id, Order>
    *
    */
    public static void setTechOrderDate(List<Order> l_newOrders, Map<Id, Order> m_oldOrders) {
        for(Order ord : l_newOrders){
            if(ord.Status == AppConstants.ORDER_STATUS_PENDING && ord.Status != m_oldOrders.get(ord.Id).Status){
                ord.LU_TECH_Order_Date__c = System.now();
                ord.EndDate = System.today();
            }
        }
    }
    
    /**
    * @description Set the LU_TECH_Order_Date__c when the order is created
    * @param List<Order>
    *
    */
    public static void setTechOrderDate(List<Order> l_newOrders) {
        for(Order ord : l_newOrders){
            ord.LU_TECH_Order_Date__c = System.now();
            if(ord.Status == AppConstants.ORDER_STATUS_PENDING){
                ord.EndDate = System.today();
            }
        }
    }
    
    /**
    * @description Set the Contact.LU_Sum_My_OrderItems_Last_Order__c and Contact.Last_Order_Total_Amount__c when the order is validated
    * @param List<Order>
    *
    */
    public static void setOrderItemSumPerContact(List<Order> l_newOrders) {
        List<Contact> l_contactToUpdate = new List<Contact>();
        Map<Id, Double> m_totalAmountForValidBasePerContact = new Map<Id, Double>();
        
        List<Id> l_idOrderValidated = new List<Id>();
        
        for(Order ord : l_newOrders){
            if(ord.Status == AppConstants.ORDER_STATUS_PENDING){
                l_idOrderValidated.add(ord.Id);
                m_totalAmountForValidBasePerContact.put(ord.BillToContactId, ord.LU_Total_Amount_For_Valid_Base__c);
            }
        }
        
        for(Contact con : [SELECT Id, LU_Sum_My_OrderItems_Last_Order__c, Last_Order_Total_Amount__c, LU_LastOrderDate__c FROM Contact WHERE Id IN :m_totalAmountForValidBasePerContact.keyset()]){
            if(m_totalAmountForValidBasePerContact.containsKey(con.Id)){
                con.Last_Order_Total_Amount__c = m_totalAmountForValidBasePerContact.get(con.Id);
            }
            con.LU_LastOrderDate__c = System.Now();
            l_contactToUpdate.add(con);
        }
        
        update l_contactToUpdate;
    }
    
    /**
    * @description Set the Contact.LU_Sum_My_OrderItems_Last_Order__c and Contact.Last_Order_Total_Amount__c when the order is validated
    * @param List<Order>
    * @param Map<Id, Order>
    *
    */
    public static void setOrderItemSumPerContact(List<Order> l_newOrders, Map<Id, Order> m_oldOrders) {
        Map<Id, Double> m_totalAmountForValidBasePerContact = new Map<Id, Double>();
        List<Id> l_idOrderValidated = new List<Id>();
        
        for(Order ord : l_newOrders){
            if(ord.Status == AppConstants.ORDER_STATUS_PENDING && ord.Status != m_oldOrders.get(ord.Id).Status){
                l_idOrderValidated.add(ord.Id);
                m_totalAmountForValidBasePerContact.put(ord.BillToContactId, ord.LU_Total_Amount_For_Valid_Base__c);
            }
        }

        if(l_idOrderValidated.size() > 0){
            List<Contact> l_contactToUpdate = new List<Contact>();
            Map<Id, Double> m_orderItemSumPerContact = new Map<Id, Double>();
            Map<Id, Double> m_orderItemSumWithTaxPerContact = new Map<Id, Double>();

            for(Orderitem oi : [SELECT LU_Contact_For__c, TotalPrice, LU_Total_Price__c FROM OrderItem WHERE OrderId IN :l_idOrderValidated]){
                if(!m_orderItemSumPerContact.containsKey(oi.LU_Contact_For__c)){
                    m_orderItemSumPerContact.put(oi.LU_Contact_For__c, oi.TotalPrice);
                }
                else{
                    m_orderItemSumPerContact.put(oi.LU_Contact_For__c, m_orderItemSumPerContact.get(oi.LU_Contact_For__c) + oi.TotalPrice);
                }
                if(!m_orderItemSumWithTaxPerContact.containsKey(oi.LU_Contact_For__c)){
                    m_orderItemSumWithTaxPerContact.put(oi.LU_Contact_For__c, oi.LU_Total_Price__c);
                }
                else{
                    m_orderItemSumWithTaxPerContact.put(oi.LU_Contact_For__c, m_orderItemSumWithTaxPerContact.get(oi.LU_Contact_For__c) + oi.LU_Total_Price__c);
                }
    
            }
            
            for(Contact con : [SELECT Id, LU_Sum_My_OrderItems_Last_Order__c,LU_Sum_My_OrderItems_With_Tax_Last_Order__c, Last_Order_Total_Amount__c, LU_LastOrderDate__c 
                                FROM Contact 
                                WHERE Id IN :m_orderItemSumPerContact.keyset() OR Id IN :m_totalAmountForValidBasePerContact.keyset()]){
                if(m_totalAmountForValidBasePerContact.containsKey(con.Id)){
                    con.Last_Order_Total_Amount__c = m_totalAmountForValidBasePerContact.get(con.Id);
                }
                if(m_orderItemSumPerContact.containsKey(con.Id)){
                    con.LU_Sum_My_OrderItems_Last_Order__c = m_orderItemSumPerContact.get(con.Id);
                }
                if(m_orderItemSumWithTaxPerContact.containsKey(con.Id)){
                    con.LU_Sum_My_OrderItems_With_Tax_Last_Order__c = m_orderItemSumWithTaxPerContact.get(con.Id);
                }
                con.LU_LastOrderDate__c = System.Now();
                l_contactToUpdate.add(con);
            }
            
            if(!l_contactToUpdate.isEmpty()){
                update l_contactToUpdate;
            }

        }
        
    }

    //JJE - 03/06/2021 - T-1693
    public static void setCommercialPeriod(List<Order> orders, Map<Id, Order> ordersOld){
        //Récupérer les orders qui nous intéressent
        List<Id> IdOrdersToUpdate = new List<Id>();
        for(Order ord : orders){
            if(ord.Status == AppConstants.ORDER_STATUS_PENDING && ord.Status != ordersOld.get(ord.Id).Status){
                IdOrdersToUpdate.add(ord.Id);
            }
        }

        if(IdOrdersToUpdate.size() > 0){
            //Récupérer les période commerciales correpondantes
            //SFT-1711, added developerName in the query
            List<Commercial_Periods__mdt> periods = [SELECT Id, Label, developerName, Type__c, TECH_External_Id__c FROM Commercial_Periods__mdt 
                                                    WHERE Startdate__c < :Datetime.now()
                                                    AND Enddate__c > :Datetime.now()]  ;


            List<Order> ordersToUpdate = [SELECT Id, LU_Country_Code__c, TECH_External_Id__c, LU_CommercialPeriod_week__c, LU_CommercialPeriod__c 
                                            FROM Order WHERE Id In: IdOrdersToUpdate];
            for(Order ord : ordersToUpdate){
                for(Commercial_Periods__mdt period : periods){
                    //SFT-1711, replaced label with developerName in this condition
                    if(ord.LU_Country_Code__c == Period.developerName.left(3)){
                        if(period.Type__c == AppConstants.COMM_PERIOD_TYPE_WEEK) ord.LU_CommercialPeriod_week__c = period.TECH_External_Id__c;
                        else if(period.Type__c == AppConstants.COMM_PERIOD_TYPE_CYCLE) ord.LU_CommercialPeriod__c = period.TECH_External_Id__c;
                    }
                }
                    
            }
            update ordersToUpdate;
        }
    }

    /**
    * @description Set the Order.Rebate_Discount_Personal_Use__c  when the order is updated
    * @param List<Order>
    *
    */
    public static void setRebateDiscountOnPersonalUse(Map<Id, Order> m_newOrders) {
        // List<LU_Order_Rule__c> lRules = new List<LU_Order_Rule__c>();
        // ALler chercher les Bill to contact des commandes
        Set<String> billTocontactTitle = new Set<String>();
        for(Order ord : m_newOrders.values()){
            billTocontactTitle.add(ord.Tech_BillToContact_Title__c);
        }

        // Set<String> titles = new Set<String>();
        // for(Contact con : [SELECT ID, Title FROM Contact WHERE ID IN: billTocontact]){
        //     titles.add(con.Title);
        // }
        
        // for(String title : billTocontactTitle){
            List<LU_Order_Rule__c> lRulesTitle = new List<LU_Order_Rule__c>([SELECT Discount__c, LU_Criteria_Value_1__c, LU_Criteria_Value_2__c, title__c FROM LU_Order_Rule__c 
            WHERE RecordType.Name='Order - Discount' AND Title__c IN: billTocontactTitle ORDER BY Discount__c]);
            // if(lRulesTitle.size() > 0) lRules.addAll(lRulesTitle);

        // }        

        System.debug('####### AP44_OrderHandler.cls >> setRebateDiscountOnPersonalUse #####################');
        List<Order> ordersToUpload = new List<Order>([SELECT Id, LU_Country_Code__c, Tech_BillToContact_Title__c, Rebate_Discount_Personal_Use__c, Discount__c
                                                      FROM Order WHERE Id IN: m_newOrders.keySet()]);

        // JJE 17/10/2023 : il faut recalculer les rollup summary car à cette étape de l'ordre d'éxecution il n'est pas toujours calculé
        List<OrderItem> orderItemByOrder = new List<OrderItem>([SELECT Id, OrderId, LU_Offer_Type__c, LU_Total_Without_Discount__c, LU_TECH_UsedForMinAmount__c FROM OrderItem 
                                                                WHERE OrderId IN: m_newOrders.keySet()]);

        for(Order lNewOrder : ordersToUpload){
            Double totalAmountPersonalUse = 0;
            Double amountForMinOrder = 0;
            for(OrderItem oi : orderItemByOrder){
                if(oi.OrderId == lNewOrder.Id){
                    amountForMinOrder += oi.LU_TECH_UsedForMinAmount__c;
                    if(oi.LU_Offer_Type__c == 'Personal Use') totalAmountPersonalUse += oi.LU_Total_Without_Discount__c;
                }
            }
            if(lNewOrder.LU_Country_Code__c != 'ITA' || totalAmountPersonalUse <= 0) continue;
            //Edit JJE 20/06/2023 -Si aucune order rule, on revient à zéro discount
            Boolean hasDiscount = false;

            for(LU_Order_Rule__c rule : lRulesTitle) {
                if(rule.title__c.contains(lNewOrder.Tech_BillToContact_Title__c) 
                && ((amountForMinOrder >= rule.LU_Criteria_Value_1__c 
                && rule.LU_Criteria_Value_2__c == null)
                || (amountForMinOrder >= rule.LU_Criteria_Value_1__c 
                && amountForMinOrder <= rule.LU_Criteria_Value_2__c)
                || (amountForMinOrder <= rule.LU_Criteria_Value_2__c 
                && rule.LU_Criteria_Value_1__c == null))
                ) {
                    lNewOrder.Rebate_Discount_Personal_Use__c = totalAmountPersonalUse*rule.Discount__c/100;
                    lNewOrder.Discount__c = rule.Discount__c;
                    hasDiscount = true;
                }
            } 

            if(hasDiscount == false) {
                lNewOrder.Rebate_Discount_Personal_Use__c = 0;
                lNewOrder.Discount__c = null;
            }
        }

        update ordersToUpload;
    }

    
    /**
     * 
     * @description Set the Order.Rebate_Discount_Personal_Use__c  when the order is created 
     * @return
     */
    @AuraEnabled
    public static String rebateDiscountOnPersonalUse(Order newOrder) {
        Id currentUser = UserInfo.getUserId();
        
        //CHeck if user is manager
        if(AP1000_Utils.isManager(currentUser)){
            Contact con = [select id, TECH_ExternalId__c from Contact where id = : newOrder.BillToContactId limit 1];
            User u = [SELECT Id From User WHERE TECH_ContactTechExternalId__c =: con.TECH_ExternalId__c LIMIT 1];
            currentUser = u.Id;
        }

        //Edit JJE 20/06/2023 -Si aucune order rule, on revient à zéro discount
        Boolean hasDiscount = false;

        List<LU_Order_Rule__c> lRules = lwc93_discount_banner_ctrl.getOrderRuleDiscount(currentUser);
            for(LU_Order_Rule__c rule : lRules) {
                if ((newOrder.LU_TECH_AmountForMinimumOrder__c >= rule.LU_Criteria_Value_1__c && rule.LU_Criteria_Value_2__c == null)
                || (newOrder.LU_TECH_AmountForMinimumOrder__c >= rule.LU_Criteria_Value_1__c && newOrder.LU_TECH_AmountForMinimumOrder__c <= rule.LU_Criteria_Value_2__c)
                    || (newOrder.LU_TECH_AmountForMinimumOrder__c <= rule.LU_Criteria_Value_2__c && rule.LU_Criteria_Value_1__c == null)
                ) {
                    newOrder.Rebate_Discount_Personal_Use__c = newOrder.Total_Amount_Total_Personal_Use__c*rule.Discount__c/100;
                    newOrder.Discount__c = rule.Discount__c;
                    hasDiscount = true;
                    break;
                }
            }

            if(hasDiscount == false) {
                newOrder.Rebate_Discount_Personal_Use__c = 0;
                newOrder.Discount__c = null;
            }

            // update newOrder; JJE 13/09/2023 - l'update se fait déjà dans le trigger after si le montant est changé
            return newOrder.Rebate_Discount_Personal_Use__c+'##'+newOrder.Discount__c;
    }
}