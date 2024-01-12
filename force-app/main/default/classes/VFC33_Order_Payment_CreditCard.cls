public class VFC33_Order_Payment_CreditCard {
   
    /* ATTRIBUTES */
    // UI
    public static Boolean isInit {get;set;}
    public static Boolean isError {get;set;}
    public static String message {get;set;}

    // BUSINESS
    public static Id param_orderId {get;set;}
    public static Order order {get;set;}
    public static Decimal amount {get;set;}
    public static Integer amountPayline {get;set;}
    
    // TECH
    public static STHEndpoints__c serviceConfig {get;set;}
    public static String status {get;set;}
    public static String country {get;set;}
    public static String urlRedirectOrderValidation {get;set;}


    /* UI METHODS */
    public static PageReference initComponent() {
        system.debug('>>> initComponent');
        PageReference pg = null;


        

        try {
            // Init variables
            isInit = false;
            isError = false;
            status = 'NONE';
            message = '';
            urlRedirectOrderValidation = '';

            // Get OrderId in URL parameter
            param_orderId = ApexPages.currentPage().getParameters().get('id');
            system.debug('>>> param_orderId: ' + param_orderId);
            // Get the Order information using the OrderId retrieved in the URL
            order = getOrderById(param_orderId);

            // Get the country of the order
            country = order.BillToContact.AccountCountryCode__c;

            // Set the URL for order validation page
            urlRedirectOrderValidation = Label.LU_Payline_URLCallback + '/s/order-validation?orderId=' + param_orderId; 

            // Get the external service endpoint
            serviceConfig = [SELECT Id, Card_Payment_Endpoint__c, Card_Payment_Merchant_Id__c, Card_Payment_API_Key__c, Card_Payment_Shop_Id__c, Card_Payment_Coef__c,
                            Card_Payment_Max_Amount_Allowed__c 
                            FROM STHEndpoints__c
                            WHERE Name = :country ];
            
            // Calculate the amount to pay
            calculateAmount();

            // Check if the amount is ok for card payment
            if (amount > serviceConfig.Card_Payment_Max_Amount_Allowed__c) {
                status = 'AMOUNTNOTALLOWED';
                message = Label.ORD00312 + ' ' + serviceConfig.Card_Payment_Max_Amount_Allowed__c + ' €';
                isInit = true;
            } else {
                // If the status = None (first time on the checkout page)
                if (order.LU_Payment_Transaction_Status__c == 'None') {
                    // Do the webservice callout to create the payment
                    isInit = initPayment();
                } else {
                    // If the amount changed, then reset the transaction and create a new one
                    if (order.LU_Local_Attribute_10__c != null && amount != Decimal.valueOf(order.LU_Local_Attribute_10__c)) {
                        AP36_Payline_Handler.Result res = AP36_Payline_Handler.ws_doReset(order.Id, false);
                        if (res.isSuccess == false) {
                            AP37_ErrorLog_Utils.add_errorLog(order.Id, AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
                                                'Reset Transaction because amount changed : ' + order.LU_Payment_Transaction_Token__c , res.code = ' : ' + res.message);
                        } else {isInit = initPayment();}// Init the payment to represent the new amount
                    } else if(order.LU_Payment_Transaction_Draft_Creation__c != null && order.LU_Payment_Transaction_Draft_Creation__c < Datetime.now().addMinutes(-20)){
                        AP36_Payline_Handler.Result res = AP36_Payline_Handler.ws_doReset(order.Id, false);
                        if (res.isSuccess == false) {
                            AP37_ErrorLog_Utils.add_errorLog(order.Id, AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
                                                'Reset Transaction because too long draft creation : ' + order.LU_Payment_Transaction_Token__c , res.code = ' : ' + res.message);
                        } else {isInit = initPayment();} // Init the payment to represent the new amount
                    }
                    
                    else{
                        // Check status
                        checkStatus();
                        isInit = true;
                    }
                }
                
            }

        } catch (Exception e) {
            system.debug('>>> exception : ' + e.getMessage());
        }

        return (pg);
    }


    /* BUSINESS METHODS */
    
    // Get the order information
    public static Order getOrderById(Id orderId) {
        System.debug('>>> getOrderById : ' + orderId);
        return ([SELECT Id, Status, Tech_External_Id__c, BillToContactId, BillToContact.AccountCountryCode__c, TotalAmount, LU_Commission_Total_Amount__c, 
                    LU_Total_Price_Without_Taxes__c,
                    LU_Admin_Fees_Total_Amount__c, LU_Transport_Fees__c, LU_Payment_Transaction_Draft_Creation__c, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Status__c, LU_Payment_Transaction_Message__c,
                    LU_Payment_Transaction_Details_Date__c, LU_Payment_Transaction_Token__c, LU_Local_Attribute_10__c, LU_Tax_Amount__c, LU_Total_Amount_To_Pay__c
                    FROM Order
                    WHERE Id =: orderId]
                );
    }

    // Calculate the Amount of the payment
    public static void calculateAmount() {
        // Calculate the amount to send to Payline service
        // Arrondi (Montant HT - Commission  + TVA + Retenue + Frais de transport) * Coef) 
        Decimal total = 0;
        
        if (country == 'FRA') {
            total = order.LU_Total_Price_Without_Taxes__c + (order.LU_Commission_Total_Amount__c * -1) + 
                        order.LU_Tax_Amount__c + order.LU_Admin_Fees_Total_Amount__c + order.LU_Transport_Fees__c;
            total = total * serviceConfig.Card_Payment_Coef__c;
            total = total.setScale(2, System.RoundingMode.HALF_UP);
        } else if (country == 'ITA') {
            total = order.LU_Total_Amount_To_Pay__c + order.LU_Transport_Fees__c;
            total = total * serviceConfig.Card_Payment_Coef__c;
            total = total.setScale(2, System.RoundingMode.HALF_UP);
        }

        // Amount payline : 100 = 1€
        amountPayline = Integer.valueOf(total * 100);
        amount = total;

    }
    
    // Init the payment in Payline
    public static Boolean initPayment() {        
        AP36_Payline_Handler.Result ret = AP36_Payline_Handler.ws_doWebPayment(order.Id, amountPayline, order.BillToContact.AccountCountryCode__c);
        if (ret.isSuccess) {
            order = getOrderById(param_orderId);
            isInit = true;
            status = 'DRAFT';

        } else {
            isError = true;
            isInit = false;
            message = (ret.code == 'EXCEPTION' ? Label.ORD00307 : ret.message );
        }

        return (ret.isSuccess);

    }

    // Check the status of the order
    public static void checkStatus() {
        if (order.LU_Payment_Transaction_Status__c == 'Draft') {
            // Calculate the amount of the transaction
            calculateAmount();

            // Do the callout to get payment status
            AP36_Payline_Handler.Result res = AP36_Payline_Handler.ws_getPaymentDetails(param_orderId);
            
            System.debug('#####################################################');
            System.debug(res);

            // Parse the result
            if (res.isSuccess == true) {
                if (res.code == '00000') {
                    status = 'APPROVED'; message = res.message;

                    // If status is approved, then validate automatically the order and go to confirmation page
                    LWC27_Checkout_Validate_Ctrl.ValidationResult resValidation = LWC27_Checkout_Validate_Ctrl.validateOrderOnValidation(param_orderId, true);
                    // If success, redirect to validation page
                    if (resValidation.success == false) {
                        status = 'ERROR';
                        message = resValidation.message;
                    }
                } else if (res.code == AP36_Payline_Handler.PAYMENTDETAILS_MISSINGCARD ) {
                    isInit = true; status = 'DRAFT';
                } else if (res.code == '1100') {
                    status = 'REFUSED';
                    message = Label.ORD01100;
                } else if (res.code == '1116') {
                    status = 'REFUSED';
                    message = Label.ORD01116;
                } else if (res.code == '3022') {
                    status = 'REFUSED';
                    message = Label.ORD03022;
                } else { status = 'REFUSED'; message = res.message;}
            } else { 
                if (res.code == AP36_Payline_Handler.PAYMENTDETAILS_NOTREDIRECTED) { isInit = true; status = 'DRAFT';}
                else {
                    status = 'ERROR';
                    message = (res.code == 'EXCEPTION' ? Label.ORD00307 : res.message);
                }

            }
            
        } else if (order.LU_Payment_Transaction_Status__c == 'Approved') {
            status = 'APPROVED';
            message = order.LU_Payment_Transaction_Message__c;

            // If status is approved, then validate automatically the order and go to confirmation page
            LWC27_Checkout_Validate_Ctrl.ValidationResult resValidation = LWC27_Checkout_Validate_Ctrl.validateOrderOnValidation(param_orderId, true);
            // If success, redirect to validation page
            if (resValidation.success == false) {
                status = 'ERROR';
                message = resValidation.message;
            }

        } else if (order.LU_Payment_Transaction_Status__c == 'Refused') {
            status = 'REFUSED';
            message = order.LU_Payment_Transaction_Message__c;

        } else if (order.LU_Payment_Transaction_Status__c == 'Error') {
            status = 'ERROR';
            message = Label.ORD00307;
        }

        // Update the order
        order = getOrderById(param_orderId);
    }


    public static PageReference actionResetPayment() {
        try {
            if (param_orderId == null) {
                // Get OrderId in URL parameter
                param_orderId = ApexPages.currentPage().getParameters().get('id');
            } 
            system.debug(param_orderId);
            // Retreive the order up-to-date
            order = getOrderById(param_orderId);

            if (order.Status != 'Draft') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ORD00173));
                return null;
            }
            
            // If the transaction has a token, reset it            
            if (order.LU_Payment_Transaction_Id__c != null && order.LU_Payment_Transaction_Id__c != '') {
                AP36_Payline_Handler.Result res = AP36_Payline_Handler.ws_doReset(order.id, false);

                if (res.isSuccess == false) { AP37_ErrorLog_Utils.add_errorLog(order.id, AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 'Reset Transaction on click reset button: ' + order.LU_Payment_Transaction_Id__c , res.code = ' : ' + res.message);} 
                else {
                    initComponent();
                }
            }

        } catch (Exception e) { AP37_ErrorLog_Utils.add_errorLog(order.id, AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 'Reset Transaction on click reset button: ' + order.LU_Payment_Transaction_Id__c , e.getMessage());}
                
        return (null);
    }

}