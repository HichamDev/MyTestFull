@isTest
private class VFC06_OfferHierarchy_TEST {
/*
----------------------------------------------------------------------
-- - Name          : VFC06_OfferHierarchy_TEST 
-- - Author        : AMU
-- - Description   : This class contains unit tests for validating the 
--                   behavior of controller VFC06_OfferHierarchy
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 30-AUG-2012  AMU    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/
	static testMethod void testOfferHierarchy(){
		System.Debug('## >>>>> Testing class VFC06_OfferHierarchy - testOfferHierarchy STARTS <<<<<'+UserInfo.getUserName());
 		
 		//Retrieving Record Type related to Article
 		//Offer
	 	ID offerRecordTypeID =   [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00001 and SObjectType = 'ART_Article__c' Limit 1].id;
	 	
	 	//Bundle
	 	ID bundleRecordTypeID =  [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00002 and SObjectType = 'ART_Article__c' Limit 1].id;
	 	
	 	//Product
	 	ID productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Creating Articles
        System.Debug('## >>>>> Creating Articles');
        List <ART_Article__c> PrdList = new List<ART_Article__c>();
        //Product
        ART_Article__c ProductTest1 = new ART_Article__c (RecordTypeId = productRecordTypeID, Name = 'ProductTest1', LocalName__c = 'ProductTest1', Number_of_Articles__c = 10);
        PrdList.add(ProductTest1); 
        ART_Article__c ProductTest2 = new ART_Article__c (RecordTypeId = productRecordTypeID, Name = 'ProductTest2', LocalName__c = 'ProductTest1', Number_of_Articles__c = 10);
        PrdList.add(ProductTest2); 
        //Bundle
        ART_Article__c BundleTest1  = new ART_Article__c (RecordTypeId = bundleRecordTypeID, Name = 'BundleTest1', LocalName__c = 'ProductTest1', Number_of_Articles__c = 10);
        PrdList.add(BundleTest1); 
        ART_Article__c BundleTest2  = new ART_Article__c (RecordTypeId = bundleRecordTypeID, Name = 'BundleTest2', LocalName__c = 'ProductTest1', Number_of_Articles__c = 10);
        PrdList.add(BundleTest2); 
        //Offer
        ART_Article__c OfferTest1   = new ART_Article__c (RecordTypeId = offerRecordTypeID, Name = 'OfferTest1', LocalName__c = 'ProductTest1', Number_of_Articles__c = 10);
        PrdList.add(OfferTest1); 
        insert(PrdList);
        
        //Creating Kits
        System.Debug('## >>>>> Creating Kits');
        List <KIT_Kit__c> KitList = new List<KIT_Kit__c>();
        KIT_Kit__c KitTest1 = new KIT_Kit__c (ParentArticle__c = BundleTest1.Id, Article__c = ProductTest1.id, KitType__c = 'Closed set');
        KitList.add(KitTest1);
        KIT_Kit__c KitTest2 = new KIT_Kit__c (ParentArticle__c = BundleTest1.Id, Article__c = ProductTest2.id, KitType__c = 'Closed set');
        KitList.add(KitTest2);
        KIT_Kit__c KitTest3 = new KIT_Kit__c (ParentArticle__c = BundleTest2.Id, Article__c = ProductTest1.id, KitType__c = 'Closed set');
        KitList.add(KitTest3);
        KIT_Kit__c KitTest4 = new KIT_Kit__c (ParentArticle__c = OfferTest1.Id, Article__c = BundleTest1.id, KitType__c = 'Closed set');
        KitList.add(KitTest4);
        KIT_Kit__c KitTest5 = new KIT_Kit__c (ParentArticle__c = OfferTest1.Id, Article__c = BundleTest2.id, KitType__c = 'Closed set');
        KitList.add(KitTest5);
        insert(KitList);
        
        test.startTest();
        
	        PageReference OfferHierarchyPage = Page.VFP06_OfferHierarchy;
	        Test.setCurrentPage( OfferHierarchyPage );
	        ApexPages.currentPage().getParameters().put( 'id', OfferTest1.id );
	    
	        // Instanciate Controller
	        VFC06_OfferHierarchy controller = new VFC06_OfferHierarchy();
	        
	        // Call Methodes for top account
	        controller.setcurrentId( null );
	        VFC06_OfferHierarchy.ObjectStructureMap[] smt1 = new VFC06_OfferHierarchy.ObjectStructureMap[]{};
	        smt1 = controller.getObjectStructure();
	        System.Assert( smt1.size() > 0, 'Test failed at Top offer, no Id' );
	
	        controller.setcurrentId( String.valueOf( OfferTest1.id ) );
	        VFC06_OfferHierarchy.ObjectStructureMap[] smt2 = new VFC06_OfferHierarchy.ObjectStructureMap[]{};
	        smt2 = controller.getObjectStructure();
	        System.Assert( smt2.size() > 0, 'Test failed at Top offer, with Id: '+smt2.size() );
	
	        //Call ObjectStructureMap methodes
	        smt2[0].setnodeId( '1234567890' );
	        smt2[0].setlevelFlag( true );
	        smt2[0].setlcloseFlag( false );
	        smt2[0].setnodeType( 'parent' );
	        smt2[0].setcurrentNode( false );
	        smt2[0].setaccount( KitTest1);
	        
	        String nodeId       = smt2[0].getnodeId();
	        Boolean[] levelFlag = smt2[0].getlevelFlag();
	        Boolean[] closeFlag = smt2[0].getcloseFlag();
	        String nodeType     = smt2[0].getnodeType();
	        Boolean currentName = smt2[0].getcurrentNode();
	        KIT_Kit__c smbAccount  = smt2[0].getaccount();
	
	        // Call Methodes for middle account
	        controller.setcurrentId( String.valueOf( KitTest2.id ) );
	        VFC06_OfferHierarchy.ObjectStructureMap[] smm = new VFC06_OfferHierarchy.ObjectStructureMap[]{};
	        smm = controller.getObjectStructure();
	        System.Assert( smm.size() > 0, 'Test failed at middle account' );
	
	        // Call Methodes for bottom account
	        controller.setcurrentId( String.valueOf( KitTest2.id ) );
	        VFC06_OfferHierarchy.ObjectStructureMap[] smb = new VFC06_OfferHierarchy.ObjectStructureMap[]{};
	        smb = controller.getObjectStructure();
	        System.Assert( smb.size() > 0, 'Test failed at top account' );
        
        test.stopTest();
    }
}