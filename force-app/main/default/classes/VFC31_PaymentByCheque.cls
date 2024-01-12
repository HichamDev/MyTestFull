/* 
----------------------------------------------------------------------
-- - Name          : VFC31_PaymentByCheque 
-- - Author        :    
-- - Description   : Controller for VFC31_PaymentByCheque Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ----------------------------------------
-- 11-NOV-2013         1.0      Initial version 
-- 25-NOV-2013  JBO    2.0      Implementation of the Cheque Interface  
-----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class VFC31_PaymentByCheque 
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
    
    public STA_Statement__c pc {get; set;}
    
    public static String CHEQUE_PAYEMENT = 'Cheque';
    
    public boolean userCurrencyFormatEuro {get;set;}
  

    /******************************************************************/
    /******************** Page Constructors ***************************/
    /******************************************************************/
    public VFC31_PaymentByCheque(ApexPages.StandardController controller)
    {
        system.debug('## Class VFC31_PaymentByCheque - START VFC31_PaymentByCheque <<<<<'); 

        //Checks if Portal User
        CheckUser();
        
        retrieveRecordType();
        
        //set statusSaved to false
        statusSaved=false;
        
        //set userCurrencyFormatEuro=true;
        userCurrencyFormatEuro=true;
        string dummyFormat=getNumberCurrencyFormat();
        
        try
        {
            // Retrieve the record
            Id idSta= getId();
            
            if(idSta != null){
                //edit mode
                this.pc = getExistingStatement(idSta);
                isEdit = true;
            }else{
                //new 
                this.pc = (STA_Statement__c) controller.getRecord();
                isEdit = false;
            }

            system.debug('## Constructor VFC31_PaymentByCheque - controller.getRecord()' + pc);   
               
            
        } catch (Exception e){
            ApexPages.addMessages(e);
        }
        system.debug('## Class VFC31_PaymentByCheque - END VFC31_PaymentByCheque <<<<<');
    }
    
     public VFC31_PaymentByCheque()
    {
        system.debug('## Class VFC31_PaymentByCheque - START VFC31_PaymentByCheque <<<<<'); 

        //Checks if Portal User
        CheckUser();
        
        retrieveRecordType();
        
        //set statusSaved to false
        statusSaved=false;
        
        try
        {
            // Retrieve the record
            Id idSta= getId();
            
            if(idSta != null){
                //edit mode
                this.pc = getExistingStatement(idSta);
                isEdit = true;
            }else{
                //new 
                this.pc = new STA_Statement__c() ;
                isEdit = false;
            }

            system.debug('## Constructor VFC31_PaymentByCheque - controller.getRecord()' + pc);   
               
            
        } catch (Exception e){
            ApexPages.addMessages(e);
        }
        system.debug('## Class VFC31_PaymentByCheque - END VFC31_PaymentByCheque <<<<<');
    }
   

    /*
    * Command Button : New Form for Dealer
      
    public PageReference savePaymentByChequeAndNew() 
    {
        try
        {
            // Set the Contact
            this.pc.Contact__c = this.contactId;

            // Set the record type 'Cheque'
           
            this.pc.RecordTypeId = recordTypeCheque;
            
            // Insert the cheque payment    
            upsert (this.pc);
            
            // Send the user to the detail page for the new payment by cheque
            PageReference pbcPage = Page.VFP31_PaymentByChequeNew;
            pbcPage.setRedirect(true);
            return (pbcPage);
                                       
        }catch(Exception e)
        {
            ApexPages.addMessages(e);
        }  
    
        return (null);
    }*/
    
    /*
    * Command Button : New and New  for Dealer
    
    public PageReference savePaymentByCheque() 
    {
        try
        {
            // Set the Contact
            this.pc.Contact__c = this.contactId;

            // Set the record type 'Cheque'
            this.pc.RecordTypeId = recordTypeCheque;
            
            // Insert the cheque payment    
            upsert(this.pc);
            
            // Send the user to the detail page for the new payment by cheque
            PageReference pbcPage = new ApexPages.StandardController(this.pc).view();
            pbcPage.setRedirect(true);
            return (pbcPage);
                                       
        }catch(Exception e)
        {
            ApexPages.addMessages(e);
        }  
    
        return (null);
    }*/
    
    public PageReference cancel() 
    {
        try
        {
            PageReference pageRef = Page.VFP31_PaymentByChequeListView;
            return pageRef;
        } catch (Exception e)
        {
            ApexPages.addMessages(e);          
        }
        
        return (null);
    }
    
    /**
    ** List View*/
       
    public List<STA_Statement__c> getChequePayments() 
    {
        try
        {
            Id rtId = [SELECT Id
                       FROM RecordType
                       WHERE Name = 'Cheque'
                       LIMIT 1].Id;

            List<STA_Statement__c> lPaymentCheque = [SELECT Id,STHID__c,Label_1__c,Status__c,TECH_ExternalId__c,Contact__c,TECH_BO_ExtractionStatus__c,TECH_BO_ExtractionMessage__c,TECH_BO_ExtractionDate__c, Cheque_Date__c, Cheque_Number__c, Cheque_Amount__c, Comments__c, CreatedDate
                                                     FROM STA_Statement__c
                                                     WHERE RecordTypeId =: rtId
                                                     AND Contact__c =: this.contactId
                                                     ORDER BY CreatedDate desc];
            
            return (lPaymentCheque);
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
    
    public Boolean getisAllowedToPayByCheque()
    {
        try
        {
            // Retrieve the filed AllowedPaymenMode of the Contact
            Contact c = [SELECT AllowedPaymentMode__c
                         FROM Contact
                         WHERE Id =: this.contactId
                         LIMIT 1];
            if (c.AllowedPaymentMode__c != null && c.AllowedPaymentMode__c != '' && c.AllowedPaymentMode__c.indexOf(CHEQUE_PAYEMENT) > -1)
            {    
                   return (true);
                
            }
        } catch (Exception e)
        {
            ApexPages.addMessages(e);        
        }
        
        return (false);
    }

    /**
    ** Display tools
    **/  
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
    
    public PageReference ChangeDealerDetails()
    {        
        System.debug('##  START ChangeDealerDetails' );
        
        System.debug('##  ChangeDealerDetails sthid >>>>> '+sthid);
        
       

        List<Contact> listContact = [SELECT Id, AllowedPaymentMode__c 
                                     FROM Contact 
                                     where STHID__c = : sthid 
                                     limit 1];
                                     
        
        if (listContact != null && listContact.size() > 0)
        {
        	System.debug('##  listContact  >>>>> '+listContact);
            
            System.debug('##  listContact  >>>>> '+this);
            
            this.pc.Contact__c = listContact[0].Id;
            
            System.debug('##  allowedPaymentMode  >>>>> '+listContact[0].AllowedPaymentMode__c);
            
            // Check of the Contact selected is allowed to pay by cheque. Display an error on the contact field otherwise.
            Boolean allowed = false;
            
            
            if(listContact[0].AllowedPaymentMode__c != null){
	            String allowedPaymentMode = listContact[0].AllowedPaymentMode__c ;

				System.debug('##  AllowedPaymentMode__c.split '+allowedPaymentMode );
				
				if(allowedPaymentMode.indexOf(CHEQUE_PAYEMENT) > -1){
					
					allowed = true;	
				}
	            
            }
            if (!allowed)
	            this.pc.Contact__c.addError(System.Label.STA00018);
            
        }
      	system.debug('##  END ChangeDealerDetails' );
        return (null);
    }
    
   
    
  /**
  * Retrieve user contact
 
  private  Contact getConnectedUserContact()
  {
    
    
        Contact c = new Contact();
        
        User user = [select id, TECH_MergeContactID__c from user where id =: Userinfo.getUserId() limit 1];
        
        system.debug('>>>>>>>>>>>>> getConnectedSFDUserContact TECH_ContactID__c : '+ user.TECH_MergeContactID__c);
         
        if(user.TECH_MergeContactID__c  != null)
        {
            system.debug('>>>>>>>>>>>>> getConnectedSFDUserContact TECH_ContactID__c is not null: '+ user.TECH_MergeContactID__c);
            List<Contact> listContact = [select ID 
                        ,Name
                        ,STHID__c

                from Contact where id = : user.TECH_MergeContactID__c limit 1];
        
            if(listContact != null && listContact.size() > 0)
            {    
                c = listContact[0];
            }
            else
            {
                c = null;
            }
    
        }
        else
        {
            c= null;
        }
        
        return c;
    } */
    
    private PageReference saveOnly(PageReference pbcPage, boolean isSaveAndNew){
        
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
    }
    
    
    /**
    * Button form Save for Manager
    */
    public PageReference savePaymentByChequeManagers() 
    {
        statusSaved=true;
        
         PageReference pbcPage = Page.VFP31_PaymentByChequeView;
        
         return saveOnly(pbcPage, false);
    }
    
    /**
    * Button form Save and new for Manager
    */
    public PageReference savePaymentByChequeAndNewManagers() 
    {
       PageReference pbcPage = Page.VFP31_PaymentByChequeManagers;
        
       return saveOnly(pbcPage, true);
    }
    
    
    /**
    * Link edit for listView
    */
    public PageReference editPaymentByChequeManagers(){     
            
            PageReference pbcPage = Page.VFP31_PaymentByChequeManagers;
            
            pbcPage.getParameters().put('Id', getId());
            
            pbcPage.setRedirect(true);
            
            return (pbcPage);
    }
    
    /**
    * Button form Save and new for Manager
    */
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
    
    
    
    
    private void retrieveRecordType(){
        
         recordTypeCheque = [SELECT Id
                         FROM RecordType
                         WHERE Name = 'Cheque'
                         LIMIT 1].Id;
    }
    
   private STA_Statement__c getExistingStatement(Id id){
        
        List<STA_Statement__c> stas = [SELECT Id,STHID__c,Label_1__c,Status__c,TECH_ExternalId__c,Contact__c,TECH_BO_ExtractionStatus__c,TECH_BO_ExtractionMessage__c,TECH_BO_ExtractionDate__c, Cheque_Date__c, Cheque_Number__c, Cheque_Amount__c, Comments__c, CreatedDate
                                                     FROM STA_Statement__c
                                                     WHERE Id =: id];
                                                     
        if(stas != null && stas.size() > 0)                                             
            return stas[0];                                             
        else
            return null;
    }
    
    
    private Id getId(){
      
      Id sta = System.currentPagereference().getParameters().get('Id');
      
      system.debug('## Class VFC31_PaymentByCheque -existingStatementId <<< ' + sta);
      
      return sta;

     
    }
}