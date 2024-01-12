public without sharing class lwc27_order_validation {

    public static final Set<String> STOCK_STATUS_TO_MANAGE = new Set<String>{ 'Dynamic', 'DynamicWithoutMessage', 'Out-of-stock', 'Temporarily out-of-stock' };
    public static final Set<String> STOCK_STATUS_OUTOFSTOCK = new Set<String>{ 'Out-of-stock', 'Temporarily out-of-stock' };
    public static final Set<String> STOCK_STATUS_LIMITED = new Set<String>{ 'Limited quantity' };
    public static final String STOCK_USED_CURRENCYISOCODE = 'EUR';
    public static final String STOCK_SUBSTITUTE_SEPARATOR = '#';
    public static final String STOCK_PRODUCT_RT_BUNDLE = 'LU_Bundle';

    public class ValidationResult {
        @AuraEnabled
        public Boolean success {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public String type {get;set;} // "stock" : if stock issue
        @AuraEnabled
        public String url {get;set;}
        @AuraEnabled
        public List<String> lOffersWithProblem {get;set;}

        public ValidationResult() {}
        public ValidationResult(Boolean success, String message) {
            this.success = success;
            this.message = message;
        }
    }
    
    /* UI METHODS */
    @AuraEnabled
    public static ValidationResult validateOrderOnCheckout(Id orderId) {

        // Variables
        ValidationResult res = new ValidationResult();

        // Get order information
        Order ord = [SELECT Id, Status, BillToContactId, BillToContact.AccountCountryCode__c, LU_Total_Amount_For_Valid_Base__c, LU_Country_Code__c,
                        LU_Payment_Transaction_Status__c, LU_TECH_AmountForMinimumOrder__c, BillToContact.LU_Eligibility_Groups__c,
                        (SELECT Id, PricebookEntryId, PricebookEntry.LU_Maximum_Quantity__c, Quantity, Product2.LU_Local_Code__c, Product2.Name,
                        Product2.IsActive, PricebookEntry.LU_Limited_Quantity_End_Date__c, PricebookEntry.LU_Limited_Quantity_Start_Date__c, 
                        PricebookEntry.LU_Limited_Quantity_Period__c, PricebookEntry.LU_Limited_Quantity_Value__c, PricebookEntry.IsActive, 
                        PricebookEntry.LU_Start_Date__c, PricebookEntry.LU_End_Date__c, LU_Child_Product__c, Product2.LU_Stock_Status__c, Product2.LU_Stock_Other_Article_Impacted__c,
                        LU_Child_Product__r.LU_Stock_Status__c, LU_Child_Product__r.LU_Local_Code__c, Product2.LU_Bundle_Type__c, Product2.LU_Stock_Substitution_Products__c,
                        LU_Child_Product__r.LU_Min_Qty_Orderable__c
                        FROM OrderItems)
                        FROM Order 
                        WHERE Id =: orderId];
        
        // Check if the order is ok
        res = validateTheOrder(ord, false);

        if (res.success) {
            res = checkProductsAndPriceBookEntriesValidity(ord);
        }

        Id contactId = ord.BillToContactId;
        Contact billTo = AP1003_Utils_Contact.getContactInfo(ord.BillToContactId);
        System.debug('validateOrderOnCheckout > contact: ' + billTo);
        System.debug('validateOrderOnCheckout > LU_Counter_1_Order_Amount_Limit_For__c: ' + billTo.title);

        return (res);
    }

    @AuraEnabled 
    public static ValidationResult validateOrderOnValidation(Id orderId) {

        // Variables
        ValidationResult res = new ValidationResult();

        // Get order information
        Order ord = [SELECT Id, BillToContactId, BillToContact.AccountCountryCode__c, BillToContact.AllowedPaymentMode__c, LU_Total_Amount_For_Valid_Base__c, LU_Payment_Transaction_Status__c,
                        LU_Transport_Mode__c, LU_Transport_Fees__c, LU_Transport_Mode_Label__c, ShippingStreet, ShippingPostalCode, LU_Country_Code__c,
                        ShippingCity, ShippingCountry, LU_Exceptional_To_Adress__c, Status, LU_TECH_AmountForMinimumOrder__c, BillToContact.LU_Eligibility_Groups__c,
                        (SELECT Id, PricebookEntryId, PricebookEntry.LU_Maximum_Quantity__c, Quantity, Product2.LU_Local_Code__c, Product2.Name, Product2.LU_Stock_Substitution_Products__c,
                        PricebookEntry.LU_Limited_Quantity_End_Date__c, PricebookEntry.LU_Limited_Quantity_Start_Date__c, PricebookEntry.LU_Counter_Value__c, Product2.LU_Stock_Other_Article_Impacted__c,
                        PricebookEntry.LU_Limited_Quantity_Period__c, PricebookEntry.LU_Limited_Quantity_Value__c , LU_Child_Product__c, LU_Is_A_Child_Line__c,
                        LU_Child_Product__r.LU_Stock_Status__c, LU_Child_Product__r.LU_Local_Code__c, Product2.LU_Stock_Status__c, Product2.LU_Bundle_Type__c,
                        LU_Child_Product__r.LU_Min_Qty_Orderable__c
                        FROM OrderItems)
                        FROM Order 
                        WHERE Id =: orderId];
        Id contactId = ord.BillToContactId;
        // Get User of the contact associated to the order
        List<User> lUser = [SELECT Id, TECH_ExternalId__c FROM User WHERE IsActive = True AND TECH_MergeContactID__c = :contactId];

        // Check if the order is ok
        res = validateTheOrder(ord, true);

        // If the order is ok
        if (res.success) {
            //empty some payment fields if the user isn't using a credit card
            if(ord != null && ord.BillToContact != null && ord.BillToContact.AllowedPaymentMode__c != null && !ord.BillToContact.AllowedPaymentMode__c.contains('CB') && !ord.BillToContact.AllowedPaymentMode__c.contains('CBP')){
                ord.LU_Payment_Transaction_Id__c = '';
                ord.LU_Payment_Provider__c = '';
                ord.LU_Payment_Transaction_Status__c = 'None';
                ord.LU_Payment_Transaction_Draft_Creation__c = null;
                ord.LU_Payment_Transaction_Draft_Message__c = '';
                ord.LU_Payment_Transaction_Token__c = '';
                ord.LU_Local_Attribute_10__c = '';
            }

            // Update the status to validated and upadte the order with the information
            ord.Status = 'Pending';
            ord.LU_TECH_BO_ExtractionStatus__c = 'To be exported';
            update ord;

            // Update the line to set the extraction status and the counter value
            List<OrderItem> l_item = new List<OrderItem>();
            for (OrderItem item : ord.OrderItems) {
                List<String> l_pbeCounterValues = item.PriceBookEntry.LU_Counter_Value__c.split('#');

                OrderItem itemToUpdate = new OrderItem(Id = item.Id, LU_TECH_BO_ExtractionStatus__c = 'To be exported');

                if(item.LU_Is_A_Child_Line__c == false){
                    for(Integer i = 1; i <= 30; i++){
                        itemToUpdate.put('LU_Counter_' + i + '_new__c', Decimal.valueOf(l_pbeCounterValues.get(i-1)) * item.Quantity); 
                    }
                }

                l_item.add(itemToUpdate);
            }
            if (!l_item.isEmpty()) {
                update l_item;
            }

            // Send confirmation email to BillToContact
            String emailTemplateName = 'LU_' + ord.BillToContact.AccountCountryCode__c + '_ORDER_Confirmation_User';
            List<EmailTemplate> lTemplateEm = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailTemplateName];
            EmailTemplate templateEm = (lTemplateEm!=null && !lTemplateEm.isEmpty() ? 
                                        lTemplateEm[0] : 
                                        [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'LU_Order_Confirmation_User' LIMIT 1]);
            
            OrgWideEmailAddress emailAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName =: AppConstants.NOREPLYITA LIMIT 1];
            
            if (templateEm != null) {
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(lUser[0].Id);
                // mail.setWhatId(ord.Id);
                if(lUser[0].TECH_ExternalId__c.startsWith('ITA') && emailAddress != null) mail.setOrgWideEmailAddressId(emailAddress.Id);
                mail.setTemplateId(templateEm.Id);
                mail.setSaveAsActivity(false);
                messages.add(mail);
                if (!messages.isEmpty())
                {
                    // Send email                
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    if (results[0].success) {
                        res.success = true;
                        res.message = '';
                    } else {
                        res.success = false;
                        res.message = results[0].errors[0].message;
                    }
                }
            }
        }
        return (res);
    }

    public static ValidationResult validateTheOrder(Order ord, Boolean commitToDB) {

        // Init variables
        ValidationResult res = new ValidationResult(true, '');

        // Get Contact information
        Contact billTo = AP1003_Utils_Contact.getContactInfo(ord.BillToContactId);

        // Controls contact activity status, return error if false
        if (billTo.ActivityStatus__c == false) {
            res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_ActivityStatus);
        }

        if (res.success) {
            // Controls contact bad debt, return error if true
            if (billTo.BadDebt__c == true) {
                res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_BadDept);
            }
        }

        if (res.success) {
            // CHECK THE ORDER RULES : must be the last check done, because commit of stock used and counters new balances
            res = checkRulesOnOrder(ord, billTo, commitToDB);
        }

        return (res);
    }

    public static ValidationResult checkRulesOnOrder(Order ord, Contact billTo, Boolean commitToDB) {

        // Variables
        ValidationResult res = new ValidationResult(true, '');
        Boolean stockOk = true;
        Boolean countersOk = true;
        AP1010_Counters_Utils.ValidationReturn checkCounters = null;
        AP1011_Stock_Utils.OrderStockStatus stockStatusForOrder = null;

        // Controls order status, return error if not Draft
        if (ord.Status != 'Draft') {
            res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_NotDraftOrder);
            res.type = 'status';
        }

        //Controls minimum of order, return error if lower than ord.BillToContactId.MinOrder__c
        if (res.success && billTo.MinOrder__c > ord.LU_TECH_AmountForMinimumOrder__c) {
            res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_MinimumOfOrder);
        }

        if (res.success) {
            // Controls max quantity per product
            res = checkMaximumQuantityOrderByLine(ord);
        }

        if (res.success) {
            // Check limited quantity pricebookentry
            res = checkLimitedQuantityByProduct(ord);
        }

        if (res.success) {
            // Controls stock
            stockStatusForOrder = checkStockForOrderValidation(ord);

            // if some products in the order are out of stock
            if (!stockStatusForOrder.lOutOfStockLines.isEmpty()) {

                String messageStock = '';
                res.lOffersWithProblem = new List<String>();
                for (AP1011_Stock_Utils.StockStatus product : stockStatusForOrder.lOutOfStockLines) {

                    if(product.type != 'substitute'){

                        Double stockAvailable = product.stockAvailable - product.stockUsed;
                        if(product.lSubstituteProducts != null && !product.lSubstituteProducts.isEmpty()){
                            for(AP1011_Stock_Utils.StockStatus stSubstitute : product.lSubstituteProducts) {
                                if (!STOCK_STATUS_OUTOFSTOCK.contains(stSubstitute.stockStatus) && product.stockRemaining != null && stSubstitute.stockRemaining > 0) {
                                    stockAvailable += stSubstitute.stockRemaining;
                                }
                            }
                        }
                        
                        String msg = '';
                        if(ord.LU_Country_Code__c == 'ITA'){
                            msg = product.productLocalCode + ' : ' + (product.childOutOfStockMessage != null ? product.childOutOfStockMessage : '');
                            msg += ' ' + Label.LU_Stock_Checkout_Error_Nb_Left + ' ' + Integer.valueOf(stockAvailable);
                        }
                        else{
                            if(product.type == 'child'){
                                for(OrderItem oItem : product.lOrderItemForOrder){
                                    if(oItem.LU_Child_Product__c != null && oItem.Product2.LU_Bundle_Type__c == 'CloseSet'){
                                        msg = oItem.Product2.LU_Local_Code__c + ' / ' + oItem.LU_Child_Product__r.LU_Local_Code__c + ' : ';
                                        if(Integer.valueOf(stockAvailable) == 0){
                                            msg += Label.LU_Stock_OutOfStock_Message + ' ';
                                        }
                                        msg += Label.LU_Stock_Checkout_Error_Nb_Left + ' ' + Integer.valueOf(Integer.valueOf(stockAvailable) / oItem.LU_Child_Product__r.LU_Min_Qty_Orderable__c);
                                        break;
                                    }
                                }
                            }
                            if(msg == ''){
                                msg = product.productLocalCode + ' : ' + (product.childOutOfStockMessage != null ? product.childOutOfStockMessage + ' ': '');
                                if(Integer.valueOf(stockAvailable) == 0){
                                    msg += Label.LU_Stock_OutOfStock_Message + ' ';
                                }
                                msg += Label.LU_Stock_Checkout_Error_Nb_Left + ' ' + Integer.valueOf(stockAvailable);
                            }
                        }
                        messageStock += (messageStock != '' ? ', ' : '') + 
                                        product.stockOutOfStockMessage + (product.childOutOfStockMessage != null ? product.childOutOfStockMessage : '') + ' ; ';

                        res.lOffersWithProblem.add(msg);
                    }
                }
                
                res.message = messageStock;
            }

            if(res.lOffersWithProblem != null && !res.lOffersWithProblem.isEmpty()){
                // Update the order lines accordingly to set the information of out of stock on the matching lines
                updateOrderWithStockInformation(ord, stockStatusForOrder);

                stockOk = false;

                // Set Validation Result values to return
                res.success = false;
                res.type = 'stock';
                res.url = 'order-view';
            }
        }
        
        if (res.success) {
            //Check the counters credits / debits 
            checkCounters = AP1010_Counters_Utils.validateUpdateCounters(ord.Id);
            if (checkCounters.msg != 'OK'){
                countersOk = false;
                res.success = false;
                res.message = checkCounters.msg;
                return res;
            }
        }

        if (commitToDB && countersOk && stockOk) {
            // Decrement the stock for the order (create the LU_Stock_Used__c)
            if (stockStatusForOrder != null) {
                decreaseTheStockForOrder(ord, stockStatusForOrder);
            }
            
            // Update the contact with the new counters balances
            if (checkCounters != null) {
                update checkCounters.con;
            	update checkCounters.lItems;
            }
        }
        return (res);
    }

    // Controls max quantity per product
    public static ValidationResult checkMaximumQuantityOrderByLine(Order ord) {

        ValidationResult res = new ValidationResult(true, '');

        Map<Id, Decimal> m_pbeQuantity = new Map<Id, Decimal>();

        //Sum quantity per pricebookEntry excluding child items
        for(OrderItem oi : ord.OrderItems){
            if(oi.LU_Child_Product__c == null){
                if(!m_pbeQuantity.containsKey(oi.PricebookEntryId)){
                    m_pbeQuantity.put(oi.PricebookEntryId, oi.Quantity);
                }
                else{
                    m_pbeQuantity.put(oi.PricebookEntryId, oi.Quantity + m_pbeQuantity.get(oi.PricebookEntryId));
                }
            }
        }

        Boolean atLeastOneKO = false;
        String errorMessage = '';

        //loop through order items
        for (OrderItem oi : ord.OrderItems)  {
            //exclude child items
            if(oi.LU_Child_Product__c == null){

                //Controls pricebookentry quantity, return error if greater than PricebookEntry.LU_Maximum_Quantity__c
                if (m_pbeQuantity.get(oi.PricebookEntryId) > oi.PricebookEntry.LU_Maximum_Quantity__c) {

                    if (atLeastOneKO == false) {
                        res = new ValidationResult(false, '');
                        atLeastOneKO = true;
                    }
                    
                    String errmsg = Label.LU_Checkout_Validation_Error_MaximumQuantity;
                    errmsg = errmsg.replace('$MAXQUANTITY', String.valueOf(oi.PricebookEntry.LU_Maximum_Quantity__c));
                    errmsg = errmsg.replace('$OFFERREF', oi.Product2.LU_Local_Code__c + ' - ' + oi.Product2.Name);
                    errorMessage += (errorMessage != '' ? ', ' + errmsg : errmsg);
                    res.message = errorMessage;
                }
            }
        }
        return (res);
    }

    /* Check the limited quantity product */
    public static ValidationResult checkLimitedQuantityByProduct(Order ord) {

        ValidationResult res = new ValidationResult(true, '');

        // Get the product with limited quantity on the order
        List<OrderItem> lLimitedQuantityLines = new List<OrderItem>();
        Map<Id, Double> m_pbeQuantity = new Map<Id, Double>();
        Datetime shorterStartPeriod = null;
        Datetime higherEndPeriod = null;

        for (OrderItem line : ord.OrderItems) {
            // Controls that a product is in a limited quantity period
            if (line.LU_Child_Product__c == null &&
                line.PricebookEntry.LU_Limited_Quantity_Period__c &&
                line.PricebookEntry.LU_Limited_Quantity_Start_Date__c <= Datetime.now() && 
                line.PricebookEntry.LU_Limited_Quantity_End_Date__c >= Datetime.now()) {

                lLimitedQuantityLines.add(line);

                //Sum quantity per pricebookEntry
                if(!m_pbeQuantity.containsKey(line.PricebookEntryId)){
                    m_pbeQuantity.put(line.PricebookEntryId, line.Quantity);
                }
                else{
                    m_pbeQuantity.put(line.PricebookEntryId, line.Quantity + m_pbeQuantity.get(line.PricebookEntryId));
                }
            }
        }

        if (!m_pbeQuantity.isEmpty()) {
            
            // Retrieve the lines already ordered for those pricebookentry
            List<OrderItem> lLinesAlreadyOrdered = [SELECT Id, PricebookEntryId, Quantity, CreatedDate,
                                                    PricebookEntry.LU_Limited_Quantity_Start_Date__c,
                                                    PricebookEntry.LU_Limited_Quantity_End_Date__c
                                                    FROM OrderItem
                                                    WHERE Order.BillToContactId = :ord.BillToContactId
                                                    AND LU_Child_Product__c = null 
                                                    AND PricebookEntryId IN :m_pbeQuantity.keyset()
                                                    AND Order.Status != 'Draft'
                                                    ];

            //for every limited quantity pricebookentry already ordered
            for (OrderItem line : lLinesAlreadyOrdered) {

                // Check if the creation date of the line is during the limited period
                if (line.CreatedDate >= line.PricebookEntry.LU_Limited_Quantity_Start_Date__c &&
                    line.CreatedDate <= line.PricebookEntry.LU_Limited_Quantity_End_Date__c) {
                    
                    // Add the quantity previously ordered to the sum of quantity ordered
                    if (m_pbeQuantity.containsKey(line.PricebookEntryId)) {
                        m_pbeQuantity.put(line.PricebookEntryId, line.Quantity + m_pbeQuantity.get(line.PricebookEntryId));
                    }
                }
            }

            // Check if all the quantity limited by period are respected
            String message = '';
            for (OrderItem line : lLimitedQuantityLines) {

                // Get the quantity allowed for this offer
                Double quantityAllowed = line.PricebookEntry.LU_Limited_Quantity_Value__c;
                // Get the quantity ordered for this offer during the limited period
                Double quantityOrdered = m_pbeQuantity.get(line.PricebookEntryId);

                // If the quantity ordered is higher than the quantity allowed, set error message
                if (quantityOrdered > quantityAllowed) {
                    String errmsg = Label.LU_Checkout_Validation_Error_LimitedQuantity;
                    errmsg = errmsg.replace('$REF', line.Product2.LU_Local_Code__c + ' - ' + line.Product2.Name);
                    errmsg = errmsg.replace('$ALLOWED', String.valueOf(Integer.valueOf(quantityAllowed)));
                    errmsg = errmsg.replace('$ORDERED', String.valueOf(Integer.valueOf(quantityOrdered)));
                    message += (message != '' ? ', ' : '') + errmsg;
                }
            }

            // If the error message is not empty, means some limited quantity have not been respected
            if (message != '') {
                res.success = false;
                res.message = message;
            }
        }

        return res;
    }

    /* Calculate the stock for the order in parameter. Return the product local code that are out of stock */
    public static AP1011_Stock_Utils.OrderStockStatus checkStockForOrderValidation(Order ord) {

        // Variables
        AP1011_Stock_Utils.OrderStockStatus status = new AP1011_Stock_Utils.OrderStockStatus();
        status.lOutOfStockLines = new List<AP1011_Stock_Utils.StockStatus>();
        status.lStockUsedToInsertForOrder = new List<LU_Stock_Used__c>();

        List<OrderItem> l_orderItemToManage = new List<OrderItem>();

        for(OrderItem oi : ord.OrderItems){
            if(STOCK_STATUS_TO_MANAGE.contains(oi.Product2.LU_Stock_Status__c) || STOCK_STATUS_LIMITED.contains(oi.Product2.LU_Stock_Status__c)
            || STOCK_STATUS_TO_MANAGE.contains(oi.LU_Child_Product__r.LU_Stock_Status__c) || STOCK_STATUS_LIMITED.contains(oi.LU_Child_Product__r.LU_Stock_Status__c)){
                l_orderItemToManage.add(oi);
            }
        }

        // If the order has lines to be managed
        if (!l_orderItemToManage.isEmpty()) {

            // Eligibility segment of contact
            Set<String> sEligibilitySegmentOfContact = new Set<String>();
            if (!String.isBlank(ord.BillToContact.LU_Eligibility_Groups__c)) {
                for (String groupEligibilty : ord.BillToContact.LU_Eligibility_Groups__c.split('#')) {
                    sEligibilitySegmentOfContact.add(groupEligibilty);
                }
            }

            // Get the list of product local code of the order and product Id linked to orderitems of the order
            Set<String> sProductLocalCodesOfOrder = new Set<String>();
            List<String> l_idProduct = new List<String>();
            for (OrderItem line : l_orderItemToManage) {
                if(line.LU_Child_Product__c != null){
                    sProductLocalCodesOfOrder.add(line.LU_Child_Product__r.LU_Local_Code__c);
                    l_idProduct.add(line.LU_Child_Product__c);
                }
                else{
                    sProductLocalCodesOfOrder.add(line.Product2.LU_Local_Code__c);
                    l_idProduct.add(line.Product2Id);
                }
            }

            // Get the remaining stock of those product local code
            List<AP1011_Stock_Utils.StockStatus> lStockStatusOfOrder = getStockRemainingForProducts(l_idProduct, sProductLocalCodesOfOrder, 
                                                    sEligibilitySegmentOfContact, ord.BillToContact.AccountCountryCode__c);

            // Link the stock status to the line of orders
            lStockStatusOfOrder = matchStockStatusToOrderItem(lStockStatusOfOrder, ord);

            Id vUserId = UserInfo.getUserId();
            String vCountry = ord.BillToContact.AccountCountryCode__c;

            //build map of quantity per local code
            Map<String, Decimal> m_quantityPerLocalCode = new Map<String, Decimal>();
            for(OrderItem oi : l_orderItemToManage){
                if(oi.LU_Child_Product__c == null){
                    if(!m_quantityPerLocalCode.containsKey(oi.Product2.LU_Local_Code__c)){
                        m_quantityPerLocalCode.put(oi.Product2.LU_Local_Code__c, 0);
                    }
                    m_quantityPerLocalCode.put(oi.Product2.LU_Local_Code__c, oi.Quantity + m_quantityPerLocalCode.get(oi.Product2.LU_Local_Code__c));
                }
                else{
                    if(!m_quantityPerLocalCode.containsKey(oi.LU_Child_Product__r.LU_Local_Code__c)){
                        m_quantityPerLocalCode.put(oi.LU_Child_Product__r.LU_Local_Code__c, 0);
                    }
                    m_quantityPerLocalCode.put(oi.LU_Child_Product__r.LU_Local_Code__c, oi.Quantity + m_quantityPerLocalCode.get(oi.LU_Child_Product__r.LU_Local_Code__c));
                }
            }

            for (AP1011_Stock_Utils.StockStatus stock : lStockStatusOfOrder) {
                stock.quantityInTheOrder = m_quantityPerLocalCode.get(stock.productLocalCode);
            }

            Map<String, Integer> m_closeSetQuantityToReplace = new Map<String, Integer>();

            // Go through the stock status and check for each article if the stock is enough
            for (AP1011_Stock_Utils.StockStatus stock : lStockStatusOfOrder) {
                
                Boolean isOutOfStock = false;
                Boolean isSubstituteCanReplace = false;

                isOutOfStock = isProductOutOfStock(stock);

                // If the main product is out of check
                if (isOutOfStock) {
                    // Check if some stubstitute products can fill the order
                    isSubstituteCanReplace = isProductOutOfStockCanBeReplaceBySubstituteProduct(stock);
                }

                if (isOutOfStock && !isSubstituteCanReplace) {
                    status.lOutOfStockLines.add(stock);
                }
                else {
                    Decimal quantityToBeUsed = stock.quantityInTheOrder;

                    // Create the line of LU_Stock_Used__c for each line of order for each product local code related to the right product
                    for (OrderItem item : stock.lOrderItemForOrder) {

                        // Get the product to decrease the stock : either the main product or the child if a child line of a bundle
                        Id productId = (item.LU_Child_Product__c != null ? item.LU_Child_Product__c : item.Product2Id);
                        Decimal quantityToBeUsedForThisLine = item.Quantity;

                        //for ITA
                        //if not enough child in a close set, get quantity missing to replace entire set
                        if(ord.LU_Country_Code__c == 'ITA' && item.LU_Child_Product__c != null && item.Product2.LU_Bundle_Type__c == 'CloseSet'){

                            status.lStockUsedToInsertForOrder.add(
                                new LU_Stock_Used__c(CurrencyIsoCode = STOCK_USED_CURRENCYISOCODE, 
                                LU_Order__c = ord.Id, 
                                LU_Order_Line__c = item.Id,
                                LU_Product__c = productId,
                                LU_Quantity_Ordered__c = quantityToBeUsedForThisLine,
                                LU_Product_Local_Code__c = stock.productLocalCode,
                                LU_Product_Local_Name__c = stock.productName)
                            );

                            if(stock.stockRemaining - quantityToBeUsedForThisLine < 0){
                                if(!m_closeSetQuantityToReplace.containsKey(item.Product2Id) || m_closeSetQuantityToReplace.get(item.Product2Id) < quantityToBeUsedForThisLine - stock.stockRemaining){
                                    m_closeSetQuantityToReplace.put(item.Product2Id, Integer.valueOf(quantityToBeUsedForThisLine - stock.stockRemaining));
                                }
                            }
                        }
                        else if (!STOCK_STATUS_LIMITED.contains(stock.stockStatus) || 
                            (stock.lSubstituteProducts != null && !stock.lSubstituteProducts.isEmpty()) ){

                            Decimal quantityToUse = 0;
                            
                            // if product has multiplication factor case
                            if(!String.isBlank(item.Product2.LU_Stock_Other_Article_Impacted__c)){
                                // If the main article has enough stock to fill the order, create the Stock Used
                                if (stock.stockRemaining - (quantityToBeUsedForThisLine * Integer.valueOf(item.Product2.LU_Stock_Other_Article_Impacted__c)) >= 0) {
                                    quantityToUse = quantityToBeUsedForThisLine * Integer.valueOf(item.Product2.LU_Stock_Other_Article_Impacted__c);
                                    quantityToBeUsedForThisLine = 0;
                                }
                                else if(stock.stockRemaining > 0){
                                    quantityToUse = Integer.valueOf(stock.stockRemaining) / Integer.valueOf(item.Product2.LU_Stock_Other_Article_Impacted__c);
                                    quantityToUse = Integer.valueOf(quantityToUse) * Integer.valueOf(item.Product2.LU_Stock_Other_Article_Impacted__c);
                                    quantityToBeUsedForThisLine -= (Integer.valueOf(stock.stockRemaining) / Integer.valueOf(item.Product2.LU_Stock_Other_Article_Impacted__c));
                                    
                                }
                            }
                            else {
                                // If the main article has enough stock to fill the order, create the Stock Used
                                if (stock.stockRemaining - quantityToBeUsedForThisLine >= 0) {
                                    quantityToUse = quantityToBeUsedForThisLine;
                                    quantityToBeUsedForThisLine = 0;
                                }
                                else if(stock.stockRemaining > 0){
                                    quantityToUse = stock.stockRemaining;
                                    quantityToBeUsedForThisLine -= stock.stockRemaining;
                                }
                            }
                            
                            if(quantityToUse > 0){
                                status.lStockUsedToInsertForOrder.add(
                                    new LU_Stock_Used__c(CurrencyIsoCode = STOCK_USED_CURRENCYISOCODE, 
                                    LU_Order__c = ord.Id, 
                                    LU_Order_Line__c = item.Id,
                                    LU_Product__c = productId, //item.Product2Id,
                                    LU_Quantity_Ordered__c = quantityToUse,
                                    LU_Product_Local_Code__c = stock.productLocalCode,
                                    LU_Product_Local_Name__c = stock.productName)
                                );
                            }
                            
                            while (quantityToBeUsedForThisLine > 0) {
                                
                                // use the substitute article to fill the rest of the order line quantity
                                if (quantityToBeUsedForThisLine > 0) {

                                    if(stock.lSubstituteProducts != null){
                                        for (AP1011_Stock_Utils.StockStatus stSubstitute : stock.lSubstituteProducts) {
                                            quantityToUse = 0;
                                            if (stSubstitute.stockRemaining != null && stSubstitute.stockRemaining > 0) {
                                                
                                                // if product has multiplication factor case
                                                if(stSubstitute.multiplicationFactor != null){
                                                    // If the substitute can finish filling the order
                                                    if (stSubstitute.stockRemaining - (Integer.valueOf(quantityToBeUsedForThisLine) * stSubstitute.multiplicationFactor) > 0) {
                                                        quantityToUse = Integer.valueOf(quantityToBeUsedForThisLine) * stSubstitute.multiplicationFactor;
                                                        quantityToBeUsedForThisLine = 0;
                                                    }
                                                    // if sub can't fill the order, use sub stock remaining
                                                    else {
                                                        quantityToUse = stSubstitute.stockRemaining / stSubstitute.multiplicationFactor;
                                                        quantityToUse = Integer.valueOf(quantityToUse) * stSubstitute.multiplicationFactor;
                                                        quantityToBeUsedForThisLine -= stSubstitute.stockRemaining / stSubstitute.multiplicationFactor;
                                                    }
                                                }
                                                else {
                                                    // If the substitute can finish filling the order
                                                    if (stSubstitute.stockRemaining - quantityToBeUsedForThisLine > 0) {
                                                        quantityToUse = quantityToBeUsedForThisLine;
                                                        quantityToBeUsedForThisLine = 0;
                                                    }
                                                    // if sub can't fill the order, use sub stock remaining
                                                    else {
                                                        quantityToUse = stSubstitute.stockRemaining;
                                                        quantityToBeUsedForThisLine -= stSubstitute.stockRemaining;
                                                    }
                                                }

                                                status.lStockUsedToInsertForOrder.add(
                                                    new LU_Stock_Used__c(CurrencyIsoCode = STOCK_USED_CURRENCYISOCODE, 
                                                                        LU_Order__c = ord.Id, 
                                                                        LU_Order_Line__c = item.Id,
                                                                        LU_Product__c = stSubstitute.product2IdOfSubstituteOffer,
                                                                        LU_Quantity_Ordered__c = quantityToUse,
                                                                        LU_Product_Local_Code__c = stSubstitute.productLocalCode,
                                                                        LU_Product_Local_Name__c = stSubstitute.productName)
                                                );

                                                if(quantityToBeUsedForThisLine == 0){
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ITA replace entire close set if child stock isn't enough
            if(!m_closeSetQuantityToReplace.isEmpty()){

                System.Debug('close set with replacement');
                System.Debug(m_closeSetQuantityToReplace);

                Map<String, List<String>> m_subParentLocalCodePerCloseSet = new Map<String, List<String>>();
                Set<String> s_subParentLocalCode = new Set<String>();

                List<OrderItem> l_closeSetOrderItem = [SELECT Id, Product2.LU_Stock_Substitution_Products__c, Product2Id
                                                        FROM OrderItem
                                                        WHERE Product2Id IN :m_closeSetQuantityToReplace.keyset()
                                                          AND OrderId = :ord.Id
                                                          AND LU_Child_Product__c = ''];

                System.Debug('l_closeSetOrderItem');
                System.Debug(l_closeSetOrderItem);

                for(OrderItem closeSetOrderItem : l_closeSetOrderItem){
                    m_subParentLocalCodePerCloseSet.put(closeSetOrderItem.Id, closeSetOrderItem.Product2.LU_Stock_Substitution_Products__c.split(STOCK_SUBSTITUTE_SEPARATOR));
                    s_subParentLocalCode.addAll(closeSetOrderItem.Product2.LU_Stock_Substitution_Products__c.split(STOCK_SUBSTITUTE_SEPARATOR));
                }

                System.Debug('m_subParentLocalCodePerCloseSet');
                System.Debug(m_subParentLocalCodePerCloseSet);

                System.Debug('s_subParentLocalCode');
                System.Debug(s_subParentLocalCode);

                Map<String, Integer> m_quantityPerSubstituteCloseSetLocalCode = new Map<String, Integer>();

                for(String parentId : m_closeSetQuantityToReplace.keyset()){
                    for (AP1011_Stock_Utils.StockStatus stock : lStockStatusOfOrder) {
                        for (OrderItem item : stock.lOrderItemForOrder) {
                            if(item.Product2Id == parentId){
                                for(LU_Stock_Used__c stockUsed : status.lStockUsedToInsertForOrder){
                                    if(stockUsed.LU_Product__c == parentId || stockUsed.LU_Product__c == item.LU_Child_Product__c){
                                        stockUsed.LU_Quantity_Ordered__c -= m_closeSetQuantityToReplace.get(parentId);
                                    }
                                }
                            }
                        }
                    }
                }

                Map<String, List<Product2>> m_subsitutePerLocalCode = new Map<String, List<Product2>>();

                List<String> l_idProductOffer = new List<String>();

                for(PriceBookEntry pbeParentSubstitute : [SELECT Id, Product2Id
                                                            FROM PriceBookEntry
                                                            WHERE Product2.LU_Local_Code__c IN :s_subParentLocalCode
                                                            AND (
                                                                LU_Eligibility_Segments__c = '*' 
                                                                OR LU_Eligibility_Segments__c LIKE :sEligibilitySegmentOfContact
                                                            )
                                                            AND Pricebook2.Name != 'Catalogue standard'
                                                            AND IsActive = true
                                                            AND LU_Start_Date__c <= :Datetime.now()
                                                            AND LU_End_Date__c >= :Datetime.now()
                                                            AND LU_TECH_External_Id__c LIKE 'ITA%'
                                                            AND Product2.LU_Country__c = 'ITA']){
                    l_idProductOffer.add(pbeParentSubstitute.Product2Id);
                }

                System.Debug('l_idProductOffer');
                System.Debug(l_idProductOffer);

                for(Product2 subChildProduct : [SELECT Id, LU_Local_Code__c, LU_Local_Name__c, LU_Parent_Product__r.LU_Local_Code__c
                                                FROM Product2 
                                                WHERE LU_Parent_Product__c = :l_idProductOffer
                                                AND IsActive = true 
                                                AND 
                                                (
                                                    (LU_Child_Start_date__c <= :Date.today() AND LU_Child_End_date__c >= :Date.today() )
                                                    OR
                                                    (LU_Child_Start_date__c = null AND LU_Child_End_date__c = null)
                                                )]){
                    if(!m_subsitutePerLocalCode.containsKey(subChildProduct.LU_Parent_Product__r.LU_Local_Code__c)){
                        m_subsitutePerLocalCode.put(subChildProduct.LU_Parent_Product__r.LU_Local_Code__c, new List<Product2>());
                    }
                    m_subsitutePerLocalCode.get(subChildProduct.LU_Parent_Product__r.LU_Local_Code__c).add(subChildProduct);
                }

                System.Debug('m_subsitutePerLocalCode');
                System.Debug(m_subsitutePerLocalCode);
                
                for(OrderItem parentOrderItem : l_closeSetOrderItem){
                    for(String subCloseSetParentLocalCode : m_subParentLocalCodePerCloseSet.get(parentOrderItem.Id)){
                        for(Product2 subChild : m_subsitutePerLocalCode.get(subCloseSetParentLocalCode)){
                            status.lStockUsedToInsertForOrder.add(
                                new LU_Stock_Used__c(CurrencyIsoCode = STOCK_USED_CURRENCYISOCODE, 
                                                    LU_Order__c = ord.Id, 
                                                    LU_Order_Line__c = parentOrderItem.Id,
                                                    LU_Product__c = subChild.Id,
                                                    LU_Quantity_Ordered__c = m_closeSetQuantityToReplace.get(parentOrderItem.Product2Id),
                                                    LU_Product_Local_Code__c = subChild.LU_Local_Code__c,
                                                    LU_Product_Local_Name__c = subChild.LU_Local_Name__c)
                            );
                        }
                    }
                }
            }
        }
        // Return the stock status for the product local code that are out of stock
        return (status);
    }

    public static List<AP1011_Stock_Utils.StockStatus> getStockRemainingForProducts(List<Id> l_idProduct,
                                                                Set<String> sLocalCodes, 
                                                                Set<String> sEligibilitySegmentOfContact, 
                                                                String country) {
        // Variables
        List<AP1011_Stock_Utils.StockStatus> lStockStatus = new List<AP1011_Stock_Utils.StockStatus>();
        List<PricebookEntry> lSubstitutePricebookEntries = null;
        Set<String> sSubstituteProductLocalCode = new Set<String>();
        Map<String, List<String>> mSubstituteLocalCodeByProductLocalCode = new Map<String, List<String>>();
        Map<String, List<Product2>> mChildByBundle = new Map<String, List<Product2>>();
        Set<String> sChildProductLocalCode = null;

        // Retrieve the product that have stock management enable and stock information
        List<Product2> lProducts = [SELECT Id, LU_Local_Code__c, Name, LU_Stock_Status__c, LU_Stock_Available__c, LU_Stock_Information__c, 
                                    LU_Stock_Substitution_Message__c, LU_Stock_Substitution_Products__c , RecordType.DeveloperName, LU_Parent_Product__c,
                                    LU_Stock_Other_Article_Impacted__c,
                                    (SELECT Id, Name, LU_Local_Code__c, LU_Parent_Product__c, LU_Parent_Product__r.LU_Local_Code__c 
                                        FROM Products__r 
                                        WHERE LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE)
                                    FROM Product2
                                    WHERE LU_Local_Code__c in :sLocalCodes
                                    AND Id IN :l_idProduct
                                    AND ( LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE OR LU_Stock_Status__c in :STOCK_STATUS_LIMITED ) 
                                    AND LU_Country__c = :country];

        // Get the list of bundle and substitutes of the product retrieved
        for (Product2 p : lProducts) {

            // If the product has substitutes
            if (!String.IsBlank(p.LU_Stock_Substitution_Products__c)) {
                mSubstituteLocalCodeByProductLocalCode.put(p.LU_Local_Code__c, p.LU_Stock_Substitution_Products__c.split(STOCK_SUBSTITUTE_SEPARATOR));
            }
            // If the product is a bundle
            if (p.RecordType.DeveloperName == STOCK_PRODUCT_RT_BUNDLE) {
                mChildByBundle.put(p.LU_Local_Code__c, p.Products__r);
            }
        }

        //Builds Set of childs LocalCode
        if (!mChildByBundle.isEmpty()) {
            sChildProductLocalCode = new Set<String>();
            for (String parentId : mChildByBundle.keyset()) {
                for (Product2 child : mChildByBundle.get(parentId)) {
                    sChildProductLocalCode.add(child.LU_Local_Code__c);
                }
            }
        }
        
        if (!mSubstituteLocalCodeByProductLocalCode.isEmpty()) {
            //Builds Set of subsitute LocalCode
            for (List<String> itemsByLocalCode : mSubstituteLocalCodeByProductLocalCode.values()) {
                sSubstituteProductLocalCode.addAll(itemsByLocalCode);
            }

            String techtexternalid = country + '%';
            
            // SOQL pricebookentry of subsitute 
            lSubstitutePricebookEntries = [SELECT Id, Name, UnitPrice, Product2.Id, Product2.LU_Stock_Status__c, Product2.LU_Local_Code__c, Product2.LU_Smart_Reference__c,
                                            LU_TECH_External_Id__c, Product2.RecordType.Name, PriceBook2Id, Product2.LU_Number_Of_Articles__c,
                                            LU_Valid_For_Total_Amount_Base__c, LU_TaxRate__c, Product2.RecordType.DeveloperName,
                                            LU_Eligibility_Segments__c, LU_Offer_type__c, Product2.LU_Bundle_Type__c, Product2.LU_TECH_External_Id__c
                                            FROM PricebookEntry
                                            WHERE Product2.LU_Local_Code__c IN :sSubstituteProductLocalCode
                                            //AND Product2.LU_Stock_Status__c IN :STOCK_STATUS_TO_MANAGE
                                            AND (
                                                LU_Eligibility_Segments__c = '*' 
                                                OR LU_Eligibility_Segments__c LIKE :sEligibilitySegmentOfContact
                                            )
                                            AND Pricebook2.Name != 'Catalogue standard'
                                            AND IsActive = true
                                            AND LU_Start_Date__c <= :Datetime.now()
                                            AND LU_End_Date__c >= :Datetime.now()
                                            AND LU_TECH_External_Id__c LIKE :techtexternalid
                                            AND Product2.LU_Country__c = :country];

            List<Product2> lSubstituteProductToManage = [SELECT Id, Name, LU_Local_Code__c, LU_Stock_Status__c, LU_Stock_Available__c, LU_Stock_Information__c, 
                                                                LU_Stock_Substitution_Message__c, LU_Stock_Substitution_Products__c, LU_Parent_Product__c,
                                                                LU_Stock_Other_Article_Impacted__c
                                                           FROM Product2
                                                          WHERE LU_Local_Code__c in :sSubstituteProductLocalCode
                                                            //AND LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE
                                                            AND LU_Country__c = :country];

            lProducts.addAll(lSubstituteProductToManage);

            sLocalCodes.addAll(sSubstituteProductLocalCode);
        }

        lStockStatus = lwc17_searchProduct.calculateRemainingStockOfProducts(lProducts, sLocalCodes, mSubstituteLocalCodeByProductLocalCode, 
                                                                            lSubstitutePricebookEntries, mChildByBundle, country);

        return lStockStatus;
    }

    /* Check if the product is out of stock with the stock status and the stock remaining */
    public static Boolean isProductOutOfStock(AP1011_Stock_Utils.StockStatus productStock) {
        
        Boolean isOutOfStock = false;

        //status out of stock OR Stock <= 0 OR quantity ordered > stock
        if (STOCK_STATUS_OUTOFSTOCK.contains(productStock.stockStatus)  || 
            productStock.stockRemaining == null || 
            (productStock.stockRemaining != null && productStock.stockRemaining <= 0) ||
            (productStock.stockRemaining != null && productStock.quantityInTheOrder != null && (productStock.stockRemaining - productStock.quantityInTheOrder) < 0 ) ||
            (productStock.multiplicationFactor != null && productStock.stockRemaining != null && productStock.quantityInTheOrder != null && (productStock.stockRemaining - (productStock.quantityInTheOrder * productStock.multiplicationFactor) ) < 0 ) ) {
                
            // Manage case of LImited quantity product : if limited quantity article and no replacment product : then is not out of stock
            /*if (STOCK_STATUS_LIMITED.contains(productStock.stockStatus) && 
                (productStock.lSubstituteProducts == null || (productStock.lSubstituteProducts != null && productStock.lSubstituteProducts.isEmpty()) ) ) {
                isOutOfStock = false;
            } else {*/
                isOutOfStock = true;
                // Set the missing quantity to be checked with the subsitute articles
                productStock.quantityMissingForProduct = (productStock.quantityInTheOrder != null ? productStock.quantityInTheOrder - productStock.stockRemaining : 0);
            //}
        }

        // If the product is a bundle, check that its child article are not out of stock
        // if (productStock.lChilds != null && !productStock.lChilds.isEmpty()) {

        //     for (AP1011_Stock_Utils.StockStatus stChild : productStock.lChilds) {
        //         // Check the status and the quantity remaining in stock
        //         if (STOCK_STATUS_OUTOFSTOCK.contains(stChild.stockStatus)  || stChild.stockRemaining == null || 
        //             (stChild.stockRemaining != null && stChild.stockRemaining <= 0) ||
        //             (stChild.quantityInTheOrder != null && stChild.stockRemaining != null && (stChild.stockRemaining - stChild.quantityInTheOrder) < 0 )) {
                    
        //             isOutOfStock = true;
                    
        //             String childrenMissingMessage = Label.LU_Stock_Checkout_Error_ChildrenMissing;
        //             childrenMissingMessage = childrenMissingMessage.replace('$REF', stChild.productLocalCode);

        //             productStock.childOutOfStockMessage = (productStock.childOutOfStockMessage != null && productStock.childOutOfStockMessage != '' ? 
        //                                                     ', ' + childrenMissingMessage : 
        //                                                     childrenMissingMessage);

        //             // Set the missing quantity to be checked with the subsitute articles
        //             stChild.quantityMissingForProduct = (stChild.quantityInTheOrder != null ? stChild.quantityInTheOrder - stChild.stockRemaining : 0);
        //         }
        //     }
        // }

        return isOutOfStock;
    }

    public static Boolean isProductOutOfStockCanBeReplaceBySubstituteProduct(AP1011_Stock_Utils.StockStatus productStock) {
    
        // Variables
        Boolean isSubstituteCanReplace = false;

        for(OrderItem oItem : productStock.lOrderItemForOrder){
            if(oItem.LU_Child_Product__c != null && oItem.Product2.LU_Bundle_Type__c == 'CloseSet' && !String.IsBlank(oItem.Product2.LU_Stock_Substitution_Products__c)){
                return true;
            }
        }

        if (productStock.lSubstituteProducts != null && !productStock.lSubstituteProducts.isEmpty()) {
            
            // Quantity of the order to fill
            Decimal quantityToFill = productStock.quantityMissingForProduct;

            for (AP1011_Stock_Utils.StockStatus stSubstitute : productStock.lSubstituteProducts) {
                
                if (!STOCK_STATUS_OUTOFSTOCK.contains(stSubstitute.stockStatus) && stSubstitute.stockRemaining != null && stSubstitute.stockRemaining > 0) {

                    // If the substitute article is enough to fill all the remaining quantity
                    if (stSubstitute.stockRemaining - quantityToFill > 0) {
                        stSubstitute.quantityInTheOrder = quantityToFill;
                    } 
                    // if the substitute article is not enough to fill all the remaining quantity, use the quantity available 
                    else { 
                        stSubstitute.quantityInTheOrder = stSubstitute.stockRemaining;
                    }

                    quantityToFill -= stSubstitute.quantityInTheOrder;
                }

                // If all the quantity have been filled, then stock looking for stock availability of substitute article
                if (quantityToFill == 0) { break; }
            }

            // If the quantity of substitute is enough, return true
            if (quantityToFill == 0) {
                isSubstituteCanReplace = true;
            }

        }

        return (isSubstituteCanReplace);
    }

    public static void updateOrderWithStockInformation(Order ord, AP1011_Stock_Utils.OrderStockStatus status) {

        List<OrderItem> lItemsToUpdate = new List<OrderItem>();

        // For each line of order, get the stock status associated
        for (OrderItem item : ord.OrderItems) {

            if(STOCK_STATUS_TO_MANAGE.contains(item.Product2.LU_Stock_Status__c) || STOCK_STATUS_LIMITED.contains(item.Product2.LU_Stock_Status__c)
            || STOCK_STATUS_TO_MANAGE.contains(item.LU_Child_Product__r.LU_Stock_Status__c) || STOCK_STATUS_LIMITED.contains(item.LU_Child_Product__r.LU_Stock_Status__c)){
                AP1011_Stock_Utils.StockStatus stProductOfItem = null;

                // Get the line of stock status that match the product local code of the order line
                for (AP1011_Stock_Utils.StockStatus st : status.lOutOfStockLines) {
                    if (st.productLocalCode == item.Product2.LU_Local_Code__c) {
                        stProductOfItem = st;
                        break;
                    }
                }

                // If there is a line of stockstatus, that means there is an issue on this product : out of stock. Put the information on the line and save.
                if (stProductOfItem != null) {
                    String stockInfoMessage = (stProductOfItem.stockOutOfStockMessage != null ? stProductOfItem.stockOutOfStockMessage : '');
                    stockInfoMessage += (stProductOfItem.childOutOfStockMessage != null ? ' : ' + stProductOfItem.childOutOfStockMessage : '');
                    OrderItem it = new OrderItem(Id = item.Id, LU_Stock_Status__c = 'outofstock');
                    if(!stockInfoMessage.contains('replaced') && !stockInfoMessage.contains('remplacé') && !stockInfoMessage.contains('sostituita')){
                        it.LU_Stock_Message__c = '';
                    }
                    else{
                        it.LU_Stock_Message__c = stockInfoMessage;
                    }
                    lItemsToUpdate.add(it);
                } else { // If no stock status, update the line with no stock status
                    OrderItem it = new OrderItem(Id = item.Id, LU_Stock_Status__c = 'ok', LU_Stock_Message__c = '');
                    lItemsToUpdate.add(it);
                }
            }
            else { // If no stock status, update the line with no stock status
                OrderItem it = new OrderItem(Id = item.Id, LU_Stock_Status__c = 'ok', LU_Stock_Message__c = '');
                lItemsToUpdate.add(it);
            }
        }

        // Update the order lines
        if (!lItemsToUpdate.isEmpty()) {
            update lItemsToUpdate;
        }
    }

    public static void decreaseTheStockForOrder(Order ord, AP1011_Stock_Utils.OrderStockStatus orderStockStatus) {

        List<OrderItem> lOrderItemsToUpdate = new List<OrderItem>();

        if (orderStockStatus.lStockUsedToInsertForOrder != null && !orderStockStatus.lStockUsedToInsertForOrder.isEmpty()) {
            
            Map<String, Integer> m_multFactorPerProductLocalCode = new Map<String,  Integer>();
            Set<String> s_idProductOfStockUsed = new Set<String>();

            for (LU_Stock_Used__c stUsed : orderStockStatus.lStockUsedToInsertForOrder) {
                s_idProductOfStockUsed.add(stUsed.LU_Product__c);
            }

            for(Product2 prod : [SELECT Id, LU_Stock_Other_Article_Impacted__c FROM Product2 WHERE Id IN :s_idProductOfStockUsed]){
                if(prod.LU_Stock_Other_Article_Impacted__c != null && prod.LU_Stock_Other_Article_Impacted__c.isNumeric()){
                    m_multFactorPerProductLocalCode.put(prod.Id, Integer.valueOf(prod.LU_Stock_Other_Article_Impacted__c));
                }
            }

            // Get local code of order item to manage
            for (OrderItem item : ord.OrderItems) {

                if(item.Product2.LU_Stock_Status__c != 'DynamicWithoutMessage' && item.LU_Child_Product__r.LU_Stock_Status__c != 'DynamicWithoutMessage'){
                    if(STOCK_STATUS_TO_MANAGE.contains(item.Product2.LU_Stock_Status__c) || STOCK_STATUS_LIMITED.contains(item.Product2.LU_Stock_Status__c)
                    || STOCK_STATUS_TO_MANAGE.contains(item.LU_Child_Product__r.LU_Stock_Status__c) || STOCK_STATUS_LIMITED.contains(item.LU_Child_Product__r.LU_Stock_Status__c)){
                    
                        String msgSubsituteForOrderItem = '';

                        for (LU_Stock_Used__c stUsed : orderStockStatus.lStockUsedToInsertForOrder) {
                            if (stUsed.LU_Order_Line__c == item.Id && stUsed.LU_Product__c != item.Product2Id && stUsed.LU_Product__c != item.LU_Child_Product__c) {

                                //check if used stock is linked to a product with multiplication factor
                                Integer multFactor = m_multFactorPerProductLocalCode.get(stUsed.LU_Product__c);

                                String msg = Label.LU_Stock_Order_ReplacedLine;
                                if(multFactor != null && multFactor > 0){
                                    msg = msg.replace('$QUANTITYREPLACED', (Integer)(stUsed.LU_Quantity_Ordered__c / multFactor) + '');
                                }
                                else{
                                    msg = msg.replace('$QUANTITYREPLACED', (Integer)stUsed.LU_Quantity_Ordered__c + '');
                                }
                                msg = msg.replace('$OFFERREPLACMENT', stUsed.LU_Product_Local_Code__c + ' ' + stUsed.LU_Product_Local_Name__c);
                                msgSubsituteForOrderItem = (msgSubsituteForOrderItem != '' ? ', ' : '') + msg;
                            }
                        }

                        if (msgSubsituteForOrderItem != '') {
                            OrderItem ordLine = new OrderItem(Id = item.Id, LU_Stock_Message__c = msgSubsituteForOrderItem);
                            lOrderItemsToUpdate.add(ordLine);
                        }
                    }
                }
            }
        }

        insert orderStockStatus.lStockUsedToInsertForOrder;
    
        if (!lOrderItemsToUpdate.isEmpty()) {
            update lOrderItemsToUpdate;
        }
    }

    /* Check if products and pricebookentries are actives and if pricebook dates are good for now */ 
    private static ValidationResult checkProductsAndPriceBookEntriesValidity(Order ord) {

        ValidationResult res = new ValidationResult(true, '');

        String errorMessage = '';

        for (OrderItem item : ord.OrderItems) {

            Product2 prod = item.Product2;

            if(prod != null && !prod.IsActive) {
                errorMessage = Label.LU_Checkout_Validation_Error_InactiveProduct.replace('{0}', prod.Name);
                res = new ValidationResult(false, errorMessage);
                break;
            }

            PricebookEntry pbe = item.PriceBookEntry;
            if (res.success) {
                if(pbe != null) {
                    if(!pbe.IsActive) {
                        errorMessage = Label.LU_Checkout_Validation_Error_InactivePriceBookEntry.replace('{0}', prod.Name);
                        res = new ValidationResult(false, errorMessage);
                        break;
                    }

                    if(pbe.LU_Start_Date__c > Datetime.now() || pbe.LU_End_Date__c < Datetime.now()) {
                        errorMessage = Label.LU_Checkout_Validation_Error_OutOfDatePriceBookEntry.replace('{0}', prod.Name);
                        res = new ValidationResult(false, errorMessage);
                        break;
                    }
                }
            }
        }
        return res;
    }

    /* Method to match the order lines on the stock status */
    public static List<AP1011_Stock_Utils.StockStatus> matchStockStatusToOrderItem(List<AP1011_Stock_Utils.StockStatus> lStockStatusOfOrder, Order order) {

        if (order.OrderItems != null && !order.OrderItems.isEmpty()) {

            for (AP1011_Stock_Utils.StockStatus st : lStockStatusOfOrder) {

                st.lOrderItemForOrder = new List<OrderItem>();

                // Get the line of OrderItem link to the status.productlocalcode
                for (OrderItem item : order.OrderItems) {

                    // Main product associated to the order line
                    if (item.LU_Child_Product__c == null && item.Product2.LU_Local_Code__c == st.productLocalCode) {
                        st.lOrderItemForOrder.add(item);
                    }
                    // if the line is a children of a main line, add the associated order line
                    else if (item.LU_Child_Product__r.LU_Local_Code__c == st.productLocalCode) {
                        st.lOrderItemForOrder.add(item);
                    }
                }
            }
        }

        return (lStockStatusOfOrder);
    }
}