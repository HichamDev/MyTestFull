@isTest
private class WS18_CreateAndUpdateCatalogContact_TEST {
	/*
//  WS18_CreateAndUpdateCatalogContact_TEST 
----------------------------------------------------------------------
-- - Name          : WS18_CreateAndUpdateCatalogContact_TEST 
-- - Author        : ASE 
-- - Description   : test class to test WebService WS18_CreateAndUpdateCatalogContact
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 10-OCT-2012  ASE    1.0      Intitial version
----------------------------------------------------------------------
**********************************************************************	*/

    static testMethod void CreateAndUpdateCatalogContact () {
    	//creating account
    	account testAccount = new account(	TypeLabel__c= 'test', 
    										Name= 'test Account', 
    										CurrencyIsoCode= 'EUR', 
    										AccountType__c= 'Level 2',
    										Country_Code__c = 'FRA'
    										);
      	insert testAccount;
      	system.debug('>>>>>>>>>>>>>>>>>>>>>>>testAccount: ' +testAccount);
        
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
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>contact: ' +contact);
        
       //creating catalog 
        CAT_Catalog__c catalog = new CAT_Catalog__c(Account__c= testAccount.id, 
        											name = 'catalog1', 
        											CatalogueType__c= 'Cycle catalog');
        insert catalog;
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>catalog: ' +catalog);
        
        //creating testdata for global class CatalogContacts 
      	WS18_CreateAndUpdateCatalogContact.CatalogContacts catCon= new WS18_CreateAndUpdateCatalogContact.CatalogContacts();
			catCon.ExternalId = 'test';
			catCon.Active= false;
			catCon.CatalogId=catalog.id;
			catCon.Dealer=contact.id;
			catCon.OffsetDaysAfterClosure= 4;
		
		//start test method
		test.startTest();
		
		//call webService WS18_CreateAndUpdateCatalogContact.acknowledgeCatalogContacts(wsCatalogContacts) and pass CatalogContacts as parameters 
		WS18_CreateAndUpdateCatalogContact.acknowledgeCatalogContacts(catCon);
        test.stopTest();
        
       	CAC_CatalogContact__c Catalog1 = [select Catalog__c from CAC_CatalogContact__c where TECH_ExternalId__c= :catCon.ExternalId];
        system.debug('>>>>>>>>>>>>>>>>>>Catalog: '+Catalog1.Catalog__c);
        system.assertEquals(Catalog1.Catalog__c, catCon.CatalogId);
    }
}