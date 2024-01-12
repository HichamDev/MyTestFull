@IsTest
public class AP1000_Utils_Test {

    public final static String FRA_OFFERTYPE_STANDARD = '1. STANDARD';
    public final static String FRA_OFFERTYPE_PUP = '2. PUP';
    public final static String FRA_CONTACT_ELIGIBILITY_GROUPS = '1#2#3';
    public final static String FRA_CONTACT_COUNTERS_UNITS = 'EURO#EURO#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#EURO#EURO#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS#POINTS';
    public final static String FRA_CONTACT_COUNTERS_TOBEDISPLAYED = '1#2#3#4#5#6';
    public final static String FRA_OR_COMMISSION_RATERANGES = '1#2#3#4';
    public final static List<CounterContactWrapper> FRA_CONTACT_COUNTERS = new List<CounterContactWrapper>{
        new CounterContactWrapper(10, 'Counter1#Description', 0, 100), new CounterContactWrapper(10, 'Counter2#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter3#Description', 0, 100), new CounterContactWrapper(10, 'Counter4#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter5#Description', 0, 100), new CounterContactWrapper(10, 'Counter6#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter7#Description', 0, 100), new CounterContactWrapper(10, 'Counter8#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter9#Description', 0, 100), new CounterContactWrapper(10, 'Counter10#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter11#Description', 0, 100), new CounterContactWrapper(10, 'Counter12#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter13#Description', 0, 100), new CounterContactWrapper(10, 'Counter14#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter15#Description', 0, 100), new CounterContactWrapper(10, 'Counter16#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter17#Description', 0, 100), new CounterContactWrapper(10, 'Counter18#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter19#Description', 0, 100), new CounterContactWrapper(10, 'Counter20#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter21#Description', 0, 100), new CounterContactWrapper(10, 'Counter22#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter23#Description', 0, 100), new CounterContactWrapper(10, 'Counter24#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter25#Description', 0, 100), new CounterContactWrapper(10, 'Counter26#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter27#Description', 0, 100), new CounterContactWrapper(10, 'Counter28#Description', 0, 100),
        new CounterContactWrapper(10, 'Counter29#Description', 0, 100), new CounterContactWrapper(10, 'Counter30#Description', 0, 100) 
    };
    public final static List<OrderRulesWrapper> FRA_ORDER_RULES = new List<OrderRulesWrapper>{
        // COMMISSION
        new OrderRulesWrapper('COMMISSION', 'LU_Order_Commission', '1#2', '201', 0.11), new OrderRulesWrapper('COMMISSION', 'LU_Order_Commission', '1#2', '202', 0.20),
        // ADMIN FEES
        new OrderRulesWrapper('ADMINFEES', 'LU_Order_Admin_Fees', '1#2', '201', 0.11), new OrderRulesWrapper('ADMINFEES', 'LU_Order_Admin_Fees', '1#2', '202', 0.20),
        // COUNTER CATEGORY
        new OrderRulesWrapper('COUNTER_CATEGORY', 'Counter_Category', true, 'Comptes', '1#2#3', 'Solde restant', 'doughnut'),
        new OrderRulesWrapper('COUNTER_CATEGORY', 'Counter_Category', true, 'PUP', '4', 'Solde restant', 'doughnut'),
        new OrderRulesWrapper('COUNTER_CATEGORY', 'Counter_Category', true, 'Documents', '11#12', 'Solde restant', 'bar'),
        // COUNTER RESET AFTER ORDER
        new OrderRulesWrapper('COUNTER_CATEGORY', 'Counter_Reset_After_An_Order', '3', 0),
        // COUNTER START AT
        new OrderRulesWrapper('COUNTER_CATEGORY', 'Order_Counter_Start_At', 150, 'Message displayed'),
        // STOCK LOW LIMIT
        new OrderRulesWrapper('STOCK_LOW_LIMIT', 'LU_Stock_Low_Limit_Threshold', 0.1, 'ATTENTION LOW LIMIT MESSAGE'),
        // SHIPPING MODE
        new OrderRulesWrapper('SHIPPING_MODE', 'Order_Shipping_Mode', true, 'Livraison à domicile', 'Standard', 1, true, '', '*', '', '', '', '', 0, '', 'FRA_STANDARD' ),
        new OrderRulesWrapper('SHIPPING_MODE', 'Order_Shipping_Mode', true, 'Livraison en point relais', 'Externe_Colissimo', 2, false, '', '*', 'LOGIN', 'PW', '10', 'http://endpoint.fr', 0, '24R', 'FRA_EXTERNAL'),
        // SHIPPING FEES
        new OrderRulesWrapper('SHIPPING_FEES', 'Order_Shipping_Fees', 'FRA_STANDARD', 'BtoBtoC', '<=', 25, '<=', 50, '>=', 0, '*', 5),
        new OrderRulesWrapper('SHIPPING_FEES', 'Order_Shipping_Fees', 'FRA_STANDARD', 'BtoBtoC', '<=', 25, '>', 50, '>=', 0, '*', 3),
        new OrderRulesWrapper('SHIPPING_FEES', 'Order_Shipping_Fees', 'FRA_EXTERNAL', 'BtoBtoC', '<=', 25, '<=', 50, '>=', 0, '*', 5),
        new OrderRulesWrapper('SHIPPING_FEES', 'Order_Shipping_Fees', 'FRA_EXTERNAL', 'BtoBtoC', '<=', 25, '>', 50, '>=', 0, '*', 3)
    };
    public final static List<OrderRulesWrapper> ITA_ORDER_RULES = new List<OrderRulesWrapper>{
        new OrderRulesWrapper('COMMISSION', 'LU_Order_Commission', '*', '201', 0.11), new OrderRulesWrapper('COMMISSION', 'LU_Order_Commission', '1#2#3#4#5#7#8', '202', 0.20)
    };

    /* WRAPPERS */
    public class CounterContactWrapper {
        public Decimal balance {get;set;}
        public String name {get;set;}
        public Decimal lowerLimit {get;set;}
        public Decimal higherLimit {get;set;}
        public CounterContactWrapper(Decimal balance, String name, Decimal lowerLimit, Decimal higherLimit) {
            this.balance = balance;
            this.name = name;
            this.lowerLimit = lowerLimit;
            this.higherLimit = higherLimit;
        }
    }

    public class OrderRulesWrapper {
        public String name {get;set;}
        public Boolean active {get;set;}
        public String rtDeveloperName {get;set;}
        public String description {get;set;}
        public String text {get;set;}
        public Decimal value {get;set;}
        public String chartType {get;set;}
        public String counterNumber {get;set;}
        public Decimal order {get;set;}
        public Boolean defaultSelected {get;set;}
        public String postalCodeExcluded {get;set;}
        public String profileApplicableFor {get;set;}
        public String serviceLogin {get;set;}
        public String servicePassword {get;set;}
        public String serviceParamText {get;set;}
        public String serviceEndpoint {get;set;}
        public Decimal serviceTimeout {get;set;}
        public String serviceParamText2 {get;set;}
        public String externalKey {get;set;}
        public String parentOrderRule {get;set;}
        public String orderType {get;set;}
        public String weightOperator {get;set;}
        public Decimal weightValue {get;set;}
        public String amountOperator {get;set;}
        public Decimal amountValue {get;set;}
        public String nbOrderOnCurrentCycleOperator {get;set;}
        public Decimal nbOrderOnCurrentCycleValue {get;set;}
        public String activitySegmentValue {get;set;}
        public Decimal fees {get;set;}

        // Shipping fees
        public OrderRulesWrapper(String orType, String rt, String parentOrderRule, String orderType, String weightOperator, Decimal weightValue, String amountOperator,
                                    Decimal amountValue, String nbOrderOnCurrentCycleOperator, Decimal nbOrderOnCurrentCycleValue, String activitySegmentValue, Decimal fees) {
            if (orType == 'SHIPPING_FEES') { this.rtDeveloperName = rt; this.parentOrderRule = parentOrderRule; this.orderType = orderType; this.weightOperator = weightOperator; 
                                            this.weightValue = weightValue; this.amountOperator = amountOperator; this.amountValue = amountValue; 
                                            this.nbOrderOnCurrentCycleOperator = nbOrderOnCurrentCycleOperator; this.nbOrderOnCurrentCycleValue = nbOrderOnCurrentCycleValue;
                                            this.activitySegmentValue = activitySegmentValue; this.fees = fees;}
        }
        // Shipping modes
        public OrderRulesWrapper(String orType, String rt, Boolean active, String name, String text, Decimal order, Boolean defaultSelected, String postalCodeExcluded,
                                String profileApplicableFor, String serviceLogin, String servicePassword, String serviceParamText, String serviceEndpoint, Decimal serviceTimeout,
                                String  serviceParamText2, String externalKey) {
            if (orType == 'SHIPPING_MODE') { this.rtDeveloperName = rt; this.active = active ; this.name = name; this.text = text; this.order = order;
                                            this.defaultSelected = defaultSelected; this.postalCodeExcluded = postalCodeExcluded; this.profileApplicableFor = profileApplicableFor;
                                        this.serviceLogin = serviceLogin; this.servicePassword = servicePassword; this.serviceParamText = serviceParamText; this.serviceEndpoint = serviceEndpoint;
                                        this.serviceTimeout = serviceTimeout; this.serviceParamText2 = serviceParamText2; this.externalKey = externalKey;}
        }
        // Commission | Admin fees
        public OrderRulesWrapper(String orType, String rt, String description, String text, Decimal value) {
            if (orType == 'COMMISSION' || orType == 'ADMINFEES') { this.rtDeveloperName = rt; this.description = description; this.text = text; this.value = value; }
        }
        // Counter Category
        public OrderRulesWrapper(String orType, String rt, Boolean active, String name, String description, String text, String chartType) {
            if (orType == 'COUNTER_CATEGORY') { this.rtDeveloperName = rt; this.active = active; this.name = name; this.description = description; this.text = text; this.chartType = chartType; }
        }
        // Counter reset after order
        public OrderRulesWrapper(String orType, String rt, String counterNumber, Decimal value) {
            if (orType == 'COUNTER_RESET') { this.rtDeveloperName = rt; this.counterNumber = counterNumber; this.value = value; }
        }
        // Counter start at
        public OrderRulesWrapper(String orType, String rt, String name, Decimal value, String text) {
            if (orType == 'COUNTER_STARTAT') { this.rtDeveloperName = rt; this.name = name; this.value = value; this.text = text; }
        }
        // Stock low limit
        public OrderRulesWrapper(String orType, String rt, Decimal value, String description) {
            if (orType == 'STOCK_LOW_LIMIT') { this.rtDeveloperName = rt; this.value = value; this.description = description; }
        }
    }


    /* UTILITY METHODS */

    /***** CONTACT FOR NEW ORDER TUNNEL *****/
    public static void setContactForNewOrderTunnel(Id contactId, String country) {
        Contact con = new Contact(Id = contactId);

        if (country == 'FRA') {
            // Activity segment
            con.ActivitySegment__c = 'Dealer';
            // Commission
            con.CommissionRateRange__c = '201';
            // Eligibility
            con.LU_Eligibility_Groups__c = FRA_CONTACT_ELIGIBILITY_GROUPS;
            // Counters
            con.LU_Counters_To_Be_Displayed__c = FRA_CONTACT_COUNTERS_TOBEDISPLAYED;
            con.LU_Counters_Unit__c = FRA_CONTACT_COUNTERS_UNITS;
            Integer cpt = 1;
            for (CounterContactWrapper wr : FRA_CONTACT_COUNTERS) {
                con.put('LU_Counter_' + cpt + '__c', wr.balance);
                con.put('LU_Counter_' + cpt + '_Name__c', wr.name);
                con.put('LU_Counter_' + cpt + '_Lower_Limit__c', wr.lowerLimit);
                con.put('LU_Counter_' + cpt + '_High_Limit__c', wr.higherLimit);
                cpt++;
            }
        }

        update con;
    }
    

    /*****  OFFERS ******/
    /* OFFERS : GENERAL METHODS */
    public static void generateOffers() {
        /* ORDER RULES */
        generateOrderRules('FRA');
        /* FRANCE */
        generateOffersForFrance();
        /* ITALY */
    }

    /* ORDER RULES */
    public static void generateOrderRules(String country) {

        // List<sObject> lRulesImported = Test.loadData(LU_Order_Rule__c.sObjectType, 'TESTDATA_OrderRules');

        List<RecordType> lRT = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'LU_Order_Rule__c'];

        List<OrderRulesWrapper> lOr = (country == 'FRA' ? FRA_ORDER_RULES : ITA_ORDER_RULES);

        List<LU_Order_Rule__c> lRules = new List<LU_Order_Rule__c>();
        List<LU_Order_Rule__c> lRulesInsertedAfter = new List<LU_Order_Rule__c>();
        for (OrderRulesWrapper wr : lOr) {

            LU_Order_Rule__c oRule = new LU_Order_Rule__c(LU_Country__c = country);
            Boolean toBeInsertedOnASecondTime = false;
            
            if (wr.rtDeveloperName == 'Order_Shipping_Fees') {
                toBeInsertedOnASecondTime = true;
            }

            // RecordType
            for (RecordType r : lRT) {
                if (r.DeveloperName == wr.rtDeveloperName) {
                    oRule.RecordTypeId = r.Id; break;
                }
            }
            // Values
            oRule.LU_Description__c = (wr.description != null ? wr.description : null);
            oRule.LU_Text__c = (wr.text != null ? wr.text : null);
            oRule.LU_Value__c = (wr.value != null ? wr.value : null);
            oRule.LU_Counter_Number__c = (wr.counterNumber != null ? wr.counterNumber : null);
            oRule.LU_Chart_Type__c = (wr.chartType != null ? wr.chartType : null);
            oRule.LU_Active__c = (wr.active != null? wr.active : false);
            oRule.LU_Order__c = (wr.order != null? wr.order : 0);
            oRule.LU_Default_Selected__c = (wr.defaultSelected != null? wr.defaultSelected : false);
            oRule.LU_Postal_Code_Excluded__c = (wr.postalCodeExcluded != null? wr.postalCodeExcluded : '');
            oRule.LU_Profile_Applicable_For__c = (wr.profileApplicableFor != null? wr.profileApplicableFor : '');
            oRule.LU_Service_Login__c = (wr.serviceLogin != null? wr.serviceLogin : '');
            oRule.LU_Service_Password__c = (wr.servicePassword != null? wr.servicePassword : '');
            oRule.LU_Service_Param_Text_1__c = (wr.serviceParamText != null? wr.serviceParamText : '');
            oRule.LU_Service_Endpoint__c = (wr.serviceEndpoint != null? wr.serviceEndpoint : '');
            oRule.LU_Service_Timeout__c = (wr.serviceTimeout != null? wr.serviceTimeout : 0);
            oRule.LU_Service_Param_Text_2__c = (wr.serviceParamText2 != null? wr.serviceParamText2 : '');
            oRule.LU_External_Id__c = (wr.externalKey != null ? wr.externalKey : '');
            if (wr.parentOrderRule != null) {
                oRule.LU_Parent_Order_Rule__r = new LU_Order_Rule__c(LU_External_Id__c = wr.parentOrderRule);
            }
            oRule.LU_Order_Type__c = (wr.orderType != null ? wr.orderType : '');
            oRule.LU_Weight_Operator__c = (wr.weightOperator != null ? wr.weightOperator : '');
            oRule.LU_Weight_Value__c = (wr.weightValue != null ? wr.weightValue : 0);
            oRule.LU_Amount_Operator__c = (wr.amountOperator != null ? wr.amountOperator : '');
            oRule.LU_Amount_Value__c = (wr.amountValue != null ? wr.amountValue : 0);
            oRule.LU_Nb_Order_On_Cycle_Operator__c = (wr.nbOrderOnCurrentCycleOperator != null ? wr.nbOrderOnCurrentCycleOperator : '');
            oRule.LU_Nb_Order_On_Cycle_Value__c = (wr.nbOrderOnCurrentCycleValue != null ? wr.nbOrderOnCurrentCycleValue : 0);
            oRule.LU_Activity_Segment_Value__c = (wr.activitySegmentValue != null ? wr.activitySegmentValue : '');
            oRule.Fees__c = (wr.fees != null ? wr.fees : 0);

            if (toBeInsertedOnASecondTime) {
                lRulesInsertedAfter.add(oRule);
            } else {
                lRules.add(oRule);
            }
        }

        insert lRules;

        if (!lRulesInsertedAfter.isEmpty()) {
            insert lRulesInsertedAfter;
        }
    }

    /* OFFERS : OFFERS FOR FRANCE FROM CSV FILE IN STATIC RESOURCES */
    public static void generateOffersForFrance() {

        Datetime startDate = Datetime.now().addDays(-1);
        Datetime endDate = Datetime.now().addDays(10);

        // Pricebook
        Pricebook2 pb = new Pricebook2(Name = 'Catalogue_standard', isActive = true, LU_Country__c = 'FRA', LU_Start_Date__c = startDate, LU_End_date__c = endDate,
                                        LU_Tech_External_Id__c = 'FRA_Pricebook_1');
        insert pb;

        // Product
        generateProducts('FRA');

        generatePricebookEntries('FRA', pb.Id);

    }

    public static void generateProducts(String country) {

        Id rtProduct = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Product2' AND DeveloperName = 'LU_Product' LIMIT 1].Id;
        Id rtBundle = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Product2' AND DeveloperName = 'LU_Bundle' LIMIT 1].Id;
        Id rtChild = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Product2' AND DeveloperName = 'LU_Child' LIMIT 1].Id;

        List<Product2> lProducts = new List<Product2>();
        List<Product2> lChild = new List<Product2>();
        /* FRANCE */
        if (country == 'FRA') {
            
            /* 1 - SIMPLE OFFERS */
            Product2 p1 = new Product2(Name = 'Simple Product 1', isActive = true, LU_Local_Code__c = '96992', LU_Local_Name__c = 'Simple Product 1', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_96992', LU_Country__c = country, RecordTypeId = rtProduct);
            lProducts.add(p1);
            Product2 p2 = new Product2(Name = 'Simple Product 2', isActive = true, LU_Local_Code__c = '96993', LU_Local_Name__c = 'Simple Product 2', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_96993', LU_Country__c = country, RecordTypeId = rtProduct);
            lProducts.add(p2);
            Product2 p3 = new Product2(Name = 'Simple Product 3', isActive = true, LU_Local_Code__c = '96994', LU_Local_Name__c = 'Simple Product 3', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_96994', LU_Country__c = country, RecordTypeId = rtProduct);
            lProducts.add(p3);

            /* 2 - SIMPLE OFFERS that credit counter1 */
            Product2 p4 = new Product2(Name = 'Simple Product 4 - Credit 1', isActive = true, LU_Local_Code__c = '97001', LU_Local_Name__c = 'Simple Product 4 - Credit 1', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_97001', LU_Country__c = country, RecordTypeId = rtProduct);
            lProducts.add(p4);

            /* 3 - OFFERS THAT DEBIT all counters */
            Product2 p5 = new Product2(Name = 'offer 5 - Debit counters', isActive = true, LU_Local_Code__c = '50001', LU_Local_Name__c = 'offer 5 - Debit counters', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_50001', LU_Country__c = country, RecordTypeId = rtProduct);
            lProducts.add(p5);
            
            /* 4 - PUP */
            Product2 p6 = new Product2(Name = 'offer 6 - PUP', isActive = true, LU_Local_Code__c = '40001', LU_Local_Name__c = 'offer 6 - PUP', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_40001', LU_Country__c = country, RecordTypeId = rtProduct);
            lProducts.add(p6);

            /* 5 - BUNDLE CLOSED STANDARD */
            Product2 p7 = new Product2(Name = 'offer 7 - Bundle Closed Parent', isActive = true, LU_Local_Code__c = '30001', LU_Local_Name__c = 'offer 7 - Bundle Closed Parent', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_30001', LU_Country__c = country, RecordTypeId = rtBundle,
                                        LU_Bundle_Type__c = 'CloseSet', LU_Number_Of_Articles__c = 2);
            lProducts.add(p7);
            Product2 p8 = new Product2(Name = 'offer 8 - Bundle Open Parent', isActive = true, LU_Local_Code__c = '30002', LU_Local_Name__c = 'offer 8 - Bundle Open Parent', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_30002', LU_Country__c = country, RecordTypeId = rtBundle,
                                        LU_Bundle_Type__c = 'OpenSet', LU_Number_Of_Articles__c = 2);
            lProducts.add(p8);
    
            /* 6 - STOCK PRODUCTS */
            Product2 p9 = new Product2(Name = 'offer 9 - Product Stock', isActive = true, LU_Local_Code__c = '1001', LU_Local_Name__c = 'offer 9 - Product Stock', 
                                        LU_Stock_Status__c = 'Dynamic', LU_TECH_External_Id__c = country+'_PRODUCT_1001', LU_Country__c = country, RecordTypeId = rtProduct,
                                        LU_Stock_Available__c = 10, LU_Stock_Substitution_Products__c = '1002');
            lProducts.add(p9);
            Product2 p11 = new Product2(Name = 'offer 10 - Product Stock SUBSITUTE', isActive = true, LU_Local_Code__c = '1002', LU_Local_Name__c = 'offer 10 - Product Stock SUBSITUTE', 
                                        LU_Stock_Status__c = 'Dynamic', LU_TECH_External_Id__c = country+'_PRODUCT_1002', LU_Country__c = country, RecordTypeId = rtProduct,
                                        LU_Stock_Available__c = 10, LU_Stock_Substitution_Products__c = '');
            lProducts.add(p11);
            Product2 p10 = new Product2(Name = 'offer 10 - Product Stock limited', isActive = true, LU_Local_Code__c = '1003', LU_Local_Name__c = 'offer 10 - Product Stock Limited', 
                                        LU_Stock_Status__c = 'Limited quantity', LU_TECH_External_Id__c = country+'_PRODUCT_1003', LU_Country__c = country, RecordTypeId = rtProduct,
                                        LU_Stock_Available__c = 0, LU_Stock_Substitution_Products__c = '1002');
            lProducts.add(p10);
            Product2 p12 = new Product2(Name = 'offer 12 - Product Stock out', isActive = true, LU_Local_Code__c = '1004', LU_Local_Name__c = 'offer 10 - Product Stock out', 
                                        LU_Stock_Status__c = 'Out-of-stock', LU_TECH_External_Id__c = country+'_PRODUCT_1004', LU_Country__c = country, RecordTypeId = rtProduct,
                                        LU_Stock_Available__c = 0);
            lProducts.add(p12);

            /* LIMITED QUANTITY PRODUCT */
            Product2 p13 = new Product2(Name = 'Simple Product 13 - limited quantity', isActive = true, LU_Local_Code__c = '876374', LU_Local_Name__c = 'Simple Product 13 - limited quantity', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_876374', LU_Country__c = country, RecordTypeId = rtProduct);
            lProducts.add(p13);

            // INSERT PRODUCTS
            insert lProducts;

            // Insert Child of the bundle offers
            Product2 p7a = new Product2(Name = 'offer 7 - Child 1 Closed', isActive = true, LU_Local_Code__c = '300011', LU_Local_Name__c = 'offer 7 - Child 1 Closed', 
                                            LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_300011', LU_Country__c = country, 
                                            RecordTypeId = rtChild, LU_Parent_Product__c = p7.Id, LU_Type_Child__c = 'NoSelect', 
                                            LU_Min_Qty_Orderable__c = 1, LU_Max_Qty_Orderable__c = 1);
            lChild.add(p7a);
            Product2 p7b = new Product2(Name = 'offer 7 - Child 2 Closed', isActive = true, LU_Local_Code__c = '300012', LU_Local_Name__c = 'offer 7 - Child 2 Closed', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_300012', LU_Country__c = country, 
                                        RecordTypeId = rtChild, LU_Parent_Product__c = p7.Id, LU_Type_Child__c = 'NoSelect', 
                                        LU_Min_Qty_Orderable__c = 1, LU_Max_Qty_Orderable__c = 1);
            lChild.add(p7b);
            Product2 p8a = new Product2(Name = 'offer 8 - Child 1 Closed', isActive = true, LU_Local_Code__c = '300021', LU_Local_Name__c = 'offer 8 - Child 1 Closed', 
                                            LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_300021', LU_Country__c = country, 
                                            RecordTypeId = rtChild, LU_Parent_Product__c = p8.Id, LU_Type_Child__c = 'NoSelect', 
                                            LU_Min_Qty_Orderable__c = 1, LU_Max_Qty_Orderable__c = 1);
            lChild.add(p8a);
            Product2 p8b = new Product2(Name = 'offer 8 - Child 2 Open', isActive = true, LU_Local_Code__c = '300022', LU_Local_Name__c = 'offer 8 - Child 2 Open', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_300022', LU_Country__c = country, 
                                        RecordTypeId = rtChild, LU_Parent_Product__c = p8.Id, LU_Type_Child__c = 'Select', 
                                        LU_Min_Qty_Orderable__c = 0, LU_Max_Qty_Orderable__c = 1);
            lChild.add(p8b);
            Product2 p8c = new Product2(Name = 'offer 8 - Child 3 Open', isActive = true, LU_Local_Code__c = '300023', LU_Local_Name__c = 'offer 8 - Child 3 Open', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_300023', LU_Country__c = country, 
                                        RecordTypeId = rtChild, LU_Parent_Product__c = p8.Id, LU_Type_Child__c = 'Select', 
                                        LU_Min_Qty_Orderable__c = 0, LU_Max_Qty_Orderable__c = 1);
            lChild.add(p8c);

            insert lChild;
            
        } if (country == 'ITA') {

            Product2 p1 = new Product2(Name = 'Simple Product 1', isActive = true, LU_Local_Code__c = '96992', LU_Local_Name__c = 'Simple Product 1', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_96992', LU_Country__c = country, RecordTypeId = rtProduct);
            lProducts.add(p1);

            Product2 p2 = new Product2(Name = 'Simple Product 2', isActive = true, LU_Local_Code__c = '96993', LU_Local_Name__c = 'Simple Product 2', 
                                        LU_Stock_Status__c = 'Available', LU_TECH_External_Id__c = country+'_PRODUCT_96993', LU_Country__c = country, RecordTypeId = rtProduct);
            lProducts.add(p2);

            // INSERT PRODUCTS
            insert lProducts;
        }
        
    }


    public static void generatePricebookEntries(String country, Id pbId) {

        if (country == 'FRA') {
            List<Product2> lProducts = [SELECT Id, LU_TECH_External_Id__c, LU_Local_Code__c 
                                        FROM Product2 
                                        WHERE ( RecordType.DeveloperName = 'LU_Product' OR RecordType.DeveloperName = 'LU_Bundle' )
                                        AND LU_TECH_External_Id__c LIKE :'FRA%'];

            Datetime startDate = Datetime.now().addDays(-1);
            Datetime endDate = Datetime.now().addDays(10);
            Integer cpt = 0;
            List<PricebookEntry> lEntries = new List<PricebookEntry>();
            for (Product2 p : lProducts) {
                // OFFERS : Simple price only in euros, Offer type : 1. Standard
                if (p.LU_Local_Code__c == '96992' || p.LU_Local_Code__c == '96993' || p.LU_Local_Code__c == '96994' || p.LU_Local_Code__c == '30001' || 
                    p.LU_Local_Code__c == '30002' || p.LU_Local_Code__c == '1001' || p.LU_Local_Code__c == '1002' || p.LU_Local_Code__c == '1003' || p.LU_Local_Code__c == '1004') {
                    lEntries.add(createPricebookEntry(pbId, p.Id, 10, true, true, '1#2', true, new List<Decimal>{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 10, '',
                                                '*', 20, FRA_OFFERTYPE_STANDARD, 10, startDate, endDate, country+'_' + p.LU_Local_Code__c + '_' + cpt, true));
                }

                // OFFERS : Limited quantity
                if (p.LU_Local_Code__c == '876374') {
                    PricebookEntry pbe = createPricebookEntry(pbId, p.Id, 10, true, true, '1#2', true, new List<Decimal>{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 10, '',
                                                '*', 10, FRA_OFFERTYPE_STANDARD, 10, startDate, endDate, country+'_' + p.LU_Local_Code__c + '_' + cpt, true);
                    pbe.LU_Limited_Quantity_Period__c = true;
                    pbe.LU_Limited_Quantity_Start_Date__c = startDate;
                    pbe.LU_Limited_Quantity_End_Date__c = endDate;
                    pbe.LU_Limited_Quantity_Value__c = 3;
                    lEntries.add(pbe);
                }

                // OFFERS : Simple price only in euros, offer type 1. Standard, credit counter 1 and 2 and 3 and 7
                if (p.LU_Local_Code__c == '97001') {
                    lEntries.add(createPricebookEntry(pbId, p.Id, 10, true, true, '1#2', true, new List<Decimal>{5, 5, 5, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 10, '',
                                                '*', 10, FRA_OFFERTYPE_STANDARD, 10, startDate, endDate, country+'_' + p.LU_Local_Code__c + '_' + cpt, true));
                }

                // OFFERS : price in euros and in points counters, offer type 1. Standard, credit counter 1
                if (p.LU_Local_Code__c == '50001') {
                    lEntries.add(createPricebookEntry(pbId, p.Id, 10, true, true, '1#2', true, new List<Decimal>{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, 10, '',
                                                '*', 20, FRA_OFFERTYPE_STANDARD, 10, startDate, endDate, country+'_' + p.LU_Local_Code__c + '_' + cpt, true));
                }

                // OFFERS : PUP
                if (p.LU_Local_Code__c == '40001') {
                    lEntries.add(createPricebookEntry(pbId, p.Id, 10, true, true, '1#2', true, new List<Decimal>{0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 10, '',
                                                '*', 10, FRA_OFFERTYPE_PUP, 10, startDate, endDate, country+'_' + p.LU_Local_Code__c + '_' + cpt, false));
                }
                cpt++;
            }

            insert lEntries;
        }
        else if (country == 'ITA') {
            List<Product2> lProducts = [SELECT Id, LU_TECH_External_Id__c, LU_Local_Code__c 
                                        FROM Product2 
                                        WHERE ( RecordType.DeveloperName = 'LU_Product' OR RecordType.DeveloperName = 'LU_Bundle' )
                                        AND LU_TECH_External_Id__c LIKE :'ITA%'];

            Datetime startDate = Datetime.now().addDays(-1);
            Datetime endDate = Datetime.now().addDays(10);
            Integer cpt = 0;
            List<PricebookEntry> lEntries = new List<PricebookEntry>();
            for (Product2 p : lProducts) {
                // OFFERS : Simple price only in euros, Offer type : 1. Standard
                
                    lEntries.add(createPricebookEntry(pbId, p.Id, 10, true, true, '1#2', true, new List<Decimal>{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 10, '',
                                                '*', 20, FRA_OFFERTYPE_STANDARD, 10, startDate, endDate, 'ITA_96992_0', true));
                
                cpt++;
            }

            insert lEntries;
        }

    }

    public static PricebookEntry createPricebookEntry(Id pbId, Id productId, Decimal unitPrice, Boolean isActive, Boolean adminFees, String categoryCommission,
                                            Boolean comm, List<Decimal> tCounters, Decimal dealerPrice, String description,
                                            String eligibilitySegments, Decimal maxQty, String offerType, Decimal publicPrice, Datetime startDate, Datetime endDate,
                                            String externalId, Boolean validTotal) {
        PricebookEntry entry = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productId, UnitPrice = unitPrice, LU_Valid_For_Total_Amount_Base__c = validTotal,
                                                isActive = isActive, LU_Admin_Fees__c = adminFees, LU_Category_Level_Commission__c = categoryCommission,
                                                LU_Commissionable__c = comm,
                                                LU_Dealer_Price__c = dealerPrice, LU_Description__c = description, 
                                                LU_Eligibility_Segments__c = eligibilitySegments, LU_Maximum_Quantity__c = maxQty, LU_Offer_type__c = offerType,
                                                LU_Public_Price__c = publicPrice, LU_Start_Date__c = startDate, LU_End_Date__c = endDate, LU_TECH_External_Id__c = externalId
                                                );

        entry.LU_Counter_Value__c = tCounters[0] + '#' + tCounters[1] + '#' + tCounters[2] + '#' + tCounters[3] + '#' + tCounters[4] + '#' + 
        tCounters[5] + '#' + tCounters[6] + '#' + tCounters[7] + '#' + tCounters[8] + '#' + tCounters[9] + '#' + tCounters[10] + '#' + 
        tCounters[11] + '#' + tCounters[12] + '#' + tCounters[13] + '#' + tCounters[14] + '#' + tCounters[15] + '#' + tCounters[16] + '#' + 
        tCounters[17] + '#' + tCounters[18] + '#' + tCounters[19] + '#' + tCounters[20] + '#' + tCounters[21] + '#' + tCounters[22] + '#' + 
        tCounters[23] + '#' + tCounters[24] + '#' + tCounters[25] + '#' + tCounters[26] + '#' + tCounters[27] + '#' + tCounters[28] + '#' + 
        tCounters[29];

        return (entry);
    }


    @IsTest
    static void testAP1000_Utils_Test() {
        Contact c = new Contact(LastName = 'LastName');
        insert c;

        List<SelectOption> l = AP1000_Utils.getPicklistOptions(c, 'Title');

        String rt = AP1000_Utils.getRecordTypeId(c.Id);

        String name = AP1000_Utils.getRecordTypeName(c.Id);

        AP1000_Utils.isManager(UserInfo.getUserId());
    }
}