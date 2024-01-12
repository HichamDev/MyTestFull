public without sharing class lwc70_order_detail_basket_view_Ctrl {
    
    /* WRAPPER */

    // Order interpretation with groupment by customer / dealer
    public class Baskets {
        @AuraEnabled
        public String status {get;set;} // Status of the Order
        @AuraEnabled
        public String clientFirstName {get;set;} // client FirstName
        @AuraEnabled
        public String clientLastName {get;set;} // client LastName
        @AuraEnabled
        public String allowedPaymentMode {get;set;} // Allowed payment mode of order's contact
        @AuraEnabled
        public String externalId {get;set;} // External Id of the Order
        @AuraEnabled
        public Id dealerOfOrder {get;set;}
        @AuraEnabled
        public Id idOrder {get;set;} // ID of the Order
        @AuraEnabled
        public Date dateOrder {get;set;} // Date of the order 'EffectiveDate'
        @AuraEnabled
        public Decimal totalOrder {get;set;} // Total price with taxes of the order
        @AuraEnabled
        public Decimal totalWithoutVATOrder {get;set;} // Total price without taxes of the order
        @AuraEnabled
        public Decimal totalValidForTotalBase {get;set;} // Total price valid for calculation of minimum of order
        @AuraEnabled
        public Map<String, BasketsByType> mBasketsByType {get;set;} // basket grouped by offer type, then by contact
        @AuraEnabled
        public Map<String, BasketsByPerson> mBasketsByPerson {get;set;} // basket grouped by offer type, then by contact
        @AuraEnabled
        public Map<String, BasketsByCatalog> mBasketsByCatalog {get;set;} // basket grouped by offer type, then by contact
        @AuraEnabled
        public Decimal bo_total_with_taxes {get;set;}
        @AuraEnabled
        public Decimal bo_total_without_taxes {get;set;}
        @AuraEnabled
        public String orderType {get;set;}
        @AuraEnabled
        public Decimal bo_taxes {get;set;}
        @AuraEnabled
        public Decimal bo_commission {get;set;}
        @AuraEnabled
        public Decimal bo_total_amount_to_pay {get;set;}
        
    }

    public class BasketsByType {
        @AuraEnabled
        public String basketType {get;set;} // OFFer type of the basket type
        @AuraEnabled
        public Map<Id, Basket> baskets {get;set;} // Map of baskets regrouped by Contact Id
    }

    public class BasketsByPerson {
        @AuraEnabled
        public PersonFor person {get;set;} // Dealer / Customer of the basket
        @AuraEnabled
        public Basket basket {get;set;} // Map of baskets regrouped by Contact Id
    }

    public class BasketsByCatalog {
        @AuraEnabled
        public String basketType {get;set;} // OFFer type of the basket type
        @AuraEnabled
        public Basket basket {get;set;} // Map of baskets regrouped by Contact Id
    }

    // Basket so : a customer / dealer + the lines of the order for this person
    public class Basket {
        @AuraEnabled
        public PersonFor contact {get;set;} // Customer / dealer of this basket
        @AuraEnabled
        public List<OrderItem> lines {get;set;} // Lines of order for this basket
        @AuraEnabled
        public Decimal total {get;set;} // Sum of the total price of the lines of this basket
        @AuraEnabled
        public Decimal totalWithoutTax {get;set;} // Sum of the total without tax price of the lines of this basket
        @AuraEnabled
        public Decimal nbProduct {get;set;} // Number of product (sum of quantity) of the lines of this basket
        @AuraEnabled
        public Decimal totalWithoutDiscount {get;set;} // Sum of the total without discounted price
        @AuraEnabled
        public Boolean hasDiscount {get;set;} // True if the basket has a discount
        @AuraEnabled
        public Boolean isPersonalUse {get;set;} // OFFer type of the basket type
        @AuraEnabled 
        public List<OrderItem> l_childs {get;set;} // OFFer type of the basket type
    }

    // Customer / dealer information 
    public class PersonFor {
        @AuraEnabled
        public String personId {get;set;} // Contact Id
        @AuraEnabled
        public String lastname {get;set;} // Contact Lastname
        @AuraEnabled
        public String firstname {get;set;} // Contact Firstname
    }


    public class UserConnected {
        @AuraEnabled
        public User connectedUser {get;set;}
        @AuraEnabled
        public Contact connectedContact {get;set;}
        @AuraEnabled
        public Boolean canOrderOnBehalf {get;set;}
    }

    @AuraEnabled
    public static Baskets getOrderById(String orderId, string orderBy) {
        String country = AP1002_Utils_User.getUserCountry(UserInfo.getUserId());

        if(orderBy == LABEL.LU_0rder_Detail_By_Customer && country == 'ITA'){
            return getOrderSortedByCustomerITA(orderId);
        }
        else if(orderBy == LABEL.LU_0rder_Detail_By_Customer && country == 'FRA'){
            return getOrderSortedByCustomerFRA(orderId);
        }
        else{
            return getOrderSortedByCatalog(orderId, country);
        }
    }

    /* UI METHODS */
    // Get order in parameter and build the baskets to be displayed
    @AuraEnabled
    public static Baskets getOrderSortedByCustomerITA(String orderId) {
        
        // Init basket
        Baskets order = new Baskets();
        order.idOrder = orderId;
        order.mBasketsByType = null;

        // Query the order header
        List<Order> lOrder = [SELECT Id, BillToContactId, LU_Total_Amount_For_Valid_Base__c, LU_Total_Price_Without_Taxes__c, EffectiveDate, TotalAmount, Status, 
                                Tech_External_Id__c, BillToContact.AllowedPaymentMode__c, Type
                                FROM Order
                                WHERE Id = :orderId];
        if (!lOrder.isEmpty()) {

            order.dealerOfOrder = lOrder[0].BillToContactId;
            order.externalId = lOrder[0].Tech_External_Id__c;
            order.status = lOrder[0].Status;
            order.orderType = lOrder[0].Type;
            order.dateOrder = lOrder[0].EffectiveDate;
            order.totalOrder = lOrder[0].TotalAmount;
            order.totalWithoutVATOrder = lOrder[0].LU_Total_Price_Without_Taxes__c;
            order.totalValidForTotalBase = lOrder[0].LU_Total_Amount_For_Valid_Base__c;
            order.allowedPaymentMode = lOrder[0].BillToContact.AllowedPaymentMode__c;

            Contact con = [SELECT LU_Counter_1_Name__c
                                    ,LU_Counter_2_Name__c
                                    ,LU_Counter_3_Name__c
                                    ,LU_Counter_4_Name__c
                                    ,LU_Counter_5_Name__c
                                    ,LU_Counter_6_Name__c
                                    ,LU_Counter_7_Name__c
                                    ,LU_Counter_8_Name__c
                                    ,LU_Counter_9_Name__c
                                    ,LU_Counter_10_Name__c
                                    ,LU_Counter_11_Name__c
                                    ,LU_Counter_12_Name__c
                                    ,LU_Counter_13_Name__c
                                    ,LU_Counter_14_Name__c
                                    ,LU_Counter_15_Name__c
                                    ,LU_Counter_16_Name__c
                                    ,LU_Counter_17_Name__c
                                    ,LU_Counter_18_Name__c
                                    ,LU_Counter_19_Name__c
                                    ,LU_Counter_20_Name__c
                                    ,LU_Counter_21_Name__c
                                    ,LU_Counter_22_Name__c
                                    ,LU_Counter_23_Name__c
                                    ,LU_Counter_24_Name__c
                                    ,LU_Counter_25_Name__c
                                    ,LU_Counter_26_Name__c
                                    ,LU_Counter_27_Name__c
                                    ,LU_Counter_28_Name__c
                                    ,LU_Counter_29_Name__c
                                    ,LU_Counter_30_Name__c
                                    ,LU_Counters_To_Be_Displayed__c
                                    ,LU_Counters_Unit__c
                                    ,LU_Counters_Unit_Bis__c
                            FROM Contact
                            WHERE Id = :lOrder[0].BillToContactId];

            // Query the system to get the current order
            List<OrderItem>  lLines = null;
            
            /*Start - SFT-1702, Challenge linked products will not be visible in draft mode*/
            if(order.status == 'Draft') {
                lLines = [SELECT Id, OrderId, Order.LU_Total_Amount_For_Valid_Base__c, Order.LU_Total_Price_Without_Taxes__c, Order.EffectiveDate, 
                                        Order.TotalAmount, Order.Status, Product2.RecordType.DeveloperName, Product2.LU_Bundle_Type__c, Product2Id,
                                        Product2.LU_Local_Code__c, Product2.Name, PricebookEntryId, PricebookEntry.LU_Offer_type__c, 
                                        LU_Contact_For__c, LU_Contact_For__r.LastName, LU_Contact_For__r.FirstName, LU_TECH_Is_Bundle_Parent_Line__c,
                                        UnitPrice, Quantity, TotalPrice, LU_Price_Without_Taxes__c, Description, Product2.LU_Number_Of_Articles__c,
                                        LU_Stock_Status__c, LU_Stock_Message__c, Personal_Use_Discount_Amount__c, LU_Discount_Amount__c, 
                                        LU_Has_Discount_Applied__c, LU_Total_Without_Discount__c, Product2.Description, PricebookEntry.LU_Counter_Value__c
                                        FROM OrderItem
                                    WHERE OrderId =: orderId 
                                        AND LU_Challenge_Linked__c = ''
                                        AND LU_Child_Product__c = null];
            } else {
                lLines = [SELECT Id, OrderId, Order.LU_Total_Amount_For_Valid_Base__c, Order.LU_Total_Price_Without_Taxes__c, Order.EffectiveDate, 
                                        Order.TotalAmount, Order.Status, Product2.RecordType.DeveloperName, Product2.LU_Bundle_Type__c, Product2Id,
                                        Product2.LU_Local_Code__c, Product2.Name, PricebookEntryId, PricebookEntry.LU_Offer_type__c, 
                                        LU_Contact_For__c, LU_Contact_For__r.LastName, LU_Contact_For__r.FirstName, LU_TECH_Is_Bundle_Parent_Line__c,
                                        UnitPrice, Quantity, TotalPrice, LU_Price_Without_Taxes__c, Description, Product2.LU_Number_Of_Articles__c,
                                        LU_Stock_Status__c, LU_Stock_Message__c, Personal_Use_Discount_Amount__c, LU_Discount_Amount__c, 
                                        LU_Has_Discount_Applied__c, LU_Total_Without_Discount__c, Product2.Description, PricebookEntry.LU_Counter_Value__c
                                        FROM OrderItem
                                    WHERE OrderId =: orderId 
                                        AND LU_Child_Product__c = null];
            }
            /*End - SFT-1702*/

            List<OrderItem> l_orderItemToDelete = new List<OrderItem>();
            for(Integer i = lLines.size() - 1; i >= 0; i--){
                for(Integer j = lLines.size() - 1; j >= 0; j--){
                    if(i == j){
                        continue;
                    }
                    
                    if(order.status == 'Draft') { //SFT-1702, Products can be deleted only in draft mode*
                        if(lLines[i].PricebookEntry == lLines[j].PricebookEntry &&
                        lLines[i].LU_Contact_For__c == lLines[j].LU_Contact_For__c &&
                        lLines[i].Product2Id == lLines[j].Product2Id){
                            if(lLines[i].Quantity < lLines[j].Quantity){
                                l_orderItemToDelete.add(lLines[i]);
                                lLines.remove(i);
                                break;
                            }
                            else{
                                l_orderItemToDelete.add(lLines[j]);
                                lLines.remove(j);
                                break;
                            }
                        }
                    }
                }
            }
            if(!l_orderItemToDelete.isEmpty()){
                delete l_orderItemToDelete;
            }

            Map<String, List<OrderItem>> m_childOrderItemPerContact = new Map<String, List<OrderItem>>();
            List<OrderItem> childItems = null;

            /*Start - SFT-1702, Challenge linked child products will not be visible in draft mode*/
            if(order.status == 'Draft') {    
                childItems = [SELECT Id, Product2Id, Quantity, LU_Child_Product__c, LU_Child_Product__r.Name, PricebookEntry.LU_Offer_type__c, LU_Contact_For__c
                            FROM OrderItem
                            WHERE OrderId = :orderId 
                            AND LU_Child_Product__c != null
                            AND LU_Challenge_Linked__c = ''
                            ORDER BY LU_Contact_For__c];
            } else {
                childItems = [SELECT Id, Product2Id, Quantity, LU_Child_Product__c, LU_Child_Product__r.Name, PricebookEntry.LU_Offer_type__c, LU_Contact_For__c
                            FROM OrderItem
                            WHERE OrderId = :orderId 
                            AND LU_Child_Product__c != null
                            ORDER BY LU_Contact_For__c];
            }    
            /*End - SFT-1702*/

            for(OrderItem oi : childItems){
                if(m_childOrderItemPerContact.containsKey(oi.LU_Contact_For__c)){
                    m_childOrderItemPerContact.get(oi.LU_Contact_For__c).add(oi);
                }
                else{
                    m_childOrderItemPerContact.put(oi.LU_Contact_For__c, new List<OrderItem>{oi});
                }
            }
            
            // Build the baskets
            if (!lLines.isEmpty()) {

                // order.baskets = new Map<Id, Basket>();
                order.mBasketsByType = new Map<String, BasketsByType>();

                for (OrderItem item : lLines) {

                    item.Description = getCounterString(item, con, 'ITA');

                    // Init variables
                    PersonFor pFor = null;
                    List<OrderItem> items = null;
                    Basket b = null;
                    BasketsByType basketTypeOfTheLine = null;
                    
                    // Check the type of the offer
                    // IF the line is a new offer type, init the line
                    if (order.mBasketsByType.containsKey(item.PricebookEntry.LU_Offer_type__c) == false) {
                        BasketsByType basketType = new BasketsByType();
                        basketType.basketType = item.PricebookEntry.LU_Offer_type__c;
                        basketType.baskets = new Map<Id, Basket>();
                        order.mBasketsByType.put(item.PricebookEntry.LU_Offer_type__c, basketType);
                    }

                    // Get the list of baskets already in the offer type matching the line
                    basketTypeOfTheLine =  order.mBasketsByType.get(item.PricebookEntry.LU_Offer_type__c);


                    // If the customer / dealer of the line is already known on the order
                    if (basketTypeOfTheLine.baskets.containsKey(item.LU_Contact_For__c)) {
                        
                        b = basketTypeOfTheLine.baskets.get(item.LU_Contact_For__c);
                        items = b.lines;

                    }  else {

                        // Create the dealer / customer of the line
                        pFor = new PersonFor();
                        pFor.personId = item.LU_Contact_For__c;
                        pFor.lastname = (item.LU_Contact_For__r.LastName != null ? item.LU_Contact_For__r.LastName.toUpperCase() : '');
                        pFor.firstname = (item.LU_Contact_For__r.FirstName != null ? item.LU_Contact_For__r.FirstName.toUpperCase() : '');                   

                        // Create the basket
                        b = new Basket();
                        b.contact = pFor;

                        // Init the list of lines
                        items = new List<OrderItem>();
                    }

                    // Add the line to the basket of the line's customer / dealer
                    items.add(item);
                    b.lines = items;
                    b.l_childs = m_childOrderItemPerContact.get(item.LU_Contact_For__c);

                    //SFT-1701, Add / Update the baskets list of the Order
                    basketTypeOfTheLine.baskets.put(item.LU_Contact_For__c, b);

                    order.mBasketsByType.get(item.PricebookEntry.LU_Offer_type__c).baskets.put(item.LU_Contact_For__c, b);
                    //order.mBasketsByType.get(item.PricebookEntry.LU_Offer_type__c).basket.l_childs = m_childOrderItemPerContact.get(item.LU_Contact_For__c);

                }

            }


            if (order.mBasketsByType != null) {

                // For each type of basket, go through the basket to calculate
                for (String basketTypeStr : order.mBasketsByType.keyset()) {

                    BasketsByType basketType = order.mBasketsByType.get(basketTypeStr);

                    if (basketType.baskets != null) {

                        for (Id contactId : basketType.baskets.keyset()) {

                            Basket basket = basketType.baskets.get(contactId);
                            Decimal totalWithTax = 0;
                            Decimal totalWithoutTax = 0;
                            Decimal nbProduct = 0;
                            Decimal totalDiscount = 0;
                            for (OrderItem line : basket.lines) {
                                totalWithTax += line.UnitPrice * line.Quantity;
                                totalWithoutTax += line.LU_Price_Without_Taxes__c;
                                nbProduct += line.Quantity;
                                totalDiscount += (line.Personal_Use_Discount_Amount__c != 0 ? 
                                                    line.Personal_Use_Discount_Amount__c : 
                                                    line.LU_Discount_Amount__c);
                            }

                            basket.total = totalWithTax;
                            basket.totalWithoutTax = totalWithoutTax;
                            basket.nbProduct = nbProduct;
                            basket.totalWithoutDiscount = totalWithTax + totalDiscount;
                            basket.hasDiscount = false;
                            if (totalDiscount != null && totalDiscount > 0) {
                                basket.hasDiscount = true;
                            }
                            basket.isPersonalUse = false;
                            if(basketTypeStr == 'Personal use'){
                                basket.isPersonalUse = true;
                            }

                            (order.mBasketsByType.get(basketType.basketType)).baskets.put(contactId, basket);
                        }
                    }
                }
            }
        }
        return (order);
    }

    @AuraEnabled
    public static Baskets getOrderSortedByCustomerFRA(String orderId) {
        
        // Init basket
        Baskets order = new Baskets();
        order.idOrder = orderId;
        order.mBasketsByPerson = null;

        // Query the order header
        List<Order> lOrder = [SELECT Id, BillToContactId, BillToContact.AllowedPaymentMode__c, LU_Total_Amount_For_Valid_Base__c, LU_Total_Price_Without_Taxes__c, EffectiveDate, TotalAmount, Status, 
                                Tech_External_Id__c, LU_CUSTOMER_FIRSTNAME__c, LU_CUSTOMER_LASTNAME__c , BO_TOTAL_WITH_TAXES__c, BO_TOTAL_WITHOUT_TAXES__c, Type
                                FROM Order
                                WHERE Id = :orderId];
        if (!lOrder.isEmpty()) {
            
            order.dealerOfOrder = lOrder[0].BillToContactId;
            order.allowedPaymentMode = lOrder[0].BillToContact.AllowedPaymentMode__c;
            order.externalId = lOrder[0].Tech_External_Id__c;
            order.status = lOrder[0].Status;
            order.dateOrder = lOrder[0].EffectiveDate;
            order.totalOrder = lOrder[0].TotalAmount;
            order.totalWithoutVATOrder = lOrder[0].LU_Total_Price_Without_Taxes__c;
            order.totalValidForTotalBase = lOrder[0].LU_Total_Amount_For_Valid_Base__c;
            order.clientFirstName = lOrder[0].LU_CUSTOMER_FIRSTNAME__c;
            order.clientLastName = lOrder[0].LU_CUSTOMER_LASTNAME__c;
            order.bo_total_with_taxes = lOrder[0].BO_TOTAL_WITH_TAXES__c;
            order.bo_total_without_taxes =  lOrder[0].BO_TOTAL_WITHOUT_TAXES__c;
            order.orderType = lOrder[0].Type;

            Contact con = [SELECT LU_Counter_1_Name__c
                                    ,LU_Counter_2_Name__c
                                    ,LU_Counter_3_Name__c
                                    ,LU_Counter_4_Name__c
                                    ,LU_Counter_5_Name__c
                                    ,LU_Counter_6_Name__c
                                    ,LU_Counter_7_Name__c
                                    ,LU_Counter_8_Name__c
                                    ,LU_Counter_9_Name__c
                                    ,LU_Counter_10_Name__c
                                    ,LU_Counter_11_Name__c
                                    ,LU_Counter_12_Name__c
                                    ,LU_Counter_13_Name__c
                                    ,LU_Counter_14_Name__c
                                    ,LU_Counter_15_Name__c
                                    ,LU_Counter_16_Name__c
                                    ,LU_Counter_17_Name__c
                                    ,LU_Counter_18_Name__c
                                    ,LU_Counter_19_Name__c
                                    ,LU_Counter_20_Name__c
                                    ,LU_Counter_21_Name__c
                                    ,LU_Counter_22_Name__c
                                    ,LU_Counter_23_Name__c
                                    ,LU_Counter_24_Name__c
                                    ,LU_Counter_25_Name__c
                                    ,LU_Counter_26_Name__c
                                    ,LU_Counter_27_Name__c
                                    ,LU_Counter_28_Name__c
                                    ,LU_Counter_29_Name__c
                                    ,LU_Counter_30_Name__c
                                    ,LU_Counters_To_Be_Displayed__c
                                    ,LU_Counters_Unit__c
                                    ,LU_Counters_Unit_Bis__c
                            FROM Contact
                            WHERE Id = :lOrder[0].BillToContactId];
                            
            // Query the system to get the current order
            List<OrderItem>  lLines = [SELECT Id, OrderId, Order.LU_Total_Amount_For_Valid_Base__c, Order.LU_Total_Price_Without_Taxes__c, Order.EffectiveDate, 
                                        Order.TotalAmount, Order.Status, Description, Product2.RecordTypeId, Product2.RecordType.DeveloperName,
                                        Product2.LU_Local_Code__c, Product2.Name, PricebookEntryId, PricebookEntry.LU_Offer_type__c, Product2.LU_Bundle_Type__c,
                                        LU_Contact_For__c, LU_Contact_For__r.LastName, LU_Contact_For__r.FirstName, Product2.LU_Number_Of_Articles__c,
                                        UnitPrice, Quantity, TotalPrice, LU_Price_Without_Taxes__c, LU_Total_Price__c, LU_TECH_Is_Bundle_Parent_Line__c,
                                        LU_Stock_Status__c, LU_Stock_Message__c, Personal_Use_Discount_Amount__c, LU_Discount_Amount__c, Product2Id, LU_Challenge_Linked__c,
                                        LU_Has_Discount_Applied__c, LU_Total_Without_Discount__c, Product2.Description, PricebookEntry.LU_Counter_Value__c
                                        FROM OrderItem
                                        WHERE OrderId =: orderId
                                        //AND LU_Challenge_Linked__c = '' 
                                        AND LU_Child_Product__c = null ];

            List<OrderItem> l_orderItemToDelete = new List<OrderItem>();
            for(Integer i = lLines.size() - 1; i >= 0; i--){
                for(Integer j = lLines.size() - 1; j >= 0; j--){
                    if(i == j){
                        continue;
                    }

                    if(lLines[i].PricebookEntry == lLines[j].PricebookEntry &&
                       lLines[i].LU_Contact_For__c == lLines[j].LU_Contact_For__c &&
                       lLines[i].Product2Id == lLines[j].Product2Id){
                        if(lLines[i].Quantity < lLines[j].Quantity){
                            l_orderItemToDelete.add(lLines[i]);
                            lLines.remove(i);
                            break;
                        }
                        else{
                            l_orderItemToDelete.add(lLines[j]);
                            lLines.remove(j);
                            break;
                        }
                    }
                }
            }
            if(!l_orderItemToDelete.isEmpty()){
                delete l_orderItemToDelete;
            }

            Map<String, List<OrderItem>> m_childOrderItemPerContact = new Map<String, List<OrderItem>>();
            
            for(OrderItem oi : [SELECT Id, Product2Id, Quantity, LU_Child_Product__c, LU_Child_Product__r.Name, PricebookEntry.LU_Offer_type__c, LU_Contact_For__c, LU_Challenge_Linked__c
                                        FROM OrderItem
                                        WHERE OrderId =: orderId 
                                        AND LU_Child_Product__c != null
                                        //AND LU_Challenge_Linked__c = ''
                                        ORDER BY LU_Contact_For__c ]){
                
                if(!String.isBlank(oi.LU_Challenge_Linked__c)){
                    if(m_childOrderItemPerContact.containsKey('Challenge')){
                        m_childOrderItemPerContact.get('Challenge').add(oi);
                    }
                    else{
                        m_childOrderItemPerContact.put('Challenge', new List<OrderItem>{oi});
                    }
                }
                else{
                    if(m_childOrderItemPerContact.containsKey(oi.LU_Contact_For__c)){
                        m_childOrderItemPerContact.get(oi.LU_Contact_For__c).add(oi);
                    }
                    else{
                        m_childOrderItemPerContact.put(oi.LU_Contact_For__c, new List<OrderItem>{oi});
                    }
                }
            }
            
            // Build the baskets
            if (!lLines.isEmpty()) {

                // order.baskets = new Map<Id, Basket>();
                order.mBasketsByPerson = new Map<String, BasketsByPerson>();

                for (OrderItem item : lLines) {

                    item.Description = getCounterString(item, con, 'FRA');

                    // Init variables
                    PersonFor pFor = null;
                    List<OrderItem> items = null;
                    Basket b = null;
                    BasketsByType basketTypeOfTheLine = null;
                    
                    // Check the type of the offer
                    // IF the line is a new offer type, init the line
                    if(!String.isBlank(item.LU_Challenge_Linked__c)){
                        if(!order.mBasketsByPerson.containsKey('Challenge')){
                            pFor = new PersonFor();
                            pFor.personId = 'Challenge';
                            pFor.lastname = 'Challenge';
                            
                            BasketsByPerson basketByPerson = new BasketsByPerson();
                            basketByPerson.person = pFor;
                            basketByPerson.basket = new Basket();
                            basketByPerson.basket.lines = new List<OrderItem>();
                            basketByPerson.basket.contact = pFor;
                            order.mBasketsByPerson.put('Challenge', basketByPerson);
                        }
                        order.mBasketsByPerson.get('Challenge').basket.lines.add(item);
                        order.mBasketsByPerson.get('Challenge').basket.l_childs = m_childOrderItemPerContact.get('Challenge');
                    }
                    else {
                        if (order.mBasketsByPerson.containsKey(item.LU_Contact_For__c) == false) {
                            pFor = new PersonFor();
                            pFor.personId = item.LU_Contact_For__c;
                            pFor.lastname = (item.LU_Contact_For__r.LastName != null ? item.LU_Contact_For__r.LastName.toUpperCase() : '');
                            pFor.firstname = (item.LU_Contact_For__r.FirstName != null ? item.LU_Contact_For__r.FirstName.toUpperCase() : '');

                            BasketsByPerson basketByPerson = new BasketsByPerson();
                            basketByPerson.person = pFor;
                            basketByPerson.basket = new Basket();
                            basketByPerson.basket.lines = new List<OrderItem>();
                            basketByPerson.basket.contact = pFor;
                            order.mBasketsByPerson.put(item.LU_Contact_For__c, basketByPerson);
                        }

                        order.mBasketsByPerson.get(item.LU_Contact_For__c).basket.lines.add(item);
                        order.mBasketsByPerson.get(item.LU_Contact_For__c).basket.l_childs = m_childOrderItemPerContact.get(item.LU_Contact_For__c);
                    }
                }
            }


            if (order.mBasketsByPerson != null) {

                // For each type of basket, go through the basket to calculate
                for (String basketPersonId : order.mBasketsByPerson.keyset()) {

                    BasketsByPerson basketByPerson = order.mBasketsByPerson.get(basketPersonId);

                    if (basketByPerson.basket != null) {

                        Basket basket = basketByPerson.basket;

                        Decimal totalWithTax = 0;
                        Decimal totalWithoutTax = 0;
                        Decimal nbProduct = 0;
                        Decimal totalDiscount = 0;

                        for (OrderItem line : basket.lines) {
                            totalWithTax += line.LU_Total_Price__c;
                            totalWithoutTax += line.LU_Price_Without_Taxes__c;
                            nbProduct += line.Quantity;
                            totalDiscount += (line.Personal_Use_Discount_Amount__c != 0 ? 
                                                    line.Personal_Use_Discount_Amount__c : 
                                                    line.LU_Discount_Amount__c);
                        }

                        basketByPerson.basket.total = totalWithTax;
                        basketByPerson.basket.totalWithoutTax = totalWithoutTax;
                        basketByPerson.basket.nbProduct = nbProduct;
                        basket.totalWithoutDiscount = totalWithTax + totalDiscount;
                        basket.hasDiscount = false;
                        if (totalDiscount != null && totalDiscount > 0) {
                            basket.hasDiscount = true;
                        }

                        order.mBasketsByPerson.put(basketPersonId, basketByPerson);
                    }
                }
            }
        }
        return (order);
    }

    @AuraEnabled
    public static Baskets getOrderSortedByCatalog(String orderId, String country) {
        
        // Init basket
        Baskets order = new Baskets();
        order.idOrder = orderId;
        order.mBasketsByCatalog = null;

        // Query the order header
        List<Order> lOrder = [SELECT Id, BillToContactId, BillToContact.AllowedPaymentMode__c, LU_Total_Amount_For_Valid_Base__c, LU_Total_Price_Without_Taxes__c, EffectiveDate, TotalAmount, Status, 
                                Tech_External_Id__c, BO_TOTAL_WITH_TAXES__c, BO_TOTAL_WITHOUT_TAXES__c, Type
                                FROM Order
                                WHERE Id = :orderId];
        if (!lOrder.isEmpty()) {

            order.dealerOfOrder = lOrder[0].BillToContactId;
            order.allowedPaymentMode = lOrder[0].BillToContact.AllowedPaymentMode__c;
            order.externalId = lOrder[0].Tech_External_Id__c;
            order.status = lOrder[0].Status;
            order.dateOrder = lOrder[0].EffectiveDate;
            order.totalOrder = lOrder[0].TotalAmount;
            order.totalWithoutVATOrder = lOrder[0].LU_Total_Price_Without_Taxes__c;
            order.totalValidForTotalBase = lOrder[0].LU_Total_Amount_For_Valid_Base__c;
            order.bo_total_with_taxes = lOrder[0].BO_TOTAL_WITH_TAXES__c;
            order.bo_total_without_taxes =  lOrder[0].BO_TOTAL_WITHOUT_TAXES__c;
            order.orderType = lOrder[0].Type;

            Contact con = [SELECT LU_Counter_1_Name__c
                                ,LU_Counter_2_Name__c
                                ,LU_Counter_3_Name__c
                                ,LU_Counter_4_Name__c
                                ,LU_Counter_5_Name__c
                                ,LU_Counter_6_Name__c
                                ,LU_Counter_7_Name__c
                                ,LU_Counter_8_Name__c
                                ,LU_Counter_9_Name__c
                                ,LU_Counter_10_Name__c
                                ,LU_Counter_11_Name__c
                                ,LU_Counter_12_Name__c
                                ,LU_Counter_13_Name__c
                                ,LU_Counter_14_Name__c
                                ,LU_Counter_15_Name__c
                                ,LU_Counter_16_Name__c
                                ,LU_Counter_17_Name__c
                                ,LU_Counter_18_Name__c
                                ,LU_Counter_19_Name__c
                                ,LU_Counter_20_Name__c
                                ,LU_Counter_21_Name__c
                                ,LU_Counter_22_Name__c
                                ,LU_Counter_23_Name__c
                                ,LU_Counter_24_Name__c
                                ,LU_Counter_25_Name__c
                                ,LU_Counter_26_Name__c
                                ,LU_Counter_27_Name__c
                                ,LU_Counter_28_Name__c
                                ,LU_Counter_29_Name__c
                                ,LU_Counter_30_Name__c
                                ,LU_Counters_To_Be_Displayed__c
                                ,LU_Counters_Unit__c
                                ,LU_Counters_Unit_Bis__c
                        FROM Contact
                        WHERE Id = :lOrder[0].BillToContactId];

            // Query the system to get the current order
            List<OrderItem>  lLines = [SELECT Id, OrderId, Order.LU_Total_Amount_For_Valid_Base__c, Order.LU_Total_Price_Without_Taxes__c, Order.EffectiveDate, 
                                        Order.TotalAmount, Order.Status, Description, Product2.RecordType.DeveloperName,
                                        Product2.LU_Local_Code__c, Product2.Name, PricebookEntryId, PricebookEntry.LU_Offer_type__c, Product2.LU_Bundle_Type__c,
                                        LU_Contact_For__c, LU_Contact_For__r.LastName, LU_Contact_For__r.FirstName, Product2.LU_Number_Of_Articles__c,
                                        UnitPrice, Quantity, TotalPrice, LU_Price_Without_Taxes__c, LU_Total_Price__c, LU_TECH_Is_Bundle_Parent_Line__c,
                                        LU_Stock_Status__c, LU_Stock_Message__c, Personal_Use_Discount_Amount__c, LU_Discount_Amount__c, LU_Challenge_Linked__c,
                                        LU_Has_Discount_Applied__c, LU_Total_Without_Discount__c, Product2.Description, PricebookEntry.LU_Counter_Value__c
                                        FROM OrderItem
                                        WHERE OrderId =: orderId 
                                        AND LU_Child_Product__c = null ];
                                        //AND LU_Challenge_Linked__c = '' ];

            List<OrderItem> l_orderItemToDelete = new List<OrderItem>();
            for(Integer i = lLines.size() - 1; i >= 0; i--){
                for(Integer j = lLines.size() - 1; j >= 0; j--){
                    if(i == j){
                        continue;
                    }

                    if(lLines[i].PricebookEntry == lLines[j].PricebookEntry &&
                       lLines[i].LU_Contact_For__c == lLines[j].LU_Contact_For__c &&
                       lLines[i].Product2Id == lLines[j].Product2Id){
                        if(lLines[i].Quantity < lLines[j].Quantity){
                            l_orderItemToDelete.add(lLines[i]);
                            lLines.remove(i);
                            break;
                        }
                        else{
                            l_orderItemToDelete.add(lLines[j]);
                            lLines.remove(j);
                            break;
                        }
                    }
                }
            }
            if(!l_orderItemToDelete.isEmpty()){
                delete l_orderItemToDelete;
            }
            
            Map<String, Map<String, OrderItem>> m_childOrderItemPerContact = new Map<String, Map<String, OrderItem>>();
            
            for(OrderItem oi : [SELECT Id, Product2Id, Quantity, LU_Child_Product__c, LU_Child_Product__r.Name, PricebookEntry.LU_Offer_type__c, LU_Challenge_Linked__c
                                  FROM OrderItem
                                 WHERE OrderId =: orderId 
                                   AND LU_Child_Product__c != null ]){
                                   //AND LU_Challenge_Linked__c = '' ]){
                if(m_childOrderItemPerContact.containsKey(oi.PricebookEntry.LU_Offer_type__c)){
                    if(m_childOrderItemPerContact.get(oi.PricebookEntry.LU_Offer_type__c).containsKey(oi.LU_Child_Product__c)){
                        oi.Quantity += m_childOrderItemPerContact.get(oi.PricebookEntry.LU_Offer_type__c).get(oi.LU_Child_Product__c).Quantity;
                        m_childOrderItemPerContact.get(oi.PricebookEntry.LU_Offer_type__c).put(oi.LU_Child_Product__c, oi);
                    }
                    else{
                        m_childOrderItemPerContact.get(oi.PricebookEntry.LU_Offer_type__c).put(oi.LU_Child_Product__c, oi);
                    }
                }
                else{
                    m_childOrderItemPerContact.put(oi.PricebookEntry.LU_Offer_type__c, new Map<String, OrderItem>{});
                    m_childOrderItemPerContact.get(oi.PricebookEntry.LU_Offer_type__c).put(oi.LU_Child_Product__c, oi);
                }
            }

            // Build the baskets
            if (!lLines.isEmpty()) {

                // order.baskets = new Map<Id, Basket>();
                order.mBasketsByCatalog = new Map<String, BasketsByCatalog>();

                for (OrderItem item : lLines) {

                    item.Description = getCounterString(item, con, country);

                    // Init variables
                    PersonFor pFor = null;
                    List<OrderItem> items = null;
                    Basket b = null;
                    BasketsByType basketTypeOfTheLine = null;
                    
                    // Check the type of the offer
                    // IF the line is a new offer type, init the line
                    if (order.mBasketsByCatalog.containsKey(item.PricebookEntry.LU_Offer_type__c) == false) {
                        pFor = new PersonFor();
                        pFor.personId = item.LU_Contact_For__c;
                        pFor.lastname = (item.LU_Contact_For__r.LastName != null ? item.LU_Contact_For__r.LastName.toUpperCase() : '');
                        pFor.firstname = (item.LU_Contact_For__r.FirstName != null ? item.LU_Contact_For__r.FirstName.toUpperCase() : '');

                        BasketsByCatalog basketByCatalog = new BasketsByCatalog();
                        basketByCatalog.basketType = item.PricebookEntry.LU_Offer_type__c;
                        basketByCatalog.basket = new Basket();
                        basketByCatalog.basket.lines = new List<OrderItem>();
                        basketByCatalog.basket.contact = pFor;
                        order.mBasketsByCatalog.put(item.PricebookEntry.LU_Offer_type__c, basketByCatalog);
                    }

                    order.mBasketsByCatalog.get(item.PricebookEntry.LU_Offer_type__c).basket.lines.add(item);
                    if(m_childOrderItemPerContact.containsKey(item.PricebookEntry.LU_Offer_type__c)){
                        order.mBasketsByCatalog.get(item.PricebookEntry.LU_Offer_type__c).basket.l_childs = m_childOrderItemPerContact.get(item.PricebookEntry.LU_Offer_type__c).values();
                    }
                }
            }


            if (order.mBasketsByCatalog != null) {

                // For each type of basket, go through the basket to calculate
                for (String basketType : order.mBasketsByCatalog.keyset()) {

                    BasketsByCatalog basketByCatalog = order.mBasketsByCatalog.get(basketType);

                    if (basketByCatalog.basket != null) {

                        Basket basket = basketByCatalog.basket;

                        Decimal totalWithTax = 0;
                        Decimal totalWithoutTax = 0;
                        Decimal nbProduct = 0;
                        Decimal totalDiscount = 0;

                        for (OrderItem line : basket.lines) {
                            totalWithTax += line.LU_Total_Price__c;
                            totalWithoutTax += line.LU_Price_Without_Taxes__c;
                            nbProduct += line.Quantity;
                            totalDiscount += (line.Personal_Use_Discount_Amount__c != 0 ? 
                                                line.Personal_Use_Discount_Amount__c : 
                                                line.LU_Discount_Amount__c);
                        }

                        basketByCatalog.basket.total = totalWithTax;
                        basketByCatalog.basket.totalWithoutTax = totalWithoutTax;
                        basketByCatalog.basket.nbProduct = nbProduct;
                        basket.totalWithoutDiscount = totalWithTax + totalDiscount;
                        basket.hasDiscount = false;
                        if (totalDiscount != null && totalDiscount > 0) {
                            basket.hasDiscount = true;
                        }

                        basket.isPersonalUse = false;
                        if(basketType == 'Personal use'){
                            basket.isPersonalUse = true;
                        }

                        order.mBasketsByCatalog.put(basketType, basketByCatalog);
                    }
                }
            }
        }
        return (order);
    }

    // Update the line quantity in parameter with the quantity in parameter
    @AuraEnabled
    public static void updateLineQuantityById(Id lineId, Integer q) {

        OrderItem oi = [SELECT Id, Product2Id, Quantity, OrderId, LU_Contact_For__c FROM OrderItem WHERE Id = :lineId];
        oi.quantity = q;
        update oi;

        Datetime vNow = Datetime.now();
        List<OrderItem> l_closeSetChilds = [SELECT Id, Quantity, LU_Child_Product__r.LU_Min_Qty_Orderable__c, LU_Child_Product__r.LU_Max_Qty_Orderable__c, LU_Child_Product__r.LU_Type_Child__c
                                              FROM OrderItem 
                                             WHERE Product2Id = :oi.Product2Id
                                               AND OrderId = :oi.OrderId
                                               AND LU_Contact_For__c = :oi.LU_Contact_For__c
                                               AND LU_Is_A_Child_Line__c = true
                                            ];

        if(!l_closeSetChilds.isEmpty()){
            List<OrderItem> l_childToUpdate = new List<OrderItem>();
            for(OrderItem child : l_closeSetChilds){
                if(child.LU_Child_Product__r.LU_Min_Qty_Orderable__c == child.LU_Child_Product__r.LU_Max_Qty_Orderable__c || child.LU_Child_Product__r.LU_Type_Child__c == 'NoSelect'){
                    child.Quantity = child.LU_Child_Product__r.LU_Max_Qty_Orderable__c * q;
                    l_childToUpdate.add(child);
                }
            }

            update l_childToUpdate;
        }
        
        // OrderItem oi = [SELECT Id, Quantity FROM OrderItem WHERE Id = :lineId];
        // OrderItem oi = new OrderItem(Id = lineId, Quantity = q);
        // update oi;

    }

    // Delete the line in parameter
    @AuraEnabled
    public static void deleteLineById(Id lineId) {

        OrderItem oi = [SELECT Id, Product2Id, OrderId FROM OrderItem WHERE Id = :lineId];
        List<OrderItem> l_oi = [SELECT Id FROM OrderItem WHERE Product2Id = :oi.Product2Id AND OrderId = :oi.OrderId AND LU_Child_Product__c != null];

        delete oi;
        delete l_oi;
    }

    // Delete all the lines assocaited with the contact in parameter
    @AuraEnabled
    public static void deleteLinesAssociatedToContactId(Id contactId, String offerType, Id orderId) {

        List<OrderItem> lLines = null;
        if (contactId != null) {
            if (offerType != null && offerType != '') {
                lLines = [SELECT Id FROM OrderItem WHERE PricebookEntry.LU_Offer_type__c = :offerType AND LU_Contact_For__c = :contactId AND OrderId = :orderId ];
            } else {
                lLines = [SELECT Id FROM OrderItem WHERE LU_Contact_For__c = :contactId AND OrderId = :orderId ];
            }
        } else {
            lLines = [SELECT Id FROM OrderItem WHERE PricebookEntry.LU_Offer_type__c = :offerType AND LU_Contact_For__c = null AND OrderId = :orderId ];
        }

        if (!lLines.isEmpty()) {
            delete lLines;
        }
    }

    // Delete all the lines assocaited with the contact in parameter
    // @AuraEnabled
    // public static void deleteLinesAssociatedToContactIdWithoutOfferType(Id contactId, Id orderId) {


    //     List<OrderItem> lLines = null;
    //     if (contactId != null) {
    //         lLines = [SELECT Id FROM OrderItem WHERE LU_Contact_For__c = :contactId AND OrderId = :orderId ];
    //     } else {
    //         lLines = [SELECT Id FROM OrderItem WHERE LU_Contact_For__c = null AND OrderId = :orderId ];
    //     }

    //     if (!lLines.isEmpty()) {
    //         delete lLines;
    //     }
        
    // }

    // Delete the order in parameter
    @AuraEnabled
    public static void deleteOrderById(Id orderId) {
        Order ord = new Order(Id = orderId);
        delete ord;
    }

    @AuraEnabled
    public static UserConnected getUserConnectedRights() {

        // Variables
        UserConnected info = new UserConnected();

        // Get connected user
        info.connectedContact = AP1002_Utils_User.getConnectedUserContact();
        info.connectedUser = AP1003_Utils_Contact.getContactUserAssociated(info.connectedContact.Id);

        // Get information about ordering for someone else
        List<LU_Order_Rule__c> lRule = [ SELECT Id
                                            FROM LU_Order_Rule__c
                                            WHERE RecordType.DeveloperName = 'LU_Order_Order_On_Behalf_Of'
                                            AND LU_Text__c = :info.connectedUser.Profile.Name
                                            AND LU_Active__c = true
                                             ];
        if (!lRule.isEmpty()) {
            info.canOrderOnBehalf = true;
        } else {
            info.canOrderOnBehalf = false;
        }

        return (info); 

    }

    @AuraEnabled
    public static String getUserCountry() {
        System.debug('USERID : ' + UserInfo.getUserId());
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    public static String getCounterString(OrderItem item, Contact con, String country){
        String counters = '';
        if (con.LU_Counters_To_Be_Displayed__c != null && con.LU_Counters_Unit__c != null) {
 
            List<String> l_countersToDiplay = con.LU_Counters_To_Be_Displayed__c.split('#');
            List<String> l_countersUnits = con.LU_Counters_Unit__c.split('#');
            if(con.LU_Counters_Unit_Bis__c != null){
                l_countersUnits.addAll(con.LU_Counters_Unit_Bis__c.split('#'));
            }
            Boolean displayUnit = (l_countersUnits != null && l_countersUnits.size() >= 20 ? true : false);
            List<String> l_pbeCounter = item.PricebookEntry.LU_Counter_Value__c == null ? null : item.PricebookEntry.LU_Counter_Value__c.split('#');

            if(l_pbeCounter != null && !l_pbeCounter.isEmpty()){
                if(con.LU_Counter_1_Name__c != null && l_pbeCounter.get(0) != null && Decimal.valueOf(l_pbeCounter.get(0)) < 0 && l_countersToDiplay.contains('1') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_1_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_1_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(0)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_2_Name__c != null && l_pbeCounter.get(1) != null && Decimal.valueOf(l_pbeCounter.get(1)) < 0 && l_countersToDiplay.contains('2') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_2_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_2_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(1)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_3_Name__c != null && l_pbeCounter.get(2) != null && Decimal.valueOf(l_pbeCounter.get(2)) < 0 && l_countersToDiplay.contains('3') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_3_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_3_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(2)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_4_Name__c != null && l_pbeCounter.get(3) != null && Decimal.valueOf(l_pbeCounter.get(3)) < 0 && l_countersToDiplay.contains('4') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_4_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_4_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(3)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_5_Name__c != null && l_pbeCounter.get(4) != null && Decimal.valueOf(l_pbeCounter.get(4)) < 0 && l_countersToDiplay.contains('5') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_5_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_5_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(4)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_6_Name__c != null && l_pbeCounter.get(5) != null && Decimal.valueOf(l_pbeCounter.get(5)) < 0 && l_countersToDiplay.contains('6') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_6_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_6_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(5)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_7_Name__c != null && l_pbeCounter.get(6) != null && Decimal.valueOf(l_pbeCounter.get(6)) < 0 && l_countersToDiplay.contains('7')  ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_7_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_7_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(6)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_8_Name__c != null && l_pbeCounter.get(7) != null && Decimal.valueOf(l_pbeCounter.get(7)) < 0 && l_countersToDiplay.contains('8')  ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_8_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_8_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(7)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_9_Name__c != null && l_pbeCounter.get(8) != null && Decimal.valueOf(l_pbeCounter.get(8)) < 0 && l_countersToDiplay.contains('9') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_9_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_9_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(8)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_10_Name__c != null && l_pbeCounter.get(9) != null && Decimal.valueOf(l_pbeCounter.get(9)) < 0 && l_countersToDiplay.contains('10') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_10_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_10_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(9)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_11_Name__c != null && l_pbeCounter.get(10) != null && Decimal.valueOf(l_pbeCounter.get(10)) < 0 && l_countersToDiplay.contains('11') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_11_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_11_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(10)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_12_Name__c != null && l_pbeCounter.get(11) != null && Decimal.valueOf(l_pbeCounter.get(11)) < 0 && l_countersToDiplay.contains('12') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_12_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_12_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(11)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_13_Name__c != null && l_pbeCounter.get(12) != null && Decimal.valueOf(l_pbeCounter.get(12)) < 0 && l_countersToDiplay.contains('13') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_13_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_13_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(12)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_14_Name__c != null && l_pbeCounter.get(13) != null && Decimal.valueOf(l_pbeCounter.get(13)) < 0 && l_countersToDiplay.contains('14') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_14_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_14_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(13)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_15_Name__c != null && l_pbeCounter.get(14) != null && Decimal.valueOf(l_pbeCounter.get(14)) < 0 && l_countersToDiplay.contains('15') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_15_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_15_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(14)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_16_Name__c != null && l_pbeCounter.get(15) != null && Decimal.valueOf(l_pbeCounter.get(15)) < 0 && l_countersToDiplay.contains('16') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_16_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_16_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(15)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_17_Name__c != null && l_pbeCounter.get(16) != null && Decimal.valueOf(l_pbeCounter.get(16)) < 0 && l_countersToDiplay.contains('17') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_17_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_17_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(16)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_18_Name__c != null && l_pbeCounter.get(17) != null && Decimal.valueOf(l_pbeCounter.get(17)) < 0 && l_countersToDiplay.contains('18') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_18_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_18_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(17)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_19_Name__c != null && l_pbeCounter.get(18) != null && Decimal.valueOf(l_pbeCounter.get(18)) < 0 && l_countersToDiplay.contains('19') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_19_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_19_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(18)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_20_Name__c != null && l_pbeCounter.get(19) != null && Decimal.valueOf(l_pbeCounter.get(19)) < 0 && l_countersToDiplay.contains('20') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_20_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_20_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(19)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_21_Name__c != null && l_pbeCounter.get(20) != null && Decimal.valueOf(l_pbeCounter.get(20)) < 0 && l_countersToDiplay.contains('21') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_21_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_21_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(20)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_22_Name__c != null && l_pbeCounter.get(21) != null && Decimal.valueOf(l_pbeCounter.get(21)) < 0 && l_countersToDiplay.contains('22') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_22_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_22_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(21)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_23_Name__c != null && l_pbeCounter.get(22) != null && Decimal.valueOf(l_pbeCounter.get(22)) < 0 && l_countersToDiplay.contains('23') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_23_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_23_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(22)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_24_Name__c != null && l_pbeCounter.get(23) != null && Decimal.valueOf(l_pbeCounter.get(23)) < 0 && l_countersToDiplay.contains('24') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_24_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_24_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(23)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_25_Name__c != null && l_pbeCounter.get(24) != null && Decimal.valueOf(l_pbeCounter.get(24)) < 0 && l_countersToDiplay.contains('25') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_25_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_25_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(24)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_26_Name__c != null && l_pbeCounter.get(25) != null && Decimal.valueOf(l_pbeCounter.get(25)) < 0 && l_countersToDiplay.contains('26') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_26_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_26_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(25)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_27_Name__c != null && l_pbeCounter.get(26) != null && Decimal.valueOf(l_pbeCounter.get(26)) < 0 && l_countersToDiplay.contains('27') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_27_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_27_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(26)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_28_Name__c != null && l_pbeCounter.get(27) != null && Decimal.valueOf(l_pbeCounter.get(27)) < 0 && l_countersToDiplay.contains('28') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_28_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_28_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(27)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_29_Name__c != null && l_pbeCounter.get(28) != null && Decimal.valueOf(l_pbeCounter.get(28)) < 0 && l_countersToDiplay.contains('29') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_29_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_29_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(28)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
                if(con.LU_Counter_30_Name__c != null && l_pbeCounter.get(29) != null && Decimal.valueOf(l_pbeCounter.get(29)) < 0 && l_countersToDiplay.contains('30') ){
                    if(country == 'ITA'){
                        counters += con.LU_Counter_30_Name__c.split('#').get(0) + ' - ';
                    }
                    else{
                        counters += con.LU_Counter_30_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(29)).setScale(2) + (displayUnit ? ' ' + l_countersUnits.get(0) : '') + ' - ';
                    }
                }
            }

            if(counters.length() > 3){
                counters = counters.left(counters.length() - 3);
            }
        }

        return counters;
    }

    // Delete the stock used AND update status to draft
    @AuraEnabled
    public static void updateStatusDeleteStockUsed(String orderId) {

        // Put order status back to "Draft"
        Order ord = [SELECT Id, Status FROM Order WHERE Id = :orderId];
        ord.Status = 'Draft';
        update ord;

        // Remove the description of the lines
        List<OrderItem> lItems = [SELECT Id, Description, LU_Stock_Message__c FROM OrderItem WHERE OrderId =: ord.Id  ];
        if (!lItems.isEmpty()) {
            for (OrderItem item : lItems) {
                item.Description = '';
                item.LU_Stock_Message__c = '';
            }
            update lItems;
        }

        // Remove the stock used for the order to release the stock
        List<LU_Stock_Used__c> l_stockUsed = [SELECT Id, LU_Order__c FROM LU_Stock_Used__c WHERE LU_Order__c = :orderId];
        delete l_stockUsed;

        // Remove the credit / debit done on the contact counters with the order
        AP1010_Counters_Utils.updateCountersBackToDraft(orderId);
    }

    @AuraEnabled
    public static String getProductListOfBundle(String idOrderItem) {

        OrderItem oi = [SELECT Id, Product2Id, PricebookEntryId, PricebookEntry.Pricebook2Id FROM OrderItem WHERE Id = :idOrderItem];

        return Lwc17_fastordersearchbar_ctrl.getPorductListOfBundle(oi.Product2Id, oi.PricebookEntryId, oi.PricebookEntry.Pricebook2Id);
    }

    @AuraEnabled
    public static List<OrderItem> getExistingOrderItemsOfBundle(String idOrderItem) {
 
        OrderItem oi = [SELECT Id, PricebookEntryId, OrderId, LU_Contact_For__c FROM OrderItem WHERE Id = :idOrderItem];
        List<OrderItem> lItems = [SELECT Id, Quantity, LU_Child_Product__c 
                                    FROM OrderItem 
                                    WHERE Id != :idOrderItem 
                                    AND PricebookEntryId = :oi.PricebookEntryId 
                                    AND OrderId = :oi.OrderId
                                    AND LU_Contact_For__c = :oi.LU_Contact_For__c];
        return (lItems);
    }

    @AuraEnabled
    public static String updateBundleProduct(String idOrderItem, List<AP1002_LookupSearchResult> l_bundleProduct) {

        system.debug('l_bundleProduct.size()' + l_bundleProduct.size());

        OrderItem oi = [SELECT Product2Id, OrderId, Order.BillToContactId, LU_Contact_For__c, Order.LU_Country_Code__c, Order.BillToContact.STHId__c, 
                                Order.LU_TECH_Order_Number__c 
                          FROM OrderItem 
                         WHERE Id = :idOrderItem];

        String ordId = oi.OrderId;
        String contactFor = oi.LU_Contact_For__c;

        delete [SELECT Id FROM OrderItem WHERE Product2Id = :oi.Product2Id AND LU_Child_Product__c != '' AND OrderId = :oi.OrderId AND LU_Contact_For__c = :contactFor];

        Set<String> s_productId = new Set<String>();
        for(AP1002_LookupSearchResult lsr : l_bundleProduct){
            s_productId.add(lsr.productId);
        }

        String query = 'SELECT Product2Id, LU_Contact_For__c, Quantity FROM OrderItem WHERE OrderId = :ordId AND Product2Id IN :s_productId AND LU_Contact_For__c = :contactFor';

        Map<Id, OrderItem> m_existingOrderItem = new Map<Id, OrderItem>();
        for(OrderItem oitem : Database.query(query) ){
            m_existingOrderItem.put(oitem.Product2Id, oitem);
        }

        List<OrderItem> l_orderItem = new List<OrderItem>();
        for(AP1002_LookupSearchResult product : l_bundleProduct){
            if(m_existingOrderItem.containsKey(product.productId)){
                m_existingOrderItem.get(product.productId).Quantity += product.quantity;
                continue;
            }

            if (product.quantity != 0) {
                //con.AccountCountryCode__c + '_ORDER_' + con.STHId__c + '_' + ord.LU_TECH_Order_Number__c
                OrderItem item = new OrderItem(
                                                OrderId = oi.OrderId, 
                                                PricebookEntryId = product.Id,
                                                Product2Id = product.productId, 
                                                Quantity = product.quantity,
                                                UnitPrice = product.unitPrice,
                                                LU_Valid_For_Total_Amount_Base__c = product.validForTotalMountBase == true,
                                                LU_Tax_Rate__c = product.taxRate,
                                                LU_Contact_For__c = oi.LU_Contact_For__c, //(contactLine != null ? contactLine.Id : null),
                                                LU_Brand_Territory__c = product.brandTerritory,
                                                LU_Brand__c = product.brand,
                                                LU_Public_Price__c = product.priceTTC,
                                                LU_Discount_Type__c = product.discountType,
                                                LU_Dealer_Price__c = product.dealerPrice,
                                                LU_Is_A_Child_Line__c = true
                );

                if(product.counterValuePricebookEntry != null){
                    item.LU_Counter_1_new__c = product.counterValuePricebookEntry.split(';')[0] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[0]) * product.quantity;
                    item.LU_Counter_2_new__c = product.counterValuePricebookEntry.split(';')[1] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[1]) * product.quantity;
                    item.LU_Counter_3_new__c = product.counterValuePricebookEntry.split(';')[2] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[2]) * product.quantity;
                    item.LU_Counter_4_new__c = product.counterValuePricebookEntry.split(';')[3] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[3]) * product.quantity;
                    item.LU_Counter_5_new__c = product.counterValuePricebookEntry.split(';')[4] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[4]) * product.quantity;
                    item.LU_Counter_6_new__c = product.counterValuePricebookEntry.split(';')[5] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[5]) * product.quantity;
                    item.LU_Counter_7_new__c = product.counterValuePricebookEntry.split(';')[6] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[6]) * product.quantity;
                    item.LU_Counter_8_new__c = product.counterValuePricebookEntry.split(';')[7] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[7]) * product.quantity;
                    item.LU_Counter_9_new__c = product.counterValuePricebookEntry.split(';')[8] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[8]) * product.quantity;
                    item.LU_Counter_10_new__c = product.counterValuePricebookEntry.split(';')[9] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[9]) * product.quantity;
                    item.LU_Counter_11_new__c = product.counterValuePricebookEntry.split(';')[10] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[10]) * product.quantity;
                    item.LU_Counter_12_new__c = product.counterValuePricebookEntry.split(';')[11] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[11]) * product.quantity;
                    item.LU_Counter_13_new__c = product.counterValuePricebookEntry.split(';')[12] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[12]) * product.quantity;
                    item.LU_Counter_14_new__c = product.counterValuePricebookEntry.split(';')[13] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[13]) * product.quantity;
                    item.LU_Counter_15_new__c = product.counterValuePricebookEntry.split(';')[14] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[14]) * product.quantity;
                    item.LU_Counter_16_new__c = product.counterValuePricebookEntry.split(';')[15] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[15]) * product.quantity;
                    item.LU_Counter_17_new__c = product.counterValuePricebookEntry.split(';')[16] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[16]) * product.quantity;
                    item.LU_Counter_18_new__c = product.counterValuePricebookEntry.split(';')[17] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[17]) * product.quantity;
                    item.LU_Counter_19_new__c = product.counterValuePricebookEntry.split(';')[18] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[18]) * product.quantity;
                    item.LU_Counter_20_new__c = product.counterValuePricebookEntry.split(';')[19] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[19]) * product.quantity;
                    item.LU_Counter_21_new__c = product.counterValuePricebookEntry.split(';')[20] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[20]) * product.quantity;
                    item.LU_Counter_22_new__c = product.counterValuePricebookEntry.split(';')[21] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[21]) * product.quantity;
                    item.LU_Counter_23_new__c = product.counterValuePricebookEntry.split(';')[22] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[22]) * product.quantity;
                    item.LU_Counter_24_new__c = product.counterValuePricebookEntry.split(';')[23] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[23]) * product.quantity;
                    item.LU_Counter_25_new__c = product.counterValuePricebookEntry.split(';')[24] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[24]) * product.quantity;
                    item.LU_Counter_26_new__c = product.counterValuePricebookEntry.split(';')[25] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[25]) * product.quantity;
                    item.LU_Counter_27_new__c = product.counterValuePricebookEntry.split(';')[26] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[26]) * product.quantity;
                    item.LU_Counter_28_new__c = product.counterValuePricebookEntry.split(';')[27] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[27]) * product.quantity;
                    item.LU_Counter_29_new__c = product.counterValuePricebookEntry.split(';')[28] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[28]) * product.quantity;
                    item.LU_Counter_30_new__c = product.counterValuePricebookEntry.split(';')[29] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split(';')[29]) * product.quantity;
                }

                item.LU_Is_A_Sell__c = item.LU_Contact_For__c != oi.Order.BillToContactId ? true : false;

                item.LU_Child_Product__c = product.id;
                item.PricebookEntryId = product.idBundle;

                l_orderItem.add(item);
            }
        }

        insert l_orderItem;

        l_orderItem = [SELECT Id, LU_TECH_Line_Number__c FROM OrderItem WHERE Id in :l_orderItem];

        // Add external id
        for (OrderItem item : l_orderItem) {
            String extIdLine = oi.Order.LU_Country_Code__c + '_ORDERLINE_' + oi.Order.BillToContact.STHId__c + '_' + + oi.Order.LU_TECH_Order_Number__c;
            extIdLine += '_' + item.LU_TECH_Line_Number__c;
            item.LU_TECH_External_Id__c = extIdLine;
        }
        update l_orderItem;


        update m_existingOrderItem.values();

        return 'ok';
    }

    @AuraEnabled
    public static String controlBundle(String orderId) {
        List<OrderItem> l_childOrderItem = [SELECT Id, Quantity, Product2Id, LU_Contact_For__c
                                              FROM OrderItem 
                                             WHERE OrderId = :orderId
                                               AND LU_Child_Product__c != ''
                                               AND LU_Challenge_Linked__c = ''];

        Map<Id, OrderItem> m_parentOrderItem = new Map<Id, OrderItem>([SELECT Id, Quantity, Product2.LU_Number_Of_Articles__c, Product2Id, Product2.Name, Product2.LU_Local_Code__c, LU_Contact_For__c ,
                                                                            Product2.LU_Bundle_Type__c, Product2.LU_Country__c
                                                                         FROM OrderItem 
                                                                        WHERE OrderId = :orderId
                                                                          AND LU_Child_Product__c = ''
                                                                          AND LU_Challenge_Linked__c = ''
                                                                          AND Product2.RecordType.Name = 'LU_Bundle']);

        Map<String, Decimal> m_childQuantityPerParentProduct = new Map<String, Decimal>();

        for(OrderItem oi : m_parentOrderItem.values()){
            m_childQuantityPerParentProduct.put(oi.Product2Id + '' + oi.LU_Contact_For__c, 0);
        }

        for(OrderItem oi : l_childOrderItem){
            m_childQuantityPerParentProduct.put(oi.Product2Id + '' + oi.LU_Contact_For__c, m_childQuantityPerParentProduct.get(oi.Product2Id + '' + oi.LU_Contact_For__c) + oi.Quantity);
        }

        for(OrderItem oi : m_parentOrderItem.values()){
            if(oi.Product2.LU_Country__c != 'FRA' || oi.Product2.LU_Bundle_Type__c != 'CloseSet'){
                if(m_childQuantityPerParentProduct.get(oi.Product2Id + '' + oi.LU_Contact_For__c) < oi.Quantity * oi.Product2.LU_Number_Of_Articles__c){
                    return Label.LU_Basket_Bundle_MaxQuantityNotReached + '###' + oi.Product2.LU_Local_Code__c + ' - ' + oi.Product2.Name;
                }
                else if(m_childQuantityPerParentProduct.get(oi.Product2Id + '' + oi.LU_Contact_For__c) > oi.Quantity * oi.Product2.LU_Number_Of_Articles__c){
                    return Label.LU_Basket_Bundle_MaxQuantityExceeded + '###' + oi.Product2.LU_Local_Code__c + ' - ' + oi.Product2.Name;
                }
            }
        }

        return 'OK';
    }

    @AuraEnabled
    public static String getOrderStatusFromOrderItem(String idOrderItem){
        return [SELECT Order.Status FROM OrderItem WHERE Id = :idOrderItem].Order.Status;
    }

    @AuraEnabled
    public static String putOrderOnNewCase(String orderId){
        try{
            Order ord = [SELECT Id, LU_Invoice_Number__c FROM Order WHERE Id =: orderId];
            User currentUser = [SELECT Id, TECH_ExternalId__c, TECH_LU_OrderCase__c FROM User WHERE Id =: UserInfo.getUserId()];
            currentUser.TECH_LU_OrderCase__c = ord.LU_Invoice_Number__c;
            update currentUser;
            return 'OK';
        }
        catch (Exception e){
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static void validateOrderOLA(String orderId){

        Order ord = new Order(
            Id = orderId,
            Status = 'Pending',
            LU_TECH_BO_ExtractionStatus__c = 'To be exported'
        );
        update ord;

        List<OrderItem> l_ordItem = [SELECT Id, LU_TECH_BO_ExtractionStatus__c FROM OrderItem WHERE OrderId = :orderId];

        for(OrderItem ordItem : l_ordItem){
            ordItem.LU_TECH_BO_ExtractionStatus__c = 'To be exported';
        }

        if(!l_ordItem.isEmpty()){
            update l_ordItem;
        }
    }
}