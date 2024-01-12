@isTest
private class AP36_Payline_Handler_Test {
	
	@testSetup static void test_setup() {

		/******  OLD ORDER TUNNEL  ******/
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
        insert endFr;
		//creating account
    	account testAccount = new account(	TypeLabel__c= 'test', 
    										Name= 'test Account', 
    										CurrencyIsoCode= 'EUR', 
    										AccountType__c= 'Level 2',
    										Country_Code__c = 'FRA'
    										);
      	insert testAccount;
        //creating contact
        Contact contact = new Contact(  STHID__c='123', 
        								AccountId=testAccount.id, 
        								CurrencyIsoCode = 'EUR', 
                                        lastname='br04Contact',
                                        email= 'br04Contact@sth.com',
                                        Birthdate =date.newinstance(1986, 12, 28),
                                        MinOrderFreeTransportFees__c = 50,
                                        MinOrder__c = 50);
        insert contact;
    	List<ORD_Order__c> orderList = new List<ORD_Order__c>{
	       		new ORD_Order__c(dealer__c = contact.Id
	       						 , Status__c = 'Draft'
	       						 , OrderDate__c = system.TODAY())
       	};
	    insert(orderList);

		/****** LINEUP ORDER TUNNEL */
		// Generate Data
        AP1000_Utils_Test.generateOffers();

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
		AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');
	}


/**
* DoWebPaymentRequest
**/
	@isTest static void test_ws_doWebPaymentRequet_successfr_lu() {
			
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            Test.startTest();

			AP36_Payline_Handler.ws_doWebPayment((Id)resultAddToBasket, 120, 'FRA');

			Test.stopTest();
        }
	}

	@isTest static void test_ws_doWebPaymentRequet_successit_lu() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            Test.startTest();

			AP36_Payline_Handler.ws_doWebPayment((Id)resultAddToBasket, 120, 'ITA');

			Test.stopTest();
        }

	}

	@isTest static void test_ws_doWebPaymentRequet_error_lu() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            Test.startTest();

			AP36_Payline_Handler.ws_doWebPayment((Id)resultAddToBasket, 121, 'FRA');

			Test.stopTest();
        }

	}

	@isTest static void test_ws_doWebPaymentRequet_exception_li() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');

            Test.startTest();

			AP36_Payline_Handler.ws_doWebPayment((Id)resultAddToBasket, 121, 'FRA');

			Test.stopTest();
        }

	}

	@isTest static void test_ws_doWebPaymentRequet_successfr_old() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];

		Test.startTest();

		AP36_Payline_Handler.ws_doWebPayment(order.Id, 120, 'FRA');

		Test.stopTest();

	}

	@isTest static void test_ws_doWebPaymentRequet_successit_old() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];

		Test.startTest();

		AP36_Payline_Handler.ws_doWebPayment(order.Id, 120, 'TIA');

		Test.stopTest();

	}

	@isTest static void test_ws_doWebPaymentRequet_error_old() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];

		Test.startTest();

		AP36_Payline_Handler.ws_doWebPayment(order.Id, 121, 'FRA');

		Test.stopTest();

	}

	@isTest static void test_ws_doWebPaymentRequet_exception_old() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];

		Test.startTest();

		AP36_Payline_Handler.ws_doWebPayment(order.Id, 122, 'FRA');

		Test.stopTest();

	}


/**
* getPaymentDetails
**/
@isTest static void test_ws_getPaymentDetails_success_lu() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
			
			Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c FROM Order WHERE Id = :resultAddToBasket LIMIT 1];
			ord.LU_Payment_Transaction_Id__c = '1111111111';
			ord.LU_Payment_Transaction_Token__c = '';
			ord.LU_Payment_Transaction_Status__c = 'Draft';
			update ord;

            Test.startTest();

				AP36_Payline_Handler.ws_getPaymentDetails(ord.Id);

			Test.stopTest();
		}
	}

	@isTest static void test_ws_getPaymentDetails_refused_lu() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
			
			Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c FROM Order WHERE Id = :resultAddToBasket LIMIT 1];
			ord.LU_Payment_Transaction_Id__c = '2222222222';
			ord.LU_Payment_Transaction_Token__c = '';
			ord.LU_Payment_Transaction_Status__c = 'Draft';
			update ord;

            Test.startTest();

				AP36_Payline_Handler.ws_getPaymentDetails(ord.Id);

			Test.stopTest();
		}

	}

	@isTest static void test_ws_getPaymentDetails_error_lu() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
			
			Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c FROM Order WHERE Id = :resultAddToBasket LIMIT 1];
			ord.LU_Payment_Transaction_Id__c = '33333333333';
			ord.LU_Payment_Transaction_Token__c = '';
			ord.LU_Payment_Transaction_Status__c = 'Draft';
			update ord;

            Test.startTest();

				AP36_Payline_Handler.ws_getPaymentDetails(ord.Id);

			Test.stopTest();
		}

	}

	@isTest static void test_ws_getPaymentDetails_errorException_lu() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
			
			Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c FROM Order WHERE Id = :resultAddToBasket LIMIT 1];
			ord.LU_Payment_Transaction_Id__c = '4444444444';
			ord.LU_Payment_Transaction_Token__c = '';
			ord.LU_Payment_Transaction_Status__c = 'Draft';
			update ord;

            Test.startTest();
				try {
					AP36_Payline_Handler.ws_getPaymentDetails(ord.Id);
				} catch (Exception e) { }
			Test.stopTest();
		}

	}

	@isTest static void test_ws_getPaymentDetails_success_old() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
		order.PaymentTransactionId__c = '1111111111';
		order.Payment_Transaction_Token__c = '';
		order.Payment_Transaction_Status__c = 'Draft';
		update order;

		Test.startTest();

		AP36_Payline_Handler.ws_getPaymentDetails(order.Id);

		Test.stopTest();

	}

	@isTest static void test_ws_getPaymentDetails_refused_old() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
		order.PaymentTransactionId__c = '2222222222';
		order.Payment_Transaction_Token__c = '';
		order.Payment_Transaction_Status__c = 'Draft';
		update order;

		Test.startTest();

		AP36_Payline_Handler.ws_getPaymentDetails(order.Id);

		Test.stopTest();

	}

	@isTest static void test_ws_getPaymentDetails_error_old() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
		order.PaymentTransactionId__c = '33333333333';
		order.Payment_Transaction_Token__c = '';
		order.Payment_Transaction_Status__c = 'Draft';
		update order;

		Test.startTest();

		AP36_Payline_Handler.ws_getPaymentDetails(order.Id);

		Test.stopTest();

	}

	@isTest static void test_ws_getPaymentDetails_errorException_old() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
		order.PaymentTransactionId__c = '4444444444';
		order.Payment_Transaction_Token__c = '';
		order.Payment_Transaction_Status__c = 'Draft';
		update order;

		Test.startTest();

			try {
				AP36_Payline_Handler.ws_getPaymentDetails(order.Id);
			} catch (Exception e) { }

		Test.stopTest();

	}


/**
* doReset
**/
	@isTest static void test_ws_doReset_success_lu() {
		
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
		
		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
			
			Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c FROM Order WHERE Id = :resultAddToBasket LIMIT 1];
			ord.LU_Payment_Transaction_Id__c = '1111111111';
			ord.LU_Payment_Transaction_Token__c = '1111111111';
			ord.LU_Payment_Transaction_Status__c = 'Approved';
			update ord;

            Test.startTest();

				AP36_Payline_Handler.ws_doReset(ord.Id, true);

			Test.stopTest();
		}

	}

	@isTest static void test_ws_doReset_error_lu() {
		
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
			
			Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c FROM Order WHERE Id = :resultAddToBasket LIMIT 1];
			ord.LU_Payment_Transaction_Id__c = '22222222';
			ord.LU_Payment_Transaction_Token__c = '22222222';
			ord.LU_Payment_Transaction_Status__c = 'Approved';
			update ord;

            Test.startTest();

				AP36_Payline_Handler.ws_doReset(ord.Id, true);

			Test.stopTest();
		}

	}

	@isTest static void test_ws_doReset_exception_lu() {
		
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
			
			Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c FROM Order WHERE Id = :resultAddToBasket LIMIT 1];
			ord.LU_Payment_Transaction_Id__c = '3333333333';
			ord.LU_Payment_Transaction_Token__c = '3333333333';
			ord.LU_Payment_Transaction_Status__c = 'Approved';
			update ord;

            Test.startTest();

				AP36_Payline_Handler.ws_doReset(ord.Id, true);

			Test.stopTest();
		}

	}

	@isTest static void test_ws_doReset_noIds_lu() {
		
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());

		User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            // GENERATE AN ORDER
            List<AP1002_LookupSearchResult> lLines = new List<AP1002_LookupSearchResult>();
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9699', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('9700', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            lLines.addAll(Lwc17_fastordersearchbar_ctrl.searchProduct('3000', new List<Id>(), AP1000_Utils_Test.FRA_OFFERTYPE_STANDARD, null));
            String resultAddToBasket = Lwc17_fastordersearchbar_ctrl.addToBasket(lLines, null, pb.Id, con);
            system.assert(resultAddToBasket != 'ko', 'ERROR ADDTOBASKET');
			
			Order ord = [SELECT Id, LU_Payment_Transaction_Id__c, LU_Payment_Transaction_Token__c, LU_Payment_Transaction_Status__c FROM Order WHERE Id = :resultAddToBasket LIMIT 1];
			ord.LU_Payment_Transaction_Id__c = '';
			ord.LU_Payment_Transaction_Token__c = '';
			ord.LU_Payment_Transaction_Status__c = 'Approved';
			update ord;

            Test.startTest();

				AP36_Payline_Handler.ws_doReset(ord.Id, true);

			Test.stopTest();
		}

	}

	@isTest static void test_ws_doReset_success_old() {
		
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
		order.PaymentTransactionId__c = '1111111111';
		order.Payment_Transaction_Token__c = '1111111111';
		order.Payment_Transaction_Status__c = 'Approved';
		update order;

		Test.startTest();

		AP36_Payline_Handler.ws_doReset(order.Id, true);

		Test.stopTest();

	}

	@isTest static void test_ws_doReset_error_old() {
		
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
		order.PaymentTransactionId__c = '22222222';
		order.Payment_Transaction_Token__c = '22222222';
		order.Payment_Transaction_Status__c = 'Approved';
		update order;

		Test.startTest();

		AP36_Payline_Handler.ws_doReset(order.Id, true);

		Test.stopTest();

	}

	@isTest static void test_ws_doReset_exception_old() {
		
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
		order.PaymentTransactionId__c = '3333333333';
		order.Payment_Transaction_Token__c = '3333333333';
		order.Payment_Transaction_Status__c = 'Approved';
		update order;

		Test.startTest();

		AP36_Payline_Handler.ws_doReset(order.Id, true);

		Test.stopTest();

	}

	@isTest static void test_ws_doReset_noIds_old() {
		
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());

		// Create an order
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
		order.PaymentTransactionId__c = '';
		order.Payment_Transaction_Token__c = '';
		order.Payment_Transaction_Status__c = 'Approved';
		update order;

		Test.startTest();

		AP36_Payline_Handler.ws_doReset(order.Id, true);

		Test.stopTest();

	}
	

}