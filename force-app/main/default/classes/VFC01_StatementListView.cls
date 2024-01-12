public with sharing class VFC01_StatementListView{
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
    //Global String
    public String userId {get;set;}
    public String userType {get;set;}
    
    /*****************************************************************/
    /******************** Page Constructor ***************************/
    /*****************************************************************/
    public VFC01_StatementListView (){
        system.debug('## Class VFC01_StatementListView - START VFC01_StatementListView <<<<<'+UserInfo.getUserName()); 
    
        //Retrieving User ID, USer Type
        userId = UserInfo.getUserId();
        userType = UserInfo.getUserType();
        
        //Checks if Portal User
        CheckUser(userType, userId);
        
        system.debug('## Class VFC01_StatementListView - END VFC01_StatementListView <<<<<'+UserInfo.getUserName());
    }
    
    /*****************************************************************/
    /*********************** CheckUser *******************************/
    /*****************************************************************/
    public void CheckUser(String userType, String userId){
        system.debug('## Class VFC01_OrderRecipient - START CheckUser <<<<<'+UserInfo.getUserName());
        
        User u = [SELECT Profile.Name, Contact.Title FROM User WHERE Id =: userId LIMIT 1];
        
        //Checks if Portal User
        if (userType == 'CspLitePortal' || (u.Profile.Name.contains('DEALER_MEMBER') || u.Profile.Name.contains('DEALER_LOGIN') || 
                                            u.Profile.Name.contains('SMILE_LOGIN') || u.Profile.Name.contains('SMILE_MEMBER')) 
                                        || (( u.Profile.Name.contains('DEALER_MANAGER') || u.Profile.Name.contains('DEALER_NEW_MANAGER')) &&  u.Contact != null && u.Contact.Title == 'Conseillère') 
                                        || (u.Profile.Name.startswith('ITA_LU') && u.Profile.Name.contains('DEALER_MANAGER') ) ) {
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
            Id statementRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = 'Statement' and SObjectType = 'STA_Statement__c' Limit 1].id;
            
            if(statementSet == null) {
                if (isPortal){
                    statementSet = new  ApexPages.StandardSetController(Database.getQueryLocator(
                                      [SELECT Id,Name, TransType__c, TransDate__c, TransDesc__c, TransDebit__c, TransCredit__c, Contact__r.Name
                                         FROM STA_Statement__c
                                        WHERE Contact__c = :contactId
                                        and recordTypeId =: statementRecordTypeID
                                        order by CreatedDate desc]));
                }
                else {
                    statementSet = new  ApexPages.StandardSetController(Database.getQueryLocator(
                                      [SELECT Id,Name, TransType__c, TransDate__c, TransDesc__c, TransDebit__c, TransCredit__c, Contact__r.Name
                                         FROM STA_Statement__c
                                         where recordTypeId =: statementRecordTypeID
                                         order by CreatedDate desc]));
                }
            }
        statementSet.setPageSize(1000); 
        return statementSet;
        }
        set;
    }
    
    public List<STA_Statement__c> getStatements(){
        return (List<STA_Statement__c>) statementSet.getRecords();
    }
     public string getNumberCurrencyFormat(){
    System.debug('getNumberCurrencyFormat >>>>>>>'+Userinfo.getLocale());
    if(Userinfo.getLocale().equalsIgnoreCase('fr_FR_EURO')){
        
        //return '€{0, number, ###.###,00}';
        return '€{0, number, 0.00}';
        
    }else if(Userinfo.getLocale().equalsIgnoreCase('es_MX')){
            return 'MXN{0, number, 0.00}';
      }else if(Userinfo.getLocale().equalsIgnoreCase('es_VE')){
            return 'VEF{0, number, 0.00}';
      }else{
        
        return '€{0, number, 0.00}';
    }
    
  }
}