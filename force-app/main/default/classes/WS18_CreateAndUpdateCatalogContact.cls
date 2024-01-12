global class WS18_CreateAndUpdateCatalogContact {

/*
//  WS18_CreateAndUpdateCatalogContact 
----------------------------------------------------------------------
-- - Name          : WS18_CreateAndUpdateCatalogContact 
-- - Author        : ASE 
-- - Description   : Web Service that allows Back office system send information related to catalog contact.
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 05-OCT-2012  ASE    1.0      Intitial version
----------------------------------------------------------------------
**********************************************************************
*/
	//Creating CatalogContacts class object 
	global class CatalogContacts { 
		webservice String ExternalId;
		webservice Boolean Active= false;
		webservice Id CatalogId;
		webservice String  Dealer;
		webservice integer OffsetDaysAfterClosure;
		
	} 
		
	//Creating Acknowledgment class object 
	global class Acknowledgment { 
		webservice String Status;
		webservice String Message;
		webservice String ExternalId;
	} 
	
   //The object CatalogContacts maps to the CAC_CatalogContact__c object in salesforce.com.
	//So need to map the CatalogContacts class
	webservice static Acknowledgment acknowledgeCatalogContacts (CatalogContacts wsCatalogContacts) {
		string status;
		string message;
		// matches order with external id and updates order with status and message in salesforce.
		CAC_CatalogContact__c catCon1 = new CAC_CatalogContact__c(	Active__c= wsCatalogContacts.Active,
																	Catalog__c=wsCatalogContacts.CatalogId,
																	Dealer__c=wsCatalogContacts.Dealer,
																	OffsetDaysAfterClosure__c= wsCatalogContacts.OffsetDaysAfterClosure,
																	TECH_ExternalId__c= wsCatalogContacts.ExternalId);
 										 
		// upserts data catalog contact. 
		// If Upsert OK, return status OK, message 'Catalog Contact inserted' 							 
		try {
			upsert catCon1 TECH_ExternalId__c;
			system.debug('>>>>>>>>>>>>catalogue: '+catCon1);
			status = system.label.CAC00001;
			message = system.label.CAC00003;
		}
		
		// If Upsert OK, return status Upsert Failed, error message from system 	
		catch(system.DmlException e){
			status =  system.label.CAC00002;
			message = e.getMessage();
		}
		
		// creates acknoledgement with message and status
		Acknowledgment acknowledgment1 = new Acknowledgment();
			acknowledgment1.ExternalId = wsCatalogContacts.ExternalId;
			acknowledgment1.Status = status;
			acknowledgment1.Message = message;
			
				
		system.debug('acknowledgment1: '+acknowledgment1);
		// displays acknowledgment
		return acknowledgment1;
		
	}/*
	test data to execute in anonymous to test WS
	WS18_CreateAndUpdateCatalogContact.CatalogContacts catCon= new WS18_CreateAndUpdateCatalogContact.CatalogContacts();
		catCon.ExternalId = 'test';
		catCon.Active= false;
		catCon.CatalogId='a0CM0000004EjHa';
		catCon.Dealer='003M000000HVH5J';
		catCon.OffsetDaysAfterClosure= 4;	
	WS18_CreateAndUpdateCatalogContact.acknowledgeCatalogContacts(catCon);*/
	
	
	
	
}