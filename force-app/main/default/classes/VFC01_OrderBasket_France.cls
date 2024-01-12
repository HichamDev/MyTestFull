/*
----------------------------------------------------------------------
-- - Name          : VFC01_OrderBasket_France
-- - Author        : Ikumbi GBU
-- - Description   : Controller for VFP01_OrderBasket_France Page
--
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  --------------------------------------
-- 26-SEP-2017  NGO    1.0      Initial version, duplication from VFC01_OrderBasket extension controller
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class VFC01_OrderBasket_France {


  /*
  Basket          CatalogArticle      Orderline  (not offer)        Orderline Master/Slave (offer)
  VFC01_ProductBasketyDTO
              VFC01_ProductDetailDTO
                          VFC01_ProductOfferDTO
                            TECH_ArticleType__c = Product  VFC01_ProductOfferDetailDTO (Master)
                                              TECH_ArticleType__c = Master

                                            VFC01_ProductOfferDetailDTO (Slave)
                                              TECH_ArticleType__c = Slave
  */

  // *********** Global Variables *****************//

  public Contact globalContact {get; set;}
  public ORD_Order__c globalOrder {get; set;}
  public boolean isHasCatalogue {get; set;}
  public boolean isContactActive {get; set;}
  public boolean isEditMode {get; set;}
  public boolean isPortalUser {get; set;}
  public string msgDeleteWarning {get; set;}
  public String contactCountry {get; set;}
  public Datetime globalOrderLastModifiedDate {get; set;}
  
  //if true lets order status change from pending to draft/order complement
  public boolean reachCommercialTarget {get; set;}
  //error message containing list of LP for which the credit is exceeded
  public string errorMsgLP {get; set;}
  public string globalArticleNameSearch{get; set;}
  public VFC01_ProductDetailDTO_France productDetail {get; set;}
  public VFC01_ProductBasketDTO_France basketDetail {get; set;}
  public boolean isCanChooseDealer {get; set;}
  public boolean isCanChangeDealer {get; set;}
  //Mass Order
  public boolean isMass {get; set;}
  public boolean hasAccess {get; set;}
  public string isMO {get; set;}
  public List<VFC01_ProductMassInputDTO> massInputs {get; set;}
  public List<VFC01_ProductDetailDTO_France> massProductDetails {get; set;}
  public string dCats {get; set;}
  public List<String> lCatsId;
  public List<String> lOtherCatsId;
  public List<String> lPUCatsId {get; set;}
  public List<string> refExistant;
  public List<String> refs;
  //Delegate or Close Order
  public boolean canDelegateClose {get; set;}
  //BATCH
  public list<CronJobDetail> CronJobDetailList {get; set;}
  public list<CronTrigger> CronTriggerList {get; set;}
  public list<VFC01_LoyaltyProgramRecapDTO> loyaltyProgramListRecap {get; set;}
  public String row_index {get; set;}
  public String STH_ID {get; set;}
  //Record Type for Article
  public Id artProductRecordTypeID;
  public Id artBundleRecordTypeID;
  public Id artOfferRecordTypeID;
  public Id artFeeRecordTypeID;
  //Map for picklist onhandStatus translation
  Map<String, String> mapMyFieldTranslation = new Map<String, String>();
  //URL Parameters
  public Id existingOrderId;
  public Id contactId_fromContactPage;
  public Id connectedUserContact {get; set;}
  public string ART_TYPE_BUNDLE = 'Bundle';
  public string ART_TYPE_OFFER = 'Offer';
  public string ART_TYPE_PRODUCT = 'Product';
  public string ORDER_LINE_TYPE_MASTER = 'Master';
  public string ORDER_LINE_TYPE_CHILD = 'Child';
  public string ORDER_LINE_TYPE_PRODUCT = 'Product';
  public string ORDER_STATUS_STEP_1 = 'Step_1';
  public string ORDER_STATUS_STEP_2 = 'Step_2';
  public list<id> catalogIdList;

  private List<Shipping_Mode__c> lShippingModeDeclared;
  private Shipping_Mode__c selectedShippingMode;
  private Integer defaultSelected;
  private List<String> lUids;
  private List<Shipping_Fees__c> lShippingFees;

  public User__c userCustomSettings { get; set; }

  //public Boolean isPrivilegeCustomerProfile { get; set ; }

  /* Happy project */
  public Set<String> lpToVerifySet { get; set; }

  // *********** End Global Variables **************//
  public VFC01_OrderBasket_France(ApexPages.Standardcontroller controller) {

    //Get the different recordtypes
    Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
    retrieveRecordTypes();
    getURLParameters();
    initializeMap();
    //get the contact of the user connected
    retrieveContactFromUser();
    checkIfCanChooseDealer();
    checkisCanChangeDealer();

    userCustomSettings = User__c.getInstance();

    //For transport fees
    List<CountryCode_Name__c> lCountryIsoCode = CountryCode_Name__c.getAll().values();
	  String modeCountry = '';
    for (CountryCode_Name__c country : lCountryIsoCode) {
        if (globalContact != null && globalContact.MailingCountry == country.CountryName__c) {
            modeCountry = country.Iso_Code__c;
            break;
        }
    }
	  // Get the shipping modes available
    lShippingModeDeclared = [SELECT Name, Default_selected__c, Label__c, Mode__c, Order__c, PickUpStation_Type__c, Picture_URL__c, Service_Login__c, Service_Password__c, Service_URL__c, Timeout__c, UID__c, Service_Param_Text_2__c, Service_Param_Text_1__c, Exclusion_parameter__c, Param_Text_1__c
	                            FROM Shipping_Mode__c
	                            WHERE Active__c = true
	                            AND Country__c =: modeCountry
	                            ORDER BY Order__c ASC];

    lUids = new List<String>();    
    for (Shipping_Mode__c mode : lShippingModeDeclared) {
        lUids.add(mode.UID__c);
        if (mode.Default_selected__c) {
            selectedShippingMode = mode;
        }
    }

    // Retrieve the shipping fees applicable
    lShippingFees = [SELECT Amount_operator__c, Amount_value__c, Order_type__c, Shipping_Mode__c, Transport_fees__c, Weight_Operator__c, Weight_value__c, Description__c
                                            FROM Shipping_Fees__c
                                            WHERE Shipping_Mode__c in: lUids
                                            ORDER BY Name];
                                            // AND Order_type__c =: orderToUpdate.OrderMode__c 

    /* Happy project */
    lpToVerifySet = new Set<String>();
    if (globalContact != null && globalContact.AccountCountryCode__c != null) {
      for (LP_Statement_Summerize__mdt lpStatementSummerize : [SELECT MasterLabel, QualifiedApiName, Country__c, LP_Name__c, Is_Verified__c 
                                                              FROM LP_Statement_Summerize__mdt WHERE Country__c = :globalContact.AccountCountryCode__c AND Is_Verified__c = true]) {
        lpToVerifySet.add(lpStatementSummerize.LP_Name__c);
      }
    }
    
    //Check if order exist
    initialiseOrder();
    //validate bad debt and expiration
    if (! isBadDedtAndExpired()) {
      checkIfHasCatalogue();
    }
    //check if can delegate/close order
    checkCanDelegateCloseOrder();
    //Mass Order
    massInputs = VFC01_ProductMassInputDTO.initialiseList();
    massProductDetails = VFC01_ProductDetailDTO_France.initialiseList();
    //initializeLightInterface();
    initializeMassOrderInterface();
    refExistant = new List<String>();
    hasAccess = hasMassOrderAccess();
    //set contact country
    if (globalContact != null) {
      contactCountry = globalContact.AccountCountryCode__c;
    } else {
      contactCountry = '';
    }
    system.debug('## Class VFC01_OrderRecap - loyaltyProgramListRecap initialise <<<<<' + loyaltyProgramListRecap);   

  }

  private void checkIfCanChooseDealer() {

    isNotAllowedToOrderForOthers__c customSettings = isNotAllowedToOrderForOthers__c.getInstance(UserInfo.getUserId());
    System.debug('*** isNotAllowedToOrderForOthers__c.isNotAllowed__c ' + customSettings.isNotAllowed__c);
    isCanChooseDealer = !customSettings.isNotAllowed__c;
    connectedUserContact = [select TECH_MergeContactID__c from User where id = :userinfo.getUserId()].TECH_MergeContactID__c;
  }

  public void checkisCanChangeDealer() {

    if (isCanChooseDealer && isPortalUser) {
      isCanChangeDealer = false ;
    } else if (isCanChooseDealer && !isPortalUser) {
      isCanChangeDealer = true ;
    } else if (!isCanChooseDealer && isPortalUser) {
      isCanChangeDealer = false ;
    } else {
      isCanChangeDealer = false ;
    }
  }
// check if the dealer can delegate or close the online order
  public void checkCanDelegateCloseOrder(){
    system.debug('## Class VFC01_OrderRecap - START >>checkCanDelegateCloseOrder');
    system.debug('## Class VFC01_OrderRecap - >>checkCanDelegateCloseOrder >>isHasCatalogue'+isHasCatalogue);
    canDelegateClose=false;
    boolean isOK=false;
    if(basketDetail.isOnlineOrder){
      if(isBadDedtAndExpired()){
        if(globalContact.BadDebt__c){//only in the case of bad debt error can the dealer delegate/close order
          canDelegateClose=true;
          /*checkIfHasCatalogue();
          if(isHasCatalogue){//dealer has the right to process(save or modify) order
            canDelegateClose=true;
          }*/
        }
      }else{
        if(isHasCatalogue){//dealer has the right to process(save or modify) order
          canDelegateClose=true;
        }
      }
    }
    system.debug('## Class VFC01_OrderRecap - END >>checkCanDelegateCloseOrder >>canDelegateClose'+canDelegateClose);
  }

  public void initializeMsgDeleteWarning(String forCountry) {

    map <string, BatchOrderDeletionOptions__c> mapBatchOrderDeletionOptions =  BatchOrderDeletionOptions__c.getAll();
    if (mapBatchOrderDeletionOptions.containsKey(forCountry)) {

      boolean isAutomaticDeletion = mapBatchOrderDeletionOptions.get(forCountry).IsAutomaticDeletion__c;
      Integer validityPeriod = mapBatchOrderDeletionOptions.get(forCountry).ValidityPeriod__c == null ? null : mapBatchOrderDeletionOptions.get(forCountry).ValidityPeriod__c.intValue();
      String value = '0';
      String theHours = '0';

      if (validityPeriod != null) {
        value = String.valueOf(validityPeriod / 24);
        theHours = String.valueOf(math.mod(validityPeriod, 24));
      }

      if (isAutomaticDeletion) {
        msgDeleteWarning = system.label.ORD00171;

      } else {

        msgDeleteWarning = string.format(system.label.ORD00170, new List<String> { value, theHours });
      }
      if (reachCommercialTarget) {
        msgDeleteWarning += '<br/>' + system.label.ORD00176;
      }
    }
  }

  /*
  * Initialize all Map
  */
  private void initializeMap() {
    //Initialise field map translation for ART_Article__c OnhandStockStatus__c
    Schema.DescribeFieldResult F = ART_Article__c.OnhandStockStatus__c.getDescribe();
    List<Schema.PicklistEntry> P = F.getPicklistValues();

    for (Schema.PicklistEntry e : P) {
      mapMyFieldTranslation.put(e.value, e.label);
    }
  }

  /* TODELETE
  public void initializeLightInterface() {
    //Initialise interface to light by default
    isMO = 'false';
    refreshInterface();
  }
  */
  public void initializeMassOrderInterface() {
    //Initialise interface to Mass Order
    isMO = 'true';
    refreshInterface();
  }

  public boolean isBadDedtAndExpired() {

    boolean result = false;
    if (globalContact != null) {
      if ( globalContact.BadDebt__c ) {
        basketDetail.errMsg = system.label.ORD00003;
        result = true;

      } else if (globalContact.LastDateToOrder__c != null && globalContact.LastDateToOrder__c <  Date.today()) {

        basketDetail.errMsg = system.label.ORD00141;

        result = true;

      } else if (!globalContact.ActivityStatus__c) {
        //Contact Inactive
        basketDetail.errMsg = system.label.ORD00161;
        result = true;
      }
    }
    return result;
  }

  public void isPortalUser() {

    system.debug('## Class VFC01_OrderBasket - START isPortalUser <<<<<' + UserInfo.getUserName());
    system.debug('## Class VFC01_OrderBasket - UserInfo.getUserType() <<<<<' + UserInfo.getUserType());
    //Checks if Portal User
    if (UserInfo.getUserType().equals(system.label.ORD00066)) {
      isPortalUser = true;
    } else {
      isPortalUser = false;
    }
  }

  /* TODELETE
  public void UpdateArticleDetails() {
    clearMessages();
    system.debug('##  - UpdateArticleDetails <<<<<' + UserInfo.getUserName());
    system.debug('>>>>>> UpdateArticleDetails productDetail.quantity : >>'+productDetail.quantity+'<<');
    try {
      integer quantity = integer.valueOf(productDetail.quantity);
      populateArticleResult(quantity);

    } catch (TypeException e) {

      basketDetail.errMsg =  system.label.ORD00139;
    }
  }
  */

  /* TODELETE
  public void AddToBasket() {
    system.debug('##  - AddToBasket<<<<<' + UserInfo.getUserName());
    system.debug('>>>>>> AddToBasket productDetail : ' + productDetail);
    clearMessages();
    if (validateQuantity(productDetail)) {
      //Populate credit and debit point for the order from orderlines paid with loyalty program
      AP16_LoyaltyProgramService loyaltyService = new AP16_LoyaltyProgramService();

      try {

        productDetail.loyaltyProgramDTO = loyaltyService.getLPAmount(extractMeansOfPaymentList(productDetail), integer.valueOf(productDetail.quantity), productDetail.CTA, globalContact);

      } catch (AP16_MissingLoyaltyProgramException e) {

        basketDetail.errMsg = e.getMessage();
      }

      loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramMouvement(productDetail.loyaltyProgramDTO, loyaltyProgramListRecap, false);
      basketDetail.addBasketDetail(productDetail.clone());
      basketDetail.updateTotalPrice();
      basketDetail.updateTotalArticle();
      system.debug('>>>>>> AddToBasket productDetail 2nd isLoyalProgram: ' + basketDetail.basketDetails.get(0).loyaltyProgramDTO);
      productDetail = null;
      globalArticleNameSearch = '';
      basketDetail.infoMsg =  system.label.ORD00067;

    }
        

    system.debug('## AddToBasket - START CheckUser <<<<<' + UserInfo.getUserName());
  }
  */


  private void compileNumberOfArticles(VFC01_ProductDetailDTO_France productDetailLocal) {

    productDetailLocal.sumNumberOfArticles = 0;
    for (VFC01_ProductOfferDTO offer : productDetailLocal.offers) {
      integer value = 0;
      for (VFC01_ProductOfferDetailDTO offerDetail : offer.offerDetails) {
        value += offerDetail.quantity != null ? integer.valueOf(offerDetail.quantity.isNumeric() ?  offerDetail.quantity : '0') : 0;
      }
      offer.actualQtyOrdered = value;
      productDetailLocal.sumNumberOfArticles += value;
    }
  }

  private boolean validateQuantity(VFC01_ProductDetailDTO_France productDetailLocal) {

    boolean isValid = true;
  	if (productDetailLocal != null && productDetailLocal.CTA_Id != null && productDetailLocal.quantity != null && productDetailLocal.quantity != '') {

	    compileNumberOfArticles(productDetailLocal);
	    //productDetailLocal.errorMsg = '';
	    if (Integer.valueOf(productDetailLocal.quantity) > productDetailLocal.CTA.MaximumQuantity__c) {
	      isValid = false;
        //productDetailLocal.errorMsg = system.label.ORD00169 + ':<br/> * ' + productDetailLocal.name + '.' + system.label.ORD00172 + (integer)productDetailLocal.CTA.MaximumQuantity__c;
	      productDetailLocal.errorMsg = system.label.ORD00169 + ':<br/> * ' + productDetailLocal.localCode + '.' + system.label.ORD00172 + ' ' + (integer)productDetailLocal.CTA.MaximumQuantity__c;
	      productDetailLocal.errorSeverity = 'error';
	    }

	    if (productDetailLocal.isOffer) {

	      if (isValid) productDetailLocal.errorMsg = '';

	      integer productDetailLocalQuantity = integer.valueOf(productDetailLocal.quantity);
	      //validate total number of article specified in catalog article
	      system.debug('## validateQuantity - productDetailLocal.sumNumberOfArticles <<<<< ' + productDetailLocal.sumNumberOfArticles);
	      if (productDetailLocal.numberOfArticles != null && (productDetailLocal.numberOfArticles * productDetailLocalQuantity) != productDetailLocal.sumNumberOfArticles) {
          //productDetailLocal.errorMsg += system.label.ORD00068 + productDetailLocal.name + system.label.ORD00069 + (productDetailLocal.numberOfArticles * productDetailLocalQuantity) + system.label.ORD00070;
	        productDetailLocal.errorMsg += system.label.ORD00068 + productDetailLocal.localCode + system.label.ORD00069 + ' ' + (productDetailLocal.numberOfArticles * productDetailLocalQuantity) + system.label.ORD00070;
	        productDetailLocal.errorSeverity = 'error';
	        isValid = false;
	      }

	      //validate if quantity is in the range specified in kit
	      for (VFC01_ProductOfferDTO offer : productDetailLocal.offers) {

	        integer totalMaxQtyOrderable  = offer.maxQtyOrderable == null ? 1 : offer.maxQtyOrderable * productDetailLocalQuantity;
	        integer totalMinQtyOrderable  = offer.minQtyOrderable == null ? 1 : offer.minQtyOrderable * productDetailLocalQuantity;
	        system.debug('## validateQuantity - offer.actualQtyOrdered ' + offer.name + ' <<<<< ' + offer.actualQtyOrdered);
	        system.debug('## validateQuantity - offer.maxQtyOrderable ' + offer.name + ' <<<<< ' + totalMaxQtyOrderable);
	        system.debug('## validateQuantity - offer.minQtyOrderable ' + offer.name + ' <<<<< ' + totalMinQtyOrderable);

	        if (offer.isParent) {
	          if (offer.actualQtyOrdered > totalMaxQtyOrderable || offer.actualQtyOrdered < totalMinQtyOrderable) {

	            productDetailLocal.errorMsg += offer.name + ' ' + system.label.ORD00071 + ' ' + totalMinQtyOrderable + '/' + totalMaxQtyOrderable;
	            productDetailLocal.errorSeverity = 'error';

	            isValid = false;
	          }
	        } else {

	          for (VFC01_ProductOfferDetailDTO offerDetail : offer.offerDetails) {

	            integer totalMaxQtyOfferDetail = offerDetail.maxQtyOrderable * productDetailLocalQuantity;
	            integer totalMinQtyOfferDetail = offerDetail.minQtyOrderable * productDetailLocalQuantity;
	            system.debug('## validateQuantity - offerDetail.minQtyOrderable ' + offerDetail.name + ' <<<<< ' + totalMinQtyOfferDetail);
	            system.debug('## validateQuantity - offerDetail.maxQtyOrderable ' + offerDetail.name + ' <<<<< ' + totalMaxQtyOfferDetail);
	            system.debug('## validateQuantity - offerDetail.quantity ' + offerDetail.name + ' <<<<< ' + offerDetail.quantity);

	            if (integer.valueOf(offerDetail.quantity) > totalMaxQtyOfferDetail || integer.valueOf(offerDetail.quantity) < totalMinQtyOfferDetail) {
	              productDetailLocal.errorMsg += offerDetail.name + ' ' + system.label.ORD00071 + ' ' + totalMinQtyOfferDetail + '/' + totalMaxQtyOfferDetail;
	              productDetailLocal.errorSeverity = 'error';
	              isValid = false;

	            }
	          }
	        }
	      }
	    }

	    system.debug('## validateQuantity - basketDetail.errMsg <<<<< ' + basketDetail.errMsg);

	}

    if (isValid) {
      clearMessages();
    }

    return isValid;
  }

  public void ReloadGlobalContactInfos() {

    List<User> listDealerUser = [SELECT Id FROM User WHERE ContactId = :globalContact.Id];
    if (listDealerUser != null && !listDealerUser.isEmpty())
      userCustomSettings = User__c.getInstance(listDealerUser[0].Id);

    //For transport fees
    List<CountryCode_Name__c> lCountryIsoCode = CountryCode_Name__c.getAll().values();
    String modeCountry = '';
    for (CountryCode_Name__c country : lCountryIsoCode) {
        if (globalContact != null && globalContact.MailingCountry == country.CountryName__c) {
            modeCountry = country.Iso_Code__c;
            break;
        }
    }
    // Get the shipping modes available
    lShippingModeDeclared = [SELECT Name, Default_selected__c, Label__c, Mode__c, Order__c, PickUpStation_Type__c, Picture_URL__c, Service_Login__c, Service_Password__c, Service_URL__c, Timeout__c, UID__c, Service_Param_Text_2__c, Service_Param_Text_1__c, Exclusion_parameter__c, Param_Text_1__c
                              FROM Shipping_Mode__c
                              WHERE Active__c = true
                              AND Country__c =: modeCountry
                              ORDER BY Order__c ASC];
    System.debug('>>> lShippingModeDeclared: ' + lShippingModeDeclared);
    lUids = new List<String>();    
    for (Shipping_Mode__c mode : lShippingModeDeclared) {
        lUids.add(mode.UID__c);
        if (mode.Default_selected__c) {
            selectedShippingMode = mode;
        }
    }

    // Retrieve the shipping fees applicable
    lShippingFees = [SELECT Amount_operator__c, Amount_value__c, Order_type__c, Shipping_Mode__c, Transport_fees__c, Weight_Operator__c, Weight_value__c, Description__c
                                            FROM Shipping_Fees__c
                                            WHERE Shipping_Mode__c in: lUids
                                            ORDER BY Name];
                                            // AND Order_type__c =: orderToUpdate.OrderMode__c
    system.debug(lShippingFees.size()); 

    /* Happy projetc */
    if (globalContact != null && globalContact.AccountCountryCode__c != null) {
      for (LP_Statement_Summerize__mdt lpStatementSummerize : [SELECT MasterLabel, QualifiedApiName, Country__c, LP_Name__c, Is_Verified__c 
                                                              FROM LP_Statement_Summerize__mdt WHERE Country__c = :globalContact.AccountCountryCode__c AND Is_Verified__c = true]) {
        lpToVerifySet.add(lpStatementSummerize.LP_Name__c);
      }
    }
  }

  public void ChangeDealerDetailsBySTH() {
    string countrySearch = globalContact == null ? '' : globalContact.AccountCountryCode__c;
    if(Test.isRunningTest()){
        countrySearch = '';
      }
    if (countrySearch == '') {
      countrySearch = [select User_Country__c from User where id = :userinfo.getUserId()].User_Country__c;
      if (countrySearch.equals('SYSTEM')) {
        countrySearch = '';
      }
      if(Test.isRunningTest()){
        countrySearch = 'FRA';
      }
    }
    if (String.isNotBlank(STH_ID)) {

      List<Contact> listContact = new list<Contact>();
      string query = 'select ID, Name, Title, MailingCountry, MailingStreet, MailingPostalCode, MailingCity, MobilePhone' +
                     ',STHID__c,TECH_campaign__c,CurrentBalance__c,CurrencyIsoCode' +
                     ',BadDebt__c,LastDateToOrder__c' +
                     ',MinOrder__c,ActivityStatus__c' +
                     ',TECH_WSAvailability__c,AccountId,CommissionRateRange__c' +
                     ',PersonalMessage__c,Account.ZonePromo__c,Account.AreaEmbeded__c,Account.Country_Code__c,LoyaltyProgramToBeDisplayed__c' +
                     ',CurrentCommercialCycle__c,MinOrderFreeTransportFees__c' +
                     ',TransportFeesApplicable__c,AccountCountryCode__c' +
                     /* Happy Project */
                        ', OrderAmountLimitForLp1__c' +
                        ', OrderAmountLimitForLp2__c' +
                        ', OrderAmountLimitForLp3__c' +
                        ', OrderAmountLimitForLp4__c' +
                        ', OrderAmountLimitForLp5__c' +
                        ', OrderAmountLimitForLp6__c' +
                        ', OrderAmountLimitForLp7__c' +
                        ', OrderAmountLimitForLp8__c' +
                        ', OrderAmountLimitForLp9__c' +
                        ', OrderAmountLimitForLp10__c' +
                        ', OrderAmountLimitForLp11__c' +
                        ', OrderAmountLimitForLp12__c' +
                        ', OrderAmountLimitForLp13__c' +
                        ', OrderAmountLimitForLp14__c' +
                        ', OrderAmountLimitForLp15__c' +
                        ', OrderAmountLimitForLp16__c' +
                        ', OrderAmountLimitForLp17__c' +
                        ', OrderAmountLimitForLp18__c' +
                        ', OrderAmountLimitForLp19__c' +
                        ', OrderAmountLimitForLp20__c' +
                     ' from Contact where STHID__c = \'' + STH_ID + '\' ';
      if (countrySearch != '') {
        query = query + 'and AccountCountryCode__c= \'' + countrySearch + '\' ';
      }
      system.debug('## OrderBasket: ChangeDealerDetailsBySTH <<<<< ' + query);
      listContact =   database.query(query);

      if (listContact != null && listContact.size() > 0) {

        globalContact =  listContact[0];

        //List<User> listDealerUser = [SELECT Id FROM User WHERE ContactId = :globalContact.Id];
        //if (listDealerUser != null && !listDealerUser.isEmpty())
        //  userCustomSettings = User__c.getInstance(listDealerUser[0].Id);
        ReloadGlobalContactInfos();

        globalOrder.Dealer__c = globalContact.Id;

        //checkIfHasCatalogue();
        if (! isBadDedtAndExpired()) {
          checkIfHasCatalogue();
        } else {
          isHasCatalogue = false;
        }

        loyaltyProgramListRecap = loyaltyProgramRecap();
        productDetail = null;
        basketDetail.emptyBasket();
        globalArticleNameSearch = null;
        STH_ID = '';

        /* Happy projetc */
        if (globalContact != null && globalContact.AccountCountryCode__c != null) {
          for (LP_Statement_Summerize__mdt lpStatementSummerize : [SELECT MasterLabel, QualifiedApiName, Country__c, LP_Name__c, Is_Verified__c 
                                                                  FROM LP_Statement_Summerize__mdt WHERE Country__c = :globalContact.AccountCountryCode__c AND Is_Verified__c = true]) {
            lpToVerifySet.add(lpStatementSummerize.LP_Name__c);
          }
        }

      } else {
        basketDetail.errMsg = system.label.ORD00185;
      }
    }
  }

  public void ChangeDealerDetails() {

    system.debug('##  Change coontact from ' + globalContact + ' to ' + globalOrder.Dealer__c);
    clearMessages();
    List<Contact> listContact = [select ID
                                 , Name
                                 , Title
                                 , MailingCountry
                                 , MailingStreet
                                 , MailingPostalCode
                                 , MailingCity
                                 , MobilePhone
                                 , STHID__c
                                 , TECH_campaign__c
                                 , CurrentBalance__c
                                 , CurrencyIsoCode
                                 , BadDebt__c
                                 , LastDateToOrder__c
                                 , MinOrder__c
                                 , ActivityStatus__c
                                 , TECH_WSAvailability__c
                                 , AccountId
                                 , CommissionRateRange__c
                                 , PersonalMessage__c
                                 , Account.ZonePromo__c
                                 , Account.AreaEmbeded__c
                                 , Account.Country_Code__c
                                 , LoyaltyProgramToBeDisplayed__c
                                 , CurrentCommercialCycle__c
                                 , MinOrderFreeTransportFees__c
                                 , TransportFeesApplicable__c
                                 , AccountCountryCode__c
                                 /* Happy Project */
                                , OrderAmountLimitForLp1__c
                                , OrderAmountLimitForLp2__c
                                , OrderAmountLimitForLp3__c
                                , OrderAmountLimitForLp4__c
                                , OrderAmountLimitForLp5__c
                                , OrderAmountLimitForLp6__c
                                , OrderAmountLimitForLp7__c
                                , OrderAmountLimitForLp8__c
                                , OrderAmountLimitForLp9__c
                                , OrderAmountLimitForLp10__c
                                , OrderAmountLimitForLp11__c
                                , OrderAmountLimitForLp12__c
                                , OrderAmountLimitForLp13__c
                                , OrderAmountLimitForLp14__c
                                , OrderAmountLimitForLp15__c
                                , OrderAmountLimitForLp16__c
                                , OrderAmountLimitForLp17__c
                                , OrderAmountLimitForLp18__c
                                , OrderAmountLimitForLp19__c
                                , OrderAmountLimitForLp20__c
                                 from Contact where id = : globalOrder.Dealer__c limit 1];

    globalContact = listContact != null && listContact.size() > 0 ? listContact[0] : null;
    system.debug('### globalContact ' + globalContact);

    if (globalContact != null) {
      //List<User> listDealerUser = [SELECT Id FROM User WHERE ContactId = :globalContact.Id];
      //if (listDealerUser != null && !listDealerUser.isEmpty())
      //  userCustomSettings = User__c.getInstance(listDealerUser[0].Id);
      ReloadGlobalContactInfos();
    }

    //checkIfHasCatalogue();
    if (! isBadDedtAndExpired()) {
      checkIfHasCatalogue();
    } else {
      isHasCatalogue = false;
    }

    loyaltyProgramListRecap = loyaltyProgramRecap();

    productDetail = null;

    //basketDetail = new VFC01_ProductBasketDTO_France();
    basketDetail.emptyBasket();

    globalArticleNameSearch = null;

  }

  /* Happy project */
  private void checkMinOrderAmountForLP() {

    for (VFC01_ProductDetailDTO_France detail : basketDetail.basketDetails) {

      detail.infoMsg = null;

      //if (detail.meansOfPayment.indexOf('Cash') == -1) {
      if (detail.CTA.MeansPayment__c.indexOf('Cash') == -1) {

        Double orderAmountLimit;
        try {

          // orderAmountLimit = (Double)globalContact.get('OrderAmountLimitFor' + detail.meansOfPayment + '__c');
          orderAmountLimit = (Double)globalContact.get('OrderAmountLimitFor' + detail.CTA.MeansPayment__c + '__c');

        } catch(Exception e) {

          orderAmountLimit = 0;
        }

        if (orderAmountLimit != 0 && lpToVerifySet.contains(detail.CTA.MeansPayment__c) && basketDetail.totalPriceForValidBase < orderAmountLimit) {

          detail.infoMsg = String.format(System.Label.ORD00317, new List<String>{orderAmountLimit + '', Math.Ceil(orderAmountLimit * 1.2) + ''});//System.Label.ORD00317 + orderAmountLimit + '.';
        }

      }
    }
  }

  public void ChangeItemNumber() {

    system.debug('##  - ChangeItemNumber<<<<<' + UserInfo.getUserName());
    system.debug('##  - row_index<<<<< ' + row_index);
    /*isHasCatalogue = true;*/
    clearMessages();
    integer index = integer.valueOf(row_index);

    for (VFC01_ProductDetailDTO_France detail : basketDetail.basketDetails) {
      //if(detail.index == index && integer.valueOf(detail.quantity) != detail.quantityOld){
      if (integer.valueOf(detail.quantity) != detail.quantityOld && detail.isOffer!=true) {
        clearMessages();

        system.debug('##  - detail.quantity <<<<< ' + detail.quantity);
        system.debug('##  - detail.quantityOld <<<<< ' + detail.quantityOld);

        detail.updateSubTotal();
        detail.isModified = true;
        basketDetail.updateTotalPrice();
        basketDetail.updateTotalArticle();
        updateTransportFees();
        updateLoyaltyProgram(integer.valueOf(detail.quantity) - detail.quantityOld, detail);
        detail.quantityOld =  integer.valueOf(detail.quantity);
      }
    }

    /* Happy project */
    checkMinOrderAmountForLP();
  }

  public void IncrementItem() {

    system.debug('##  - IncrementItem<<<<<' + UserInfo.getUserName());
    system.debug('##  - row_index<<<<< ' + row_index);
    boolean invalidInteger = false;
    clearMessages();
    integer index = integer.valueOf(row_index);

    for (VFC01_ProductDetailDTO_France detail : basketDetail.basketDetails) {

      if (detail.index == index && detail.quantity.isNumeric() && String.isNotEmpty(detail.quantity)) {

        detail.quantity = string.valueOf(integer.valueOf(detail.quantity) + 1);
        detail.updateSubTotal();
        detail.isModified = true;
        basketDetail.updateTotalPrice();
        basketDetail.updateTotalArticle();
        updateTransportFees();
        updateLoyaltyProgram(1, detail);

        /* if(detail.isOffer){

           updateOfferDetailsQuantity('+', detail);

         }*/

        detail.quantityOld =  integer.valueOf(detail.quantity);
      } else {
        //detail.quantity=detail.quantityOld!=null ? string.valueOf(detail.quantityOld) : '1';
        invalidInteger = true;
      }
    }
    /*if(invalidInteger){
      isHasCatalogue=false;
      basketDetail.errMsg = system.label.ORD00139;
    }else{
      isHasCatalogue=true;
      basketDetail.infoMsg = system.label.ORD00072;
    }*/

    /* Happy project */
    checkMinOrderAmountForLP();
  }


  public void DecrementItem() {

    system.debug('##  - IncrementItem<<<<<' + UserInfo.getUserName());
    system.debug('##  - row_index<<<<< ' + row_index);
    integer index = integer.valueOf(row_index);
    boolean invalidInteger = false;
    clearMessages();
    boolean rightValue = false;

    for (VFC01_ProductDetailDTO_France detail : basketDetail.basketDetails) {
      rightValue = String.isNotEmpty(detail.quantity) ? (detail.quantity.isNumeric() ? (integer.valueOf(detail.quantity) > 1 ? true : false) : false) : false;
      if (detail.index == index && rightValue) {

        detail.quantity = string.valueOf(integer.valueOf(detail.quantity) - 1);
        detail.updateSubTotal();
        detail.isModified = true;
        basketDetail.updateTotalPrice();
        basketDetail.updateTotalArticle();
        updateTransportFees();
        updateLoyaltyProgram(-1, detail);

        /*if(detail.isOffer){

          updateOfferDetailsQuantity('-', detail);

        }*/
        detail.quantityOld =  integer.valueOf(detail.quantity);
      } else {
        //detail.quantity=detail.quantityOld!=null ? string.valueOf(detail.quantityOld) : '1';
        invalidInteger = true;
      }
    }
    /*if(invalidInteger){
      isHasCatalogue=false;
      basketDetail.errMsg = system.label.ORD00139;
    }else{
      isHasCatalogue=true;
      basketDetail.infoMsg = system.label.ORD00073;
    }*/

    /* Happy project */
    checkMinOrderAmountForLP();
  }

  private void updateLoyaltyProgram(integer delta, VFC01_ProductDetailDTO_France detail) {

    system.debug('##  - updateLoyaltyProgram<<<<< ' + detail);
    integer quantity = integer.valueOf(detail.quantity);
    if (detail.loyaltyProgramDTO != null) {

      AP16_LoyaltyProgram reverseDto = detail.loyaltyProgramDTO.clone();
      reverseDto.reverseValues();
      AP16_LoyaltyProgramService_France loyaltyService = new AP16_LoyaltyProgramService_France();
      loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramMouvement(reverseDto, loyaltyProgramListRecap, true);
      detail.loyaltyProgramDTO.adjustValues(delta, quantity);
      loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramMouvement(detail.loyaltyProgramDTO, loyaltyProgramListRecap, false);
    }

  }

  public void updateOfferDetailsQuantity(String stype, VFC01_ProductDetailDTO_France detail) {

    integer quantity = integer.valueOf(detail.quantity);
    system.debug('## updateOfferDetailsQuantity - detail.quantity <<<<<' + detail.quantity);
    integer delta = stype.equals('+') ? 1 : -1;
    for (VFC01_ProductOfferDTO offer : detail.offers) {
      for (VFC01_ProductOfferDetailDTO offerDetail : offer.offerDetails) {
        Integer offerDetailQuantity = integer.valueOf(offerDetail.quantity);
        if (offerDetail.getIsSelected()) {
          system.debug('## updateOfferDetailsQuantity - offerDetail.quantity <<<<<' + offerDetail.quantity);
          Integer value = offerDetailQuantity * quantity;
          offerDetail.quantity = string.valueOf(value / (quantity - delta));
        }
      }
    }
  }

  public void DeleteOrderLine() {

    clearMessages();
    integer index = integer.valueOf(row_index);
    VFC01_ProductDetailDTO_France detail = basketDetail.getProductDetailByIndex(index);
    if (detail.loyaltyProgramDTO != null) {
      AP16_LoyaltyProgram reverseDto = detail.loyaltyProgramDTO.clone();
      reverseDto.reverseValues();
      AP16_LoyaltyProgramService_France loyaltyService = new AP16_LoyaltyProgramService_France();
      loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramMouvement(reverseDto, loyaltyProgramListRecap, true);
    }

    if (isEditMode) {
      basketDetail.preDeleteBasketDetail(index);
      basketDetail.updateTotalPrice();
      basketDetail.updateTotalArticle();
      updateTransportFees();
    } else {
      basketDetail.deleteBasketDetail(index);
      basketDetail.updateTotalPrice();
      basketDetail.updateTotalArticle();
      updateTransportFees();
    }

    basketDetail.infoMsg = system.label.ORD00074;

  }

  public void SimulateOrder() {
    system.debug('## Class VFC01_OrderBasket - START SimulateOrder <<<<<' + UserInfo.getUserName());
    //errMessage = true;
    //canOrder = true;
    //Call Simulate Order WbebService with parameter newOrder.Id
    VFC01_UpsertOrder.UpsertOrder(globalOrder.Id);
    //Populate Basket again
    //redirect to order page with updated order from WS

  }

  private boolean isWSAvailable() {

    return globalContact.TECH_WSAvailability__c == 1 ;
  }

  private Double getMinOrder() {

    return globalContact.MinOrder__c;
  }

  public boolean validateLoyaltyProgram() {

    boolean isValid = true;
    errorMsgLP = '<br/>';
    for (VFC01_LoyaltyProgramRecapDTO dto : loyaltyProgramListRecap) {
      system.debug('## Class VFC01_OrderBasket - validateLoyaltyProgram dto<<<<<' + dto);
      if (dto.totalPoint < dto.lowerLimit && dto.isChanged() && !dto.lpCode.equalsIgnoreCase(system.label.LYP00002) && !dto.lpCode.equalsIgnoreCase(system.label.LYP00001)) {
        errorMsgLP = errorMsgLP + '* ' + dto.lpName + '<br/>';
        isValid = false;
      }
    }

    return isValid;
  }
  /**
  * Check if order has been validated/saved elsewhere
  */
  private boolean isOrderValidated() {
    //compare the LastModifiedDate field of object Order, in case order was modified elsewhere 
    List<ORD_Order__c> theListStatus = new List<ORD_Order__c>();
    boolean checkStatus = false;
    if (globalOrder.Id != null) {
      theListStatus = [select Id, Status__c, TECH_BO_ExtractionStatus__c,LastModifiedDate from ORD_Order__c where Id = : globalOrder.Id];
    }
    if (theListStatus != null && theListStatus.size() > 0) {
      if (theListStatus[0].Status__c.equals('Pending') && !reachCommercialTarget && !theListStatus[0].TECH_BO_ExtractionStatus__c.equals('To be exported')) {
        checkStatus = true;
      }
      if(theListStatus[0].LastModifiedDate!=globalOrderLastModifiedDate){
        checkStatus = true;
      }
    }

    return checkStatus;

  }

  public PageReference SaveOrderNextStep() {
    system.debug('## Class VFC01_OrderBasket - START SaveOrderNextStep <<<<<' + UserInfo.getUserName());
    clearMessages();
    PageReference orderAddressPageRef = null;
    system.debug('>>>>>> SaveOrderNextStep getMinOrder ' + getMinOrder());
    system.debug('>>>>>> SaveOrderNextStep getMaxAllowableArticles ' + getMaxAllowableArticles());
    system.debug('>>>>>> SaveOrderNextStep globalContact.BadDebt__c ' + globalContact.BadDebt__c);
    system.debug('>>>>>> SaveOrderNextStep globalContact.LastDateToOrder__c ' + globalContact.LastDateToOrder__c);
    system.debug('>>>>>> SaveOrderNextStep basketDetail ' + basketDetail);
    system.debug('>>>>>> SaveOrderNextStep globalContact ' + globalContact);
    //bypass this validation when online order
    if (basketDetail.totalPriceForValidBase < getMinOrder() && !basketDetail.isOnlineOrder) {

      basketDetail.errMsg = system.label.ORD00251 + ' ' + getMinOrder() + system.label.ORD00252 ;//+ currencyCode;

    } else if (isOrderValidated()) {

      basketDetail.errMsg = system.label.ORD00173+'<a href="/'+existingOrderId+'">'+system.label.ORD00184+'</a>';

    } else if (basketDetail.totalArticle > getMaxAllowableArticles()) {

      basketDetail.errMsg = system.label.ORD00075 + getMaxAllowableArticles() + system.label.ORD00076;

    } else if (globalContact.BadDebt__c ) {

      basketDetail.errMsg = system.label.ORD00003;

    } else if (globalContact.LastDateToOrder__c != null && globalContact.LastDateToOrder__c <  Date.today()) {

      basketDetail.errMsg = system.label.ORD00141;

    } else if (basketDetail.totalArticle < 1) {

      basketDetail.errMsg = system.label.ORD00097;

    } else if (!basketDetail.validateStock()) {

      String pCodes = ':';
      for (String pCode : basketDetail.getProductOutOfStock()) {
        pCodes = pCodes + '<br/>  * ' + pCode;
      }
      basketDetail.errMsg = system.label.ORD00147 + pCodes;

    } else if (!basketDetail.validateCatalogArticle()) {

      basketDetail.errMsg = system.label.ORD00158 + basketDetail.getValidateInactive();

    } else if (!basketDetail.validateCatalog()) {

      basketDetail.errMsg = system.label.ORD00156 + basketDetail.getValidateInactive();

    } else if (!basketDetail.validateArticle()) {

      basketDetail.errMsg = system.label.ORD00157 + basketDetail.getValidateInactive();

    } else if (!basketDetail.validateCatalogContact(globalContact)) {

      basketDetail.errMsg = system.label.ORD00159;

    } else if (!globalContact.ActivityStatus__c) {

      basketDetail.errMsg = system.label.ORD00161;

    } else if (!validateLoyaltyProgram()) {

      basketDetail.errMsg = system.label.ORD00146 + errorMsgLP;

    } else if (!basketDetail.validateMaxOrderableQuantity()) {

      basketDetail.errMsg = system.label.ORD00169 + basketDetail.getValidateInactive();

    } else if (basketDetail.isOnlineOrder && !basketDetail.validateOrderlineQtyOnlineOrder()) {

      basketDetail.errMsg = system.label.ORD00183;

    }else {

      system.debug('>>>>>> SaveOrderNextStep saving order ');

      if (saveOrder(ORDER_STATUS_STEP_2)) {

        //Checks if web service is available for this account
        if (isWSAvailable()) {
          SimulateOrder();
        }

        orderAddressPageRef = Page.VFP01_OrderAddress_France;
        orderAddressPageRef.getParameters().put('orderId', globalOrder.Id);
        orderAddressPageRef.getParameters().put('dealerId', globalOrder.Dealer__c);
      }

    }
    system.debug('>>>>>> articleMsg in Order Offer: ' + basketDetail.infoMsg);
    system.debug('>>>>>> articleErrorMsg in Order: ' + basketDetail.errMsg);
    return orderAddressPageRef;
  }

/**
  * if dealer does not want to handle order, delegate or close the order. change status from "Draft" to "Closed" or "Delegate".
  **/

public PageReference delegateOrder() {
    system.debug('## Class VFC01_OrderBasket - START delegateOrder <<<<<' + UserInfo.getUserName());
    clearMessages();
    PageReference orderRecapPageRef = null;
    system.debug('>>>>>> delegateOrder globalContact ' + globalContact);

    //check if order can be delegated or closed
    checkCanDelegateCloseOrder();
    system.debug('>>>>>> delegateOrder canDelegateClose ' + canDelegateClose);
    if (canDelegateClose) {
      ORD_Order__c order1 = new ORD_Order__c  (id = globalOrder.Id, Status__c = SHW_IBZ_Constants.ORDER_STATUS_DELEGATED);
      update(order1);
      list<ORL_OrderLine__c> orderlineListRCT=[SELECT Id,Order__c from ORL_OrderLine__c where Order__c = :  globalOrder.Id];
      for (ORL_Orderline__c theOrderline : orderlineListRCT) {
          theOrderline.TECH_OrderStatus__c=SHW_IBZ_Constants.ORDER_STATUS_DELEGATED;
      } 
      update(orderlineListRCT);
      orderRecapPageRef = Page.VFP01_OrderRecap_France;
      orderRecapPageRef.getParameters().put('orderId', globalOrder.Id);
      orderRecapPageRef.getParameters().put('dealerId', globalOrder.Dealer__c);
    }
    system.debug('## Class VFC01_OrderBasket - END delegateOrder <<<<<' + UserInfo.getUserName());
    return orderRecapPageRef;
  }
public PageReference closeOrder() {
    system.debug('## Class VFC01_OrderBasket - START closeOrder <<<<<' + UserInfo.getUserName());
    clearMessages();
    PageReference orderRecapPageRef = null;
    system.debug('>>>>>> closeOrder globalContact ' + globalContact);


    //check if order can be delegated or closed
    checkCanDelegateCloseOrder();
    system.debug('>>>>>> delegateOrder canDelegateClose ' + canDelegateClose);
    if (canDelegateClose) {
      ORD_Order__c order1 = new ORD_Order__c  (id = globalOrder.Id, Status__c = SHW_IBZ_Constants.ORDER_STATUS_CLOSED);
      update(order1);
      list<ORL_OrderLine__c> orderlineListRCT=[SELECT Id,Order__c from ORL_OrderLine__c where Order__c = :  globalOrder.Id];
      for (ORL_Orderline__c theOrderline : orderlineListRCT) {
          theOrderline.TECH_OrderStatus__c=SHW_IBZ_Constants.ORDER_STATUS_CLOSED;
      } 
      update(orderlineListRCT);
      orderRecapPageRef = Page.VFP01_OrderRecap_France;
      orderRecapPageRef.getParameters().put('orderId', globalOrder.Id);
      orderRecapPageRef.getParameters().put('dealerId', globalOrder.Dealer__c);
    }
    system.debug('## Class VFC01_OrderBasket - END closeOrder <<<<<' + UserInfo.getUserName());
    return orderRecapPageRef;
  }


  /**
  * Check if connected user is Interface
  * Using cuntom settings User__c
  */
  private integer getMaxAllowableArticles() {
    //retrieve custom settings
    OrderValidation__c  orderValidation = OrderValidation__c.getInstance(UserInfo.getProfileId());
    System.debug('***orderValidation.maxNumberArticles__c ' + orderValidation.maxNumberArticles__c);
    return integer.valueOf(orderValidation.maxNumberArticles__c);
  }




  public PageReference SaveOrderTemp() {
    clearMessages();
    PageReference orderBasketPageRef = Page.VFP01_OrderBasket_France;

    if (globalContact.BadDebt__c ) {

      basketDetail.errMsg = system.label.ORD00003;

    } else if (isOrderValidated()) {

      basketDetail.errMsg = system.label.ORD00173+'<a href="/'+existingOrderId+'">'+system.label.ORD00184+'</a>';

    } else if (globalContact.LastDateToOrder__c != null && globalContact.LastDateToOrder__c  <  Date.today()) {

      basketDetail.errMsg = system.label.ORD00141;

    } else if (basketDetail.totalArticle < 1) {

      basketDetail.errMsg = system.label.ORD00097;

    } else if (!basketDetail.validateStock()) {

      basketDetail.errMsg = system.label.ORD00147;

    } else if (!basketDetail.validateCatalogArticle()) {

      basketDetail.errMsg = system.label.ORD00158 + basketDetail.getValidateInactive();

    } else if (!basketDetail.validateCatalog()) {

      basketDetail.errMsg = system.label.ORD00156 + basketDetail.getValidateInactive();

    } else if (!basketDetail.validateArticle()) {

      basketDetail.errMsg = system.label.ORD00157 + basketDetail.getValidateInactive();

    } else if (!basketDetail.validateCatalogContact(globalContact)) {

      basketDetail.errMsg = system.label.ORD00159;

    } else if (!basketDetail.validateMaxOrderableQuantity()) {

      basketDetail.errMsg = system.label.ORD00169 + basketDetail.getValidateInactive();

    } else {

      if (saveOrder(ORDER_STATUS_STEP_1)) {

        basketDetail.infoMsg = system.label.ORD00077;
        orderBasketPageRef = Page.VFP01_OrderBasket_France;
        orderBasketPageRef.getParameters().put('orderId', globalOrder.Id);
        existingOrderId = globalOrder.Id;
        initialiseOrder();
      }
    }

    return orderBasketPageRef;
  }


  public String getZonePromoUrl() {

    return getIframeUrl(1);
  }

  private String getIframeUrl(Integer code) {
    if (globalContact <> null) {
      if (code == 1) {
        return globalContact.Account.ZonePromo__c;
      } else {
        return globalContact.Account.AreaEmbeded__c;
      }
    } else {
      return null;
    }

  }

  private boolean saveOrder(String step) {
    system.debug('## saveOrder start,basketDetail.basketDetails.size(): ' + basketDetail.basketDetails.size());
    boolean returnValue = true;
    try {
      if (isEditMode) {
        Set<Id> orderLinesDeleted = new Set<Id>();
        List<ORL_OrderLine__c> orderLinesModified = new List<ORL_OrderLine__c>();
        List<VFC01_ProductDetailDTO_France> orderLinesInserted = new List<VFC01_ProductDetailDTO_France>();
        for (VFC01_ProductDetailDTO_France detail : basketDetail.basketDetails) {
          //update orderline loop to check if updated
          system.debug('## detail.isDeleted : ' + detail.isDeleted);
          system.debug('## detail.isCreated : ' + detail.isCreated);
          system.debug('## detail.isModified : ' + detail.isModified);

          if (!detail.isDeleted) {
            if (detail.isCreated) {

              if (detail.loyaltyProgramDTO == null) {
                if (basketDetail.isOnlineOrder) {
                  orderLinesModified.add(new ORL_OrderLine__c(Id = detail.orderLine, Qty__c = integer.valueOf(detail.quantity),
                                         AmountWihtoutTax__c = detail.subTotal, Amount__c  = detail.getAmountWithTax(), TECH_BO_ExtractionStatus__c = 'To be exported'));
                } else {
                  orderLinesModified.add(new ORL_OrderLine__c(Id = detail.orderLine, Qty__c = integer.valueOf(detail.quantity),
                                         AmountWihtoutTax__c = detail.subTotal, Amount__c  = detail.getAmountWithTax()));
                }
              } else {

                ORL_OrderLine__c modifiedOrderline = new ORL_OrderLine__c(Id = detail.orderLine, Qty__c = integer.valueOf(detail.quantity),
                    AmountWihtoutTax__c = detail.subTotal, Amount__c  = detail.getAmountWithTax(),
                    LPAmount__c = detail.loyaltyProgramDTO.getLpAmount(), LPCode__c = detail.loyaltyProgramDTO.getToLpCode(),
                    /* Happy project */
                    TECH_MeansOfPayment__c = detail.CTA.MeansPayment__c
                    );

                //if is online order set field TECH_BO_ExtractionStatus__c to 'To be exported'
                if (basketDetail.isOnlineOrder) {
                  modifiedOrderline.TECH_BO_ExtractionStatus__c = 'To be exported';
                }
                system.debug('## wchy detail.loyaltyProgramDTO.mapLpCodeToLpAmount: ' + detail.loyaltyProgramDTO.mapLpCodeToLpAmount);

                //Update commission and admin fees
                if (detail.loyaltyProgramDTO.mapLpCodeToLpAmount.containsKey(system.label.LYP00002)) {

                  modifiedOrderline.Commission__c = Decimal.valueOf(detail.loyaltyProgramDTO.mapLpCodeToLpAmount.get(system.label.LYP00002));

                }
                if (detail.loyaltyProgramDTO.mapLpCodeToLpAmount.containsKey(system.label.LYP00001)) {

                  modifiedOrderline.AdministrativeFee__c = Decimal.valueOf(detail.loyaltyProgramDTO.mapLpCodeToLpAmount.get(system.label.LYP00001));

                }
                if (detail.loyaltyProgramDTO.mapLpCodeToLpAmount.containsKey(system.label.LYP00003)) {

                  modifiedOrderline.Discount__c = Decimal.valueOf(detail.loyaltyProgramDTO.mapLpCodeToLpAmount.get(system.label.LYP00003));

                }

                orderLinesModified.add(modifiedOrderline);
              }

              for (VFC01_ProductOfferDTO offer : detail.offers) {
                for (VFC01_ProductOfferDetailDTO offerDetail : offer.offerDetails) {
                  orderLinesModified.add(
                    new ORL_OrderLine__c(
                      Id = offerDetail.orderline, 
                      Qty__c = integer.valueOf(offerDetail.quantity),
                      LPCode__c = (detail.loyaltyProgramDTO != null && detail.loyaltyProgramDTO.mapLpCodeToLpAmount != null && detail.loyaltyProgramDTO.mapLpCodeToLpAmount.containsKey(system.label.LYP00003) 
                                  ? system.label.LYP00003 
                                  : null)));
                }
              }
            } else {
              orderLinesInserted.add(detail);
            }

          } else if (detail.isDeleted) {
            //delete orderline loop to check if deleted
            orderLinesDeleted.add(detail.orderLine);
          } else if (basketDetail.isOnlineOrder) {
            orderLinesModified.add(new ORL_OrderLine__c(Id = detail.orderLine, TECH_BO_ExtractionStatus__c = 'To be exported'));
          }

        }

        system.debug('## Class VFC01_OrderBasket - save- order basketDetail.basketDetails <<<<<' + basketDetail.basketDetails);
        system.debug('## Class VFC01_OrderBasket - save- order orderLinesDeleted <<<<<' + orderLinesDeleted);
        system.debug('## Class VFC01_OrderBasket - save- order orderLinesModified <<<<<' + orderLinesModified);
        system.debug('## Class VFC01_OrderBasket - save- order orderLinesInserted <<<<<' + orderLinesInserted);
        deleteOrderLines(orderLinesDeleted);
        update(orderLinesModified);
        createOrderLines(orderLinesInserted);
        globalOrder.TECH_Status_state__c = step;
        if (!basketDetail.isOnlineOrder) {
          calculateTransportFees();
        }
        globalOrder.Status__c = 'Draft';
        update globalOrder;

      } else {
        globalOrder.TECH_NumberOrderLines__c = basketDetail.totalArticle;
        globalOrder.TECH_Status_state__c = step;
        if (!basketDetail.isOnlineOrder) {
          calculateTransportFees();
        }
        globalOrder.Status__c = 'Draft';
        upsert globalOrder;
        if (basketDetail.basketDetails != null) {
          createOrderLines(basketDetail.basketDetails);
        }
      }
    }
    catch (DmlException e) {
      //Catch the validation error when creating statement
      if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
        basketDetail.errMsg = system.label.ORD00098;
      } else {
        basketDetail.errMsg = e.getMessage();
      }
      returnValue = false;
    } catch (AP16_MissingLoyaltyProgramException e) {
      basketDetail.errMsg = system.label.ORD00099;
      returnValue = false;
    }
    return returnValue;
  }

  private void deleteOrderLines(Set<Id> orderLineIds) {
    orderLineIds.remove(null);
    List<ORL_OrderLine__c> orderlines = [Select id
                                         From ORL_OrderLine__c
                                         Where TECH_ParentOrderline__c = : orderLineIds
                                             or Id in : orderLineIds];
    system.debug('#### orderLineIds' + orderLineIds);
    system.debug('#### orderlines' + orderlines);
    delete orderlines;
  }

  private void calculateTransportFees() {

    system.debug('## Class VFC01_OrderBasket - calculateTransportFees TECH_TotalPrice__c <<<<<' + globalOrder.TECH_TotalPrice__c);
    system.debug('## Class VFC01_OrderBasket - calculateTransportFees MinOrderFreeTransportFees__c <<<<<' + globalContact.MinOrderFreeTransportFees__c);
    system.debug('## Class VFC01_OrderBasket - calculateTransportFees TransportFeesApplicable__c <<<<<' + globalContact.TransportFeesApplicable__c);
    if (globalContact.TransportFeesApplicable__c) {

      if (basketDetail.totalPrice > globalContact.MinOrderFreeTransportFees__c) {
        system.debug('## Class VFC01_OrderBasket - calculateTransportFees details transport free <<<<<');
        globalOrder.TransportFees__c = 0 ;

      } else {

        Double fee = 0;
        map <string, TransportFees__c> mapTransportFees =  TransportFees__c.getAll();
        if (mapTransportFees.containsKey(globalContact.Account.Country_Code__c)) {

          fee = mapTransportFees.get(globalContact.Account.Country_Code__c).Amount__c;
        }

        system.debug('## Class VFC01_OrderBasket - calculateTransportFees details transport fee <<<<<' + fee);
        globalOrder.TransportFees__c = fee;
      }

    } else {

      globalOrder.TransportFees__c = 0 ;
    }



  }


  private Map<Id, ART_Article__c>  createMapArticles(List<VFC01_ProductDetailDTO_France> details) {
    set<Id> articles = new set<Id>();
    //Extract all Articles Ids
    for (VFC01_ProductDetailDTO_France detail : details) {

      if (detail.isOffer) {

        articles.add(detail.article);

        for (VFC01_ProductOfferDTO offer : detail.offers) {

          for (VFC01_ProductOfferDetailDTO offerDetail : offer.offerDetails) {

            if (offerDetail.getIsSelected()) {
              articles.add(offerDetail.article);

            }
          }
        }

      } else {
        articles.add(detail.article);
      }
    }

    Map<Id, ART_Article__c> articlesMap = new Map<Id, ART_Article__c>([Select Id
        , Name
        , LocalName__c
        , LocalCode__c
        , Description__c
        , PriceLOrKg__c
        , InternationalCode__c
        , Type__c
        From ART_Article__c
        Where id in : articles]);

    return articlesMap;
  }

  private void createOrderLines(List<VFC01_ProductDetailDTO_France> details) {
    List<ORL_OrderLine__c> orderlines = new List<ORL_OrderLine__c>();
    system.debug('## Class VFC01_OrderBasket - createOrderLines details <<<<<' + details);
    Map<Id, ART_Article__c> articlesMap = createMapArticles(details);
    for (VFC01_ProductDetailDTO_France detail : details) {
      if (detail.isOffer) {
        //create master orderline first
        ORL_OrderLine__c orderline = populateOrderLineOfferOrProduct(detail, ORDER_LINE_TYPE_MASTER, articlesMap);
        insert orderline;
        //orderline = [select Id, TECHCatalogExternalId__c, CatalogType__c, TECH_ExternalId__c from ORL_OrderLine__c where Id = : orderline.Id limit 1];
        system.debug('>>>>>> master orderline.id ' + orderline.id);
        system.debug('>>>>>> master orderline.TECH_ExternalId__c ' + orderline.TECH_ExternalId__c);
        //Create slave orderline
        for (VFC01_ProductOfferDTO offer : detail.offers) {
          for (VFC01_ProductOfferDetailDTO offerDetail : offer.offerDetails) {
            //populate slave orderline
            if (offerDetail.getIsSelected()) {
              ORL_OrderLine__c orderlineSlave =  populateOrderlinekitBundle(offerDetail, orderline, detail.CTA.Article__r.TECH_ExternalId__c, articlesMap);
              orderlines.add(orderlineSlave);
            }
          }
        }
      } else {
        ORL_OrderLine__c orderline = populateOrderLineOfferOrProduct(detail, ORDER_LINE_TYPE_PRODUCT, articlesMap);
        orderlines.add(orderline);
      }
    }
    system.debug('## Class VFC01_OrderBasket - createOrderLines - orderlines <<<<<' + orderlines);
    insert orderlines;
  }

  private ORL_OrderLine__c populateOrderlinekitBundle(VFC01_ProductOfferDetailDTO offerDetail, ORL_OrderLine__c master, String articleParent, Map<Id, ART_Article__c> articlesMap) {

    ORL_OrderLine__c orderline = new ORL_OrderLine__c(Order__c = globalOrder.id,  TECH_OrderStatus__c = SHW_IBZ_Constants.ORDER_STATUS_DRAFT);
    ART_Article__c article = articlesMap.get(offerDetail.article);
    orderline.Article__c = article.id;
    orderline.TECH_ParentOrderline__c = master.id;
    system.debug('>>>>>> master.TECH_ExternalId__c ' + master.TECH_ExternalId__c);
    system.debug('>>>>>> master.articleParent ' + articleParent);
    orderline.TECH_OfferBundleExternalId__c = articleParent;
    orderline.TECH_ArticleDescription__c = article.Description__c;
    orderline.ArticleInternationalCode__c = article.InternationalCode__c;
    orderline.ArticleLocalCode__c = article.LocalCode__c;
    orderline.ArticleLocalName__c = article.LocalName__c;
    orderline.ArticleName__c = article.Name;
    orderline.CatalogArticlesType__c = article.Type__c;
    orderline.PublicPrice__c = 0;
    orderline.Qty__c = Decimal.valueOf(offerDetail.quantity);
    orderline.Amount__c = 0;
    orderline.AmountWihtoutTax__c = 0;
    //orderline.TECH_DeleteIcon__c = system.label.ORD00017;
    orderline.TECH_ArticleType__c = ORDER_LINE_TYPE_CHILD;
    orderline.Commission__c = 0;
    orderline.Discount__c = 0;
    orderline.AdministrativeFee__c = 0;
    orderline.PublicPrice__c = 0;
    orderline.CatalogType__c = master.CatalogType__c;
    orderline.TECHCatalogExternalId__c =  master.TECHCatalogExternalId__c;
    orderline.CommissionnableArticle__c = master.CommissionnableArticle__c;
    orderline.LPCode__c = (master.LPCode__c != null && master.LPCode__c.contains(system.label.LYP00003) ? system.label.LYP00003 : null);
    return orderline;
  }

  private ORL_OrderLine__c populateOrderLineOfferOrProduct(VFC01_ProductDetailDTO_France detail, String orderlineType, Map<Id, ART_Article__c> articlesMap) {

    ORL_OrderLine__c orderline = new ORL_OrderLine__c(Order__c = globalOrder.id, TECH_OrderStatus__c = SHW_IBZ_Constants.ORDER_STATUS_DRAFT);
    detail.isCreated = true;
    ART_Article__c article = articlesMap.get(detail.article);
    orderline.Article__c = article.id;
    //orderline.TECH_OfferBundleID__c = article.id;
    orderline.TECH_ArticleDescription__c = detail.description;
    orderline.ArticleInternationalCode__c   = article.InternationalCode__c;
    orderline.ArticleLocalCode__c = article.LocalCode__c;
    orderline.ArticleLocalName__c = article.LocalName__c;
    orderline.ArticleName__c = article.Name;
    orderline.CatalogArticlesType__c = article.Type__c;
    system.debug('>>>>>> populateOrderLineOfferOrProduct detail.price' + detail.price);
    orderline.PublicPrice__c = detail.price;
    orderLine.RegularPrice__c = detail.regularPrice;
    orderline.Qty__c = integer.valueOf(detail.quantity);
    orderline.Amount__c = detail.getAmountWithTax();
    orderline.AmountWihtoutTax__c = detail.subTotal;
    orderline.TECH_ArticleType__c = orderlineType;
    //Transfer data ValidTotalAmountBase to orderline
    orderline.ValidTotalAmountBase__c = detail.isValidTotalAmountBase;
    orderline.ArticleBrandTerritory__c = detail.brandTerritory;
    //orderline.AmountWihtoutTax__c
    //orderline.InvoicedQuantity__c
    //orderline.OrderLineOrigin__c
    orderline.Commission__c = 0;
    orderline.Discount__c = 0;
    orderline.AdministrativeFee__c = 0;
    orderline.CatalogType__c = detail.CTA.TECH_Catalog_type__c;
    orderline.TECHCatalogExternalId__c =  detail.CTA.TECH_CatalogExternalId__c;
    orderline.CommissionnableArticle__c = detail.CTA.Commissionable__c;
    orderline.Product_to_sell__c = (detail.sale == null ? false : detail.sale);
    orderline.TECH_MeansOfPayment__c = detail.CTA.MeansPayment__c;
    if (detail.loyaltyProgramDTO != null) {
      orderline.LPAmount__c = detail.loyaltyProgramDTO.getLpAmount();
      orderline.LPCode__c = detail.loyaltyProgramDTO.getToLpCode();
      detail.loyaltyProgramDTO.constructMap();
      system.debug('>>>>>> detail.loyaltyProgramDTO.mapLpCodeToLpAmount' + detail.loyaltyProgramDTO.mapLpCodeToLpAmount);
      //system.debug('>>>>>> OrderLine : LPAmount__c' + dto.getLpAmount());
      //system.debug('>>>>>> meansOfPayment: ' + detail.meansOfPayment);
      if (detail.loyaltyProgramDTO.mapLpCodeToLpAmount.containsKey(system.label.LYP00002)) {
        orderline.Commission__c = Decimal.valueOf(detail.loyaltyProgramDTO.mapLpCodeToLpAmount.get(system.label.LYP00002));
      }
      if (detail.loyaltyProgramDTO.mapLpCodeToLpAmount.containsKey(system.label.LYP00001)) {
        orderline.AdministrativeFee__c = Decimal.valueOf(detail.loyaltyProgramDTO.mapLpCodeToLpAmount.get(system.label.LYP00001));
      }
      if (detail.loyaltyProgramDTO.mapLpCodeToLpAmount.containsKey(system.label.LYP00003)) {
        orderline.Discount__c = Decimal.valueOf(detail.loyaltyProgramDTO.mapLpCodeToLpAmount.get(system.label.LYP00003));
      }
    }
    return orderline;
  }

  private String getTranslatedPicklistValue(CTA_CatalogArticle__c picklistObject) {
    String translatedValue;
    if (picklistObject != null) {
      translatedValue = mapMyFieldTranslation.get(picklistObject.Article__r.OnhandStockStatus__c);
    }
    return (translatedValue);
  }

  /* TO DELETE
  private void populateArticleResult(Integer quantity) {
    clearMessages();
    if (!String.isBlank(globalArticleNameSearch)) {
        if(productDetail!=null){
            if(( globalArticleNameSearch.unescapeHtml4()).indexOf(productDetail.CTA.Article__r.SmartReference__c==null? 'NO_SMARTREFERENCE':productDetail.CTA.Article__r.SmartReference__c)!=-1 &&
                ( globalArticleNameSearch.unescapeHtml4()).indexOf(productDetail.CTA.Catalog__r.Name==null? 'NO_CATALOGNAME': productDetail.CTA.Catalog__r.Name.length()>=12 ? productDetail.CTA.Catalog__r.Name.substring(0,11) : productDetail.CTA.Catalog__r.Name)!=-1
              ){ 
                if(productDetail.CTA!=null){
                    if(productDetail.CTA.name!=null){
                        globalArticleNameSearch=productDetail.CTA.name;
                    }
                }
            }
        }
      system.debug('>>>>>> globalArticleNameSearch : ' + globalArticleNameSearch);
      productDetail = new VFC01_ProductDetailDTO_France();
      list<CTA_CatalogArticle__c> ctalist = new list<CTA_CatalogArticle__c>();
      string query = 'SELECT id, name,Article__c, TECH_ArticleRecordType__c, TECH_CatalogArticleDateInRange__c,MaximumQuantity__c,' +
                     'Catalog__r.Active__c,Catalog__r.EndDate__c,Catalog__r.StartDate__c, Catalog__r.Name, Catalog__c, Article__r.PriceLOrKg__c,' +
                     ' RegularPrice__c, Article__r.OnhandStockStatus__c, Article__r.StockStatusMessage__c, Article__r.Description__c, Article__r.Type__c,' +
                     ' Article__r.LocalCode__c, Article__r.Name, Article__r.Number_of_Articles__c, Article__r.Image__c, Article__r.LocalName__c, MeansPayment__c,' +
                     ' Article__r.BrandTerritory__c, Article__r.TECH_ExternalId__c, LoyaltyPrgUnit1__c , taxRate__c, Active__c,' +
                     ' CategoryLevelCommission__c, PublicPrice__c, DealerPrice__c, NetPrice__c, LoyaltyPrgVal1__c, LoyaltyPrgVal2__c,' +
                     ' LoyaltyPrgVal3__c, ValidTotalAmountBase__c,Article__r.ActiveProduct__c, AdminFees__c,Article__r.SmartReference__c, Commissionable__c, TECH_Catalog_type__c, TECH_CatalogExternalId__c ' +
                     ' FROM CTA_CatalogArticle__c ' +
                     ' WHERE Active__c = true' +
                     ' AND TECH_CatalogArticleDateInRange__c = \'true\'' +
                     ' AND TECH_ArticleRecordType__c <> :artFeeRecordTypeID' +
                     ' AND Catalog__c in (SELECT  c.Catalog__c From CAC_CatalogContact__c c where c.Dealer__c =  \'' + globalContact.Id + '\'' +
                     ' and c.Active__c = true and c.TECH_CatalogDateInRange__c = \'true\')' +
                     ' and name = \'' + string.escapeSingleQuotes( globalArticleNameSearch.unescapeHtml4() ) + '\'  limit 1';

      ctalist = database.query(query);
      system.debug('>>>>>> ctaList : ' + ctaList);

      if (ctaList != null && ctaList.size() > 0) {
        productDetail.CTA = ctaList[0];
        productDetail.article = ctaList[0].Article__c;
        productDetail.quantity = string.valueOf(quantity);
        productDetail.quantityOld = quantity;
        productDetail.description = (ctaList[0].Article__r.Description__c == null) ?  '' : ctaList[0].Article__r.Description__c;
        productDetail.stockStatus = ctaList[0].Article__r.OnhandStockStatus__c;
        productDetail.stockMessage = getTranslatedPicklistValue(ctaList[0]);
        productDetail.localName = ctaList[0].Article__r.LocalName__c;
        productDetail.localCode = ctaList[0].Article__r.LocalCode__c;
        productDetail.name = ctaList[0].Article__r.Name;
        productDetail.price = ctaList[0].PublicPrice__c;
        productDetail.regularPrice = ctaList[0].RegularPrice__c;
        productDetail.netPrice = ctaList[0].NetPrice__c;
        productDetail.numberOfArticles = Integer.valueOf(ctaList[0].Article__r.Number_of_Articles__c);
        productDetail.imageUrl = ctaList[0].Article__r.Image__c;
        productDetail.isValidTotalAmountBase = ctaList[0].ValidTotalAmountBase__c;
        productDetail.brandTerritory = ctaList[0].Article__r.BrandTerritory__c;
        productDetail.isOffer = isOffer(ctaList[0]);
        productDetail.loyaltyPrgUnit1 = ctaList[0].LoyaltyPrgUnit1__c ;
        productDetail.loyaltyPrgVal1 = string.valueOf(ctaList[0].LoyaltyPrgVal1__c) ;
        productDetail.tax = ctaList[0].taxRate__c;
        productDetail.activeProduct = ctaList[0].Article__r.ActiveProduct__c;
        system.debug('>>>>>> isOffer : ' + isOffer(ctaList[0]));
        AP16_LoyaltyProgramService_France loyaltyService = new AP16_LoyaltyProgramService_France();
        getSubstitutionArticle(productDetail, ctaList[0]);
        extractMeansOfPaymentList(productDetail);
        if (productDetail.isLoyalProgram) {
          productDetail.price = 0;
        }
        if (productDetail.isOffer) {
          createOffer();
        }

        system.debug('>>>>>> productDetail : ' + productDetail);
      } else {
        productDetail = null;
        basketDetail.errMsg = system.label.ORD00138;
      }

    } else {
      productDetail = null;
      basketDetail.errMsg = system.label.ORD00138;
    }
  }
  */


  private void getSubstitutionArticle(VFC01_ProductDetailDTO_France productDetail, CTA_CatalogArticle__c cta) {
    system.debug('>>>>>> getSubstitutionArticle : ' + productDetail);
    system.debug('>>>>>> getSubstitutionArticle : ' + cta);
    productDetail.hasCTASubstitution = false;
    system.debug('>>>>>> cta.Article__r.StockStatusMessage__c : ' + cta.Article__r.StockStatusMessage__c);

    //retrieve name from techexternalid
    if (String.isNotBlank(cta.Article__r.StockStatusMessage__c)) {
      List<CTA_CatalogArticle__c> ctas = [SELECT name  FROM CTA_CatalogArticle__c WHERE Active__c = true and Article__r.TECH_ExternalId__C = : cta.Article__r.StockStatusMessage__c
                                          AND TECH_CatalogArticleDateInRange__c = 'true'
                                              AND TECH_ArticleRecordType__c <> :artFeeRecordTypeID
                                              AND Catalog__c in (SELECT  c.Catalog__c From CAC_CatalogContact__c c where c.Dealer__c = :  globalContact.Id
                                                  and c.Active__c = true and c.TECH_CatalogDateInRange__c = 'true')];
      if (ctas != null && ctas.size() > 0) {
        productDetail.hasCTASubstitution = true;
        productDetail.CTASubstitution = ctas[0].name;
      }
    }
  }


  /* TODELETE
  public void ShowArticleDetails() {
    system.debug('## Class VFC01_OrderBasket - START ShowArticleDetails <<<<<' + UserInfo.getUserName());
    populateArticleResult(1);
  }
  */

  private void createOfferBundle(Id articleId, KIT_Kit__c kitParent) {

  	createOfferBundle(productDetail, articleId, kitParent);
  }

  private void createOfferBundle(VFC01_ProductDetailDTO_France dto, Id articleId, KIT_Kit__c kitParent) {

    VFC01_ProductOfferDTO offer = new VFC01_ProductOfferDTO(ART_TYPE_BUNDLE);
    if (kitParent != null) {
      offer.name = kitParent.Article__r.LocalCode__c;//Name;
      offer.minQtyOrderable = integer.valueOf(kitParent.MinQtyOrderable__c);
      offer.maxQtyOrderable = integer.valueOf(kitParent.MaxQtyOrderable__c);
      offer.isParent = true;
    }

    boolean isOfferClosedSet = true;

    for (KIT_Kit__c kit : [Select Article__c
                           , Article__r.Name
                           , Article__r.LocalName__c
                           , Article__r.LocalCode__c
                           , MinQtyOrderable__c
                           , MaxQtyOrderable__c
                           , Required__c
                           , name
                           , KitType__c
                           From KIT_Kit__c
                           Where ParentArticle__c = : articleId]) {

      system.debug('>>>>> Kit bundle: ' + Kit);
      VFC01_ProductOfferDetailDTO offerDetails = new VFC01_ProductOfferDetailDTO();
      offerDetails.article = kit.Article__c;
      offerDetails.localCode = kit.Article__r.LocalCode__c;
      offerDetails.name = kit.Article__r.LocalName__c;
      //used to initialise quantity
      offerDetails.minQtyOrderable = integer.valueOf(kit.MinQtyOrderable__c);
      offerDetails.maxQtyOrderable = integer.valueOf(kit.MaxQtyOrderable__c);
      offerDetails.isClosedSet = checkIfIsClosedSet(kit);
      if (!offerDetails.isClosedSet) {
        isOfferClosedSet = false;
      }
      system.debug('>>>>> test hdu min: ' + offerDetails.minQtyOrderable);
      system.debug('>>>>>  test hdu  prod: ' + dto.quantity);
      offerDetails.quantity = string.valueOf((offerDetails.minQtyOrderable == null ? 0 : offerDetails.minQtyOrderable) * integer.valueOf(dto.quantity));
      offer.addOfferDetails(offerDetails);

    }

    dto.isClosedSet = isOfferClosedSet;
    dto.offers.add(offer);

  }

  private boolean checkIfIsClosedSet(KIT_Kit__c kit) {
    String kitType = kit.KitType__c;
    //check if closed set
    if (kitType != null && kitType.equalsIgnoreCase(system.label.KIT00001)) {
      return true;
    } else {
      return false;
    }

  }

  private void createOfferOfferType(Id articleId) {

  	createOfferOfferType(productDetail, articleId);
  }

  private void createOfferOfferType(VFC01_ProductDetailDTO_France dto, Id articleId) {

    boolean isOfferClosedSet = false;

    for (KIT_Kit__c kit : [Select Article__c
                           , TECH_ArticleRecordType__c
                           , MinQtyOrderable__c
                           , MaxQtyOrderable__c
                           , Article__r.Name
                           , Article__r.LocalName__c
                           , Article__r.LocalCode__c
                           , Required__c
                           , name
                           , KitType__c
                           From KIT_Kit__c
                           Where ParentArticle__c = :articleId]) {
      system.debug('>>>>> Kit offer: ' + Kit);
      //Kit is bundle
      if (kit.TECH_ArticleRecordType__c == artBundleRecordTypeID) {

        createOfferBundle(kit.Article__c, kit);
      }

      //Kit is product
      else if (kit.TECH_ArticleRecordType__c == artProductRecordTypeID) {
        VFC01_ProductOfferDTO offer = new VFC01_ProductOfferDTO(ART_TYPE_PRODUCT);
        system.debug('>>>>> Kit bundle: ' + kit);
        VFC01_ProductOfferDetailDTO offerDetail = new VFC01_ProductOfferDetailDTO();
        offerDetail.article = kit.Article__c;
        offerDetail.name = kit.Article__r.LocalName__c;
        offerDetail.localCode = kit.Article__r.LocalCode__c;
        offerDetail.isRequired = kit.Required__c;
        //used to initialise quantity
        offerDetail.minQtyOrderable = integer.valueOf(kit.MinQtyOrderable__c);
        offerDetail.maxQtyOrderable = integer.valueOf(kit.MaxQtyOrderable__c);
        offerDetail.quantity = String.valueOf(offerDetail.minQtyOrderable * integer.valueOf(dto.quantity));
        offerDetail.isClosedSet = checkIfIsClosedSet(kit);
        if (offerDetail.isClosedSet) {
          isOfferClosedSet = true;
        }
        offer.addOfferDetails(offerDetail);
        dto.offers.add(offer);
      }
    }

    dto.isClosedSet = isOfferClosedSet;
  }
  private void createOffer(VFC01_ProductDetailDTO_France dto) {

  	VFC01_ProductDetailDTO_France localDto = dto;
  	if (localDto == null) localDto = productDetail;

    //Bundle get all articles from kit
    if (localDto.CTA.TECH_ArticleRecordType__c == artBundleRecordTypeID) {
      createOfferBundle(localDto, localDto.article, null);
      //Offer get all articles or bundle from kit
    } else if (localDto.CTA.TECH_ArticleRecordType__c == artOfferRecordTypeID) {
      createOfferOfferType(localDto, localDto.article);
    } else {
      //type article product
    }
  }
  private void createOffer() {

  	createOffer(null);

  	/*
    //Bundle get all articles from kit
    if (productDetail.CTA.TECH_ArticleRecordType__c == artBundleRecordTypeID) {
      createOfferBundle(productDetail.article, null);
      //Offer get all articles or bundle from kit
    } else if (productDetail.CTA.TECH_ArticleRecordType__c == artOfferRecordTypeID) {
      createOfferOfferType(productDetail.article);
    } else {
      //type article product
    }
    */
  }
  private List<String> extractMeansOfPaymentList(VFC01_ProductDetailDTO_France productDetail) {
    List<String> lpcodes = new List<String>();
    productDetail.isLoyalProgram = true;
    if (productDetail.CTA.MeansPayment__c != null && productDetail.CTA.MeansPayment__c.length() > 0) {
      String[] payments = productDetail.CTA.MeansPayment__c.split(';');
      system.debug('## Class VFC01_OrderBasket - START extractMeansOfPaymentList  payments <<<<<' + payments);
      for (String val : payments) {
        lpcodes.add(val);
        if (val.equalsIgnoreCase('Cash')) {
          productDetail.isLoyalProgram = false;
        }
      }
    } else {
      productDetail.isLoyalProgram = false;
    }
    return lpcodes;
  }

  private boolean isOffer(CTA_CatalogArticle__c cta) {
    system.debug('## Class VFC01_OrderBasket - isOffer<<<<<' + cta.TECH_ArticleRecordType__c);
    return (cta.TECH_ArticleRecordType__c == artBundleRecordTypeID || cta.TECH_ArticleRecordType__c == artOfferRecordTypeID);
  }

  private void initialiseOrder() {
    system.debug('>>>>>> existingOrderId : ' + existingOrderId + ' global contact : ' + globalContact );
    if (existingOrderId == null && globalContact <> null) {
      globalOrder = new ORD_Order__c(dealer__c = globalContact.Id, Status__c = SHW_IBZ_Constants.ORDER_STATUS_DRAFT, OrderDate__c = system.NOW());
      // Initialise loyaltyProgramListRecap from contact
      loyaltyProgramListRecap = loyaltyProgramRecap();
      if (basketDetail == null) {
        basketDetail = new VFC01_ProductBasketDTO_France();
      }
      isEditMode = false;
    } else if (existingOrderId == null && globalContact == null) {
      //TODO this case does not exit must removed.
      globalOrder = new ORD_Order__c();
      isEditMode = false;
    } else {

      getExistingOrder(existingOrderId);
      // Initialise loyaltyProgramListRecap from contact
      loyaltyProgramListRecap = loyaltyProgramRecap();
      populateBasketEditMode();
      isEditMode = true;

      /* Happy project */
      checkMinOrderAmountForLP();
    }
  }

  private void getExistingOrder(ID orderID) {
    system.debug('## Class VFC01_OrderBasket - START ExistingOrder <<<<<' + UserInfo.getUserName());
    List<ORD_Order__c> existingOrder = [Select id
                                        , status__c
                                        , OrderDate__c
                                        , Dealer__c
                                        , TECH_TotalPrice__c
                                        , TECH_NumberOrderLines__c
                                        , TECH_NumberOfArticles__c
                                        , TECH_BO_ExtractionStatus__c
                                        , TECH_TotalPriceExcludeFee__c
                                        , Country_Code__c
                                        , OrderType__c
                                        , CustomerFirstName__c
                                        , CustomerLastName__c
                                        , CreatedById
                                        , LastModifiedDate
                                        From ORD_Order__c
                                        Where id = :orderID ];

    if (existingOrder.size() > 0) {

      system.debug('>>>>>> Order Exists : ' + existingOrder);
      globalOrder = existingOrder[0];
      initializeMsgDeleteWarning(existingOrder[0].Country_Code__c);
      if (globalOrder.Dealer__c != null) {
        globalContact = [select ID
                         , Name 
                         , Title
                         , MailingCountry
                         , MailingStreet
                         , MailingPostalCode
                         , MailingCity
                         , MobilePhone
                         , STHID__c
                         , TECH_campaign__c
                         , CurrentBalance__c
                         , CurrencyIsoCode
                         , BadDebt__c
                         , LastDateToOrder__c
                         , MinOrder__c
                         , ActivityStatus__c
                         , TECH_WSAvailability__c
                         , AccountId
                         , CommissionRateRange__c
                         , PersonalMessage__c
                         , Account.ZonePromo__c
                         , Account.AreaEmbeded__c
                         , Account.Country_Code__c
                         , LoyaltyProgramToBeDisplayed__c
                         , CurrentCommercialCycle__c
                         , MinOrderFreeTransportFees__c
                         , TransportFeesApplicable__c
                         , AccountCountryCode__c
                         /* Happy Project */
                        , OrderAmountLimitForLp1__c
                        , OrderAmountLimitForLp2__c
                        , OrderAmountLimitForLp3__c
                        , OrderAmountLimitForLp4__c
                        , OrderAmountLimitForLp5__c
                        , OrderAmountLimitForLp6__c
                        , OrderAmountLimitForLp7__c
                        , OrderAmountLimitForLp8__c
                        , OrderAmountLimitForLp9__c
                        , OrderAmountLimitForLp10__c
                        , OrderAmountLimitForLp11__c
                        , OrderAmountLimitForLp12__c
                        , OrderAmountLimitForLp13__c
                        , OrderAmountLimitForLp14__c
                        , OrderAmountLimitForLp15__c
                        , OrderAmountLimitForLp16__c
                        , OrderAmountLimitForLp17__c
                        , OrderAmountLimitForLp18__c
                        , OrderAmountLimitForLp19__c
                        , OrderAmountLimitForLp20__c
                         from Contact where id = : globalOrder.Dealer__c limit 1];

        //List<User> listDealerUser = [SELECT Id FROM User WHERE ContactId = :globalContact.Id];
        //if (listDealerUser != null && !listDealerUser.isEmpty())
        //  userCustomSettings = User__c.getInstance(listDealerUser[0].Id);
        ReloadGlobalContactInfos();
      }
      globalOrderLastModifiedDate=globalOrder.LastModifiedDate;
    } else {
      system.debug('>>>>>> No Order Exists --> Initialising new order ');
      globalOrder = new ORD_Order__c(dealer__c = globalContact.Id, Status__c = SHW_IBZ_Constants.ORDER_STATUS_DRAFT, OrderDate__c = system.NOW());
    }
  }

  private void populateBasketEditMode() {
    system.debug('>>>>>> populateBasketEditMode');
    AP16_LoyaltyProgramService_France loyaltyService = new AP16_LoyaltyProgramService_France();
    List<ORL_OrderLine__c> orderlines = [Select ID
                                         , name
                                         , Amount__c
                                         , Article__c
                                         , RegularPrice__c
                                         , PublicPrice__c
                                         , Qty__c
                                         , Order__c
                                         , ArticleDescription__c
                                         , ArticleInternationalCode__c
                                         , ArticleLocalCode__c
                                         , ArticleLocalName__c
                                         , ArticleName__c
                                         , TECH_ParentOrderline__c
                                         , TECH_ArticleDescription__c
                                         , TECH_ArticleType__c
                                         , LPCode__c
                                         , LpAmount__c
                                         , ValidTotalAmountBase__c
                                         , ArticleBrandTerritory__c
                                         , TECHCatalogExternalId__c
                                         , Article__r.ActiveProduct__c
                                         , Article__r.LocalCode__c
                                         , Product_to_sell__c 
                                         , CatalogType__c
                                         From ORL_OrderLine__c
                                         Where Order__c = :globalOrder.Id
                                             //And TECH_ArticleType__c = 'Master'
                                             AND TECH_ArticleType__c <> 'Fee'
                                             order By CreatedDate asc];

    system.debug('>>>>>> populateBasketEditMode orderlines' + orderlines);

    List<ORL_OrderLine__c> orderlinesMaster = new List<ORL_OrderLine__c>();
    List<ORL_OrderLine__c> orderlinesSlave = new List<ORL_OrderLine__c>();
    List<ORL_OrderLine__c> orderlinesProduct = new List<ORL_OrderLine__c>();
    Map<Id, String> orderlinesOnline = new Map<Id, String>();
    
    if (orderlines != null && orderlines.size() > 0) {
      map<Id, CTA_CatalogArticle__c> mapOrderlineCTA = getCTAMapOrderline(orderlines);
      for (ORL_OrderLine__c orderline : orderlines) {
        if (orderline.TECH_ArticleType__c != null ? orderline.TECH_ArticleType__c.equals(ORDER_LINE_TYPE_MASTER) : false) {
          orderlinesMaster.add(orderline);
        } else if (orderline.TECH_ArticleType__c != null ? orderline.TECH_ArticleType__c.equals(ORDER_LINE_TYPE_CHILD) : false) {
          orderlinesSlave.add(orderline);
        } else {
          orderlinesProduct.add(orderline);
        }
        orderlinesOnline.put(orderline.Id,orderline.LPCode__c);
      }

      system.debug('>>>>>> populateBasketEditMode orderlinesMaster ' + orderlinesMaster.size() + ' ' + orderlinesMaster );
      system.debug('>>>>>> populateBasketEditMode orderlinesSlave ' + orderlinesSlave.size() + ' ' + orderlinesSlave );
      system.debug('>>>>>> populateBasketEditMode orderlinesProduct ' + orderlinesProduct.size() + ' ' + orderlinesProduct );
      system.debug('>>>>>> populateBasketEditMode create basket' );
      basketDetail = new VFC01_ProductBasketDTO_France();
      checkIfIsOnlineOrder();

      if (orderlinesProduct.size() > 0) {

        for (ORL_OrderLine__c orderline : orderlinesProduct) {

          system.debug('>>>>>> in for loop orderlinesProduct' );

          VFC01_ProductDetailDTO_France productDetail = new VFC01_ProductDetailDTO_France();
          productDetail.description = orderline.TECH_ArticleDescription__c;
          productDetail.localName = orderline.ArticleLocalName__c;
          productDetail.localCode = orderline.ArticleLocalCode__c;
          productDetail.name = orderline.ArticleName__c;
          productDetail.price = orderline.PublicPrice__c;
          productDetail.RegularPrice = orderline.RegularPrice__c;
          productDetail.netPrice = orderline.Qty__c == 0 ? 0 : orderline.Amount__c / orderline.Qty__c;
          productDetail.quantity = string.valueOf(orderline.Qty__c);
          productDetail.quantityOld = integer.valueOf(orderline.Qty__c);
          productDetail.orderline = orderline.id;
          productDetail.isCreated = true;
          productDetail.isValidTotalAmountBase = orderline.ValidTotalAmountBase__c;
          productDetail.brandTerritory = orderline.ArticleBrandTerritory__c;
          getCTAFromOrderline(productDetail, orderline, mapOrderlineCTA);
          productDetail.tax = productDetail.CTA.TaxRate__c;
          productDetail.stockMessage = getTranslatedPicklistValue(productDetail.CTA);
          productDetail.stockStatus = productDetail.CTA.Article__r.OnhandStockStatus__c;
          productDetail.activeProduct = orderline.Article__r.ActiveProduct__c;
          productDetail.sale = orderline.Product_to_sell__c;
          productDetail.professionalUse = (orderline.CatalogType__c == 'Professional Use');
          if (String.isNotBlank(orderline.LpCode__c)) {

            //productDetail.loyaltyProgramDTO = loyaltyService.getLPAmount(extractMeansOfPaymentList(productDetail), integer.valueOf(orderline.Qty__c), productDetail.CTA, globalContact);
            productDetail.loyaltyProgramDTO = new AP16_LoyaltyProgram(orderline.LpCode__c, orderline.LpAmount__c);

            loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramMouvement(productDetail.loyaltyProgramDTO, loyaltyProgramListRecap, false);

          }

          productDetail.isOffer = false;

          basketDetail.addBasketDetail(productDetail);
        }
        basketDetail.updateTotalArticle();
        updateTransportFees();
      }

      system.debug('>>>>>> populateBasketEditMode orderlinesProduct' + orderlinesProduct);

      if (orderlinesMaster.size() > 0) {
        for (ORL_OrderLine__c orderline : orderlinesMaster) {
          VFC01_ProductDetailDTO_France productDetail = new VFC01_ProductDetailDTO_France();
          productDetail.description = orderline.TECH_ArticleDescription__c;
          productDetail.localName = orderline.ArticleLocalName__c;
          productDetail.localCode = orderline.ArticleLocalCode__c;
          productDetail.name = orderline.ArticleName__c;
          productDetail.price = orderline.PublicPrice__c;
          productDetail.RegularPrice = orderline.RegularPrice__c;
          productDetail.netPrice = orderline.Qty__c == 0 ? 0 : orderline.Amount__c / orderline.Qty__c;
          productDetail.quantity = string.valueOf(orderline.Qty__c);
          productDetail.quantityOld = integer.valueOf(orderline.Qty__c);
          productDetail.orderline = orderline.id;
          productDetail.isCreated = true;
          productDetail.isValidTotalAmountBase = orderline.ValidTotalAmountBase__c;
          productDetail.brandTerritory = orderline.ArticleBrandTerritory__c;
          productDetail.activeProduct = orderline.Article__r.ActiveProduct__c;
          getCTAFromOrderline(productDetail, orderline, mapOrderlineCTA);
          productDetail.tax = productDetail.CTA.TaxRate__c;
          productDetail.stockStatus = getTranslatedPicklistValue(productDetail.CTA);
          productDetail.sale = orderline.Product_to_sell__c;
          if (String.isNotBlank(orderline.LpCode__c)) {
            //productDetail.loyaltyProgramDTO = loyaltyService.getLPAmount(extractMeansOfPaymentList(productDetail), integer.valueOf(orderline.Qty__c), productDetail.CTA, globalContact);
            productDetail.loyaltyProgramDTO = new AP16_LoyaltyProgram(orderline.LpCode__c, orderline.LpAmount__c);
            loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramMouvement(productDetail.loyaltyProgramDTO, loyaltyProgramListRecap, false);
          }

          productDetail.isOffer = true;
          system.debug('>>>>>> populateBasketEditMode in for loop' + orderlinesMaster);
          VFC01_ProductOfferDTO productoffer = new VFC01_ProductOfferDTO(ART_TYPE_BUNDLE);
          for (ORL_OrderLine__c orderlineSlave : orderlinesSlave) {
            if (orderline.Id == orderlineSlave.TECH_ParentOrderline__c ) {
              VFC01_ProductOfferDetailDTO offerDetail = new VFC01_ProductOfferDetailDTO();
              offerDetail.name = orderlineSlave.ArticleName__c;
              offerDetail.localCode = orderlineSlave.Article__r.LocalCode__c;
              offerDetail.quantity = string.valueOf(orderlineSlave.Qty__c);
              offerDetail.orderline = orderlineSlave.Id;
              productoffer.addOfferDetails(offerDetail);
            }
          }
          productDetail.offers.add(productoffer);
          basketDetail.addBasketDetail(productDetail);
        }
        basketDetail.updateTotalPrice();
        basketDetail.updateTotalArticle();
      }
      
      
      //TODO #300144 for online orders recalculate LP
      if(basketDetail.isOnlineOrder){
        //productDetail.loyaltyProgramDTO = loyaltyService.getLPAmount(extractMeansOfPaymentList(productDetail), integer.valueOf(productDetail.quantity), productDetail.CTA, globalContact);
        loyaltyService.recalculateLPForOnlineOrder(basketDetail.basketDetails, globalContact,orderlinesOnline);
        for(VFC01_ProductDetailDTO_France oneDetail : basketDetail.basketDetails){
            loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramMouvement(oneDetail.loyaltyProgramDTO, loyaltyProgramListRecap, false);
            system.debug('>>>>>> populateBasketEditMode online Order>LP Amount>' + oneDetail.loyaltyProgramDTO.getLpAmounts()+'>LP Code>'+oneDetail.loyaltyProgramDTO.getToLpCodes());
            system.debug('>>>>>> populateBasketEditMode online Order>mapLpCodeToLpAmount>'+oneDetail.loyaltyProgramDTO.mapLpCodeToLpAmount);
        }
      }
      
      system.debug('>>>>>> populateBasketEditMode basketDetail' + basketDetail);
    }
  }


  private void getCTAFromOrderline(VFC01_ProductDetailDTO_France productDetail, ORL_OrderLine__c orderline,  map<Id, CTA_CatalogArticle__c>  mapOrderlineCTA) {
    productDetail.CTA = mapOrderlineCTA.get(orderline.id);
  }


  private void checkIfIsOnlineOrder() {
    if (globalOrder != null && globalOrder.OrderType__c != null && globalOrder.OrderType__c.equals(VFC01_ProductBasketDTO_France.ONLINE_ORDER)) {
      basketDetail.isOnlineOrder = true;
    }else{
        basketDetail.isOnlineOrder = false;
    }
  }

  private map<Id, CTA_CatalogArticle__c>  getCTAMapOrderline(List<ORL_OrderLine__c> orderlines) {
    map<Id, CTA_CatalogArticle__c> mapOrderlineCTA = new map<Id, CTA_CatalogArticle__c>();
    set<Id> setArticles = new Set<Id>();
    set<String> setCatalogs = new Set<String>();
    for (ORL_OrderLine__c orderline : orderlines) {
      setArticles.add(orderline.Article__c);
      setCatalogs.add(orderline.TECHCatalogExternalId__c);
    }

    List<CTA_CatalogArticle__c> ctas = [select TECH_CatalogArticleDateInRange__c, MaximumQuantity__c, Article__r.Type__c, Article__r.OnhandStockStatus__c, Article__r.LocalCode__c, Article__r.LocalName__c, Catalog__r.Active__c, Catalog__r.EndDate__c, Catalog__r.StartDate__c, EndDate__c, StartDate__c, MeansPayment__c, CategoryLevelCommission__c, AdminFees__c, taxRate__c,
                                        Commissionable__c, NetPrice__c, RegularPrice__c, PublicPrice__c, DealerPrice__c, LoyaltyPrgVal1__c, Active__c,
                                        LoyaltyPrgVal2__c, LoyaltyPrgVal3__c, Catalog__r.Name, Article__r.TECH_ExternalId__c , TECH_CatalogExternalId__c, IsPushZone__c 
                                        from CTA_CatalogArticle__c where Article__c in : setArticles  and TECH_CatalogExternalId__c in : setCatalogs];

    for (CTA_CatalogArticle__c cta : ctas) {
      for (ORL_OrderLine__c orderline : orderlines) {
        if (cta.Article__c == orderline.Article__c && cta.TECH_CatalogExternalId__c == orderline.TECHCatalogExternalId__c ) {
          mapOrderlineCTA.put(orderline.id, cta);
        }
      }
    }

    return mapOrderlineCTA;
  }

  private void getURLParameters() {
    existingOrderId = System.currentPagereference().getParameters().get('orderId');
    try {
      contactId_fromContactPage = System.currentPagereference().getParameters().get('contactId');
      if (System.currentPagereference().getParameters().get('reachCT') == null ? false : System.currentPagereference().getParameters().get('reachCT').equals('true')) {
        reachCommercialTarget = true;
      } else {
        reachCommercialTarget = false;
      }

    } catch (Exception e) {
      contactId_fromContactPage = null;
    }
  }

  /**
  * Retrieve all recordType that will be used.
  */
  private void retrieveRecordTypes() {
    //Retrieving Record Type for Article
    artProductRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
    system.debug('>>>>>>>>>>>>> retrieveRecordTypes artProductRecordTypeID : ' + artProductRecordTypeID);
    artBundleRecordTypeID  = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00002 and SObjectType = 'ART_Article__c' Limit 1].id;
    system.debug('>>>>>>>>>>>>> retrieveRecordTypes artBundleRecordTypeID : ' + artBundleRecordTypeID);
    artOfferRecordTypeID   = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00001 and SObjectType = 'ART_Article__c' Limit 1].id;
    system.debug('>>>>>>>>>>>>> retrieveRecordTypes artOfferRecordTypeID : ' + artOfferRecordTypeID);
    artFeeRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00004 and SObjectType = 'ART_Article__c' Limit 1].id;

  }

  /*
  * Retrieve contact and assign it to globalContact
  */
  public boolean retrieveContactFromUser() {
    //fetch contact from contactId parameters sent over the URL from Contact Detail page >> Orders related list
    Contact contact = new Contact();
    if (contactId_fromContactPage != null) {
      List<Contact> listContact = [select ID
                                   , Name
                                   , Title
                                   , MailingCountry
	                               , MailingStreet
	                               , MailingPostalCode
	                               , MailingCity
	                               , MobilePhone
                                   , STHID__c
                                   , TECH_campaign__c
                                   , CurrentBalance__c
                                   , CurrencyIsoCode
                                   , BadDebt__c
                                   , LastDateToOrder__c
                                   , MinOrder__c
                                   , ActivityStatus__c
                                   , TECH_WSAvailability__c
                                   , AccountId
                                   , CommissionRateRange__c
                                   , PersonalMessage__c
                                   , Account.ZonePromo__c
                                   , Account.AreaEmbeded__c
                                   , Account.Country_Code__c
                                   , LoyaltyProgramToBeDisplayed__c
                                   , CurrentCommercialCycle__c
                                   , MinOrderFreeTransportFees__c
                                   , TransportFeesApplicable__c
                                   , AccountCountryCode__c
                                   /* Happy Project */
                                   , OrderAmountLimitForLp1__c
                                   , OrderAmountLimitForLp2__c
                                   , OrderAmountLimitForLp3__c
                                   , OrderAmountLimitForLp4__c
                                   , OrderAmountLimitForLp5__c
                                   , OrderAmountLimitForLp6__c
                                   , OrderAmountLimitForLp7__c
                                   , OrderAmountLimitForLp8__c
                                   , OrderAmountLimitForLp9__c
                                   , OrderAmountLimitForLp10__c
                                   , OrderAmountLimitForLp11__c
                                   , OrderAmountLimitForLp12__c
                                   , OrderAmountLimitForLp13__c
                                   , OrderAmountLimitForLp14__c
                                   , OrderAmountLimitForLp15__c
                                   , OrderAmountLimitForLp16__c
                                   , OrderAmountLimitForLp17__c
                                   , OrderAmountLimitForLp18__c
                                   , OrderAmountLimitForLp19__c
                                   , OrderAmountLimitForLp20__c
                                   from Contact where id = : contactId_fromContactPage limit 1];
      contact = listContact[0];
    } else {
      contact = getConnectedUserContact();
    }
    isPortalUser();

    system.debug('>>>>>>>>>>>>> retrieveContactFromUser contact : ' + contact);

    if (contact != null) {

      globalContact = contact;

      globalOrder = new ORD_Order__c(Dealer__c = globalContact.Id);

      return true;

    } else {
      //Contact doesnot exist
      if (basketDetail == null) {
        basketDetail = new VFC01_ProductBasketDTO_France();
      }

      basketDetail.errMsg = system.label.ORD00051;

      return false;

    }
  }

  /**
  * Construct a global currency format to display currency from a wrapper
  */
  public string getNumberCurrencyFormat() {
    System.debug('getNumberCurrencyFormat >>>>>>>' + Userinfo.getLocale());
    if (Userinfo.getLocale().equalsIgnoreCase('fr_FR_EURO')) {
      return '€{0, number, 0.00}';
    } else {
      return '€{0, number, 0.00}';
    }
  }

  /**
  * Retrieve user contact
  */
  private  Contact getConnectedUserContact() {

    //YGO Added contact c
    Contact c = new Contact();
    User user = [select id, TECH_MergeContactID__c from user where id = : Userinfo.getUserId() limit 1];
    system.debug('>>>>>>>>>>>>> getConnectedSFDUserContact TECH_ContactID__c : ' + user.TECH_MergeContactID__c);
    if (user.TECH_MergeContactID__c  != null) {
      List<Contact> listContact = [select ID
                                   , Name
                                   , Title
                                   , MailingCountry
                                 	, MailingStreet
	                                 , MailingPostalCode
	                                 , MailingCity
	                                 , MobilePhone
                                   , STHID__c
                                   , TECH_campaign__c
                                   , CurrentBalance__c
                                   , CurrencyIsoCode
                                   , BadDebt__c
                                   , LastDateToOrder__c
                                   , MinOrder__c
                                   , ActivityStatus__c
                                   , TECH_WSAvailability__c
                                   , AccountId
                                   , CommissionRateRange__c
                                   , PersonalMessage__c
                                   , Account.ZonePromo__c
                                   , Account.AreaEmbeded__c
                                   , Account.Country_Code__c
                                   , LoyaltyProgramToBeDisplayed__c
                                   , CurrentCommercialCycle__c
                                   , MinOrderFreeTransportFees__c
                                   , TransportFeesApplicable__c
                                   , AccountCountryCode__c
                                   /* Happy project */
                                   , OrderAmountLimitForLp1__c
                                   , OrderAmountLimitForLp2__c
                                   , OrderAmountLimitForLp3__c
                                   , OrderAmountLimitForLp4__c
                                   , OrderAmountLimitForLp5__c
                                   , OrderAmountLimitForLp6__c
                                   , OrderAmountLimitForLp7__c
                                   , OrderAmountLimitForLp8__c
                                   , OrderAmountLimitForLp9__c
                                   , OrderAmountLimitForLp10__c
                                   , OrderAmountLimitForLp11__c
                                   , OrderAmountLimitForLp12__c
                                   , OrderAmountLimitForLp13__c
                                   , OrderAmountLimitForLp14__c
                                   , OrderAmountLimitForLp15__c
                                   , OrderAmountLimitForLp16__c
                                   , OrderAmountLimitForLp17__c
                                   , OrderAmountLimitForLp18__c
                                   , OrderAmountLimitForLp19__c
                                   , OrderAmountLimitForLp20__c
                                   from Contact where id = : user.TECH_MergeContactID__c limit 1];

      if (listContact != null && listContact.size() > 0) {
        c = listContact[0];
      } else {
        c = null;
      }
    } else {
      c = null;
    }
    return c;
  }


  /*
   * check if dealer has catalog
   */
  public void checkIfHasCatalogue() {
    system.debug('## Class VFC01_OrderBasket - START CheckCatalogue <<<<<' + UserInfo.getUserName());
    clearMessages();
    List<CTA_CatalogArticle__c> catalogArticles = new list<CTA_CatalogArticle__c>();
    catalogIdList = new list<id>();
    if (globalContact != null) {
      system.debug('#### globalContact: ' + globalContact);
      system.debug('#### globalContact.Id ' + globalContact.Id);
      catalogArticles = [SELECT Name, Article__r.Description__c, RegularPrice__c, PublicPrice__c
                         from CTA_CatalogArticle__c
                         where  Active__c = true
                                            and TECH_CatalogArticleDateInRange__c = 'true'
                                                and TECH_ArticleRecordType__c <> :artFeeRecordTypeID
                                                and Catalog__c in (SELECT  c.Catalog__c From CAC_CatalogContact__c c where c.Dealer__c = :globalContact.Id
                                                    and c.Active__c = true and c.TECH_CatalogDateInRange__c = 'true') limit 1];

      system.debug('>>>>>> function:checkIfHasCatalogue ==> catalogueList: ' + catalogArticles);

      //respect custom setting "isNotAllowedToOrderForOthers", except if current user is the order owner
      system.debug('>>>>>> function:checkIfHasCatalogue ==> globalOrder.CreatedById: ' + globalOrder.CreatedById);
      boolean isOrderOwnerEqualsDealer = globalOrder.CreatedById != null ? connectedUserContact!=null ? (connectedUserContact == globalContact.Id) :(UserInfo.getUserId() == globalOrder.CreatedById) : true;

      if (isCanChooseDealer || isOrderOwnerEqualsDealer) {

        isHasCatalogue = (catalogArticles.size() > 0 && globalContact.ActivityStatus__c);
      } else {
        isHasCatalogue = false;
      }
      isContactActive = globalContact.ActivityStatus__c;
      if (!(catalogArticles.size() > 0)) {

        //initializeLightInterface();
        initializeMassOrderInterface();
        refreshInterface();
        basketDetail.errMsg = system.label.ORD00053;
      }
      if (!isContactActive) {

        //initializeLightInterface();
        initializeMassOrderInterface();
        refreshInterface();
        basketDetail.errMsg = system.label.ORD00161;
      }
      if(basketDetail.isOnlineOrder && !basketdetail.validateOrderlineQtyOnlineOrder()){
        basketDetail.errMsg = system.label.ORD00183;
        isHasCatalogue = false;
      }

    } else {
      isHasCatalogue = false;
      basketDetail.errMsg = system.label.ORD00051;
      //initializeLightInterface();
      initializeMassOrderInterface();
      refreshInterface();
    }
    system.debug('### isHasCatalogue :' + isHasCatalogue);
  }

  private void clearMessages() {
    basketDetail.infoMsg = null;
    basketDetail.errMsg = null;
  }


  private list<VFC01_LoyaltyProgramRecapDTO> loyaltyProgramRecap() {

    list<VFC01_LoyaltyProgramRecapDTO> lpcodeTotalPointList  = new list<VFC01_LoyaltyProgramRecapDTO>();

    List<String> allLps = new List<String> {'LP1', 'LP2', 'LP3', 'LP4', 'LP5', 'LP6', 'LP7', 'LP8', 'LP9', 'LP10', 'LP11',
                                            'LP12', 'LP13', 'LP14', 'LP15', 'LP16', 'LP17', 'LP18', 'LP19', 'LP20', 'Com', 'Adm'
                                           };
    if (globalContact != null) {
      for (Contact c : [Select id
                        , Name
                        , Title
                        , LoyaltyProgramToBeDisplayed__c
                        , LoyaltyProgram1Balance__c
                        , LoyaltyProgram2Balance__c
                        , LoyaltyProgram3Balance__c
                        , LoyaltyProgram4Balance__c
                        , LoyaltyProgram5Balance__c
                        , LoyaltyProgram6Balance__c
                        , LoyaltyProgram7Balance__c
                        , LoyaltyProgram8Balance__c
                        , LoyaltyProgram9Balance__c
                        , LoyaltyProgram10Balance__c
                        , LoyaltyProgram11Balance__c
                        , LoyaltyProgram12Balance__c
                        , LoyaltyProgram13Balance__c
                        , LoyaltyProgram14Balance__c
                        , LoyaltyProgram15Balance__c
                        , LoyaltyProgram16Balance__c
                        , LoyaltyProgram17Balance__c
                        , LoyaltyProgram18Balance__c
                        , LoyaltyProgram19Balance__c
                        , LoyaltyProgram20Balance__c
                        , LoyaltyProgram1LowerLimit__c
                        , LoyaltyProgram2LowerLimit__c
                        , LoyaltyProgram3LowerLimit__c
                        , LoyaltyProgram4LowerLimit__c
                        , LoyaltyProgram5LowerLimit__c
                        , LoyaltyProgram6LowerLimit__c
                        , LoyaltyProgram7LowerLimit__c
                        , LoyaltyProgram8LowerLimit__c
                        , LoyaltyProgram9LowerLimit__c
                        , LoyaltyProgram10LowerLimit__c
                        , LoyaltyProgram11LowerLimit__c
                        , LoyaltyProgram12LowerLimit__c
                        , LoyaltyProgram13LowerLimit__c
                        , LoyaltyProgram14LowerLimit__c
                        , LoyaltyProgram15LowerLimit__c
                        , LoyaltyProgram16LowerLimit__c
                        , LoyaltyProgram17LowerLimit__c
                        , LoyaltyProgram18LowerLimit__c
                        , LoyaltyProgram19LowerLimit__c
                        , LoyaltyProgram20LowerLimit__c
                        , AdminFeesAmount__c
                        , CommissionsAmount__c
                        , AccountCountryCode__c
                        From Contact
                        Where id = :globalContact.Id]) {
        system.debug('## globalContact - lpCodeDisplayed  <<<<<' + globalContact);
        if (globalContact.LoyaltyProgramToBeDisplayed__c != null) {
          list<string> lpCodeDisplayed = globalContact.LoyaltyProgramToBeDisplayed__c.split(';');
          system.debug('## Class VFC01_OrderRecap - lpCodeDisplayed  <<<<<' + lpCodeDisplayed);
          for (String lpcode : allLps) {
            VFC01_LoyaltyProgramRecapDTO loyalty = new VFC01_LoyaltyProgramRecapDTO();
            if (lpcode.equalsIgnoreCase('LP1')) {
              if(LP_Reset_Per_Country__c.getInstance('LP1_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP1_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram1Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram1LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP2')) {
              if(LP_Reset_Per_Country__c.getInstance('LP2_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP2_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram2Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram2LowerLimit__c;
            }

            /*if (lpcode.equalsIgnoreCase('LP2') && c.AccountCountryCode__c == 'FRA') {
              loyalty.lpCode = lpcode;
              loyalty.totalPoint = 0;
              loyalty.lowerLimit = c.LoyaltyProgram2LowerLimit__c;
            }*/

            if (lpcode.equalsIgnoreCase('LP3')) {
              if(LP_Reset_Per_Country__c.getInstance('LP3_'+c.AccountCountryCode__c)==null ? false :LP_Reset_Per_Country__c.getInstance('LP3_'+c.AccountCountryCode__c).LP_isReset__c ){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram3Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram3LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP4')) {
              if(LP_Reset_Per_Country__c.getInstance('LP4_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP4_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram4Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram4LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP5')) {
              if(LP_Reset_Per_Country__c.getInstance('LP5_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP5_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram5Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram5LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP6')) {
              if(LP_Reset_Per_Country__c.getInstance('LP6_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP6_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram6Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram6LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP7')) {
              if(LP_Reset_Per_Country__c.getInstance('LP7_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP7_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram7Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram7LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP8')) {
              if(LP_Reset_Per_Country__c.getInstance('LP8_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP8_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram8Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram8LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP9')) {
              if(LP_Reset_Per_Country__c.getInstance('LP9_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP9_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram9Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram9LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP10')) {
              if(LP_Reset_Per_Country__c.getInstance('LP10_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP10_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram10Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram10LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP11')) {
              if(LP_Reset_Per_Country__c.getInstance('LP11_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP11_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram11Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram11LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP12')) {
              if(LP_Reset_Per_Country__c.getInstance('LP12_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP12_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram12Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram12LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP13')) {
              if(LP_Reset_Per_Country__c.getInstance('LP13_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP13_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram13Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram13LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP14')) {
              if(LP_Reset_Per_Country__c.getInstance('LP14_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP14_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram14Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram14LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP15')) {
              if(LP_Reset_Per_Country__c.getInstance('LP15_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP15_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram15Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram15LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP16')) {
              if(LP_Reset_Per_Country__c.getInstance('LP16_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP16_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram16Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram16LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP17')) {
              if(LP_Reset_Per_Country__c.getInstance('LP17_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP17_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram17Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram17LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP18')) {
              if(LP_Reset_Per_Country__c.getInstance('LP18_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP18_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram18Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram18LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP19')) {
              if(LP_Reset_Per_Country__c.getInstance('LP19_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP19_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram19Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram19LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('LP20')) {
              if(LP_Reset_Per_Country__c.getInstance('LP20_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('LP20_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.LoyaltyProgram20Balance__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = c.LoyaltyProgram20LowerLimit__c;
            }
            if (lpcode.equalsIgnoreCase('Adm')) {
              if(LP_Reset_Per_Country__c.getInstance('ADM_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('ADM_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.AdminFeesAmount__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = 0;
            }
            if (lpcode.equalsIgnoreCase('Com')) {
              if(LP_Reset_Per_Country__c.getInstance('COM_'+c.AccountCountryCode__c)==null ? false : LP_Reset_Per_Country__c.getInstance('COM_'+c.AccountCountryCode__c).LP_isReset__c){
                loyalty.totalPoint = 0;
              }else{
                loyalty.totalPoint = c.CommissionsAmount__c;
              }
              loyalty.lpCode = lpcode;
              loyalty.lowerLimit = 0;
            }

            if (loyalty.lowerLimit == null) {
              loyalty.lowerLimit = 0;
            }

            lpcodeTotalPointList.add(loyalty);
          }

          for (VFC01_LoyaltyProgramRecapDTO loyaltyCreated : lpcodeTotalPointList) {

            for (String lpCodeToDisplayed : lpCodeDisplayed) {

              if (loyaltyCreated.lpCode.equalsIgnoreCase(lpCodeToDisplayed)) {

                loyaltyCreated.isDisplay = true;

              }
            }
          }
        }
      }
    }

    AP16_LoyaltyProgramService_France service = new AP16_LoyaltyProgramService_France();

    return service.populateLoyaltyProgramName(lpcodeTotalPointList);

  }
//Mass Order

  private Boolean checkOffers = false;
  public void RefreshMassProductDetailsForOffers() {

    checkOffers = true;
    RefreshMassProductDetails();
    checkOffers = false;
  }
	
	public void RefreshMassProductDetails() {

		List<Id> listCTAId = new List<Id>();
		for (VFC01_ProductDetailDTO_France dto : massProductDetails) {
			if (dto.CTA_Id != null && String.isNotBlank(dto.localCode)) {
				listCTAId.add(dto.CTA_Id);

			}
		}
		Map<Id, CTA_CatalogArticle__c> mapCTA = new Map<Id, CTA_CatalogArticle__c>(
				[SELECT Id, Name, Article__c, TECH_ArticleRecordType__c, TECH_CatalogArticleDateInRange__c, MaximumQuantity__c, IsPushZone__c,
	             Catalog__r.Active__c,Catalog__r.EndDate__c,Catalog__r.StartDate__c, Catalog__r.Name, Catalog__r.CatalogueType__c, Catalog__c, Article__r.PriceLOrKg__c, Article__r.Type__c,
	             RegularPrice__c, Article__r.OnhandStockStatus__c, Article__r.StockStatusMessage__c, Article__r.Description__c,
	             Article__r.LocalCode__c, Article__r.Name, Article__r.Number_of_Articles__c, Article__r.Image__c, Article__r.LocalName__c, MeansPayment__c,
	             Article__r.BrandTerritory__c, Article__r.TECH_ExternalId__c, LoyaltyPrgUnit1__c , taxRate__c, Active__c,
	             CategoryLevelCommission__c, PublicPrice__c, DealerPrice__c, NetPrice__c, LoyaltyPrgVal1__c, LoyaltyPrgVal2__c,
	             LoyaltyPrgVal3__c, ValidTotalAmountBase__c,Article__r.ActiveProduct__c, AdminFees__c,Article__r.SmartReference__c, Commissionable__c, TECH_Catalog_type__c, TECH_CatalogExternalId__c
	             FROM CTA_CatalogArticle__c 
	             WHERE Active__c = true
	             AND TECH_CatalogArticleDateInRange__c = 'true'
	             AND TECH_ArticleRecordType__c <> :artFeeRecordTypeID
	             AND Catalog__c in (SELECT  c.Catalog__c From CAC_CatalogContact__c c where c.Dealer__c = :globalContact.Id
	             AND c.Active__c = true and c.TECH_CatalogDateInRange__c = 'true')
	             AND Id IN :listCTAId]);

	    for (VFC01_ProductDetailDTO_France dto : massProductDetails) {

        Boolean qtyChanged = false;

	    	dto.price = null;
	    	dto.errorMsg = null;

	    	if (dto.localCode == null || dto.localCode == '') {
	    		dto.CTA = null;
	    		dto.CTA_Id = null;
	    	}

	    	if (dto.CTA != null && dto.CTA.Id != dto.CTA_Id) {
	    		dto.CTA = null;
          dto.offers = new List<VFC01_ProductOfferDTO>();
        }

	    	if (dto.CTA_Id != null && mapCTA.containsKey(dto.CTA_Id)) {

    		if (dto.CTA_Id != null && dto.CTA != null && (dto.quantity == null || dto.quantity == '')) {
	    		dto.errorMsg = Label.ORD00139;
	    		dto.errorSeverity = 'error';
	    	} else {

	    			CTA_CatalogArticle__c cta = mapCTA.get(dto.CTA_Id);

            //if (cta != null)

		    		//dto.CTA = cta;
	        		dto.article = cta.Article__c;
			      //   if (dto.quantity == null || dto.quantity == '') {
				    //    dto.quantity = '1';//String.valueOf(quantity);
				    //    dto.quantityOld = 1;//quantity;
				    //}
		        dto.description = (cta.Article__r.Description__c == null) ?  '' : cta.Article__r.Description__c;
		        dto.stockStatus = cta.Article__r.OnhandStockStatus__c;
		        dto.stockMessage = getTranslatedPicklistValue(cta);
		        dto.localName = cta.Article__r.LocalName__c;
		        dto.localCode = cta.Article__r.LocalCode__c;
		        dto.name = cta.Article__r.Name;
		        dto.price = cta.PublicPrice__c;
		        dto.regularPrice = cta.RegularPrice__c;
		        dto.netPrice = cta.NetPrice__c;
		        dto.numberOfArticles = Integer.valueOf(cta.Article__r.Number_of_Articles__c);
		        dto.imageUrl = cta.Article__r.Image__c;
		        dto.isValidTotalAmountBase = cta.ValidTotalAmountBase__c;
		        dto.brandTerritory = cta.Article__r.BrandTerritory__c;
		        dto.isOffer = isOffer(cta);
		        dto.loyaltyPrgUnit1 = cta.LoyaltyPrgUnit1__c ;
		        dto.loyaltyPrgVal1 = String.valueOf(cta.LoyaltyPrgVal1__c) ;
		        dto.tax = cta.taxRate__c;
		        dto.activeProduct = cta.Article__r.ActiveProduct__c;
            dto.professionalUse = cta.Catalog__r.CatalogueType__c == 'Professional Use';
		        //System.debug('>>>>>> isOffer : ' + isOffer(cta));
		        AP16_LoyaltyProgramService_France loyaltyService = new AP16_LoyaltyProgramService_France();
		        getSubstitutionArticle(dto, cta);
		        extractMeansOfPaymentList(dto);
		        //if (dto.isLoyalProgram) {
		        //  dto.price = 0;
		        //}
		        /*if (dto.isOffer && dto.quantity != null && dto.quantity != '' ) {
		          dto.offers = new List<VFC01_ProductOfferDTO>();
		          createOffer(dto);
		        }*/		

		        dto.errorMsg = null;
        	 	dto.errorSeverity = 'error';
          	if (cta.Article__r.OnhandStockStatus__c == 'Out-of-stock' ) {

          	 	dto.errorMsg = Label.ORD00147;
          	} else if (dto.quantity != null && dto.quantity != '' && Integer.valueOf(dto.quantity) > dto.CTA.MaximumQuantity__c) {

  						dto.errorMsg = Label.ORD00169 + '. ' + Label.ORD00172 + dto.CTA.MaximumQuantity__c;					
          	} else if (cta.Article__r.StockStatusMessage__c != null && cta.Article__r.StockStatusMessage__c != '') {

          	 	dto.errorMsg = Label.ORD00160 + ' ' + (dto.hasCTASubstitution ? dto.CTASubstitution : cta.Article__r.StockStatusMessage__c);//;//
          	 	dto.errorSeverity = 'warning';
            } else if (cta.Article__r.OnhandStockStatus__c == 'Limited quantity' ) {

              dto.errorMsg = Label.ORD00210;
              dto.errorSeverity = 'warning';
          	}

            dto.sale = true;

          	if (dto.CTA == null) {
          		//Evol France dto.quantity = '1';
          		dto.quantityOld = 1;
             // dto.sale = false;
	        	//	dto.saleEnabled = false;
	        		//if (globalContact.Title == 'Privilege customer') {

              /*
	        		if (userCustomSettings.isPrivilegeCustomerProfile__c) {

            	dto.sale = false;
	        		} else if (!cta.Commissionable__c) {

            		dto.sale = false;
            		dto.saleEnabled = false;
            	} else if (cta.Commissionable__c && !cta.IsPushZone__c) {

            		dto.sale = true;
            		dto.saleEnabled = false;
            	} else if (cta.Commissionable__c && cta.IsPushZone__c) {

            		dto.sale = false;//true;
            		dto.saleEnabled = true;
            	}

            	//if (globalContact.Title == 'Privilege customer')
            	//	dto.sale = null;
              */

            } else if (dto.quantity != null && dto.quantity != '') {

              if (dto.quantityOld != null && dto.quantityOld != Integer.valueOf(dto.quantity)) {
                qtyChanged = true;
              }

              dto.quantityOld = Integer.valueOf(dto.quantity);
            }  

          	dto.CTA = cta;	

            if (dto.isOffer && dto.quantity != null && dto.quantity != '' ) {
                if ((!checkOffers && (dto.offers == null || dto.offers.isEmpty()))
                    || qtyChanged) {
                  dto.offers = new List<VFC01_ProductOfferDTO>();
                  createOffer(dto);
                }

                if (checkOffers)
                  validateQuantity(dto);
            }

      	}				
    	} else if (dto.localCode != null && dto.localCode != '') {
    		dto.errorMsg = Label.ORD00138;
    	} /*else if (dto.CTA_Id != null && (dto.quantity == null || dto.quantity == '')) {
    		dto.errorMsg = Label.ORD00139;
    	}*/
    }
	}

  /*
	public PageReference AddToBasketMassIta() {

		if (!blockAddToBasketMassOrderIta()) {

			AP16_LoyaltyProgramService_France loyaltyService = new AP16_LoyaltyProgramService_France();
			for (VFC01_ProductDetailDTO_France dto : massProductDetails) {
		    	if (dto.CTA_Id != null && dto.quantity != null && dto.quantity != '' && dto.localCode != null && dto.localCode != '') {

		    		if (dto.isLoyalProgram) {
		                dto.price = 0;
	              	}

					dto.loyaltyProgramDTO = loyaltyService.getLPAmount(extractMeansOfPaymentList(dto), Integer.valueOf(dto.quantity), dto.CTA, globalContact, null, dto.sale);
			   		loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramMouvement(dto.loyaltyProgramDTO, loyaltyProgramListRecap, false);
			      	basketDetail.addBasketDetail(dto.clone());
			  	}
		  	}

		  	basketDetail.updateTotalPrice();
			basketDetail.updateTotalArticle();

			updateTransportFees();
			
			basketDetail.infoMsg =  system.label.ORD00067;
			basketDetail.errMsg =  null;
			//productDetail = null;
			//globalArticleNameSearch = '';
			//clear the form when all articles have been added
			massProductDetails = VFC01_ProductDetailDTO_France.initialiseList();

		}

		refExistant = new List<String>();
    	return null;
	}
  */

  public static String getLPNameFromCode(Map<String, LPCode_Name__c> lpNameCodeMap, Contact globalContact, VFC01_ProductDetailDTO_France dto) {
    String label = '';
    if (dto.loyaltyProgramDTO != null) {
      label = '';
      if (dto.loyaltyProgramDTO.getToLpCodes() != null) {
          for (String lp : dto.loyaltyProgramDTO.getToLpCodes()) {
            if (lpNameCodeMap.containsKey(lp.toUpperCase()+'_'+globalContact.AccountCountryCode__c)) {
              if (globalContact.LoyaltyProgramToBeDisplayed__c.contains(lp)) {
                if (label != '') {label += ', '; }
                label += lpNameCodeMap.get(lp.toUpperCase()+'_'+globalContact.AccountCountryCode__c).LPName__c;
              }
            } 
          }
      } else {
          label = System.Label.ORD00100;
      }
    }

    return (label);
  }

  public PageReference AddToBasketMassIta() {

    //if (!blockAddToBasketMassOrderIta()) {

      // Retrieve the list of LP names
      Map<String, LPCode_Name__c> lpNameCodeMap = LPCode_Name__c.getAll();

      Set<Integer> setBlockingIndex = blockAddToBasketMassOrderIta();
      List<VFC01_ProductDetailDTO_France> newList = new List<VFC01_ProductDetailDTO_France>();
      AP16_LoyaltyProgramService_France loyaltyService = new AP16_LoyaltyProgramService_France();
      Integer counter = 0;
      for (VFC01_ProductDetailDTO_France dto : massProductDetails) {

        if (dto.CTA_Id != null && dto.quantity != null && dto.quantity != '' && dto.localCode != null && dto.localCode != ''
            && !setBlockingIndex.contains(counter)
          ) {

          if (dto.isLoyalProgram) {
            dto.price = 0;
          }

          dto.loyaltyProgramDTO = loyaltyService.getLPAmount(extractMeansOfPaymentList(dto), Integer.valueOf(dto.quantity), dto.CTA, globalContact, null, dto.sale);
          loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramMouvement(dto.loyaltyProgramDTO, loyaltyProgramListRecap, false);

          if (dto.isLoyalProgram) {
             dto.labelLP = '';//getLPNameFromCode(lpNameCodeMap, globalContact, dto);
             /* Happy project */
             String lpNames = getLPNameFromCode(lpNameCodeMap, globalContact, dto);
             String lpAmounts = dto.loyaltyProgramDTO.getLpAmount();
             if (lpNames != null && lpAmounts != null) {
              for (Integer i = 0 ; i < lpNames.split(',').size() ; i++) {
                if (i != 0) {
                  dto.labelLP += '<br/>';
                }
                dto.labelLP += lpNames.split(',')[i] + ' : ' + lpAmounts.split(';')[i]; 
              }
             }
          }

          basketDetail.addBasketDetail(dto.clone());
          
        } else {

          newList.add(dto.clone());          
        }
        counter++;
      }

      //massProductDetails.clear();
      massProductDetails = VFC01_ProductDetailDTO_France.initialiseList();
      counter = 0;
      for (VFC01_ProductDetailDTO_France dto : newList) {
        dto.price = null;
        massProductDetails[counter] = dto.clone();
        counter++;
      }      

      if (basketDetail.basketDetails != null && !basketDetail.basketDetails.isEmpty()) {
        basketDetail.updateTotalPrice();
        basketDetail.updateTotalArticle();

        updateTransportFees();
      }

      /* Happy project */
      checkMinOrderAmountForLP();
      
      //basketDetail.infoMsg =  system.label.ORD00067;
      //basketDetail.errMsg =  null;
      

      //List<Integer> listBlockingIndex = new List<Integer>(setBlockingIndex);
      //for(Integer index = listBlockingIndex.size()-1; index >= 0; index--)
      //{
      //    if (index != listBlockingIndex.get(index))
      //      massProductDetails.remove(index);
      //}

      //massProductDetails = VFC01_ProductDetailDTO_France.initialiseList();

    //}

    refExistant = new List<String>();
      return null;
  }

	private void updateTransportFees() {

		if (globalContact.TransportFeesApplicable__c) {
			List<VFC01_OrderAddress_France.ShippingModeDisplayed> lShippingModeDisplayed = 
					VFC01_OrderAddress_France.FindShippingModeDisplayed(lUids, 0.0, (Decimal)(basketDetail.totalPrice - basketDetail.totalPriceGift), 
			                                                            lShippingModeDeclared, 'BtoBtoC', globalContact,
			                                                            defaultSelected, selectedShippingMode, lShippingFees);
			if (lShippingModeDisplayed != null && lShippingModeDisplayed.size() > 0)
				basketDetail.updateTransportFees((Double)lShippingModeDisplayed[0].fee.Transport_fees__c, lShippingModeDisplayed[0].fee.Description__c);
		}
	}

	/* TO DELETE */
  //public void validateAddToBasketMass() {
  //  system.debug('### validateAddToBasketMass : Start');
  //  //check if no catalogs available for the dealer
  //  if (validateMassOrderCatalog()) {
  //    basketDetail.errMsg = system.label.ORD00053;
  //    return;
  //  }
  //  //Clear all error message from massInputs
  //  basketDetail.errMsg =  null;
  //  basketDetail.infoMsg = null;
  //  for (VFC01_ProductMassInputDTO dto : massInputs) {
  //    dto.errMsg = null;
  //  }

  //  refs = new List<String>();
  //  boolean found, perime, isItOffer, outOfStock, isProdActive, maxQtyExceeded;
  //  integer counter = 0, maxQty;
  //  //if no error at client side validation
  //  if (validateClientSideMO()) {
  //    List<CTA_CatalogArticle__c> listCatArt = [select ID
  //        , Catalog__c
  //        , article__r.LocalCode__c
  //        , catalog__r.Name
  //        , TECH_CatalogArticleDateInRange__c
  //        , TECH_ArticleRecordType__c
  //        , Article__r.OnhandStockStatus__c
  //        , Article__r.ActiveProduct__c
  //        , Active__c
  //        , MaximumQuantity__c
  //        from CTA_CatalogArticle__c
  //        //where Catalog__c = : dCats and article__r.LocalCode__c IN : refs and Article__r.ActiveProduct__c = true];
  //        where Catalog__c IN : lCatsId and Id IN : refs and Article__r.ActiveProduct__c = true];
  //    /*system.debug('### validateAddToBasketMass >>>>> dCats : ' + dCats);
  //    system.debug('### validateAddToBasketMass >>>>> refs : ' + refs);
  //    system.debug('### validateAddToBasketMass >>>>> listCatArt : ' + listCatArt);*/
  //    if (listCatArt.size() > 0 && listCatArt != null) {
  //      for (string myRefs : refs) {
  //        //initialise boolean variables
  //        found = false; perime = false; isItOffer = false; outOfStock = false; isProdActive = true; maxQtyExceeded = false; maxQty = 0;
  //        for (CTA_CatalogArticle__c dto : listCatArt) {
  //          //if (dto.article__r.LocalCode__c == myrefs) {
  //          if (dto.Id + '' == myrefs) {
  //            found = true;
  //            //add CTA to massinputs
  //            massInputs[counter].CTA = dto;
  //            //check if catalog active and date not outdated
  //            if (dto.TECH_CatalogArticleDateInRange__c == 'false' || !dto.Active__c) {
  //              perime = true;
  //            }
  //            //check if an offer
  //            if (isOffer(dto)) {
  //              isItOffer = true;
  //            }
  //            //check if product is out of stock
  //            if (dto.Article__r.OnhandStockStatus__c.equalsIgnoreCase('Out-of-stock')) {
  //              outOfStock = true;
  //            }
  //            //check if product active
  //            /* if(!dto.Article__r.ActiveProduct__c){
  //                 isProdActive=false;
  //             }*/
  //            //check if MaximumQuantity__c has not been exceeded per lines of massp input
  //            if (integer.valueOf(massInputs[counter].quantity) > dto.MaximumQuantity__c && dto.MaximumQuantity__c != null && dto.MaximumQuantity__c != 0) {
  //              maxQtyExceeded = true;
  //              maxQty = (integer)dto.MaximumQuantity__c;
  //            }
  //          }
  //        }
  //        if (found && !perime && !isItOffer && !outOfStock && isProdActive && !maxQtyExceeded) {
  //          refExistant.add(myrefs);
  //        } else {
  //          refExistant.add('BLANK');
  //          if (myrefs != 'BLANK') {
  //            if (!found) {
  //              massInputs[counter].errMsg = system.label.ORD00138/*'Product not found in catalog. Please enter the correct reference.'*/;
  //            } else {
  //              if (isItOffer) {
  //                massInputs[counter].errMsg = system.label.ORD00162/*'Product is an offer or a bundle. Please enter the another reference.'*/;
  //              } else {
  //                if (outOfStock) {
  //                  massInputs[counter].errMsg = system.label.ORD00147/*'Product is out of stock. Please enter the another reference.'*/;
  //                }
  //                if (perime) {
  //                  massInputs[counter].errMsg = system.label.ORD00158/*'Product found in catalog but expired. Please enter another reference.'*/;
  //                }
  //                /*if(!isProdActive){
  //                    massInputs[counter].errMsg = system.label.ORD00157/*'Product in catalog not active. Please enter another reference.';
  //                }*/
  //                if (maxQtyExceeded) {
  //                  massInputs[counter].errMsg = system.label.ORD00169 + '.' + system.label.ORD00172 + maxQty/*'Product Quantity orderable exceeded. Please enter the another qty.'*/;
  //                }
  //              }
  //            }
  //          }
  //        }
  //        counter++;
  //      }
  //    } else {
  //      //zero items have been found
  //      counter = 0;
  //      for (VFC01_ProductMassInputDTO dto : massInputs) {
  //        if (!refs[counter].equals('BLANK')) {
  //          dto.errMsg = system.label.ORD00138/*'Product not found in catalog'*/;
  //        }
  //        counter++;
  //      }
  //    }
  //  }
  //  system.debug('### refExistant.size() = : ' + refExistant.size());

  //}

  /* TO DELETE */
  /*public PageReference AddToBasketMass() {
    validateAddToBasketMass();
    //basketDetails size before
    //system.debug('### basketDetails.size before= : ' + basketDetail.basketDetails.size());
    if (!blockAddToBasketMassOrder()) {
      //go ahead with filling the basket no client side validation errors
      List<CTA_CatalogArticle__c> listCatArt = [select id
          , Article__c
          , TECH_ArticleRecordType__c
          , TECH_CatalogArticleDateInRange__c
          , Catalog__r.Active__c
          , Catalog__r.EndDate__c
          , Catalog__r.StartDate__c
          , Catalog__r.Name
          , Catalog__c
          , Article__r.PriceLOrKg__c
          , RegularPrice__c
          , Article__r.OnhandStockStatus__c
          , Article__r.StockStatusMessage__c
          , Article__r.Description__c
          , Article__r.LocalCode__c
          , Article__r.Name
          , Article__r.Number_of_Articles__c
          , Article__r.Image__c
          , Article__r.LocalName__c
          , Article__r.SmartReference__c
          , MeansPayment__c
          , Article__r.BrandTerritory__c
          , Article__r.TECH_ExternalId__c
          , LoyaltyPrgUnit1__c
          , taxRate__c
          , Active__c
          , CategoryLevelCommission__c
          , PublicPrice__c
          , DealerPrice__c
          , NetPrice__c
          , LoyaltyPrgVal1__c
          , LoyaltyPrgVal2__c
          , LoyaltyPrgVal3__c
          , ValidTotalAmountBase__c
          , AdminFees__c
          , Commissionable__c
          , TECH_Catalog_type__c
          , TECH_CatalogExternalId__c
          , MaximumQuantity__c
          from CTA_CatalogArticle__c
          //where Catalog__c = : dCats and article__r.LocalCode__c IN : refExistant and Article__r.ActiveProduct__c = true];
          where Catalog__c IN : lCatsId and Id IN : refExistant and Article__r.ActiveProduct__c = true];

      system.debug('### listCatArt.size() = : ' + listCatArt.size());

      for (integer i = 0; i < refExistant.size(); i++) {
        if (refExistant[i] != 'BLANK') {
          for (CTA_CatalogArticle__c ctamo : listCatArt) {
            //if (ctamo.Article__r.LocalCode__c == refExistant[i]) {
            if (ctamo.Id == refExistant[i]) {
              productDetail = new VFC01_ProductDetailDTO();
              //system.debug('### basketDetails.size before= : ' + basketDetail.basketDetails.size());
              productDetail.CTA = ctamo;
              productDetail.article = ctamo.Article__c;
              productDetail.quantity = massInputs[i].quantity;
              productDetail.quantityOld = integer.valueof(massInputs[i].quantity);
              productDetail.description = (ctamo.Article__r.Description__c == null) ?  '' : ctamo.Article__r.Description__c;
              productDetail.stockStatus = ctamo.Article__r.OnhandStockStatus__c;
              productDetail.stockMessage = getTranslatedPicklistValue(ctamo);
              productDetail.localName = ctamo.Article__r.LocalName__c;
              productDetail.localCode = ctamo.Article__r.LocalCode__c;
              productDetail.name = ctamo.Article__r.Name;
              productDetail.price = ctamo.PublicPrice__c;
              productDetail.regularPrice = ctamo.RegularPrice__c;
              productDetail.netPrice = ctamo.NetPrice__c;
              productDetail.numberOfArticles = Integer.valueOf(ctamo.Article__r.Number_of_Articles__c);
              productDetail.imageUrl = ctamo.Article__r.Image__c;
              productDetail.isValidTotalAmountBase = ctamo.ValidTotalAmountBase__c;
              productDetail.brandTerritory = ctamo.Article__r.BrandTerritory__c;
              productDetail.isOffer = isOffer(ctamo);
              productDetail.loyaltyPrgUnit1 = ctamo.LoyaltyPrgUnit1__c ;
              productDetail.loyaltyPrgVal1 = string.valueOf(ctamo.LoyaltyPrgVal1__c) ;
              productDetail.tax = ctamo.taxRate__c;
              productDetail.sale = massInputs[i].sale;
              system.debug('>>>>>> isOffer : ' + isOffer(ctamo));
              AP16_LoyaltyProgramService loyaltyService = new AP16_LoyaltyProgramService();
              extractMeansOfPaymentList(productDetail);
              if (productDetail.isLoyalProgram) {
                productDetail.price = 0;
              }
              //Populate credit and debit point for the order from orderlines paid with loyalty program
              productDetail.loyaltyProgramDTO = loyaltyService.getLPAmount(extractMeansOfPaymentList(productDetail), integer.valueOf(productDetail.quantity), productDetail.CTA, globalContact);
              loyaltyProgramListRecap = loyaltyService.getLoyaltyProgramMouvement(productDetail.loyaltyProgramDTO, loyaltyProgramListRecap, false);
              basketDetail.addBasketDetail(productDetail.clone());
            }
          }
        }
      }
      basketDetail.updateTotalPrice();
      basketDetail.updateTotalArticle();
      basketDetail.infoMsg =  system.label.ORD00067;
      basketDetail.errMsg =  null;
      productDetail = null;
      globalArticleNameSearch = '';
      //clear the form when all articles have been added
      massInputs = VFC01_ProductMassInputDTO.initialiseList();
    }
    //basketDetails size after
    //system.debug('### basketDetails.size after= : ' + basketDetail.basketDetails.size());
    //clear list for correct articles
    refExistant = new List<String>();
    return null;
  }*/

  public PageReference refreshInterface() {
    system.debug('### refreshInterface isMO : ' + isMO);
    if (isMO == 'true') {
      clearInfoErrMsg();
      isMass = true;
    } else {

      isMass = false;
    }
    return null;
  }

  public void clearInfoErrMsg() {
    basketDetail.infoMsg = null;
    basketDetail.errMsg = null;
  }

  public List<SelectOption> getDealerCatalogs() {
  	lOtherCatsId = new List<String>();
  	lPUCatsId = new List<String>();
    List<SelectOption> options = new List<SelectOption>();
    list<CAC_CatalogContact__c> myctalist = new list<CAC_CatalogContact__c>();

    if (globalContact != null) {

      string selectCatalogType = basketDetail.isOnlineOrder ? 'and Catalog__r.CatalogueType__c=\'Digital Catalog\'' : 'and Catalog__r.CatalogueType__c!=\'Digital Catalog\'';
      string querycat = 'SELECT  c.Catalog__c,catalog__r.Name, Catalog__r.CatalogueType__c From CAC_CatalogContact__c c where c.Dealer__c =  \'' + globalContact.Id + '\'' +
                        ' and c.Active__c = true and c.TECH_CatalogDateInRange__c = \'true\' ' + selectCatalogType + ' order by catalog__r.Priority__c desc';
      myctalist = database.query(querycat);
      system.debug('>>>>>> myctalist : ' + myctalist);
      if (myctalist != null && myctalist.size() > 0) {
        Boolean professionalUseCatalogexists = false, otherCatalogsExists = false;
        for (CAC_CatalogContact__c eachCat : myctalist) {
          //options.add(new SelectOption(string.valueOf(eachCat.Catalog__c), eachCat.catalog__r.Name));
          if (eachCat.Catalog__r.CatalogueType__c == 'Professional Use') {
          	professionalUseCatalogexists = true;
          	lPUCatsId.add(String.valueOf(eachCat.Catalog__c));
          } else {
          	otherCatalogsExists = true;
          	lOtherCatsId.add(String.valueOf(eachCat.Catalog__c));
          }
        }
  	  if (otherCatalogsExists)
  	      	options.add(new SelectOption('Other Catalogs', Label.ORD00208));
        if (professionalUseCatalogexists)
  	      	options.add(new SelectOption('Professional Use', Label.ORD00207));
        if (dCats == null) {
  	      if (professionalUseCatalogexists) {
  	      	dCats = 'Professional Use';
  			lCatsId = lPUCatsId;
  		  }
  	      if (otherCatalogsExists) {
  	      	//if (!professionalUseCatalogexists) {
  				dCats = 'Other Catalogs';
  				lCatsId = lOtherCatsId;
  			//}
  	      }
  	  }
      } else {
        options.add(new SelectOption('NO_VALUE', 'No Catalogs Available'));
        dCats = 'NO_VALUE';
      }
    }
    return options;
  }
  public boolean validateMassOrderCatalog() {
    if (dCats == 'NO_VALUE') {
      return true;
    }
    return false;
  }
  /**
  * Check if connected user is Manager
  * Using custom settings Mass_Order_Access__c
  */
  public Boolean hasMassOrderAccess() {
    //retrieve custom settings
    Mass_Order_Access__c userAccess = Mass_Order_Access__c.getInstance(UserInfo.getProfileId());
    System.debug('***userAccess.hasAccess__c ' + userAccess.hasAccess__c);
    return userAccess.hasAccess__c;
  }
  public boolean blockAddToBasketMassOrder() {
    for (VFC01_ProductMassInputDTO dto : massInputs) {
      if (dto.errMsg != null) {
        return true;
      }
    }
    if (validateMassOrderCatalog()) {
      return true;
    }
    return false;
  }
  /*public boolean blockAddToBasketMassOrderIta() {
  	Boolean block = false;
    for (VFC01_ProductDetailDTO_France dto : massProductDetails) {
   	  validateQuantity(dto);
      if ((dto.errorMsg != null && dto.errorMsg != '' && dto.errorSeverity == 'error' && dto.localCode != null && dto.localCode != '')) {
        block = true;
      }
    }
    if (validateMassOrderCatalog()) {
      block = true;
    }
    return block;
  }*/
  public Set<Integer> blockAddToBasketMassOrderIta() {
    //Boolean block = false;
    Set<Integer> setBlockingIndex = new Set<Integer>();
    Integer counter = 0;
    for (VFC01_ProductDetailDTO_France dto : massProductDetails) {
      validateQuantity(dto);
      if ((dto.errorMsg != null && dto.errorMsg != '' && dto.errorSeverity == 'error' && dto.localCode != null && dto.localCode != '')) {
        //block = true;
        setBlockingIndex.add(counter);
      }
      counter++;
    }
    //if (validateMassOrderCatalog()) {
    //  block = true;
    //}
    return setBlockingIndex;//block;
  }
  public void changeCatMO() {
    //massInputs = VFC01_ProductMassInputDTO.initialiseList();
    refExistant = new List<String>();
    basketDetail.infoMsg = null;
    basketDetail.errMsg = null;

    if (dCats == 'Professional Use')
    	lCatsId = lPUCatsId;
    else if (dCats == 'Other Catalogs')
    	lCatsId = lOtherCatsId;

    for (VFC01_ProductDetailDTO_France dto : massProductDetails) {
      if (dto.CTA_Id == null || String.isBlank(dto.localCode)) {
        dto.price = null;
      }
    }
  }

  /* TO DELETE */
  //public boolean validateClientSideMO() {
  //  integer allInvalidRef = 0;
  //  integer allBlank = 0;
  //  for (VFC01_ProductMassInputDTO dto : massInputs) {
  //    //system.debug('>>>>>> Quantity wchy : >>' + dto.quantity+'<<');
  //    if ((!(dto.productName == null || dto.productName == '' || dto.productName == ' ') && (!dto.quantity.isNumeric() ? 0 : integer.valueof(dto.quantity)) > 0)) {
  //      //system.debug('>>>>>> Quantity wchy1 : >>' + (!dto.quantity.isNumeric() ? 0 : integer.valueof(dto.quantity))+'<<');
  //      //refs.add(dto.productName);
  //      refs.add(dto.sfId);
  //    } else if ((dto.productName == null || dto.productName == '' || dto.productName == ' ') && (!dto.quantity.isNumeric() ? 0 : integer.valueof(dto.quantity)) != 0) {
  //      //system.debug('>>>>>> Quantity wchy2 : >>' + (!dto.quantity.isNumeric() ? 0 : integer.valueof(dto.quantity))+'<<');
  //      refs.add('INVALID_REF');
  //      allInvalidRef++;
  //      dto.errMsg = system.label.ORD00148 + ' ' + system.label.ORD00151 + ' ' + system.label.ORD00037/*'Invalid product reference for quantity'*/;
  //    } else if (!(dto.productName == null || dto.productName == '' || dto.productName == ' ') && (!dto.quantity.isNumeric() ? 0 : integer.valueof(dto.quantity)) == 0) {
  //      //system.debug('>>>>>> Quantity wchy3 : >>' + (!dto.quantity.isNumeric() ? 0 : integer.valueof(dto.quantity))+'<<');
  //      refs.add('INVALID_REF');
  //      allInvalidRef++;
  //      dto.errMsg = system.label.ORD00154 + ' ' + system.label.ORD00037/*'Invalid quantity for product reference'*/;
  //    } else {
  //      //system.debug('>>>>>> Quantity wchy4 : >>' + (!dto.quantity.isNumeric() ? 0 : integer.valueof(dto.quantity))+'<<');
  //      refs.add('BLANK');
  //      allBlank++;
  //    }
  //  }
  //  if (allBlank == massInputs.size()) {
  //    massInputs[0].errMsg = system.label.ORD00006/*'At least one product is required to save the order'*/;
  //    basketDetail.errMsg =  system.label.ORD00097;
  //    system.debug('### number of blank inputs  = : ' + allInvalidRef);
  //    return false;
  //  } else if (allInvalidRef > 0) {
  //    system.debug('### number of invalid inputs  = : ' + allInvalidRef);
  //    return false;
  //  } else {
  //    return true;
  //  }

  //}
  
  public List<String> getDocumentAdvertUrl() {
    //set contact country
    //contactCountry=globalOrder.Country_Code__c;
    if (globalContact != null) {
      contactCountry = globalContact.AccountCountryCode__c == null ? '' : globalContact.AccountCountryCode__c;
    } else {
      contactCountry = '_NONE_';
    }
    string fetchFolder = 'select id from Folder where DeveloperName =\'Stanhome_' + contactCountry + '\' '; string selectFolder = '';
    List<Folder> lstFolder = database.query(fetchFolder);
    if (lstFolder != null && lstFolder.size() > 0) {
      selectFolder = 'FolderId=\'' + lstFolder[0].id + '\' AND ';
    }
    string query = 'Select Id,Name,LastModifiedById from Document where ' + selectFolder + ' Name like \'' + system.label.ORD00178 + '%' + contactCountry + '\' Order by Name asc limit 2 ';
    List<Document> lstDocument = database.query(query);
    string strOrgId = UserInfo.getOrganizationId();
    List<String> strDocUrl = new List<String>();
    if (lstDocument != null && lstDocument.size() > 0) {
      for (Document eachDoc : lstDocument) {
        strDocUrl.add('https://' + ApexPages.currentPage().getHeaders().get('Host') + '/servlet/servlet.ImageServer?id=' + eachDoc.Id + '&oid=' + strOrgId);
      }
    }
    return strDocUrl;
  }
}