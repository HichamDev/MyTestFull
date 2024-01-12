public class AP36_Payline_Handler {
    
    public class Result {
        public Boolean isSuccess {get;set;}
        public String code {get;set;}
        public String message {get;set;}
        // public ORD_Order__c ord {get;set;}
        public Sobject ord {get;set;}
        public Error_log__c log {get;set;}
    }

    static final String APIVERSION = '18'; 
    static final String PAYMENT_CURRENCY = '978';
    static final String PAYMENT_ACTION = '100';
    static final String PAYMENT_MODE = 'CPT'; //DIF
    static final String PAYMENT_SECURITYMODE = 'SSL';
    static final String TRANSACTIONID_SEPARATOR = '#'; 
    
    static final String DORESET_SUCCESSCODES = '00000, 02400, 02500, 02501, 02601, 02602, 02517, 02520 ,02616, 03000, 04000';

    public static final String PAYMENTDETAILS_MISSINGCARD = '02306';
    public static final String PAYMENTDETAILS_NOTREDIRECTED = '02533';
    
    static final String PAYMENTDETAILS_SUCCESSCODE = '00000';
    static final String PAYMENTDETAILS_REFUSEDCODE = '01';
    static final String PAYMENTDETAILS_FRAUDCODE = '04002';
    static final String TRANSACTION_REFUSED = '1100';
    static final String AMOUNT_LIMIT = '1116';
    static final String AUTHENTICATION_VERIFICATION_FAILED = '3022';
    
    static final String DOWEBPAYMENT_SUCCESSCODE = '00000';


    public static Result ws_doReset(String orderId, Boolean commitRecord) {
        System.debug('>>> ws_doReset START');
        // Retrieve order information needed
        ORD_Order__c ord = null;
        Order order1 = null;

        System.debug('orderId : ' + orderId);
        // Retrieve order information needed
        if (orderId.left(3) != '801') {
            ord = [SELECT Id, PaymentTransactionId__c, Payment_Transaction_Token__c, PaymentProvider__c, Payment_Transaction_Status__c
                    FROM ORD_Order__c
                    WHERE Id =: orderId];
        } else {
            order1 = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Provider__c, LU_Payment_Transaction_Status__c, LU_Payment_Transaction_Draft_Creation__c
                        FROM Order
                        WHERE Id =: orderId];
        }

        Boolean vDoReset = false;
        
        // SFT-1566 : Workaround Payline reset failed
        if(order1 != null) {
            if(order1.LU_Payment_Transaction_Status__c == 'Approved') {
                vDoReset = true;
            } else {
                order1.LU_Payment_Transaction_Status__c = 'None';
                if(order1.LU_Payment_Transaction_Draft_Creation__c != null && 
                    order1.LU_Payment_Transaction_Draft_Creation__c < Datetime.now().addMinutes(-20)){
                        order1.LU_Payment_Transaction_Id__c = '';
                    }
                update order1;
            }
        }
        
        if(ord != null) {
            if(ord.Payment_Transaction_Status__c == 'Approved') {
                vDoReset = true;
            } else {
                ord.Payment_Transaction_Status__c = 'None';
                update ord;
            }
        }

        Result res = new Result();
        res.isSuccess = false;
        res.ord = null;

        if(vDoReset) {
            // Parse the callout return
            String token = (ord != null ? ord.Payment_Transaction_Token__c : order1.LU_Payment_Transaction_Token__c);
            System.debug('token : ' + token);
            try {
                if (token != null && token != '') {
                    // API Init 
                    WS02_Payline_DIrectPaymentAPI.DirectPaymentAPI api = new WS02_Payline_DIrectPaymentAPI.DirectPaymentAPI();

                    // Preparing parameters
                    String version = APIVERSION;
                    String transactionID = token; //ord.Payment_Transaction_Token__c;
                    String comment = '';
                    String media = '';

                    // Do the callout
                    WS02_Payline_DIrectPaymentAPI.doResetResponse_element ret = api.doReset(version, transactionID, comment, media);
                    
                    // Get the return code + message
                    res.code = ret.result.code;
                    res.message = ret.result.longMessage;

                    if (DORESET_SUCCESSCODES.contains(ret.result.code)) {
                        res.isSuccess = true;
                        if (ord != null) {
                            ord.PaymentTransactionId__c = '';
                            ord.Payment_Transaction_Token__c = '';
                            ord.LocalAttribute10__c = '';
                            ord.PaymentProvider__c = '';
                            ord.Payment_Transaction_Status__c = 'None';
                            ord.Payment_Transaction_Message__c = '';
                            ord.Payment_Transaction_Details_Date__c = null;
                            ord.Payment_Transaction_Reset__c = Datetime.now();
                            ord.Payment_Transaction_Reset_Message__c = ret.result.longMessage;
                            ord.Payment_Transaction_Draft_Creation__c = null;
                            if (commitRecord)
                                update ord;
                            res.ord = ord;
                        } else {
                            order1.LU_Payment_Transaction_Id__c = '';
                            order1.LU_Payment_Transaction_Token__c = '';
                            order1.LU_Local_Attribute_10__c = '';
                            order1.LU_Payment_Provider__c = '';
                            order1.LU_Payment_Transaction_Status__c = 'None';
                            order1.LU_Payment_Transaction_Message__c = '';
                            order1.LU_Payment_Transaction_Details_Date__c = null;
                            order1.LU_Payment_Transaction_Reset_Date__c = Datetime.now();
                            order1.LU_Payment_Transaction_Reset_Message__c = ret.result.longMessage;
                            order1.LU_Payment_Transaction_Draft_Creation__c = null;
                            order1.LU_Payment_Transaction_Draft_Message__c = '';
                            
                            if (commitRecord)
                                update order1;
                            res.ord = order1;
                        }
                    } else {
                        res.isSuccess = false;
                        Error_log__c log = AP37_ErrorLog_Utils.create_errorLog((ord != null ? ord.Id : order1.Id), AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
                                                        'doReset : ' + token, String.valueOf(ret));
                        if (commitRecord)
                            insert log;
                        res.ord = null;
                        res.log = log;
                    }
                } else {
                    res.isSuccess = true;
                    if (ord != null) {
                        ord.PaymentTransactionId__c = '';
                        ord.Payment_Transaction_Token__c = '';
                        ord.LocalAttribute10__c = '';
                        ord.PaymentProvider__c = '';
                        ord.Payment_Transaction_Status__c = 'None';
                        ord.Payment_Transaction_Message__c = '';
                        ord.Payment_Transaction_Details_Date__c = null;
                        ord.Payment_Transaction_Reset__c = Datetime.now();
                        ord.Payment_Transaction_Reset_Message__c = res.message;
                        ord.Payment_Transaction_Draft_Creation__c = null;
                        if (commitRecord)
                            update ord;
                        res.ord = ord;
                    } else {
                        order1.LU_Payment_Transaction_Id__c = '';
                        order1.LU_Payment_Transaction_Token__c = '';
                        order1.LU_Local_Attribute_10__c = '';
                        order1.LU_Payment_Provider__c = '';
                        order1.LU_Payment_Transaction_Status__c = 'None';
                        order1.LU_Payment_Transaction_Message__c = '';
                        order1.LU_Payment_Transaction_Details_Date__c = null;
                        order1.LU_Payment_Transaction_Reset_Date__c = Datetime.now();
                        order1.LU_Payment_Transaction_Reset_Message__c = res.message;
                        order1.LU_Payment_Transaction_Draft_Creation__c = null;
                        order1.LU_Payment_Transaction_Draft_Message__c = '';
                        
                        if (commitRecord)
                            update order1;
                        res.ord = order1;
                    }
                }
            } catch (Exception e) {
                res.isSuccess = false;
                res.code = 'Exception';
                res.message = Label.ORD00307;
                Error_log__c log = AP37_ErrorLog_Utils.create_errorLog((ord != null ? ord.Id : order1.Id), AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
                                                'doReset : ' + token, e.getMessage());
                if (commitRecord)
                    insert log;
                res.ord = null;
                res.log = log;
            }
            System.debug('>>> ws_doReset result: ' + res);
            System.debug('>>> ws_doReset END');
        }
        return (res);
    }

    public static Result ws_getPaymentDetails(String orderId) {
        ORD_Order__c ord = null;
        Order order1 = null;
        // Retrieve order information needed
        if (orderId.left(3) != '801') {
            ord = [SELECT PaymentTransactionId__c, Payment_Transaction_Token__c
                    FROM ORD_Order__c
                    WHERE Id =: orderId];
        } else {
            order1 = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c
                        FROM Order
                        WHERE Id =: orderId];
        }

        // Parse the callout return
        Result res = new Result();
        String transactionId = (ord != null ? ord.PaymentTransactionId__c : order1.LU_Payment_Transaction_Id__c);
        String token = (ord != null ? ord.Payment_Transaction_Token__c : order1.LU_Payment_Transaction_Token__c);

            // API Init
            WS01_Payline_WebPaymentAPI.WebPaymentAPI api = new WS01_Payline_WebPaymentAPI.WebPaymentAPI();

            // Do the callout
            WS01_Payline_WebPaymentAPI.getWebPaymentDetailsResponse_element ret = api.getWebPaymentDetails(APIVERSION, transactionId);
            res.code = ret.result.code;
            res.message = ret.result.longMessage;
            WS02_Payline_Object.transaction_x vTrans = ret.transaction_x;

            if (res.code == PAYMENTDETAILS_MISSINGCARD) {
                res.isSuccess = true;
            } else if (res.code == PAYMENTDETAILS_SUCCESSCODE && vTrans != null && String.isNotBlank(vTrans.Id)) {
                res.isSuccess = true;
                if (ord != null) {
                    ord.Payment_Transaction_Token__c = vTrans.Id;
                    ord.Payment_Transaction_Status__c = 'Approved';
                    ord.Payment_Transaction_Message__c = res.message;
                    ord.Payment_Transaction_Details_Date__c = Datetime.now();
                    update ord;
                } else {
                    order1.LU_Payment_Transaction_Token__c = vTrans.Id;
                    order1.LU_Payment_Transaction_Status__c  = 'Approved';
                    order1.LU_Payment_Transaction_Message__c = res.message;
                    order1.LU_Payment_Transaction_Details_Date__c = Datetime.now();
                    update order1;
                }
                
            } else if (res.code.startsWith(PAYMENTDETAILS_REFUSEDCODE) || res.code == PAYMENTDETAILS_FRAUDCODE || res.code == TRANSACTION_REFUSED 
            || res.code == AMOUNT_LIMIT || res.code == AUTHENTICATION_VERIFICATION_FAILED) {
                res.isSuccess = true;
                if (ord != null) {
                    ord.Payment_Transaction_Token__c = (ret.transaction_x != null ? ret.transaction_x.Id : '');
                    ord.Payment_Transaction_Status__c = 'Refused';
                    ord.Payment_Transaction_Message__c = res.message;
                    ord.Payment_Transaction_Details_Date__c = Datetime.now();
                    update ord;
                } else {
                    order1.LU_Payment_Transaction_Token__c = (ret.transaction_x != null ? ret.transaction_x.Id : '');
                    order1.LU_Payment_Transaction_Status__c  = 'Refused';
                    order1.LU_Payment_Transaction_Message__c = res.message;
                    order1.LU_Payment_Transaction_Details_Date__c = Datetime.now();
                    update order1;
                }
                AP37_ErrorLog_Utils.add_errorLog((ord != null ? ord.Id : order1.Id), AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
                                            'getWebPaymentDetails : ' + token, String.valueOf(res));
            } else {
                res.isSuccess = false;
                if (ord != null) {
                    ord.Payment_Transaction_Token__c = (ret.transaction_x != null ? ret.transaction_x.Id : '');
                    ord.Payment_Transaction_Status__c = 'Error';
                    ord.Payment_Transaction_Message__c = res.message;
                    ord.Payment_Transaction_Details_Date__c = Datetime.now();
                    update ord;
                } else {
                    order1.LU_Payment_Transaction_Token__c = (ret.transaction_x != null ? ret.transaction_x.Id : '');
                    order1.LU_Payment_Transaction_Status__c  = 'Error';
                    order1.LU_Payment_Transaction_Message__c = res.message;
                    order1.LU_Payment_Transaction_Details_Date__c = Datetime.now();
                    update order1;
                }
                
                AP37_ErrorLog_Utils.add_errorLog((ord != null ? ord.Id : order1.Id), AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
                                            'getWebPaymentDetails : ' + token, String.valueOf(res));
            }

        return (res);
    }

    public static Result ws_doWebPayment(String orderId, Integer amount, String countryCode) {        
        ORD_Order__c ord = null;
        Order order1 = null;
        Id contactId = null;

        // Retrieve order information needed
        if (orderId.left(3) != '801') {
            ord = [SELECT Id, TECH_ExternalId__c, Dealer__c, Dealer__r.LastName, Dealer__r.FirstName, Dealer__r.Email, Dealer__r.MobilePhone,
                            Dealer__r.MailingStreet, Dealer__r.MailingCity, Dealer__r.MailingPostalCode, Dealer__r.MailingCountry, Payment_Transaction_Token__c,
                            PaymentTransactionId__c
                            FROM ORD_Order__c
                            WHERE Id =: orderId];
            contactId = ord.Dealer__c;
        } else {
            order1 = [SELECT Id, OrderNumber, BillToContactId, BillToContact.FirstName, BillToContact.LastName, BillToContact.Email, 
                    BillToContact.MailingStreet, BillToContact.MailingPostalCode, BillToContact.MailingCity, BillToContact.MailingCountry,
                    BillToContact.MobilePhone, TotalAmount,  
                    LU_Payment_Provider__c, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Status__c,
                    LU_Payment_Transaction_Token__c, Tech_External_Id__c 
                    FROM Order
                    WHERE Id =: orderId];
            contactId = order1.BillToContactId;
        }
        // Init variables
        Result res = new Result();
        WS02_Payline_Object.payment payment = new WS02_Payline_Object.payment();
        WS02_Payline_Object.order order = new WS02_Payline_Object.order();
        WS02_Payline_Object.buyer buyer = new WS02_Payline_Object.buyer();

        try {
            // Country code
            String urlPortal = '';
            if (countryCode == 'FRA') { urlPortal = '/fr'; }
            if (countryCode == 'ITA') { urlPortal = '/it'; }
            User currentUser = [SELECT Id, UserType FROM User WHERE Id =: UserInfo.getUserId()];
            User associatedUserOfTheContactOfOrder = [SELECT Id, LU_Use_New_Order_v2__c FROM User 
                                                        WHERE TECH_MergeContactID__c = :contactId 
                                                        AND IsActive = true];

            STHEndpoints__c serviceConfig = [SELECT Id, Card_Payment_Endpoint__c, Card_Payment_Merchant_Id__c, Card_Payment_API_Key__c, Card_Payment_Shop_Id__c , Card_payment_Delay_date_payment__c 
                                                FROM STHEndpoints__c
                                                WHERE Name =: countryCode ];

            // API Init
            WS01_Payline_WebPaymentAPI.WebPaymentAPI api = new WS01_Payline_WebPaymentAPI.WebPaymentAPI();

            // Preparing parameters
            String version = APIVERSION;
            payment.amount = String.valueOf(amount);
            payment.currency_x = PAYMENT_CURRENCY;
            payment.action = PAYMENT_ACTION;
            payment.mode = PAYMENT_MODE;
            payment.contractNumber = serviceConfig.Card_Payment_Merchant_Id__c;
            payment.softDescriptor = '';
            
            String urlCallback ='';
            system.debug('>>>> url : ' + URL.getSalesforceBaseUrl().toExternalForm());
            String network = Network.getNetworkId();
            if (network != null && network != '') {
                if (associatedUserOfTheContactOfOrder.LU_Use_New_Order_v2__c == false) {
                    if (countryCode == 'FRA') {
                        urlCallback = Label.LU_Payline_URLCallback + '/apex/vfp01_orderrecap_france?orderId=' + orderId;
                    } else {
                        urlCallback = Label.LU_Payline_URLCallback + '/apex/vfp01_orderrecap_italy?orderId=' + orderId;
                    }
                } else {
                    urlCallback = Label.LU_Payline_URLCallback + '/apex/VFP33_Order_Payment_CreditCard?id=' + orderId;
                }
                
            } else if (countryCode == 'FRA') {
                urlCallback = URL.getSalesforceBaseUrl().toExternalForm() + (currentUser.UserType == 'CSPLitePortal' ? urlPortal : '' ) 
                                + '/apex/vfp01_orderrecap_france?orderId=' + orderId; 
            } else if (countryCode == 'ITA') {
                urlCallback = URL.getSalesforceBaseUrl().toExternalForm() + (currentUser.UserType == 'CSPLitePortal' ? urlPortal : '' ) 
                                + '/apex/vfp01_orderrecap_italy?orderId=' + orderId + '&dealerId=' + ord.Dealer__c;
            }   
            
            String returnURL = urlCallback; /*URL.getSalesforceBaseUrl().toExternalForm() + (currentUser.UserType == 'CSPLitePortal' ? urlPortal : '' ) 
                                + '/apex/vfp01_orderrecap_france?orderId=' + orderId;*/
            String cancelURL = urlCallback; /*URL.getSalesforceBaseUrl().toExternalForm() + (currentUser.UserType == 'CSPLitePortal' ? urlPortal : '' ) 
                                + '/apex/vfp01_orderrecap_france?orderId=' + orderId;*/
            
            Datetime timenow = Datetime.now();
            String txtNow = timenow.format('yyyy-MM-dd\'T\'hh:mm:ss');
            order.ref = (ord != null ? ord.TECH_ExternalId__c : order1.Tech_External_Id__c) + TRANSACTIONID_SEPARATOR + txtNow;
            order.origin = '';
            order.country = '';
            order.taxes = '';
            order.amount = String.valueOf(amount);
            order.currency_x = PAYMENT_CURRENCY;
            Datetime now = Datetime.now();
            order.date_x = (now.day() < 10 ? '0' + now.day() : String.valueOf(now.day())) + '/' + (now.month() < 10 ? '0' + now.month() : String.valueOf(now.month())) + '/' + now.year() + ' ' + 
                            (now.hour() < 10 ? '0' + now.hour() : String.valueOf(now.hour())) + ':' + (now.minute() < 10 ? '0' + now.minute() : String.valueOf(now.minute())); // '22/05/2018 10:00';
            order.details = new WS02_Payline_Object.details();
            order.details.details = new List<WS02_Payline_Object.orderDetail>();
            WS02_Payline_Object.orderDetail detail = new WS02_Payline_Object.orderDetail();
            detail.ref = (ord != null ? ord.TECH_ExternalId__c : order1.OrderNumber) + Datetime.now();
            detail.price = String.valueOf(amount);
            detail.quantity = '1';
            detail.comment = '';
            order.details.details.add(detail);
            
            String notificationURL = urlCallback; /*URL.getSalesforceBaseUrl().toExternalForm() + (currentUser.UserType == 'CSPLitePortal' ? urlPortal : '' ) 
                                    + '/apex/vfp01_orderrecap_france?orderId=' + orderId;*/
            
            WS02_Payline_Object.selectedContractList selectedContractList = new WS02_Payline_Object.selectedContractList();
            selectedContractList.selectedContract = new List<String>();
            String contract = serviceConfig.Card_Payment_Merchant_Id__c;
            selectedContractList.selectedContract.add(contract);
            system.debug('>>> contract number: ' + contract);
            
            WS02_Payline_Object.selectedContractList secondSelectedContractList = null;
            WS02_Payline_Object.privateDataList privateDataList = null;
            String languageCode = '';
            String customPaymentPageCode = '';
            
            buyer.lastName = (ord != null ? ord.Dealer__r.LastName : order1.BillToContact.LastName);
            buyer.firstName = (ord != null ? ord.Dealer__r.FirstName : order1.BillToContact.FirstName);
            buyer.email = (ord != null ? ord.Dealer__r.Email : order1.BillToContact.Email);
            buyer.shippingAdress = new WS02_Payline_Object.address();
            buyer.shippingAdress.name = '';
            buyer.shippingAdress.street1 = (ord != null ? ord.Dealer__r.MailingStreet : order1.BillToContact.MailingStreet);
            buyer.shippingAdress.street2 = '';
            buyer.shippingAdress.cityName = (ord != null ? ord.Dealer__r.MailingCity : order1.BillToContact.MailingCity) ;
            buyer.shippingAdress.zipCode = (ord != null ? ord.Dealer__r.MailingPostalCode : order1.BillToContact.MailingPostalCode) ;
            buyer.shippingAdress.country = (ord != null ? ord.Dealer__r.MailingCountry : order1.BillToContact.MailingCountry) ;
            buyer.shippingAdress.phone = (ord != null ? ord.Dealer__r.MobilePhone : order1.BillToContact.MobilePhone) ;
            buyer.shippingAdress.state = '';

            
            WS02_Payline_Object.owner owner = null;
            String securityMode = PAYMENT_SECURITYMODE;
            WS02_Payline_Object.recurring recurring = null;
            String customPaymentTemplateURL = '';
            WS02_Payline_Object.contractNumberWalletList contractNumberWalletList = null;
            String merchantName = '';
            WS02_Payline_Object.subMerchant subMerchant = null;
            String miscData = '';

            System.debug('>>> BEFORE CALLOUT ');
            System.debug(version);
            System.debug(payment);
            System.debug(returnURL);
            System.debug(cancelURL);
            System.debug(order);
            System.debug(notificationURL);
            System.debug(selectedContractList);
            System.debug(secondSelectedContractList);
            System.debug(privateDataList);
            System.debug(languageCode);
            System.debug(customPaymentPageCode);
            System.debug(buyer);
            System.debug(owner);
            System.debug(securityMode);
            System.debug(recurring);
            System.debug(customPaymentTemplateURL);
            System.debug(contractNumberWalletList);
            System.debug(merchantName);
            System.debug(subMerchant);
            System.debug(miscData);

            // Do the callout
            WS01_Payline_WebPaymentAPI.doWebPaymentResponse_element ret = api.doWebPayment(version, payment, returnURL, cancelURL, order, notificationURL, 
                                                                                            selectedContractList, secondSelectedContractList, privateDataList,
                                                                                            languageCode, customPaymentPageCode, buyer, owner, securityMode,
                                                                                            recurring, customPaymentTemplateURL, contractNumberWalletList,
                                                                                            merchantName, subMerchant, miscData);
            system.debug('>>> Ret : ' + ret);
            // Parse the callout return
            if (ret != null) {
                Decimal amountToSave = Decimal.valueOf(String.valueOf(amount)) / 100;

                // Transaction draft approved
                if (ret.result.code == DOWEBPAYMENT_SUCCESSCODE) {
                    res.isSuccess = true;
                    res.code = ret.result.code;
                    res.message = ret.result.longMessage;

                    if (orderId.left(3) != '801') {
                        ORD_Order__c ordUpdate = new ORD_Order__c(Id = orderId, 
                                            Payment_Transaction_Status__c = 'Draft', 
                                            Payment_Transaction_Token__c = '',
                                            PaymentTransactionId__c = ret.token, 
                                            PaymentProvider__c = 'Payline',
                                            LocalAttribute10__c = String.valueOf(amountToSave),
                                            Payment_Transaction_Draft_Creation__c = Datetime.now(),
                                            Payment_Transaction_Draft_Message__c = ret.result.longMessage);

                        update ordUpdate;
                    } else {
                        Order ordUpdate = new Order(Id = orderId,
                                                    LU_Payment_Transaction_Status__c = 'Draft',
                                                    LU_Payment_Transaction_Token__c = '',
                                                    LU_Payment_Transaction_Id__c = ret.token,
                                                    LU_Payment_Provider__c = 'Payline',
                                                    LU_Local_Attribute_10__c = String.valueOf(amountToSave),
                                                    LU_Payment_Transaction_Draft_Creation__c = Datetime.now(),
                                                    LU_Payment_Transaction_Draft_Message__c = ret.result.longMessage);
                        update ordUpdate;
                    }
                    
                
                } else {
                    system.debug('>>> ERROR DOWEBPAYMENT');
                    system.debug(ret);
                    res.isSuccess = false;
                    res.code = ret.result.code;
                    res.message = ret.result.longMessage;

                    if (orderId.left(3) != '801') {
                        ORD_Order__c ordUpdate = new ORD_Order__c(Id = orderId, 
                                            Payment_Transaction_Status__c = 'Draft', 
                                            Payment_Transaction_Token__c = '',
                                            PaymentTransactionId__c = ret.token, 
                                            PaymentProvider__c = 'Payline',
                                            LocalAttribute10__c = String.valueOf(amountToSave),
                                            Payment_Transaction_Draft_Creation__c = Datetime.now(),
                                            Payment_Transaction_Draft_Message__c = ret.result.longMessage);

                    update ordUpdate;
                    } else {
                        Order ordUpdate = new Order(Id = orderId,
                                                    LU_Payment_Transaction_Status__c = 'Draft',
                                                    LU_Payment_Transaction_Token__c = '',
                                                    LU_Payment_Transaction_Id__c = ret.token,
                                                    LU_Payment_Provider__c = 'Payline',
                                                    LU_Local_Attribute_10__c = String.valueOf(amountToSave),
                                                    LU_Payment_Transaction_Draft_Creation__c = Datetime.now(),
                                                    LU_Payment_Transaction_Draft_Message__c = ret.result.longMessage);
                        update ordUpdate;
                    }




                    AP37_ErrorLog_Utils.add_errorLog((ord != null ? ord.Id : order1.Id), AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
                                            'doWebPayment : ' + (ord != null ? ord.PaymentTransactionId__c : order1.LU_Payment_Transaction_Id__c) + '<br/>' + JSON.serialize(payment) + JSON.serialize(order) + JSON.serialize(buyer), 
                                            ret.result.longMessage);
                }
            }

        } catch (Exception e) {

            system.debug('>> exception : ' + e.getMessage());
            
            res.isSuccess = false;
            res.code = 'Exception';
            res.message = Label.ORD00307;
            AP37_ErrorLog_Utils.add_errorLog((ord != null ? ord.Id : order1.Id), AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
                                            'doWebPayment : ' + (ord != null ? ord.PaymentTransactionId__c : order1.LU_Payment_Transaction_Id__c) + '<br/>' + JSON.serialize(payment) + JSON.serialize(order) + JSON.serialize(buyer), 
                                            e.getMessage());
            if (orderId.left(3) != '801') {
                ord.Payment_Transaction_Status__c = 'Error';
                ord.Payment_Transaction_Message__c = res.message;
                ord.Payment_Transaction_Details_Date__c = Datetime.now();
                update ord;
            } else {
                order1.LU_Payment_Transaction_Status__c = 'Error';
                order1.LU_Payment_Transaction_Message__c = res.message;
                order1.LU_Payment_Transaction_Details_Date__c = datetime.now();
                update order1;
            }

        }

        return (res);
    }



}