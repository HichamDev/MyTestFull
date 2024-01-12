public with sharing class VFC01_PersonalContactListView{

/* 
----------------------------------------------------------------------
-- - Name          : VFC01_PersonalContactListView
-- - Author        : NGO
-- - Description   : Controller for VFP01_PersonalContactListView Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 18-MAR-2014         1.0      Initial version   
-- 04-APR-2016  WCH    1.8      Add an option "My Personal Contact Online" in drop down menu for filter
----------------------------------------------------------------------
**********************************************************************
*/
    /*****************************************************************/
    /***************** Instantiating Global Variable *****************/
    /*****************************************************************/
    //Global Boolean
    public Boolean isPortal {get;set;}

    //Global Id
    public Id contactId {get;set;}
    
    //Global String
    public String userId {get;set;}
    public String userType {get;set;}
    public String contactCountryCode {get;set;}

    //filter
    public final List<SelectOption> filterOptions {get;set;}
    public String selectedOption {get;set;}
    public List<PCT_PersonalContact__c> thePersonalContactList {get;set;}
    
    /*****************************************************************/
    /******************** Page Constructor ***************************/
    /*****************************************************************/
    public VFC01_PersonalContactListView(){
        system.debug('## Class VFC01_PersonalContactListView- START VFC01_PersonalContactListView<<<<<'+UserInfo.getUserName()); 
    
        //Retrieving User ID, USer Type
        userId = UserInfo.getUserId();
        userType = UserInfo.getUserType();
        
        //Checks if Portal User
        CheckUser(userType, userId);
        
         contactId = [Select TECH_ContactID__c
                           From User
                          Where id = :userId
                          limit 1].TECH_ContactID__c;
        list<string> listOfFilters= getFieldLabel(new list<string>{'Customer__c','Customer_prospect__c','Dealer_prospect__c','Competitive_dealer__c','Hostess__c','Hostess_prospect__c','OtherPersonalContactType__c','Competitive_hostess__c','PersonalContactType__c','OptinNewsletter1__c','OptinNewsletter2__c'});                
        filterOptions = new List<SelectOption>();

        filterOptions.add(new SelectOption(system.label.ORD00045+'0',system.label.ORD00045));
        filterOptions.add(new SelectOption(listOfFilters.get(0)+'#1#',listOfFilters.get(0)));
        filterOptions.add(new SelectOption(listOfFilters.get(1)+'#2#',listOfFilters.get(1)));
        filterOptions.add(new SelectOption(listOfFilters.get(2)+'#3#',listOfFilters.get(2)));
        filterOptions.add(new SelectOption(listOfFilters.get(3)+'#4#',listOfFilters.get(3)));
        filterOptions.add(new SelectOption(listOfFilters.get(4)+'#5#',listOfFilters.get(4)));
        filterOptions.add(new SelectOption(listOfFilters.get(5)+'#6#',listOfFilters.get(5)));
        filterOptions.add(new SelectOption(listOfFilters.get(6)+'#7#',listOfFilters.get(6)));
        filterOptions.add(new SelectOption(listOfFilters.get(7)+'#8#',listOfFilters.get(7)));
        filterOptions.add(new SelectOption(system.label.WAT00025+'#9#',system.label.WAT00025));
        filterOptions.add(new SelectOption(system.label.WAT00026+'#10#',system.label.WAT00026));
        filterOptions.add(new SelectOption(system.label.WAT00027+'#11#',system.label.WAT00027));
        filterOptions.add(new SelectOption(system.label.WAT00028+'#12#',system.label.WAT00028));
        filterOptions.add(new SelectOption(system.label.WAT00029+'#13#',system.label.WAT00029));
        filterOptions.add(new SelectOption(listOfFilters.get(8)+'#14#',listOfFilters.get(8)));
        filterOptions.add(new SelectOption(listOfFilters.get(9)+'#15#',listOfFilters.get(9)));
        filterOptions.add(new SelectOption(system.label.WAT00030+'#16#',system.label.WAT00030));

        selectedOption='0';

        filterOptions.sort();

        getPersonalContact();
        system.debug('## Class VFC01_PersonalContactListView- END VFC01_PersonalContactListView<<<<<'+UserInfo.getUserName());
    }
    
    /*****************************************************************/
    /*********************** CheckUser *******************************/
    /*****************************************************************/
    public void CheckUser(String userType, String userId){
        system.debug('## Class VFC01_OrderRecipient - START CheckUser <<<<<'+UserInfo.getUserName());
        
        //Checks if Portal User
        if (userType == 'CspLitePortal'){
            isPortal = true;
            //Retrieving Contact ID related to user
            contactId = [Select TECH_ContactID__c
                           From User
                          Where id = :userId
                          limit 1].TECH_ContactID__c;
        }
        else{
            isPortal = false;
        }
                                                
    }
    
    /*****************************************************************/
    /******************** ControllerSet Init *************************/
    /*****************************************************************/
    public ApexPages.StandardSetController personalContactSet {   
        get {
            system.debug('## contact ID <<<<<'+contactId);
            //finding the country code of the contact
            
            string theQuery=generateQuery(selectedOption);
            if(personalContactSet == null) {                                     
                    personalContactSet= new ApexPages.StandardSetController(Database.query(theQuery));
            }
        personalContactSet.setPageSize(1000); 
        return personalContactSet;
        }
        set;
    }
    
    public void getPersonalContact(){
        thePersonalContactList=(List<PCT_PersonalContact__c>) personalContactSet.getRecords();
    }
    public PageReference refreshPagePC() {
        string theQuery=generateQuery(selectedOption);
        thePersonalContactList = database.query(theQuery);
        system.debug('>>>>>> refreshPagePC: thePersonalContactList'+thePersonalContactList);
        system.debug('>>>>>> refreshPagePC: selectedOption'+selectedOption);
        return null;
    }
    
    
    public string generateQuery(string theOption){
        system.debug('## Class VFP01_PersonalContactListView - function generateQuery <<<<<'+UserInfo.getUserName());
        string theQuery='SELECT  Id,Name,FirstName__c,PersonalZipCode__c,PersonalCity__c,Phone__c,Mobile__c,Last_order_date__c,Last_order_Amount__c,PersonalContactType__c,OptinNewsletter1__c,OptinNewsletter2__c,Email__c,Birthdate__c,BrandsPreference__c,ProductsPreference__c,Customer__c,Hostess__c,Dealer_prospect__c,Customer_prospect__c,Competitive_dealer__c,Hostess_prospect__c,OtherPersonalContactType__c,Competitive_hostess__c,CreatedDate   FROM PCT_PersonalContact__c   where OwnerId=:userId ';
        string selectiveQueryPart='';
       if(theOption.contains('#1#')){
            selectiveQueryPart = ' and Customer__c=true ';
        }else if(theOption.contains('#2#')){
            selectiveQueryPart = ' and Customer_prospect__c=true ';
        }else if(theOption.contains('#3#')){
            selectiveQueryPart = ' and Dealer_prospect__c=true ';
        }else if(theOption.contains('#4#')){
            selectiveQueryPart = ' and Competitive_dealer__c=true ';
        }else if(theOption.contains('#5#')){
            selectiveQueryPart = ' and Hostess__c=true ';
        }else if(theOption.contains('#6#')){
            selectiveQueryPart = ' and Hostess_prospect__c=true ';
        }else if(theOption.contains('#7#')){
            selectiveQueryPart = ' and OtherPersonalContactType__c=true ';
        }else if(theOption.contains('#8#')){
            selectiveQueryPart = ' and Competitive_hostess__c=true ';
        }else if(theOption.contains('#9#')){
            selectiveQueryPart = ' and BrandsPreference__c includes(\'Stanhome\') ';
        }else if(theOption.contains('#10#')){
            selectiveQueryPart = ' and BrandsPreference__c includes(\'Kiotis\') ';
        }else if(theOption.contains('#11#')){
            selectiveQueryPart = ' and Last_order_date__c=THIS_MONTH ';
        }else if(theOption.contains('#12#')){
            selectiveQueryPart = ' and Last_order_date__c=LAST_MONTH ';
        }else if(theOption.contains('#13#')){
            selectiveQueryPart = ' and Last_order_date__c<LAST_N_DAYS:60 ';
        }else if(theOption.contains('#14#')){
            selectiveQueryPart = ' and OptinNewsletter1__c = true ';
        }else if(theOption.contains('#15#')){
            selectiveQueryPart = ' and OptinNewsletter2__c = true ';
        }else if(theOption.contains('#16#')){
            selectiveQueryPart = ' and PersonalContactType__c = \'Digital Customer\' ';
        }

        system.debug('## Class VFP01_PersonalContactListView - function generateQuery theOption:<<<<<'+theOption+' Query:'+theQuery+selectiveQueryPart+'  order by Id desc');
        return (theQuery+selectiveQueryPart+'  order by Id desc');
    }

      /*****************************************************************/
    /************************ RedirectStatement **********************/
    /*****************************************************************/
    public List<string> getFieldLabel(List<string> theFieldNames) {
        system.debug('## Class VFP01_PersonalContactListView - getFieldLabel <<<<<'+UserInfo.getUserName());
        
        String type= 'PCT_PersonalContact__c'; 
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        list<string> fieldNamesNeeded= new list<string>();
        for (string fieldNameSent : theFieldNames){
            for(String fieldName: fieldMap.keySet()) {
                 if(fieldName==fieldNameSent){
                    fieldNamesNeeded.add(fieldMap.get(fieldName).getDescribe().getLabel());
                 }
            }
       }
       return fieldNamesNeeded;
    }
    /*****************************************************************/
    /************************ Create New Statement for Managers ****/
    /****************************************************************
    public PageReference newStatementManagers() {
        system.debug('## Class VFP31_PaymentByChequeListView - START newStatementManagers <<<<<'+UserInfo.getUserName());
        PageReference pageRef;
        pageRef = Page.VFP31_PaymentByChequeManagers;
        system.debug('>>>>>> pageRef: ' + pageRef);
        return PageRef;
    }*/
    public string getNumberCurrencyFormat(){
        System.debug('getNumberCurrencyFormat >>>>>>>'+Userinfo.getLocale());
        if(Userinfo.getLocale().equalsIgnoreCase('es_MX')){
                return 'MXN{0, number, 0.00}';
        }else if(Userinfo.getLocale().equalsIgnoreCase('es_VE')){
                return 'VEF{0, number, 0.00}';
        }else{
            return '€{0, number, 0.00}';
        }
    }
}