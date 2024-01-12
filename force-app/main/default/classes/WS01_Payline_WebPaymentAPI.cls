public class WS01_Payline_WebPaymentAPI {
 

/**** DoWebPayment Callout ****/

    public class doWebPaymentRequest_element {
        public String version;
        public WS02_Payline_Object.payment payment;
        public String returnURL;
        public String cancelURL;
        public WS02_Payline_Object.order order;
        public String notificationURL;
        public WS02_Payline_Object.selectedContractList selectedContractList;
        public WS02_Payline_Object.selectedContractList secondSelectedContractList;
        public WS02_Payline_Object.privateDataList privateDataList;
        public String languageCode;
        public String customPaymentPageCode;
        public WS02_Payline_Object.buyer buyer;
        public WS02_Payline_Object.owner owner;
        public String securityMode;
        public WS02_Payline_Object.recurring recurring;
        public String customPaymentTemplateURL;
        public WS02_Payline_Object.contractNumberWalletList contractNumberWalletList;
        public String merchantName;
        public WS02_Payline_Object.subMerchant subMerchant;
        public String miscData;
        private String[] version_type_info = new String[]{'version','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] payment_type_info = new String[]{'payment','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] returnURL_type_info = new String[]{'returnURL','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] cancelURL_type_info = new String[]{'cancelURL','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] order_type_info = new String[]{'order','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] notificationURL_type_info = new String[]{'notificationURL','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] selectedContractList_type_info = new String[]{'selectedContractList','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] secondSelectedContractList_type_info = new String[]{'secondSelectedContractList','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] privateDataList_type_info = new String[]{'privateDataList','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] languageCode_type_info = new String[]{'languageCode','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] customPaymentPageCode_type_info = new String[]{'customPaymentPageCode','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] buyer_type_info = new String[]{'buyer','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] owner_type_info = new String[]{'owner','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] securityMode_type_info = new String[]{'securityMode','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] recurring_type_info = new String[]{'recurring','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] customPaymentTemplateURL_type_info = new String[]{'customPaymentTemplateURL','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] contractNumberWalletList_type_info = new String[]{'contractNumberWalletList','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] merchantName_type_info = new String[]{'merchantName','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] subMerchant_type_info = new String[]{'subMerchant','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] miscData_type_info = new String[]{'miscData','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://impl.ws.payline.experian.com','true','false'};
        private String[] field_order_type_info = new String[]{'version','payment','returnURL','cancelURL','order','notificationURL','selectedContractList','secondSelectedContractList','privateDataList','languageCode','customPaymentPageCode','buyer','owner','securityMode','recurring','customPaymentTemplateURL','contractNumberWalletList','merchantName','subMerchant','miscData'};
    }

    public class doWebPaymentResponse_element {
        public WS02_Payline_Object.result result;
        public String token;
        public String redirectURL;
        public String stepCode;
        public String reqCode;
        public String method;
        private String[] result_type_info = new String[]{'result','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] token_type_info = new String[]{'token','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] redirectURL_type_info = new String[]{'redirectURL','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] stepCode_type_info = new String[]{'stepCode','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] reqCode_type_info = new String[]{'reqCode','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] method_type_info = new String[]{'method','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://impl.ws.payline.experian.com','true','false'};
        private String[] field_order_type_info = new String[]{'result','token','redirectURL','stepCode','reqCode','method'};
    }

/**** / DoWebPayment Callout ****/


/**** GetWebPaymentDetails Callout ****/


    public class getWebPaymentDetailsRequest_element {
        public String version;
        public String token;
        private String[] version_type_info = new String[]{'version','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] token_type_info = new String[]{'token','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://impl.ws.payline.experian.com','true','false'};
        private String[] field_order_type_info = new String[]{'version','token'};
    }



    public class getWebPaymentDetailsResponse_element {
        public WS02_Payline_Object.result result;
        public WS02_Payline_Object.transaction_x transaction_x;
        public WS02_Payline_Object.payment payment;
        public WS02_Payline_Object.authorization authorization;
        public WS02_Payline_Object.privateDataList privateDataList;
        public String paymentRecordId;
        public WS02_Payline_Object.billingRecordList billingRecordList;
        public WS02_Payline_Object.authentication3DSecure authentication3DSecure;
        public WS02_Payline_Object.cardOut card;
        public WS02_Payline_Object.extendedCardType extendedCard;
        public WS02_Payline_Object.order order;
        public WS02_Payline_Object.paymentAdditionalList paymentAdditionalList;
        public String media;
        public String numberOfAttempt;
        public WS02_Payline_Object.wallet wallet;
        public WS02_Payline_Object.contractNumberWalletList contractNumberWalletList;
        public String contractNumber;
        public WS02_Payline_Object.bankAccountData bankAccountData;
        public WS02_Payline_Object.subMerchant subMerchant;
        public WS02_Payline_Object.buyer buyer;
        private String[] result_type_info = new String[]{'result','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] transaction_x_type_info = new String[]{'transaction','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] payment_type_info = new String[]{'payment','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] authorization_type_info = new String[]{'authorization','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] privateDataList_type_info = new String[]{'privateDataList','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] paymentRecordId_type_info = new String[]{'paymentRecordId','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] billingRecordList_type_info = new String[]{'billingRecordList','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] authentication3DSecure_type_info = new String[]{'authentication3DSecure','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] card_type_info = new String[]{'card','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] extendedCard_type_info = new String[]{'extendedCard','http://impl.ws.payline.experian.com',null,'0','1','false'};
        private String[] order_type_info = new String[]{'order','http://impl.ws.payline.experian.com',null,'1','1','false'};
        private String[] paymentAdditionalList_type_info = new String[]{'paymentAdditionalList','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] media_type_info = new String[]{'media','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] numberOfAttempt_type_info = new String[]{'numberOfAttempt','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] wallet_type_info = new String[]{'wallet','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] contractNumberWalletList_type_info = new String[]{'contractNumberWalletList','http://impl.ws.payline.experian.com',null,'0','1','true'};
        private String[] contractNumber_type_info = new String[]{'contractNumber','http://impl.ws.payline.experian.com',null,'0','1','false'};
        private String[] bankAccountData_type_info = new String[]{'bankAccountData','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] subMerchant_type_info = new String[]{'subMerchant','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] buyer_type_info = new String[]{'buyer','http://impl.ws.payline.experian.com',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://impl.ws.payline.experian.com','true','false'};
        private String[] field_order_type_info = new String[]{'result','transaction_x','payment','authorization','privateDataList','paymentRecordId','billingRecordList','authentication3DSecure','card','extendedCard','order','paymentAdditionalList','media','numberOfAttempt','wallet','contractNumberWalletList','contractNumber','bankAccountData','subMerchant','buyer'};
    }


/**** GetWebPaymentDetails Callout ****/



    
/**** API methods ****/

    public class WebPaymentAPI {
        public String endpoint_x = 'WebPaymentAPI';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://impl.ws.payline.experian.com', 'WS01_Payline_WebPaymentAPI', 'http://obj.ws.payline.experian.com', 'objWsPaylineExperianCom'};
       
        public WS01_Payline_WebPaymentAPI.doWebPaymentResponse_element doWebPayment(String version,WS02_Payline_Object.payment payment,String returnURL,String cancelURL,WS02_Payline_Object.order order,String notificationURL,WS02_Payline_Object.selectedContractList selectedContractList,WS02_Payline_Object.selectedContractList secondSelectedContractList,WS02_Payline_Object.privateDataList privateDataList,String languageCode,String customPaymentPageCode,WS02_Payline_Object.buyer buyer,WS02_Payline_Object.owner owner,String securityMode,WS02_Payline_Object.recurring recurring,String customPaymentTemplateURL,WS02_Payline_Object.contractNumberWalletList contractNumberWalletList,String merchantName,WS02_Payline_Object.subMerchant subMerchant,String miscData) {
            
            String endpointCountry = (returnURL != null && (returnURL.contains('fra') || returnURL.contains('france')) ? 'FRA' : 'ITA');
            system.debug('>>>> endpointCountry: ' + endpointCountry);
            STHEndpoints__c serviceConfig = [SELECT Id, Card_Payment_Endpoint__c, Card_Payment_Merchant_Id__c, Card_Payment_API_Key__c, Card_Payment_Shop_Id__c  
                                                FROM STHEndpoints__c
                                                WHERE Name = :endpointCountry ];

            endpoint_x = serviceConfig.Card_Payment_Endpoint__c + endpoint_x ;
            String key = EncodingUtil.base64Encode(Blob.valueof(serviceConfig.Card_Payment_Shop_Id__c + ':' + serviceConfig.Card_Payment_API_Key__c));

            inputHttpHeaders_x = new Map<String, String>();
            inputHttpHeaders_x.put('Authorization', 'Basic ' + key); //MTU1MzI0MDc1OTA0MDA6UjhlajczN0ZBb3ZJMWFvVzJoTnA=

            WS01_Payline_WebPaymentAPI.doWebPaymentRequest_element request_x = new WS01_Payline_WebPaymentAPI.doWebPaymentRequest_element();
            request_x.version = version;
            request_x.payment = payment;
            request_x.returnURL = returnURL;
            request_x.cancelURL = cancelURL;
            request_x.order = order;
            request_x.notificationURL = notificationURL;
            request_x.selectedContractList = selectedContractList;
            request_x.secondSelectedContractList = secondSelectedContractList;
            request_x.privateDataList = privateDataList;
            request_x.languageCode = languageCode;
            request_x.customPaymentPageCode = customPaymentPageCode;
            request_x.buyer = buyer;
            request_x.owner = owner;
            request_x.securityMode = securityMode;
            request_x.recurring = recurring;
            request_x.customPaymentTemplateURL = customPaymentTemplateURL;
            request_x.contractNumberWalletList = contractNumberWalletList;
            request_x.merchantName = merchantName;
            request_x.subMerchant = subMerchant;
            request_x.miscData = miscData;

            WS01_Payline_WebPaymentAPI.doWebPaymentResponse_element response_x;
            Map<String, WS01_Payline_WebPaymentAPI.doWebPaymentResponse_element> response_map_x = new Map<String, WS01_Payline_WebPaymentAPI.doWebPaymentResponse_element>();
            
            response_map_x.put('response_x', response_x);
            
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'doWebPayment',
              'http://impl.ws.payline.experian.com',
              'doWebPaymentRequest',
              'http://impl.ws.payline.experian.com',
              'doWebPaymentResponse',
              'WS01_Payline_WebPaymentAPI.doWebPaymentResponse_element'}
            );
            
            response_x = response_map_x.get('response_x');
            
            return response_x;
        }

        
        public WS01_Payline_WebPaymentAPI.getWebPaymentDetailsResponse_element getWebPaymentDetails(String version,String token) {
            
            List<ORD_Order__c> ord = [SELECT Id, Country_Code__c FROM ORD_Order__c WHERE PaymentTransactionId__c = :token LIMIT 2000 ];
            List<Order> lOrders = [SELECT Id, LU_Country_Code__c FROM Order WHERE LU_Payment_Transaction_Id__c = :token LIMIT 2000];

            String endpointCountry = (ord != null && !ord.isEmpty() ? ord[0].Country_Code__c : 
                                        (lOrders != null && !lOrders.isEmpty()) ?  lOrders[0].LU_Country_Code__c :  'FRA');
            STHEndpoints__c serviceConfig = [SELECT Id, Card_Payment_Endpoint__c, Card_Payment_Merchant_Id__c, Card_Payment_API_Key__c, Card_Payment_Shop_Id__c  
                                            FROM STHEndpoints__c
                                            WHERE Name = :endpointCountry ];

            endpoint_x = serviceConfig.Card_Payment_Endpoint__c + endpoint_x ;
            String key = EncodingUtil.base64Encode(Blob.valueof(serviceConfig.Card_Payment_Shop_Id__c + ':' + serviceConfig.Card_Payment_API_Key__c));

            inputHttpHeaders_x = new Map<String, String>();
            inputHttpHeaders_x.put('Authorization', 'Basic ' + key); //MTU1MzI0MDc1OTA0MDA6UjhlajczN0ZBb3ZJMWFvVzJoTnA=

            WS01_Payline_WebPaymentAPI.getWebPaymentDetailsRequest_element request_x = new WS01_Payline_WebPaymentAPI.getWebPaymentDetailsRequest_element();
            request_x.version = version;
            request_x.token = token;
            
            WS01_Payline_WebPaymentAPI.getWebPaymentDetailsResponse_element response_x;
           
            Map<String, WS01_Payline_WebPaymentAPI.getWebPaymentDetailsResponse_element> response_map_x = new Map<String, WS01_Payline_WebPaymentAPI.getWebPaymentDetailsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'getWebPaymentDetails',
              'http://impl.ws.payline.experian.com',
              'getWebPaymentDetailsRequest',
              'http://impl.ws.payline.experian.com',
              'getWebPaymentDetailsResponse',
              'WS01_Payline_WebPaymentAPI.getWebPaymentDetailsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        
    }

/**** / API Methods ****/

}