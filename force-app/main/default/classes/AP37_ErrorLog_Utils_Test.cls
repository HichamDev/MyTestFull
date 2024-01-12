@isTest
private class AP37_ErrorLog_Utils_Test {
	
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


	}

	@isTest static void test_insert() {
		
		ORD_Order__c order = [SELECT Id FROM ORD_Order__c LIMIT 1];

		AP37_ErrorLog_Utils.add_errorLog(order.Id, AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
											'my request', 'message');

		AP37_ErrorLog_Utils.create_errorLog(order.Id, AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
											'my request', 'message');
	
	}
	
}