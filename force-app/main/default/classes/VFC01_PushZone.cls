public with sharing class VFC01_PushZone {
	
	public String orderContactId {get; set;}
	
	public VFC01_PushZone(){
			
	}
	
	String artFeeRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00004 and SObjectType = 'ART_Article__c' Limit 1].id;
    
    

	public List<CTA_CatalogArticle__c> getCatalogArticles(){
		
		List<CTA_CatalogArticle__c> catalogArticles = new List<CTA_CatalogArticle__c>();
		
		system.debug('## Class VFC01_PushZone - Start getList <<<<<'+UserInfo.getUserName());

		system.debug('## Class VFC01_PushZone - contactId <<<<< '+orderContactId);
		
		catalogArticles = [		SELECT Name, Article__r.Description__c, RegularPrice__c  from CTA_CatalogArticle__c where  Active__c = true and isPushZone__c = true and TECH_ArticleRecordType__c <> :artFeeRecordTypeID and 
								Catalog__c in (SELECT  c.Catalog__c From CAC_CatalogContact__c c 
								where c.Dealer__c = :orderContactId and c.Active__c = true 
								and c.TECH_CatalogDateInRange__c = 'true') order by TECH_CatalogPriority__c desc, Name limit 10];
								
		 system.debug('## Class VFC01_PushZone - End getList <<<<<'+UserInfo.getUserName());
					   
		return catalogArticles;
	}

}