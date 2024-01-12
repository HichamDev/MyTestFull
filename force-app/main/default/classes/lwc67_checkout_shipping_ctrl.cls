public without sharing class lwc67_checkout_shipping_ctrl {

    @AuraEnabled
    public static Order getOrder(String orderId){

        return [SELECT Id, BillToContact.MailingStreet, BillToContact.MailingPostalCode, BillToContact.MailingCity, BillToContact.MobilePhone,
                    ShippingStreet, ShippingPostalCode, ShippingCity, ShippingCountry
                  FROM Order
                 WHERE Id = :orderId LIMIT 1];
    }

    @AuraEnabled
    public static void updateOrder(Order ord){

        update ord;
    }

    @AuraEnabled
    public static List<LU_Order_Rule__c> getApplicableFees(String orderId){

        Map<Id, LU_Order_Rule__c> m_orderRuleToReturn = new Map<Id, LU_Order_Rule__c>();

        Order ord = [SELECT Id, BillToContactId, BillToContact.AccountCountryCode__c, BillToContact.TransportFeesApplicable__c, 
                            LU_Total_Price_Without_Taxes__c, LU_Total_Amount_To_Pay__c, BillToContact.Shipping_Fees_Segment__c, BillToContact.Title,
                            Total_Amount_Total_Sell__c, Total_Amount_Total_Personal_Use__c, LU_Total_Amount_Professional_Use__c, BillToContact.NbOrderForCurrentComCycle__c
                        FROM Order 
                        WHERE Id = :orderId];

        Id contactId = ord.BillToContactId;
        
        //List<OrderItem> vListOrderItems = new List<OrderItem>();
        String vConActivitySeg = ord.BillToContact.Shipping_Fees_Segment__c;
        
        // Use Sales Consultant fees information if user is a DF
        /* if(ord.BillToContact.Title == AppConstants.CON_TITLE_DF) {
            vListOrderItems = [Select Id, LU_Contact_For__c, LU_Contact_For__r.ActivitySegment__c 
                                From OrderItem Where OrderId = :orderId];
            if(vListOrderItems.size() > 0) {
                if(String.isNotBlank(vListOrderItems[0].LU_Contact_For__c)) {
                    vConActivitySeg = vListOrderItems[0].LU_Contact_For__r.ActivitySegment__c;
                }
            }
        } */

        String vConCountryCode = '';
        if(String.isNotBlank(orderId) && ord != null && String.isNotBlank(ord.BillToContactId)) {
            vConCountryCode = ord.BillToContact.AccountCountryCode__c;
        }

        // User us = [SELECT Profile.Name FROM User WHERE ContactId = :ord.BillToContactId];
        User us = [SELECT Profile.Name FROM user WHERE TECH_MergeContactID__c = :contactId AND IsActive = true];
        // SGO - SFT-1408 : Use "first total amount" for Italie
		Decimal amountOrder = (vConCountryCode == 'FRA' ? ord.LU_Total_Price_Without_Taxes__c : ord.Total_Amount_Total_Sell__c + ord.Total_Amount_Total_Personal_Use__c + ord.LU_Total_Amount_Professional_Use__c);
        Decimal orderWeight = getOrderWeight(orderId);

        List<LU_Order_Rule__c> l_shippingModes = getAvailableShippingMode(vConCountryCode, '%' + us.Profile.Name + '%');

        List<LU_Order_Rule__c> l_shippingFees = getShippingFees(vConCountryCode, l_shippingModes);

        AP1001_Cycle_Utils.CycleInfo vCycle = AP1001_Cycle_Utils.getCountryCurrentCycle(vConCountryCode);
        
        //Integer vNbOrdersInCurrentCycle = getNbOrdersInCurrentCycle(vCycle, ord.BillToContactId);

        Integer vNbOrdersInCurrentCycle = ord.BillToContact != null && ord.BillToContact.NbOrderForCurrentComCycle__c != null ? ord.BillToContact.NbOrderForCurrentComCycle__c.intValue() : 0;

        for (LU_Order_Rule__c oMode : l_shippingModes) {

            for (LU_Order_Rule__c oRule : l_shippingFees) {
                
                // If contact flagged without transport fees, put the fees to 0
                if (ord.BillToContact.TransportFeesApplicable__c == false) {
                    oRule.Fees__c = 0;
                }

                if (oRule.LU_Parent_Order_Rule__c == oMode.Id) {
                    system.debug('>>> oRUle');
                    system.debug(oRule);
                    system.debug('>> order');
                    system.debug(ord);
                    if (compare(amountOrder, oRule.LU_Amount_Operator__c, oRule.LU_Amount_Value__c) //ord.LU_Total_Price_Without_Taxes__c
                            && compare(orderWeight, oRule.LU_Weight_Operator__c, oRule.LU_Weight_Value__c)
                            && compare(vNbOrdersInCurrentCycle, oRule.LU_Nb_Order_On_Cycle_Operator__c, oRule.LU_Nb_Order_On_Cycle_Value__c)
                            && ((String.isNotBlank(vConActivitySeg) && vConActivitySeg.contains(oRule.LU_Activity_Segment_Value__c))
                                || oRule.LU_Activity_Segment_Value__c == '*') ) {

                        //if (m_orderRuleToReturn.get(oRule.LU_Parent_Order_Rule__c) != null) {
                        //	system.debug('>>>> old fee : ' + m_orderRuleToReturn.get(oRule.LU_Parent_Order_Rule__c).Fees__c);
                        //}
                    
                        if ( (m_orderRuleToReturn.containsKey(oRule.LU_Parent_Order_Rule__c) 
                            && m_orderRuleToReturn.get(oRule.LU_Parent_Order_Rule__c).Fees__c > oRule.Fees__c )
                            || !m_orderRuleToReturn.containsKey(oRule.LU_Parent_Order_Rule__c)) {
                            m_orderRuleToReturn.put(oRule.LU_Parent_Order_Rule__c ,oRule);
                            break;
                        }

                    }       
                }

            }

        }

        return m_orderRuleToReturn.values();
    }

    public static Decimal getOrderWeight(String orderId){
        
        Decimal weight = 0;

        for(OrderItem oi : [SELECT Id, Quantity, LU_Line_Weight__c, PriceBookEntry.LU_Offer_type__c FROM OrderItem WHERE OrderId = :orderId]){
            if(oi.PriceBookEntry.LU_Offer_type__c != 'Gift'){
                weight += oi.LU_Line_Weight__c;
            }
        }

        return weight;
    }

    public static List<LU_Order_Rule__c> getAvailableShippingMode(String userCountry, String userProfile){
        
        return [SELECT Id, LU_Text__c 
                  FROM LU_Order_Rule__c
                 WHERE RecordType.DeveloperName = 'Order_Shipping_Mode'
                   AND LU_Country__c = :userCountry
                   AND LU_Active__c = True 
                   AND ( LU_Profile_Applicable_For__c = '*' 
                      OR LU_Profile_Applicable_For__c LIKE :userProfile ) ];
    }

    public static List<LU_Order_Rule__c> getShippingFees(String userCountry, List<LU_Order_Rule__c> l_shippingModes){

        return [SELECT Id, LU_Weight_Operator__c, LU_Weight_Value__c, LU_Amount_Value__c, LU_Amount_Operator__c, Fees__c, LU_Parent_Order_Rule__c, 
                    LU_Parent_Order_Rule__r.LU_Text__c, LU_Text__c, LU_Activity_Segment_Value__c, LU_Nb_Order_On_Cycle_Operator__c, LU_Nb_Order_On_Cycle_Value__c
                  FROM LU_Order_Rule__c
                  WHERE RecordType.DeveloperName = 'Order_Shipping_Fees'
                   AND LU_Country__c = :userCountry
                   AND LU_Parent_Order_Rule__c IN :l_shippingModes
               	   ORDER BY LU_Amount_Value__c ASC];
    }

    public static Boolean compare(Decimal a, String operator, Decimal b){

        switch on operator {
            when '=' {
                return a == b;
            }
            when '>' {
                return a > b;
            }
            when '>=' {
                return a >= b;
            }
            when '<' {
                return a < b;
            }
            when '<=' {
                return a <= b;
            }
        }

        return false;
    }

    /**
    * @description Get orders number in current cycle
    * @param AP1001_Cycle_Utils.CycleInfo
    * @param String : contact id
    * @return Integer
    *
    */
    private static Integer getNbOrdersInCurrentCycle(AP1001_Cycle_Utils.CycleInfo pCycle, String pConId){
        Integer vNbOrdersInCurrentCycle = 0;
        if(pCycle != null && String.isNotBlank(pConId)){
            List<Order> vListOrders = [Select Id
                                        From Order
                                        Where BillToContactId = :pConId
                                        AND EffectiveDate >= :Date.valueOf(pCycle.startdate)
                                        AND EffectiveDate <= :Date.valueOf(pCycle.enddate)
                                        AND Status != 'Draft'];

            vNbOrdersInCurrentCycle = vListOrders.size();
        }

        return vNbOrdersInCurrentCycle;
    }

    @AuraEnabled
    public static String getUserCountry(){
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }
}