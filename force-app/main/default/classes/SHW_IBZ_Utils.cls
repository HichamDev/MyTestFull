public with sharing class SHW_IBZ_Utils {
/*
----------------------------------------------------------------------
-- - Name          : SHW_IBZ_Utils 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Class containing generic utils method 
--                   
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 28-AUG-2012  NGO    1.0      Initial version 
----------------------------------------------------------------------  



    /* Returns a dynamic SOQL statement for the whole object, includes only 
    * creatable fields since we will be inserting a cloned result of this query
    */
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
 
        String selects = '';

        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
 
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
 
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
 
        }
        
        String query = 'SELECT ' + selects + ' FROM ' + objectName;

        if (whereClause == null || whereClause == ''){ 
         
             return query ;
         
         }else{
            
             return query + ' WHERE ' + whereClause;
            
         }

    }
    
    /* Returns a dynamic SOQL statement for the whole object, includes only 
    * creatable fields since we will be inserting a cloned result of this query
    */
    public static string getCreatableFieldsSOQLByID(String objectName, List<Id> ids){
        
        String query = getCreatableFieldsSOQL(objectName, null);
        
        if(ids != null && ids.size() >0){
            
            query += ' where Id in (';
            
            for(Id id : ids){
                
                query += '\'' + id + '\','; 
                
            }
            
            query = query.removeEnd(',');
            
            query += ')';
            
        }
        
        return query;
        
    }
    
    
    public static Map<string,string> populateObjectNameByIdMap(){
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 

        Set<String> keyPrefixSet = gd.keySet();
        
        Map<string,string> keyPrefixMap = new Map<string, string>();
        
        for(String sObj : keyPrefixSet){
            
           Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
           
           String tempName = r.getName();
           
           String tempPrefix = r.getKeyPrefix();
           
           System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
           
           keyPrefixMap.put(tempPrefix,tempName);
           
        }
        
        return keyPrefixMap;
    }
    
    
   // Get a list of picklist values from an existing object field.
   public static List<string> getPicklistValues(SObject obj, String fld){
      List<string> options = new List<string>();
      // Get the object type of the SObject.
      Schema.sObjectType objType = obj.getSObjectType(); 
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      // Get a map of fields for the SObject
      Map<string,Schema.Sobjectfield> fieldMap = objDescribe.fields.getMap(); 
      
      Schema.Sobjectfield  field = fieldMap.get(fld); 
      // Get the list of picklist values for this field.
      List<Schema.PicklistEntry> values = field.getDescribe().getPickListValues();
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a : values){ 
        
         System.debug('getPicklistValues' + a.getValue());
         
         options.add(a.getValue()); 
      }
      return options;
   }
   
    /**
    * Check if connected user is Interface
    * Using cuntom settings User__c
    */
    static public Boolean isInterfaceUser(){
         
        //retrieve custom settings 
        User__c userSettings = User__c.getInstance(UserInfo.getProfileId());
        
        System.debug('***userSettings.isInterfaceUser__c '+ userSettings.isInterfaceUser__c);
        
        return userSettings.isInterfaceUser__c;
        
    }
    
      
     static public Contact getConnectedUserContact(){
        
        User user = [select id, TECH_MergeContactID__c from user where id =: Userinfo.getUserId() limit 1];
        
        system.debug('>>>>>>>>>>>>> getConnectedSFDUserContact TECH_ContactID__c : '+ user.TECH_MergeContactID__c);
        
        if(user.TECH_MergeContactID__c  != null){
        
            List<Contact> contacts = [select    ID 
                            ,Name
                            ,STHID__c
                            ,TECH_campaign__c
                            ,CurrentBalance__c
                            ,CurrencyIsoCode
                            ,BadDebt__c
                            ,LastDateToOrder__c
                            ,MinOrder__c
                            ,TECH_WSAvailability__c
                            ,AccountId
                            ,CommissionRateRange__c
                            ,PersonalMessage__c 
                            ,TECH_ApplicationDateSent__c
                            ,TECH_ApplicationAcessUrl__c
                            ,FirstName
                            ,LastName
                            ,MailingAddressComment__c
                            ,CurrentCommercialCycle__c
                            ,MailingStreet
                            ,MailingState
                            ,MailingPostalCode
                            ,MailingCountry
                            ,MailingCity
                            ,ReportsToId
                            ,NbOrderForCurrentComCycle__c
                            ,AccountCountryCode__c
                    from Contact where id = : user.TECH_MergeContactID__c limit 1];
                    
            if(contacts != null && contacts.size() > 0 ){
                
                return contacts[0];
                
            }else{
                return null;
            }
    
        }else{
            
            return null;
        }
    }
    
}