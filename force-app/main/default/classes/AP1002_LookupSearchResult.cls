/**
* Class used to serialize a single Lookup search result item
* The Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning
*/
public class AP1002_LookupSearchResult {

    public class Counter {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Decimal value {get;set;}
        @AuraEnabled
        public String unit {get;set;}
    }
    


    @AuraEnabled
    public Id id {get;set;}
    @AuraEnabled
    public String sObjectType {get;set;}
    @AuraEnabled
    public String icon {get;set;}
    @AuraEnabled
    public String title {get;set;}
    @AuraEnabled
    public String subtitle {get;set;}
    @AuraEnabled
    public String description {get;set;}
    @AuraEnabled
    public Integer quantity {get;set;}
    @AuraEnabled
    public Integer quantityDisplayed {get;set;}
    @AuraEnabled
    public Decimal unitPrice {get;set;}
    @AuraEnabled
    public Decimal priceHT {get;set;}
    @AuraEnabled
    public Decimal taxRate {get;set;}
    @AuraEnabled
    public Decimal priceTTC {get;set;}
    @AuraEnabled
    public Boolean isInBundle {get;set;}
    @AuraEnabled
    public Boolean isBundleClosed {get;set;}
    @AuraEnabled
    public Id idBundle {get;set;}
    @AuraEnabled
    public Boolean displayInPreBasketList {get;set;}
    @AuraEnabled
    public Boolean isReadOnly {get;set;}
    @AuraEnabled
    public Decimal maxQuantity {get;set;}
    @AuraEnabled
    public Decimal minQuantity {get;set;}
    @AuraEnabled
    public Decimal numberOfArticle {get;set;}
    @AuraEnabled
    public Id priceBook {get;set;}
    @AuraEnabled
    public Id productId {get;set;}
    @AuraEnabled
    public Boolean validForTotalMountBase {get;set;}
    @AuraEnabled
    public String counters {get;set;}
    @AuraEnabled
    public List<Counter> l_counters {get;set;}
    @AuraEnabled
    public Decimal stockAvailable {get;set;}
    @AuraEnabled
    public String stockStatus {get;set;}
    @AuraEnabled
    public String stockCSSClass {get;set;}
    @AuraEnabled
    public String stockBasketCSSClass {get;set;}
    @AuraEnabled
    public String stockMessage {get;set;}
    @AuraEnabled
    public String stockSubstitutionMessage {get;set;}
    @AuraEnabled
    public Boolean isSubstituteArtile {get;set;}
    @AuraEnabled
    public Substitute subsituteArticle {get;set;}
    @AuraEnabled
    public String brandTerritory {get;set;}
    @AuraEnabled
    public String brand {get;set;}
    @AuraEnabled
    public String discountType {get;set;}
    @AuraEnabled
    public Decimal dealerPrice {get;set;}
    @AuraEnabled
    public Boolean priceStrikout {get;set;}
    @AuraEnabled
    public Boolean pricePersonnalUse {get;set;}
    @AuraEnabled
    public Decimal priceNotDiscounted {get;set;}
    @AuraEnabled
    public Boolean isSelectable {get;set;}
    @AuraEnabled
    public String articleOfTheLine {get;set;}
    @AuraEnabled
    public String imageUrl {get;set;}
    @AuraEnabled
    public String offerType {get;set;}
    @AuraEnabled
    public String counterValuePricebookEntry {get;set;}

    public class Substitute {
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public String sObjectType {get;set;}
        @AuraEnabled
        public String icon {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String subtitle {get;set;}
        @AuraEnabled
        public Integer quantity {get;set;}
        @AuraEnabled
        public Decimal unitPrice {get;set;}
        @AuraEnabled
        public Decimal priceHT {get;set;}
        @AuraEnabled
        public Decimal taxRate {get;set;}
        @AuraEnabled
        public Decimal priceTTC {get;set;}
        @AuraEnabled
        public Boolean isInBundle {get;set;}
        @AuraEnabled
        public Boolean isBundleClosed {get;set;}
        @AuraEnabled
        public Id idBundle {get;set;}
        @AuraEnabled
        public Boolean isBundleValidated {get;set;}
        @AuraEnabled
        public Boolean displayInPreBasketList {get;set;}
        @AuraEnabled
        public Boolean isReadOnly {get;set;}
        @AuraEnabled
        public Decimal maxQuantity {get;set;}
        @AuraEnabled
        public Decimal minQuantity {get;set;}
        @AuraEnabled
        public Decimal numberOfArticle {get;set;}
        @AuraEnabled
        public Id priceBook {get;set;}
        @AuraEnabled
        public Id productId {get;set;}
        @AuraEnabled
        public Boolean validForTotalMountBase {get;set;}
        @AuraEnabled
        public String counters {get;set;}
        @AuraEnabled
        public List<Counter> l_counters {get;set;}
        @AuraEnabled
        public Decimal stockAvailable {get;set;}
        @AuraEnabled
        public String stockStatus {get;set;}
        @AuraEnabled
        public String stockCSSClass {get;set;}
        @AuraEnabled
        public String stockBasketCSSClass {get;set;}
        @AuraEnabled
        public String stockMessage {get;set;}
        @AuraEnabled
        public String stockSubstitutionMessage {get;set;}
        @AuraEnabled
        public String articleOfTheLine {get;set;}
        @AuraEnabled
        public String counterValuePricebookEntry {get;set;}

        @AuraEnabled
        public String name {get;set;}
    }


    public AP1002_LookupSearchResult() {}
    
    public AP1002_LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
    }
/*
    @AuraEnabled
    public Id getId() {
        return id;
    }

    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }

    @AuraEnabled
    public String getIcon() {
        return icon;
    }

    @AuraEnabled
    public String getTitle() {
        return title;
    }

    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }*/
}