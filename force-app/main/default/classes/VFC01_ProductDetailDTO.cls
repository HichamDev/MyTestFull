/*
----------------------------------------------------------------------
-- - Name          : VFC01_ProductDetailDTO 
-- - Author        : NGO
-- - Description   : Object which contain information about ProductDetail
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 07-JUL-2013  NGO    1.0      Initial version   
----------------------------------------------------------------------
**********************************************************************
*/
global with sharing class VFC01_ProductDetailDTO implements Comparable {

    //Id catalog article
    public CTA_CatalogArticle__c CTA {get; set;}
    
    //internal use variable
    
    //index to identify line when item is in basket
    public integer index {get; set;} 
    
    public boolean isModified {get; set;}
    
    public boolean isDeleted {get; set;}
    
    public boolean isCreated {get; set;}
    
    public Id orderline {get; set;}
    
    /////////////////////////////////////
    public Id article {get; set;}

    public string description {get; set;}
    
    public string localName {get; set;}
    
    public string localCode {get; set;}
    
    public string name {get; set;}
    
    public Double price {get; set;}
    
    public Double regularPrice {get; set;}
    
    public Double netPrice {get;set;}
    
    public string quantity {get; set;}
    
    public integer quantityOld {get; set;}
    
    public Double subTotal {get; set;}
    
    public string stockMessage {get; set;}
    
    public string stockStatus {get; set;}
    
    public boolean isOffer {get; set;}
    
    public string errorMsg {get; set;}
    
    public string infoMsg {get; set;}
    
    public integer sumNumberOfArticles {get; set;}
    
    public integer numberOfArticles {get; set;}
    
    public string imageUrl {get; set;}
    
    public String loyaltyPrgUnit1 {get; set;}
    
    public String loyaltyPrgVal1 {get; set;}
    
    public double tax {get; set;}
    
    public boolean activeProduct {get; set;}
    
    //public List<SelectOption> meansOfPayments {get; set;}
    
    public String meansOfPayment{get;set;}
    
    public boolean isLoyalProgram {get;set;}
    
    public boolean isValidTotalAmountBase {get; set;}
    
    public String brandTerritory {get; set;}
    
    public boolean isClosedSet {get; set;}
            
    public List<VFC01_ProductOfferDTO> offers {get; set;}
    
    public AP16_LoyaltyProgram loyaltyProgramDTO {get; set;}
    
    public string CTASubstitution {get; set;}
    
    public boolean hasCTASubstitution {get; set;}

    public static final String TERRITORY_HOME_CARE = 'Home Care'; 
    
    public static final String TERRITORY_FAMILLY_CARE = 'Family Care'; 
    
    public static final String TERRITORY_BEAUTY_CARE = 'Beauty care'; 
    
    
    public VFC01_ProductDetailDTO(){
        
        offers = new List<VFC01_ProductOfferDTO>();
        
        quantity = '1';
        
        isDeleted = false;
        
        isModified = false;
        
        isCreated = false;
        
        sumNumberOfArticles = 0;
    }
    
    public void updateSubTotal(){
        if(price != null)
            subTotal = price * integer.valueOf(quantity);
        else
            subTotal = 0;
    
    }
    
    public String getStockCSS(){
        /* Status available
        Available   
        Temporarily out-of-stock    
        Out-of-stock    
        Limited quantity
        */
        if(stockStatus != null){
            if(stockStatus.equalsIgnoreCase('Available')){
                return '';
            }else if(stockStatus.equalsIgnoreCase('Temporarily out-of-stock')){
                return '';
            }else if(stockStatus.equalsIgnoreCase('Out-of-stock')){
                return 'rupture_stock';
            }else if(stockStatus.equalsIgnoreCase('Limited quantity')){
                return '';
            }else{
                return '';
            }
        }else{
            
            return '';
        }
    }
    

    public boolean getIsInStock(){
        
        return ! getStockCSS().equals('rupture_stock');

    }
    
    public string getNumberOfArticlesOrderable(){
        system.debug('>>>> getNumberOfArticlesOrderable quantity' + this.quantity);
        system.debug('>>>> getNumberOfArticlesOrderable quantity' + this.numberOfArticles);
        return String.valueOf(integer.valueOf(this.quantity.isNumeric() ? (this.quantity!=null ? this.quantity : '0') : '0') * integer.valueOf(this.numberOfArticles!=null ? this.numberOfArticles : 1));    
        
    }
    
    public boolean isValidTotalHomeCare(){
        //Home Care
        return this.brandTerritory != null && this.brandTerritory.equalsIgnoreCase(TERRITORY_HOME_CARE);
    }
    
    public boolean isValidTotalFamilyCare(){
        //Family Care
        return this.brandTerritory != null && this.brandTerritory.equalsIgnoreCase(TERRITORY_FAMILLY_CARE);
    }
        
    public boolean isValidTotalBeautyCare(){
        //Beauty care
        return this.brandTerritory != null && this.brandTerritory.equalsIgnoreCase(TERRITORY_BEAUTY_CARE);
    }
    
    public Double getOldPrice(){
    
        if(regularPrice != null && regularPrice > price){
            
            return regularPrice;
            
        }else{
            
            return null;
        }

    }
    
    public Double getAmountWithTax(){
    
        /*if(this.tax != null){
            
            if(subTotal != null){
                
                return ((this.tax/100)* subTotal) + subTotal; 
                
            }else{
                
                return 0;
            }
            
        }else{
            
            return subTotal;
        }*/
        if(netPrice != null){
            return (netPrice * integer.valueOf(quantity));
        }else{
            return 0;
        }
    }

    public Double getAmountWithOutTax(){
    
        if(price != null){
            return (price * integer.valueOf(quantity));
        }else{
            return 0;
        }
    }
    
    
    public boolean getHasDebit(){
        
        return loyaltyProgramDTO != null && loyaltyProgramDTO.hasDebit();
        
    }
     // Implement the compareTo() method
    global Integer compareTo(Object compareTo) {
        VFC01_ProductDetailDTO compareToProdDet = (VFC01_ProductDetailDTO)compareTo;
        if (index == compareToProdDet.index) return 0;
        if (index > compareToProdDet.index) return -1;
        return 1;        
    }
    
}