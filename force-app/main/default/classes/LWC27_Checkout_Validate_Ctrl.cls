public without sharing class LWC27_Checkout_Validate_Ctrl {
    
    /* UI METHODS */
    @AuraEnabled
    public static ValidationResult validateOrderOnCheckout(Id orderId) {

        // Variables
        ValidationResult res = new ValidationResult();

        // Get order information
        Order ord = [SELECT Id, Status, BillToContactId, BillToContact.AccountCountryCode__c, LU_Total_Amount_For_Valid_Base__c, 
                        LU_Payment_Transaction_Status__c, LU_TECH_AmountForMinimumOrder__c,
                        (SELECT Id, PricebookEntryId, PricebookEntry.LU_Maximum_Quantity__c, Quantity, Product2.LU_Local_Code__c, Product2.Name,
                        Product2.IsActive, PricebookEntry.LU_Limited_Quantity_End_Date__c, PricebookEntry.LU_Limited_Quantity_Start_Date__c, 
                        PricebookEntry.LU_Limited_Quantity_Period__c, PricebookEntry.LU_Limited_Quantity_Value__c, PricebookEntry.IsActive, 
                        PricebookEntry.LU_Start_Date__c, PricebookEntry.LU_End_Date__c, LU_Child_Product__c
                        FROM OrderItems)
                        FROM Order 
                        WHERE Id =: orderId];
        
        // Check if the order is ok
        res = validateTheOrder(ord, false, false, false);

        if (res.success) {
            res = checkProductsAndPriceBookEntriesValidity(ord);
        }

        return (res);

    }

    @AuraEnabled 
    public static ValidationResult validateOrderOnValidation(Id orderId, Boolean commitToDB) {

        // Variables
        ValidationResult res = new ValidationResult();

        // Get order information
        Order ord = [SELECT Id, BillToContactId, BillToContact.AccountCountryCode__c, BillToContact.AllowedPaymentMode__c, LU_Total_Amount_For_Valid_Base__c, LU_Payment_Transaction_Status__c,
                        LU_Transport_Mode__c, LU_Transport_Fees__c, LU_Transport_Mode_Label__c, ShippingStreet, ShippingPostalCode,
                        ShippingCity, ShippingCountry, LU_Exceptional_To_Adress__c, Status, LU_TECH_AmountForMinimumOrder__c,
                        (SELECT Id, PricebookEntryId, PricebookEntry.LU_Maximum_Quantity__c, Quantity, Product2.LU_Local_Code__c, Product2.Name,
                        PricebookEntry.LU_Limited_Quantity_End_Date__c, PricebookEntry.LU_Limited_Quantity_Start_Date__c, PricebookEntry.LU_Counter_Value__c,
                        PricebookEntry.LU_Limited_Quantity_Period__c, PricebookEntry.LU_Limited_Quantity_Value__c , LU_Child_Product__c, LU_Is_A_Child_Line__c
                        FROM OrderItems)
                        FROM Order 
                        WHERE Id =: orderId];
        Id contactId = ord.BillToContactId;
        // Get User of the contact associated to the order
        List<User> lUser = [SELECT Id, TECH_ExternalId__c FROM User WHERE IsActive = True AND TECH_MergeContactID__c = :contactId];


        // Check if the order is ok
        res = validateTheOrder(ord, true, false, false);
		system.debug('>>> validateTheOrder');
        system.debug(res);
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
            List<OrderItem> lLines = new List<OrderItem>();
            for (OrderItem line : ord.OrderItems) {
                List<String> l_pbeCounterValues = line.PriceBookEntry.LU_Counter_Value__c.split('#');

                OrderItem vLine = new OrderItem(Id = line.Id, LU_TECH_BO_ExtractionStatus__c = 'To be exported');

                if(line.LU_Is_A_Child_Line__c == false){
                    for(Integer i = 1; i <= 30; i++){
                        vLine.put('LU_Counter_' + i + '_new__c', Decimal.valueOf(l_pbeCounterValues.get(i-1)) * line.Quantity); 
                    }
                }

                lLines.add(vLine);
            }
            if (!lLines.isEmpty()) {
                update lLines;
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

    /* BUSINESS METHODS */

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

    public static ValidationResult validateTheOrder(Order ord, Boolean commitToDB, Boolean checkShipping, Boolean checkPayment) {

        // Init variables
        ValidationResult res = new ValidationResult(true, '');

        // Get Contact information
        Contact billTo = AP1003_Utils_Contact.getContactInfo(ord.BillToContactId);

        // CHECK CONTACT RULES
        res = checkRulesOnContact(ord, billTo);

        if (res.success) {

            // CHECK THE ORDER RULES : must be the last check done, because commit of stock used and counters new balances
            res = checkRulesOnOrder(ord, billTo, commitToDB, checkShipping, checkPayment);
        }

        return (res);

    }

    /* Check the rules on the Order : Minimum of order, Limited quantity, delivery mode selected, payment by card done, enough points on the different counters */
    public static ValidationResult checkRulesOnOrder(Order ord, Contact billTo, Boolean commitToDB, Boolean checkShipping, Boolean checkPayment) {

        // Variables
        ValidationResult res = new ValidationResult(true, '');
        Boolean stockOk = true;
        Boolean countersOk = true;
        AP1010_Counters_Utils.ValidationReturn checkCounters = null;
        AP1011_Stock_Utils.OrderStockStatus stockStatusForOrder = null;

        // Status of the order : must be draft
        if (ord.Status != 'Draft') {
            res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_NotDraftOrder);
            res.type = 'status';
        }

        // Minimum of order
        // SGO 18092020 : use LU_TECH_AmountForMinimumOrder__c instead of LU_Total_Amount_For_Valid_Base__c
        // to have the good price to compare with contact minimum order
        if (res.success && billTo.MinOrder__c > ord.LU_TECH_AmountForMinimumOrder__c) {
            res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_MinimumOfOrder);
        }

        if (res.success && checkShipping) {
            // Delivery method choosed
            if (ord.LU_Transport_Mode__c == null || (ord.LU_Transport_Mode__c != null && ord.LU_Transport_Mode__c == '')) {
                res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_DeliveryChoice);
            }
        }

        if (res.success && checkShipping) {
            // Check that we have a delivery address
            if (ord.ShippingStreet == '' || ord.ShippingPostalCode == '' || ord.ShippingCity == '') {
                res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_DeliveryAddress);
            }
        }
        
        if (res.success && checkPayment) {
            // Payment card done if contact paid by credit card
            if (billTo.AllowedPaymentMode__c != null) {
                if (billTo.AllowedPaymentMode__c.contains('CBP') && ord.LU_Payment_Transaction_Status__c != 'Approved') {
                    res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_CreditCardNotApproved);
                }
            }
        }

        if (res.success) {
            // Check that the maximum of order by offer has been respected
            res = checkMaximumQuantityOrderByLine(ord);
        }

        if (res.success) {
            // Check the limited quantity
            res = checkLimitedQuantityByProduct(ord);
        }
        
        if (res.success) {
            // Check the stock are enough
            stockStatusForOrder = AP1011_Stock_Utils.checkStockForOrder(ord.Id);
            if (!stockStatusForOrder.lOutOfStockLines.isEmpty()) {
                // Some products in the order are out of stock
                // Update the order lines accordingly to set the information of out of stock on the matching lines
                AP1011_Stock_Utils.updateOrderWithStockInformation(ord.Id, stockStatusForOrder);

                stockOk = false;

                // Send back the result
                res = new ValidationResult();
                res.success = false;
                res.type = 'stock';
                res.url = 'order-view';

                String messageStock = '';
                res.lOffersWithProblem = new List<String>();
                for (AP1011_Stock_Utils.StockStatus product : stockStatusForOrder.lOutOfStockLines) {
                    String msg = product.productLocalCode + ' : ' + product.stockOutOfStockMessage + (product.childOutOfStockMessage != null ? product.childOutOfStockMessage : '');
                    msg += ' ' + Label.LU_Stock_Checkout_Error_Nb_Left + ' ' + product.stockAvailable;
                    messageStock += (messageStock != '' ? ', ' : '') + 
                                    product.stockOutOfStockMessage + (product.childOutOfStockMessage != null ? product.childOutOfStockMessage : '') + ' ; ';

                    res.lOffersWithProblem.add(msg);
                }
                
                res.message = messageStock;
            }
        }

        if (res.success) {
            //Check the counters credits / debits 
            checkCounters = AP1010_Counters_Utils.validateUpdateCounters(ord.Id);
            if (checkCounters.msg != 'OK'){
                countersOk = false;
                res = new ValidationResult();
                res.success = false;
                res.message = checkCounters.msg;
                return res;
            }
        }

        if (commitToDB && countersOk && stockOk) {
            // Decrement the stock for the order (create the LU_Stock_Used__c)
            if (stockStatusForOrder != null) {
                AP1011_Stock_Utils.decreaseTheStockForOrder(ord.Id, stockStatusForOrder);
            }
            
            // Update the contact with the new counters balances
            if (checkCounters != null) {
                update checkCounters.con;
            	update checkCounters.lItems;
            }
            
        }

        return (res);

    }

    /* Check the rules on the Contact : Activity status, Bad dept */
    public static ValidationResult checkRulesOnContact(Order ord, Contact billTo) {

        ValidationResult res = new ValidationResult(true, '');

        // Activity Status
        if (billTo.ActivityStatus__c == false) {
            res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_ActivityStatus);
        }

        if (res.success) {

            // Bad debt
            if (billTo.BadDebt__c == true) {
                res = new ValidationResult(false, Label.LU_Checkout_Validation_Error_BadDept);
            }
        
        }
        
        return (res);

    }

/* BUSINESS METHODS */

    /* Check the limited quantity product */
    public static ValidationResult checkLimitedQuantityByProduct(Order ord) {

        ValidationResult res = new ValidationResult(true, '');

        // Get the product with limited quantity on the order
        List<OrderItem> lLimitedQuantityLines = new List<OrderItem>();
        Map<Id, Double> mOffersLimitedOrdered = new Map<Id, Double>();
        Map<Id, Double> mLimitedOffersVAlue = new Map<Id, Double>();
        Datetime shorterStartPeriod = null;
        Datetime higherEndPeriod = null;

        for (OrderItem line : ord.OrderItems) {
            if (line.LU_Child_Product__c == null &&
                line.PricebookEntry.LU_Limited_Quantity_Period__c &&
                line.PricebookEntry.LU_Limited_Quantity_Start_Date__c <= Datetime.now() && 
                line.PricebookEntry.LU_Limited_Quantity_End_Date__c >= Datetime.now()) {

                lLimitedQuantityLines.add(line);

                // If offers already in order : add the quantity
                if (mOffersLimitedOrdered.containsKey(line.PricebookEntryId)) {
                    mOffersLimitedOrdered.put(line.PricebookEntryId, (mOffersLimitedOrdered.get(line.PricebookEntryId) + line.Quantity));
                } else {
                    mOffersLimitedOrdered.put(line.PricebookEntryId, line.Quantity);
                }
                
                // Get the quantity allowed to be ordered of the limited offer
                mLimitedOffersVAlue.put(line.PricebookEntryId, line.PricebookEntry.LU_Limited_Quantity_Value__c);


                // Get the shorter start period datetime
                if (shorterStartPeriod == null || 
                    (shorterStartPeriod != null && shorterStartPeriod > line.PricebookEntry.LU_Limited_Quantity_Start_Date__c)) {
                    shorterStartPeriod = line.PricebookEntry.LU_Limited_Quantity_Start_Date__c;
                }

                // Get the higher end period datetime
                if (higherEndPeriod == null || 
                    (higherEndPeriod != null && higherEndPeriod < line.PricebookEntry.LU_Limited_Quantity_End_Date__c)) {
                    higherEndPeriod = line.PricebookEntry.LU_Limited_Quantity_End_Date__c;
                }
            }
        }

        // If offers ordered are in a limited quantity period
        if (!mOffersLimitedOrdered.isEmpty() && shorterStartPeriod  != null && higherEndPeriod != null) {
			system.debug('>>> LIMITED PricebookEntry : ' + mOffersLimitedOrdered.keyset());
            system.debug('>>> LIMITED shorterStartPeriod : ' + shorterStartPeriod);
            system.debug('>>> LIMITED higherEndPeriod : ' + higherEndPeriod);
            // Retrieve the lines already ordered for those offers
            List<OrderItem> lLinesAlreadyOrdered = [SELECT Id, PricebookEntryId, Quantity, CreatedDate,
                                                    PricebookEntry.LU_Limited_Quantity_Start_Date__c,
                                                    PricebookEntry.LU_Limited_Quantity_End_Date__c
                                                    FROM OrderItem
                                                    WHERE Order.BillToContactId =: ord.BillToContactId
                                                    AND LU_Child_Product__c = null 
                                                    AND PricebookEntryId in: mOffersLimitedOrdered.keyset()
                                                    AND CreatedDate >=: shorterStartPeriod
                                                    AND CreatedDate <=: higherEndPeriod
                                                    AND Order.Status != 'Draft'
                                                    ];

            // If lines already ordered for offers with limited quantity
            if (!lLinesAlreadyOrdered.isEmpty()) {

                for (OrderItem line : lLinesAlreadyOrdered) {

                    // Check if the creation date of the line is during the limited period
                    if (line.CreatedDate >= line.PricebookEntry.LU_Limited_Quantity_Start_Date__c &&
                        line.CreatedDate <= line.PricebookEntry.LU_Limited_Quantity_End_Date__c) {
                        
                        // Add the quantity previously ordered to the sum of quantity ordered
                        if (mOffersLimitedOrdered.containsKey(line.PricebookEntryId)) {
                            mOffersLimitedOrdered.put(line.PricebookEntryId, (mOffersLimitedOrdered.get(line.PricebookEntryId) + line.Quantity));
                        }
                    }
                }
            }

            // Check if all the quantity limited by period are respected
            String message = '';
            for (OrderItem line : lLimitedQuantityLines) {

                // Get the quantity allowed for this offer
                Double quantityAllowed = mLimitedOffersVAlue.get(line.PricebookEntryId);
                // Get the quantity ordered for this offer during the limited period
                Double quantityOrdered = mOffersLimitedOrdered.get(line.PricebookEntryId);

                // If the quantity ordered is higher than the quantity allowed
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
                res = new ValidationResult(false, message);
            }

        }

        return (res);
    }


    /* Check the order lines : maximum of order */
    public static ValidationResult checkMaximumQuantityOrderByLine(Order ord) {

        ValidationResult res = new ValidationResult(true, '');

        // Retrieve the quantity grouped by product
        AggregateResult[] quantityByProduct = [SELECT sum(Quantity)qty, PricebookEntryId
                                                FROM OrderItem
                                                WHERE OrderId =: ord.Id
                                                AND LU_Child_Product__c = null
                                                GROUP BY PricebookEntryId];

        Boolean atLeastOneKO = false;
        String errorMessage = '';
        for (AggregateResult ar : quantityByProduct)  {

            OrderItem line = null;
            for (OrderItem item : ord.OrderItems) {
                if (item.PricebookEntryId == ar.get('PricebookEntryId')) {
                    line = item; break;
                }
            }

            if (line != null) {
                
                Decimal qty = (ar.get('qty') != null ? decimal.valueof(String.valueOf(ar.get('qty'))) : 0);

                if (qty > line.PricebookEntry.LU_Maximum_Quantity__c) {

                    if (atLeastOneKO == false) {
                        res = new ValidationResult(false, '');
                        atLeastOneKO = true;
                    }
                    
                    String errmsg = Label.LU_Checkout_Validation_Error_MaximumQuantity;
                    errmsg = errmsg.replace('$MAXQUANTITY', String.valueOf(line.PricebookEntry.LU_Maximum_Quantity__c));
                    errmsg = errmsg.replace('$OFFERREF', line.Product2.LU_Local_Code__c + ' - ' + line.Product2.Name);
                    errorMessage += (errorMessage != '' ? ', ' + errmsg : errmsg);
                    res.message = errorMessage;

                }

            }

        }


        return (res);

    }

    /* Check if products and pricebookentries are actives and if pricebook dates are good for now */ 
    private static ValidationResult checkProductsAndPriceBookEntriesValidity(Order vOrd) {
        ValidationResult res = new ValidationResult(true, '');
        
        String vErrorMessage = '';

        for (OrderItem pOrderItem : vOrd.OrderItems) {
            Product2 vProd = pOrderItem.Product2;
            if(vProd != null && !vProd.IsActive) {
                vErrorMessage = Label.LU_Checkout_Validation_Error_InactiveProduct.replace('{0}', vProd.Name);
                res = new ValidationResult(false, vErrorMessage);
                break;
            }

            PricebookEntry vPBE = pOrderItem.PriceBookEntry;
            if (res.success) {
                if(vPBE != null) {
                    if(!vPBE.IsActive) {
                        vErrorMessage = Label.LU_Checkout_Validation_Error_InactivePriceBookEntry.replace('{0}', vProd.Name);
                        res = new ValidationResult(false, vErrorMessage);
                        break;
                    }

                    if(vPBE.LU_Start_Date__c > Datetime.now() || vPBE.LU_End_Date__c < Datetime.now()) {
                        vErrorMessage = Label.LU_Checkout_Validation_Error_OutOfDatePriceBookEntry.replace('{0}', vProd.Name);
                        res = new ValidationResult(false, vErrorMessage);
                        break;
                    }
                }
            }
        }

        return res;
    }

}