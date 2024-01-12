public without sharing class AP1011_Stock_Utils {
    
    /* CONSTANTS */
        public static final Set<String> STOCK_STATUS_TO_MANAGE = new Set<String>{ 'Dynamic', 'Out-of-stock', 'Temporarily out-of-stock' };
        public static final Set<String> STOCK_STATUS_OUTOFSTOCK = new Set<String>{ 'Out-of-stock', 'Temporarily out-of-stock' };
        public static final Set<String> STOCK_STATUS_LIMITED = new Set<String>{ 'Limited quantity' };
        public static final String STOCK_USED_CURRENCYISOCODE = 'EUR';
        public static final String STOCK_SUBSTITUTE_SEPARATOR = '#';
        public static final String STOCK_PRODUCT_RT_BUNDLE = 'LU_Bundle';
    
    
    /* WRAPPER */
    
        public class OrderStockStatus {
            @AuraEnabled
            public List<StockStatus> lOutOfStockLines {get;set;}
            @AuraEnabled
            public List<LU_Stock_Used__c> lStockUsedToInsertForOrder {get;set;}
        }
    
        public class StockStatus {
            @AuraEnabled
            public String productLocalCode {get;set;} // Local Code of the product : matches Product2.LU_Local_Code__c
            @AuraEnabled
            public String productName {get;set;} // Local name of the product
            @AuraEnabled
            public String stockStatus {get;set;} // Status of the stock : Product2.LU_Stock_Status__c
            @AuraEnabled
            public Decimal stockAvailable {get;set;} // Stock available for the product local code : Product2.LU_Stock_Available__c
            @AuraEnabled
            public Decimal stockUsed {get;set;} // Stock used for the product Local code using the LU_Stock_Used__c custom object
            @AuraEnabled
            public Decimal stockRemaining {get;set;} // Stock remaining for the product local code : stockAvailable - stockUsed
            @AuraEnabled
            public Decimal quantityInTheOrder {get;set;} // Quantity needed for the order
            @AuraEnabled
            public Decimal quantityMissingForProduct {get;set;} // Quantity missing on the main product
            @AuraEnabled
            public String stockOutOfStockMessage {get;set;} // Stock information : displayed if out-of-stock
            @AuraEnabled
            public List<OrderItem> lOrderItemForOrder {get;set;} // Line of order linked to the productLocalCode
            @AuraEnabled
            public Decimal multiplicationFactor {get;set;} // Local name of the product
    
            /* IF THE LOCALCODE IS A BUNDLE : child stock status */
            @AuraEnabled
            public List<StockStatus> lChilds {get;set;}
            @AuraEnabled
            public String childOutOfStockMessage {get;set;}
    
            /* SUBSTITUTE OFFERS */
            @AuraEnabled
            public Id product2IdOfSubstituteOffer {get;set;}
            @AuraEnabled
            public PricebookEntry pricebookEntryOfSubstituteOffer {get;set;}
            @AuraEnabled
            public List<PricebookEntry> lPricebookEntriesOfSubstituteOffers {get;set;}
            @AuraEnabled
            public List<StockStatus> lSubstituteProducts {get;set;} // Information regarding substitute articles stock

            //can be parent, child, substitute
            @AuraEnabled
            public String type {get;set;}
        }
    
    
    /* BUSINESS METHODS */
    
        /* Retreive stock available for list of local product code */
        public static List<StockStatus> getStockRemainingForProducts(List<Id> l_idProduct,
                                                                    Set<String> sLocalCodes, 
                                                                    Set<String> sEligibilitySegmentOfContact, 
                                                                    String offerType,
                                                                    String country) {
    
            // Variables
            List<StockStatus> lStockStatus = new List<StockStatus>();
            List<PricebookEntry> lSubstitutePricebookEntries = null;
            Set<String> sSubstituteProductLocalCode = null;
            // Map<String, List<String>> mSubstituteOffersByProductLocalCode = new Map<String, List<String>>();
            Map<String, List<String>> mSubstituteLocalCodeByProductLocalCode = new Map<String, List<String>>();
            Map<String, List<Product2>> mChildByBundle = new Map<String, List<Product2>>();
            Set<String> sChildProductLocalCode = null;
    
            // Retrieve the product that have stock management enable and stock information
            List<Product2> lProducts = [SELECT Id, LU_Local_Code__c, Name, LU_Stock_Status__c, LU_Stock_Available__c, LU_Stock_Information__c, 
                                        LU_Stock_Substitution_Message__c, LU_Stock_Substitution_Products__c , RecordType.DeveloperName, 
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
                if (p.LU_Stock_Substitution_Products__c != null && p.LU_Stock_Substitution_Products__c != '') {
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
                Set<String> lSubProductCode = new Set<String>();
                for (List<String> itemsByLocalCode : mSubstituteLocalCodeByProductLocalCode.values()) {
                    lSubProductCode.addAll(itemsByLocalCode);
                }
    
                lSubstitutePricebookEntries = getPricebookEntriesOfProductLocalCodeWithEligibilityAndOfferType(lSubProductCode, sEligibilitySegmentOfContact, offerType, country);
                sSubstituteProductLocalCode = lSubProductCode;
            }
            /* / SUBSTITUTE MANAGEMENT */
    
            /* CALCULATE STOCK REMAINING FOR MAIN PRODUCTS, SUBSTITUTE AND CHILD OFFER */
            // Calculate the remaining stock of the products in parameter
            lStockStatus = calculateRemainingStockOfProducts(lProducts, sLocalCodes, 'MAIN', null, null, null, null, country);
    
            // Calculate the stock remaining on the substitute articles if some available
            if (sSubstituteProductLocalCode != null && !sSubstituteProductLocalCode.isEmpty()) {
                lStockStatus = calculateRemainingStockOfProducts(null, sSubstituteProductLocalCode, 'SUBSTITUTE', lStockStatus, mSubstituteLocalCodeByProductLocalCode,
                                                                lSubstitutePricebookEntries, null, country);
            }
            
            // Calculate the stock remaining on the child article of a bundle 
            if (sChildProductLocalCode != null && !sChildProductLocalCode.isEmpty()) {
                lStockStatus = calculateRemainingStockOfProducts(lProducts, sChildProductLocalCode, 'CHILD', lStockStatus, null, null, mChildByBundle, country);
                system.debug('>>>>> MAIN : ' + lStockStatus);
            }
    
            return (lStockStatus);
    
        }
    
        public static List<PricebookEntry> getPricebookEntriesOfProductLocalCode(Set<String> sLocalCodes) {
            List<PricebookEntry> lEntries = [SELECT Id, Name, UnitPrice, Product2.Id, Product2.LU_Stock_Status__c, Product2.LU_Local_Code__c, Product2.LU_Smart_Reference__c,
                                                LU_TECH_External_Id__c, Product2.RecordType.Name, PriceBook2Id, Product2.LU_Number_Of_Articles__c,
                                                LU_Valid_For_Total_Amount_Base__c, LU_TaxRate__c, Product2.RecordType.DeveloperName, Product2.LU_Bundle_Type__c, LU_Eligibility_Segments__c,
                                                Product2.LU_TECH_External_Id__c
                                                FROM PricebookEntry
                                                WHERE LU_TECH_External_Id__c in: sLocalCodes
                                                AND Product2.LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE];
            return (lEntries);
        }
    
        public static List<PricebookEntry> getPricebookEntriesOfProductLocalCodeWithEligibilityAndOfferType(Set<String> sLocalCodes, 
                                                                                                            Set<String> sEligibilitySegmentOfContact, 
                                                                                                            String offerType,
                                                                                                            String country) {
            String techtexternalid = country + '%';
            List<PricebookEntry> lEntries = null;
            system.debug('>>>>>> getPricebookEntriesOfProductLocalCodeWithEligibilityAndOfferType');
            system.debug('>>> sLocalCodes');
            system.debug(sLocalCodes);
            system.debug('>>> sEligibilitySegmentOfContact');
            system.debug(sEligibilitySegmentOfContact);
            system.debug('>>> offerType');
            system.debug(offerType);
            system.debug('>>> country');
            system.debug(country); 
                                                                                                               
            if (offerType != null) {
    
                lEntries = [SELECT Id, Name, UnitPrice, Product2.Id, Product2.LU_Stock_Status__c, Product2.LU_Local_Code__c, Product2.LU_Smart_Reference__c,
                                LU_TECH_External_Id__c, Product2.RecordType.Name, PriceBook2Id, Product2.LU_Number_Of_Articles__c,
                                LU_Valid_For_Total_Amount_Base__c, LU_TaxRate__c, Product2.RecordType.DeveloperName, LU_Counter_Value__c,
                                LU_Eligibility_Segments__c, LU_Offer_type__c, LU_Public_Price__c, Product2.LU_Bundle_Type__c, Product2.LU_TECH_External_Id__c
                                FROM PricebookEntry
                                WHERE Product2.LU_Local_Code__c in: sLocalCodes
                                AND Product2.LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE
                                AND (
                                    LU_Eligibility_Segments__c = '*' 
                                    OR LU_Eligibility_Segments__c LIKE :sEligibilitySegmentOfContact
                                )
                                AND Pricebook2.Name != 'Catalogue standard'
                                AND LU_Offer_type__c = :offerType
                                AND IsActive = true
                                AND LU_Start_Date__c <= :Date.today()
                                AND LU_End_Date__c >= :Date.today()
                                AND LU_TECH_External_Id__c LIKE :techtexternalid
                                AND Product2.LU_Country__c = :country
                            ];
            } else {
                lEntries = [SELECT Id, Name, UnitPrice, Product2.Id, Product2.LU_Stock_Status__c, Product2.LU_Local_Code__c, Product2.LU_Smart_Reference__c,
                                LU_TECH_External_Id__c, Product2.RecordType.Name, PriceBook2Id, Product2.LU_Number_Of_Articles__c,
                                LU_Valid_For_Total_Amount_Base__c, LU_TaxRate__c, Product2.RecordType.DeveloperName,
                                LU_Eligibility_Segments__c, LU_Offer_type__c, Product2.LU_Bundle_Type__c, Product2.LU_TECH_External_Id__c
                                FROM PricebookEntry
                                WHERE Product2.LU_Local_Code__c in: sLocalCodes
                                AND Product2.LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE
                                AND (
                                    LU_Eligibility_Segments__c = '*' 
                                    OR LU_Eligibility_Segments__c LIKE :sEligibilitySegmentOfContact
                                )
                                AND Pricebook2.Name != 'Catalogue standard'
                                AND IsActive = true
                                AND LU_Start_Date__c <= :Date.today()
                                AND LU_End_Date__c >= :Date.today()
                                AND LU_TECH_External_Id__c LIKE :techtexternalid
                                AND Product2.LU_Country__c = :country
                            ];
            } 
            return (lEntries);
        }
    
        /* Calculate the reming stock of the products in parameter */
        /* TypeProduct : 'MAIN' is for products in the basket, 'SUBSTITUTE' is for substitute product, 'CHILD' is for child product of a bundle */
        public static List<StockStatus> calculateRemainingStockOfProducts(List<Product2> lProducts, Set<String> sLocalCodes, String typeProduct, 
                                                                            List<StockStatus> lStockStatusOfBasketArticles, 
                                                                            Map<String, List<String>> mSubstituteLocalCodeByProductLocalCode,
                                                                            List<PricebookEntry> lSubstitutePricebookEntries,
                                                                            Map<String, List<Product2>> mChildByBundle,
                                                                            String pCountry) {
    
            // Variables
            List<StockStatus> lStockStatus = new List<StockStatus>();
            Map<String, Decimal> mStockUsedByProductLocalCode = new Map<String, Decimal>();
            List<Product2> lProductToManage = lProducts;
            Set<String> sLocalCodeAlreadyManaged = new Set<String>();
    
            // If no products are sent, then retrieve them using the sLocalCodes in parameter
            if (lProductToManage == null) {
                lProductToManage = [SELECT Id, Name, LU_Local_Code__c, LU_Stock_Status__c, LU_Stock_Available__c, LU_Stock_Information__c, 
                                        LU_Stock_Substitution_Message__c, LU_Stock_Substitution_Products__c 
                                        FROM Product2
                                        WHERE LU_Local_Code__c in :sLocalCodes
                                        AND LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE
                                        AND LU_Country__c = :pCountry];
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
    
                        StockStatus st = new StockStatus();
                        st.productLocalCode = product.LU_Local_Code__c;
                        st.productName = product.Name;
                        st.stockStatus = product.LU_Stock_Status__c;
                        st.stockAvailable = product.LU_Stock_Available__c;
                        st.stockUsed = (stockUsed != null ? stockUsed : 0);
                        st.stockRemaining = (st.stockAvailable != null ? st.stockAvailable - st.stockUsed : 0 );
                        String outOfStockMsg = Label.LU_Stock_OutOfStock_Message;
                        outOfStockMsg = outOfStockMsg.replace('$REF', product.LU_Local_Code__c);
                        // outOfStockMsg += ' ' + (product.LU_Stock_Substitution_Message__c != null ? product.LU_Stock_Substitution_Message__c : '');
                        st.stockOutOfStockMessage = (outOfStockMsg != null ? outOfStockMsg : '');
    
                        // IN CASE SUBSTITUTE
                        if (typeProduct == 'SUBSTITUTE') {
                            st.lPricebookEntriesOfSubstituteOffers = lSubstitutePricebookEntries;
                        }
    
                        lStockStatus.add(st);
    
                        sLocalCodeAlreadyManaged.add(product.LU_Local_Code__c);
                    }
                }
    
                // If the typeProduct in parameter is set to 'CHILD' : we must link the stockstatus to the parent Bundle Product
                if (typeProduct == 'CHILD' && mChildByBundle != null) {
                    for (StockStatus mainBasketProduct : lStockStatusOfBasketArticles) {
                        // Go through the child, to get all the child of the current parent
                        List<Product2> lChildProductOfParent = mChildByBundle.get(mainBasketProduct.productLocalCode);
                        if (lChildProductOfParent != null && !lChildProductOfParent.isEmpty()) {
                            mainBasketProduct.lChilds = new List<StockStatus>();
                            for (Product2 child : lChildProductOfParent) {
                                for (StockStatus st : lStockStatus) {
                                    if (st.productLocalCode == child.LU_Local_Code__c) {
                                        mainBasketProduct.lChilds.add(st); break;
                                    }
                                }
                            }
                        }
    
                    }
    
                    // Return the list of stockstatus of the main product of the basket with the information of the child added
                    lStockStatus = lStockStatusOfBasketArticles;
                }
    
                // If the typeProduct in parameter is set to 'SUBSTITUTE' : means we manage substitute, so we mus link the StockStatus to its main product link
                if (typeProduct == 'SUBSTITUTE') {
    
                    // Go through the main basket product, and attach the stock of thei substitute products
                    for (StockStatus mainBasketProduct : lStockStatusOfBasketArticles) {
    
                        // Get the substiture product code of the main basket product
                        List<String> lSubstituteProducts = mSubstituteLocalCodeByProductLocalCode.get(mainBasketProduct.productLocalCode);
    
                        // If the main product of the basket ahs substitute product
                        if (lSubstituteProducts != null && !lSubstituteProducts.isEmpty()) {
    
                            mainBasketProduct.lSubstituteProducts = new List<StockStatus>();
    
                            // Retrieve the stock level of the substitute article
                            for (String substituteLocalCode : lSubstituteProducts) {
    
                                Pricebookentry pbEntryIdCorresponding = null;
                                // Find the pricebookentry corresponding
                                for (Pricebookentry entry : lSubstitutePricebookEntries) {
                                    if (entry.Product2.LU_Local_Code__c == substituteLocalCode) {
                                        pbEntryIdCorresponding = entry;
                                    }
                                }
    
                                for (StockStatus stSubstitute : lStockStatus) {
    
                                    if (stSubstitute.productLocalCode == substituteLocalCode) {
                                        stSubstitute.product2IdOfSubstituteOffer = (pbEntryIdCorresponding != null ? pbEntryIdCorresponding.Product2.Id : null);
                                        stSubstitute.pricebookEntryOfSubstituteOffer = pbEntryIdCorresponding;
                                        mainBasketProduct.lSubstituteProducts.add(stSubstitute);
                                    }
                                }
    
                            }
                            
                        }
    
                    }
    
                    // Return the list of stockstatus of the main product of the basket with the information of the substitute added
                    lStockStatus = lStockStatusOfBasketArticles;
                }            
            } else {
                if (typeProduct == 'CHILD' || typeProduct == 'SUBSTITUTE') {
                    lStockStatus = (lStockStatusOfBasketArticles != null && !lStockStatusOfBasketArticles.isEmpty() ? lStockStatusOfBasketArticles : lStockStatus);
                }
            }
    
            return (lStockStatus);
        }
        
    
        /* Check that product stock is not under warning message thershold */
        public static Boolean isProductUnderLowLimitThreshold(Decimal lowLimitThreshold, StockStatus productStock) {
    
            // Variables
            Boolean res = false;
            
            // Limited quantity : by status
            if (productStock != null && STOCK_STATUS_LIMITED.contains(productStock.stockStatus)) {
                res = true;
            } else if (lowLimitThreshold != null && productStock.stockAvailable != null ) { // Check Limited quantity based on the quantity available
    
                Decimal pctLeft = 0;
                if (productStock.stockAvailable != 0) {
                    pctLeft = 1 - (productStock.stockUsed / productStock.stockAvailable);
                }
                if (pctLeft <= lowLimitThreshold) {
                    res = true;
                }
    
            }
    
            return (res);
        }
    
    
        public static Boolean isProductOutOfStockCanBeReplaceBySubstituteProduct(StockStatus productStock) {
    
            // Variables
            Boolean isSubstituteCanReplace = false;
    
            if (productStock.lSubstituteProducts != null && !productStock.lSubstituteProducts.isEmpty()) {
                
                // Quantity of the order to fill
                Decimal quantityToFill = productStock.quantityMissingForProduct;
    
                for (StockStatus stSubstitute : productStock.lSubstituteProducts) {
    
                    if (!STOCK_STATUS_OUTOFSTOCK.contains(stSubstitute.stockStatus) && productStock.stockRemaining != null && stSubstitute.stockRemaining > 0) {
    
                        // If the substitute articel is enough to fill all the remaining quantity
                        if (stSubstitute.stockRemaining - quantityToFill > 0) {
                            stSubstitute.quantityInTheOrder = quantityToFill;
                        } else { // if the substitute article is not enough to fill all the remaining quantity, use the quantity available 
                            stSubstitute.quantityInTheOrder = stSubstitute.stockRemaining;
                        }
    
                        quantityToFill -= stSubstitute.quantityInTheOrder;
                    }
    
                    // If all the quantity have been filled, then stock looking for stock availability of substitute article
                    if (quantityToFill == 0) { break; }
                }
    
                // If the quantity of substitute is enough, return true
                if (quantityToFill == 0) {
                    isSubstituteCanReplace = true;
                }
    
            }
    
            return (isSubstituteCanReplace);
        }
    
        /* Check if the product is out of stock with the stock status and the stock remaining */
        public static Boolean isProductOutOfStock(StockStatus productStock) {
            system.debug('>>> isProductOutOfStock : ' + productStock.productLocalCode);
            // Variables
            Boolean isOutOfStock = false;
    
            if (productStock != null) {
                // Check the status and the quantity remaining in stock
                if ( STOCK_STATUS_OUTOFSTOCK.contains(productStock.stockStatus)  || 
                    productStock.stockRemaining == null || 
                    (productStock.stockRemaining != null && productStock.stockRemaining <= 0) ||
                    (productStock.quantityInTheOrder != null && productStock.stockRemaining != null && (productStock.stockRemaining - productStock.quantityInTheOrder) < 0 )) {
                    
                    // Manage case of case of LImited quantity product : if limited quantity article and no replacment product : then is not out of stock
                    if (STOCK_STATUS_LIMITED.contains(productStock.stockStatus) && 
                        (productStock.lSubstituteProducts == null || (productStock.lSubstituteProducts != null && productStock.lSubstituteProducts.isEmpty()) ) ) {
                        isOutOfStock = false;
                    } else {
                        isOutOfStock = true;
                        // Set the missing quantity to be checked with the subsitute articles
                        productStock.quantityMissingForProduct = (productStock.quantityInTheOrder != null ? productStock.quantityInTheOrder - productStock.stockRemaining : 0);
                    }
    
                }
    
                // If the product is a bundle, check that its child article are not out of stock
                if (productStock.lChilds != null && !productStock.lChilds.isEmpty()) {
    
                    for (StockStatus stChild : productStock.lChilds) {
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
            }
            system.debug('>>>>> result : ' + isOutOfStock);
            return (isOutOfStock);
        }
    
        /* Get country Low limit threshold */
        public static LU_Order_Rule__c getLowLimitThreshold(String country) {
    
            //String countryCriteria = (country == 'FRA' ? 'France' : 'Italy');
            return ([SELECT Id, LU_Value__c, LU_Description__c FROM LU_Order_Rule__c WHERE RecordType.DeveloperName = 'LU_Stock_Low_Limit_Threshold' AND LU_Country__c = :country LIMIT 1]);
    
        }
    
        /* Method to match the order lines on the stock status */
        public static List<StockStatus> matchStockStatusToOrderItem(List<StockStatus> lStockStatusOfOrder, Order order) {
    
            if (order.OrderItems != null && !order.OrderItems.isEmpty()) {
    
                for (StockStatus st : lStockStatusOfOrder) {
    
                    st.lOrderItemForOrder = new List<OrderItem>();
    
                    // Get the line of OrderItem link to the status.productlocalcode
                    for (OrderItem item : order.OrderItems) {
    
                        // Main product associated to the order line
                        if (item.Product2.LU_Local_Code__c == st.productLocalCode) {
                            st.lOrderItemForOrder.add(item);
                        }
                        // if the line is a children of a main line, add the associated order line
                        if (item.LU_Child_Product__r.LU_Local_Code__c == st.productLocalCode) {
                            st.lOrderItemForOrder.add(item);
                        }
                    }
    
                }
    
            }
    
            return (lStockStatusOfOrder);
        }
    
        /* Calculate the stock for the order in parameter. Return the product local code that are out of stock */
        public static OrderStockStatus checkStockForOrder(Id orderId) {
    
            // Variables
            OrderStockStatus status = new OrderStockStatus();
            status.lOutOfStockLines = new List<StockStatus>();
            status.lStockUsedToInsertForOrder = new List<LU_Stock_Used__c>();
    
            //List<StockStatus> lStockOutOfStock = new List<StockStatus>();
    
            // Get the OrderItems associated with the order in parameter
            Order order = [SELECT Id, BillToContactId, BillToContact.LU_Eligibility_Groups__c, BillToContact.AccountCountryCode__c, 
                            (SELECT Id, PricebookEntryId, Product2Id, Product2.LU_TECH_External_Id__c, Product2.LU_Local_Code__c, 
                                Product2.LU_Stock_Status__c, Product2.LU_Stock_Available__c, Product2.LU_Stock_Information__c,
                                Product2.LU_Stock_Other_Article_Impacted__c, Product2.LU_Stock_Substitution_Message__c, 
                                Product2.LU_Stock_Substitution_Products__c, Quantity , LU_Child_Product__c, LU_Child_Product__r.Name, LU_Child_Product__r.LU_Local_Code__c
                                FROM OrderItems
                                WHERE (Product2.LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE OR Product2.LU_Stock_Status__c in :STOCK_STATUS_LIMITED))
                            FROM Order
                            WHERE Id =: orderId];
    
            // If the order has lines to be managed
            if (!order.OrderItems.isEmpty()) {
                
                // Eligibility segment of contact
                Set<String> sEligibilitySegmentOfContact = new Set<String>();
                if (order.BillToContact.LU_Eligibility_Groups__c != null && order.BillToContact.LU_Eligibility_Groups__c != '') {
                    for (String groupEligibilty : order.BillToContact.LU_Eligibility_Groups__c.split('#')) {
                        sEligibilitySegmentOfContact.add(groupEligibilty);
                    }
                }
    
                // Get the list of product local code of the order
                Set<String> sProductLocalCodesOfOrder = getProductLocalCodeOfOrderItem(order.OrderItems);
                List<Id> l_idProduct = new List<Id>();
                for(OrderItem oi : order.OrderItems){
                    l_idProduct.add(oi.Product2Id);
                }
    
                // Get the remaining stock of those product local code
                List<StockStatus> lStockStatusOfOrder = getStockRemainingForProducts(l_idProduct, sProductLocalCodesOfOrder, sEligibilitySegmentOfContact, 
                                                                                    null, order.BillToContact.AccountCountryCode__c);
    
                // Link the stock status to the line of orders
                lStockStatusOfOrder = matchStockStatusToOrderItem(lStockStatusOfOrder, order);
    
                Id vUserId = UserInfo.getUserId();
                String vCountry = AP1002_Utils_User.getUserCountry(vUserId);
    
                // Calculate the quantity needed for each product local code of the order
                /*AggregateResult[] agStockNeeded = [SELECT Product2.LU_Local_Code__c localCode, SUM(Quantity)qty 
                                                    FROM OrderItem
                                                    WHERE OrderId = :orderId
                                                    AND Product2.LU_Local_Code__c in :sProductLocalCodesOfOrder
                                                    AND ( Product2.LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE OR Product2.LU_Stock_Status__c in :STOCK_STATUS_LIMITED )
                                                    AND Product2.LU_Country__c = :vCountry
                                                    GROUP BY Product2.LU_Local_Code__c];
                for (AggregateResult aggResult : agStockNeeded) {
                    
                    String localCode = (String)aggResult.get('localCode');
                    for (StockStatus stock : lStockStatusOfOrder) {
                        if (stock.productLocalCode == localCode) {
                            stock.quantityInTheOrder = (Decimal)aggResult.get('qty');
                            break;
                        }
                    }
                }*/

                List<OrderItem> l_orderItems = [SELECT Product2.LU_Local_Code__c, LU_Child_Product__c, LU_Child_Product__r.LU_Local_Code__c, Quantity
                                                FROM OrderItem
                                                WHERE OrderId = :orderId
                                                AND ( Product2.LU_Local_Code__c in :sProductLocalCodesOfOrder OR LU_Child_Product__r.LU_Local_Code__c in :sProductLocalCodesOfOrder )
                                                AND ( Product2.LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE OR Product2.LU_Stock_Status__c in :STOCK_STATUS_LIMITED OR LU_Child_Product__r.LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE OR LU_Child_Product__r.LU_Stock_Status__c in :STOCK_STATUS_LIMITED)
                                                AND Product2.LU_Country__c = :vCountry];
                
                Map<String, Decimal> m_quantityPerLocalCode = new Map<String, Decimal>();
                for(OrderItem oi : l_orderItems){
                    if(oi.LU_Child_Product__c == null){
                        if(!m_quantityPerLocalCode.containsKey(oi.Product2.LU_Local_Code__c)){
                            m_quantityPerLocalCode.put(oi.Product2.LU_Local_Code__c, 0);
                        }
                        m_quantityPerLocalCode.put(oi.Product2.LU_Local_Code__c, oi.Quantity + m_quantityPerLocalCode.get(oi.Product2.LU_Local_Code__c));
                    }
                    else{
                        if(!m_quantityPerLocalCode.containsKey(oi.LU_Child_Product__r.LU_Local_Code__c)){
                            m_quantityPerLocalCode.put(oi.LU_Child_Product__r.LU_Local_Code__c, 0);
                        }
                        m_quantityPerLocalCode.put(oi.LU_Child_Product__r.LU_Local_Code__c, oi.Quantity + m_quantityPerLocalCode.get(oi.LU_Child_Product__r.LU_Local_Code__c));
                    }
                }
                
                for(String localCode : m_quantityPerLocalCode.keySet()){ 
                    for (StockStatus stock : lStockStatusOfOrder) {
                        if (stock.productLocalCode == localCode) {
                            stock.quantityInTheOrder = m_quantityPerLocalCode.get(localCode);
                            break;
                        }
                    }
                }
    
    
                // Go through the stock status and check for each article if the stock is enough
                for (StockStatus stock : lStockStatusOfOrder) {
    
                    Boolean isOutOfStock = isProductOutOfStock(stock);
                    Boolean isSubstituteCanReplace = false;
    
                    // If the main product is out of check
                    if (isOutOfStock) {
                        // Check if some stubstitute products can fill the order
                        isSubstituteCanReplace = isProductOutOfStockCanBeReplaceBySubstituteProduct(stock);
                    }
    
                    // If the main product is out of stock and its substitute can't fill the order, then the order line is out-of-stock
                    if (isOutOfStock && !isSubstituteCanReplace) {
                        status.lOutOfStockLines.add(stock);
                    } else {
    
                        Decimal quantityToBeUsed = stock.quantityInTheOrder;
    
                        // Create the line of LU_Stock_Used__c for each line of order for each product local code related to the right product
                        for (OrderItem item : stock.lOrderItemForOrder) {
    
                            // Get the product to decrease the stock : either the main product or the child if a child line of a bundle
                            Id productId = (item.LU_Child_Product__c != null ? item.LU_Child_Product__c : item.Product2Id);
                            Decimal quantityToBeUsedForThisLine = item.Quantity;
    
                            // Manage case of Limited quantity article but without substitute
                            if (STOCK_STATUS_LIMITED.contains(stock.stockStatus) && 
                                ( stock.lSubstituteProducts == null || (stock.lSubstituteProducts != null && stock.lSubstituteProducts.isEmpty())) ){
                                    // Nothing to calculate on the stock. Leave the "limited quantity" product on the order.
                            } else { // In other cases
    
                                while (quantityToBeUsedForThisLine > 0) {
    
                                    // If the main article has enough stock to fill the order, create the Stock Used
                                    if (stock.stockRemaining - quantityToBeUsedForThisLine > 0) {
                                        status.lStockUsedToInsertForOrder.add(new LU_Stock_Used__c(CurrencyIsoCode = STOCK_USED_CURRENCYISOCODE, 
                                                                                                    LU_Order__c = orderId, 
                                                                                                    LU_Order_Line__c = item.Id,
                                                                                                    LU_Product__c = productId, //item.Product2Id,
                                                                                                    LU_Quantity_Ordered__c = quantityToBeUsedForThisLine));
                                        quantityToBeUsedForThisLine = 0;
                                    } else {
                                        // Use the main article + some of its substitute to fill the order
                                        // Use the main article quantity left
                                        if (stock.stockRemaining > 0) {
                                            status.lStockUsedToInsertForOrder.add(new LU_Stock_Used__c(CurrencyIsoCode = STOCK_USED_CURRENCYISOCODE, 
                                                                                                    LU_Order__c = orderId, 
                                                                                                    LU_Order_Line__c = item.Id,
                                                                                                    LU_Product__c = productId, //item.Product2Id,
                                                                                                    LU_Quantity_Ordered__c = stock.stockRemaining,
                                                                                                    LU_Product_Local_Code__c = stock.productLocalCode,
                                                                                                    LU_Product_Local_Name__c = stock.productName));
                                            quantityToBeUsedForThisLine -= stock.stockRemaining;
                                        }
                                        
                                        // use the substitute article to fill the rest of the order line quantity
                                        if (quantityToBeUsedForThisLine > 0) {
                                            if (stock.lSubstituteProducts != null && !stock.lSubstituteProducts.isEmpty()) {
                                                for (StockStatus stSubstitute : stock.lSubstituteProducts) {
                                                    if (stSubstitute.stockRemaining != null && stSubstitute.stockRemaining > 0) {
                                                        
                                                        // If the substitute can finish filling the order
                                                        if (stSubstitute.stockRemaining - quantityToBeUsedForThisLine > 0) {
                                                            status.lStockUsedToInsertForOrder.add(new LU_Stock_Used__c(CurrencyIsoCode = STOCK_USED_CURRENCYISOCODE, 
                                                                                                                LU_Order__c = orderId, 
                                                                                                                LU_Order_Line__c = item.Id,
                                                                                                                LU_Product__c = stSubstitute.product2IdOfSubstituteOffer, //item.Product2Id,
                                                                                                                LU_Quantity_Ordered__c = quantityToBeUsedForThisLine,
                                                                                                                LU_Product_Local_Code__c = stSubstitute.productLocalCode,
                                                                                                                LU_Product_Local_Name__c = stSubstitute.productName));
                                                            quantityToBeUsedForThisLine = 0;
                                                            break;
                                                        } else {
                                                            // Use the quantity left on the substitute article
                                                            status.lStockUsedToInsertForOrder.add(new LU_Stock_Used__c(CurrencyIsoCode = STOCK_USED_CURRENCYISOCODE, 
                                                                                                                LU_Order__c = orderId, 
                                                                                                                LU_Order_Line__c = item.Id,
                                                                                                                LU_Product__c = stSubstitute.product2IdOfSubstituteOffer, //item.Product2Id,
                                                                                                                LU_Quantity_Ordered__c = stSubstitute.stockRemaining,
                                                                                                                LU_Product_Local_Code__c = stSubstitute.productLocalCode,
                                                                                                                LU_Product_Local_Name__c = stSubstitute.productName));
                                                            quantityToBeUsedForThisLine -= stSubstitute.stockRemaining;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }  
                            }
     
                        }                    
                    }
                }
            }
    
            // Return the stock status for the product local code that are out of stock
            return (status);
        } 
    
        public static void updateOrderWithStockInformation(Id orderId, OrderStockStatus orderStockStatus) { 
    
            // Variables
            List<OrderItem> lItemsToUpdate = new List<OrderItem>();
    
            // Get the stock status of the order or the one in parameter
            // List<StockStatus> lStockStatus = stockStatusWithIssue;
            OrderStockStatus status = orderStockStatus;
            if (status == null)
                status = checkStockForOrder(orderId);
    
            if (!status.lOutOfStockLines.isEmpty()) {
    
                // Get the OrderItems associated with the order in parameter
                Order order = [SELECT Id, BillToContactId, 
                                (SELECT Id, PricebookEntryId, Product2Id, Product2.LU_TECH_External_Id__c, Product2.LU_Local_Code__c, 
                                    Product2.LU_Stock_Status__c, Product2.LU_Stock_Available__c, Product2.LU_Stock_Information__c,
                                    Product2.LU_Stock_Other_Article_Impacted__c, Product2.LU_Stock_Substitution_Message__c, 
                                    Product2.LU_Stock_Substitution_Products__c, Quantity, Description
                                    FROM OrderItems
                                    WHERE Product2.LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE)
                                FROM Order
                                WHERE Id =: orderId];
    
                // For each line of order, get the stock status associated
                for (OrderItem item : order.OrderItems) {
    
                    StockStatus stProductOfItem = null;
    
                    // Get the line of stock status that match the product local code of the order line
                    for (StockStatus st : status.lOutOfStockLines) {
                        if (st.productLocalCode == item.Product2.LU_Local_Code__c) {
                            stProductOfItem = st;
                            break;
                        }
                    }
    
                    // If there is a line of stockstatus, that means there is an issue on this product : out of stock. Put the inforamtion on the line and save.
                    if (stProductOfItem != null) {
                        String stockInfoMessage = (stProductOfItem.stockOutOfStockMessage != null ? stProductOfItem.stockOutOfStockMessage : '');
                        stockInfoMessage += (stProductOfItem.childOutOfStockMessage != null ? ' : ' + stProductOfItem.childOutOfStockMessage : '');
                        OrderItem it = new OrderItem(Id = item.Id, LU_Stock_Status__c = 'outofstock', LU_Stock_Message__c = stockInfoMessage);
                        lItemsToUpdate.add(it);
                    } else { // If no stock status, update the line with no stock status
                        OrderItem it = new OrderItem(Id = item.Id, LU_Stock_Status__c = 'ok', LU_Stock_Message__c = '');
                        lItemsToUpdate.add(it);
                    }
    
                }
    
                // Update the order lines
                if (!lItemsToUpdate.isEmpty()) {
                    update lItemsToUpdate;
                }
    
            }
    
        }
    
        public static void decreaseTheStockForOrder(Id orderId, OrderStockStatus orderStockStatus) {
    
            if (orderStockStatus.lStockUsedToInsertForOrder != null && !orderStockStatus.lStockUsedToInsertForOrder.isEmpty()) {
    
                List<OrderItem> lOrderItemsToUpdate = new List<OrderItem>();
    
                // Get order item information
                Order order = [SELECT Id, BillToContactId, 
                                (SELECT Id, PricebookEntryId, Product2Id, Product2.LU_TECH_External_Id__c, Product2.LU_Local_Code__c, 
                                    Quantity, Description
                                    FROM OrderItems
                                    WHERE Product2.LU_Stock_Status__c in :STOCK_STATUS_TO_MANAGE)
                                FROM Order
                                WHERE Id =: orderId];
                Set<String> sLocalCodes = new Set<String>();
                for (OrderItem line : order.OrderItems) {
                    sLocalCodes.add(line.Product2.LU_Local_Code__c);
                }
    
                for (OrderItem line : order.OrderItems) {
                    
                    String productId = line.Product2Id;
                    String msgSubsituteForOrderItem = '';
                    for (LU_Stock_Used__c stUsed : orderStockStatus.lStockUsedToInsertForOrder) {
                        if (stUsed.LU_Order_Line__c == line.Id && stUsed.LU_Product__c != productId) {
                            String msg = Label.LU_Stock_Order_ReplacedLine;
                            msg = msg.replace('$QUANTITYREPLACED', (Integer)stUsed.LU_Quantity_Ordered__c + '');
                            msg = msg.replace('$OFFERREPLACMENT', stUsed.LU_Product_Local_Code__c + ' ' + stUsed.LU_Product_Local_Name__c);
                            msgSubsituteForOrderItem = (msgSubsituteForOrderItem != '' ? ', ' : '') + msg;
                        }
                    }
    
                    if (msgSubsituteForOrderItem != '') {
                        OrderItem ordLine = new OrderItem(Id = line.Id, LU_Stock_Message__c = msgSubsituteForOrderItem);
                        lOrderItemsToUpdate.add(ordLine);
                    }
                }
                
                insert orderStockStatus.lStockUsedToInsertForOrder;
    
                if (!lOrderItemsToUpdate.isEmpty()) {
                    update lOrderItemsToUpdate;
                }
    
            }
    
        }
    
    /* UTILITY METHODS */
        public static Set<String> getProductLocalCodeOfOrderItem(List<OrderItem> lOrderItems) {
    
            // Variables
            Set<String> sProductLocalCodes = new Set<String>();
    
            // Get the local code of each product
            for (OrderItem line : lOrderItems) {
                sProductLocalCodes.add(line.Product2.LU_Local_Code__c);
            }
    
            return (sProductLocalCodes);
        }
    
        public static Set<String> getProductLocalCodeOfPricebookEntries(List<PricebookEntry> lPricebookEntries) {
    
            // Variables
            Set<String> sProductLocalCodes = new Set<String>();
    
            // Get the local code of each product
            for (PricebookEntry product : lPricebookEntries) {
                sProductLocalCodes.add(product.Product2.LU_Local_Code__c);
            }
    
            return (sProductLocalCodes);
        }
    
        public static StockStatus getProductStockStatusFromList(List<StockStatus> lStockStatus, String productLocalCode) {
    
            // Variable
            StockStatus st = null;
    
            for (StockStatus pStatus : lStockStatus) {
                if (pStatus.productLocalCode == productLocalCode) {
                    st = pStatus;
                    break;
                }
            }
    
            return (st);
        }
    }