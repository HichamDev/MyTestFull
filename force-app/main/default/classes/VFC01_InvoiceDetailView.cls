/* 
----------------------------------------------------------------------
-- - Name          : VFC01_InvoiceDetailView 
-- - Author        :    
-- - Description   : Controller for VFC01_InvoiceDetailView Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ----------------------------------------
-- 07-MAY-2014  WCH    1.0      Initial version 
-----------------------------------------------------------------------
************************************************* *********************
*/
public with sharing class VFC01_InvoiceDetailView 
{
    //Global Boolean
    public Boolean isPortal {get;set;}
    
    public boolean isEdit {get; set;}
    
    public boolean statusSaved {get; set;}
    
    //Global Id
    public Id contactId {get;set;}
    
    public String userId {get;set;}
    
    public String userType {get;set;}
    
    public String sthid {get; set;}
    
    public Id recordTypeCheque {get; set;}
    
    public INV_Invoice__c theInvoice {get; set;}
    
    public List<INO_InvoiceOrder__c> theInvoiceOrderList {get; set;}
    
    public List<string> theInvoiceAttachmentNoteIdList {get; set;}
    
    public List<string> theInvoiceAttachmentNoteTitleList {get; set;}
    
    public List<string> theInvoiceAttachmentNoteTypeList {get; set;}
    
    public static String CHEQUE_PAYEMENT = 'Cheque';
  

    /******************************************************************/
    /******************** Page Constructors ***************************/
    /******************************************************************/
    public VFC01_InvoiceDetailView(ApexPages.StandardController controller)
    {
        system.debug('## Class VFC01_InvoiceDetailView - START VFC01_InvoiceDetailView <<<<<'); 

        //Checks if Portal User
        CheckUser();
        
        //set statusSaved to false
        statusSaved=false;
        
        try
        {
            // Retrieve the record
            Id invId= getId();
            
            if(invId != null){
                //edit mode
                this.theInvoice = getExistingInvoice(invId);
                this.theInvoiceOrderList=getExistingInvoiceOrders(invId);
                isEdit = true;
            }else{
                //new 
                this.theInvoice = (INV_Invoice__c) controller.getRecord();
                isEdit = false;
            }

            system.debug('## Constructor VFC01_InvoiceDetailView - controller.getRecord()' + theInvoice);   
               
            
        } catch (Exception e){
            ApexPages.addMessages(e);
        }
        system.debug('## Class VFC01_InvoiceDetailView - END VFC01_InvoiceDetailView <<<<<');
    }
    
     public VFC01_InvoiceDetailView()
    {
        system.debug('## Class VFC01_InvoiceDetailView - START VFC01_InvoiceDetailView <<<<<'); 

        //Checks if Portal User
        CheckUser();
        
        //set statusSaved to false
        statusSaved=false;
        
        try
        {
            // Retrieve the record
            Id invId= getId();
            
            if(invId != null){
                //edit mode
                this.theInvoice = getExistingInvoice(invId);
                isEdit = true;
            }else{
                //new 
                this.theInvoice = new INV_Invoice__c() ;
                isEdit = false;
            }

            system.debug('## Constructor VFC01_InvoiceDetailView - controller.getRecord()' + theInvoice);   
               
            
        } catch (Exception e){
            ApexPages.addMessages(e);
        }
        system.debug('## Class VFC01_InvoiceDetailView - END VFC01_InvoiceDetailView <<<<<');
    }
   

  public PageReference cancel() 
    {
        try
        {
            PageReference pageRef = Page.VFP01_InvoiceListView_Ven;
            return pageRef;
        } catch (Exception e)
        {
            ApexPages.addMessages(e);          
        }
        
        return (null);
    }
    
   /**
    ** Controls
    **/
    public void CheckUser()
    {
        system.debug('## Class VFC01_OrderRecipient - START CheckUser <<<<<'+UserInfo.getUserName());
      
        //Retrieving User ID, USer Type
        userId = UserInfo.getUserId();
        userType = UserInfo.getUserType();
      
        //Checks if Portal User
        if (userType == 'CspLitePortal')
        {
            isPortal = true;
      
            //Retrieving Contact ID related to user
            contactId = [Select contactID
                        From User
                        Where id = :userId
                        limit 1].contactID;
        }
        else
        {
            isPortal = false;
            
        }
        
    } 
        /*private PageReference saveOnly(PageReference pbcPage, boolean isSaveAndNew){
        
        try {
            // Set the record type 'Cheque'
             
            this.pc.RecordTypeId = recordTypeCheque;
            
            boolean isError = false;
            
            if(this.pc.Contact__c==null)
            {
                this.pc.Contact__c.addError(System.Label.STA00019);
                system.debug('##  saveOnly this.pc.Contact__c <<< ' + this.pc.Contact__c);
                isError = true;
            }
            
            if(this.pc.Cheque_Amount__c==null || (String.valueOf(this.pc.Cheque_Amount__c)).isNumeric()==true || this.pc.Cheque_Amount__c<=0)
            {
                this.pc.Cheque_Amount__c.addError(System.Label.STA00020);
                 system.debug('##  saveOnly Cheque_Amount__c <<< ' + this.pc.Cheque_Amount__c);
                isError = true;
            }
            
            if(this.pc.Cheque_Date__c==null)
            {
                this.pc.Cheque_Date__c.addError(System.Label.STA00021);
                system.debug('##  saveOnly Cheque_Date__c <<< ' + this.pc.Cheque_Date__c);
                isError = true;
            }
            
            system.debug('##  saveOnly isError <<< ' + isError);
            
            // Insert the cheque payment    
            if(!isError)
            {
                 upsert pc;
                
                // Send the user to the detail page for the new payment by cheque
                
                if(! isSaveAndNew){
                    system.debug('## Class VFC31_PaymentByCheque StatementId <<< ' + pc.id);
                    pbcPage.getParameters().put('Id', pc.id);
                }else{
                    pbcPage.setRedirect(true);
                    pbcPage.getParameters().put('Id', null);
                }   
                return (pbcPage);
            }
            

            return null;  
                                       
        }catch(Exception e)
        {
            ApexPages.addMessages(e);
            
        }  
    
        return (null);
    }*/
    
    /**
    ** Display tools
    **/  
    public string getNumberCurrencyFormat()
    {
        System.debug('getNumberCurrencyFormat >>>>>>>'+Userinfo.getLocale());
        if(Userinfo.getLocale().equalsIgnoreCase('fr_FR_EURO'))
        {
            return ('€{0, number, 0.00}');
        
        } else
        {
            return ('€{0, number, 0.00}');
        }   

    }
    
    /**
    * Button form Save for Manager
    
    public PageReference savePaymentByChequeManagers() 
    {
        statusSaved=true;
        
         PageReference pbcPage = Page.VFP31_PaymentByChequeView;
        
         return saveOnly(pbcPage, false);
    }
    
    /**
    * Button form Save and new for Manager
    
    public PageReference savePaymentByChequeAndNewManagers() 
    {
       PageReference pbcPage = Page.VFP31_PaymentByChequeManagers;
        
       return saveOnly(pbcPage, true);
    }
    
    
    /**
    * Link edit for listView
    
    public PageReference editPaymentByChequeManagers(){     
            
            PageReference pbcPage = Page.VFP31_PaymentByChequeManagers;
            
            pbcPage.getParameters().put('Id', getId());
            
            pbcPage.setRedirect(true);
            
            return (pbcPage);
    }
    
    /**
    * Button form Save and new for Manager
    
    public PageReference deletePaymentByChequeManagers(){
    
        try
        {
            STA_Statement__c sta = [select id from STA_Statement__c where Id =: getId()];
            
            delete sta;
        
            PageReference pageRef = Page.VFP31_PaymentByChequeListView;
            
            return pageRef;
        
        
        } catch (Exception e)
        {
            ApexPages.addMessages(e);          
        }
        
        return (null);
    }
    */
   
   @TestVisible private INV_Invoice__c getExistingInvoice(Id id){
        
        List<INV_Invoice__c> invoiceList = [Select
                            Dealer__c
                            ,Dealer__r.Name
                            ,TotalPriceExclusiveOfTax__c
                            ,TotalTransportFees__c
                            ,Subtotal1__c
                            ,Subtotal2__c
                            ,Subtotal3__c
                            ,Subtotal4__c
                            ,Tax__c
                            ,TotalPriceAllTaxIncluded__c
                            ,Tax1Amt__c
                            ,Tax2Amt__c
                            ,Tax3Amt__c
                            ,Tax4Amt__c
                            ,OriginOrderType__c
                            ,InvoiceDate__c
                            ,Total__c
                            ,InvoiceNumber__c
                            ,PaymentDate__c
                            ,InvoicingStreet__c
                            ,InvoicingCountry__c
                            ,InvoicingZipCode__c
                            ,InvoicingState__c
                            ,InvoicingProvince__c
                            ,InvoicingCity__c
                            ,(SELECT Id,Title,createddate,createdbyid,body FROM Notes)
                            ,(SELECT Id,Name,createddate,createdbyid FROM Attachments)
                         From INV_Invoice__c 
                         where Id =: id];
                                           
        if(invoiceList != null && invoiceList.size() > 0) {     
        	                                    
            return invoiceList[0];  
        }                                           
        else{
            return null;
        }
    }
    
    @TestVisible private List<INO_InvoiceOrder__c> getExistingInvoiceOrders(Id id){
        
        List<INO_InvoiceOrder__c> invoiceOrdersList = [Select
        					Id
                            ,Name
                         From INO_InvoiceOrder__c 
                         where Invoice__c =: id];
                                                     
        if(invoiceOrdersList != null && invoiceOrdersList.size() > 0)                                             
            return invoiceOrdersList;                                             
        else
            return null;
    }
    
    
    @TestVisible private Id getId(){
      
      Id theInvoiceId = System.currentPagereference().getParameters().get('Id');
      
      system.debug('## Class VFC01_InvoiceDetailView -theInvoiceId <<< ' + theInvoiceId);
      
      return theInvoiceId;

     
    }
}