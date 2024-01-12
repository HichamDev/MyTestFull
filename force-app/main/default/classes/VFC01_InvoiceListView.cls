public with sharing class VFC01_InvoiceListView {

/* 
----------------------------------------------------------------------
-- - Name          : VFC01_InvoiceListView 
-- - Author        : NGO
-- - Description   : Controller for VFC01_InvoiceListView Page
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
    public Id invoiceId {get;set;}
    //Global String
    public String userId {get;set;}
    public String userType {get;set;}
    
    /*****************************************************************/
    /******************** Page Constructor ***************************/
    /*****************************************************************/
    public VFC01_InvoiceListView (){
        system.debug('## Class VFC01_InvoiceListView - START VFC01_InvoiceListView <<<<<'+UserInfo.getUserName()); 
    
        //Retrieving User ID, USer Type
        userId = UserInfo.getUserId();
        userType = UserInfo.getUserType();
        
        //Checks if Portal User
        CheckUser(userType, userId);
        
        system.debug('## Class VFC01_InvoiceListView - END VFC01_InvoiceListView <<<<<'+UserInfo.getUserName());
    }
    
    /*****************************************************************/
    /*********************** CheckUser *******************************/
    /*****************************************************************/
    public void CheckUser(String userType, String userId) {
        system.debug('## Class VFC01_InvoiceListView - START CheckUser <<<<<'+UserInfo.getUserName());
        
        User u = [SELECT Profile.Name, Contact.Title FROM User WHERE Id =: userId LIMIT 1];
        
        //Checks if Portal User
        if (userType == 'CspLitePortal' || (u.Profile.Name.contains('DEALER_MEMBER') || u.Profile.Name.contains('DEALER_LOGIN') || 
                                            u.Profile.Name.contains('SMILE_LOGIN') || u.Profile.Name.contains('SMILE_MEMBER')) 
                                        || ((u.Profile.Name.contains('DEALER_MANAGER') || u.Profile.Name.contains('DEALER_NEW_MANAGER') ) &&  u.Contact != null && u.Contact.Title == 'Conseillère') 
                                        || (u.Profile.Name.startswith('ITA_LU') && u.Profile.Name.contains('DEALER_MANAGER') )) {
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
    public ApexPages.StandardSetController invoiceSet {   
        get {
            
           
            if(invoiceSet == null) {
                if (isPortal){
                    invoiceSet = new  ApexPages.StandardSetController(Database.getQueryLocator(
                                      [SELECT Id,Name, InvoiceNumber__c,Dealer__c,Status__c,InvoiceType__c,InvoiceDate__c, Dealer__r.Name,CodifFiscale__c,Subtotal1__c,Tax__c,Total__c
                                         FROM INV_Invoice__c
                                        WHERE Dealer__c = :contactId
                                        order by CreatedDate desc]));
                }
                else {
                    invoiceSet = new  ApexPages.StandardSetController(Database.getQueryLocator(
                                      [SELECT Id,Name,InvoiceNumber__c,Dealer__c,Status__c,InvoiceType__c,InvoiceDate__c, Dealer__r.Name,CodifFiscale__c,Subtotal1__c,Tax__c,Total__c
                                         FROM INV_Invoice__c
                                         order by CreatedDate desc limit 30]));
                }
            }
        invoiceSet.setPageSize(1000); 
        return invoiceSet;
        }
        set;
    }
    
    public List<INV_Invoice__c> getInvoice(){
        return (List<INV_Invoice__c>) invoiceSet.getRecords();
    }
    public List<INV_Invoice__c> getVenInvoice(){
        ApexPages.StandardSetController invoiceSetVen = new  ApexPages.StandardSetController(Database.getQueryLocator(
                                      [SELECT Id,Name,InvoiceNumber__c,Dealer__c,Status__c,InvoiceType__c,InvoiceDate__c, Dealer__r.Name,CodifFiscale__c,Subtotal1__c,Tax__c,Total__c
                                         FROM INV_Invoice__c
                                         WHERE InvoicingCountry__c='Venezuela' and Dealer__r.AccountCountryCode__c='VEN'
                                         order by CreatedDate desc limit 1000]));
                                         System.debug('getVenInvoice>>>>>>>');
                                         invoiceSetVen.setPageSize(1000);
        return (List<INV_Invoice__c>) invoiceSetVen.getRecords();
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
  
    /*****************************************************************/
    /************************ Redirect to invoice detail *************/
    /*****************************************************************/
    public PageReference RedirectInvoiceDetail() {
        system.debug('## Class VFP01_InvoiceListView - START RedirectInvoiceDetail <<<<<'+UserInfo.getUserName());
        PageReference pageRef;
        
        pageRef = Page.VFP01_InvoiceDetailView;
        pageRef.getParameters().put('Id',invoiceId);

        system.debug('>>>>>> pageRef: ' + pageRef);
        return PageRef;
    }
  
}