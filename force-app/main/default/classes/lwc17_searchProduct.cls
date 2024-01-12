public without sharing class lwc17_searchProduct {

    /* CONSTANTS */
    public static final Set<String> STOCK_STATUS_TO_MANAGE = new Set<String>{ 'Dynamic', 'DynamicWithoutMessage', 'Out-of-stock', 'Temporarily out-of-stock' };
    public static final Set<String> STOCK_STATUS_OUTOFSTOCK = new Set<String>{ 'Out-of-stock', 'Temporarily out-of-stock' };
    public static final Set<String> STOCK_STATUS_LIMITED = new Set<String>{ 'Limited quantity' };
    public static final String STOCK_PRODUCT_RT_BUNDLE = 'LU_Bundle';
    public static final String STOCK_SUBSTITUTE_SEPARATOR = '#';

    public class wrapperCounters {
        @AuraEnabled
        public String counters {get;set;}
        @AuraEnabled
        public List<AP1002_LookupSearchResult.Counter> l_counters {get;set;}
    }
    
    @AuraEnabled
    public static List<AP1002_LookupSearchResult> searchProduct(String searchTerm, List<Id> selectedIds, String offerType, String contactStr) {

        Boolean isWebOnly = false;
        if(offerType == 'WEB'){
            isWebOnly = true;
        }

        List<LU_ProductSearchRule__mdt> vListProdSearchRules = [SELECT Id, Country__c, How__c, What__c FROM LU_ProductSearchRule__mdt];

        // Variables
        List<AP1002_LookupSearchResult> lRes = new List<AP1002_LookupSearchResult>();
        String country = null;
        String techExternalId = null;
        Id contactId = null;
        String prodCodeSearchTerm = '';
        String prodNameSearchTerm = '';

        // Manage the contact selected or current dealer
        Boolean useCurrentUser = false;
        if (contactStr != null && contactStr != '' && contactStr != 'null') {
            Contact contactTeamMember = (Contact)JSON.deserialize(contactStr, Contact.class);
            contactId = contactTeamMember.Id;
            Contact contactTemp = null;
            if (contactId != null) {
                contactTemp = AP1003_Utils_Contact.getContactInfo(contactId);
                if (contactTemp.RecordType.DeveloperName != 'LU_Personal_Contact') {
                    country = contactTemp.AccountCountryCode__c;
                    techExternalId = country + '%';                   
                } else {
                    useCurrentUser = true;
                }
            } else {
                useCurrentUser = true;
            }
        } else {
            useCurrentUser = true;
        }

        if (useCurrentUser) {
            Id userId = UserInfo.getUserId();
            User u = [SELECT TECH_MergeContactID__c FROM User WHERE Id = :userId];
            country = AP1002_Utils_User.getUserCountry(userId);
            techExternalId = country + '%';
            contactId = u.TECH_MergeContactID__c;
        }

        //SFT-1696, In case of numberic search, only order number should be searched else name only
		if(country == 'FRA' || country == 'ITA')  {
			if(searchTerm.isNumeric()) {
                prodCodeSearchTerm = searchTerm + '%';
            } else {
                prodNameSearchTerm = '%' + searchTerm + '%';
            }
		}

        // Get contact information : balances
        Contact con = [SELECT LU_Counter_1_Name__c, LU_Counter_2_Name__c, LU_Counter_3_Name__c, LU_Counter_4_Name__c, LU_Counter_5_Name__c, 
        LU_Counter_6_Name__c, LU_Counter_7_Name__c, LU_Counter_8_Name__c, LU_Counter_9_Name__c, LU_Counter_10_Name__c, LU_Counter_11_Name__c, 
        LU_Counter_12_Name__c, LU_Counter_13_Name__c, LU_Counter_14_Name__c, LU_Counter_15_Name__c, LU_Counter_16_Name__c, LU_Counter_17_Name__c, 
        LU_Counter_18_Name__c, LU_Counter_19_Name__c, LU_Counter_20_Name__c, LU_Counter_21_Name__c, LU_Counter_22_Name__c, LU_Counter_23_Name__c, 
        LU_Counter_24_Name__c, LU_Counter_25_Name__c, LU_Counter_26_Name__c, LU_Counter_27_Name__c, LU_Counter_28_Name__c, LU_Counter_29_Name__c, 
        LU_Counter_30_Name__c, LU_Counters_Unit__c, LU_Counters_Unit_Bis__c, LU_Eligibility_Groups__c
        FROM Contact
        WHERE Id = :contactId];

        // Eligibility segment of contact
        Set<String> sEligibilitySegmentOfContact = new Set<String>();
        if (con.LU_Eligibility_Groups__c != null && con.LU_Eligibility_Groups__c != '') {
            for (String groupEligibilty : con.LU_Eligibility_Groups__c.split('#')) {
                sEligibilitySegmentOfContact.add(groupEligibilty);
            }
        }

        // Manage Offer Type
        // for italy , if 'Personal Use' choosed, add 'Professional Use' and 'Gift'
        // Otherwise, just keep the offer type selected
        List<String> lOfferType = new List<String>();
        if (offerType == Label.LU_Offer_Type_PersonalUse) {
            lOfferType.add(Label.LU_Offer_Type_PersonalUse);
            lOfferType.add(Label.LU_Offer_Type_Gift);
            lOfferType.add(Label.LU_Offer_Type_ProfessionalUse);
        } else {
            lOfferType.add(offerType);
        }

        List<PriceBookEntry> l_product = new List<PriceBookEntry>();
        if(isWebOnly == true){
            l_product = [SELECT Id, LU_Offer_type__c, Name, UnitPrice, Product2.LU_Number_Of_Articles__c, Product2.RecordType.Name, 
                                Product2.RecordType.DeveloperName, Product2Id, LU_Maximum_Quantity__c, 
                                PriceBook2Id, LU_Valid_For_Total_Amount_Base__c, LU_TaxRate__c, LU_Counter_Value__c, Product2.Description,
                                Product2.LU_Local_Code__c, Product2.LU_Stock_Status__c, Product2.LU_Stock_Available__c, Product2.LU_Smart_Reference__c, Product2.LU_Brand__c, Product2.LU_Brand_Territory__c ,
                                Discount_Type__c, LU_Dealer_Price__c, LU_Public_Price__c, LU_TECH_External_Id__c, Product2.LU_Bundle_Type__c, LU_Eligibility_Segments__c, Product2.LU_TECH_External_Id__c
                                FROM PriceBookEntry 
                                WHERE Id NOT IN :selectedIds
                                AND LU_Start_Date__c <= :Datetime.now()
                                AND LU_End_Date__c >= :Datetime.now()
                                AND LU_TECH_External_Id__c LIKE :techExternalId
                                AND IsActive = true
                                AND LU_Offer_type__c in :lOfferType
                                AND ( Product2.RecordType.DeveloperName = 'LU_Bundle'
                                    OR Product2.RecordType.DeveloperName = 'LU_Product'
                                )
                                AND Pricebook2.Name != 'Catalogue standard'
                                AND Pricebook2.IsActive = true
                                AND (
                                    Product2.LU_Local_Code__c LIKE :prodCodeSearchTerm
                                    OR Product2.Name LIKE :prodNameSearchTerm
                                )
                                ORDER BY LU_Tech_Search_Order_By__c, LU_TECH_Catalog_Code__c
                            ];  
        }else{
            l_product = [SELECT Id, LU_Offer_type__c, Name, UnitPrice, Product2.LU_Number_Of_Articles__c, Product2.RecordType.Name, 
                                Product2.RecordType.DeveloperName, Product2Id, LU_Maximum_Quantity__c, 
                                PriceBook2Id, LU_Valid_For_Total_Amount_Base__c, LU_TaxRate__c, LU_Counter_Value__c, Product2.Description,
                                Product2.LU_Local_Code__c, Product2.LU_Stock_Status__c, Product2.LU_Stock_Available__c, Product2.LU_Smart_Reference__c, Product2.LU_Brand__c, Product2.LU_Brand_Territory__c ,
                                Discount_Type__c, LU_Dealer_Price__c, LU_Public_Price__c, LU_TECH_External_Id__c, Product2.LU_Bundle_Type__c, LU_Eligibility_Segments__c, Product2.LU_TECH_External_Id__c
                                FROM PriceBookEntry 
                                WHERE Id NOT IN :selectedIds
                                AND LU_Start_Date__c <= :Datetime.now()
                                AND LU_End_Date__c >= :Datetime.now()
                                AND LU_TECH_External_Id__c LIKE :techExternalId
                                AND IsActive = true
                                AND LU_Offer_type__c in :lOfferType
                                AND ( Product2.RecordType.DeveloperName = 'LU_Bundle'
                                    OR Product2.RecordType.DeveloperName = 'LU_Product'
                                )
                                AND Pricebook2.Name != 'Catalogue standard'
                                AND Pricebook2.IsActive = true
                                AND (
                                    Product2.LU_Local_Code__c LIKE :prodCodeSearchTerm
                                    OR Product2.Name LIKE :prodNameSearchTerm
                                )
                                AND (
                                    LU_Eligibility_Segments__c = '*' 
                                    OR LU_Eligibility_Segments__c LIKE :sEligibilitySegmentOfContact
                                )
                                ORDER BY LU_Tech_Search_Order_By__c, LU_TECH_Catalog_Code__c
                            ];  
        }

        if (!l_product.isEmpty()) {

            // Get stock settings
            LU_Order_Rule__c lowLimitSetting = AP1011_Stock_Utils.getLowLimitThreshold(country);

            // Get stock status of products
            Set<String> sProductLocalCodes = AP1011_Stock_Utils.getProductLocalCodeOfPricebookEntries(l_product);
            List<Id> l_idProduct = new List<Id>();
            for(PriceBookEntry pB : l_product){
                l_idProduct.add(pB.product2Id);
            }

            List<AP1011_Stock_Utils.StockStatus> lStockStatus = getStockRemainingForProducts(l_idProduct, sProductLocalCodes, sEligibilitySegmentOfContact, offerType, country);

            for (PriceBookEntry pbe : l_product) {
                // Init the search result
                AP1002_LookupSearchResult res = new AP1002_LookupSearchResult();

                /* Check the stock information */
                // Get the product status
                AP1011_Stock_Utils.StockStatus stockStatusOfProduct = AP1011_Stock_Utils.getProductStockStatusFromList(lStockStatus, pbe.Product2.LU_Local_Code__c);
                Boolean isUnderLowLimitThreshold = false;
                Boolean isOutOfStock = false;

                if (stockStatusOfProduct != null) {
                    isUnderLowLimitThreshold = AP1011_Stock_Utils.isProductUnderLowLimitThreshold(lowLimitSetting.LU_Value__c, stockStatusOfProduct);
                }

                if (isUnderLowLimitThreshold && AP1011_Stock_Utils.STOCK_STATUS_OUTOFSTOCK.contains(stockStatusOfProduct.stockStatus) || stockStatusOfProduct == null) {
                    isOutOfStock = false;
                }
                else{
                    isOutOfStock = isProductOutOfStock(stockStatusOfProduct);
                }

                res.imageUrl = 'A';

                // If the product is out of stock, check if a substitute can be used instead
                if (isOutOfStock) {
                    
                    res.imageUrl = 'B';

                    // If the product has substitute
                    if (stockStatusOfProduct.lSubstituteProducts != null && !stockStatusOfProduct.lSubstituteProducts.isEmpty()) {

                        res.imageUrl = 'C';

                        for (AP1011_Stock_Utils.StockStatus stSubstitute : stockStatusOfProduct.lSubstituteProducts) {

                            res.imageUrl = 'D';
                            
                            if (stSubstitute.stockRemaining != null && stSubstitute.stockRemaining > 0) {

                                res.imageUrl = 'E';

                                for (PricebookEntry entrySub : stSubstitute.lPricebookEntriesOfSubstituteOffers) {

                                    res.imageUrl = 'F';
                                    
                                    if (country == 'ITA' || (country == 'FRA' && entrySub.LU_Eligibility_Segments__c == pbe.LU_Eligibility_Segments__c) ) {

                                        res.imageUrl = 'G';

                                        res.isSubstituteArtile = true;
                                        wrapperCounters wrCountersSubStitute = setCountersValues(con, entrySub, country); // stSubstitute.pricebookEntryOfSubstituteOffer,
                                        res.subsituteArticle = setValuesOnSearchResultSubstitute(entrySub, wrCountersSubStitute, false, false, 
                                                                                                    stSubstitute, lowLimitSetting); // stSubstitute.pricebookEntryOfSubstituteOffer,
                                        break;
                                    }
                                }
                                
                            }
                        }
                    }
                }

                // Get the counters of the offer to be displayed
                wrapperCounters wrCounters = setCountersValues(con, pbe, country);
                // Set the value of the 
                res = setValuesOnSearchResult(res, pbe, wrCounters, isOutOfStock, isUnderLowLimitThreshold, stockStatusOfProduct, lowLimitSetting);
                res.description = pbe.Product2.Description;

                lRes.add(res);
            }
        }

        return lRes;
    }

    public static List<AP1011_Stock_Utils.StockStatus> getStockRemainingForProducts(List<Id> l_idProduct,
                                                                Set<String> sLocalCodes, 
                                                                Set<String> sEligibilitySegmentOfContact, 
                                                                String offerType,
                                                                String country) {

        // Variables
        List<AP1011_Stock_Utils.StockStatus> lStockStatus = new List<AP1011_Stock_Utils.StockStatus>();
        List<PricebookEntry> lSubstitutePricebookEntries = null;
        Set<String> sSubstituteProductLocalCode = new Set<String>();
        Map<String, List<String>> mSubstituteLocalCodeByProductLocalCode = new Map<String, List<String>>();
        Map<String, List<Product2>> mChildByBundle = new Map<String, List<Product2>>();
        Set<String> sChildProductLocalCode = null;

        // Retrieve the product that have stock management enable and stock information
        List<Product2> lProducts = [SELECT Id, LU_Local_Code__c, Name, LU_Stock_Status__c, LU_Stock_Available__c, LU_Stock_Information__c, 
                                    LU_Stock_Substitution_Message__c, LU_Stock_Substitution_Products__c , RecordType.DeveloperName, LU_Parent_Product__c,
                                    LU_Stock_Other_Article_Impacted__c,
                                        (SELECT Id, Name, LU_Local_Code__c, LU_Parent_Product__c, LU_Parent_Product__r.LU_Local_Code__c 
                                           FROM Products__r 
                                          WHERE LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE)
                                    FROM Product2
                                    WHERE LU_Local_Code__c in :sLocalCodes
                                    AND Id IN :l_idProduct
                                    AND ( LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE OR LU_Stock_Status__c in :STOCK_STATUS_LIMITED ) 
                                    AND LU_Country__c = :country];

        // Get the list of bundle and substitutes of the product retrieved
        for (Product2 p : lProducts) {

            // If the product has substitutes
            if (!String.isBlank(p.LU_Stock_Substitution_Products__c)) {
                List<String> lSubstituteLocalCodes = p.LU_Stock_Substitution_Products__c.split(STOCK_SUBSTITUTE_SEPARATOR);
                mSubstituteLocalCodeByProductLocalCode.put(p.LU_Local_Code__c, lSubstituteLocalCodes);
            }

            // If the product is a bundle
            if (p.RecordType.DeveloperName == STOCK_PRODUCT_RT_BUNDLE) {
                mChildByBundle.put(p.LU_Local_Code__c, p.Products__r);
            }
        }

        /* BUNDLE MANAGEMENT */
        if (!mChildByBundle.isEmpty()) {
            sChildProductLocalCode = new Set<String>();
            for (String parentId : mChildByBundle.keyset()) {
                for (Product2 child : mChildByBundle.get(parentId)) {
                    sChildProductLocalCode.add(child.LU_Local_Code__c);
                }
            }
        }
        /* / BUNDLE MANAGEMENT */

        /* SUBSTITUTE MANAGEMENT */
        if (mSubstituteLocalCodeByProductLocalCode != null) {
            for (List<String> itemsByLocalCode : mSubstituteLocalCodeByProductLocalCode.values()) {
                sSubstituteProductLocalCode.addAll(itemsByLocalCode);
            }

            List<Product2> lSubstituteProductToManage = [SELECT Id, Name, LU_Local_Code__c, LU_Stock_Status__c, LU_Stock_Available__c, LU_Stock_Information__c, 
                                                                LU_Stock_Substitution_Message__c, LU_Stock_Substitution_Products__c, LU_Parent_Product__c,
                                                                LU_Stock_Other_Article_Impacted__c
                                                           FROM Product2
                                                          WHERE LU_Local_Code__c in :sSubstituteProductLocalCode
                                                            //AND LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE
                                                            AND LU_Country__c = :country];

            lProducts.addAll(lSubstituteProductToManage);

            sLocalCodes.addAll(sSubstituteProductLocalCode);

            String techtexternalid = country + '%';

            // SOQL pricebookentry of subsitute 
            lSubstitutePricebookEntries = [SELECT Id, Name, UnitPrice, Product2.Id, Product2.LU_Stock_Status__c, Product2.LU_Local_Code__c, Product2.LU_Smart_Reference__c,
                                            LU_TECH_External_Id__c, Product2.RecordType.Name, PriceBook2Id, Product2.LU_Number_Of_Articles__c, LU_Public_Price__c,
                                            LU_Valid_For_Total_Amount_Base__c, LU_TaxRate__c, Product2.RecordType.DeveloperName, LU_Counter_Value__c,
                                            LU_Eligibility_Segments__c, LU_Offer_type__c, Product2.LU_Bundle_Type__c, Product2.LU_TECH_External_Id__c
                                            FROM PricebookEntry
                                            WHERE Product2.LU_Local_Code__c IN :sSubstituteProductLocalCode
                                            //AND Product2.LU_Stock_Status__c IN :STOCK_STATUS_TO_MANAGE
                                            AND (
                                                LU_Eligibility_Segments__c = '*' 
                                                OR LU_Eligibility_Segments__c LIKE :sEligibilitySegmentOfContact
                                            )
                                            AND Pricebook2.Name != 'Catalogue standard'
                                            AND IsActive = true
                                            AND LU_Start_Date__c <= :Date.today()
                                            AND LU_End_Date__c >= :Date.today()
                                            AND LU_TECH_External_Id__c LIKE :techtexternalid
                                            AND Product2.LU_Country__c = :country];
        }
        /* / SUBSTITUTE MANAGEMENT */

        /* CALCULATE STOCK REMAINING FOR MAIN PRODUCTS, SUBSTITUTE AND CHILD OFFER */
        // Calculate the remaining stock of the products in parameter
        lStockStatus = calculateRemainingStockOfProducts(lProducts, sLocalCodes, mSubstituteLocalCodeByProductLocalCode, 
                                                            lSubstitutePricebookEntries, mChildByBundle, country);

        return (lStockStatus);
    }

    /* Calculate the reming stock of the products in parameter */
    public static List<AP1011_Stock_Utils.StockStatus> calculateRemainingStockOfProducts(List<Product2> lProductToManage, Set<String> sLocalCodes,
                                                                        Map<String, List<String>> mSubstituteLocalCodeByProductLocalCode,
                                                                        List<PricebookEntry> lSubstitutePricebookEntries,
                                                                        Map<String, List<Product2>> mChildByBundle,
                                                                        String pCountry) {

        // Variables
        List<AP1011_Stock_Utils.StockStatus> lStockStatus = new List<AP1011_Stock_Utils.StockStatus>();
        Map<String, Decimal> mStockUsedByProductLocalCode = new Map<String, Decimal>();
        Set<String> sLocalCodeAlreadyManaged = new Set<String>();
        List<String> l_subLocalCode = new List<String>();

        if(mSubstituteLocalCodeByProductLocalCode != null){
            for(List<String> l_tempSubLocalCode : mSubstituteLocalCodeByProductLocalCode.values()){
                l_subLocalCode.addAll(l_tempSubLocalCode);
            }
        }

        // If some products are to be calculated
        if (!lProductToManage.isEmpty()) {

            // Retrieve the stock used per local code on the order
            AggregateResult[] agStockUsed = [SELECT LU_Product__r.LU_Local_Code__c localCode, SUM(LU_Quantity_Ordered__c)used 
                                                FROM LU_Stock_Used__c
                                                WHERE LU_Product__r.LU_Local_Code__c in :sLocalCodes
                                                AND LU_Product__r.LU_Country__c = :pCountry
                                                GROUP BY LU_Product__r.LU_Local_Code__c];       
            for(AggregateResult aggResult : agStockUsed) {
                mStockUsedByProductLocalCode.put((String)aggResult.get('localCode'), (Decimal)aggResult.get('used'));
            }

            // For each product, build the StockStatus record with the stock information (available, used)
            for (Product2 product : lProductToManage) {

                // Get the stock used of this product local code
                Decimal stockUsed = mStockUsedByProductLocalCode.get(product.LU_Local_Code__c);

                // Prepare the stock status for the product
                if (!sLocalCodeAlreadyManaged.contains(product.LU_Local_Code__c)) {

                    AP1011_Stock_Utils.StockStatus st = new AP1011_Stock_Utils.StockStatus();
                    st.productLocalCode = product.LU_Local_Code__c;
                    st.productName = product.Name;
                    st.stockStatus = product.LU_Stock_Status__c;
                    st.stockAvailable = product.LU_Stock_Available__c;
                    st.stockUsed = (stockUsed != null ? stockUsed : 0);
                    st.stockRemaining = (st.stockAvailable != null ? st.stockAvailable - st.stockUsed : 0 );
                    String outOfStockMsg = Label.LU_Stock_OutOfStock_Message;
                    outOfStockMsg = outOfStockMsg.replace('$REF', product.LU_Local_Code__c);
                    st.stockOutOfStockMessage = (outOfStockMsg != null ? outOfStockMsg : '');
                    if(l_subLocalCode.contains(product.LU_Local_Code__c)){
                        st.type = 'substitute';
                    }
                    else if(!String.isBlank(product.LU_Parent_Product__c)){
                        st.type = 'child';
                    }
                    else{
                        st.type = 'parent';
                    }
                    if(!String.IsBlank(product.LU_Stock_Other_Article_Impacted__c) && product.LU_Stock_Other_Article_Impacted__c.isNumeric()){
                        st.multiplicationFactor = Integer.valueOf(product.LU_Stock_Other_Article_Impacted__c);
                    }

                    // IN CASE SUBSTITUTE
                    if (l_subLocalCode.contains(product.LU_Local_Code__c)) {
                        st.lPricebookEntriesOfSubstituteOffers = lSubstitutePricebookEntries;
                    }

                    lStockStatus.add(st);

                    sLocalCodeAlreadyManaged.add(product.LU_Local_Code__c);
                }
            }

            // Go through the main basket product, and attach the stock of the substitute products
            if(!mSubstituteLocalCodeByProductLocalCode.isEmpty()){
                for (AP1011_Stock_Utils.StockStatus mainBasketProduct : lStockStatus) {

                    // Get the substiture product code of the main basket product
                    List<String> lSubstituteProducts = mSubstituteLocalCodeByProductLocalCode.get(mainBasketProduct.productLocalCode);

                    // If the main product of the basket has substitute product
                    if (lSubstituteProducts != null && !lSubstituteProducts.isEmpty()) {

                        mainBasketProduct.lSubstituteProducts = new List<AP1011_Stock_Utils.StockStatus>();

                        // Retrieve the stock level of the substitute article
                        for (String substituteLocalCode : lSubstituteProducts) {

                            Pricebookentry pbEntryIdCorresponding = null;
                            // Find the pricebookentry corresponding
                            for (Pricebookentry entry : lSubstitutePricebookEntries) {
                                if (entry.Product2.LU_Local_Code__c == substituteLocalCode) {
                                    pbEntryIdCorresponding = entry;
                                }
                            }

                            for (AP1011_Stock_Utils.StockStatus stSubstitute : lStockStatus) {

                                if (stSubstitute.productLocalCode == substituteLocalCode) {
                                    stSubstitute.product2IdOfSubstituteOffer = (pbEntryIdCorresponding != null ? pbEntryIdCorresponding.Product2.Id : null);
                                    stSubstitute.pricebookEntryOfSubstituteOffer = pbEntryIdCorresponding;
                                    mainBasketProduct.lSubstituteProducts.add(stSubstitute);
                                }
                            }
                        }
                    }
                }
            }

            // If there are bundles in the order we link the stockstatus to the parent Bundle Product
            if (mChildByBundle != null) {
                for (AP1011_Stock_Utils.StockStatus mainBasketProduct : lStockStatus) {
                    // Go through the child, to get all the child of the current parent
                    List<Product2> lChildProductOfParent = mChildByBundle.get(mainBasketProduct.productLocalCode);
                    if (lChildProductOfParent != null && !lChildProductOfParent.isEmpty()) {
                        mainBasketProduct.lChilds = new List<AP1011_Stock_Utils.StockStatus>();
                        for (Product2 child : lChildProductOfParent) {
                            for (AP1011_Stock_Utils.StockStatus st : lStockStatus) {
                                if (st.productLocalCode == child.LU_Local_Code__c) {
                                    mainBasketProduct.lChilds.add(st); break;
                                }
                            }
                        }
                    }
                }
            }
        }
        return lStockStatus;
    }

    @AuraEnabled
    public static AP1002_LookupSearchResult.Substitute setValuesOnSearchResultSubstitute(PricebookEntry entry, wrapperCounters wrCounters, Boolean isOutOfStock, Boolean isUnderLowLimitThreshold,
                                                                    AP1011_Stock_Utils.StockStatus stockStatusOfProduct, LU_Order_Rule__c lowLimitSetting) {

        // Variables
        AP1002_LookupSearchResult.Substitute res = new AP1002_LookupSearchResult.Substitute();
        
        if (entry != null) {
            // Set the value of the search bar result
            res.id = entry.Id;
            res.sObjectType = 'PriceBookEntry';
            res.icon = 'standard:PriceBookEntry';
            res.title = entry.Product2.LU_Smart_Reference__c + ' - ' + entry.Name;
        
            res.productId = entry.Product2Id;
            res.quantity = 1;
            res.unitPrice = entry.UnitPrice;
            res.priceHT = entry.UnitPrice;
            res.priceTTC = (entry.LU_TECH_External_Id__c.startsWith('FRA') ? entry.LU_Public_Price__c : entry.UnitPrice);
            res.isInBundle = entry.Product2.RecordType.DeveloperName == 'LU_Bundle';
            res.isBundleClosed = entry.Product2.LU_Bundle_Type__c == 'CloseSet';
            res.idBundle = null;
            res.isBundleValidated = false;
            res.priceBook = entry.PriceBook2Id;
            res.displayInPreBasketList = true;
            res.numberOfArticle = entry.Product2.LU_Number_Of_Articles__c;
            res.validForTotalMountBase = entry.LU_Valid_For_Total_Amount_Base__c;
            res.taxRate = entry.LU_TaxRate__c;
            // COUNTERS
            res.l_counters = wrCounters.l_counters; 
            res.counters = wrCounters.counters;
            // STOCK
            
            res.stockAvailable = stockStatusOfProduct.stockRemaining;

            res.stockStatus = entry.Product2.LU_Stock_Status__c;
            res.stockCSSClass = (isOutOfStock ? 'color: rgb(194, 57, 52);' : (isUnderLowLimitThreshold ? 'color: #E6641E;' : ''));
            res.stockBasketCSSClass = (isOutOfStock ? 'error-message' : (isUnderLowLimitThreshold ? 'warning-message' : ''));
            res.stockMessage = (isOutOfStock & stockStatusOfProduct.stockOutOfStockMessage != null ? stockStatusOfProduct.stockOutOfStockMessage : 
                                (isUnderLowLimitThreshold ? lowLimitSetting.LU_Description__c : ''));
            // DISPLAY SUBTITLE
            String stockInfo = (res.stockMessage != null && res.stockMessage != '' ? 
                                '<span style=\'' + res.stockCSSClass + '\'>' + res.stockMessage + '</span>' : '');
            res.subtitle = (entry.UnitPrice > 0 ? entry.UnitPrice + '€ ' : '') + 
                            (wrCounters.counters != null ? wrCounters.counters : '') + 
                            (stockInfo != null ? stockInfo : '');

            res.articleOfTheLine = entry.Product2.LU_TECH_External_Id__c;
            res.counterValuePricebookEntry = entry.LU_Counter_Value__c;
        }

        return (res);
    }

    @AuraEnabled
    public static wrapperCounters setCountersValues(Contact con, PricebookEntry pbe, String country) {

        // Variables
        wrapperCounters wrCounter = new wrapperCounters();
        String counters = '';
        List<AP1002_LookupSearchResult.Counter> l_counters = new List<AP1002_LookupSearchResult.Counter>();
        AP1002_LookupSearchResult.Counter cou = null;
        List<String> l_pbeCounter = new List<String>();
        if(!String.IsBlank(pbe.LU_Counter_Value__c)){
            l_pbeCounter = pbe.LU_Counter_Value__c.split('#');
        }

        String countersUnit = con.LU_Counters_Unit__c + con.LU_Counters_Unit_Bis__c;

        for(Integer i = 1; i <= 30; i++){
            if(con.get('LU_Counter_' + i + '_Name__c') != null && l_pbeCounter.get(i - 1) != null && Decimal.valueOf(l_pbeCounter.get(i - 1)) < 0){
                if(country == 'ITA'){
                    counters += ( (String) con.get('LU_Counter_' + i + '_Name__c')).split('#').get(0) + ' - ';
                }
                else{
                    counters += ( (String) con.get('LU_Counter_' + i + '_Name__c')).split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(i - 1)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = ( (String) con.get('LU_Counter_' + i + '_Name__c')).split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(i - 1));
                cou.unit = countersUnit.split('#').get(i - 1);
                l_counters.add(cou);
            }
        }

        if(counters.length() > 3){
            counters = counters.left(counters.length() - 3);
        }

        wrCounter.counters = counters;
        wrCounter.l_counters = l_counters;

        return (wrCounter);
    }

    @AuraEnabled
    public static AP1002_LookupSearchResult setValuesOnSearchResult(AP1002_LookupSearchResult res, PricebookEntry entry, wrapperCounters wrCounters, Boolean isOutOfStock, Boolean isUnderLowLimitThreshold,
                                                                    AP1011_Stock_Utils.StockStatus stockStatusOfProduct, LU_Order_Rule__c lowLimitSetting) {
        system.debug('>>>> setValuesOnSearchResult START ');
        // Variables
        if (res == null) {
            res = new AP1002_LookupSearchResult();
        }
        
        // Set the value of the search bar result
        res.id = entry.Id;
        res.sObjectType = 'PriceBookEntry';
        res.icon = 'standard:PriceBookEntry';
        res.title = entry.Product2.LU_Smart_Reference__c + ' - ' + entry.Name;
       
        res.productId = entry.Product2Id;
        res.quantity = 1;
        res.unitPrice = entry.UnitPrice; 
        res.priceHT = entry.UnitPrice;// dispayed on the order home
        res.priceTTC = (entry.LU_TECH_External_Id__c.startsWith('FRA') ? entry.LU_Public_Price__c : entry.UnitPrice);
        res.isInBundle = entry.Product2.RecordType.Name == 'LU_Bundle';
        res.isBundleClosed = entry.Product2.LU_Bundle_Type__c == 'CloseSet';
        res.idBundle = null;
        res.priceBook = entry.PriceBook2Id;
        res.displayInPreBasketList = true;
        res.numberOfArticle = entry.Product2.LU_Number_Of_Articles__c;
        res.validForTotalMountBase = entry.LU_Valid_For_Total_Amount_Base__c;
        res.taxRate = entry.LU_TaxRate__c;
        res.maxQuantity = entry.LU_Maximum_Quantity__c;
        // COUNTERS
        res.l_counters = wrCounters.l_counters; 
        res.counters = wrCounters.counters;

        // STOCK
        res.stockStatus = entry.Product2.LU_Stock_Status__c;
        // Manage case of stock : limited quantity / out of stock
        if (stockStatusOfProduct != null ) {

            
            if (AP1011_Stock_Utils.STOCK_STATUS_OUTOFSTOCK.contains(stockStatusOfProduct.stockStatus) || 
                (isOutOfStock && !AP1011_Stock_Utils.STOCK_STATUS_LIMITED.contains(stockStatusOfProduct.stockStatus)) ) {
                if(stockStatusOfProduct.stockStatus != 'DynamicWithoutMessage'){
                    res.stockCSSClass = 'color: rgb(194, 57, 52);';
                    res.stockBasketCSSClass = 'error-message';
                    res.stockMessage = (stockStatusOfProduct.stockOutOfStockMessage != null ? 
                                        stockStatusOfProduct.stockOutOfStockMessage : 
                                        (isUnderLowLimitThreshold ? lowLimitSetting.LU_Description__c : ''));
                
                    if (stockStatusOfProduct.lSubstituteProducts != null && !stockStatusOfProduct.lSubstituteProducts.isEmpty()) {
                        if (stockStatusOfProduct.lSubstituteProducts[0].stockRemaining != null && stockStatusOfProduct.lSubstituteProducts[0].stockRemaining > 0) {
                            String msg = Label.LU_Stock_Replacement_Message;
                            msg = msg.replace('$REF', stockStatusOfProduct.lSubstituteProducts[0].productLocalCode + ' - ' + 
                                                        stockStatusOfProduct.lSubstituteProducts[0].productName);
                            res.stockMessage += ' ' + msg;
                        }
                    }
                }
                else if (stockStatusOfProduct.lSubstituteProducts == null || stockStatusOfProduct.lSubstituteProducts.isEmpty()) {
                    res.stockCSSClass = 'color: rgb(194, 57, 52);';
                    res.stockBasketCSSClass = 'error-message';
                    res.stockMessage = (stockStatusOfProduct.stockOutOfStockMessage != null ? 
                                        stockStatusOfProduct.stockOutOfStockMessage : 
                                        (isUnderLowLimitThreshold ? lowLimitSetting.LU_Description__c : ''));
                }
            } 
            else if (AP1011_Stock_Utils.STOCK_STATUS_LIMITED.contains(stockStatusOfProduct.stockStatus) || isUnderLowLimitThreshold ) {
                if(stockStatusOfProduct.stockStatus != 'DynamicWithoutMessage'){
                    res.stockCSSClass = 'color: #E6641E;';
                    res.stockBasketCSSClass = 'warning-message';
                    res.stockMessage = lowLimitSetting.LU_Description__c;
                    if (stockStatusOfProduct.lSubstituteProducts != null && !stockStatusOfProduct.lSubstituteProducts.isEmpty()) {
                        if (stockStatusOfProduct.lSubstituteProducts[0].stockRemaining != null && stockStatusOfProduct.lSubstituteProducts[0].stockRemaining > 0) {
                            String msg = Label.LU_Stock_Replacement_Message;
                            msg = msg.replace('$REF', stockStatusOfProduct.lSubstituteProducts[0].productLocalCode + ' - ' + 
                                                        stockStatusOfProduct.lSubstituteProducts[0].productName);
                            res.stockMessage += ' ' + msg;
                        }
                    }
                }
            } 
        } 
        
        // Discount
        res.discountType = entry.Discount_Type__c;
        res.dealerPrice = entry.LU_Dealer_Price__c;
        res.priceStrikout = (entry.Discount_Type__c == 'Personal Use' || entry.Discount_Type__c == 'Strikeout' ? true : false);
        res.pricePersonnalUse = (entry.Discount_Type__c == 'Personal Use');

        //BRAND
        res.brandTerritory = entry.Product2.LU_Brand_Territory__c;
        res.brand = entry.Product2.LU_Brand__c;
        
        // DISPLAY SUBTITLE
        String stockInfo = (res.stockMessage != null && res.stockMessage != '' ? 
                            '<span style=\'' + res.stockCSSClass + '\'>' + res.stockMessage + '</span>' : '');
        // res.subtitle = (entry.UnitPrice > 0 ? entry.UnitPrice + '€ ' : '') + 
        //                 (wrCounters.counters != null ? wrCounters.counters : '') + 
        //                 (stockInfo != null ? stockInfo : '');

        if(entry.Discount_Type__c == 'Personal Use'){
            res.subtitle = /* Label.LU_SearchProductLimitedQuantity.replace('{MAX}', entry.LU_Maximum_Quantity__c.setScale(0) + '') + '<br/>' + */
                            (entry.LU_Dealer_Price__c > 0 ? entry.LU_Dealer_Price__c + '€ ' : '') + 
                            (wrCounters.counters != null ? wrCounters.counters : '') + 
                            (stockInfo != null ? stockInfo : '');
        }
        else{
            res.subtitle = /* Label.LU_SearchProductLimitedQuantity.replace('{MAX}', entry.LU_Maximum_Quantity__c.setScale(0) + '') + '<br/>' + */
                            (entry.UnitPrice > 0 ? entry.UnitPrice + '€ ' : '') + 
                            (wrCounters.counters != null ? wrCounters.counters : '') + 
                            (stockInfo != null ? stockInfo : '');
        }

        res.articleOfTheLine = entry.Product2.LU_TECH_External_Id__c;

        res.counterValuePricebookEntry = entry.LU_Counter_Value__c;

        system.debug(res);
        system.debug('>>>> setValuesOnSearchResult END ');

        return (res);
    }

    /* Check if the product is out of stock with the stock status and the stock remaining */
    public static Boolean isProductOutOfStock(AP1011_Stock_Utils.StockStatus productStock) {
        
        Boolean isOutOfStock = false;

        //status out of stock OR Stock <= 0 OR quantity ordered > stock
        if (STOCK_STATUS_OUTOFSTOCK.contains(productStock.stockStatus)  || 
            productStock.stockRemaining == null || 
            (productStock.stockRemaining != null && productStock.stockRemaining <= 0) ) {
                
            // Manage case of LImited quantity product : if limited quantity article and no replacment product : then is not out of stock
            if (STOCK_STATUS_LIMITED.contains(productStock.stockStatus) && 
                (productStock.lSubstituteProducts == null || (productStock.lSubstituteProducts != null && productStock.lSubstituteProducts.isEmpty()) ) ) {
                isOutOfStock = false;
            } else {
                isOutOfStock = true;
                // Set the missing quantity to be checked with the subsitute articles
                productStock.quantityMissingForProduct = (productStock.quantityInTheOrder != null ? productStock.quantityInTheOrder - productStock.stockRemaining : 0);
            }
        }

        //If the product is a bundle, check that its child article are not out of stock
        if (productStock.lChilds != null && !productStock.lChilds.isEmpty()) {

            for (AP1011_Stock_Utils.StockStatus stChild : productStock.lChilds) {
                // Check the status and the quantity remaining in stock
                if (STOCK_STATUS_OUTOFSTOCK.contains(stChild.stockStatus)  || stChild.stockRemaining == null || 
                    (stChild.stockRemaining != null && stChild.stockRemaining <= 0) ||
                    (stChild.quantityInTheOrder != null && stChild.stockRemaining != null && (stChild.stockRemaining - stChild.quantityInTheOrder) < 0 )) {
                    
                    isOutOfStock = true;
                    
                    String childrenMissingMessage = Label.LU_Stock_Checkout_Error_ChildrenMissing;
                    childrenMissingMessage = childrenMissingMessage.replace('$REF', stChild.productLocalCode);

                    productStock.childOutOfStockMessage = (productStock.childOutOfStockMessage != null && productStock.childOutOfStockMessage != '' ? 
                                                            ', ' + childrenMissingMessage : 
                                                            childrenMissingMessage);

                    // Set the missing quantity to be checked with the subsitute articles
                    stChild.quantityMissingForProduct = (stChild.quantityInTheOrder != null ? stChild.quantityInTheOrder - stChild.stockRemaining : 0);
                }
            }
        }

        return isOutOfStock;
    }

    @AuraEnabled
    public static String getPorductListOfBundle(Id idProductOffer, Id idpbentry, Id idPb) {

        Product2 parent = [SELECT Id, LU_Number_Of_Articles__c
                            FROM Product2
                            WHERE Id =: idProductOffer];

        List<AP1002_LookupSearchResult> lRes = new List<AP1002_LookupSearchResult>();
        List<AP1002_LookupSearchResult> lResGift = new List<AP1002_LookupSearchResult>();
        Datetime vNow = Datetime.now();
        List<Product2> childs = [SELECT Id, Name, LU_Local_Code__c, LU_Min_Qty_Orderable__c, LU_Max_Qty_Orderable__c, LU_Type_Child__c, 
                                        LU_TECH_External_Id__c, LU_Stock_Substitution_Products__c, LU_Stock_Available__c, LU_Stock_Status__c
                                    FROM Product2
                                    WHERE LU_Parent_Product__c =: idProductOffer
                                    AND IsActive = true 
                                    AND 
                                    (
                                        (LU_Child_Start_date__c <= :vNow AND LU_Child_End_date__c >= :vNow )
                                        OR
                                        (LU_Child_Start_date__c = null AND LU_Child_End_date__c = null)
                                    )];

        List<Product2> l_childToManage = new List<Product2>();
        Set<String> s_localCodeToManage = new Set<String>();
        Set<String> s_substituteProductLocalCode = new Set<String>();
        Map<String, List<String>> mSubstituteLocalCodeByProductLocalCode = new Map<String, List<String>>();
        Map<String, Decimal> mStockUsedBySubstituteProductLocalCode = new Map<String, Decimal>();
        Map<String, PriceBookEntry> m_substituteByInitialProductLocalCode = new Map<String, PriceBookEntry>();
        Map<String, Decimal> mStockUsedByProductLocalCode = new Map<String, Decimal>();

        for (Product2 child : childs) {
            if(STOCK_STATUS_TO_MANAGE.contains(child.LU_Stock_Status__c)){
                l_childToManage.add(child);
                s_localCodeToManage.add(child.LU_Local_Code__c);
            }

            // If the product has substitutes
            if (!String.isBlank(child.LU_Stock_Substitution_Products__c)) {
                List<String> lSubstituteLocalCodes = child.LU_Stock_Substitution_Products__c.split(STOCK_SUBSTITUTE_SEPARATOR);
                mSubstituteLocalCodeByProductLocalCode.put(child.LU_Local_Code__c, lSubstituteLocalCodes);
                s_substituteProductLocalCode.addAll(lSubstituteLocalCodes);
            }
        }

        if(!s_localCodeToManage.isEmpty()){

            String country = childs.get(0).LU_TECH_External_Id__c.left(3);
            String techtexternalid = country + '%';

            // Get contact information : balances
            Contact con = AP1002_Utils_User.getConnectedUserContact();

            // Eligibility segment of contact
            Set<String> sEligibilitySegmentOfContact = new Set<String>();
            if (con.LU_Eligibility_Groups__c != null && con.LU_Eligibility_Groups__c != '') {
                for (String groupEligibilty : con.LU_Eligibility_Groups__c.split('#')) {
                    sEligibilitySegmentOfContact.add(groupEligibilty);
                }
            }

            AggregateResult[] agStockUsed = [SELECT LU_Product__r.LU_Local_Code__c localCode, SUM(LU_Quantity_Ordered__c)used 
                                                FROM LU_Stock_Used__c
                                                WHERE LU_Product__r.LU_Local_Code__c in :s_localCodeToManage
                                                AND LU_Product__r.LU_Country__c = :country
                                                GROUP BY LU_Product__r.LU_Local_Code__c];       
            for(AggregateResult aggResult : agStockUsed) {
                mStockUsedByProductLocalCode.put((String)aggResult.get('localCode'), (Decimal)aggResult.get('used'));
            }

            // SOQL pricebookentry of subsitute 
            List<PriceBookEntry> l_SubstitutePricebookEntries = [SELECT Id, Product2.LU_Stock_Status__c, Product2.LU_Local_Code__c, Product2.Name, Product2.LU_Stock_Available__c
                                                                    FROM PricebookEntry
                                                                    WHERE Product2.LU_Local_Code__c IN :s_substituteProductLocalCode
                                                                    AND (
                                                                        LU_Eligibility_Segments__c = '*' 
                                                                        OR LU_Eligibility_Segments__c LIKE :sEligibilitySegmentOfContact
                                                                    )
                                                                    AND Pricebook2.Name != 'Catalogue standard'
                                                                    AND IsActive = true
                                                                    AND LU_Start_Date__c <= :Date.today()
                                                                    AND LU_End_Date__c >= :Date.today()
                                                                    AND LU_TECH_External_Id__c LIKE :techtexternalid
                                                                    AND Product2.LU_Country__c = :country];
                                                            
            AggregateResult[] agStockUsedSubstitute = [SELECT LU_Product__r.LU_Local_Code__c localCode, SUM(LU_Quantity_Ordered__c)used 
                                                        FROM LU_Stock_Used__c
                                                        WHERE LU_Product__r.LU_Local_Code__c in :s_substituteProductLocalCode
                                                        AND LU_Product__r.LU_Country__c = :country
                                                        GROUP BY LU_Product__r.LU_Local_Code__c];       
            for(AggregateResult aggResult : agStockUsedSubstitute) {
                mStockUsedBySubstituteProductLocalCode.put((String)aggResult.get('localCode'), (Decimal)aggResult.get('used'));
            }

            for(PriceBookEntry sub : l_SubstitutePricebookEntries){

                if((!STOCK_STATUS_OUTOFSTOCK.contains(sub.Product2.LU_Stock_Status__c) && !STOCK_STATUS_TO_MANAGE.contains(sub.Product2.LU_Stock_Status__c)) || 
                    (STOCK_STATUS_TO_MANAGE.contains(sub.Product2.LU_Stock_Status__c) && !mStockUsedBySubstituteProductLocalCode.containsKey(sub.Product2.LU_Local_Code__c)) || 
                    (STOCK_STATUS_TO_MANAGE.contains(sub.Product2.LU_Stock_Status__c) && sub.Product2.LU_Stock_Available__c - mStockUsedBySubstituteProductLocalCode.get(sub.Product2.LU_Local_Code__c) > 0) ){
                    for(String mainLocalCode : mSubstituteLocalCodeByProductLocalCode.keySet()){
                        if(mSubstituteLocalCodeByProductLocalCode.get(mainLocalCode).contains(sub.Product2.LU_Local_Code__c)){
                            m_substituteByInitialProductLocalCode.put(mainLocalCode, sub);
                            break;
                        }
                    }
                }
            }
        }


        if (!childs.isEmpty()) {
            
            for (Product2 child : childs) {
                system.debug('>>> child');
                system.debug(child);
                AP1002_LookupSearchResult res = new AP1002_LookupSearchResult(child.Id, 
                                                                'PriceBookEntry', 
                                                                'standard:PriceBookEntry',
                                                                child.LU_Local_Code__c + ' - ' + child.Name,
                                                                '');
                res.productId = child.Id;
                res.quantity = (child.LU_Min_Qty_Orderable__c == child.LU_Max_Qty_Orderable__c ? (integer)child.LU_Min_Qty_Orderable__c : 0);
                res.quantityDisplayed = res.quantity;
                res.priceHT = 0;
                res.unitPrice = 0;
                res.priceTTC = 0;
                res.isInBundle = true;
                res.idBundle = idpbentry;
                res.displayInPreBasketList = false;
                res.maxQuantity = child.LU_Max_Qty_Orderable__c;
                res.minQuantity = child.LU_Min_Qty_Orderable__c;
                res.isReadOnly = false;
                if(child.LU_Min_Qty_Orderable__c == child.LU_Max_Qty_Orderable__c || child.LU_Type_Child__c == 'NoSelect'){
                    res.isReadOnly = true;
                }
                res.isSelectable = child.LU_Type_Child__c == 'NoSelect' ? false : true;
                res.numberOfArticle = parent.LU_Number_Of_Articles__c;
                res.priceBook = idPb;
                if(child.LU_Type_Child__c == 'NoSelect'){
                    lResGift.add(res);
                }
                else{
                    lRes.add(res);
                }

                res.subtitle = child.LU_Stock_Status__c;

                //Stock
                if(STOCK_STATUS_TO_MANAGE.contains(child.LU_Stock_Status__c)){
                    if(mStockUsedByProductLocalCode.containsKey(child.LU_Local_Code__c)){
                        res.stockAvailable = (child.LU_Stock_Available__c - mStockUsedByProductLocalCode.get(child.LU_Local_Code__c)) < 0 ? 0 : child.LU_Stock_Available__c - mStockUsedByProductLocalCode.get(child.LU_Local_Code__c);
                    }
                    else{
                        res.stockAvailable = child.LU_Stock_Available__c != null ? child.LU_Stock_Available__c : 0;
                    }
                }
                else if(STOCK_STATUS_OUTOFSTOCK.contains(child.LU_Stock_Status__c)){
                    res.stockAvailable = 0;
                }

                if((STOCK_STATUS_OUTOFSTOCK.contains(child.LU_Stock_Status__c) || STOCK_STATUS_TO_MANAGE.contains(child.LU_Stock_Status__c)) && !String.isEmpty(child.LU_Stock_Substitution_Products__c)){
                    if(m_substituteByInitialProductLocalCode.containsKey(child.LU_Local_Code__c)){
                        res.isSubstituteArtile = false;
                        res.subsituteArticle = new AP1002_LookupSearchResult.Substitute();
                        res.subsituteArticle.name = m_substituteByInitialProductLocalCode.get(child.LU_Local_Code__c).Product2.LU_Local_Code__c + ' - ' + m_substituteByInitialProductLocalCode.get(child.LU_Local_Code__c).Product2.Name;
                        res.subsituteArticle.quantity = (res.stockAvailable - res.quantity) < 0 ? Integer.valueOf(res.quantity - res.stockAvailable) : 0;
                        if(res.subsituteArticle.quantity > 0){
                            res.isSubstituteArtile = true;
                        }
                    }
                }

                res.articleOfTheLine = child.LU_TECH_External_Id__c;
            }

            if(!lResGift.isEmpty()){
                List<AP1002_LookupSearchResult> lResTemp = new List<AP1002_LookupSearchResult>();
                lResTemp.addAll(lRes);
                lResTemp.addAll(lResGift);
                lRes = lResTemp;
            }
            
        }

        return JSON.serialize(lRes);
    }
}