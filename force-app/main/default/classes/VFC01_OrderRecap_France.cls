public with sharing class VFC01_OrderRecap_France {
   /*
----------------------------------------------------------------------
-- - Name          : VFC01_OrderRecap_France
-- - Author        : AMU
-- - Description   : Controller for VFC01_OrderRecap_France Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 16-OCT-2012  AMU    1.0      Initial version  
-- 11-SEP-2013  HDU    2.0      Rework Version with taxes
----------------------------------------------------------------------
**********************************************************************
*/
    /* ****************************************************************/
    /* **************** Instantiating Global Variable *****************/
    /* ****************************************************************/
    //Global Id
    public Id orderId {get;set;}
    public Id dealerId {get;set;}
    public Id connectedUserContact {get; set;}
    //Global Strings
    public Boolean onCommunity {get;set;}
    public String communityLandingUrl {get;set;}
    public String STHID {get;set;}
    public String contactName {get;set;}
    public Double minOrder {get;set;}
    public String campaign {get;set;}
    public String balanceColor {get;set;}
    public String currencyCode {get;set;}    
    public String currentCommercial {get;set;}
    public String confirmationMsg {get;set;}
    public String orderNumber {get;set;}
    public String deliveryAddress {get;set;}
    public String invoicingAddress {get;set;}
    public String deliveryMode {get;set;}
    public String contactEmail {get;set;}
    public String contactCountry {get;set;}
    public String orderDateString {get;set;}
    public String errorOrderValidatedElsewhere{get;set;}
    public String orderJustValidated {get;set;}
    
      //Global Booleans
    public Boolean badDebt {get;set;}
    public Boolean renderFlag {get;set;}
    public Boolean confMessage {get;set;}
    public Boolean reachCommercialTarget {get;set;}
    public Boolean isCanChooseDealer {get;set;}
    public Boolean orderValidatedElsewhere {get;set;}
    public Boolean displayCGV {get;set;}
    public Boolean containsProfessionalUseLine {get;set;}
    //Global Date
    public Date lastDateToOrder {get;set;}
    public Datetime orderDate {get;set;}
    public Datetime globalOrderLastModifiedDate {get;set;}
    //Global Double
    public Double currentBalance {get;set;}
    public Double NetPriceByHomeCare{get;set;}
    public Double NetPriceByFamilyCare{get;set;}
    public Double NetPriceByBeautyCare {get;set;}
    public Double NetPriceByFlormar {get;set;}
    public Double NetPriceProductsToSale {get;set;}
    //public Double transportfee{get;set;}
    //public Double taxes {get;set;}
    //Global Lists
    public list<ORL_OrderLine__c> orderLineList {get;set;}
    public list<ORL_OrderLine__c> orderChildLineList {get;set;}
    public list<ORL_OrderLine__c> feeLineList {get;set;}
    public list<ORD_Order__c> orderList {get;set;}
    public list<string> lpCodeDisplayed {get; set;}
    //Globals 
    private list<Id> articleslist = new list<Id> ();
    private list<String> catExternalIdlist = new list<String> ();
    public Contact globalContact {get;set;}
    public Boolean isDisplayButton {get;set;}
    ApexPages.Message myMsg {get; set;}
    public ORD_Order__c globalOrder {get;set;}
    
    public string ORDER_LINE_TYPE_MASTER = 'Master';
    
    public string ORDER_LINE_TYPE_PRODUCT = 'Product';
  
    public string ORDER_LINE_TYPE_CHILD = 'Child';
    
    public string ORDER_LINE_TYPE_FEE = 'Fee';
    
    public String ORDER_LINE_PROFESSIONAL_USE = 'Professional Use';

    public List<CAT_Catalog__c> catalogs {get; set;}
   
    public list<VFC01_LoyaltyProgramRecapDTO> loyaltyProgramListRecap {get;set;}
    
    public boolean isOnlineOrder {get;set;}

    public User__c userCustomSettings { get; set; }
    
    public Boolean displayCardPayment {get;set;}
    public Boolean displayValidateOrderBtn {get;set;}
    public String paymentStatus {get;set;}
	
    public String userAgent {get;set;}
    public Boolean isIE {get;set;}

    /* Happy project */
    public Boolean insufficientOrderAmountForLP { get; set; }
    public Set<String> lpToVerifySet { get; set; }

    public Boolean redirectAfterValidate { get; set; }
    
    public VFC01_OrderRecap_France getThis() {
    return this;
  }
  
      /* *************************************************************** */
      /* ******************* Page Constructor ************************** */
      /* *************************************************************** */
    public VFC01_OrderRecap_France(ApexPages.Standardcontroller controller){
      system.debug('## Class VFC01_OrderRecap_France - START VFC01_OrderRecap_France <<<<<'+UserInfo.getUserName());
			
        	userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        isIE = false;
        if (userAgent != null) {
            if (userAgent.contains('Edge') || userAgent.contains('Trident')) {
                isIE = true;
            }
        }	
        
        /* Added for Migration to community */
        Pagereference pageRef = Network.communitiesLanding();
        String network = Network.getNetworkId();
        if (network != null && network != '') {
          this.onCommunity = true;
          this.communityLandingUrl = pageRef.getUrl();
        }
        
        this.displayCardPayment = false;
        
        this.containsProfessionalUseLine = false;
        userCustomSettings = User__c.getInstance();
        
        //Retrieving parameters
        orderId = System.currentPagereference().getParameters().get('orderId');
        dealerId = System.currentPagereference().getParameters().get('dealerId');  
        orderJustValidated = System.currentPagereference().getParameters().get('ojv');  
        system.debug('>>> orderId : ' + orderId);
        //Setting parameters
        ApexPages.currentPage().getParameters().put('Id',orderId); 
        errorOrderValidatedElsewhere = system.label.ORD00173+'<a href="/'+orderId+'">'+system.label.ORD00184+'</a>';
        orderValidatedElsewhere=false;
           
            //Initialising 
            orderLineList = new List<ORL_OrderLine__c>();
            //taxes = 0.0;
            //transportfee = 0.0; 
            //Retrieving Order Information//globalOrder
            string theQuery='Select Id, Name, Dealer__c, CGV__c, Transporter__c, OrderDate__c, Status__c, DeliveryStreet3__c, DeliveryStreet2__c, DeliveryStreet1__c, DeliveryState__c, '+
            'DeliveryProvince__c, DeliveryCountry__c, DeliveryCity__c, DeliveryAddressComment__c , DeliveryZipCode__c, Shipping_Mode_Label__c  '+
            ', PickUpStation_Name__c, PickUpStation_Street1__c, NetPriceProductsToSale__c, PickUpStation_Street2__c, PickUpStation_Street3__c, PickUpStation_PostalCode__c, PickUpStation_City__c, PickUpStation_Country__c'+
            ',InvoicingCity__c,InvoicingCountry__c,InvoicingProvince__c,InvoicingState__c,InvoicingStreet__c,InvoicingZipCode__c,LastModifiedDate,  '+
            'TECH_TotalPrice__c, NumberOrderLines__c,NetPriceByHomeCare__c,NetPriceByFamilyCare__c,NetPriceByBeautyCare__c,Net_Price_By_Flormar__c,TECH_BO_ExtractionStatus__c,Country_Code__c, OrderType__c, CustomerFirstName__c, CustomerLastName__c,CreatedById,Dealer__r.Id,Dealer__r.OwnerId, Dealer__r.AllowedPaymentMode__c , Payment_Transaction_Status__c , PaymentTransactionId__c  '+
            ' From ORD_Order__c Where id = \''+orderId+'\' ';
            List<ORD_Order__c> fetchOrder = database.query(theQuery);
            globalOrder=fetchOrder[0];
            dealerId = globalOrder.Dealer__c;
            


            //retrieve order's last modified date
            globalOrderLastModifiedDate=globalOrder.LastModifiedDate;
            checkIfIsOnlineOrder();
            
            checkIfCanChooseDealer();
            

            // Check if need to display the card payment section
            if (globalOrder.Dealer__c != null && globalOrder.Dealer__r.AllowedPaymentMode__c != null && globalOrder.Dealer__r.AllowedPaymentMode__c.contains('CBP')) {
              this.displayCardPayment = true;
              this.displayValidateOrderBtn = (globalOrder.Payment_Transaction_Status__c == 'Approved' ? true : false);
              system.debug('>>> globalOrder.Payment_Transaction_Status__c: ' + globalOrder.Payment_Transaction_Status__c);
            } else {
              this.displayValidateOrderBtn = true;
            }

            redirectAfterValidate = false;

           for(ORD_Order__c ord : fetchOrder)
           {    
                //set variable reachCommercialTarget
                setReachCT(ord);
                //Checks if Status is Draft
               if (ord.Status__c == SHW_IBZ_Constants.ORDER_STATUS_DRAFT){
                    confMessage = false;
                    
                    //order is in draft mode can be saved
                    
               }else{
                    
                    confMessage = true;
                    if(ord.Status__c.equals(SHW_IBZ_Constants.ORDER_STATUS_DELEGATED)){
                        confirmationMsg = system.label.ORD00197;
                    }else if(ord.Status__c.equals(SHW_IBZ_Constants.ORDER_STATUS_CLOSED)){
                        confirmationMsg = system.label.ORD00198;
                    }else{
                      if(orderJustValidated=='t'){
                        confirmationMsg = system.label.ORD00047;
                        redirectAfterValidate = true;
                      }else{
                        confirmationMsg = system.label.ORD00046;
                      }
                    }
                    
               }
               //set contact country
               contactCountry= ord.Country_Code__c==null ? '_NONE_' : ord.Country_Code__c;
               //set care value
                NetPriceByHomeCare   = ord.NetPriceByHomeCare__c;
                NetPriceByFamilyCare = ord.NetPriceByFamilyCare__c;
                NetPriceByBeautyCare = ord.NetPriceByBeautyCare__c;
                NetPriceProductsToSale = ord.NetPriceProductsToSale__c;
                NetPriceByFlormar = ord.Net_Price_By_Flormar__c;

                /* Happy project */
                lpToVerifySet = new Set<String>();
                for (LP_Statement_Summerize__mdt lpStatementSummerize : [SELECT MasterLabel, QualifiedApiName, Country__c, LP_Name__c, Is_Verified__c 
                                                                        FROM LP_Statement_Summerize__mdt WHERE Country__c = :contactCountry AND Is_Verified__c = true]) {
                  lpToVerifySet.add(lpStatementSummerize.LP_Name__c);
                }
                
                //set detailed information about the order
                orderNumber      = ord.Name;
                orderDate        = ord.OrderDate__c;
                orderDateString  =ord.OrderDate__c.format();//ord.OrderDate__c.format('dd/MM/yy HH:mm a', 'PST');//GMT PST
                if( ord.DeliveryStreet1__c == null || ord.DeliveryStreet1__c == '' || ord.DeliveryZipCode__c == null || ord.DeliveryCity__c == null || ord.DeliveryCountry__c == null ){
                    deliveryAddress = '';
                }else{
                    deliveryAddress  = (ord.DeliveryAddressComment__c==null ? '' : ord.DeliveryAddressComment__c+'<br/>')+(ord.DeliveryStreet1__c==null? '' : ord.DeliveryStreet1__c)+' '+(ord.DeliveryStreet2__c==null? '' : ord.DeliveryStreet2__c)+' '+(ord.DeliveryStreet3__c==null? '' : ord.DeliveryStreet3__c+'<br/>')+(ord.DeliveryZipCode__c==null? '' : ord.DeliveryZipCode__c+' ')+(ord.DeliveryCity__c==null? '' : ord.DeliveryCity__c+'<br/>')+(ord.DeliveryProvince__c==null? '' : ord.DeliveryProvince__c+'<br/>')+(ord.DeliveryState__c==null? '' : ord.DeliveryState__c+'<br/>')+(ord.DeliveryCountry__c==null? '' : ord.DeliveryCountry__c);
                }
                invoicingAddress = (ord.InvoicingStreet__c==null? '' : ord.InvoicingStreet__c+'<br/>')+(ord.InvoicingZipCode__c==null? '' : ord.InvoicingZipCode__c+', ')+(ord.InvoicingCity__c==null? '' : ord.InvoicingCity__c+'<br/>')+(ord.InvoicingProvince__c==null? '' : ord.InvoicingProvince__c+'<br/>')+(ord.InvoicingState__c==null? '' : ord.InvoicingState__c+'<br/>')+(ord.InvoicingCountry__c==null? '' : ord.InvoicingCountry__c);
                deliveryMode     = 'None';
                
           }
           
           orderList = [Select Id
                               ,NumberOrderLines__c
                         From ORD_Order__c
                         Where id = :orderId ];
           
            //Retrieving existing address if any          
            for(Contact c : [Select id
                                               ,Name
                                               ,Title
                                               ,Email
                                               ,STHID__c
                                               ,TECH_campaign__c
                                               ,CurrentBalance__c
                                               ,CurrencyIsoCode
                                               ,BadDebt__c
                                               ,MinOrder__c
                                               ,LastDateToOrder__c
                                               ,CurrentCommercialCycle__c
                                               ,MailingAddressComment__c
                                               ,MailingStreet
                                               ,MailingState
                                               ,MailingPostalCode
                                               ,MailingCountry
                                               ,MailingCity
                                               /* Happy Project */
                                               ,OrderAmountLimitForLp1__c
                                               ,OrderAmountLimitForLp2__c
                                               ,OrderAmountLimitForLp3__c
                                               ,OrderAmountLimitForLp4__c
                                               ,OrderAmountLimitForLp5__c
                                               ,OrderAmountLimitForLp6__c
                                               ,OrderAmountLimitForLp7__c
                                               ,OrderAmountLimitForLp8__c
                                               ,OrderAmountLimitForLp9__c
                                               ,OrderAmountLimitForLp10__c
                                               ,OrderAmountLimitForLp11__c
                                               ,OrderAmountLimitForLp12__c
                                               ,OrderAmountLimitForLp13__c
                                               ,OrderAmountLimitForLp14__c
                                               ,OrderAmountLimitForLp15__c
                                               ,OrderAmountLimitForLp16__c
                                               ,OrderAmountLimitForLp17__c
                                               ,OrderAmountLimitForLp18__c
                                               ,OrderAmountLimitForLp19__c
                                               ,OrderAmountLimitForLp20__c
                                      From Contact
                                     Where id = :dealerId])
          {
            globalContact = c;     

            List<User> listDealerUser = [SELECT Id FROM User WHERE ContactId = :globalContact.Id];
            if (listDealerUser != null && !listDealerUser.isEmpty())
              userCustomSettings = User__c.getInstance(listDealerUser[0].Id);
              displayCGV = userCustomSettings.displayCGV__c;

                  STHID                    = c.STHID__c; 
                  contactName              = c.Name;
                  campaign                 = c.TECH_campaign__c;
                  badDebt                  = c.BadDebt__c;
                  lastDateToOrder    = c.LastDateToOrder__c;
                                               
                  //Balance
                  if (c.CurrentBalance__c < 0){
                        balanceColor = 'red';
                  }
                  else{
                        balanceColor = 'none';
                  }
                  //Balance currency code and check if current balance is not null
                  if (c.CurrentBalance__c <> null){
                        currentBalance = c.CurrentBalance__c;
                  }
                  if(c.CurrencyIsoCode=='EUR'){
                        currencyCode = '€';
                  }
                  else if(c.CurrencyIsoCode=='USD'){
                        currencyCode = '$';
                  }
                  else {
                        currencyCode = c.CurrencyIsoCode == null ? '' : c.CurrencyIsoCode;
                  }
                   //fill header details
                    STHID = c.STHId__c;
                    minOrder = c.MinOrder__c;
                    lastDateToOrder = c.LastDateToOrder__c;
                    currentBalance = c.CurrentBalance__c;
                    currentCommercial = c.CurrentCommercialCycle__c;
                    contactEmail     = c.Email;
                    if(deliveryAddress==''){
                        deliveryAddress = (c.MailingAddressComment__c==null? '' : c.MailingAddressComment__c+'<br/>')+(c.MailingStreet==null? '' : c.MailingStreet+'<br/>')+(c.MailingPostalCode==null? '' : c.MailingPostalCode+'<br/>')+(c.MailingCity==null? '' : c.MailingCity+'<br/>')+(c.MailingState==null? '' : c.MailingState+'<br/>')+(c.MailingCountry==null? '' : c.MailingCountry);
                    }
                  
         }
        
   
         if (badDebt){
              renderFlag = false;
         }
         else{
              renderFlag = true;
         }
         
         /* Happy project */
         insufficientOrderAmountForLP = false;

         //Retrieve all order Lines 
         GetOrderLines();

         if (displayCGV && this.containsProfessionalUseLine == false) {
          displayCGV = false;
         }

         //
         // Initialise loyaltyProgramListRecap from contact 
        
         loyaltyProgramListRecap = loyaltyProgramRecap();
         
         system.debug('## Class VFC01_OrderRecap_France - loyaltyProgramListRecap initialise <<<<<' + loyaltyProgramListRecap);
         
         //Populate credit and debit point for the order from orderlines paid with loyalty program
         AP16_LoyaltyProgramService_France loyaltyService = new AP16_LoyaltyProgramService_France();
         
        //  loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramRecap(orderId, loyaltyProgramListRecap, confMessage); 
         /* Happy project */
         List<VFC01_LoyaltyProgramRecapDTO> loyaltyProgramListRecapTemp = loyaltyService.getLoyaltyProgramRecap(orderId, loyaltyProgramListRecap, confMessage);
         loyaltyProgramListRecap = new List<VFC01_LoyaltyProgramRecapDTO>();
         for (VFC01_LoyaltyProgramRecapDTO lpRecap : loyaltyProgramListRecapTemp) {
            if ( !lpRecap.lpCode.startsWith('L') ||
                globalContact.get('OrderAmountLimitFor' + lpRecap.lpCode + '__c') == null ||
                !lpToVerifySet.contains(lpRecap.lpCode) ||
                (lpRecap.lpCode.startsWith('L') && 
                lpToVerifySet.contains(lpRecap.lpCode) && 
                globalContact.get('OrderAmountLimitFor' + lpRecap.lpCode + '__c') != null && 
                globalOrder.TECH_TotalPrice__c >= (Decimal)globalContact.get('OrderAmountLimitFor' + lpRecap.lpCode + '__c'))) {

               loyaltyProgramListRecap.add(lpRecap);   
            }
          //  ((NOT(BEGINS(lpRecap.lpCode,'L'))) || 
          //   ISNULL(globalContact['OrderAmountLimitFor' + lpRecap.lpCode + '__c']) ||
          //                                                           NOT(CONTAINS(varLpToVerifySet, lpRecap.lpCode)) ||
          //                                                           (CONTAINS(varLpToVerifySet, lpRecap.lpCode) && BEGINS(lpRecap.lpCode,'L') && NOT(ISNULL(globalContact['OrderAmountLimitFor' + lpRecap.lpCode + '__c'])) && basketDetail.totalPriceForValidBase >= globalContact['OrderAmountLimitFor' + lpRecap.lpCode + '__c'])), 'block', 'none')
         }        
         
        //extract taxes from all order line
        list<ORL_OrderLine__c> allOrderLine = new list<ORL_OrderLine__c>();
        allOrderLine.addall(orderLineList);
        allOrderLine.addall(feeLineList);
        for (integer i=0;i<allOrderLine.size();i++){
            if(allOrderLine[i].TECHCatalogExternalId__c != null && allOrderLine[i].Article__c != null)  
            {
                catExternalIdlist.add(allOrderLine[i].TECHCatalogExternalId__c);
                articleslist.add(allOrderLine[i].Article__c);   
            }//End if not equal null
            
            
             //get transport fee
            /*if(allOrderLine[i].TECH_ArticleType__c == ORDER_LINE_TYPE_FEE && allOrderLine[i].PublicPrice__c != null){
                transportfee = transportfee + allOrderLine[i].PublicPrice__c;
            }//end if orderline fee*/
            
         }//end for
        
        //get catalog of all article
         List<CTA_CatalogArticle__c> ctas = [select MeansPayment__c, CategoryLevelCommission__c, AdminFees__c, 
              Commissionable__c,NetPrice__c,RegularPrice__c,PublicPrice__c, DealerPrice__c,LoyaltyPrgVal1__c,TaxRate__c,
              LoyaltyPrgVal2__c, LoyaltyPrgVal3__c, Catalog__r.Name  
        from CTA_CatalogArticle__c where Article__c IN :articleslist and TECH_CatalogExternalId__c IN :catExternalIdlist];
             
        for(integer i = 0;i<ctas.size();i++)
        /*Calculate taxes for all products
        *retrieve tax and public price from CTA_CatalogArticle__c
        
        {
            if(ctas[i].TaxRate__c != null){
                taxes = taxes +(ctas[i].PublicPrice__c * (ctas[i].TaxRate__c/100.00));
            }//end if tax = null
        
        }//end for 
         */
         
          system.debug('## Class VFC01_OrderRecap_France - loyaltyProgramListRecap after update <<<<<' + loyaltyProgramListRecap);
      }//controller
      
      public PageReference navigateToPaymentPage() {

        ORD_Order__c orderRefreshed = [SELECT Id, Dealer__c, PaymentTransactionId__c FROM ORD_Order__c WHERE Id =: globalOrder.id];

        PageReference pageRef = new PageReference('/apex/VFP01_OrderRecap_PaylinePage');
        pageRef.getParameters().put('token', orderRefreshed.PaymentTransactionId__c);
        pageRef.getParameters().put('dealerId', orderRefreshed.Dealer__c);
        pageRef.getParameters().put('orderId', orderRefreshed.Id);
        pageRef.setRedirect(true); 

        return (pageRef);
      }


    public PageReference refreshBtnZone() {
		
        if (this.displayCardPayment) {
            this.displayValidateOrderBtn = (paymentStatus == 'Approved' ? true : false);
        } else {
            this.displayValidateOrderBtn = true;
        }
        
        if (displayCGV && globalOrder.CGV__c == false) { this.displayValidateOrderBtn = false; }

        return (null);
    }

    public PageReference resetCard() {

        ORD_Order__c order = null;

        try {
            
          order = [SELECT Id, TECH_ExternalId__c, Dealer__c, TECH_TotalPrice__c, TotalCommision__c, Taxes__c, TECH_TotalPriceWithTax__c, 
                        TotalAdministrativeFee__c, TransportFees__c, PaymentTransactionId__c, Payment_Transaction_Status__c, Payment_Transaction_Message__c,
                        Payment_Transaction_Details_Date__c, Payment_Transaction_Token__c, LocalAttribute10__c , Dealer__r.AccountCountryCode__c, Status__c 
                    FROM ORD_Order__c
                    WHERE Id =: globalOrder.id];

          // GBU
          if (order.Status__c != 'Draft' && order.Status__c != 'Pending') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ORD00173));
            return null;
          }
			
			    // If the transaction has a token, reset it            
          if (order.Payment_Transaction_Token__c != null && order.Payment_Transaction_Token__c != '') {

              AP36_Payline_Handler.Result res = AP36_Payline_Handler.ws_doReset(globalOrder.id, false);

            if (res.isSuccess == false) {
                AP37_ErrorLog_Utils.add_errorLog(globalOrder.id, AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
                      'Reset Transaction on click reset button: ' + order.Payment_Transaction_Token__c , res.code = ' : ' + res.message);
            } 
          }

        } catch (Exception e) {
            AP37_ErrorLog_Utils.add_errorLog(globalOrder.id, AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
											'Reset Transaction on click reset button: ' + order.Payment_Transaction_Token__c , e.getMessage());
        }
                
        // Reset Payline fields on the order
        ORD_Order__c orderToUpdate = new ORD_Order__c();
        orderToUpdate.Id = globalOrder.id;
        orderToUpdate.PaymentTransactionId__c = '';
        orderToUpdate.Payment_Transaction_Token__c = '';
        orderToUpdate.LocalAttribute10__c = '';
        orderToUpdate.PaymentProvider__c = '';
        orderToUpdate.Payment_Transaction_Status__c = 'None';
        orderToUpdate.Payment_Transaction_Message__c = '';
        orderToUpdate.Payment_Transaction_Details_Date__c = null;
        orderToUpdate.Payment_Transaction_Reset__c = null;
        orderToUpdate.Payment_Transaction_Reset_Message__c = '';
        orderToUpdate.Payment_Transaction_Draft_Creation__c = null;
        update orderToUpdate;
        
        // Refresh the page
        PageReference pageRef = Page.VFP01_OrderRecap_France;
        pageRef.getParameters().put('orderId',globalOrder.id);
        return pageRef;
        
    }
    
       /* ****************************************************************/
      /* **********************setReachCT***********************/
      /* ****************************************************************/      
      
      
      private void checkIfIsOnlineOrder(){
        
            if(globalOrder != null && globalOrder.OrderType__c != null && globalOrder.OrderType__c.equals(VFC01_ProductBasketDTO_France.ONLINE_ORDER)){
                isOnlineOrder = true;
            }
      }
      
      
      private void setReachCT(ORD_Order__c ord){
        reachCommercialTarget=false;
        if(!String.isBlank(ord.TECH_BO_ExtractionStatus__c) && !String.isBlank(ord.Status__c)){
            if(ord.Status__c.equals('Pending') && ord.TECH_BO_ExtractionStatus__c.equals('To be exported')){
                if(isCanChooseDealer){
                     reachCommercialTarget=true;
                }
            }
        }
      }
       /* ****************************************************************/
      /* **********************LoyaltyProgramRecap***********************/
      /* ****************************************************************/
      private list<VFC01_LoyaltyProgramRecapDTO> loyaltyProgramRecap(){
            
            list<VFC01_LoyaltyProgramRecapDTO> lpcodeTotalPointList  = new list<VFC01_LoyaltyProgramRecapDTO>();
            
            for(Contact c : [Select id
                                               ,Name
                                               ,LoyaltyProgramToBeDisplayed__c
                                               ,LoyaltyProgram1Balance__c
                                               ,LoyaltyProgram2Balance__c
                                               ,LoyaltyProgram3Balance__c
                                               ,LoyaltyProgram4Balance__c
                                               ,LoyaltyProgram5Balance__c
                                               ,LoyaltyProgram6Balance__c
                                               ,LoyaltyProgram7Balance__c
                                               ,LoyaltyProgram8Balance__c
                                               ,LoyaltyProgram9Balance__c
                                               ,LoyaltyProgram10Balance__c
                                               ,LoyaltyProgram11Balance__c
                                               ,LoyaltyProgram12Balance__c
                                               ,LoyaltyProgram13Balance__c
                                               ,LoyaltyProgram14Balance__c
                                               ,LoyaltyProgram15Balance__c
                                               ,LoyaltyProgram16Balance__c
                                               ,LoyaltyProgram17Balance__c
                                               ,LoyaltyProgram18Balance__c
                                               ,LoyaltyProgram19Balance__c
                                               ,LoyaltyProgram20Balance__c
                                               ,AdminFeesAmount__c
                                               ,CommissionsAmount__c
                                               ,AccountCountryCode__c
                                               /* Happy Project */
                                               ,OrderAmountLimitForLp1__c
                                               ,OrderAmountLimitForLp2__c
                                               ,OrderAmountLimitForLp3__c
                                               ,OrderAmountLimitForLp4__c
                                               ,OrderAmountLimitForLp5__c
                                               ,OrderAmountLimitForLp6__c
                                               ,OrderAmountLimitForLp7__c
                                               ,OrderAmountLimitForLp8__c
                                               ,OrderAmountLimitForLp9__c
                                               ,OrderAmountLimitForLp10__c
                                               ,OrderAmountLimitForLp11__c
                                               ,OrderAmountLimitForLp12__c
                                               ,OrderAmountLimitForLp13__c
                                               ,OrderAmountLimitForLp14__c
                                               ,OrderAmountLimitForLp15__c
                                               ,OrderAmountLimitForLp16__c
                                               ,OrderAmountLimitForLp17__c
                                               ,OrderAmountLimitForLp18__c
                                               ,OrderAmountLimitForLp19__c
                                               ,OrderAmountLimitForLp20__c
                                      From Contact
                                     Where id = :dealerId])
          {
             
            if(c.LoyaltyProgramToBeDisplayed__c != null){
                       
                lpCodeDisplayed = c.LoyaltyProgramToBeDisplayed__c.split(';');
                
                system.debug('## Class VFC01_OrderRecap_France - lpCodeDisplayed  <<<<<' + lpCodeDisplayed);
                
                      for(integer i=0; i<lpCodeDisplayed.size(); i++)
                      {
                        VFC01_LoyaltyProgramRecapDTO loyalty = new VFC01_LoyaltyProgramRecapDTO(); 
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP1'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP1_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP1_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram1Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP2'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP2_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP2_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                 }else{
                                    loyalty.totalPoint = c.LoyaltyProgram2Balance__c;
                                 }
                            }
                            
                            /*if(lpCodeDisplayed[i].equalsIgnoreCase('LP2') && c.AccountCountryCode__c == 'FRA'){
                                loyalty.lpCode = lpCodeDisplayed[i];
                                loyalty.totalPoint = 0;
                            }*/
                            
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP3'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP3_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP3_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                 }else{
                                    loyalty.totalPoint = c.LoyaltyProgram3Balance__c;
                                 }
                                 
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP4'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP4_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP4_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram4Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP5'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP5_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP5_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram5Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP6'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP6_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP6_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram6Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP7'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP7_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP7_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram7Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP8'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP8_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP8_'+c.AccountCountryCode__c).LP_isReset__c){
                                     loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram8Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP9'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP9_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP9_'+c.AccountCountryCode__c).LP_isReset__c){
                                     loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram9Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP10'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP10_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP10_'+c.AccountCountryCode__c).LP_isReset__c){
                                     loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram10Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP11'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP11_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP11_'+c.AccountCountryCode__c).LP_isReset__c){
                                     loyalty.totalPoint = 0;
                                  }else{
                                     loyalty.totalPoint = c.LoyaltyProgram11Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP12'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP12_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP12_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram12Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP13'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP13_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP13_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram13Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP14'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP14_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP14_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram14Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP15'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP15_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP15_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram15Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP16'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP16_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP16_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{    
                                    loyalty.totalPoint = c.LoyaltyProgram16Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP17'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP17_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP17_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram17Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP18'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP18_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP18_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram18Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP19'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP19_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP19_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram19Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('LP20'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('LP20_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP20_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.LoyaltyProgram20Balance__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('Adm'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('ADM_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('ADM_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.AdminFeesAmount__c;
                                  }
                            }
                            if(lpCodeDisplayed[i].equalsIgnoreCase('Com'))
                            {
                                 loyalty.lpCode = lpCodeDisplayed[i];
                                 if(LP_Reset_Per_Country__c.getInstance('COM_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('COM_'+c.AccountCountryCode__c).LP_isReset__c){
                                    loyalty.totalPoint = 0;
                                  }else{
                                    loyalty.totalPoint = c.CommissionsAmount__c;
                                  }
                            }
                            lpcodeTotalPointList.add(loyalty);
                        }
                  }// for Contact
            }
          return lpcodeTotalPointList;
            
      }
      
      
      /* ****************************************************************/
      /* ************************ GetOrderLines *************************/
      /* ****************************************************************/
    public void GetOrderLines() {
      system.debug('## Class VFC01_OrderRecap_France- START ExistingOrder <<<<<'+UserInfo.getUserName());
                 
            List<ORL_OrderLine__c> allOrderLineList =  [Select Id, name
                                               ,Amount__c
                                               ,Article__c
                                               ,CatalogType__c
                                               ,RegularPrice__c
                                               ,PublicPrice__c 
                                               ,Qty__c
                                               ,Order__c         
                                               ,ArticleDescription__c
                                               ,ArticleInternationalCode__c 
                                               ,ArticleLocalCode__c
                                               ,ArticleLocalName__c
                                               ,ArticleName__c                          
                                               ,TECH_ArticleType__c
                                               ,TECH_ParentOrderline__c                                             
                                               ,TECH_ArticleDescription__c
                                               ,TECHCatalogExternalId__c 
                                               ,AmountWihtoutTax__c
                                               ,Article__r.LocalCode__c 
                                               ,Product_to_sell__c   
                                               /* Happy project */
                                               ,CatalogArticlesType__c 
                                               ,Order__r.TECH_TotalPrice__c
                                               ,TECH_MeansOfPayment__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp1__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp2__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp3__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp4__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp5__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp6__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp7__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp8__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp9__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp10__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp11__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp12__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp13__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp14__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp15__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp16__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp17__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp18__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp19__c
                                               ,Order__r.Dealer__r.OrderAmountLimitForLp20__c                                     
                                From ORL_OrderLine__c
                               Where Order__c = :orderId
                                 /*And TECH_ArticleType__c <>: ORDER_LINE_TYPE_FEE*//*(HDU) If this is uncomment , transport fee will not be taken. */ 
                           order By Name desc];    
                        
            orderLineList = new List<ORL_OrderLine__c>();
            feeLineList = new List<ORL_OrderLine__c>();
            orderChildLineList = new List<ORL_OrderLine__c>();
            
            set<String> catalogExternalIdSet = new Set<String>();
            
            if(allOrderLineList != null && allOrderLineList.size() > 0){
            
                for(ORL_OrderLine__c orderToAllocate : allOrderLineList){
                    
                    catalogExternalIdSet.add(orderToAllocate.TECHCatalogExternalId__c);
                    
                    String lineType = orderToAllocate.TECH_ArticleType__c;
                    system.debug('>>> orderToAllocate.CatalogType__c: ' + orderToAllocate.CatalogType__c);
                    if (orderToAllocate.CatalogType__c == ORDER_LINE_PROFESSIONAL_USE) {
                      this.containsProfessionalUseLine = true;
                    }

                    if(lineType.equals(ORDER_LINE_TYPE_MASTER) || lineType.equals(ORDER_LINE_TYPE_PRODUCT) ){
                        
                        orderLineList.add(orderToAllocate);
                        
                    }else if(lineType.equals(ORDER_LINE_TYPE_FEE)){
                        
                        //feeLineList.add(orderToAllocate);
                        
                    }else if(lineType.equals(ORDER_LINE_TYPE_CHILD)){
                        
                        orderChildLineList.add(orderToAllocate);
                    }else{
                        
                    }

                    /* Happy project */
                    if (orderToAllocate.TECH_MeansOfPayment__c != null && orderToAllocate.TECH_MeansOfPayment__c.indexOf('Cash') == -1) {
                      Double orderAmountLimit;
                      try {
                        orderAmountLimit = (Double)orderToAllocate.Order__r.Dealer__r.get('OrderAmountLimitFor' + orderToAllocate.TECH_MeansOfPayment__c + '__c');
                      } catch(Exception e) {
                        orderAmountLimit = 0;
                      }
                      if (orderAmountLimit != 0 && lpToVerifySet.contains(orderToAllocate.TECH_MeansOfPayment__c) && orderToAllocate.Order__r.TECH_TotalPrice__c < orderAmountLimit) {
                        insufficientOrderAmountForLP = true;
                      }
                    }
                }            
                       
            //Populating basket with orderlines
            
            catalogs = [select Name, TECH_ExternalId__c, CatalogueType__c  from CAT_Catalog__c where TECH_ExternalId__c in : catalogExternalIdSet];
            system.debug('######catalogExternalIdSet: ' + catalogExternalIdSet);                 
            system.debug('######catalogs: ' + catalogs);               
            system.debug('######orderLineList: ' + orderLineList);
            system.debug('######feeLineList: ' + feeLineList);
            system.debug('######orderChildLineList: ' + orderChildLineList);
            
         }
            
    }
   
    /* ****************************************************************/
    /* *********************** addCurrencySymbol *******************************/
    /* ****************************************************************/
    public string getNumberCurrencyFormat(){
      System.debug('getNumberCurrencyFormat >>>>>>>'+Userinfo.getLocale());
      if(Userinfo.getLocale().equalsIgnoreCase('fr_FR_EURO')){
          return '€{0, number, 0.00}';
      }else if(Userinfo.getLocale().equalsIgnoreCase('es_MX')){
            return 'MXN{0, number, 0.00}';
      }else if(Userinfo.getLocale().equalsIgnoreCase('es_VE')){
            return 'VEF{0, number, 0.00}';
      }else{
          return '€{0, number, 0.00}';
      }
      
    } 
    
    /* ****************************************************************/
      /* ************************ SendOrder *****************************/
    public PageReference SendOrder(){
      system.debug('## Class VFC01_OrderRecap_France - START SendOrder <<<<<'+UserInfo.getUserName());
      PageReference orderViewPageRef = null;
      //update status to Pending
      if (orderId <> null){
        // Check the CGV if needed
        if (displayCGV && globalOrder.CGV__c == false) {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,Label.Order_Recap_CGV_Error));
        } else if(isOrderValidated() && (!displayCardPayment || (displayCardPayment && !displayValidateOrderBtn))) { 
        //check if order has been validated/saved elsewhere
          // If credit card + not approved
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,errorOrderValidatedElsewhere));
         }// End if check last modified date
         else{
            ORD_Order__c order1 = new ORD_Order__c  (id = orderId, OrderDate__c = system.NOW()
                                                     , Status__c = SHW_IBZ_Constants.ORDER_STATUS_PENDING);
            update(order1);
            confMessage = true;
            confirmationMsg = system.label.ORD00047 ;
            for(ORD_Order__c ord : [Select Id
                                        , Status__c
                                        ,TECH_BO_ExtractionStatus__c
                                        , LastModifiedDate
                                 From ORD_Order__c
                                 Where id = :orderId])
           {
            setReachCT(ord);
            globalOrderLastModifiedDate=ord.LastModifiedDate;
            //redirect to orderview
            orderViewPageRef = Page.VFP01_OrderView_France;
            orderViewPageRef.getParameters().put('Id', orderId);
            orderViewPageRef.getParameters().put('ojv', 't');
           }
         }   
      }
      return orderViewPageRef;
    }
    
    public String getIframeUrl(Integer code){
      if (dealerId <> null){
            Contact contact = [select Id, AccountId, Account.ZonePromo__c, Account.AreaEmbeded__c from Contact where id =: dealerId];
            
            if(contact != null && contact.AccountId != null){
                  if(code == 1){
                        return contact.Account.ZonePromo__c;
                  }else{
                        return contact.Account.AreaEmbeded__c;
                  }
                  
                  
            }else{
                  return null;
            }
      }
      else{
            return null;
      }
      
    }
    
    public PageReference modifyOrder(){
      //check if order has been validated/saved elsewhere
        if(isOrderValidated()){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,errorOrderValidatedElsewhere));
        system.debug('## Class VFC01_OrderRecap_France - ApexPages.getParameters() <<<<<'+ApexPages.currentPage().getParameters().get('Id'));
        return ApexPages.currentPage();
         }// End if check last modified date
         else{
          system.debug('## Class VFC01_OrderRecap_France - START modifyOrder <<<<<'+UserInfo.getUserName());

          // If paid by card, cancel the transaction
          if (globalOrder.PaymentTransactionId__c != null && globalOrder.PaymentTransactionId__c != '') {

            // If the transaction has been approved / refused, delete the payline transaction
            if (globalOrder.Payment_Transaction_Status__c != 'None' && globalOrder.Payment_Transaction_Status__c != 'Draft') {
              AP36_Payline_Handler.Result res = AP36_Payline_Handler.ws_doReset(orderId, true);
              if (res.isSuccess == false) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,res.message));
                return ApexPages.currentPage();
              }
            }
          }
          
          PageReference pageRef = Page.VFP01_OrderBasket_France;
          pageRef.getParameters().put('orderId',orderId);
          pageRef.getParameters().put('dealerId',dealerID);
          return pageRef;
         }
    }
    
    
    public PageReference reachCT(){

      ORD_Order__c order = [SELECT Id, Status__c  
                            FROM ORD_Order__c
                            WHERE Id =: globalOrder.id];

      // GBU
      if (order.Status__c != 'Draft' && order.Status__c != 'Pending') {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ORD00173));
        return null;
      }

      //check if order has been validated/saved elsewhere
        if(isOrderValidated() ){

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,errorOrderValidatedElsewhere));
            return ApexPages.currentPage();
         }// End if check last modified date
         else{
          system.debug('## Class VFC01_OrderRecap_France - START set status of order to draft <<<<<'+UserInfo.getUserName());

          // If paid by card, cancel the transaction
          if (globalOrder.PaymentTransactionId__c != null && globalOrder.PaymentTransactionId__c != '') {

            // If the transaction has been approved / refused, delete the payline transaction
            if (globalOrder.Payment_Transaction_Status__c != 'None' || globalOrder.Payment_Transaction_Status__c != 'Draft') {
              AP36_Payline_Handler.Result res = AP36_Payline_Handler.ws_doReset(orderId, true);
              if (res.isSuccess == false) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,res.message));
                return ApexPages.currentPage();
              }
            }
          }

          if (orderId <> null){
              ORD_Order__c order1 = new ORD_Order__c  (id = orderId, Status__c = SHW_IBZ_Constants.ORDER_STATUS_DRAFT);
              update(order1);
              list<ORL_OrderLine__c> orderlineListRCT=[SELECT Id,Order__c from ORL_OrderLine__c where Order__c = : orderId];
              for (ORL_Orderline__c theOrderline : orderlineListRCT) {
                  theOrderline.TECH_OrderStatus__c=SHW_IBZ_Constants.ORDER_STATUS_DRAFT;
              }
              update(orderlineListRCT);
          }
          

          system.debug('## Class VFC01_OrderRecap_France - reachCT <<<<<'+UserInfo.getUserName());
          PageReference pageRef = Page.VFP01_OrderBasket_France;
          pageRef.getParameters().put('orderId',orderId);
          pageRef.getParameters().put('dealerId',dealerID);
          pageRef.getParameters().put('reachCT','true');
          return pageRef;
         }
    }
    
    public String getZonePromoUrl(){
      
      return getIframeUrl(1);
    }
    
    public String getAreaEmbededUrl(){
      
      return getIframeUrl(2);
    }
    
    public List<String> getDocumentAdvertUrl()
    {
        string fetchFolder = 'select id from Folder where DeveloperName =\'Stanhome_'+contactCountry+'\' ';string selectFolder='';
        List<Folder> lstFolder = database.query(fetchFolder);
        if(lstFolder!= null && lstFolder.size() > 0){
            selectFolder='FolderId=\''+lstFolder[0].id+'\' AND ';
        }
        string query = 'Select Id,Name,LastModifiedById from Document where '+selectFolder+' Name like \''+system.label.ORD00178+'%'+contactCountry+'\' Order by Name asc limit 2 ';
        List<Document> lstDocument = database.query(query);
        string strOrgId = UserInfo.getOrganizationId();
        List<String> strDocUrl=new List<String>();
        if(lstDocument!= null && lstDocument.size() > 0){
            for(Document eachDoc : lstDocument){
                strDocUrl.add('https://'+ApexPages.currentPage().getHeaders().get('Host')+ '/servlet/servlet.ImageServer?id='+eachDoc.Id+'&oid=' + strOrgId);
            }
         }
        return strDocUrl;
    }
    /***********************************************************************************************************************************/
    /************************ un dealer manager en France ne peut pas saisir de commande pour une dealer *******************************/
    /***********************************************************************************************************************************/
    private void checkIfCanChooseDealer(){
    
        isNotAllowedToOrderForOthers__c customSettings = isNotAllowedToOrderForOthers__c.getInstance(UserInfo.getUserId());
        
        System.debug('*** isNotAllowedToOrderForOthers__c.isNotAllowed__c '+ customSettings.isNotAllowed__c);
        connectedUserContact = [select TECH_MergeContactID__c from User where id = :userinfo.getUserId()].TECH_MergeContactID__c;
    boolean isOrderOwnerEqualsDealer = globalOrder.CreatedById != null ? connectedUserContact!=null ? (connectedUserContact == globalOrder.Dealer__r.Id) :(UserInfo.getUserId() == globalOrder.CreatedById) : false;
        if (!customSettings.isNotAllowed__c || isOrderOwnerEqualsDealer) {
            isCanChooseDealer = true;
        }else{
            isCanChooseDealer =  false;
        }
  }
  /**
  * Check if order has been validated/saved elsewhere
  */
  private boolean isOrderValidated() {
    //compare the LastModifiedDate field of object Order, in case order was modified elsewhere 
    List<ORD_Order__c> theListStatus = new List<ORD_Order__c>();
    boolean checkStatus = false;
    if (globalOrder.Id != null) {
      theListStatus = [select Id, Status__c, TECH_BO_ExtractionStatus__c,LastModifiedDate, PaymentTransactionId__c from ORD_Order__c where Id = : globalOrder.Id];
    }
    if (theListStatus != null && theListStatus.size() > 0) {
      if(theListStatus[0].PaymentTransactionId__c == '' && theListStatus[0].LastModifiedDate!=globalOrderLastModifiedDate){
        checkStatus = true;
        confMessage = true;
        orderValidatedElsewhere=true;
      }
    }

    return checkStatus;

  } 
}