public class AP1010_Counters_Utils {

    /* WRAPPERS */
    public class Counter {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public Decimal value {get;set;}
        @AuraEnabled
        public Decimal currentOrderValue {get;set;}
        @AuraEnabled
        public Decimal debitValueOnOrder {get;set;}
        @AuraEnabled
        public Decimal creditValueOnOrder {get;set;}
        @AuraEnabled
        public Decimal balancePlusCreditOnOrder {get;set;}
        @AuraEnabled
        public Decimal highLimit {get;set;}
        @AuraEnabled
        public Decimal lowLimit {get;set;}
        @AuraEnabled
        public Decimal orderLimit {get;set;}
        @AuraEnabled
        public String unit {get;set;}
        @AuraEnabled
        public Boolean creditValuesCount {get;set;}
        @AuraEnabled
        public Boolean isDisplayed {get;set;}
        @AuraEnabled
        public Boolean displayInfoMessage {get;set;}
        @AuraEnabled
        public String infoMessageToBeDisplayed {get;set;}
    }

    public class ValidationReturn {
        @AuraEnabled
        public String msg {get;set;}
        @AuraEnabled
        public Sobject con {get;set;}
        @AuraEnabled
        public List<OrderItem> lItems {get;set;}
    }


    @AuraEnabled
    public static ValidationReturn validateUpdateCounters(String idOrder){

        // Get contact of the order
        List<Order> lOrder = [SELECT Id, BillToContactId, LU_TECH_AmountForMinimumOrder__c,
                                (SELECT Id, LU_Counter_1_new__c, LU_Counter_2_new__c, 
                                LU_Counter_3_new__c, LU_Counter_4_new__c,  LU_Counter_5_new__c,LU_Counter_6_new__c, LU_Counter_7_new__c, LU_Counter_8_new__c,  
                                LU_Counter_9_new__c,LU_Counter_19_new__c,  LU_Counter_10_new__c, LU_Counter_11_new__c, LU_Counter_12_new__c,  LU_Counter_13_new__c, 
                                LU_Counter_14_new__c,  LU_Counter_15_new__c,  LU_Counter_16_new__c,  LU_Counter_17_new__c, LU_Counter_18_new__c,  LU_Counter_20__c, 
                                LU_Counter_21_new__c, LU_Counter_22_new__c,  LU_Counter_23_new__c, LU_Counter_24_new__c,  LU_Counter_25_new__c,  LU_Counter_26_new__c,
                                 LU_Counter_27_new__c, LU_Counter_28_new__c,  LU_Counter_30_new__c, TECH_Counters_Not_Count_Credit_Value__c
                                FROM OrderItems)
                                FROM Order WHERE Id = :idOrder];

        Sobject con = [SELECT Id,
                              LU_Counter_1__c, LU_Counter_1_High_Limit__c, 
                              LU_Counter_2__c, LU_Counter_2_High_Limit__c, 
                              LU_Counter_3__c, LU_Counter_3_High_Limit__c, 
                              LU_Counter_4__c, LU_Counter_4_High_Limit__c, 
                              LU_Counter_5__c, LU_Counter_5_High_Limit__c, 
                              LU_Counter_6__c, LU_Counter_6_High_Limit__c, 
                              LU_Counter_7__c, LU_Counter_7_High_Limit__c, 
                              LU_Counter_8__c, LU_Counter_8_High_Limit__c, 
                              LU_Counter_9__c, LU_Counter_9_High_Limit__c, 
                              LU_Counter_10__c, LU_Counter_10_High_Limit__c,
                              LU_Counter_11__c, LU_Counter_11_High_Limit__c,
                              LU_Counter_12__c, LU_Counter_12_High_Limit__c,
                              LU_Counter_13__c, LU_Counter_13_High_Limit__c,
                              LU_Counter_14__c, LU_Counter_14_High_Limit__c,
                              LU_Counter_15__c, LU_Counter_15_High_Limit__c,
                              LU_Counter_16__c, LU_Counter_16_High_Limit__c,
                              LU_Counter_17__c, LU_Counter_17_High_Limit__c,
                              LU_Counter_18__c, LU_Counter_18_High_Limit__c,
                              LU_Counter_19__c, LU_Counter_19_High_Limit__c,
                              LU_Counter_20__c, LU_Counter_20_High_Limit__c,
                              LU_Counter_21__c, LU_Counter_21_High_Limit__c,
                              LU_Counter_22__c, LU_Counter_22_High_Limit__c,
                              LU_Counter_23__c, LU_Counter_23_High_Limit__c,
                              LU_Counter_24__c, LU_Counter_24_High_Limit__c,
                              LU_Counter_25__c, LU_Counter_25_High_Limit__c,
                              LU_Counter_26__c, LU_Counter_26_High_Limit__c,
                              LU_Counter_27__c, LU_Counter_27_High_Limit__c,
                              LU_Counter_28__c, LU_Counter_28_High_Limit__c,
                              LU_Counter_29__c, LU_Counter_29_High_Limit__c,
                              LU_Counter_30__c, LU_Counter_30_High_Limit__c,
                              TECH_ExternalId__c
                         FROM Contact
                        WHERE Id = :lOrder[0].BillToContactId ];

        String country = ((String) con.get('TECH_ExternalId__c')).left(3) == 'FRA' ? 'FRA' : 'ITA'; // France, Italy

        Map<Integer, LU_Order_Rule__c> m_oRuleMessagesPerCounter = new Map<Integer, LU_Order_Rule__c>();
        for(LU_Order_Rule__c orule : [SELECT LU_Counter_Number__c, LU_Text__c, LU_Text_2__c 
                                     FROM LU_Order_Rule__c 
                                    WHERE RecordType.DeveloperName = 'LU_Counter_Messages'
                                      AND LU_Country__c = :country]){
            m_oRuleMessagesPerCounter.put(Integer.valueOf(orule.LU_Counter_Number__c), orule);
        }

        // Variables
        Map<Integer, Counter> m_counters = AP1010_Counters_Utils.getCounters(idOrder, null, null);
        ValidationReturn ret = new ValidationReturn();
        system.debug('>>counters');
        for (Integer n : m_counters.keyset()) {

            if (m_counters.get(n) != null) {
                system.debug(m_counters.get(n));
                if (m_counters.get(n).orderLimit != null && lOrder[0].LU_TECH_AmountForMinimumOrder__c < m_counters.get(n).orderLimit) {
                    System.debug('toto m_counters.get(n).orderLimit ==> '+ m_counters.get(n).orderLimit);
                    System.debug('toto lOrder[0].LU_TECH_AmountForMinimumOrder__c ==> '+ lOrder[0].LU_TECH_AmountForMinimumOrder__c);
                    String err = Label.LU_Counters_OrderLimitNotEnoughError; //Label.LU_Not_enough_points;
                    err = err.replace('[counterName]', String.valueof(m_counters.get(n).label));
                    err = err.replace('[pointsNeeded]', String.valueof(m_counters.get(n).orderLimit - lOrder[0].LU_TECH_AmountForMinimumOrder__c));
                    ret.msg = err;
                    return ret;
                } else if (m_counters.get(n).lowLimit != null && m_counters.get(n).currentOrderValue < m_counters.get(n).lowLimit) {
                    if(m_oRuleMessagesPerCounter.containsKey(n) && m_oRuleMessagesPerCounter.get(n).LU_Text__c != ''){
                        String value = String.valueof(m_counters.get(n).value);
                        String err = m_oRuleMessagesPerCounter.get(n).LU_Text__c; 
                        err = err.replace('$LIMIT', (value != null ? value : '0'));
                        ret.msg = err;
                        return ret;
                    }
                    else{
                        String err = Label.LU_Counters_LowLimitError; //Label.LU_Not_enough_points_to_debit;
                        String value = String.valueof(m_counters.get(n).value);
                        err = err.replace('[counterName]', m_counters.get(n).label);
                        err = err.replace('[pointsNeeded]', String.valueof(m_counters.get(n).currentOrderValue.setScale(2)));
                        err = err.replace('[balance]', (value != null ? value : '0'));
                        err = err.replace('[limit]', String.valueof(m_counters.get(n).lowLimit.setScale(2)));
                        ret.msg = err;
                        return ret;
                    }
                } else if (m_counters.get(n).orderLimit != null && (m_counters.get(n).currentOrderValue - m_counters.get(n).value) > m_counters.get(n).orderLimit) {
                    if(m_oRuleMessagesPerCounter.containsKey(n) && m_oRuleMessagesPerCounter.get(n).LU_Text_2__c != ''){
                        String err = m_oRuleMessagesPerCounter.get(n).LU_Text_2__c; 
                        err = err.replace('$LIMIT', String.valueof(m_counters.get(n).highLimit));
                        ret.msg = err;
                        return ret;
                    }
                    else{
                        String err = Label.LU_Counters_OrderLimitError; //Label.LU_Not_enough_points_to_debit;
                        err = err.replace('[counterName]', String.valueof(m_counters.get(n).label));
                        err = err.replace('[pointsNeeded]', String.valueof(m_counters.get(n).currentOrderValue - m_counters.get(n).value));
                        err = err.replace('[limit]', String.valueof(m_counters.get(n).highLimit));
                        ret.msg = err;
                        return ret;
                    }
                }
            }
        }
        
        Map<Integer, LU_Order_Rule__c> m_orderRulePerCounter = new Map<Integer, LU_Order_Rule__c>();


        List<LU_Order_Rule__c> l_oRuleMessages = [SELECT LU_Counter_Number__c, LU_Text__c, LU_Text_2__c
                                                    FROM LU_Order_Rule__c 
                                                   WHERE RecordType.DeveloperName = 'LU_Counter_Messages'
                                                     AND LU_Country__c = :country];

        for(LU_Order_Rule__c orule : [SELECT Id, LU_Counter_Number__c, LU_Value__c 
                                        FROM LU_Order_Rule__c 
                                        WHERE LU_Country__c = :country 
                                        AND RecordType.DeveloperName = 'Counter_Reset_After_An_Order']){
            if(orule.LU_Counter_Number__c != null){
                m_orderRulePerCounter.put(Integer.valueOf(orule.LU_Counter_Number__c), orule);
            }
        }

        for (Integer i = 1; i <= 30; i++) {
            if (m_orderRulePerCounter.containsKey(i)) {
                con.put('LU_Counter_' + i + '__c', m_orderRulePerCounter.get(i).LU_Value__c);
            }
            else {
                if (m_counters.get(i) != null) {
                    if (con.get('LU_Counter_' + i + '_High_Limit__c') != null && m_counters.get(i).currentOrderValue > (Decimal) con.get('LU_Counter_' + i + '_High_Limit__c')) {
                        con.put('LU_Counter_' + i + '__c', (Decimal) con.get('LU_Counter_' + i + '_High_Limit__c') );
                    } else {
                        con.put('LU_Counter_' + i + '__c', m_counters.get(i).currentOrderValue);

                        if (m_counters.get(i).creditValuesCount == false) {
                            // Update on the order item, the counters for which credit should not be used / extracted
                            for (OrderItem item : lOrder[0].OrderItems) {
                                if (item.get('LU_Counter_' + i + '_new__c') != null && (Decimal)item.get('LU_Counter_' + i + '_new__c') > 0) {
                                    item.TECH_Counters_Not_Count_Credit_Value__c = (item.TECH_Counters_Not_Count_Credit_Value__c != null ? item.TECH_Counters_Not_Count_Credit_Value__c + i + '#' : i + '#');
                                    system.debug('>>> item.TECH_Counters_Not_Count_Credit_Value__c : ' + item.TECH_Counters_Not_Count_Credit_Value__c);
                                }
                            }
                        }

                    }
                } 
            } 
        }
        ret.con = con;
        ret.msg = 'OK';
        ret.lItems = lOrder[0].OrderItems;
        //update con;
        // return 'OK';
        return (ret);
    }

    @AuraEnabled
    public static Map<Integer, Counter> getCounters(String idOrder, List<AP1002_LookupSearchResult> l_products, List<String> l_idProducts){
        return getCounters(idOrder, l_products, l_idProducts, null);
    }

    @AuraEnabled
    public static Map<Integer, Counter> getCounters(String idOrder, List<AP1002_LookupSearchResult> l_products, List<String> l_idProducts, String idContact){

        // Variables
        Map<Integer, Counter> m_counters = new Map<Integer, Counter>();
        Counter cou = null;
        system.debug('>>> idOrder : ' + idOrder);
        // Get the contact of the order
        List<Order> lOrder = [SELECT Id, BillToContactId, LU_Total_Price_Without_Taxes__c FROM Order WHERE Id = :idOrder];
        String idCurrentUserContact = null;
        if(idContact != null){
            idCurrentUserContact = idContact;
        }
        else if (lOrder.isEmpty()) {
            idCurrentUserContact = AP1002_Utils_User.getConnectedUserContact().Id;
        } else {
            idCurrentUserContact = lOrder[0].BillToContactId;
        }

        Contact vCon = [Select Id, TECH_ExternalId__c From Contact Where Id = :idCurrentUserContact];
        String vCountry = '';
        if(vCon != null && vCon.TECH_ExternalId__c != null) {
            vCountry = vCon.TECH_ExternalId__c.left(3) == 'FRA' ? 'FRA' : 'ITA'; // France, Italy
        }
        
        // Get the rules of counters
        List<LU_Order_Rule__c> lOrderRules = [SELECT Id, LU_Name__c, LU_Value__c, LU_Text__c, RecordType.DeveloperName
                                                FROM LU_Order_Rule__c 
                                                WHERE RecordType.DeveloperName = 'Order_Counter_Start_At'
                                                AND LU_Country__c = :vCountry];

        // Get the counters of the contact
        List<String> l_fieldsToRequest = new List<String>{'Id','LU_Counter_10_BO_Changes__c','LU_Counter_10_High_Limit__c','LU_Counter_10_Lower_Limit__c','LU_Counter_10_Name__c','LU_Counter_10_Order_Amount_Limit_For__c','LU_Counter_10__c',
                                                               'LU_Counter_11_BO_Changes__c','LU_Counter_11_High_Limit__c','LU_Counter_11_Lower_Limit__c','LU_Counter_11_Name__c','LU_Counter_11_Order_Amount_Limit_For__c','LU_Counter_11__c',
                                                               'LU_Counter_12_BO_Changes__c','LU_Counter_12_High_Limit__c','LU_Counter_12_Lower_Limit__c','LU_Counter_12_Name__c','LU_Counter_12_Order_Amount_Limit_For__c','LU_Counter_12__c',
                                                               'LU_Counter_13_BO_Changes__c','LU_Counter_13_High_Limit__c','LU_Counter_13_Lower_Limit__c','LU_Counter_13_Name__c','LU_Counter_13_Order_Amount_Limit_For__c','LU_Counter_13__c',
                                                               'LU_Counter_14_BO_Changes__c','LU_Counter_14_High_Limit__c','LU_Counter_14_Lower_Limit__c','LU_Counter_14_Name__c','LU_Counter_14_Order_Amount_Limit_For__c','LU_Counter_14__c',
                                                               'LU_Counter_15_BO_Changes__c','LU_Counter_15_High_Limit__c','LU_Counter_15_Lower_Limit__c','LU_Counter_15_Name__c','LU_Counter_15_Order_Amount_Limit_For__c','LU_Counter_15__c',
                                                               'LU_Counter_16_BO_Changes__c','LU_Counter_16_High_Limit__c','LU_Counter_16_Lower_Limit__c','LU_Counter_16_Name__c','LU_Counter_16_Order_Amount_Limit_For__c','LU_Counter_16__c',
                                                               'LU_Counter_17_BO_Changes__c','LU_Counter_17_High_Limit__c','LU_Counter_17_Lower_Limit__c','LU_Counter_17_Name__c','LU_Counter_17_Order_Amount_Limit_For__c','LU_Counter_17__c',
                                                               'LU_Counter_18_BO_Changes__c','LU_Counter_18_High_Limit__c','LU_Counter_18_Lower_Limit__c','LU_Counter_18_Name__c','LU_Counter_18_Order_Amount_Limit_For__c','LU_Counter_18__c',
                                                               'LU_Counter_19_BO_Changes__c','LU_Counter_19_High_Limit__c','LU_Counter_19_Lower_Limit__c','LU_Counter_19_Name__c','LU_Counter_19_Order_Amount_Limit_For__c','LU_Counter_19__c',
                                                               'LU_Counter_20_BO_Changes__c','LU_Counter_20_High_Limit__c','LU_Counter_20_Lower_Limit__c','LU_Counter_20_Name__c','LU_Counter_20_Order_Amount_Limit_For__c','LU_Counter_20__c',
                                                               'LU_Counter_21_BO_Changes__c','LU_Counter_21_High_Limit__c','LU_Counter_21_Lower_Limit__c','LU_Counter_21_Name__c','LU_Counter_21_Order_Amount_Limit_For__c','LU_Counter_21__c',
                                                               'LU_Counter_22_BO_Changes__c','LU_Counter_22_High_Limit__c','LU_Counter_22_Lower_Limit__c','LU_Counter_22_Name__c','LU_Counter_22_Order_Amount_Limit_For__c','LU_Counter_22__c',
                                                               'LU_Counter_23_BO_Changes__c','LU_Counter_23_High_Limit__c','LU_Counter_23_Lower_Limit__c','LU_Counter_23_Name__c','LU_Counter_23_Order_Amount_Limit_For__c','LU_Counter_23__c',
                                                               'LU_Counter_24_BO_Changes__c','LU_Counter_24_High_Limit__c','LU_Counter_24_Lower_Limit__c','LU_Counter_24_Name__c','LU_Counter_24_Order_Amount_Limit_For__c','LU_Counter_24__c',
                                                               'LU_Counter_25_BO_Changes__c','LU_Counter_25_High_Limit__c','LU_Counter_25_Lower_Limit__c','LU_Counter_25_Name__c','LU_Counter_25_Order_Amount_Limit_For__c','LU_Counter_25__c',
                                                               'LU_Counter_26_BO_Changes__c','LU_Counter_26_High_Limit__c','LU_Counter_26_Lower_Limit__c','LU_Counter_26_Name__c','LU_Counter_26_Order_Amount_Limit_For__c','LU_Counter_26__c',
                                                               'LU_Counter_27_BO_Changes__c','LU_Counter_27_High_Limit__c','LU_Counter_27_Lower_Limit__c','LU_Counter_27_Name__c','LU_Counter_27_Order_Amount_Limit_For__c','LU_Counter_27__c',
                                                               'LU_Counter_28_BO_Changes__c','LU_Counter_28_High_Limit__c','LU_Counter_28_Lower_Limit__c','LU_Counter_28_Name__c','LU_Counter_28_Order_Amount_Limit_For__c','LU_Counter_28__c',
                                                               'LU_Counter_29_BO_Changes__c','LU_Counter_29_High_Limit__c','LU_Counter_29_Lower_Limit__c','LU_Counter_29_Name__c','LU_Counter_29_Order_Amount_Limit_For__c','LU_Counter_29__c',
                                                               'LU_Counter_30_BO_Changes__c','LU_Counter_30_High_Limit__c','LU_Counter_30_Lower_Limit__c','LU_Counter_30_Name__c','LU_Counter_30_Order_Amount_Limit_For__c','LU_Counter_30__c',
                                                               'LU_Counter_1_BO_Changes__c','LU_Counter_1_High_Limit__c','LU_Counter_1_Lower_Limit__c','LU_Counter_1_Name__c','LU_Counter_1_Order_Amount_Limit_For__c','LU_Counter_1__c','LU_Counter_2_BO_Changes__c','LU_Counter_2_High_Limit__c','LU_Counter_2_Lower_Limit__c','LU_Counter_2_Name__c','LU_Counter_2_Order_Amount_Limit_For__c','LU_Counter_2__c','LU_Counter_3_BO_Changes__c','LU_Counter_3_High_Limit__c','LU_Counter_3_Lower_Limit__c','LU_Counter_3_Name__c','LU_Counter_3_Order_Amount_Limit_For__c','LU_Counter_3__c','LU_Counter_4_BO_Changes__c','LU_Counter_4_High_Limit__c','LU_Counter_4_Lower_Limit__c','LU_Counter_4_Name__c','LU_Counter_4_Order_Amount_Limit_For__c','LU_Counter_4__c','LU_Counter_5_BO_Changes__c','LU_Counter_5_High_Limit__c','LU_Counter_5_Lower_Limit__c','LU_Counter_5_Name__c','LU_Counter_5_Order_Amount_Limit_For__c','LU_Counter_5__c','LU_Counter_6_BO_Changes__c','LU_Counter_6_High_Limit__c','LU_Counter_6_Lower_Limit__c','LU_Counter_6_Name__c','LU_Counter_6_Order_Amount_Limit_For__c','LU_Counter_6__c','LU_Counter_7_BO_Changes__c','LU_Counter_7_High_Limit__c','LU_Counter_7_Lower_Limit__c','LU_Counter_7_Name__c','LU_Counter_7_Order_Amount_Limit_For__c','LU_Counter_7__c','LU_Counter_8_BO_Changes__c','LU_Counter_8_High_Limit__c','LU_Counter_8_Lower_Limit__c','LU_Counter_8_Name__c','LU_Counter_8_Order_Amount_Limit_For__c','LU_Counter_8__c','LU_Counter_9_BO_Changes__c','LU_Counter_9_High_Limit__c','LU_Counter_9_Lower_Limit__c','LU_Counter_9_Name__c','LU_Counter_9_Order_Amount_Limit_For__c','LU_Counter_9__c','LU_Counters_to_be_displayed_Total__c', 'LU_Counters_Unit__c', 'LU_Counters_Unit_Bis__c', 'LU_Counters_To_Be_Displayed__c'};
        Sobject c = Database.query('SELECT ' + String.join(l_fieldsToRequest, ',') + ' FROM Contact WHERE Id = :idCurrentUserContact');

        String countersUnit = '';
        if(c.get('LU_Counters_Unit__c') != null){
            countersUnit += c.get('LU_Counters_Unit__c');
        }
        if(c.get('LU_Counters_Unit_Bis__c') != null){
            if(countersUnit != null){
                countersUnit += '#';
            }
            countersUnit += c.get('LU_Counters_Unit_Bis__c');
        }

        Map<Id, Sobject> m_pbe = null;

        if(l_products != null){

            m_pbe = new Map<Id, Sobject>([SELECT Id, LU_Counter_Value__c, UnitPrice
                                            FROM PricebookEntry
                                            WHERE ID IN :l_idProducts]);
        }

        List<OrderItem> l_orderItem = [SELECT Quantity, PricebookEntryId, LU_Child_Product__c
                                         FROM OrderItem 
                                        WHERE OrderId = :idOrder];

        List<Id> l_idPriceBookEntry = new List<Id>();
        for(OrderItem oi : l_orderItem){
            l_idPriceBookEntry.add(oi.PricebookEntryId);
        }

        Map<Id, PricebookEntry> m_priceBookEntry = new Map<Id, PricebookEntry>([SELECT LU_Counter_Value__c, UnitPrice
                                                                                    FROM PricebookEntry
                                                                                    WHERE Id IN :l_idPriceBookEntry]);    
        
        // Initialise the wrapper with the Contact information : balance, limits...
        for (Integer i = 1; i <= 30; i++) {

            // Initialize the counter variable
            cou = new Counter();
            cou.id = 'counter' + i;
            Boolean addDraftPoints = true;
            cou.creditValuesCount = true;

            // Get if rules on the counter configured
            Map<String, LU_Order_Rule__c> mRulesOfTheCounter = new Map<String, LU_Order_Rule__c>();
            if (!lOrderRules.isEmpty()) {
                for (LU_Order_Rule__c rule : lOrderRules) {
                    if (rule.LU_Name__c == (i + '')) {
                        mRulesOfTheCounter.put(rule.RecordType.DeveloperName, rule);
                    }
                }
            }


            // Get balance of the contact
            List<String> lName = ( ((String) c.get('LU_Counter_' + i + '_Name__c')) != null && ((String) c.get('LU_Counter_' + i + '_Name__c')) != '' ?
                                    ((String) c.get('LU_Counter_' + i + '_Name__c')).split('#') :
                                    null);

            cou.label = (lName != null && lName.size() > 0 ? lName.get(0) : '');
            cou.description = (lName != null && lName.size() > 1 ? lName.get(1) : '');
            cou.value = (Decimal) c.get('LU_Counter_' + i + '__c');
            if(cou.value != null){
                cou.value = cou.value.setScale(2);
            }
            cou.currentOrderValue = (cou.value != null ? cou.value : 0);
            cou.balancePlusCreditOnOrder = (cou.value != null ? cou.value : 0);
            cou.debitValueOnOrder = 0;
            cou.creditValueOnOrder = 0;
            cou.highLimit = (Decimal) c.get('LU_Counter_' + i + '_High_Limit__c');
            cou.lowLimit = (Decimal) c.get('LU_Counter_' + i + '_Lower_Limit__c');
            cou.orderLimit = (Decimal) c.get('LU_Counter_' + i + '_Order_Amount_Limit_For__c');
            cou.unit = ( countersUnit != null && countersUnit.split('#').size() >= i  ? countersUnit.split('#').get(i - 1) : '');
            //cou.unit += ( c.get('LU_Counters_Unit_Bis__c') != null ? '#' + ((String) c.get('LU_Counters_Unit_Bis__c')).split('#').get(Integer.valueOf(i) - 1) : '');
            cou.isDisplayed = (c.get('LU_Counters_To_Be_Displayed__c') != null ? ((List<String>) ((String) c.get('LU_Counters_To_Be_Displayed__c')).split('#')).contains( String.valueOf(i) ) : false );


            // If rule type 'Order_Counter_Start_At' then add the points only if the total amount is higher than the one set
            if (mRulesOfTheCounter.containsKey('Order_Counter_Start_At')) {
                system.debug('>>>>>> RULE START AT COUNTER ' + i );
                Decimal ruleValue = mRulesOfTheCounter.get('Order_Counter_Start_At').LU_Value__c;

                // Calculate the total without tax amount of the current draft order
                Decimal totalOrder = 0;
                // Add total of order
                // totalOrder = (lOrder != null && !lOrder.isEmpty() ? lOrder[0].LU_Total_Price_Without_Taxes__c : 0);
                // system.debug('>>> totalOrder :' + totalOrder);
                
                // Add the total of the current draft order
                for (Sobject oi : l_orderItem) {
                    
                    Boolean productCounted = (((OrderItem)oi).LU_Child_Product__c != null ? false : true);

                    Sobject pbe = m_priceBookEntry.get((String) oi.get('PricebookEntryId'));
                    String counter = (String) pbe.get('LU_Counter_Value__c');
                    if( Decimal.valueOf(counter.split('#')[i-1]) != null && Decimal.valueOf(counter.split('#')[i-1]) != 0 && 
                        productCounted) {
                        totalOrder +=  (Decimal)pbe.get('UnitPrice') * (Decimal) oi.get('Quantity'); 
                        System.debug('>>> EXISTING LINE : totalOrder + ( ' + (Decimal)pbe.get('UnitPrice') + ' * ' + (Decimal) oi.get('Quantity') + ') = ' + totalOrder);                       
                    }
                }

                // Add the total of the line of the order home
                if (l_products != null) {
                    for (AP1002_LookupSearchResult lsr : l_products) {
                        if (m_pbe.containsKey(lsr.id)) {
                            // 2054 JJE 04/10/2023 - Faire aussi le check si le produit ajouté fait bien aprtie du bon compteur
                            // Boolean productCounted = (((OrderItem)oi).LU_Child_Product__c != null ? false : true);
                            Sobject pbe = m_pbe.get(lsr.id);
                            String counter = (String) pbe.get('LU_Counter_Value__c');
                            System.debug(pbe);
                            System.debug(Decimal.valueOf(counter.split('#')[i-1]));
                            if(Decimal.valueOf(counter.split('#')[i-1]) != null 
                                && Decimal.valueOf(counter.split('#')[i-1]) != 0 ){
                                // && productCounted) {
                                    totalOrder +=  (Decimal)pbe.get('UnitPrice') * lsr.quantity;
                                    System.debug('>>> BASKET : totalOrder + ( ' + pbe.get('UnitPrice') + ' * ' + lsr.quantity + ') = ' + totalOrder);
                                }
                        }
                    }
                }

                // Check if the rule is ok
                System.debug('>>> RULE : ' + totalOrder + ' <= ' + ruleValue );
                if (totalOrder <= ruleValue) {
                    addDraftPoints = false;
                    cou.creditValuesCount = false;
                    cou.infoMessageToBeDisplayed = mRulesOfTheCounter.get('Order_Counter_Start_At').LU_Text__c;
                }
            }
            
            // Add to the balance : Lines of the current order draft
            for (Sobject oi : l_orderItem) {
                Sobject pbe = m_priceBookEntry.get((String) oi.get('PricebookEntryId'));
                Boolean productCounted = (((OrderItem)oi).LU_Child_Product__c != null ? false : true);
                String counter = (String) pbe.get('LU_Counter_Value__c');
                if( counter != null && Decimal.valueOf(counter.split('#')[i-1]) != null && Decimal.valueOf(counter.split('#')[i-1]) != 0 && productCounted) {
                    
                    // Case of a debit and in case of credit + rule ok
                    if ( ( Decimal.valueOf(counter.split('#')[i-1]) > 0 && addDraftPoints ) ||
                        Decimal.valueOf(counter.split('#')[i-1]) < 0 ) {
                        Decimal value = Decimal.valueOf(counter.split('#')[i-1]);
                        value = ( (Decimal) oi.get('Quantity') ) * value;
                        cou.currentOrderValue += value;

                        if (value < 0) {
                            cou.debitValueOnOrder = (cou.debitValueOnOrder != null ? cou.debitValueOnOrder : 0) + value;
                        } else {
                            cou.creditValueOnOrder = (cou.creditValueOnOrder != null ? cou.creditValueOnOrder : 0) + value;
                            cou.balancePlusCreditOnOrder += value;
                        }
                    } 

                    
                }
            }


            // Add to the balance : Lines of the order-home basket 
            if (l_products != null) {
                for(AP1002_LookupSearchResult lsr : l_products){
                    if(m_pbe.containsKey(lsr.id)){

                        String counter = (String) m_pbe.get(lsr.id).get('LU_Counter_Value__c');

                        if ( ( Decimal.valueOf(counter.split('#')[i-1]) > 0 && addDraftPoints ) ||
                        Decimal.valueOf(counter.split('#')[i-1]) < 0 ) {

                            System.debug(lsr.quantity);
                            Decimal value = Decimal.valueOf(counter.split('#')[i-1]) == null ? 0 : Decimal.valueOf(counter.split('#')[i-1]);
                            value *= lsr.quantity;
                            cou.currentOrderValue += value;

                            if (value < 0) {
                                cou.debitValueOnOrder = (cou.debitValueOnOrder != null ? cou.debitValueOnOrder : 0) + value;
                            } else {
                                cou.creditValueOnOrder = (cou.creditValueOnOrder != null ? cou.creditValueOnOrder : 0) + value;
                                cou.balancePlusCreditOnOrder += value;
                            }
                        }
                    }
                }
            }

            if(String.isBlank(cou.description)){
                cou.displayInfoMessage = false;
            }
            else{
                cou.displayInfoMessage = true;
            }

            m_counters.put(i, cou);
            system.debug('>>>> counter ' + i + ' : ' + cou);
        
        }

        return m_counters;
    }

    public static void calculateCountersWithBOChanges(List<Contact> lContact, Map<Id, Contact> mOld) {

        List<Contact> lContactToUpdate = new List<Contact>();

        // Go through the contact to check if the BO has changed some counters
        for (Contact c : lContact) {
            Integer i = 1;
            for (i = 1 ; i <= 30 ; i++) {
                if (c.get('LU_Counter_' + i + '_BO_Changes__c') != mOld.get(c.Id).get('LU_Counter_' + i + '_BO_Changes__c')) {
                    lContactToUpdate.add(c); break;
                }
            }
        }

        if (!lContactToUpdate.isEmpty()) {

            for (Contact c : lContactToUpdate) {

                Integer i = 1;
                for (i = 1 ; i <= 30 ; i++) {
                    Decimal counterBalance = ( (Decimal)c.get('LU_Counter_' + i + '__c') != null ? 
                                                (Decimal)c.get('LU_Counter_' + i + '__c') : 
                                                0);
                    Decimal BOChanges = ( (Decimal)c.get('LU_Counter_' + i + '_BO_Changes__c') != null ? 
                                            (Decimal)c.get('LU_Counter_' + i + '_BO_Changes__c') : 
                                            0);
                    if (BOChanges != 0) {
                        counterBalance = counterBalance + BOChanges;
                        c.put('LU_Counter_' + i + '__c', counterBalance);
                        c.put('LU_Counter_' + i + '_BO_Changes__c', 0);
                    }
                    
                }
            }
        }
    }

    @AuraEnabled
    public static void updateCountersBackToDraft(String idOrder){

        Map<Integer, Counter> m_counters = new Map<Integer, Counter>();
        Counter cou = null;

        // Get the contact of the order
        List<Order> lOrder = [SELECT Id, BillToContactId FROM Order WHERE Id = :idOrder];
        String idCurrentUserContact = null;
        if (lOrder.isEmpty()) {
            idCurrentUserContact = AP1002_Utils_User.getConnectedUserContact().Id;
        } else {
            idCurrentUserContact = lOrder[0].BillToContactId;
        }
         

        List<String> l_fieldsToRequest = new List<String>{'Id',
        'LU_Counter_1__c', 'LU_Counter_2__c', 'LU_Counter_3__c', 'LU_Counter_4__c', 'LU_Counter_5__c', 'LU_Counter_6__c', 'LU_Counter_7__c', 'LU_Counter_8__c', 'LU_Counter_9__c', 'LU_Counter_10__c', 'LU_Counter_11__c', 'LU_Counter_12__c', 'LU_Counter_13__c', 'LU_Counter_14__c', 'LU_Counter_15__c', 'LU_Counter_16__c', 'LU_Counter_17__c', 'LU_Counter_18__c', 'LU_Counter_19__c', 'LU_Counter_20__c', 'LU_Counter_21__c', 'LU_Counter_22__c', 'LU_Counter_23__c', 'LU_Counter_24__c', 'LU_Counter_25__c', 'LU_Counter_26__c', 'LU_Counter_27__c', 'LU_Counter_28__c', 'LU_Counter_29__c', 'LU_Counter_30__c', 
        'LU_Counter_1_Lower_Limit__c', 'LU_Counter_2_Lower_Limit__c', 'LU_Counter_3_Lower_Limit__c', 'LU_Counter_4_Lower_Limit__c', 'LU_Counter_5_Lower_Limit__c', 'LU_Counter_6_Lower_Limit__c', 'LU_Counter_7_Lower_Limit__c', 'LU_Counter_8_Lower_Limit__c', 'LU_Counter_9_Lower_Limit__c', 'LU_Counter_10_Lower_Limit__c', 'LU_Counter_11_Lower_Limit__c', 'LU_Counter_12_Lower_Limit__c', 'LU_Counter_13_Lower_Limit__c', 'LU_Counter_14_Lower_Limit__c', 'LU_Counter_15_Lower_Limit__c', 'LU_Counter_16_Lower_Limit__c', 'LU_Counter_17_Lower_Limit__c', 'LU_Counter_18_Lower_Limit__c', 'LU_Counter_19_Lower_Limit__c', 'LU_Counter_20_Lower_Limit__c', 'LU_Counter_21_Lower_Limit__c', 'LU_Counter_22_Lower_Limit__c', 'LU_Counter_23_Lower_Limit__c', 'LU_Counter_24_Lower_Limit__c', 'LU_Counter_25_Lower_Limit__c', 'LU_Counter_26_Lower_Limit__c', 'LU_Counter_27_Lower_Limit__c', 'LU_Counter_28_Lower_Limit__c', 'LU_Counter_29_Lower_Limit__c', 'LU_Counter_30_Lower_Limit__c', 
        'LU_Counter_1_High_Limit__c', 'LU_Counter_2_High_Limit__c', 'LU_Counter_3_High_Limit__c', 'LU_Counter_4_High_Limit__c', 'LU_Counter_5_High_Limit__c', 'LU_Counter_6_High_Limit__c', 'LU_Counter_7_High_Limit__c', 'LU_Counter_8_High_Limit__c', 'LU_Counter_9_High_Limit__c', 'LU_Counter_10_High_Limit__c', 'LU_Counter_11_High_Limit__c', 'LU_Counter_12_High_Limit__c', 'LU_Counter_13_High_Limit__c', 'LU_Counter_14_High_Limit__c', 'LU_Counter_15_High_Limit__c', 'LU_Counter_16_High_Limit__c', 'LU_Counter_17_High_Limit__c', 'LU_Counter_18_High_Limit__c', 'LU_Counter_19_High_Limit__c', 'LU_Counter_20_High_Limit__c','LU_Counter_21_High_Limit__c', 'LU_Counter_22_High_Limit__c', 'LU_Counter_23_High_Limit__c', 'LU_Counter_24_High_Limit__c', 'LU_Counter_25_High_Limit__c', 'LU_Counter_26_High_Limit__c', 'LU_Counter_27_High_Limit__c', 'LU_Counter_28_High_Limit__c', 'LU_Counter_29_High_Limit__c', 'LU_Counter_30_High_Limit__c'};
        Sobject c = Database.query('SELECT ' + String.join(l_fieldsToRequest, ',') + ' FROM Contact WHERE Id = :idCurrentUserContact');

        Map<Integer, Decimal> m_valuePerCounter = new Map<Integer, Decimal>();

        for(Sobject oi : [SELECT Quantity, PricebookEntryId, LU_Counter_1_new__c, LU_Counter_2_new__c, LU_Counter_3_new__c, LU_Counter_4_new__c, LU_Counter_5_new__c, LU_Counter_6_new__c, 
                            LU_Counter_7_new__c, LU_Counter_8_new__c, LU_Counter_9_new__c, LU_Counter_10_new__c, LU_Counter_11_new__c, LU_Counter_12_new__c, LU_Counter_13_new__c, 
                            LU_Counter_14_new__c, LU_Counter_15_new__c, LU_Counter_16_new__c, LU_Counter_17_new__c, LU_Counter_18_new__c, LU_Counter_19_new__c, LU_Counter_20_new__c,
                            LU_Counter_21_new__c, LU_Counter_22_new__c, LU_Counter_23_new__c, LU_Counter_24_new__c, LU_Counter_25_new__c, LU_Counter_26_new__c, LU_Counter_27_new__c, 
                            LU_Counter_28_new__c, LU_Counter_29_new__c, LU_Counter_30_new__c,
                            TECH_Counters_Not_Count_Credit_Value__c
                            FROM OrderItem 
                            WHERE OrderId = :idOrder]){
                                system.debug('>>>> COMPLEMENT : ' );
                                system.debug(oi);
            Set<String> lCountersNotToCountCreditForLine = null;
            String countersCreditNotToCount = ((OrderItem)oi).TECH_Counters_Not_Count_Credit_Value__c;
            if (countersCreditNotToCount != null && countersCreditNotToCount != '') {
                lCountersNotToCountCreditForLine = new Set<String>(countersCreditNotToCount.split('#'));
            }
            system.debug('>>>> lCountersNotToCountCreditForLine : ' );
            system.debug(lCountersNotToCountCreditForLine);
            for (Integer i = 1; i <= 30; i++) {
                system.debug('>>> COUNTER ' + i);
                if (lCountersNotToCountCreditForLine == null || 
                    (lCountersNotToCountCreditForLine != null && !lCountersNotToCountCreditForLine.contains(i + '')) ) {
                        system.debug('>> count');
                        if(!m_valuePerCounter.containsKey(i)){
                            m_valuePerCounter.put(i, 0);
                        }
                        system.debug('>> OLD VALUE : ' + m_valuePerCounter.get(i));
                        system.debug('>> VALUE TO BE ADDED: ' + (Decimal) oi.get('LU_Counter_' + i + '_new__c'));
                        if(oi.get('LU_Counter_' + i + '_new__c') != null){
                            m_valuePerCounter.put(i, m_valuePerCounter.get(i) + (Decimal) oi.get('LU_Counter_' + i + '_new__c'));
                        }
                        system.debug('>> NEW VALUE : ' + m_valuePerCounter.get(i));
                }
                    
            }
        }
        
        system.debug('>>> CONTACT BEFORE CHANGES');
        system.debug(c);
        for (Integer i = 1; i <= 30; i++) {

            if (m_valuePerCounter.get(i) != null && c.get('LU_Counter_' + i + '__c') != null) {
                if((Decimal) c.get('LU_Counter_' + i + '__c') - m_valuePerCounter.get(i) > (Decimal) c.get('LU_Counter_' + i + '_High_Limit__c')){
                    c.put('LU_Counter_' + i + '__c', (Decimal) c.get('LU_Counter_' + i + '_High_Limit__c'));
                }
                else if((Decimal) c.get('LU_Counter_' + i + '__c') - m_valuePerCounter.get(i) < (Decimal) c.get('LU_Counter_' + i + '_Lower_Limit__c')){
                    c.put('LU_Counter_' + i + '__c', (Decimal) c.get('LU_Counter_' + i + '_Lower_Limit__c'));
                }
                else{
                    c.put('LU_Counter_' + i + '__c', (Decimal) c.get('LU_Counter_' + i + '__c') - m_valuePerCounter.get(i));
                }
            }
            
        }

        system.debug('>>> CONTACT AFTER CHANGES');
        system.debug(c);

        update c;
    }
    
}