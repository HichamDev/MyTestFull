public with sharing class lwc75_wishlist_ctrl {
    
    /* WRAPPERS */
    public class Wishlist {
        @AuraEnabled
        public List<ItemWishlist> l_itemWishlist {get;set;}
        @AuraEnabled
        public String idDealer {get;set;}
        @AuraEnabled
        public String contactFirstName {get;set;}
        @AuraEnabled
        public String contactLastName {get;set;}
        @AuraEnabled
        public String contactEmail {get;set;}
        @AuraEnabled
        public String contactMobile {get;set;}
    }
    public class ItemWishlist {
        @AuraEnabled
        public String productId {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String quantity {get;set;}
        @AuraEnabled
        public Decimal price {get;set;}
        @AuraEnabled
        public Boolean isBundle {get;set;}
        @AuraEnabled
        public String bundleText {get;set;}
    }

    @AuraEnabled
    public static List<ItemWishlist> getProductWithBundle(List<ItemWishlist> l_item) {
        
        List<String> l_idPbe = new List<String>();

        for(ItemWishlist item : l_item){
            l_idPbe.add(item.productId);
        }

        Map<String, String> m_pbeRecordTypePerExternalId = new Map<String, String>();

        for(PriceBookEntry pbe : [SELECT Product2.RecordType.DeveloperName, LU_TECH_External_Id__c
                                    FROM PriceBookEntry
                                   WHERE LU_TECH_External_Id__c IN :l_idPbe]){
            m_pbeRecordTypePerExternalId.put(pbe.LU_TECH_External_Id__c, pbe.Product2.RecordType.DeveloperName);
        }

        for(ItemWishlist item : l_item){
            if(m_pbeRecordTypePerExternalId.containsKey(item.productId)){
                item.isBundle = (m_pbeRecordTypePerExternalId.get(item.productId) == 'LU_Bundle' ? true : false);
            }
            else{
                item.isBundle = false;
            }
        }

        return l_item;
    }
}