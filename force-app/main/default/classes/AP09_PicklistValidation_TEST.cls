/* 
------------------------------------------------------------
-- - Name          : AP09_PicklistValidation 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Class used to enforce picklist values when importing data to salesforce 
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 15-OCT-2012  NGO    1.0    Initial version
------------------------------------------------------------
*/
@isTest(SeeAllData = true)
private class AP09_PicklistValidation_TEST {

    static testMethod void pickListValidationTest() {
    	
    	Account account = createAccount();
    	
    	insert account;
    	
    	account.AccountType__c = 'Level 3';
    	
    	update account;
    	
    	try{
    		
    		account.AccountType__c = 'Level 20';
    	
    		update account;
    		
    	}catch(DmlException e){

    		System.assert(e.getMessage().contains('The value Level 20 for picklist field AccountType__c is not valid'));
    	}
    	
    	
    	Contact contact = createContact(account.Id);
    	
    	insert contact;
    
    	contact.AllowedPaymentMode__c = 'Cash';
    
    	update contact;
    	
    	
    	try{
    		
    		contact.AllowedPaymentMode__c = 'Cash;Test';
    	
    		update contact;
    		
    	}catch(DmlException e){
    		
    		System.debug(e.getMessage());

    		//System.assert(e.getMessage().contains('The value Credit card;test for picklist field AllowedPaymentMode__c is not valid'));
    	}
    	
   		User user = createUser(contact.Id);
       
        insert user;
        
        user.Civility__c = 'Ms';
        
        //update user;
        
        
        
        ART_Article__c article   = createArticle();
        
        insert(article);
        
        update(article);
        
        KIT_Kit__c kit = createKit(article.Id);
        
        insert kit;
        
        update kit;
        
        
        CAT_Catalog__c catalog =  createCatalog(account.Id);
        
        insert catalog;
        
        update catalog;
        
        CTA_CatalogArticle__c cta = createCatalogArticle(catalog.id, article.Id);
        
        insert cta;
        
        update cta;
        
        
        CAC_CatalogContact__c cac = createCatalogContact(catalog.Id, contact.Id);
        
        ORD_Order__c order1 = createOrder(cac.Id,  contact.Id);
        
        insert order1;
        
        update order1;
        
        ORL_OrderLine__c orl = createOrderLine(order1.Id, article.Id);
        
        insert orl;
        
        update orl;
        
        INV_Invoice__c inv = createInvoice(contact.Id);
        
        try{

        	insert inv;
        
        }catch(DmlException e){
        	System.assert(e.getMessage().contains('The value Val1 for picklist field InvoicingCountry__c is not valid'));
        }
        
        inv.InvoicingCountry__c = 'France';
        
        insert  inv;
        
        inv.InvoicingCountry__c = '';
      
      	update inv;

      	//System.assert([select InvoicingCountry__c from INV_Invoice__c where Id = : inv.Id limit 1][0].InvoicingCountry__c == '');
      	
      
    }
    
    
    static INV_Invoice__c createInvoice(Id contactId){
    	
    	date t = system.today();
        integer INVnumMonths = Integer.valueOf(system.label.INV00001);
        date purgeINV= t.addMonths(INVnumMonths);
    	
    	INV_Invoice__c invoice1 = new INV_Invoice__c(Status__c = 'Paid', OriginOrderType__c='Invoice', 
                                                    InvoicingZipCode__c='12010', InvoicingStreet__c= 'Lana street', 
                                                    InvoicingCountry__c= 'Val1', InvoicingCity__c= 'New York', 
                                                    InvoiceType__c= 'Invoice', Dealer__c= contactId , CurrencyIsoCode = 'EUR', 
                                                    PaymentDate__c= purgeINV-2, InvoiceDate__c= purgeINV-30);
                                                    
       return invoice1;
    }
    
    static ORL_OrderLine__c createOrderLine(Id orderId, Id articleID){
    	
    	ORL_OrderLine__c orderLine = new ORL_OrderLine__c(Order__c = orderId,
												    	Article__c = articleID,
												    	RegularPrice__c = 100,
												    	Qty__c = 10,
												    	Amount__c = 1000,
												    	AmountWihtoutTax__c = 1000,
												    	Commission__c = 0);
    	
    	return orderLine;
    	
    }
    
    
    
    static CAC_CatalogContact__c createCatalogContact(Id catalogId, Id contactId){
    	
    	CAC_CatalogContact__c cac = new CAC_CatalogContact__c(Catalog__c = catalogId, Dealer__c = contactId);
    	
    	return cac;
    } 
    
    static ORD_Order__c createOrder(Id cacId, Id dealerId){
    	
    	date t = system.today();
        integer ORDnumMonths = Integer.valueOf(system.label.ORD00001);
        date purgeORD= t.addMonths(ORDnumMonths); 
    	
    	ORD_Order__c order1 = new ORD_Order__c(Status__c ='Draft', OrderDate__c =purgeORD -50, 
    	NeedByDate__c= purgeORD-10, Dealer__c= dealerId, CommCycleStartDate__c= purgeORD-30, 
    	CommCycleEndDate__c= purgeORD-15, CommCycle__c= 'cycle1', ClosingDate__c= purgeORD-10, 
    	Catalog__c= cacId);
     
     
     	return order1;
    }
    
    
    static ART_Article__c createArticle(){
    	
    	ID offerRecordTypeID =   [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00001 and SObjectType = 'ART_Article__c' Limit 1].id;
	 	
    	
    	ART_Article__c article = new ART_Article__c (RecordTypeId = offerRecordTypeID, Name = 'OfferTest1', LocalName__c = 'ProductTest1', Number_of_Articles__c =5);
    	
    	return article;
    	
    }
    
    static KIT_Kit__c createKit(Id articleId){
    	
    	 KIT_Kit__c kit = new KIT_Kit__c (ParentArticle__c = articleId, Article__c = articleId, KitType__c = 'Closed set');
    	 
    	 return kit;
    }
    
    static  CAT_Catalog__c createCatalog(Id accountId){
    	
    	 CAT_Catalog__c catalog = new CAT_Catalog__c(Account__c= accountId, 
        											name = 'catalog1', 
        											CatalogueType__c= 'Cycle catalog');
    	
    	return catalog;
    	
    }
    
    static CTA_CatalogArticle__c createCatalogArticle(Id idCatalog, Id idArticle){
    	
    	CTA_CatalogArticle__c obj = new CTA_CatalogArticle__c(Name ='test', Catalog__c = idCatalog, Article__c= idArticle);
    	
    	return obj;
    	
    }
    
  
    
    /*
    static PCT_PersonalContact__c createPersonalContact(){
    	
    	PCT_PersonalContact__c pct = new PCT_PersonalContact__c(Name ='PCT', Salutation__c = 'Ms', FirstName__c ='Test');
    	
    	return PCT;
    	
    }*/
    
    static User createUser(Id contactId){
    	
    	 Profile profileDealer = [Select Id From Profile Where name = 'Dealer'];
    	
    	  //Insert new user
        User user1 =new User(	alias = 'dealer', 
        						email='user1@sth.com', 
        						emailencodingkey='UTF-8', 
                                lastname='testUser1',
                                languagelocalekey='fr', 
                                localesidkey='fr_FR_EURO', 
                                profileid = profileDealer.Id,
                                timezonesidkey='Europe/Paris', 
                                username='user1@sth.com',
                                MobilePhone= '34567', 
                                TECH_ExternalId__c= 'zyx',
                                ContactId =contactId);       
        return user1;
    	
    }
    
    
    static Contact createContact(Id accountId){
    
        Contact contact = new Contact(  STHID__c='123', 
        								AccountId=accountId, 
        								CurrencyIsoCode = 'EUR', 
                                        lastname='user1',
                                        email= 'user1@sth.com',
                                        Birthdate =date.newinstance(1986, 12, 28),
                                        TECH_ExternalId__c= 'ase3',
                                        AllowedPaymentMode__c ='Cash;Bank transfer',
                                        MinOrder__c=50, 
                                        MinOrderFreeTransportFees__c=50
                                        );
                                        
         return contact;
    }
    
    
    
    static Account createAccount(){
    
        String acc_name = 'Test Account BR09';
        
        Account acct = new Account(name=acc_name, AccountType__c = 'Level 2', Country_Code__c='FRA');
        
        return acct;
    }
}