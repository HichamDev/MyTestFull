@isTest
public class AP31_BatchDeleteCB_TEST
{

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
        STHEndpoints__c endIt = new STHEndpoints__c();
        endIt.Name = 'ITA';
        endIt.Google_Timeout__c = 10000;
        endIt.Google_Endpoint__c = 'http://google.fr';
        endIt.Google_Crypto_Key__c = 'crypto';
        endIt.Google_Client_Id__c = 'clientID';
        endIt.Google_Channel_Id__c = 'channel';
        endIt.Card_Payment_Shop_Id__c = 'ShopId';
        endIt.Card_Payment_Merchant_Id__c = 'merchantId';
        endIt.Card_Payment_Coef__c = 1.01;
        endIt.Card_Payment_Endpoint__c = 'endpoint';
        endIt.Card_Payment_API_Key__c  = 'apikey';
        insert endIt;

		//creating account
    	account testAccount = new account(	TypeLabel__c= 'test', 
    										Name= 'test Account', 
    										CurrencyIsoCode= 'EUR', 
    										AccountType__c= 'Level 2',
    										Country_Code__c = 'FRA'
    										);
      	insert testAccount;
        //creating account ITA
    	account testAccountITA = new account(	TypeLabel__c= 'test', 
    										Name= 'test Account', 
    										CurrencyIsoCode= 'EUR', 
    										AccountType__c= 'Level 2',
    										Country_Code__c = 'ITA'
    										);
      	insert testAccountITA;
        
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
        //creating contact ITA
        Contact contactITA = new Contact(  STHID__c='123', 
        								AccountId=testAccountITA.id, 
        								CurrencyIsoCode = 'EUR', 
                                        lastname='br04Contact',
                                        email= 'br04Contact@sth.com',
                                        Birthdate =date.newinstance(1986, 12, 28),
                                        MinOrderFreeTransportFees__c = 50,
                                        MinOrder__c = 50);
        insert contactITA;
        
    	List<ORD_Order__c> orderList = new List<ORD_Order__c>{
	       		new ORD_Order__c(dealer__c = contact.Id
	       						 , Status__c = 'Draft'
	       						 , OrderDate__c = system.TODAY()
                                 , Payment_Transaction_Draft_Creation__c = Datetime.now().addHours(-2)
	       						 , Payment_Transaction_Token__c = 'skdfjk')
       	};
	    insert(orderList);
    	List<ORD_Order__c> orderListITA = new List<ORD_Order__c>{
	       		new ORD_Order__c(dealer__c = contactITA.Id
	       						 , Status__c = 'Draft'
	       						 , OrderDate__c = system.TODAY()
                                 , Payment_Transaction_Draft_Creation__c = Datetime.now().addHours(-2)
	       						 , Payment_Transaction_Token__c = 'skdfjk')
       	};
	    insert(orderListITA);

	    BatchOrderDeletionOptions__c options = new BatchOrderDeletionOptions__c();
        options.Name = 'FRA';
        options.IsAutomaticDeletion__c = true;
        insert options;
	    BatchOrderDeletionOptions__c optionsITA = new BatchOrderDeletionOptions__c();
        optionsITA.Name = 'ITA';
        optionsITA.IsAutomaticDeletion__c = true;
        insert optionsITA;

	}

	static testMethod void testScheduler() {
        
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        Test.startTest();
        
        AP31_SchFRA_BatchDeleteCB  SchFRA = new AP31_SchFRA_BatchDeleteCB ();

        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing AP31_BatchDeletCB FRA', sch, SchFRA);
                
        Test.stopTest();
    }

	static testMethod void testSchedulerITA() {
        
        Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
        Test.startTest();
        
        AP31_SchITA_BatchDeleteCB  SchITA = new AP31_SchITA_BatchDeleteCB ();

        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing AP31_BatchDeletCB ITA', sch, SchITA);
                
        Test.stopTest();
    }


    static testMethod void testBatch() {

    	Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
    	Test.startTest();

    	AP31_BatchDeleteCB deleteOrder = new AP31_BatchDeleteCB('FRA');        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(deleteOrder);

    	Test.stopTest();

    }

    static testMethod void testBatchITA() {

    	Test.setMock(WebServiceMock.class, new WS02_Payline_DIrectPaymentAPI_Mock());
    	Test.startTest();

    	AP31_BatchDeleteCB deleteOrder = new AP31_BatchDeleteCB('ITA');        
        //Launch the batch process and get the job ID for the test batch
        Id batchprocessid = Database.executeBatch(deleteOrder);

    	Test.stopTest();

    }
}