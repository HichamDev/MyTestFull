public with sharing class VFC31_PaymentByChequeListView {
/* 
----------------------------------------------------------------------
-- - Name          : VFC01_StatementListView 
-- - Author        : NGO
-- - Description   : Controller for VFP01_StatementListView Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 25-OCT-2013  NGO    1.0      Initial version   
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
    public Id statementId {get;set;}
    //Global String
    public String statementStatus {get;set;}
    public String userId {get;set;}
    public String userType {get;set;}
    public boolean userCurrencyFormatEuro {get;set;}
    
    /*****************************************************************/
    /******************** Page Constructor ***************************/
    /*****************************************************************/
    public VFC31_PaymentByChequeListView (){
        system.debug('## Class VFC01_StatementListView - START VFC01_StatementListView <<<<<'+UserInfo.getUserName()); 
    
        //Retrieving User ID, USer Type
        userId = UserInfo.getUserId();
        userType = UserInfo.getUserType();
        
        //Checks if Portal User
        CheckUser(userType, userId);
        
        //set userCurrencyFormatEuro=true;
        userCurrencyFormatEuro=true;
        string dummyFormat=getNumberCurrencyFormat();
        system.debug('## Class VFC01_StatementListView - END VFC01_StatementListView <<<<<'+UserInfo.getUserName());
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
            contactId = [Select contactID
                           From User
                          Where id = :userId
                          limit 1].contactID;
        }
        else{
            isPortal = false;
        }
    }
    
    /*****************************************************************/
    /******************** ControllerSet Init *************************/
    /*****************************************************************/
    public ApexPages.StandardSetController statementSet {   
        get {
            
            //Retrieving Record Type related to Article
            //Offer
            Id chequeRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = 'Cheque' and SObjectType = 'STA_Statement__c' Limit 1].id;
            
            if(statementSet == null) {
               
                   statementSet = new  ApexPages.StandardSetController(Database.getQueryLocator(
                                      [SELECT  Id,Name, STHID__c, Label_1__c, Status__c, TECH_ExternalId__c, Contact__r.Name,
                                       Cheque_Date__c, Cheque_Number__c, Cheque_Amount__c, Comments__c, CreatedDate
                                         FROM STA_Statement__c
                                         where recordTypeId =: chequeRecordTypeID
                                         order by Cheque_Date__c desc limit 1000]));
            }
        statementSet.setPageSize(1000); 
        return statementSet;
        }
        set;
    }
    
    public List<STA_Statement__c> getStatements(){
        return (List<STA_Statement__c>) statementSet.getRecords();
    }

      /*****************************************************************/
    /************************ RedirectStatement **********************/
    /*****************************************************************/
    public PageReference RedirectStatement() {
        system.debug('## Class VFP31_PaymentByChequeListView - START RedirectStatement <<<<<'+UserInfo.getUserName());
        PageReference pageRef;
        
        pageRef = Page.VFP31_PaymentByChequeView;
        pageRef.getParameters().put('Id',statementId);

        system.debug('>>>>>> pageRef: ' + pageRef);
        return PageRef;
    }
    /*****************************************************************/
    /************************ Create New Statement for Managers ****/
    /*****************************************************************/
    public PageReference newStatementManagers() {
        system.debug('## Class VFP31_PaymentByChequeListView - START newStatementManagers <<<<<'+UserInfo.getUserName());
        PageReference pageRef;
        pageRef = Page.VFP31_PaymentByChequeManagers;
        system.debug('>>>>>> pageRef: ' + pageRef);
        return PageRef;
    }
    public string getNumberCurrencyFormat(){
        userCurrencyFormatEuro=true;
    System.debug('getNumberCurrencyFormat >>>>>>>'+Userinfo.getLocale());
    System.debug('getDefaultCurrency() >>>>>>>'+Userinfo.getDefaultCurrency());
    if(Userinfo.getLocale().equalsIgnoreCase('fr_FR_EURO')){
        //return '€{0, number, ###.###,00}';
        return '€{0, number, 0.00}';
    }else if(Userinfo.getLocale().equalsIgnoreCase('es_MX')){
            userCurrencyFormatEuro=false;
            return 'MXN{0, number, 0.00}';
    }else if(Userinfo.getLocale().equalsIgnoreCase('es_VE')){
            userCurrencyFormatEuro=false;
            return 'VEF{0, number, 0.00}';
    }else if(Userinfo.getLocale().equalsIgnoreCase('it_IT')){
            return '€{0, number, 0.00}';
    }else{
        return '€{0, number, 0.00}';
    }
    
  }
}