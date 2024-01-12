public without sharing class Lwc17_fastordersearchbar_ctrl {
    
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

        System.debug('Lwc17_fastordersearchbar_ctrl.searchProduct searchTerm : ' + searchTerm);
        System.debug('Lwc17_fastordersearchbar_ctrl.searchProduct selectedIds : ' + selectedIds);
        System.debug('Lwc17_fastordersearchbar_ctrl.searchProduct offerType : ' + offerType);
        System.debug('Lwc17_fastordersearchbar_ctrl.searchProduct contactStr : ' + contactStr);

        List<LU_ProductSearchRule__mdt> vListProdSearchRules = [Select Id, Country__c, How__c, What__c
                                                                From LU_ProductSearchRule__mdt];

        // Variables
        List<AP1002_LookupSearchResult> lRes = new List<AP1002_LookupSearchResult>();
        String country = null;
        String techExternalId = null;
        Id contactId = null;
        //searchTerm = (String) '%' + searchTerm + '%';
        String vProdCodeSearchTerm = '';
        String vProdNameSearchTerm = '';

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
                vProdCodeSearchTerm = searchTerm + '%';
            } else {
                vProdNameSearchTerm = '%' + searchTerm + '%';
            }
		} 
		
		//SFT-1696, Commented out because now product search will happen according to new algorithm
		/*	
        for(LU_ProductSearchRule__mdt vProdSearchRule : vListProdSearchRules) {
            // FRA or ITA
            if(vProdSearchRule.Country__c == country) {
				
				String vWhat = vProdSearchRule.What__c;
				String vHow = vProdSearchRule.How__c;
				if(vWhat == AppConstants.PRODSEARCHRULE_WHAT_CODE) {
					vProdCodeSearchTerm = vHow.replace('#', searchTerm);
				} else if(vWhat == AppConstants.PRODSEARCHRULE_WHAT_NAME) {
					vProdNameSearchTerm = vHow.replace('#', searchTerm);
				}
            }
        }*/

        // Get contact information : balances
        Contact con = [SELECT LU_Counter_1_Name__c,
                              LU_Counter_2_Name__c,
                              LU_Counter_3_Name__c,
                              LU_Counter_4_Name__c,
                              LU_Counter_5_Name__c,
                              LU_Counter_6_Name__c,
                              LU_Counter_7_Name__c,
                              LU_Counter_8_Name__c,
                              LU_Counter_9_Name__c,
                              LU_Counter_10_Name__c,
                              LU_Counter_11_Name__c,
                              LU_Counter_12_Name__c,
                              LU_Counter_13_Name__c,
                              LU_Counter_14_Name__c,
                              LU_Counter_15_Name__c,
                              LU_Counter_16_Name__c,
                              LU_Counter_17_Name__c,
                              LU_Counter_18_Name__c,
                              LU_Counter_19_Name__c,
                              LU_Counter_20_Name__c,
                              LU_Counter_21_Name__c,
                              LU_Counter_22_Name__c,
                              LU_Counter_23_Name__c,
                              LU_Counter_24_Name__c,
                              LU_Counter_25_Name__c,
                              LU_Counter_26_Name__c,
                              LU_Counter_27_Name__c,
                              LU_Counter_28_Name__c,
                              LU_Counter_29_Name__c,
                              LU_Counter_30_Name__c,
                              LU_Counters_Unit__c,
                              LU_Counters_Unit_Bis__c,
                              LU_Eligibility_Groups__c
                         FROM Contact
                        WHERE Id = :contactId]; //u.TECH_MergeContactID__c

        

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
                                    Product2.LU_Local_Code__c LIKE :vProdCodeSearchTerm
                                    OR Product2.Name LIKE :vProdNameSearchTerm
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
                                    Product2.LU_Local_Code__c LIKE :vProdCodeSearchTerm
                                    OR Product2.Name LIKE :vProdNameSearchTerm
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
            
            List<AP1011_Stock_Utils.StockStatus> lStockStatus = AP1011_Stock_Utils.getStockRemainingForProducts(l_idProduct, sProductLocalCodes, sEligibilitySegmentOfContact, 
                                                                                                                offerType, country);

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
                    if (isUnderLowLimitThreshold && AP1011_Stock_Utils.STOCK_STATUS_OUTOFSTOCK.contains(stockStatusOfProduct.stockStatus)) {
                        isOutOfStock = false;
                    } else {
                        isOutOfStock = AP1011_Stock_Utils.isProductOutOfStock(stockStatusOfProduct);

                        // If the product is out of stock, check if a substitute can be used instead
                        if (isOutOfStock) {

                            // If the product has substitute
                            if (stockStatusOfProduct.lSubstituteProducts != null && !stockStatusOfProduct.lSubstituteProducts.isEmpty()) {

                                for (AP1011_Stock_Utils.StockStatus stSubstitute : stockStatusOfProduct.lSubstituteProducts) {
                                    
                                    if (stSubstitute.stockRemaining != null && stSubstitute.stockRemaining > 0) {

                                        for (PricebookEntry entrySub : stSubstitute.lPricebookEntriesOfSubstituteOffers) {
                                            if (country == 'ITA' || (country == 'FRA' && entrySub.LU_Eligibility_Segments__c == pbe.LU_Eligibility_Segments__c) ) {
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

        if (pbe != null && l_pbeCounter.size() > 0) {
            if(con.LU_Counter_1_Name__c != null && l_pbeCounter.get(0) != null && Decimal.valueOf(l_pbeCounter.get(0)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_1_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_1_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(0)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_1_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(0));
                cou.unit = countersUnit.split('#').get(0);
                l_counters.add(cou);
            }
            if(con.LU_Counter_2_Name__c != null && l_pbeCounter.get(1) != null && Decimal.valueOf(l_pbeCounter.get(1)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_2_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_2_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(1)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_2_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(1));
                cou.unit = countersUnit.split('#').get(1);
                l_counters.add(cou);
            }
            if(con.LU_Counter_3_Name__c != null && l_pbeCounter.get(2) != null && Decimal.valueOf(l_pbeCounter.get(2)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_3_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_3_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(2)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_3_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(2));
                cou.unit = countersUnit.split('#').get(2);
                l_counters.add(cou);
            }
            if(con.LU_Counter_4_Name__c != null && l_pbeCounter.get(3) != null && Decimal.valueOf(l_pbeCounter.get(3)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_4_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_4_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(3)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_4_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(3));
                cou.unit = countersUnit.split('#').get(3);
                l_counters.add(cou);
            }
            if(con.LU_Counter_5_Name__c != null && l_pbeCounter.get(4) != null && Decimal.valueOf(l_pbeCounter.get(4)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_5_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_5_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(4)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_5_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(4));
                cou.unit = countersUnit.split('#').get(4);
                l_counters.add(cou);
            }
            if(con.LU_Counter_6_Name__c != null && l_pbeCounter.get(5) != null && Decimal.valueOf(l_pbeCounter.get(5)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_6_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_6_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(5)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_6_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(5));
                cou.unit = countersUnit.split('#').get(5);
                l_counters.add(cou);
            }
            if(con.LU_Counter_7_Name__c != null && l_pbeCounter.get(6) != null && Decimal.valueOf(l_pbeCounter.get(6)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_7_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_7_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(6)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_7_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(6));
                cou.unit = countersUnit.split('#').get(6);
                l_counters.add(cou);
            }
            if(con.LU_Counter_8_Name__c != null && l_pbeCounter.get(7) != null && Decimal.valueOf(l_pbeCounter.get(7)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_8_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_8_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(7)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_8_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(7));
                cou.unit = countersUnit.split('#').get(7);
                l_counters.add(cou);
            }
            if(con.LU_Counter_9_Name__c != null && l_pbeCounter.get(8) != null && Decimal.valueOf(l_pbeCounter.get(8)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_9_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_9_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(8)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_9_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(8));
                cou.unit = countersUnit.split('#').get(8);
                l_counters.add(cou);
            }
            if(con.LU_Counter_10_Name__c != null && l_pbeCounter.get(9) != null && Decimal.valueOf(l_pbeCounter.get(9)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_10_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_10_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(9)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_10_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(9));
                cou.unit = countersUnit.split('#').get(9);
                l_counters.add(cou);
            }
            if(con.LU_Counter_11_Name__c != null && l_pbeCounter.get(10) != null && Decimal.valueOf(l_pbeCounter.get(10)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_11_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_11_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(10)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_11_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(10));
                cou.unit = countersUnit.split('#').get(10);
                l_counters.add(cou);
            }
            if(con.LU_Counter_12_Name__c != null && l_pbeCounter.get(11) != null && Decimal.valueOf(l_pbeCounter.get(11)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_12_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_12_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(11)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_12_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(11));
                cou.unit = countersUnit.split('#').get(11);
                l_counters.add(cou);
            }
            if(con.LU_Counter_13_Name__c != null && l_pbeCounter.get(12) != null && Decimal.valueOf(l_pbeCounter.get(12)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_13_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_13_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(12)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_13_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(12));
                cou.unit = countersUnit.split('#').get(12);
                l_counters.add(cou);
            }
            if(con.LU_Counter_14_Name__c != null && l_pbeCounter.get(13) != null && Decimal.valueOf(l_pbeCounter.get(13)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_14_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_14_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(13)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_14_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(13));
                cou.unit = countersUnit.split('#').get(13);
                l_counters.add(cou);
            }
            if(con.LU_Counter_15_Name__c != null && l_pbeCounter.get(14) != null && Decimal.valueOf(l_pbeCounter.get(14)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_15_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_15_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(14)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_15_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(14));
                cou.unit = countersUnit.split('#').get(14);
                l_counters.add(cou);
            }
            if(con.LU_Counter_16_Name__c != null && l_pbeCounter.get(15) != null && Decimal.valueOf(l_pbeCounter.get(15)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_16_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_16_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(15)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_16_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(15));
                cou.unit = countersUnit.split('#').get(15);
                l_counters.add(cou);
            }
            if(con.LU_Counter_17_Name__c != null && l_pbeCounter.get(16) != null && Decimal.valueOf(l_pbeCounter.get(16)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_17_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_17_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(16)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_17_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(16));
                cou.unit = countersUnit.split('#').get(16);
                l_counters.add(cou);
            }
            if(con.LU_Counter_18_Name__c != null && l_pbeCounter.get(17) != null && Decimal.valueOf(l_pbeCounter.get(17)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_18_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_18_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(17)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_18_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(17));
                cou.unit = countersUnit.split('#').get(17);
                l_counters.add(cou);
            }
            if(con.LU_Counter_19_Name__c != null && l_pbeCounter.get(18) != null && Decimal.valueOf(l_pbeCounter.get(18)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_19_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_19_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(18)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_19_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(18));
                cou.unit = countersUnit.split('#').get(18);
                l_counters.add(cou);
            }
            if(con.LU_Counter_20_Name__c != null && l_pbeCounter.get(19) != null && Decimal.valueOf(l_pbeCounter.get(19)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_20_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_20_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(19)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_20_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(19));
                cou.unit = countersUnit.split('#').get(19);
                l_counters.add(cou);
            }
            if(con.LU_Counter_21_Name__c != null && l_pbeCounter.get(20) != null && Decimal.valueOf(l_pbeCounter.get(20)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_21_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_21_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(20)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_21_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(20));
                cou.unit = countersUnit.split('#').get(20);
                l_counters.add(cou);
            }
            if(con.LU_Counter_22_Name__c != null && l_pbeCounter.get(21) != null && Decimal.valueOf(l_pbeCounter.get(21)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_22_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_22_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(21)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_22_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(21));
                cou.unit = countersUnit.split('#').get(21);
                l_counters.add(cou);
            }
            if(con.LU_Counter_23_Name__c != null && l_pbeCounter.get(22) != null && Decimal.valueOf(l_pbeCounter.get(22)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_23_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_23_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(22)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_23_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(22));
                cou.unit = countersUnit.split('#').get(22);
                l_counters.add(cou);
            }
            if(con.LU_Counter_24_Name__c != null && l_pbeCounter.get(23) != null && Decimal.valueOf(l_pbeCounter.get(23)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_24_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_24_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(23)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_24_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(23));
                cou.unit = countersUnit.split('#').get(23);
                l_counters.add(cou);
            }
            if(con.LU_Counter_25_Name__c != null && l_pbeCounter.get(24) != null && Decimal.valueOf(l_pbeCounter.get(24)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_25_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_25_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(24)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_25_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(24));
                cou.unit = countersUnit.split('#').get(24);
                l_counters.add(cou);
            }
            if(con.LU_Counter_26_Name__c != null && l_pbeCounter.get(25) != null && Decimal.valueOf(l_pbeCounter.get(25)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_26_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_26_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(25)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_26_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(25));
                cou.unit = countersUnit.split('#').get(25);
                l_counters.add(cou);
            }
            if(con.LU_Counter_27_Name__c != null && l_pbeCounter.get(26) != null && Decimal.valueOf(l_pbeCounter.get(26)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_27_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_27_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(26)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_27_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(26));
                cou.unit = countersUnit.split('#').get(26);
                l_counters.add(cou);
            }
            if(con.LU_Counter_28_Name__c != null && l_pbeCounter.get(27) != null && Decimal.valueOf(l_pbeCounter.get(27)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_28_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_28_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(27)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_28_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(27));
                cou.unit = countersUnit.split('#').get(27);
                l_counters.add(cou);
            }
            if(con.LU_Counter_29_Name__c != null && l_pbeCounter.get(28) != null && Decimal.valueOf(l_pbeCounter.get(28)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_29_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_29_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(28)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_29_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(28));
                cou.unit = countersUnit.split('#').get(28);
                l_counters.add(cou);
            }
            if(con.LU_Counter_30_Name__c != null && l_pbeCounter.get(29) != null && Decimal.valueOf(l_pbeCounter.get(29)) < 0){
                if(country == 'ITA'){
                    counters += con.LU_Counter_30_Name__c.split('#').get(0) + ' - ';
                }
                else{
                    counters += con.LU_Counter_30_Name__c.split('#').get(0) + ' : ' + Decimal.valueOf(l_pbeCounter.get(29)).setScale(2) + ' - ';
                }
                cou = new AP1002_LookupSearchResult.Counter();
                cou.name = con.LU_Counter_30_Name__c.split('#').get(0);
                cou.value = Decimal.valueOf(l_pbeCounter.get(29));
                cou.unit = countersUnit.split('#').get(29);
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
    public static AP1002_LookupSearchResult.Substitute setValuesOnSearchResultSubstitute(PricebookEntry entry, wrapperCounters wrCounters, Boolean isOutOfStock, Boolean isUnderLowLimitThreshold,
                                                                    AP1011_Stock_Utils.StockStatus stockStatusOfProduct, LU_Order_Rule__c lowLimitSetting) {
        system.debug('>>>> setValuesOnSearchResultSubstitute START ');
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
        
        system.debug(res);
        system.debug('>>>> setValuesOnSearchResultSubstitute END ');

        return (res);
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
            } else if (AP1011_Stock_Utils.STOCK_STATUS_LIMITED.contains(stockStatusOfProduct.stockStatus) || isUnderLowLimitThreshold ) {
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

    @AuraEnabled
    public static String getPorductListOfBundle(Id idProductOffer, Id idpbentry, Id idPb) {

        System.Debug('idProductOffer : ' + idProductOffer);
        System.Debug('idProductOffer : ' + idPb);

        Product2 parent = [SELECT Id, LU_Number_Of_Articles__c
                            FROM Product2
                            WHERE Id =: idProductOffer];

        List<AP1002_LookupSearchResult> lRes = new List<AP1002_LookupSearchResult>();
        List<AP1002_LookupSearchResult> lResGift = new List<AP1002_LookupSearchResult>();
        Datetime vNow = Datetime.now();
        List<Product2> childs = [SELECT Id, Name, LU_Local_Code__c, LU_Min_Qty_Orderable__c, LU_Max_Qty_Orderable__c, LU_Type_Child__c, LU_TECH_External_Id__c
                                    FROM Product2
                                    WHERE LU_Parent_Product__c =: idProductOffer
                                    AND IsActive = true 
                                    AND 
                                    (
                                        (LU_Child_Start_date__c <= :vNow AND LU_Child_End_date__c >= :vNow )
                                        OR
                                        (LU_Child_Start_date__c = null AND LU_Child_End_date__c = null)
                                    )];
    
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

                res.articleOfTheLine = child.LU_TECH_External_Id__c;
            }

            if(!lResGift.isEmpty()){
                List<AP1002_LookupSearchResult> lResTemp = new List<AP1002_LookupSearchResult>();
                lResTemp.addAll(lRes);
                lResTemp.addAll(lResGift);
                lRes = lResTemp;
//                lRes.addAll(lResGift);
            }
            
        }

        return JSON.serialize(lRes);
    }

    @AuraEnabled
    public static String addToBasket(List<AP1002_LookupSearchResult> l_product, String idOrder, Id idPriceBook, Contact contactLine) {

        String contactId; 

        Set<String> s_productId = new Set<String>();

        Id idContact = (contactLine != null && contactLine.RecordType.DeveloperName != 'LU_Personal_Contact' ? contactLine.Id : null);

        Contact vCon = AP1003_Utils_Contact.getContactInfo(AP1002_Utils_User.getConnectedUserContact().Id);
        
        if (idOrder == null || vCon.Title == AppConstants.CON_TITLE_DF) {
            idOrder = Lwc17_fastordersearchbar_ctrl.getOrder(idPriceBook, idContact);
        }

        if(l_product.isEmpty() || String.IsBlank(idOrder) ){
            return 'ko';
        }

        Order ord = [SELECT Id, BillToContactId, BillToContact.STHId__c, LU_Country_Code__c, LU_TECH_Order_Number__c, Status FROM Order WHERE Id = :idOrder];
        if(ord.Status != 'Draft'){
            return Label.LU_Order_Validated_Error;
        }
        
        Contact connectedContact = AP1002_Utils_User.getConnectedUserContact();
        contactId = (contactLine != null ? (String) contactLine.Id : connectedContact.Id);

        for(AP1002_LookupSearchResult lsr : l_product){
            s_productId.add(lsr.productId);
        }

        String query = 'SELECT Product2Id, LU_Contact_For__c, Quantity, LU_Article_Of_The_Line__c, PriceBookEntry.LU_Maximum_Quantity__c '
                        + 'FROM OrderItem ' 
                        + 'WHERE OrderId = :idOrder '
                        + 'AND Product2Id IN :s_productId '
                        + 'AND LU_Contact_For__c = :contactId';

        Map<String, OrderItem> m_existingOrderItem = new Map<String, OrderItem>();
        for(OrderItem oi : Database.query(query) ){
            m_existingOrderItem.put(oi.LU_Article_Of_The_Line__c, oi);
        }

        Set<Id> s_idPbe = new Set<Id>();
        for(AP1002_LookupSearchResult product : l_product){
            s_idPbe.add(product.id);
        }

        Map<Id, PriceBookEntry> m_pbe = new Map<Id, PriceBookEntry>([SELECT LU_Offer_type__c, Product2.LU_Type__c FROM PricebookEntry WHERE Id IN :s_idPbe]);

        List<OrderItem> l_orderItem = new List<OrderItem>();
        for(AP1002_LookupSearchResult product : l_product){

            if(m_existingOrderItem.containsKey(product.articleOfTheLine)){
                m_existingOrderItem.get(product.articleOfTheLine).Quantity += product.quantity;
                if(m_existingOrderItem.get(product.articleOfTheLine).Quantity > m_existingOrderItem.get(product.articleOfTheLine).PriceBookEntry.LU_Maximum_Quantity__c){
                    return 'Error - ' + product.title + ' : ' + Label.LU_SearchProductLimitedQuantity.replace('{MAX}', m_existingOrderItem.get(product.articleOfTheLine).PriceBookEntry.LU_Maximum_Quantity__c.setScale(0) + '');
                }
                continue;
            }

            if (product.quantity != 0) {
                //con.AccountCountryCode__c + '_ORDER_' + con.STHId__c + '_' + ord.LU_TECH_Order_Number__c
                OrderItem item = new OrderItem(
                                                OrderId = idOrder, 
                                                PricebookEntryId = product.Id,
                                                Product2Id = product.productId, 
                                                Quantity = product.quantity,
                                                UnitPrice = product.unitPrice,
                                                LU_Valid_For_Total_Amount_Base__c = product.validForTotalMountBase == true,
                                                LU_Tax_Rate__c = product.taxRate,
                                                LU_Contact_For__c = contactId, //(contactLine != null ? contactLine.Id : null),
                                                LU_Brand_Territory__c = product.brandTerritory,
                                                LU_Brand__c = product.brand,
                                                LU_Public_Price__c = product.priceTTC,
                                                LU_Discount_Type__c = product.discountType,
                                                LU_Dealer_Price__c = product.dealerPrice
                );

                if(vCon.AccountCountryCode__c == 'FRA'){
                    if(product.stockStatus == 'Available'){
                        item.LU_Stock_Status__c = 'ok';
                    }
                    else if(product.stockStatus == 'Out-of-stock' || product.stockStatus == 'Temporarily out-of-stock'|| product.stockStatus == 'Out-of stock'){
                        item.LU_Stock_Status__c = 'outofstock';
                    }
                    else if(product.stockStatus == 'Limited quantity'){
                        item.LU_Stock_Status__c = 'warning';
                    }
                    item.LU_Stock_Message__c = product.stockMessage;
                }

                if(!String.isBlank(product.counterValuePricebookEntry)){
                    item.LU_Counter_1_new__c = product.counterValuePricebookEntry.split('#')[0] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[0]) * product.quantity;
                    item.LU_Counter_2_new__c = product.counterValuePricebookEntry.split('#')[1] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[1]) * product.quantity;
                    item.LU_Counter_3_new__c = product.counterValuePricebookEntry.split('#')[2] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[2]) * product.quantity;
                    item.LU_Counter_4_new__c = product.counterValuePricebookEntry.split('#')[3] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[3]) * product.quantity;
                    item.LU_Counter_5_new__c = product.counterValuePricebookEntry.split('#')[4] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[4]) * product.quantity;
                    item.LU_Counter_6_new__c = product.counterValuePricebookEntry.split('#')[5] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[5]) * product.quantity;
                    item.LU_Counter_7_new__c = product.counterValuePricebookEntry.split('#')[6] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[6]) * product.quantity;
                    item.LU_Counter_8_new__c = product.counterValuePricebookEntry.split('#')[7] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[7]) * product.quantity;
                    item.LU_Counter_9_new__c = product.counterValuePricebookEntry.split('#')[8] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[8]) * product.quantity;
                    item.LU_Counter_10_new__c = product.counterValuePricebookEntry.split('#')[9] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[9]) * product.quantity;
                    item.LU_Counter_11_new__c = product.counterValuePricebookEntry.split('#')[10] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[10]) * product.quantity;
                    item.LU_Counter_12_new__c = product.counterValuePricebookEntry.split('#')[11] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[11]) * product.quantity;
                    item.LU_Counter_13_new__c = product.counterValuePricebookEntry.split('#')[12] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[12]) * product.quantity;
                    item.LU_Counter_14_new__c = product.counterValuePricebookEntry.split('#')[13] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[13]) * product.quantity;
                    item.LU_Counter_15_new__c = product.counterValuePricebookEntry.split('#')[14] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[14]) * product.quantity;
                    item.LU_Counter_16_new__c = product.counterValuePricebookEntry.split('#')[15] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[15]) * product.quantity;
                    item.LU_Counter_17_new__c = product.counterValuePricebookEntry.split('#')[16] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[16]) * product.quantity;
                    item.LU_Counter_18_new__c = product.counterValuePricebookEntry.split('#')[17] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[17]) * product.quantity;
                    item.LU_Counter_19_new__c = product.counterValuePricebookEntry.split('#')[18] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[18]) * product.quantity;
                    item.LU_Counter_20_new__c = product.counterValuePricebookEntry.split('#')[19] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[19]) * product.quantity;
                    item.LU_Counter_21_new__c = product.counterValuePricebookEntry.split('#')[20] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[20]) * product.quantity;
                    item.LU_Counter_22_new__c = product.counterValuePricebookEntry.split('#')[21] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[21]) * product.quantity;
                    item.LU_Counter_23_new__c = product.counterValuePricebookEntry.split('#')[22] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[22]) * product.quantity;
                    item.LU_Counter_24_new__c = product.counterValuePricebookEntry.split('#')[23] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[23]) * product.quantity;
                    item.LU_Counter_25_new__c = product.counterValuePricebookEntry.split('#')[24] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[24]) * product.quantity;
                    item.LU_Counter_26_new__c = product.counterValuePricebookEntry.split('#')[25] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[25]) * product.quantity;
                    item.LU_Counter_27_new__c = product.counterValuePricebookEntry.split('#')[26] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[26]) * product.quantity;
                    item.LU_Counter_28_new__c = product.counterValuePricebookEntry.split('#')[27] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[27]) * product.quantity;
                    item.LU_Counter_29_new__c = product.counterValuePricebookEntry.split('#')[28] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[28]) * product.quantity;
                    item.LU_Counter_30_new__c = product.counterValuePricebookEntry.split('#')[29] == '' ? 0 : Decimal.valueOf(product.counterValuePricebookEntry.split('#')[29]) * product.quantity;
                }
                // Case of main line (not child)
                if ( m_pbe.get(product.id) != null ) {
                    item.LU_Offer_Type__c = m_pbe.get(product.id).LU_Offer_type__c;
                    item.LU_Product_Type__c = m_pbe.get(product.id).Product2.LU_Type__c;
                }

                item.LU_Is_A_Sell__c = item.LU_Contact_For__c != ord.BillToContactId ? true : false;

                if (product.idBundle != null) {
                    item.LU_Child_Product__c = product.id;
                    item.PricebookEntryId = product.idBundle;
                    item.LU_Is_A_Child_Line__c = true;
                }

                l_orderItem.add(item);
            }
            
        }

        // /* Merge the lines of the same products for each customer */
        // Order ord = [SELECT Id, (SELECT Id, PricebookEntryId, Quantity FROM OrderItems) 
        //                 FROM Order 
        //                 WHERE Id =: idOrder];
        // List<OrderItem> lItemsToInsert = new List<OrderItem>();
        // List<OrderItem> lItemsToUpdate = new List<OrderItem>();
        // for (OrderItem item : ord.OrderItems) {

        // }

        // Insert the order items
        insert l_orderItem;
        
        l_orderItem = [SELECT Id, LU_TECH_Line_Number__c FROM OrderItem WHERE Id in :l_orderItem];

        // Add external id
        for (OrderItem item : l_orderItem) {
            String extIdLine = ord.LU_Country_Code__c + '_ORDERLINE_' + ord.BillToContact.STHId__c + '_' + + ord.LU_TECH_Order_Number__c;
            extIdLine += '_' + item.LU_TECH_Line_Number__c;
            item.LU_TECH_External_Id__c = extIdLine;
        }
        update l_orderItem;


        update m_existingOrderItem.values();

        return idOrder;
    }


    /* BUSINES METHODS */
    public static Id getOrder(Id idPriceBook, Id contactId) {

        Contact con = null;

        if(String.IsBlank(idPriceBook)) {
            return 'ko';
        }

        if (contactId != null) {
            con = AP1003_Utils_Contact.getContactInfo(contactId);
            if (con.RecordType.DeveloperName == 'LU_Personal_Contact') {
                con = AP1002_Utils_User.getConnectedUserContact();
            }
        } else {
            con = AP1002_Utils_User.getConnectedUserContact();
        }

        List<Order> l_order = [SELECT Id FROM Order 
                               WHERE BillToContactId = :con.Id 
                                 AND Status = 'Draft' AND Type='LineUp'
                                 LIMIT 1 ]; //AND Pricebook2Id = :idPriceBook 
        Order ord;
        if (l_order.isEmpty() ){
                ord = new Order(
                    EffectiveDate = Date.today(),
                    AccountId = con.AccountId,
                    Status = 'Draft',
                    BillToContactId = con.Id,
                    Pricebook2Id = idPriceBook
                );

            insert ord;

            // ORD-{YYYY}{MM}{DD}-{000000}
            Date dt = Date.today();
            ord = [SELECT Id, Name, OrderNumber, LU_TECH_Order_Number__c, Tech_External_Id__c FROM Order WHERE Id =: ord.Id];
            //ord.Name = 'ORD-' + dt.year() + dt.month() + dt.day() + '-' + ord.OrderNumber;
            ord.Name = 'ORD-' + ord.LU_TECH_Order_Number__c;
            ord.Tech_External_Id__c = con.AccountCountryCode__c + '_ORDER_' + con.STHId__c + '_' + ord.LU_TECH_Order_Number__c;
            update ord;

            return ord.Id;
        }
        else{
            l_order.get(0).Pricebook2Id = idPriceBook;
            update l_order;
            return l_order.get(0).Id;
        }
    }

    @AuraEnabled
    public static String getOrderIdWithoutPricebook(Id contactId) {

        Contact con = null;
        if (contactId != null) {
            con = AP1003_Utils_Contact.getContactInfo(contactId);
            if (con.RecordType.DeveloperName == 'LU_Personal_Contact') {
                con = AP1002_Utils_User.getConnectedUserContact();
            }
        } else {
            con = AP1002_Utils_User.getConnectedUserContact();
        }


        List<Order> l_order = [SELECT Id FROM Order 
                               WHERE BillToContactId = :con.Id 
                                 AND Status = 'Draft' AND Type = 'LineUp' LIMIT 1];
        Order ord;
        if(l_order.isEmpty()){
            ord = new Order(
                EffectiveDate = Date.today(),
                AccountId = con.AccountId,
                Status = 'Draft',
                BillToContactId = con.Id
            );

            insert ord;

            // ORD-{YYYY}{MM}{DD}-{000000}
            Date dt = Date.today();
            ord = [SELECT Id, Name, OrderNumber, LU_TECH_Order_Number__c, Tech_External_Id__c FROM Order WHERE Id =: ord.Id];
            //ord.Name = 'ORD-' + dt.year() + dt.month() + dt.day() + '-' + ord.OrderNumber;
            ord.Name = 'ORD-' + ord.LU_TECH_Order_Number__c;
            ord.Tech_External_Id__c = con.AccountCountryCode__c + '_ORDER_' + con.STHId__c + '_' + ord.LU_TECH_Order_Number__c;
            update ord;

            return ord.Id;
        }
        else{
            return l_order.get(0).Id;
        }
    }

    @AuraEnabled
    public static String getUserCountry(){
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    @AuraEnabled
    public static List<AP1002_LookupSearchResult> getPriceBookEntry(String pbeId, Contact orderContact){

        List<String> l_pbeId = pbeId.split(';');

        List<AP1002_LookupSearchResult> l_res = new List<AP1002_LookupSearchResult>();

        if(!l_pbeId.isEmpty()){
            List<PriceBookEntry> l_product = [SELECT id, LU_Offer_type__c, Name, UnitPrice, Product2.LU_Number_Of_Articles__c, Product2.RecordType.Name, 
                                                     Product2.RecordType.DeveloperName, Product2Id, Product2.LU_Bundle_Type__c, LU_Maximum_Quantity__c,
                                                     PriceBook2Id, LU_Valid_For_Total_Amount_Base__c, LU_TaxRate__c, LU_Counter_Value__c, Product2.LU_TECH_External_Id__c,
                                                     Product2.LU_Local_Code__c, Product2.LU_Stock_Status__c, Product2.LU_Stock_Available__c, Product2.LU_Smart_Reference__c,
                                                     Product2.LU_Brand_Territory__c, Product2.LU_Brand__c , LU_TECH_External_Id__c, Discount_Type__c, LU_Dealer_Price__c, LU_Public_Price__c
                                                FROM PricebookEntry 
                                               WHERE LU_TECH_External_Id__c IN :l_pbeId];

            User u = [SELECT TECH_MergeContactID__c FROM User WHERE Id = :UserInfo.getUserId()];

            Contact con = [SELECT LU_Counter_1_Name__c,
                                LU_Counter_2_Name__c,
                                LU_Counter_3_Name__c,
                                LU_Counter_4_Name__c,
                                LU_Counter_5_Name__c,
                                LU_Counter_6_Name__c,
                                LU_Counter_7_Name__c,
                                LU_Counter_8_Name__c,
                                LU_Counter_9_Name__c,
                                LU_Counter_10_Name__c,
                                LU_Counter_11_Name__c,
                                LU_Counter_12_Name__c,
                                LU_Counter_13_Name__c,
                                LU_Counter_14_Name__c,
                                LU_Counter_15_Name__c,
                                LU_Counter_16_Name__c,
                                LU_Counter_17_Name__c,
                                LU_Counter_18_Name__c,
                                LU_Counter_19_Name__c,
                                LU_Counter_20_Name__c,
                                LU_Counter_21_Name__c,
                                LU_Counter_22_Name__c,
                                LU_Counter_23_Name__c,
                                LU_Counter_24_Name__c,
                                LU_Counter_25_Name__c,
                                LU_Counter_26_Name__c,
                                LU_Counter_27_Name__c,
                                LU_Counter_28_Name__c,
                                LU_Counter_29_Name__c,
                                LU_Counter_30_Name__c,
                                LU_Counters_Unit__c,
                                LU_Counters_Unit_Bis__c,
                                LU_Eligibility_Groups__c
                            FROM Contact
                            WHERE Id = :orderContact.Id];

            String country = AP1002_Utils_User.getUserCountry(UserInfo.getUserId());

            // Get stock settings
            LU_Order_Rule__c lowLimitSetting = AP1011_Stock_Utils.getLowLimitThreshold(country);
            

            if (!l_product.isEmpty()) {

                Set<String> sEligibilitySegmentOfContact = new Set<String>();
                if (con.LU_Eligibility_Groups__c != null && con.LU_Eligibility_Groups__c != '') {
                    for (String groupEligibilty : con.LU_Eligibility_Groups__c.split('#')) {
                        sEligibilitySegmentOfContact.add(groupEligibilty);
                    }
                }

                // Get stock status of products
                Set<String> sProductLocalCodes = AP1011_Stock_Utils.getProductLocalCodeOfPricebookEntries(l_product);
                List<Id> l_idProduct = new List<Id>();
                for(PriceBookEntry pB : l_product){
                    l_idProduct.add(pB.product2Id);
                }
                
                List<AP1011_Stock_Utils.StockStatus> lStockStatus = AP1011_Stock_Utils.getStockRemainingForProducts(l_idProduct,
                                                                                                                    sProductLocalCodes,
                                                                                                                    sEligibilitySegmentOfContact,
                                                                                                                    null,
                                                                                                                    country + '%');


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
                        isOutOfStock = AP1011_Stock_Utils.isProductOutOfStock(stockStatusOfProduct);

                        // If the product is out of stock, check if a substitute can be used instead
                        if (isOutOfStock) {
                            // If the product has substitute
                            if (stockStatusOfProduct.lSubstituteProducts != null && !stockStatusOfProduct.lSubstituteProducts.isEmpty()) {
                                for (AP1011_Stock_Utils.StockStatus stSubstitute : stockStatusOfProduct.lSubstituteProducts) {
                                    if (stSubstitute.stockRemaining != null && stSubstitute.stockRemaining > 0) {
                                        res.isSubstituteArtile = true;
                                        Lwc17_fastordersearchbar_ctrl.wrapperCounters wrCountersSubStitute = Lwc17_fastordersearchbar_ctrl.setCountersValues(con, stSubstitute.pricebookEntryOfSubstituteOffer, country);
                                        res.subsituteArticle = Lwc17_fastordersearchbar_ctrl.setValuesOnSearchResultSubstitute(stSubstitute.pricebookEntryOfSubstituteOffer, wrCountersSubStitute, false, false, 
                                                                                                    stSubstitute, lowLimitSetting);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    
                    // Get the counters of the offer to be displayed
                    Lwc17_fastordersearchbar_ctrl.wrapperCounters wrCounters = Lwc17_fastordersearchbar_ctrl.setCountersValues(con, pbe, country);
                    // Set the value of the 
                    res = Lwc17_fastordersearchbar_ctrl.setValuesOnSearchResult(res, pbe, wrCounters, isOutOfStock, isUnderLowLimitThreshold, stockStatusOfProduct, lowLimitSetting);

                    l_res.add(res);
                }
            }

            return l_res;
        }

        return null;
    }
}