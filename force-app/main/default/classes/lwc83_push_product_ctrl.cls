public without sharing class lwc83_push_product_ctrl {

    public class PushedProductWrapper {
        @AuraEnabled
        public String imageUrl {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public Decimal price {get;set;}
        @AuraEnabled
        public String externalId {get;set;}
        //1716
        @AuraEnabled
        public String productUrl {get;set;}
        @AuraEnabled
        public String replacementProduct {get;set;}
        @AuraEnabled
        public String bundleType {get;set;}

        @AuraEnabled
        public String externalIdToSale {get;set;}
        @AuraEnabled
        public String productUrlToSale {get;set;}
    }

    @AuraEnabled
    public static List<PushedProductWrapper> getPushedProducts(String country, String productGroup, String orderId, Boolean isOnOrderBasket) {

        if(country == 'France'){
            country = 'FRA';
        }
        else if(country == 'Italy'){
            country = 'ITA';
        }

        List<PushedProductWrapper> l_ppw = new List<PushedProductWrapper>();

        Map<String, String> m_urlPerExternalId = new Map<String, String>();

        List<LU_Pushed_Product__mdt> l_pp = new List<LU_Pushed_Product__mdt>();

        Contact con = AP1002_Utils_User.getConnectedUserContact();

        List<Order> l_order;

        String pushedProductType;
        if(isOnOrderBasket !=null){
            if(isOnOrderBasket && String.isBlank(orderId)){
                pushedProductType = 'LineUp%';
            }
            else{
                if(isOnOrderBasket && !String.isBlank(orderId)){
                    l_order = [SELECT Id, Type FROM Order WHERE Id = :orderId ];
                }
                else{
                    l_order = [SELECT Id, Type FROM Order 
                                WHERE BillToContactId = :con.Id 
                                AND Status = 'Draft' LIMIT 1];
                }
    
                if(l_order.isEmpty() || l_order.get(0).Type == 'LineUp'){
                    pushedProductType = 'LineUp%';
                }
                else if(l_order.get(0).Type == 'B2C'){
                    pushedProductType = 'B2C%';
                }
                else if(l_order.get(0).Type == 'B2B2C'){
                    pushedProductType = 'B2B2C%';
                }
            }
        }

        if(!Test.isRunningTest()){
            l_pp = [SELECT LU_Display_Order__c, LU_TECH_External_Id__c, LU_Image_Url__c, LU_Replacement_Product__c, LU_Group__c
                    FROM LU_Pushed_Product__mdt
                    WHERE LU_Country__c = :country
                      AND LU_Group__c LIKE :pushedProductType
                    ORDER BY LU_Display_Order__c ASC];
        } else {
            LU_Pushed_Product__mdt vPushProd = new LU_Pushed_Product__mdt(LU_Display_Order__c = 1, 
                                                                            LU_TECH_External_Id__c = 'FRA_Pricebook_1', 
                                                                            LU_Image_Url__c = 'myImage', 
                                                                            LU_Country__c = 'FRA',
                                                                            LU_Replacement_Product__c = 'Twix',
                                                                            LU_Group__c = 'A');
            l_pp.add(vPushProd);
        }

        for(LU_Pushed_Product__mdt pp : l_pp){
            m_urlPerExternalId.put(pp.LU_TECH_External_Id__c, pp.LU_Image_Url__c);
        }

        Map<String, PriceBookEntry> m_pbePerExternalId = new Map<String, PriceBookEntry>();
        
        for(PriceBookEntry pbe : [SELECT Id, LU_TECH_External_Id__c, LU_Dealer_Price__c, 
                                    Product2.LU_Smart_Reference__c, Name, UnitPrice, Product2.LU_Bundle_Type__c
                                    FROM PriceBookEntry WHERE LU_TECH_External_Id__c IN :m_urlPerExternalId.keyset()]){
            m_pbePerExternalId.put(pbe.LU_TECH_External_Id__c, pbe);
        }

        for(LU_Pushed_Product__mdt pp : l_pp){
            if(!String.isBlank(productGroup) && pp.LU_Group__c.right(1) != productGroup){
                continue;
            }
            PushedProductWrapper ppw = new PushedProductWrapper();
            PriceBookEntry vPbe = m_pbePerExternalId.get(pp.LU_TECH_External_Id__c);
            if(vPbe != null) {
                ppw.imageUrl = m_urlPerExternalId.get(pp.LU_TECH_External_Id__c);
                ppw.name = vPbe.Name;
                ppw.externalId = pp.LU_TECH_External_Id__c;
                if(country == 'ITA') {
                    ppw.price = vPbe.LU_Dealer_Price__c;
                    //1716
                    ppw.productUrl = '/ita/s/order-home?push=' + ppw.externalId;
                } else {
                    ppw.price = vPbe.UnitPrice;
                    //1716
                    ppw.productUrl = '/fra/s/order-home?push=' + ppw.externalId;
                }
                ppw.code = vPbe.Product2.LU_Smart_Reference__c;
                ppw.replacementProduct = pp.LU_Replacement_Product__c;
                ppw.bundleType = vPbe.Product2.LU_Bundle_Type__c;
                l_ppw.add(ppw);
            }
        }

        return l_ppw;
    }

    @AuraEnabled
    public static List<PushedProductWrapper> getPushedProductsITA(String productGroup, String contactTitle) {

        List<PushedProductWrapper> l_ppw = new List<PushedProductWrapper>();

        Map<String, String> m_urlPerExternalId = new Map<String, String>();

        List<LU_Pushed_Product__mdt> l_pp = new List<LU_Pushed_Product__mdt>();

        Contact con = AP1002_Utils_User.getConnectedUserContact();

        List<Order> l_order = [SELECT Id, Type FROM Order 
                               WHERE BillToContactId = :con.Id 
                                 AND Status = 'Draft' LIMIT 1];

        if(!Test.isRunningTest()){
            l_pp = [SELECT LU_Display_Order__c, LU_TECH_External_Id__c, LU_Image_Url__c, LU_Replacement_Product__c, LU_Group__c, LU_TECH_External_Id_2__c
                    FROM LU_Pushed_Product__mdt
                    WHERE LU_Country__c = 'ITA'
                    ORDER BY LU_Display_Order__c ASC];
        } else {
            LU_Pushed_Product__mdt vPushProd = new LU_Pushed_Product__mdt(LU_Display_Order__c = 1, 
                                                                            LU_TECH_External_Id__c = 'FRA_Pricebook_1', 
                                                                            LU_Image_Url__c = 'myImage', 
                                                                            LU_Country__c = 'FRA',
                                                                            LU_Replacement_Product__c = 'Twix',
                                                                            LU_Group__c = 'A');
            l_pp.add(vPushProd);
        }

        for(LU_Pushed_Product__mdt pp : l_pp){
            m_urlPerExternalId.put(pp.LU_TECH_External_Id__c, pp.LU_Image_Url__c);
            if(pp.LU_TECH_External_Id_2__c != null){
                m_urlPerExternalId.put(pp.LU_TECH_External_Id_2__c, pp.LU_Image_Url__c);
            }
        }

        Map<String, PriceBookEntry> m_pbePerExternalId = new Map<String, PriceBookEntry>();
        
        for(PriceBookEntry pbe : [SELECT Id, LU_TECH_External_Id__c, LU_Dealer_Price__c, LU_Offer_type__c, Product2Id,
                                    Product2.LU_Smart_Reference__c, Name, UnitPrice, Product2.LU_Bundle_Type__c
                                    FROM PriceBookEntry WHERE LU_TECH_External_Id__c IN :m_urlPerExternalId.keyset()]){
            m_pbePerExternalId.put(pbe.LU_TECH_External_Id__c, pbe);
        }

        for(LU_Pushed_Product__mdt pp : l_pp){
            if(!String.isBlank(productGroup) && pp.LU_Group__c.right(1) != productGroup){
                continue;
            }
            PushedProductWrapper ppw = new PushedProductWrapper();
            PriceBookEntry vPbe = m_pbePerExternalId.get(pp.LU_TECH_External_Id__c);
            PriceBookEntry vPbe2 = m_pbePerExternalId.get(pp.LU_TECH_External_Id_2__c);
            if(vPbe != null) {
                if(contactTitle == 'Smile' || contactTitle == AP1000_Utils.REBATE_JOB_TITLE){
                    if(vPbe.LU_Offer_type__c == 'Personal Use'){
                        ppw.imageUrl = m_urlPerExternalId.get(pp.LU_TECH_External_Id__c);
                        ppw.name = vPbe.Name;
                        ppw.externalId = pp.LU_TECH_External_Id__c;
                        ppw.price = vPbe.LU_Dealer_Price__c;
                        ppw.productUrl = '/ita/s/order-home?push=' + ppw.externalId;
                        ppw.code = vPbe.Product2.LU_Smart_Reference__c;
                        ppw.replacementProduct = pp.LU_Replacement_Product__c;
                        ppw.bundleType = vPbe.Product2.LU_Bundle_Type__c;
                        l_ppw.add(ppw);
                    }
                }
                else{
                    ppw.imageUrl = m_urlPerExternalId.get(pp.LU_TECH_External_Id__c);
                    ppw.name = vPbe.Name;
                    ppw.price = vPbe.LU_Dealer_Price__c;
                    ppw.code = vPbe.Product2.LU_Smart_Reference__c;
                    ppw.bundleType = vPbe.Product2.LU_Bundle_Type__c;
                    ppw.externalId = pp.LU_TECH_External_Id__c;
                    ppw.productUrl = '/ita/s/order-home?push=' + ppw.externalId;
                    ppw.replacementProduct = pp.LU_Replacement_Product__c;
                    if(vPbe2 != null){
                        ppw.externalIdToSale = pp.LU_TECH_External_Id_2__c;
                        ppw.productUrlToSale = '/ita/s/order-home?push=' + ppw.externalIdToSale;
                    }
                    l_ppw.add(ppw);
                }
                
            }
        }

        return l_ppw;
    }

    @AuraEnabled
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    @AuraEnabled
    public static String getCurrentOrderType() {
        Order ord = lwc66_current_order_summary_ctrl.getDraftOrder();
        if(ord == null){
            return  null;
        }
        else{
            for(OrderItem oi : [SELECT PricebookEntry.LU_Offer_type__c FROM OrderItem WHERE OrderId = :ord.Id]){
                return oi.PricebookEntry.LU_Offer_type__c;
            }
        }

        return null;
    }
}