global class VFC01_AutoCompleteController 
{
    @RemoteAction
    global static SObject[] findSObjects(string obj, string qry, string addFields, String contactId, String orderType) 
    {
        System.debug('## Class VFC01_AutoCompleteController - START findSObjects <<<<<'+UserInfo.getUserName());
        System.debug('<<<<<obj: '+obj);
        System.debug('<<<<<qry: '+qry);
        System.debug('<<<<<addFields: '+addFields);
        //System.debug('<<<<<profilename: '+profilename);
        System.debug('<<<<<contact: '+contactId);
        	
        //Retrieving Fee recordtypeif for product
	 	String artFeeRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00004 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        
        /* More than one field can be passed in the addFields parameter
           Split it into an array for later use */
        List<String> fieldList=new List<String>();
        if (addFields != '')  
        fieldList = addFields.split(',');
        
        /* Check whether the object passed is valid */
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) 
        {
            return null;
        }
        
        /* Creating the filter text */
        String filter = ' like \'%' + String.escapeSingleQuotes(qry) + '%\'';
        
        /* Begin building the dynamic soql query */
        String soql = 'SELECT Name';
        
        /* If any additional field was passed, adding it to the soql */
        if (fieldList.size()>0) 
        {
            for (String s : fieldList) 
            {
                soql += ', ' + s;
            }
        }
        
        /* Adding the object and filter by name to the soql */
        soql += ' from ' + obj + ' where name' + filter;
        
        //Adding additional filters
        //Catalogue Article must be true
        soql += ' and Active__c = true ';
        //check if in range
        soql += ' and TECH_CatalogArticleDateInRange__c = \'true\' ';
        
        //Exclude Fee articles
        soql += ' and TECH_ArticleRecordType__c <> \'' + artFeeRecordTypeID + '\'';
        //filter by Catalog Date
        
        if(contactId != null)
        {
            //profile name and the System Administrator are allowed
            //soql += ' and Profile.Name like \'%' + String.escapeSingleQuotes(profilename) + '%\'';
            
            
            soql += ' and Catalog__c in (SELECT  c.Catalog__c From CAC_CatalogContact__c c where c.Dealer__c = \'' + contactId + 
            								'\' and c.Active__c = true and c.TECH_CatalogDateInRange__c = \'true\' ';
            String theType = (orderType==null || orderType=='') ? 'Offline' : orderType;
             system.debug('## Class VFC01_AutoCompleteController - theType<<<<<'+theType);
             system.debug('## Class VFC01_AutoCompleteController - orderType<<<<<'+orderType+'>>>');
            if(theType.equals('Offline')){
            	soql += ' and c.Catalog__r.CatalogueType__c <> \'Digital Catalog\' ';
            }else{
            	soql += ' and c.Catalog__r.CatalogueType__c = \'Digital Catalog\' ';
            }
            soql +=' )';
            system.debug('contactId:'+contactId+' and SOQL:'+soql);
            
            /*system.debug('Profile:'+profilename+' and SOQL:'+soql);*/
            
        }
        
        /* Adding the filter for additional fields to the soql */
        if (fieldList != null) 
        {
            for (String s : fieldList) 
            {
                soql += ' or ' + s + filter;
            }
        }
        
        soql += ' order by TECH_CatalogPriority__c desc, Name limit 20';
        
        system.debug('>>>>>>>Qry: '+soql);
        
        List<sObject> L = new List<sObject>();
        try 
        {
            L = Database.query(soql);
            system.debug('>>>>>>>L: '+l);
        }
        catch (QueryException e) 
        {
            system.debug('Query Exception:'+e.getMessage());
            return null;
        }
        System.debug('## Class VFC01_AutoCompleteController - END findSObjects <<<<<'+UserInfo.getUserName());
        return L;
   }
}