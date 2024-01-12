/*
----------------------------------------------------------------------
-- - Name          : VFC01_ProductBasketDTO 
-- - Author        : NGO
-- - Description   : Object which contain information about ProductBasket
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
public without sharing class VFC01_ProductBasketDTO_France {
  
  public static final String ONLINE_ORDER = 'Online'; 
    
    public static final String OFFLINE_ORDER = 'Offline'; 

    public integer totalArticle {get; set;}
    
    public Double totalPrice {get; set;}
    
    public Double totalPriceForValidBase {get; set;}
    
    public Double totalPriceByBrandHomeCare {get; set;}
    
    public Double totalPriceByBrandFamilyCare {get; set;}
    
    public Double totalPriceByBrandBeautyCare {get; set;}

    public Double totalPriceByBrandFlormar {get; set;}
    
    public Double totalPriceByBrandOthers {get; set;}
    
    public Double totalPricePersonalUse {get; set;}
    
    public Double totalPriceGift {get; set;}

    public Double totalPriceProductsToSale {get; set;}

    public Double totalPriceProfessionalUse {get; set;}        
    
    public Double transportFees {get; set;}        
    public String transportDescription {get; set;}        
    
    public integer numberOfArticles {get; set;}

    public string errMsg {get; set;}
    
    public string infoMsg {get; set;}
    
    public boolean isEmpty {get; set;}
    
    public boolean isOnlineOrder {get; set;}
    
    private string validateInactive='';
    
    public VFC01_ProductBasketDTO_France(){
        
        this.isEmpty = true;
        
        this.totalArticle = 0;
        
        this.totalPrice = 0;
        
        this.totalPriceForValidBase = 0;
        
        this.totalPriceByBrandHomeCare = 0;
        
        this.totalPriceByBrandFamilyCare = 0;
        
        this.totalPriceByBrandBeautyCare = 0;

        this.totalPriceByBrandFlormar = 0;
        
        this.totalPriceByBrandOthers = 0;

        this.totalPricePersonalUse = 0;

        this.totalPriceGift = 0;

        this.totalPriceProductsToSale = 0;

        this.totalPriceProfessionalUse = 0;
        
        this.transportFees = 0;
        this.transportDescription = null;
        
        this.isOnlineOrder = false;
        
    }
    
    public List<VFC01_ProductDetailDTO_France> basketDetails {get; set;}
    
    public void addBasketDetail(VFC01_ProductDetailDTO_France basket){
        
        if(basketDetails == null){
            
            basketDetails = new List<VFC01_ProductDetailDTO_France>();
        }
        
        //default quantity is 1
        basket.updateSubTotal();
        
        basketDetails.add(basket);
        
        setIndexToBasket(basket);
        
        isEmpty = false;
        
        totalArticle ++;
        
        if(basket.subTotal != null ){
        
            updateEachSubTotalPrice(basket);    
        }
        
        // Sort using the custom compareTo() method
        basketDetails.sort();
    }
    
    public void deleteBasketDetail(integer index){

        integer listIndex = -1;
        integer newIndex = -1;
        boolean found = false;

        for(integer i = basketDetails.size()-1; i > -1; i--){
            
            VFC01_ProductDetailDTO_France detail = basketDetails.get(i);

            if(found==true){
                basketDetails.get(i).index=newIndex;
                newIndex++;
            }

            if(detail.index == index && !found){
                found=true;
                newIndex= index;
                listIndex = i;
            }
        }

        
        basketDetails.remove(listIndex);

        // Sort using the custom compareTo() method
        basketDetails.sort();

    }
    
    public VFC01_ProductDetailDTO_France getProductDetailByIndex(integer index){
        
        VFC01_ProductDetailDTO_France result = new VFC01_ProductDetailDTO_France();
        
        for(VFC01_ProductDetailDTO_France basketDetail : basketDetails){
            
            if(basketDetail.index == index){
                
                result = basketDetail;
            }
        }
        return result;
    }
    
    public void preDeleteBasketDetail(integer index){
        
        for(VFC01_ProductDetailDTO_France detail : basketDetails){
            
            if(detail.index == index){
                
                detail.isDeleted = true;
            }   
        }
    }
    
    
    private void setIndexToBasket(VFC01_ProductDetailDTO_France basket){
        
        basket.index = basketDetails.size();
        
    }
    
    public void updateTotalArticle(){
        
        totalArticle = 0;
        
        for(VFC01_ProductDetailDTO_France detail : basketDetails){
            
            if(!detail.isDeleted){
                totalArticle += integer.valueOf(detail.quantity);
            }
        }
    
    }
    
    
    public boolean validateStock(){
        
        boolean result = true ;
        
        for(VFC01_ProductDetailDTO_France detail : basketDetails){
            
            if(!detail.getIsInStock() && !detail.isDeleted){
                result = false;
            }
        }
        
        return result;
    }
    

    public boolean validateCatalogArticle(){
        
        boolean result = true ;
        validateInactive=':<br/>';
        for(VFC01_ProductDetailDTO_France detail : basketDetails){
            
            if((detail.CTA.Active__c == false || detail.CTA.TECH_CatalogArticleDateInRange__c=='false') && !detail.isDeleted){
                result = false;
                validateInactive=validateInactive+' * '+detail.CTA.Article__r.LocalCode__c+' - '+detail.CTA.Article__r.LocalName__c+'<br/>';
            }
        }
        
        return result;
    }
    
     public boolean validateMaxOrderableQuantity(){
        integer maxQtyCounter=0;
        boolean result = true ;
        validateInactive=':<br/>';
        for(VFC01_ProductDetailDTO_France detailList : basketDetails){
          if(detailList.CTA.MaximumQuantity__c!=null  && !detailList.isDeleted){ 
            maxQtyCounter=0;
            for(VFC01_ProductDetailDTO_France detail : basketDetails){
              if(detailList.CTA.Id==detail.CTA.Id && !detail.isDeleted){
                maxQtyCounter=maxQtyCounter+integer.valueOf(detail.quantity);
                }
            }
            if(maxQtyCounter > detailList.CTA.MaximumQuantity__c){
                  result = false;
                  if(validateInactive.indexOf(detailList.CTA.Article__r.LocalCode__c+' - '+detailList.CTA.Article__r.LocalName__c)==-1){
                    validateInactive=validateInactive+' * '+detailList.CTA.Article__r.LocalCode__c+' - '+detailList.CTA.Article__r.LocalName__c+'.'+system.label.ORD00172+(integer)detailList.CTA.MaximumQuantity__c+'.<br/>';
                  }
              }
          }
        }
        
        return result;
    }
    public boolean validateCatalog(){
        
        boolean result = true ;
        //validateInactive=':<br/>';
        for(VFC01_ProductDetailDTO_France detail : basketDetails){
            
            if((detail.CTA.Catalog__r.Active__c == false || !(detail.CTA.Catalog__r.StartDate__c<=DateTime.now() && detail.CTA.Catalog__r.EndDate__c>=DateTime.now())) && !detail.isDeleted){
                result = false;
                //validateInactive=validateInactive+' * '+detail.CTA.Catalog__r.Name+'<br/>';
            }
        }
        
        return result;
    }
    public boolean validateArticle(){
        
        boolean result = true ;
        validateInactive=':<br/>';
        for(VFC01_ProductDetailDTO_France detail : basketDetails){
            system.debug('>>>>>>validateArticle detail.activeProduct:'+detail.activeProduct);
            if(detail.activeProduct == false && !detail.isDeleted){
                result = false;
                validateInactive=validateInactive+' * '+detail.localCode+' - '+detail.localName+'<br/>';
            }
        }
        
        return result;
    }
     public boolean validateCatalogContact(Contact theDealer){
        boolean result = true ;
        Set<id> catalogIds = new Set<id>();
        for(VFC01_ProductDetailDTO_France detail : basketDetails){
          if(!detail.isDeleted){
              catalogIds.add(detail.CTA.Catalog__c);
              system.debug('>>>>>>detail.CTA.Catalog__c:'+detail.CTA.Catalog__c);
          }
        }

        system.debug('>>>>>>catalogIds:'+catalogIds);
        system.debug('>>>>>>catalogIds size:'+catalogIds.size());
        List<CAC_CatalogContact__c> catalogContacts = new list<CAC_CatalogContact__c>();
        catalogContacts = [SELECT Active__c,TECH_CatalogDateInRange__c
                            from CAC_CatalogContact__c 
                            where Catalog__c in :catalogIds and Dealer__c = :theDealer.Id];
        if(catalogContacts.size()>0){
          for(CAC_CatalogContact__c catCon : catalogContacts){
              if(!catCon.Active__c ){
                  result = false;
              }
          }
        }
        else{
          result=false;
        }
        system.debug('>>>>>>catalogContacts size:'+catalogContacts.size());
        if(result && catalogContacts.size()!=catalogIds.size()){
          result=false;
        }
        return result;
    }
    public List<String> getProductOutOfStock(){
        
       List<String> listProductRef = new List<string>();
        
        for(VFC01_ProductDetailDTO_France detail : basketDetails){
            
            if(!detail.getIsInStock() && !detail.isDeleted){
                listProductRef.add(detail.localCode+' - '+detail.localName);
            }
        }
        
        return listProductRef;
    }
    public string getValidateInactive(){
        
       return validateInactive;
    }  
    public void updateTotalPrice(){
        
        this.totalPrice = 0;
        
        this.totalPriceForValidBase = 0;
        
        this.totalPriceByBrandHomeCare = 0;
        
        this.totalPriceByBrandFamilyCare = 0;
        
        this.totalPriceByBrandBeautyCare = 0;

        this.totalPriceByBrandFlormar = 0;
        
        this.totalPriceByBrandOthers = 0;

        this.totalPricePersonalUse = 0;

        this.totalPriceGift = 0;

        this.totalPriceProductsToSale = 0;

        this.totalPriceProfessionalUse = 0;
        
        for(VFC01_ProductDetailDTO_France detail : basketDetails){
            
            if(!detail.isDeleted && detail.subTotal != null ){
        
                updateEachSubTotalPrice(detail);
            }           
        }      
    }
    
    private void updateEachSubTotalPrice(VFC01_ProductDetailDTO_France detail){
        
        totalPrice += detail.subTotal;

        if(detail.isValidTotalAmountBase){
            this.totalPriceForValidBase += detail.subTotal;
        }

        if(detail.isProduct()){
            if ((detail.sale != null && !detail.sale && !detail.professionalUse) //detail.CTA != null && detail.CTA.Catalog__r.CatalogueType__c != 'Professional Use')
                //|| (detail.sale == null && detail.isDiscountable())
                )
                this.totalPricePersonalUse += detail.subTotal;
            else if (detail.sale != null && detail.sale && !detail.professionalUse)//detail.CTA != null && detail.CTA.Catalog__r.CatalogueType__c != 'Professional Use')
                this.totalPriceProductsToSale += detail.subTotal;
            else if (!detail.isCommissionable() && detail.professionalUse)//detail.CTA != null && detail.CTA.Catalog__r.CatalogueType__c == 'Professional Use')
                this.totalPriceProfessionalUse += detail.subTotal;
        } else {
            this.totalPriceGift += detail.subTotal;
        }
            
        if(detail.isValidTotalHomeCare()){
            
            this.totalPriceByBrandHomeCare += detail.subTotal;
            
        }else if(detail.isValidTotalFamilyCare()){
            
            this.totalPriceByBrandFamilyCare += detail.subTotal;
            
        }else if(detail.isValidTotalBeautyCare()){
            
            this.totalPriceByBrandBeautyCare += detail.subTotal;
            
        }
        else if(detail.isValidTotalFlormar()){
            this.totalPriceByBrandFlormar += detail.subTotal;
            
        }else{
            
            this.totalPriceByBrandOthers += detail.subTotal;
        }
        
    }

    public void updateTransportFees(Double fees, String description) {

        this.transportFees = fees;
        this.transportDescription = description;
        this.totalPrice += this.transportFees;
    }
    
    public void emptyBasket(){
      
      basketDetails = new List<VFC01_ProductDetailDTO_France>();
      
      updateTotalPrice();
      updateTotalArticle();
    }
    
    public boolean validateOrderlineQtyOnlineOrder(){
      return(totalArticle<100);
    }
    
}