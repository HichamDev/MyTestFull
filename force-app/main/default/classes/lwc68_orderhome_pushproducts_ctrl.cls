public without sharing class lwc68_orderhome_pushproducts_ctrl {

    @AuraEnabled
    public static Contact getUserInformation() {
        return (AP1002_Utils_User.getConnectedUserContact());
    }
    
    @AuraEnabled
    public static List<AP1002_LookupSearchResult> getPriceBookEntry(String pbeId){

        List<String> l_pbeId = pbeId.split(';');

        List<AP1002_LookupSearchResult> l_res = new List<AP1002_LookupSearchResult>();

        if(!l_pbeId.isEmpty()){
            List<PriceBookEntry> l_product = [SELECT id, LU_Offer_type__c, Name, UnitPrice, Product2.LU_Number_Of_Articles__c, Product2.RecordType.Name, LU_Counter_Value__c,
                                                     Product2.RecordType.DeveloperName, Product2Id, Product2.LU_Bundle_Type__c, LU_Maximum_Quantity__c,
                                                     PriceBook2Id, LU_Valid_For_Total_Amount_Base__c, LU_TaxRate__c, Product2.LU_TECH_External_Id__c,
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
                            WHERE Id = :u.TECH_MergeContactID__c];

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
                    l_idProduct.add(pB.Product2Id);
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