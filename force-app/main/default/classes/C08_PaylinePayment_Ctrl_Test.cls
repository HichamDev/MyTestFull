@isTest
private class C08_PaylinePayment_Ctrl_Test {
	
	@testSetup static void test_setup() {

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
	       						 , OrderDate__c = system.TODAY()
	       						 , TransportFees__c = 2
	       						 , LocalAttribute10__c = '204.02')
       	};
	    insert(orderList);

        //Product
        Id productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;

        //Creating new articles
        List<ART_Article__c> articleList = new List<ART_Article__c>{
            new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[0]
                               , Name = 'Shampoo1'
                               , LocalName__c = 'Shampoo1'
                               , StockStatusMessage__c = 'Test')
        }; 
        insert(articleList);
        system.debug('>>>>>> articleList : ' + articleList);
        
        //Creating new catalogue
        List<CAT_Catalog__c> catalogueList = new List<CAT_Catalog__c>{
            new CAT_Catalog__c(Account__c = testAccount.id
                               , Name = 'CatalogueTest1'
                               ,StartDate__c = Date.today().addDays(-20)
                               ,EndDate__c= Date.today().addDays(20))
        };
        insert (catalogueList);

        List<CTA_CatalogArticle__c> catArticleList = new List<CTA_CatalogArticle__c>{
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test1'
                                      , Active__c = true
                                      , PublicPrice__c = 1000
                                      , Article__c = articleList[0].Id
                                      ,ValidTotalAmountBase__c = true
                                      ,NetPrice__c = 50
                                      ,StartDate__c = Date.today().addDays(-20)
                                      ,EndDate__c= Date.today().addDays(20)
                                      )
        };

        List<CAC_CatalogContact__c> catContactList = new List<CAC_CatalogContact__c>{
            new CAC_CatalogContact__c(Catalog__c = catalogueList[0].Id
                                      //, Name = contactList[0].Id
                                      , Active__c = true
                                      , Dealer__c = contact.Id
                                       )
        };
        insert(catContactList);

        List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
                new ORL_OrderLine__c(Order__c = orderList[0].id
                                     , Article__c = articleList[0].Id
                                     , PublicPrice__c = 100
                                     , Qty__c = 1
                                     , Amount__c = 200
                                     , TECH_ArticleType__c = 'Master'
                                     , TECH_OrderStatus__c = 'Pending')
            };
        insert orderLineList;

    }


	@isTest static void test_initDraft() {
		
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
   		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		
        Test.startTest();
        
		PageReference orderRecapPage = Page.VFP01_OrderRecap_France;
    	Test.setCurrentPage( orderRecapPage );
	        	
    	//Add parameters to page URL
    	ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
		ApexPages.currentPage().getParameters().put('orderId', order.Id);
        
		C08_PaylinePayment_Ctrl ctrl = new C08_PaylinePayment_Ctrl();

		ctrl.initComponent();
		ctrl.navigateToPaymentPage();
        
		Test.stopTest();
	}

	@isTest static void test_evaluatDraft_rightAmount() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
		

		PageReference orderRecapPage = Page.VFP01_OrderRecap_France;
    	Test.setCurrentPage( orderRecapPage );
	        	
    	//Add parameters to page URL
    	ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
    	order.Payment_Transaction_Status__c = 'Draft';
    	order.PaymentTransactionId__c = '1111111111';
    	order.LocalAttribute10__c = '204.02';
    	update order;
		
        Test.startTest();
        
		ApexPages.currentPage().getParameters().put('orderId', order.Id);

		C08_PaylinePayment_Ctrl ctrl = new C08_PaylinePayment_Ctrl();

		ctrl.initComponent();

		Test.stopTest();
	}

	@isTest static void test_evaluatDraft_notRightAmount() {
		
        //Add parameters to page URL
    	ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
    	order.Payment_Transaction_Status__c = 'Draft';
    	order.PaymentTransactionId__c = '1111111111';
    	order.LocalAttribute10__c = '5206.02';
    	update order;
        
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
		Test.startTest();

		PageReference orderRecapPage = Page.VFP01_OrderRecap_France;
    	Test.setCurrentPage( orderRecapPage );
	        	        
		ApexPages.currentPage().getParameters().put('orderId', order.Id);

		C08_PaylinePayment_Ctrl ctrl = new C08_PaylinePayment_Ctrl();

		ctrl.initComponent();

		Test.stopTest();
	}
	
	@isTest static void test_approved() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
		

		PageReference orderRecapPage = Page.VFP01_OrderRecap_France;
    	Test.setCurrentPage( orderRecapPage );
	        	
    	ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
    	order.Payment_Transaction_Status__c = 'Approved';
    	update order;
		
        Test.startTest();
        
		ApexPages.currentPage().getParameters().put('orderId', order.Id);

		C08_PaylinePayment_Ctrl ctrl = new C08_PaylinePayment_Ctrl();

		ctrl.initComponent();

		Test.stopTest();
	}
	
	@isTest static void test_refused() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
		

		PageReference orderRecapPage = Page.VFP01_OrderRecap_France;
    	Test.setCurrentPage( orderRecapPage );
	        	
    	ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
    	order.Payment_Transaction_Status__c = 'Refused';
    	update order;
		
        Test.startTest();
        
		ApexPages.currentPage().getParameters().put('orderId', order.Id);

		C08_PaylinePayment_Ctrl ctrl = new C08_PaylinePayment_Ctrl();

		ctrl.initComponent();

		Test.stopTest();
	}
	
	@isTest static void test_error() {
		
		Test.setMock(WebServiceMock.class, new WS01_Payline_WebPaymentAPI_Mock());
		Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
		

		PageReference orderRecapPage = Page.VFP01_OrderRecap_France;
    	Test.setCurrentPage( orderRecapPage );
	        	
    	ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];
    	order.Payment_Transaction_Status__c = 'Error';
    	update order;
		
        Test.startTest();
        
		ApexPages.currentPage().getParameters().put('orderId', order.Id);

		C08_PaylinePayment_Ctrl ctrl = new C08_PaylinePayment_Ctrl();

		ctrl.initComponent();

		Test.stopTest();
	}
}