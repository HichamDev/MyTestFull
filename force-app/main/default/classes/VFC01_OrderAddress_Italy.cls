global without sharing class VFC01_OrderAddress_Italy {
/*
----------------------------------------------------------------------
-- - Name          : VFC01_OrderAddress_Italy 
-- - Author        : AMU
-- - Description   : Controller for VFP01_OrderAddress Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 08-OCT-2012  AMU     1.0      Initial version
-- 09-SEP-2013  HDU     1.0      Rework Version
----------------------------------------------------------------------
**********************************************************************
*/
    /*****************************************************************/
    /***************** Instantiating Global Variable *****************/
    /*****************************************************************/
    //Global Objects
    public ORD_Order__c newOrder {get; set;}
    //Global Id 
    public Id orderId {get;set;}
    public Id dealerId {get;set;}
    //Global Strings
    public String SdeliveryStreet {get;set;}
    public String deliveryStreet {get;set;}
    public String  exceptionalAddressComment {get;set;}
    public String exceptionalStreet {get;set;}
    public String exceptionalStreet2 {get;set;}
    public String exceptionalCity {get;set;}
    public String exceptionalState {get;set;}
    public String exceptionalPostalCode {get;set;}
    public String exceptionalCountry {get;set;}
    public String existingStreet {get;set;}
    public String existingCity {get;set;}
    public String existingState {get;set;}
    public String existingPostalCode {get;set;}
    public String existingCountry {get;set;}
    public String STHID {get;set;}
    public Double minOrder {get;set;}
    public String contactName {get;set;}
    public String campaign {get;set;}
    public String balanceColor {get;set;}
    public String currencyCode {get;set;}
    public String currentCommercial {get;set;}
    //contact country
    public String contactCountry {get;set;}
    //public String deliveryModeId {get;set;}
    //Global Booleans
    public Boolean adresseHabituelleFlag {get;set;}
    public Boolean badDebt {get;set;}
    public Boolean renderFlag {get;set;}
    //Global Date
    public Date lastDateToOrder {get;set;}
    public Datetime globalOrderLastModifiedDate {get;set;}
    //Global Double
    public Double currentBalance {get;set;} 
    public String errorNoDelivery{get;set;}
    public String errorMissingHabAdd{get;set;}
    public String errorMissingExepAdd{get;set;}
    public String errorNoSelectedDelivery{get;set;}
    public String errorEmptyAnswer{get;set;}
    public String errorOrderValidatedElsewhere{get;set;}
    public Contact globalContact {get;set;}
    //YGO 
    public Contact contactAdress {get;set;}
    public ORD_Order__c orderUpdate {get; set;}
    public ORD_Order__c orderToUpdate {get; set;} 
    public Account orderAccount {get; set;}  
    public string deliveryModeId {get; set;}
    
    
    public boolean isOnlineOrder {get;set;}
    //public string artFeeRecordTypeID {get;set;}

    // IK - Colissimo project -->
    public List<CountryCode_Name__c> lCountryIsoCode {get;set;}
    public String search_address {get;set;}
    public String search_postalCode {get;set;}
    public String search_city {get;set;}
    public String search_country {get;set;}
    public String search_weight {get;set;}
    public String errorColissimo {get;set;}

    public String addressType {get;set;} // Usual ou Exce

    public String colissimo_exc_street1 {get;set;}
    public String colissimo_exc_street2 {get;set;}
    public String colissimo_exc_street3 {get;set;}
    public String colissimo_exc_zipCode {get;set;}
    public String colissimo_exc_city {get;set;}
    public String colissimo_exc_state {get;set;}
    public String colissimo_exc_province {get;set;}
    public String colissimo_exc_country {get;set;}
    public String colissimo_mobilePhone {get;set;}

    public v2PointretraitGeopostCom.pointRetraitAcheminement pointSelected {get;set;}
    public String pointSelectedId {get;set;}
    public List<v2PointretraitGeopostCom.pointRetraitAcheminement> lPoints {get;set;}
    public String lPointsJson {get;set;}

    public Decimal packageWeight {get;set;}
    public Decimal orderAmountToConsider {get;set;}

    public List<ShippingModeDisplayed> lShippingModeDisplayed {get;set;}
    public Shipping_Mode__c selectedShippingMode {get;set;}
    public Integer defaultSelected{get;set;}
    public class ShippingModeDisplayed {
        public Shipping_Mode__c mode {get;set;}
        public Shipping_Fees__c fee {get;set;}
        public List<Shipping_Mode_Excluded__c> lZipCode {get;set;}
    }
    public String googleMapUrl {get;set;}

    public String markerLabels {get;set;}

    public Boolean feesApplicable {get;set;}

    // \ IK

    /*****************************************************************/
    /******************** Page Constructor ***************************/
    /*****************************************************************/
    public VFC01_OrderAddress_Italy (ApexPages.Standardcontroller controller){
        system.debug('## Class VFC01_OrderAddress_Italy - START VFC01_OrderAddress_Italy <<<<<'+UserInfo.getUserName());
        //Retrieving parameters
        orderId = System.currentPagereference().getParameters().get('orderId');
        dealerId = System.currentPagereference().getParameters().get('dealerId');   
        
        system.debug('>>>>>> parameters orderId: ' + orderId);
        system.debug('>>>>>> parameters dealerId: ' + dealerId);
        
        
        //Setting parameters
        ApexPages.currentPage().getParameters().put('Id',orderId);
        errorNoDelivery= system.label.ORD00129; 
        errorMissingHabAdd= system.label.ORD00130;
        errorMissingExepAdd=  system.label.ORD00131;   
        errorNoSelectedDelivery = system.label.ORD00132;
        errorEmptyAnswer = system.label.ORD00133;
        errorOrderValidatedElsewhere = system.label.ORD00173+'<a href="/'+orderId+'">'+system.label.ORD00184+'</a>';
        
        //YGO
       //   contactAdress = SHW_IBZ_Utils.getConnectedUserContact();
        orderUpdate = (ORD_Order__c)controller.getRecord();
         
        orderToUpdate = [Select  Id
                                , DeliveryStreet__c
                                , DeliveryStreet3__c
                                , DeliveryStreet2__c
                                , DeliveryStreet1__c
                                , DeliveryState__c
                                , DeliveryProvince__c
                                , DeliveryCountry__c
                                , DeliveryCity__c
                                , DeliveryAddressComment__c 
                                , DeliveryZipCode__c 
                                , Dealer__c
                                , AccountLabelQuestion1__c
                                , AccountLabelQuestion2__c
                                , AccountLabelQuestion3__c
                                , AccountLabelQuestion4__c
                                , AccountLabelQuestion5__c
                                , LabelQuestion1__c
                                , LabelQuestion2__c
                                , LabelQuestion3__c
                                , LabelQuestion4__c
                                , LabelQuestion5__c
                                , NumberOrderLines__c 
                                , TECH_CatalogExternalId__c
                                , TECH_NumberOrderLines__c
                                , TECH_NumberOfArticles__c
                                , TECH_TotalPrice__c
                                , OrderType__c
                                ,Transporter__c
                                ,TransportFees__c
                                , CustomerFirstName__c
                                , CustomerLastName__c
                                , LastModifiedDate
                                , CustomerMobile__c
                                , OrderMode__c
                                , Status__c
                                , PickUpStation_Street1__c
                                , PickUpStation_PostalCode__c
                                , PickUpStation_City__c
                                , PickUpStation_Country__c
                        From ORD_Order__c 
                        where ID =: orderUpdate.id];
        checkIfIsOnlineOrder();
        
        //retrieve last modified date
        globalOrderLastModifiedDate=orderToUpdate.LastModifiedDate;
        //retrive dealer details            
        contactAdress = [select     ID 
                            ,Name
                            ,STHID__c
                            ,TECH_campaign__c
                            ,CurrentBalance__c
                            ,LastDateToOrder__c
                            ,MinOrder__c
                            ,FirstName
                            ,LastName
                            ,MailingAddressComment__c
                            ,CurrentCommercialCycle__c
                            ,MailingStreet
                            ,MailingState
                            ,MailingPostalCode
                            ,MailingCountry
                            ,MailingCity
                            ,NbOrderForCurrentComCycle__c
                            ,AccountCountryCode__c
                            ,MobilePhone
                            ,TransportFeesApplicable__c
                    from Contact where Id= :dealerId];
        

        feesApplicable = contactAdress.TransportFeesApplicable__c;
        //Dafaulting values
        adresseHabituelleFlag = isAddressHab(orderToUpdate)==false && orderToUpdate.Transporter__c=='Standard' && isOnlineOrder ? true : isAddressHab(orderToUpdate);
        system.debug('>>> adresseHabituelleFlag: ' + adresseHabituelleFlag);
        if(adresseHabituelleFlag){
            SdeliveryStreet = 'HAB';
            deliveryStreet='HAB';
        }else{
            SdeliveryStreet = 'EXC';
            deliveryStreet='HAB';
        }

        system.debug('>>> after 1 ');

        //set contact country
        contactCountry=contactAdress.AccountCountryCode__c;
        //deliveryStreet = 'ExistingAdd'; 
        exceptionalStreet     = contactAdress.MailingStreet;
        exceptionalCity       = contactAdress.MailingCity;
        exceptionalState      = contactAdress.MailingState;
        exceptionalPostalCode = contactAdress.MailingPostalCode;
        exceptionalCountry    = contactAdress.MailingCountry;
        exceptionalAddressComment = contactAdress.MailingAddressComment__c;
        //set the exceptional delivery country to the dealer's contact mailing country 
        orderToUpdate.DeliveryCountry__c=contactAdress.MailingCountry;
        //fill header details
        STHID = contactAdress.STHId__c;
        minOrder = contactAdress.MinOrder__c;
        lastDateToOrder = contactAdress.LastDateToOrder__c;
        currentBalance = contactAdress.CurrentBalance__c;
        currentCommercial = contactAdress.CurrentCommercialCycle__c;
        
        system.debug('>>> after 2 ');
        //active delivery mode radio button if any
 //       setSelectedDeliveryMode();
       
       /* to delete *///
        //check if there are delivery mode + if habitualler address is complete
       //if (getDeliveryMode().size() <1){
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,errorNoDelivery));
       //}
       //else if(contactAdress.MailingPostalCode == null ||contactAdress.MailingCountry == null || contactAdress.MailingStreet == null  ||contactAdress.MailingCity == null ){
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,errorMissingHabAdd));
       //}// End if check address

       system.debug('>>> after 3 ');
       // IK - 201706
       // Get google map URL
       STHEndpoints__c endpt = [SELECT Id, Google_Endpoint__c, Google_Crypto_Key__c, Google_Client_Id__c, Google_Channel_Id__c
                                FROM STHEndpoints__c
                                WHERE Name =: contactAdress.AccountCountryCode__c
                                LIMIT 1];
       if (endpt != null ) {
        googleMapUrl = endpt.Google_Endpoint__c + '?client=' + endpt.Google_Client_Id__c + '&channel=' + endpt.Google_Channel_Id__c;
       }
       system.debug('>>> googleMapUrl: ' + googleMapUrl);
       // https://maps.googleapis.com/maps/api/js?key=AIzaSyDxASnV7XGr-9Sl5chmiQbYN6iW5giZ1So&channelId=dev_mystan_sh_fr_fr_web_vd

       // init variables
        addressType = 'Usual';
        markerLabels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

        lCountryIsoCode = CountryCode_Name__c.getAll().values();
        system.debug(lCountryIsoCode);

        search_address = contactAdress.MailingStreet;
        search_postalCode = contactAdress.MailingPostalCode;
        search_city = contactAdress.MailingCity;
        search_country = contactAdress.MailingCountry;
        colissimo_mobilePhone = contactAdress.MobilePhone;
        orderToUpdate.CustomerMobile__c = (orderToUpdate.CustomerMobile__c != '' && orderToUpdate.CustomerMobile__c != null ? orderToUpdate.CustomerMobile__c : contactAdress.MobilePhone);

        colissimo_exc_country = 'France';

        String modeCountry = '';
        for (CountryCode_Name__c country : lCountryIsoCode) {
            if (contactAdress.MailingCountry == country.CountryName__c) {
                modeCountry = country.Iso_Code__c;
                break;
            }
        }

        lPointsJson = '';

        pointSelected = null;
        pointSelectedId = null;
        errorColissimo = null;

        // Get the shipping modes available
        List<Shipping_Mode__c> lShippingModeDeclared = [SELECT Name, Default_selected__c, Label__c, Mode__c, Order__c, PickUpStation_Type__c, Picture_URL__c, Service_Login__c, Service_Password__c, Service_URL__c, Timeout__c, UID__c, Service_Param_Text_2__c, Service_Param_Text_1__c, Exclusion_parameter__c, Param_Text_1__c
                                                        FROM Shipping_Mode__c
                                                        WHERE Active__c = true
                                                        AND Country__c =: modeCountry
                                                        ORDER BY Order__c ASC];
        system.debug('>>> lShippingModeDeclared: ' + lShippingModeDeclared);
        List<String> lUids = new List<String>();
        for (Shipping_Mode__c mode : lShippingModeDeclared) {
            lUids.add(mode.UID__c);
            if (mode.Default_selected__c) {
                selectedShippingMode = mode;
            }
        }

        // Calculate the package weight
        AggregateResult[] soqlWeight = [SELECT SUM(Line_Weight__c)weight FROM ORL_OrderLine__c WHERE Order__c =: orderToUpdate.Id AND CatalogArticlesType__c != 'Gift'];
        // JBO : Add control if the weight is 0
        // Old : packageWeight = (Decimal)soqlWeight[0].get('weight');
        if (soqlWeight != null && soqlWeight[0] != null && soqlWeight[0].get('weight') != null) {
            packageWeight = (Decimal)soqlWeight[0].get('weight');
        } else {
            packageWeight = 0;
        }
        search_weight = String.valueOf(Integer.valueOf(packageWeight * 1000));
        

        // Calculate the order amount to consider for shipping fees
        AggregateResult[] soqlAmount = [SELECT SUM(AmountWihtoutTax__c)total FROM ORL_OrderLine__c WHERE Order__c =: orderToUpdate.Id AND ValidTotalAmountBase__c = true AND CatalogArticlesType__c != 'Gift'];
        orderAmountToConsider = (Decimal)soqlAmount[0].get('total');
        
        system.debug('>>> packageWeight: ' + packageWeight);
        system.debug('>>> orderAmountToConsider: ' + orderAmountToConsider);

        // Retrieve the shipping fees applicable
        List<Shipping_Fees__c> lShippingFees = [SELECT Amount_operator__c, Amount_value__c, Order_type__c, Shipping_Mode__c, Transport_fees__c, Weight_Operator__c, Weight_value__c, Description__c
                                                FROM Shipping_Fees__c
                                                WHERE Shipping_Mode__c in: lUids
                                                ORDER BY Name];
                                                // AND Order_type__c =: orderToUpdate.OrderMode__c
        system.debug(lShippingFees.size());

        lShippingModeDisplayed = FindShippingModeDisplayed(lUids, packageWeight, orderAmountToConsider, 
                                                                lShippingModeDeclared, orderToUpdate.OrderMode__c, contactAdress,
                                                                defaultSelected, selectedShippingMode, lShippingFees);
        
        Integer cpt = 0;
        for (ShippingModeDisplayed shipp : lShippingModeDisplayed){
            if (shipp.mode.Default_selected__c) {
                defaultSelected = cpt;
                selectedShippingMode = shipp.mode;
            }
        }
        cpt++;
        /*
        // Retrieve the shipping fees applicable
        List<Shipping_Fees__c> lShippingFees = [SELECT Amount_operator__c, Amount_value__c, Order_type__c, Shipping_Mode__c, Transport_fees__c, Weight_Operator__c, Weight_value__c
                                                FROM Shipping_Fees__c
                                                WHERE Shipping_Mode__c in: lUids
                                                ORDER BY Name];
                                                // AND Order_type__c =: orderToUpdate.OrderMode__c
        system.debug(lShippingFees.size());

        // If fees are found
        List<Shipping_Fees__c> lShippingFeesApplicable = new List<Shipping_Fees__c>();
        if (lShippingFees.size() > 0) {

            for (Shipping_Fees__c fee : lShippingFees) {
                system.debug(fee);

                Boolean weightMatch = false;
                Boolean amountMatch = false;
                Boolean orderTypeMatch = false;

                // Determinate if the order type match
                if (fee.Order_type__c == '*' || fee.Order_type__c == orderToUpdate.OrderMode__c) {
                    orderTypeMatch = true;
                }

                // Determinate if the weight condition match
                if (fee.Weight_Operator__c == '<' && weightMatch != true) {
                    if (packageWeight < fee.Weight_value__c) {
                        weightMatch = true;
                    }
                } else if (fee.Weight_Operator__c == '<=' && weightMatch != true) {
                    if (packageWeight <= fee.Weight_value__c) {
                        weightMatch = true;
                    }
                } else if (fee.Weight_Operator__c == '=' && weightMatch != true) {
                    if (packageWeight == fee.Weight_value__c) {
                        weightMatch = true;
                    }
                } else if (fee.Weight_Operator__c == '>' && weightMatch != true) {
                    if (packageWeight > fee.Weight_value__c) {
                        weightMatch = true;
                    }
                } else if (fee.Weight_Operator__c == '>=' && weightMatch != true) {
                    if (packageWeight >= fee.Weight_value__c) {
                        weightMatch = true;
                    }
                }

                // Determinate if the amount condition match
                if (fee.Amount_operator__c == '<' && amountMatch != true) {
                    if (orderAmountToConsider < fee.Amount_value__c) {
                        amountMatch = true;
                    }
                } else if (fee.Amount_operator__c == '<=' && amountMatch != true) {
                    if (orderAmountToConsider <= fee.Amount_value__c) {
                        amountMatch = true;
                    }
                } else if (fee.Amount_operator__c == '=' && amountMatch != true) {
                    if (orderAmountToConsider == fee.Amount_value__c) {
                        amountMatch = true;
                    }
                } else if (fee.Amount_operator__c == '>' && amountMatch != true) {
                    if (orderAmountToConsider > fee.Amount_value__c) {
                        amountMatch = true;
                    }
                } else if (fee.Amount_operator__c == '>=' && amountMatch != true) {
                    if (orderAmountToConsider >= fee.Amount_value__c) {
                        amountMatch = true;
                    }
                }

                // If the weight and amount matches
                if (weightMatch && amountMatch && orderTypeMatch) {
                    lShippingFeesApplicable.add(fee);
                }
            }


            // Retrieve the excluded zip code of the shipping mode applicable
            List<Shipping_Mode_Excluded__c> lZipCode = [SELECT Id, Shipping_Mode__c, Zip_code__c 
                                                        FROM Shipping_Mode_Excluded__c
                                                        WHERE Shipping_Mode__c in: lUids];

            // Check that a fee is available for all shipping mode displayed
            lShippingModeDisplayed = new List<ShippingModeDisplayed>();
            Integer cpt = 0;
            for (Shipping_Mode__c mode : lShippingModeDeclared) {
                Shipping_Fees__c rightFee = null;
                // Check if the shipping mode has a fee
                for (Shipping_Fees__c fee : lShippingFeesApplicable) {
                    if (fee.Shipping_Mode__c == mode.UID__c) {
                       rightFee = fee;
                       break;
                    }
                }

                // Check if the zip code of the coach is not excluded
                Boolean zipExcluded = false;
                List<Shipping_Mode_Excluded__c> lzipCodeExcludingByMode = new List<Shipping_Mode_Excluded__c>();
                for (Shipping_Mode_Excluded__c zipCode : lZipCode) {
                    if (zipCode.Shipping_Mode__c == mode.UID__c) {
                        lzipCodeExcludingByMode.add(zipCode);
                       if (zipCode.Zip_code__c.contains('*') ) {
                            string cleanZip = zipCode.Zip_code__c.replace('*', '');
                            if (contactAdress.MailingPostalCode.startsWith(cleanZip)) {
                                zipExcluded = true;
                            }
                       } else {
                            if (zipCode.Zip_code__c == contactAdress.MailingPostalCode) {
                                zipExcluded = true;
                            }
                       }
                    }
                }

                // If a fee is applicable and the zip code is not excluded, display the shipping mode
                if (rightFee != null && zipExcluded == false) {
                    ShippingModeDisplayed ship = new ShippingModeDisplayed();
                    ship.mode = mode;
                    ship.fee = rightFee;
                    ship.lZipCode = lzipCodeExcludingByMode;
                    if (mode.Default_selected__c) {
                        defaultSelected = cpt;
                        selectedShippingMode = mode;
                    }
                    lShippingModeDisplayed.add(ship);
                    cpt++;
                }
            }
            system.debug('>>> lShippingModeDisplayed : ' + lShippingModeDisplayed);
            if (lShippingModeDisplayed != null && defaultSelected == null && selectedShippingMode == null) {
                defaultSelected = 0;
                selectedShippingMode = lShippingModeDisplayed[0].mode;
            }

        }

        // In case of an update, select the previous shipping mode selected
        if (orderToUpdate.Status__c == 'Draft' || orderToUpdate.Status__c == 'Pending') {

            // In case of Colissimo selected previously
            if (orderToUpdate.PickUpStation_Street1__c != '' && orderToUpdate.PickUpStation_PostalCode__c != '' &&
                orderToUpdate.PickUpStation_City__c != '' && orderToUpdate.PickUpStation_Country__c != '' &&
                orderToUpdate.PickUpStation_Street1__c != null && orderToUpdate.PickUpStation_PostalCode__c != null &&
                orderToUpdate.PickUpStation_City__c != null && orderToUpdate.PickUpStation_Country__c != null) {

                // Set the address search to the one of the pick up station
                search_address = orderToUpdate.PickUpStation_Street1__c;
                search_postalCode = orderToUpdate.PickUpStation_PostalCode__c;
                search_city = orderToUpdate.PickUpStation_City__c;
                search_country = orderToUpdate.PickUpStation_Country__c;

                if (orderToUpdate.DeliveryStreet1__c != '' && orderToUpdate.DeliveryZipCode__c != '' &&
                    orderToUpdate.DeliveryCity__c != '' && orderToUpdate.DeliveryCountry__c != '' &&
                    orderToUpdate.DeliveryStreet1__c != null && orderToUpdate.DeliveryZipCode__c != null &&
                    orderToUpdate.DeliveryCity__c != null && orderToUpdate.DeliveryCountry__c != null) {
                    deliveryStreet = 'EXC';
                    colissimo_exc_street1 = orderToUpdate.DeliveryStreet1__c;
                    colissimo_exc_street2 = orderToUpdate.DeliveryStreet2__c;
                    colissimo_exc_street3 = orderToUpdate.DeliveryStreet3__c;
                    colissimo_exc_zipCode = orderToUpdate.DeliveryZipCode__c;
                    colissimo_exc_city = orderToUpdate.DeliveryCity__c;
                    colissimo_exc_country = orderToUpdate.DeliveryCountry__c;

                } else {
                    deliveryStreet = 'Usual';
                }
                

                // Set the colissimo mode as default
                if (lShippingModeDisplayed != null) {
                    Integer cpt = 0;
                    for (ShippingModeDisplayed md : lShippingModeDisplayed) {
                        if (md.mode.Mode__c == 'Externe_Colissimo') {
                            defaultSelected = cpt;
                            selectedShippingMode = md.mode;
                            break;
                        }
                        cpt++;
                    }
                }
            }
        }*/
                                

     } // Constructor

    public static List<ShippingModeDisplayed> FindShippingModeDisplayed(List<String> lUids, 
                                                    Decimal packageWeight, 
                                                    Decimal orderAmountToConsider, 
                                                    List<Shipping_Mode__c> lShippingModeDeclared,
                                                    String orderMode,
                                                    Contact contactAdress,
                                                    Integer defaultSelected,
                                                    Shipping_Mode__c selectedShippingMode,
                                                    List<Shipping_Fees__c> lShippingFees) {

        List<ShippingModeDisplayed> lShippingModeDisplayed = new List<ShippingModeDisplayed>();

        //// Retrieve the shipping fees applicable
        //List<Shipping_Fees__c> lShippingFees = [SELECT Amount_operator__c, Amount_value__c, Order_type__c, Shipping_Mode__c, Transport_fees__c, Weight_Operator__c, Weight_value__c
        //                                        FROM Shipping_Fees__c
        //                                        WHERE Shipping_Mode__c in: lUids
        //                                        ORDER BY Name];
        //                                        // AND Order_type__c =: orderToUpdate.OrderMode__c
        //system.debug(lShippingFees.size());

        // If fees are found
        List<Shipping_Fees__c> lShippingFeesApplicable = new List<Shipping_Fees__c>();
        if (lShippingFees.size() > 0) {

            for (Shipping_Fees__c fee : lShippingFees) {
                system.debug(fee);

                Boolean weightMatch = false;
                Boolean amountMatch = false;
                Boolean orderTypeMatch = false;

                // Determinate if the order type match
                if (fee.Order_type__c == '*' || fee.Order_type__c == orderMode) {//orderToUpdate.OrderMode__c) {
                    orderTypeMatch = true;
                }

                // Determinate if the weight condition match
                if (fee.Weight_Operator__c == '<' && weightMatch != true) {
                    if (packageWeight < fee.Weight_value__c) {
                        weightMatch = true;
                    }
                } else if (fee.Weight_Operator__c == '<=' && weightMatch != true) {
                    if (packageWeight <= fee.Weight_value__c) {
                        weightMatch = true;
                    }
                } else if (fee.Weight_Operator__c == '=' && weightMatch != true) {
                    if (packageWeight == fee.Weight_value__c) {
                        weightMatch = true;
                    }
                } else if (fee.Weight_Operator__c == '>' && weightMatch != true) {
                    if (packageWeight > fee.Weight_value__c) {
                        weightMatch = true;
                    }
                } else if (fee.Weight_Operator__c == '>=' && weightMatch != true) {
                    if (packageWeight >= fee.Weight_value__c) {
                        weightMatch = true;
                    }
                }

                // Determinate if the amount condition match
                if (fee.Amount_operator__c == '<' && amountMatch != true) {
                    if (orderAmountToConsider < fee.Amount_value__c) {
                        amountMatch = true;
                    }
                } else if (fee.Amount_operator__c == '<=' && amountMatch != true) {
                    if (orderAmountToConsider <= fee.Amount_value__c) {
                        amountMatch = true;
                    }
                } else if (fee.Amount_operator__c == '=' && amountMatch != true) {
                    if (orderAmountToConsider == fee.Amount_value__c) {
                        amountMatch = true;
                    }
                } else if (fee.Amount_operator__c == '>' && amountMatch != true) {
                    if (orderAmountToConsider > fee.Amount_value__c) {
                        amountMatch = true;
                    }
                } else if (fee.Amount_operator__c == '>=' && amountMatch != true) {
                    if (orderAmountToConsider >= fee.Amount_value__c) {
                        amountMatch = true;
                    }
                }

                // If the weight and amount matches
                if (weightMatch && amountMatch && orderTypeMatch) {
                    lShippingFeesApplicable.add(fee);
                }
            }


            // Retrieve the excluded zip code of the shipping mode applicable
            List<Shipping_Mode_Excluded__c> lZipCode = [SELECT Id, Shipping_Mode__c, Zip_code__c 
                                                        FROM Shipping_Mode_Excluded__c
                                                        WHERE Shipping_Mode__c in: lUids];

            // Check that a fee is available for all shipping mode displayed
            //lShippingModeDisplayed = new List<ShippingModeDisplayed>();
            Integer cpt = 0;
            for (Shipping_Mode__c mode : lShippingModeDeclared) {
                Shipping_Fees__c rightFee = null;
                // Check if the shipping mode has a fee
                for (Shipping_Fees__c fee : lShippingFeesApplicable) {
                    if (fee.Shipping_Mode__c == mode.UID__c) {
                       rightFee = fee;
                       break;
                    }
                }

                // Check if the zip code of the coach is not excluded
                Boolean zipExcluded = false;
                List<Shipping_Mode_Excluded__c> lzipCodeExcludingByMode = new List<Shipping_Mode_Excluded__c>();
                for (Shipping_Mode_Excluded__c zipCode : lZipCode) {
                    if (zipCode.Shipping_Mode__c == mode.UID__c) {
                        lzipCodeExcludingByMode.add(zipCode);
                       if (zipCode.Zip_code__c.contains('*') ) {
                            string cleanZip = zipCode.Zip_code__c.replace('*', '');
                            if (contactAdress.MailingPostalCode.startsWith(cleanZip)) {
                                zipExcluded = true;
                            }
                       } else {
                            if (zipCode.Zip_code__c == contactAdress.MailingPostalCode) {
                                zipExcluded = true;
                            }
                       }
                    }
                }

                // If a fee is applicable and the zip code is not excluded, display the shipping mode
                if (rightFee != null && zipExcluded == false) {
                    ShippingModeDisplayed ship = new ShippingModeDisplayed();
                    ship.mode = mode;
                    ship.fee = rightFee;
                    ship.lZipCode = lzipCodeExcludingByMode;
                    if (mode.Default_selected__c) {
                        defaultSelected = cpt;
                        selectedShippingMode = mode;
                    }
                    lShippingModeDisplayed.add(ship);
                    cpt++;
                }
            }
            system.debug('>>> lShippingModeDisplayed : ' + lShippingModeDisplayed);
            if (lShippingModeDisplayed != null && defaultSelected == null && selectedShippingMode == null) {
                defaultSelected = 0;
                selectedShippingMode = lShippingModeDisplayed[0].mode;
            }

        }

        return lShippingModeDisplayed;
    }

    public PageReference updateSelectedPickUpStation() {

        String identifiant = ApexPages.currentPage().getParameters().get('identifiant');
        
        errorColissimo = null;

        pointSelectedId = identifiant;
        pointSelected = null;

        if (identifiant != null) {
            for (v2PointretraitGeopostCom.pointRetraitAcheminement pt : lPoints) {
                system.debug(pt.identifiant + ' : ' + pt.nom);
                if (pt.identifiant.contains(identifiant)) {
                    pointSelected = pt; break;
                }
            }
        }

        return (null);
    }

    public PageReference updateSelectedMode() {
        String mode = ApexPages.currentPage().getParameters().get('mode');
        errorColissimo = null;
        if (lShippingModeDisplayed != null) {
            for (ShippingModeDisplayed md : lShippingModeDisplayed) {
                if (md.mode.Mode__c == mode) {
                    selectedShippingMode = md.mode;
                    break;
                }
            }
        }
        
        return (null);
    }

    public PageReference searchPointsAround() {
        system.debug('>>>>> searchPointsAround START');
        try {
        pointSelected = null;
        pointSelectedId = null;
        errorColissimo = null;

        String searchType = ApexPages.currentPage().getParameters().get('searchType');


        search_address = (searchType == 'Usual' ? search_address : colissimo_exc_street1);
        search_postalCode = (searchType == 'Usual' ? search_postalCode : colissimo_exc_zipCode);
        search_city = (searchType == 'Usual' ? search_city : colissimo_exc_city);
        search_country = (searchType == 'Usual' ? search_country : colissimo_exc_country);


        // Get the iso code of the country
        Boolean foundIsoCountry = false;
        for (CountryCode_Name__c country : lCountryIsoCode) {
            if (search_country == country.CountryName__c) {
                search_country = country.Iso_Code__c;
                foundIsoCountry = true;
                break;
            }
        }
        if (foundIsoCountry == false && search_country.length() == 2) { foundIsoCountry = true;}

        ShippingModeDisplayed dis = null;
        if (lShippingModeDisplayed != null) {
            for (ShippingModeDisplayed md : lShippingModeDisplayed) {
                if (md.mode.Mode__c == 'Externe_Colissimo') {
                    selectedShippingMode = md.mode;
                    dis = md;
                    break;
                }
            }
        }

        Boolean zipCodeOk = true;
        String zipcodeSearch = (searchType == 'Usual' ? contactAdress.MailingPostalCode : colissimo_exc_zipCode);
        for (Shipping_Mode_Excluded__c zipCode : dis.lZipCode) {
           if (zipCode.Zip_code__c.contains('*') ) {
                string cleanZip = zipCode.Zip_code__c.replace('*', '');
                if (zipcodeSearch.startsWith(cleanZip)) {
                    zipCodeOk = false; break;
                }
           } else {
                if (zipCode.Zip_code__c == zipcodeSearch) {
                    zipCodeOk = false; break;
                }
           }
        }

        if (foundIsoCountry && zipCodeOk && selectedShippingMode != null) {

            Date trueDate = Date.today() + 4;
            //String day = String.valueOf(Date.today().day() + 4);
            String day = String.valueOf(trueDate.day());
            String shippingDate = (Integer.valueOf(day) < 10 ? '0' +  day : day) + '/' + (trueDate.month() < 10 ? '0' + trueDate.month() : trueDate.month() + '')  + '/' + trueDate.year();

            ColissimoService_Handler.ResultClass result = ColissimoService_Handler.findPickUpStationNearAddress(Integer.valueOf(selectedShippingMode.Timeout__c), selectedShippingMode.Service_Url__c, selectedShippingMode.Service_Login__c, selectedShippingMode.Service_Password__c, search_address, search_postalCode, search_city, search_country,
            selectedShippingMode.Param_Text_1__c , shippingDate, selectedShippingMode.Service_Param_Text_1__c, '' + orderToUpdate.Id, search_country, selectedShippingMode.Service_Param_Text_2__c);
            if (result.success) {
                Set<String> sType = new Set<String>();

                // Keep only the right pick up station type
                if (selectedShippingMode.PickUpStation_Type__c != null && selectedShippingMode.PickUpStation_Type__c != '') {
                    sType.addAll(selectedShippingMode.PickUpStation_Type__c.split(';'));
                }
                lPoints = result.listPoints;

                // Get only the configured relais type
                if (sType != null && sType.size() > 0) {
                    lPoints = new List<v2PointretraitGeopostCom.pointRetraitAcheminement>();
                    for (v2PointretraitGeopostCom.pointRetraitAcheminement pt : result.listPoints) {
                        if (sType.contains(pt.typeDePoint)) {
                            lPoints.add(pt);
                        }
                    }
                }
                
                // Get only the configured relais names
                if (selectedShippingMode.Exclusion_parameter__c != null && selectedShippingMode.Exclusion_parameter__c != '') {
                    List<v2PointretraitGeopostCom.pointRetraitAcheminement> tmp = lPoints;
                    lPoints = new List<v2PointretraitGeopostCom.pointRetraitAcheminement>();
                    for (v2PointretraitGeopostCom.pointRetraitAcheminement pt : tmp) {
                        if (!pt.nom.contains(selectedShippingMode.Exclusion_parameter__c)) {
                            lPoints.add(pt);
                        }
                    }
                }

                Integer cpt = 0;
                for (v2PointretraitGeopostCom.pointRetraitAcheminement pt : lPoints) {
                    pt.markerLabel = markerLabels.substring(cpt, cpt+1);
                    pt.nomAffiche = (pt.nom.length() > 10 ? pt.nom.substring(0, 9) + '...' : pt.nom);
                    cpt++;
                }

                lPointsJson = Json.serialize(lPoints);
                errorColissimo = null;
            } else {
                errorColissimo = result.errorMessage;
               // lPoints = null;
               // lPointsJson = null;
            }
        }
        else
        {
            errorColissimo = Label.Colissimo_NoRelayPointFound;
            //lPoints = null;
            //lPointsJson = null;
        }        
        
        pointSelected = null;

        } catch (Exception e) {
            errorColissimo = e.getMessage();
            system.debug('>>>>> EXCEPTIOn:' + e.getMessage());
        }
        return (null);
    }




    private void checkIfIsOnlineOrder(){
     
        if(orderToUpdate != null && orderToUpdate.OrderType__c != null && orderToUpdate.OrderType__c.equals(VFC01_ProductBasketDTO_Italy.ONLINE_ORDER)){
            isOnlineOrder = true;
        }else{
            isOnlineOrder = false;
        }
    }
    
    public boolean isAddressHab(ORD_Order__c currentOrder){
        if( currentOrder.DeliveryStreet1__c == null || currentOrder.DeliveryStreet1__c == '' || currentOrder.DeliveryZipCode__c == null || currentOrder.DeliveryCity__c == null || currentOrder.DeliveryCountry__c == null )
        {
            return true;
        }
        return false;
    }


    public PageReference colissimoSelectAddress() {
        String mode = ApexPages.currentPage().getParameters().get('mode');
        deliveryStreet = mode;
        errorColissimo = null;
        return (null);
    }

    public PageReference standardSelectAddress() {
        String mode = ApexPages.currentPage().getParameters().get('mode');
        system.debug('>>>> standardSelectAddress : ' + mode);
        system.debug('>>>> deliveryStreet : ' + deliveryStreet);
        system.debug('>>>> SdeliveryStreet : ' + SdeliveryStreet);
        deliveryStreet = mode;
        SdeliveryStreet = mode;
        errorColissimo = null;
        system.debug('>>>> after deliveryStreet : ' + deliveryStreet);
        system.debug('>>>> after SdeliveryStreet : ' + SdeliveryStreet);
        return (null);
    }
    

    /*****************************************************************/
    /*****************************************************************/ 
    public void CheckAddress(){
        system.debug('## Class VFC01_OrderAddress_Italy - START CheckAddress <<<<<'+UserInfo.getUserName());
        if (deliveryStreet == 'EXC'){
            exceptionalStreet     = orderToUpdate.DeliveryStreet1__c;
            exceptionalStreet2    = orderToUpdate.DeliveryStreet2__c;
            exceptionalCity       = orderToUpdate.DeliveryCity__c;
            exceptionalState      = orderToUpdate.DeliveryState__c;
                    
        }
        system.debug('>>>>>> ExceptionalFlag: ' + adresseHabituelleFlag);
    }   
      
      public string getNumberCurrencyFormat(){
        System.debug('getNumberCurrencyFormat >>>>>>>'+Userinfo.getLocale());
        if(Userinfo.getLocale().equalsIgnoreCase('fr_FR_EURO')){
            
            //return '€{0, number, ###.###,00}';
            return '€{0, number, 0.00}';
            
        }else{
            
            return '€{0, number, 0.00}';
        }
        
      }

  
    /*****************************************************************/
    /******************* setSelectedDeliveryMode**********************/
    /*****************************************************************/ 
 //    public void setSelectedDeliveryMode(){
        //initlialise set of delivery Id
        /*
        list<Id> articleslist=  new list<Id>();
        list<String> catExternalIdlist=  new list<String>();
        //retrive delivery
        for (ORL_OrderLine__c ord :[Select name
                                               ,Amount__c
                                               ,Article__c
                                               ,RegularPrice__c
                                               ,Qty__c
                                               ,Order__c         
                                               ,ArticleDescription__c
                                               ,ArticleInternationalCode__c 
                                               ,ArticleLocalCode__c
                                               ,ArticleLocalName__c
                                               ,ArticleName__c                          
                                               ,TECH_ArticleType__c
                                               ,TECH_OfferBundleID__c
                                               ,TECH_DeleteIcon__c
                                               ,PublicPrice__c 
                                               ,TECHCatalogExternalId__c 
                                From ORL_OrderLine__c
                               Where Order__c = :orderId
                                 And TECH_ArticleType__c ='Fee']){
            articleslist.add(ord.Article__c);
            catExternalIdlist.add(ord.TECHCatalogExternalId__c); 
         }
         
        //retrieve and set corresponding catalogue Id;
        
       for(CTA_CatalogArticle__c catArticle : [Select Id,TaxRate__c, PublicPrice__c From CTA_CatalogArticle__c Where Article__c IN :articlesSet])
        {
            deliveryModeId = catArticle.Id;
        }//end for 
        
        for(CTA_CatalogArticle__c catArticle :[select Id 
                                                from CTA_CatalogArticle__c 
                                                where Article__c IN :articleslist and TECH_CatalogExternalId__c IN :catExternalIdlist])
        
        {
            deliveryModeId = catArticle.Id; 
        }//end for 
        
        */   
 //       if(string.isBlank(deliveryModeId)){
 //           deliveryModeId = 'None';
 //       }//end if deliveryModeId not blank
        
 //    }//end of  setSelectedDeliveryMode()
    
    /*****************************************************************/
    /************************ getItems *******************************/
    /*****************************************************************/ 
  /* to delete *///
 //   public List<SelectOption> getItems() {
 //       List<SelectOption> options = new List<SelectOption>(); 
 //       options.add(new SelectOption('ExistingAdd',system.label.ORD00043)); 
 //       options.add(new SelectOption('ExceptionalAdd',system.label.ORD00044)); 
 //       return options; 
 //   }
       
    
    /*****************************************************************/
    /******************** modifyOrder *************************/
    /*****************************************************************/  
    public PageReference modifyOrder(){
        //check if order has been validated/saved elsewhere
        if(isOrderValidated()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,errorOrderValidatedElsewhere));
            return ApexPages.currentPage();
         }// End if check last modified date
         else{
            system.debug('## Class VFC01_OrderAddress_Italy - START modifyOrder <<<<<'+UserInfo.getUserName());
            PageReference pageRef = Page.VFP01_OrderBasket_Italy;
            pageRef.getParameters().put('orderId',orderId);
            pageRef.getParameters().put('dealerId',dealerID);
            return pageRef;
         }
    }
    
    
    /*****************************************************************/
    /******************** getDeliveryCountry *************************/
    /*****************************************************************/     
 //   public List<SelectOption> getDeliveryCountry(){
 //       List<SelectOption> DeliveryCountry = new List<SelectOption>();
 //       if (exceptionalCountry <> null){
 //           DeliveryCountry.add(new SelectOption(exceptionalCountry,exceptionalCountry));
 //           Schema.DescribeFieldResult country = Schema.sObjectType.ORD_Order__c.fields.DeliveryCountry__c;

 //           for (Schema.PickListEntry countryPickVal : country.getPicklistValues()){
                    // create a selectoption for each pickval
 //               DeliveryCountry.add(new SelectOption(countryPickVal.getValue(),countryPickVal.getLabel()));
 //           }

 //       }
 //       return DeliveryCountry;
 //   }
    
    /*****************************************************************/
    /******************** getDeliveryMode    *************************/
    /*****************************************************************/     
 //   public List<SelectOption> getDeliveryMode(){
                
 //       List<SelectOption> DeliveryMode = new List<SelectOption>();
 //       DeliveryMode.add(new SelectOption('None',system.label.ORD00045));

        /*
        //Retrieving Fee recordtypeid for product
        ID artFeeRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART000c04 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        for(CTA_CatalogArticle__c cta: [Select id
                                               , Name
                                          From CTA_CatalogArticle__c
                                         Where  Active__c = true 
                                         and TECH_ArticleRecordType__c = :artFeeRecordTypeID 
                                         and Catalog__c in 
                                                (SELECT  c.Catalog__c 
                                                From CAC_CatalogContact__c c 
                                                where c.Dealer__c = :dealerId 
                                                and c.Active__c = true 
                                                and c.TECH_CatalogDateInRange__c = 'true')
                                         
                                         ]){
                                        // create a selectoption for each pickval
                                        DeliveryMode.add(new SelectOption(cta.Id,cta.Name));    
        }*/

 //       return DeliveryMode;
 //   }
    
    /*****************************************************************/
    /******************** ValidateAddress ****************************/
    /*****************************************************************/   

    public PageReference checkBeforeValidate() {
        system.debug('## Class VFC01_OrderAddress_Italy - START CheckAddress <<<<<'+UserInfo.getUserName());


        Integer deliverySize;
        ORD_Order__c order1;
        //Retrieving the delivery mode
        deliverySize = CheckDeliveryMode();

        System.debug(UserInfo.getUserId());
        
        Decimal transportFee = 0;
        String labelMode = '';
        for (ShippingModeDisplayed mode : lShippingModeDisplayed) {
            if (mode.mode.UID__c == selectedShippingMode.UID__c && feesApplicable) {
                transportFee = mode.fee.Transport_fees__c; labelMode = mode.mode.Label__c; break;
            }
        }

        //check if order has been validated/saved elsewhere
        if(isOrderValidated()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,errorOrderValidatedElsewhere));
            return ApexPages.currentPage();
         }// End if check last modified date

         //set value of order
        order1 = new ORD_Order__c  (id = orderId
                                     ,TECH_NumberOrderLines__c = deliverySize
                                     ,TECH_Status_state__c = 'Step_3'
                                     ,LabelQuestion1__c=orderToUpdate.LabelQuestion1__c
                                     ,LabelQuestion2__c=orderToUpdate.LabelQuestion2__c
                                     ,LabelQuestion3__c=orderToUpdate.LabelQuestion3__c
                                     ,LabelQuestion4__c=orderToUpdate.LabelQuestion4__c
                                     ,LabelQuestion5__c=orderToUpdate.LabelQuestion5__c
                                     ,Transporter__c=selectedShippingMode.Name
                                     ,TransportFees__c = transportFee
                                     ,Shipping_Mode_Label__c = labelMode
                                     );

        // Case #1 : Standard mode
        if (selectedShippingMode.Mode__c == 'Standard') {
            system.debug('>>>> STANDARD MODE');
            system.debug('>>>> SdeliveryStreet: ' + SdeliveryStreet);
            system.debug('>>>> deliveryStreet: ' + deliveryStreet);
            system.debug('>>>> orderToUpdate.DeliveryStreet1__c: ' + orderToUpdate.DeliveryStreet1__c);
            system.debug('>>>> orderToUpdate.DeliveryZipCode__c: ' + orderToUpdate.DeliveryZipCode__c);
            system.debug('>>>> orderToUpdate.DeliveryCity__c: ' +  orderToUpdate.DeliveryCity__c);
            system.debug('>>>> orderToUpdate.DeliveryCountry__c: ' + orderToUpdate.DeliveryCountry__c);
            //check mandatory field is exception address and  is all fills
            if(SdeliveryStreet == 'EXC' && ( orderToUpdate.DeliveryStreet1__c == null ||
                                        orderToUpdate.DeliveryStreet1__c == '' || 
                                        orderToUpdate.DeliveryZipCode__c == null ||
                                        orderToUpdate.DeliveryCity__c == null ||
                                        orderToUpdate.DeliveryCountry__c == null ))
            {           
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,errorMissingExepAdd));
                return ApexPages.currentPage();
            }
            //check if delivery address is habituelle and is incomplete
            if(SdeliveryStreet == 'HAB' && (contactAdress.MailingPostalCode == null ||contactAdress.MailingCountry == null || contactAdress.MailingStreet == null  || contactAdress.MailingCity == null )){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR ,errorMissingHabAdd));
                return ApexPages.currentPage();
            }// End if check address

            // Reset the pickupstation fields
            order1.DistributionCenter__c = '';
            order1.PickUpStation_Name__c = '';
            order1.PickUpStation_Street1__c = '';
            order1.PickUpStation_Street2__c = '';
            order1.PickUpStation_Street3__c = '';
            order1.PickUpStation_PostalCode__c = '';
            order1.PickUpStation_City__c = '';
            order1.PickUpStation_Country__c = '';

            if(SdeliveryStreet == 'EXC'){
            order1.DeliveryAddressComment__c = orderToUpdate.DeliveryAddressComment__c;
            order1.DeliveryStreet1__c = orderToUpdate.DeliveryStreet1__c;
            order1.DeliveryStreet2__c = orderToUpdate.DeliveryStreet2__c;
            order1.DeliveryStreet3__c = orderToUpdate.DeliveryStreet3__c;
            order1.DeliveryCity__c = orderToUpdate.DeliveryCity__c; 
            order1.DeliveryState__c = orderToUpdate.DeliveryState__c; 
            order1.DeliveryProvince__c = orderToUpdate.DeliveryProvince__c;
            order1.DeliveryZipCode__c = orderToUpdate.DeliveryZipCode__c; 
            //order1.DeliveryCountry__c = orderToUpdate.DeliveryCountry__c ;     
            order1.DeliveryCountry__c =  contactAdress.MailingCountry ;
        }
        else {
            order1.DeliveryAddressComment__c = null;
            order1.DeliveryStreet1__c = null;
            order1.DeliveryStreet2__c = null;
            order1.DeliveryStreet3__c = null;
            order1.DeliveryCity__c = null; 
            order1.DeliveryState__c = null; 
            order1.DeliveryProvince__c = null;
            order1.DeliveryZipCode__c = null; 
            order1.DeliveryCountry__c = null ;    
        }                                      
        }


        // Case #2 : Colissimo mode
        if (selectedShippingMode.Mode__c == 'Externe_Colissimo') {
            
            errorColissimo = '';

            if (deliveryStreet == 'EXC' && ( colissimo_exc_street1 == null ||
                                        colissimo_exc_street1 == '' || 
                                        colissimo_exc_zipCode == null ||
                                        colissimo_exc_city == null ||
                                        colissimo_exc_country == null ))
            {           
                errorColissimo = errorMissingExepAdd;
                return (null);
            }

            // Missing mobile number
            if (orderToUpdate.CustomerMobile__c == null || orderToUpdate.CustomerMobile__c == '') {
                errorColissimo = Label.ColissimoMissingMobilePhone;
                return (null);
            }

            // Check mobile phone format
            if (colissimo_exc_country == 'France' &&
                !Pattern.matches('^(06|07)[0-9]{8}$', orderToUpdate.CustomerMobile__c)) {
                errorColissimo = Label.Colissimo_MobilePhone_WrongFormat;
                return (null);
            }

            // Check pickupstation selected
            if (pointSelectedId == null || (pointSelectedId != null && pointSelectedId == '')) {
                errorColissimo = Label.Colissimo_PickUpStation;
                return (null);
            }


            for (v2PointretraitGeopostCom.pointRetraitAcheminement pt : lPoints) {
                if (pt.identifiant == pointSelectedId) {
                    pointSelected = pt; break;
                }
            }

            // Fill in the fields specific to Colissimo delivery
            order1.CustomerMobile__c = orderToUpdate.CustomerMobile__c;
            order1.DistributionCenter__c = pointSelected.identifiant;
            order1.PickUpStation_Name__c = pointSelected.nom;
            order1.PickUpStation_Street1__c = pointSelected.adresse1;
            order1.PickUpStation_Street2__c = pointSelected.adresse2;
            order1.PickUpStation_Street3__c = pointSelected.adresse3;
            order1.PickUpStation_PostalCode__c = pointSelected.codePostal;
            order1.PickUpStation_City__c = pointSelected.localite;
            order1.PickUpStation_Country__c = pointSelected.codePays;

            order1.DeliveryAddressComment__c = '';
            order1.DeliveryStreet1__c = colissimo_exc_street1;
            order1.DeliveryStreet2__c = colissimo_exc_street2;
            order1.DeliveryStreet3__c = colissimo_exc_street3;
            order1.DeliveryCity__c = colissimo_exc_city; 
            order1.DeliveryState__c = colissimo_exc_state; 
            order1.DeliveryProvince__c = colissimo_exc_province;
            order1.DeliveryZipCode__c = colissimo_exc_zipCode; 
            //order1.DeliveryCountry__c = orderToUpdate.DeliveryCountry__c ;     
            order1.DeliveryCountry__c =  colissimo_exc_country ;
            
        }

        try 
        {
            system.debug(order1);         
            update order1;

            // Go to Order recap page
            PageReference pageRef = Page.VFP01_OrderRecap_Italy;
            pageRef.getParameters().put('orderId',orderId);
            pageRef.getParameters().put('dealerId',dealerID);
            return PageRef;
        } catch (Exception e) {
            errorColissimo = e.getMessage();
            
        }
        return (null); 
    }   

    /* TO DELETE */
 //   public PageReference ValidateAddress(){
 //       system.debug('## Class VFC01_OrderAddress_Italy - START CheckAddress <<<<<'+UserInfo.getUserName());
        
        

 ////       // Case #1 : Standard mode
 //       if (selectedShippingMode.Mode__c == 'Standard') {

            
 //       }


        // Case #2 : Colissimo mode
 //       if (selectedShippingMode.Mode__c == 'Externe_Colissimo') {            
            
 //       }
        
        
                        
    


        // Go to Order recap page
 //       PageReference pageRef = Page.VFP01_OrderRecap;
 //       pageRef.getParameters().put('orderId',orderId);
 //       pageRef.getParameters().put('dealerId',dealerID);
 //       return PageRef;
 //   }
   
    /*****************************************************************/
    /*********************** CancelOrder *****************************/
    /*****************************************************************/
    public void CancelOrder(){
        system.debug('## Class VFC01_OrderRecipient - START CancelOrder <<<<<'+UserInfo.getUserName());
        
        //update status to draft
        if (orderId <> null){
            ORD_Order__c order1 = new ORD_Order__c  (id = orderId
                                                     , Status__c = SHW_IBZ_Constants.ORDER_STATUS_DRAFT);
            update(order1);
            
            deliveryStreet = 'ExistingAdd';
            CheckAddress();
        }
    }
    
    /*****************************************************************/
    /********************** CheckDeliveryMode ************************/
    /*****************************************************************/
    public Integer CheckDeliveryMode(){
        system.debug('## Class VFC01_OrderRecipient - START CheckDeliveryMode <<<<<'+UserInfo.getUserName());
        /*
        list<ORL_OrderLine__c> delModeList = new list<ORL_OrderLine__c>();

        //Check if delivery mode already exists
        list<ORL_OrderLine__c> existingDelModeList = [Select id
                                                             , TECH_ArticleType__c
                                                        From ORL_OrderLine__c
                                                       Where Order__c = :orderId
                                                         And TECH_ArticleType__c = 'Fee'];
                                                         
        system.debug('>>>>>>> existingDelModeList: ' + existingDelModeList);                                                     
                                                         
        if (existingDelModeList.size() > 0){
            delete(existingDelModeList);
        }
        
        for(CTA_CatalogArticle__c cta: [SELECT Name
                                               , id
                                               , Article__c
                                               , TECH_ArticleRecordType__c
                                               , TECH_ExternalId__c
                                               , Catalog__r.Name
                                               , Catalog__c
                                               , Article__r.PriceLOrKg__c
                                               , RegularPrice__c
                                               , PublicPrice__c
                                               , Article__r.OnhandStockStatus__c
                                               , Article__r.Description__c
                                               , Article__r.LocalCode__c
                                               , Article__r.LocalName__c
                                               , Article__r.Name
                                               , Article__r.Number_of_Articles__c
                                               , Article__r.InternationalCode__c 
                                               ,TECH_CatalogExternalId__c
                                        from CTA_CatalogArticle__c 
                                        where  id = :deliveryModeId ])
        {
            ORL_OrderLine__c off = new ORL_OrderLine__c();
            off.Order__c = orderId;
            off.Article__c = cta.Article__c;
            off.TECH_ArticleDescription__c = cta.Article__r.Description__c;
            off.ArticleInternationalCode__c  = cta.Article__r.InternationalCode__c;
            off.ArticleLocalCode__c = cta.Article__r.LocalCode__c;
            off.ArticleLocalName__c = cta.Article__r.LocalName__c;
            off.ArticleName__c = cta.Article__r.Name; 
            off.RegularPrice__c = cta.RegularPrice__c;
            off.PublicPrice__c = cta.PublicPrice__c;
            off.AmountWihtoutTax__c = cta.PublicPrice__c;
            off.Amount__c = cta.PublicPrice__c;
            off.Qty__c = 1;
            off.TECH_DeleteIcon__c = '';
            off.TECH_ArticleType__c = 'Fee';
            off.TECHCatalogExternalId__c =  cta.TECH_CatalogExternalId__c;  
            delModeList.add(off);
        }
        
        system.debug('>>>>>>> delModeList: ' + delModeList);    
        if(delModeList.size()> 0 ){
            insert (delModeList);
        }
        */
        list<ORL_OrderLine__c> delModesizeList = [Select id
                                                    From ORL_OrderLine__c
                                                    Where Order__c = :orderId];
        
        return delModesizeList.size();
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
    
    public String getZonePromoUrl(){
        
        return getIframeUrl(1);
    }
    
    public String getAreaEmbededUrl(){
        
        return getIframeUrl(2);
    }
    
    /**** NEW METHODS ADDED BY YGO ****/
    public List<SelectOption> getItemss() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('ExistingAdd','Votre adresse habituelle')); 
        return options; 
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
    /*****************************************************************/
    /************************ get field labels **********************/
    /*****************************************************************/
   public List<string> getFieldLabel(List<string> theFieldNames) {
        system.debug('## Class VFP01_OrderAddress - getFieldLabel <<<<<'+UserInfo.getUserName());
        
        String type= 'ORD_Order__c'; 
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
  /**
  * Check if order has been validated/saved elsewhere
  */
  private boolean isOrderValidated() {
    //compare the LastModifiedDate field of object Order, in case order was modified elsewhere 
    List<ORD_Order__c> theListStatus = new List<ORD_Order__c>();
    boolean checkStatus = false;
    if (orderToUpdate.Id != null) {
      theListStatus = [select Id, Status__c, TECH_BO_ExtractionStatus__c,LastModifiedDate from ORD_Order__c where Id = : orderToUpdate.Id];
    }
    if (theListStatus != null && theListStatus.size() > 0) {
      if(theListStatus[0].LastModifiedDate!=globalOrderLastModifiedDate){
        checkStatus = true;
      }
    }

    return checkStatus;

  }
  
  /**
  * call private functions for class test use alone
  */
  Public void callAllPrivateFunctionForTestClass(){
      isOrderValidated();
  }
}