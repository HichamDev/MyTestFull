/*

----------------------------------------------------------------------
-- - Name          : AP16_LoyaltyProgramService_TEST.cls
-- - Author        : NGO
-- - Description   : Test class for retrieving loyalty program.
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 06-MAY-2013  NGO    1.0      Initial version 

----------------------------------------------------------------------  
*/
@isTest 
private class AP16_LoyaltyProgramService_TEST {
     static list<Account> accountList;
     static list<Contact> contactList;
     static list<User> userList;
     static list<ART_Article__c> articleList;
     static list<KIT_Kit__c> kitList;
     static list<CAT_Catalog__c> catalogueList;
     static list<CTA_CatalogArticle__c> catArticleList;
     static list<VFC01_ProductDetailDTO> ProductDetail;
     static list<VFC01_ProductOfferDTO> ProductOffer;
     static list<VFC01_ProductOfferDetailDTO> ProductOfferDetail;
     static list<VFC01_LoyaltyProgramRecapDTO> LYPRecapList;
     static Id contactDealerRecordTypeID, DealerProfileId, offerRecordTypeID, bundleRecordTypeID, productRecordTypeID;
     static list<LYP_LoyaltyProgram__c> lpsList;
     static {
        System.Debug('## >>>>> Start VFC01_OrderBasket_TEST >>> Inserting Data for Tests <<<<<'+UserInfo.getUserName());
        
        //Retrieving Record Type related to Contact
        contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
        system.debug('>>>>>> contactDealerRecordTypeID : ' + contactDealerRecordTypeID);
        
        //Retrieving Record Type related to Article
        //Offer
        offerRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00001 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Bundle
        bundleRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00002 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Product
        productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        
        //Retrieving Profile Ids
        DealerProfileId = [select id from Profile where Name= :system.label.CON00001].Id;
        system.debug('>>>>>> DealerProfileId : ' + DealerProfileId);
        
        //Creating new accounts
        accountList = new List<Account>{
            new Account(Name='AccountTest1'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test1'
                        , Country_Code__c = 'FRA'
                        , WebServiceAvailability__c = true),
            new Account(Name='AccountTest2'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test2'
                        , Country_Code__c = 'FRA')
        };
        insert (accountList);
        system.debug('>>>>>> accountList : ' + accountList);
        
        //Creating new contacts
        contactList = new List<Contact>{
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest1'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , STHID__c = 'test1'
                        , AccountId = accountList[0].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        ,CommissionRateRange__c = 'LP1'
                        , MinOrderFreeTransportFees__c=50),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest2'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test2.com'
                        , STHID__c = 'test2'
                        , AccountId = accountList[1].id
                        , CurrentBalance__c = -5
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50)           
        };
        insert (contactList);
        system.debug('>>>>>> contactList : ' + contactList);
        
        //Creating new users
        userList = new List<User>{
            new User(Username ='testemail1@test.com'
                     , LastName = 'TestLastName1'
                     , Email = 'TestEmail1@test.com'
                     , alias = 'testAl1'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , ContactId = contactList[0].Id),
            new User(Username ='testemail2@test.com'
                     , LastName = 'TestLastName1'
                     , Email = 'TestEmail2@test.com'
                     , alias = 'testAl2'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , ContactId = contactList[1].Id)        
        };
        insert (userList);
        system.debug('>>>>>> userList : ' + userList);
        
        //Creating new articles
        articleList = new List<ART_Article__c>{
            new ART_Article__c(//Product
                               RecordTypeId = productRecordTypeID  //articleList[0]
                               , Name = 'Shampoo1'
                               , LocalName__c = 'Shampoo1'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[1]
                                , Name = 'Shampoo2'
                                , LocalName__c = 'Shampoo2'),
            new ART_Article__c(RecordTypeId = productRecordTypeID  //articleList[2]
                               , Name = 'Gel1'
                               , LocalName__c = 'Gel1'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[3]
                                , Name = 'Gel2'
                                , LocalName__c = 'Gel2'),
            new ART_Article__c (RecordTypeId = productRecordTypeID //articleList[4]
                                , Name = 'Deo1'
                                , LocalName__c = 'Deo1'),
            new ART_Article__c (//Bundle
                                RecordTypeId = bundleRecordTypeID  //articleList[5]
                                , Name = 'ShampooBundle'
                                , LocalName__c = 'ShampooBundle'
                                , Number_of_Articles__c = 2),
            new ART_Article__c (RecordTypeId = bundleRecordTypeID  //articleList[6]
                                , Name = 'GelBundle'
                                , LocalName__c = 'GelBundle'
                                , Number_of_Articles__c = 2),
            new ART_Article__c (//Offer
                                RecordTypeId = offerRecordTypeID   //articleList[7]
                                , Name = 'ShampooGelBundle'
                                , LocalName__c = 'ShampooGelBundle'
                                , Number_of_Articles__c = 3)
        }; 
        insert(articleList);
        system.debug('>>>>>> articleList : ' + articleList);
        
        //Creating new kits
        kitList = new List<KIT_Kit__c>{
            new KIT_Kit__c (ParentArticle__c = articleList[5].Id
                            , Article__c = articleList[0].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 0
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[5].Id
                            , Article__c = articleList[1].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 0
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[6].Id
                            , Article__c = articleList[2].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 0
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[6].Id
                            , Article__c = articleList[3].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 0
                            , MaxQtyOrderable__c = 1),
            new KIT_Kit__c (ParentArticle__c = articleList[7].Id
                            , Article__c = articleList[5].id
                            , KitType__c = 'Closed set'),
            new KIT_Kit__c (ParentArticle__c = articleList[7].Id
                            , Article__c = articleList[6].id
                            , KitType__c = 'Closed set'),
            new KIT_Kit__c (ParentArticle__c = articleList[7].Id
                            , Article__c = articleList[4].id
                            , KitType__c = 'Closed set'
                            , MinQtyOrderable__c = 1
                            , MaxQtyOrderable__c = 1)
        };
        insert(kitList);
        system.debug('>>>>>> kitList : ' + kitList);
        
        //Creating new catalogue
        catalogueList = new List<CAT_Catalog__c>{
            new CAT_Catalog__c(Account__c = accountList[0].id
                               , Name = 'CatalogueTest1')
        };
        insert (catalogueList);
        system.debug('>>>>>> catalogueList : ' + catalogueList);
        
        //Creating new catalogue articles
        catArticleList = new List<CTA_CatalogArticle__c>{
            new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test1'
                                      , Active__c = true
                                      , AdminFees__c = true
                                      , Commissionable__c = true
                                      , DealerPrice__c = 9.73
                                      , IsByDefault__c = false
                                      , IsPushZone__c = true
                                      , LoyaltyPrgVal1__c = 10.0
                                      , LoyaltyPrgVal2__c = 10.0
                                      , LoyaltyPrgVal3__c = 10.0
                                      , MeansPayment__c = 'Cash;LP9'
                                      , NetPrice__c = 13.5
                                      ,CategoryLevelCommission__c = 'LP1'
                                      , PublicPrice__c = 9.73
                                      , ValidTotalAmountBase__c = true
                                      , RegularPrice__c = 10.0
                                      , Article__c = articleList[7].Id),
         new CTA_CatalogArticle__c(Catalog__c = catalogueList[0].Id
                                      , Name = 'Test1'
                                      , Active__c = true
                                      , AdminFees__c = true
                                      , Commissionable__c = true
                                      , DealerPrice__c = 9.73
                                      , IsByDefault__c = false
                                      , IsPushZone__c = true
                                      , LoyaltyPrgVal1__c = 10.0
                                      , LoyaltyPrgVal2__c = 10.0
                                      , LoyaltyPrgVal3__c = 10.0
                                      , MeansPayment__c = 'Cash;LP1'
                                      , NetPrice__c = 13.5
                                      ,CategoryLevelCommission__c = 'LP1'
                                      , PublicPrice__c = 9.73
                                      , ValidTotalAmountBase__c = true
                                      , RegularPrice__c = 10.0
                                      , Article__c = articleList[2].Id)         //catArticleList[1]                    
        };
        insert(catArticleList);
        system.debug('>>>>>> catArticleList : ' + catArticleList);
        
        LYPRecapList = new list<VFC01_LoyaltyProgramRecapDTO>();
        VFC01_LoyaltyProgramRecapDTO lypRecap = new VFC01_LoyaltyProgramRecapDTO();
        lypRecap.totalPoint = 10;
        lypRecap.pointCredited = 0;
        lypRecap.pointDebited = 10;
        lypRecap.lowerLimit = 1;
        lypRecap.quantity = 1;
        lypRecap.isDisplay = true;
        lypRecap.isChanged();
        lypREcap.lpCode = 'LP1';
        LYPRecapList.add(lypRecap);
        
        
        
      //  List<LYP_LoyaltyProgram__c> lps = new List<LYP_LoyaltyProgram__c>(
        LYP_LoyaltyProgram__c lp1 = new LYP_LoyaltyProgram__c (
        								Country__c = 'FRA',
        								LPCode__c = 'LP1',
        								CategoryLevelCommission__c = 'LP1',
        								CommissionRateRange__c = 'LP1',
        								FromDate__c = system.now() - 1890,
        								ToDate__c = system.now()
        							);
        							
         LYP_LoyaltyProgram__c lp2 = new LYP_LoyaltyProgram__c (
        								Country__c = 'FRA',
        								LPCode__c = 'LP1',
        								LPCreditBase__c = 'PublicPrice__c',
        								CategoryLevelCommission__c = 'LP1',
        								CommissionRateRange__c = 'LP1'
        								);
        LYP_LoyaltyProgram__c lp3 = new LYP_LoyaltyProgram__c (
        								Country__c = 'FRA',
        								LPCode__c = 'LP1',
        								LPCreditBase__c = 'RegularPrice__c',
        								CategoryLevelCommission__c = 'LP1',
        								CommissionRateRange__c = 'LP1'
        								);
       	LYP_LoyaltyProgram__c lp4 = new LYP_LoyaltyProgram__c (
        								Country__c = 'FRA',
        								LPCode__c = 'LP1',
        								LPCreditBase__c = 'DealerPrice__c',
        								CategoryLevelCommission__c = 'LP1',
        								CommissionRateRange__c = 'LP1'
        								);
		LYP_LoyaltyProgram__c lp5 = new LYP_LoyaltyProgram__c (
        								Country__c = 'FRA',
        								LPCode__c = 'LP1',
        								LPCreditBase__c = 'NetPrice__c',
        								CategoryLevelCommission__c = 'LP1',
        								CommissionRateRange__c = 'LP1'
        								);
       	LYP_LoyaltyProgram__c lp6 = new LYP_LoyaltyProgram__c (
        								Country__c = 'FRA',
        								LPCode__c = 'LP1',
        								LPCreditBase__c = 'LoyaltyPrgVal1__c',
        								CategoryLevelCommission__c = 'LP1',
        								CommissionRateRange__c = 'LP1'
        								);
       	LYP_LoyaltyProgram__c lp7 = new LYP_LoyaltyProgram__c (
        								Country__c = 'FRA',
        								LPCode__c = 'LP1',
        								LPCreditBase__c = 'LoyaltyPrgVal2__c',
        								CategoryLevelCommission__c = 'LP1',
        								CommissionRateRange__c = 'LP1'
        								);
       	LYP_LoyaltyProgram__c lp8 = new LYP_LoyaltyProgram__c (
        								Country__c = 'FRA',
        								LPCode__c = 'LP1',
        								LPCreditBase__c = 'LoyaltyPrgVal3__c',
        								CategoryLevelCommission__c = 'LP1',
        								CommissionRateRange__c = 'LP1'
        								);
        /*
        LYP_LoyaltyProgram__c lp2 = new LYP_LoyaltyProgram__c (
        								Country__c = 'FRA',
        								LPCode__c = 'LP2',
        								CategoryLevelCommission__c = 'l1',
        								CommissionRateRange__c = 'l1'
        								);
        
        
        lpsList.add(lp2);
        */
        //);
        lpsList= new list<LYP_LoyaltyProgram__c>();
        lpsList.add(lp1);
        lpsList.add(lp2);
        lpsList.add(lp3);
        lpsList.add(lp4);
        lpsList.add(lp5);
        lpsList.add(lp6);
        lpsList.add(lp7);
        lpsList.add(lp8);
        insert lpsList;
        system.debug('## lpsList : '+ lpsList); 
    }
    
    static testMethod void AddToBasketTest()
    {
        /*
        ORD_Order__c newOrder1 = new ORD_Order__c();
        test.startTest();
            ApexPages.StandardController sc1 = new ApexPages.StandardController(newOrder1);
            VFC01_OrderBasket vfcOrdBskt = new VFC01_OrderBasket(sc1);
            vfcOrdBskt.AddToBasket();
        test.stopTest();
        */
        boolean isFinal = true;
        list<VFC01_LoyaltyProgramRecapDTO> LYPList = new list<VFC01_LoyaltyProgramRecapDTO>();
        ORD_Order__c newOrder1 = new ORD_Order__c(dealer__c = contactList[0].id
                                 , Status__c = 'Draft'
                                 , OrderDate__c = system.TODAY());
        insert newOrder1;
        ORD_Order__c newOrder2 = new ORD_Order__c(dealer__c = contactList[0].id
                                 , Status__c = 'Draft'
                                 , OrderDate__c = system.TODAY());
        insert newOrder2;
        
        List<ORL_OrderLine__c> orderLineList = new List<ORL_OrderLine__c>{
                new ORL_OrderLine__c(Order__c = newOrder1.id
                                     , Article__c = articleList[7].Id
                                     , RegularPrice__c = 100
                                     , Qty__c = 1
                                     ,LpCode__c = 'LP1;LP2;LP3;LP4'
                                     ,LPAmount__c = '10;1;2;3'
                                     , TECH_ArticleType__c = 'Master'),
                new ORL_OrderLine__c(Order__c = newOrder1.id
                                     , Article__c = articleList[0].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'),
                new ORL_OrderLine__c(Order__c = newOrder1.id
                                     , Article__c = articleList[1].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 0
                                     , TECH_ArticleType__c = 'Child'),              
                new ORL_OrderLine__c(Order__c = newOrder1.id
                                     , Article__c = articleList[2].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child'),              
                new ORL_OrderLine__c(Order__c = newOrder1.id
                                     , Article__c = articleList[3].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 0
                                     , TECH_ArticleType__c = 'Child'),              
                new ORL_OrderLine__c(Order__c = newOrder1.id
                                     , Article__c = articleList[4].Id
                                     , RegularPrice__c = 0
                                     , Qty__c = 1
                                     , TECH_ArticleType__c = 'Child')
            };
            insert(orderLineList);  
            
            List<ORL_OrderLine__c> orderLineList2 = new List<ORL_OrderLine__c>{
                new ORL_OrderLine__c(Order__c = newOrder2.id
                                     , Article__c = articleList[2].Id
                                     , RegularPrice__c = 100
                                     , Qty__c = 1
                                     ,LpCode__c = ''
                                     ,LPAmount__c = ''
                                     , TECH_ArticleType__c = 'Product')
            };
            insert(orderLineList2);//ProductDetail // Article__c = articleList[2].Id)         //catArticleList[1]
            
            ProductDetail=new list<VFC01_ProductDetailDTO>();
            Map<Id, String> orderlinesOnline = new Map<Id, String>();
            
            orderlinesOnline.put(orderLineList2[0].Id,orderLineList2[0].LPCode__c);
            
            for (ORL_OrderLine__c orderline : orderLineList2) {
              VFC01_ProductDetailDTO theProductDetail = new VFC01_ProductDetailDTO();
	          theProductDetail.RegularPrice = orderline.RegularPrice__c;
	          theProductDetail.quantity = string.valueOf(orderline.Qty__c);
	          theProductDetail.quantityOld = integer.valueOf(orderline.Qty__c);
	          theProductDetail.orderline = orderline.id;
	          theProductDetail.CTA=catArticleList[1];
	          ProductDetail.add(theProductDetail);
            }
      	test.startTest();
		   AP16_LoyaltyProgramService AP16 = new AP16_LoyaltyProgramService();
		   AP16_LoyaltyProgram AP16LYP = new AP16_LoyaltyProgram('LP1', '10');
		   LYPList =  AP16.getLoyaltyProgramRecap(newOrder1.id, LYPRecapList, isFinal);
		         
		   //AP16.getLP('FRA', new List<String>('LP1'), '*', '*');
		   //AP16.getLP('FRA', new List<String>('LP1'), null, null);
		   AP16.getLoyaltyProgramMouvement(AP16LYP, LYPRecapList, true);
		   AP16.getLoyaltyProgramMouvement(AP16LYP, LYPRecapList, false);
		   list <string> llp = new list<string>();
		   llp.add('LP1');
		   AP16.getLPAmount(llp, 1, catArticleList[0], contactList[0]);
		   AP16.recalculateLPForOnlineOrder(ProductDetail, contactList[0], orderlinesOnline);
       	test.stopTest();
       
    }
    /*****Test for AP16_LoyaltyProgram.cls****/
    static testMethod void AP16_LoyaltyProgram_all_test()
    {
    	test.startTest();
	    	AP16_LoyaltyProgram Ap16_lp = new AP16_LoyaltyProgram();
	      	Ap16_lp.setLpAmounts(new list<String> {'100','200'});
	   		Ap16_lp.setToLpCodes(new list<String> {'LP1','LP2'});
	   		Ap16_lp.getToLpCode();
	  		Ap16_lp.getLpAmount();       
	   		system.assertEquals( Ap16_lp.getLpAmounts() ,new list<String> {'100','200'});
	   		system.assertEquals( Ap16_lp.getToLpCodes() ,new list<String> {'LP1','LP2'});
   		test.stopTest();
    }//end of AP16_LoyaltyProgram_test
    
    static testMethod void AP16_LoyaltyProgram_adjust_test()
    {
       test.startTest();
	       AP16_LoyaltyProgram Ap16_lp = new AP16_LoyaltyProgram();
	       Ap16_lp.setLpAmounts(new list<String> {'100','200'});
	       Ap16_lp.adjustValues(1,9);      
	       system.assertEquals( Ap16_lp.getLpAmounts() ,new list<String> {'112.5','225.0'});
       test.stopTest();
    }//end of AP16_LoyaltyProgram_test
    
     static testMethod void AP16_LoyaltyProgram_add_test()
    {
    	test.startTest();
	       AP16_LoyaltyProgram Ap16_lp = new AP16_LoyaltyProgram();
	       Ap16_lp.addToLpCode('LP5');
	       Ap16_lp.addLpAmount('500');     
	       system.assertEquals( Ap16_lp.getLpAmounts() ,new list<String> {'500'});
	       system.assertEquals( Ap16_lp.getToLpCodes() ,new list<String> {'LP5'});
       test.stopTest();
    }//end of AP16_LoyaltyProgram_test
    static testMethod void AP16_LoyaltyProgram_reverse_test()
    {
    	test.startTest();
	       AP16_LoyaltyProgram Ap16_lp = new AP16_LoyaltyProgram();
	       Ap16_lp.setLpAmounts(new list<String> {'100','200'});
	       Ap16_lp.setToLpCodes(new list<String> {'LP1','LP2'});
	       Ap16_lp.reverseValues();
	       Ap16_lp.hasDebit();
	       Ap16_lp.addToLpCode('LP5');
	       Ap16_lp.addLpAmount('500');
       test.stopTest();
    }//end of AP16_LoyaltyProgram_test
    
}