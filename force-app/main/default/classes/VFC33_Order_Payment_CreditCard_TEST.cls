@isTest
public class VFC33_Order_Payment_CreditCard_TEST {
    
    @TestSetup 
    static void test_setup() {
        // Generate Data
        AP1000_Utils_Test.generateOffers();

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');

        STHEndpoints__c endFr = new STHEndpoints__c();
        endFr.Name = 'FRA';
        endFr.Google_Timeout__c = 10000;
        endFr.Google_Endpoint__c = 'http://google.fr';
        endFr.Google_Crypto_Key__c = 'crypto';
        endFr.Google_Client_Id__c = 'clientID';
        endFr.Google_Channel_Id__c = 'channel';
        endFr.Card_Payment_Shop_Id__c = 'ShopId';
        endFr.Card_Payment_Merchant_Id__c = 'merchantId';
        endFr.Card_Payment_Coef__c = 1.01;
        endFr.Card_Payment_Endpoint__c = 'endpoint';
        endFr.Card_Payment_API_Key__c  = 'apikey';
        endFr.Card_Payment_Max_Amount_Allowed__c = 1500;
        insert endFr;
    }

    @isTest 
    static void test_unit_1_order() {

        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.initComponent();
        
        Test.stopTest();

    }

    @isTest 
    static void test_evaluatDraft_rightAmount() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Id__c = '1111111111';
        // ord.LU_Local_Attribute_10__c = '204.02';
        ord.LU_Payment_Transaction_Status__c = 'Draft';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.initComponent();
        
        Test.stopTest();
	        	
	}

    @isTest 
    static void test_evaluatDraft_transactionRefused() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            // system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Id__c = '44444444444';
        // ord.LU_Local_Attribute_10__c = '204.02';
        ord.LU_Payment_Transaction_Status__c = 'Draft';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.initComponent();
        
        // system.assertEquals('REFUSED',VFC33_Order_Payment_CreditCard.status);
        // system.assertEquals('Transaction refused',VFC33_Order_Payment_CreditCard.message);
        Test.stopTest();
	        	
	}

    @isTest 
    static void test_evaluatDraft_amountLimit() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            // system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Id__c = '55555555555';
        // ord.LU_Local_Attribute_10__c = '204.02';
        ord.LU_Payment_Transaction_Status__c = 'Draft';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.initComponent();
        
        // system.assertEquals('REFUSED',VFC33_Order_Payment_CreditCard.status);
        // system.assertEquals('Amount limit',VFC33_Order_Payment_CreditCard.message);
        Test.stopTest();
	        	
	}

    @isTest 
    static void test_evaluatDraft_authentificationVerificationFailed() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            // system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Id__c = '66666666666';
        // ord.LU_Local_Attribute_10__c = '204.02';
        ord.LU_Payment_Transaction_Status__c = 'Draft';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.initComponent();
        
        // system.assertEquals('REFUSED',VFC33_Order_Payment_CreditCard.status);
        // system.assertEquals('Authentification verification failed',VFC33_Order_Payment_CreditCard.message);
        Test.stopTest();
	        	
	}

	@isTest 
    static void test_evaluatDraft_notRightAmount() {
        
        Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Id__c = '1111111111';
        ord.LU_Local_Attribute_10__c = '5206.02';
        ord.LU_Payment_Transaction_Status__c = 'Draft';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.initComponent();
        
        Test.stopTest();

	}
	
	@isTest 
    static void test_approved() {
        
        Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Status__c = 'Approved';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.initComponent();
        
        Test.stopTest();

	}
	
	@isTest 
    static void test_refused() {
        
        Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Status__c = 'Refused';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.initComponent();
        
        Test.stopTest();

	}
	
	@isTest static void test_error() {
        
        Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Status__c = 'Error';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.initComponent();
        
        Test.stopTest();

    }
    
    @isTest static void test_reset_payment() {
        
        Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Status__c = 'Approved';
        ord.LU_Payment_Transaction_Id__c = '1111111111';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.actionResetPayment();
        
        Test.stopTest();

    }

    @isTest static void test_reset_payment_notDraft() {
        
        Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Status__c = 'Approved';
        ord.LU_Payment_Transaction_Id__c = '1111111111';
        ord.Status = 'Processing';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.actionResetPayment();
        
        Test.stopTest();

    }
    
    @isTest static void test_reset_payment_error() {
        
        Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Status__c = 'Approved';
        ord.LU_Payment_Transaction_Id__c = '1111111111';
        //ord.Status = 'Pending';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.actionResetPayment();
        
        Test.stopTest();

	}
    @isTest static void test_calculateAmount_ITA() {
        
        Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        
        // CREATE AN ORDER
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Account acc = [SELECT Id FROM Account WHERE Id= : con.AccountId];
        acc.Country_Code__c = 'ITA';
        update acc;
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        Id orderId = null;
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
            orderId = (Id)resultAddToBasket;
        }

        Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c, LU_Local_Attribute_10__c FROM Order WHERE Id = :orderId LIMIT 1];
        ord.LU_Payment_Transaction_Status__c = 'Approved';
        ord.LU_Payment_Transaction_Id__c = '1111111111';
        //ord.Status = 'Pending';
        update ord;

        Test.startTest();
    
        PageReference orderRecapPage = Page.VFP33_Order_Payment_CreditCard;
        Test.setCurrentPage( orderRecapPage );
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', orderId);
        
        VFC33_Order_Payment_CreditCard ctrl = new VFC33_Order_Payment_CreditCard();

        VFC33_Order_Payment_CreditCard.calculateAmount();
        
        Test.stopTest();

	}

}