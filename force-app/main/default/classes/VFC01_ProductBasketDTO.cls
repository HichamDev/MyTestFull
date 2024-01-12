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
public with sharing class VFC01_ProductBasketDTO {
  
  public static final String ONLINE_ORDER = 'Online'; 
    
    public static final String OFFLINE_ORDER = 'Offline'; 

    public integer totalArticle {get; set;}
    
    public Double totalPrice {get; set;}
    
    public Double totalPriceForValidBase {get; set;}
    
    public Double totalPriceByBrandHomeCare {get; set;}
    
    public Double totalPriceByBrandFamilyCare {get; set;}
    
    public Double totalPriceByBrandBeautyCare {get; set;}
    
    public Double totalPriceByBrandOthers {get; set;}
    
    public integer numberOfArticles {get; set;}

    public string errMsg {get; set;}
    
    public string infoMsg {get; set;}
    
    public boolean isEmpty {get; set;}
    
    public boolean isOnlineOrder {get; set;}
    
    private string validateInactive='';
    
    public VFC01_ProductBasketDTO(){
        
        this.isEmpty = true;
        
        this.totalArticle = 0;
        
        this.totalPrice = 0;
        
        this.totalPriceForValidBase = 0;
        
        this.totalPriceByBrandHomeCare = 0;
        
        this.totalPriceByBrandFamilyCare = 0;
        
        this.totalPriceByBrandBeautyCare = 0;
        
        this.totalPriceByBrandOthers = 0;
        
        this.isOnlineOrder = false;
        
    }
    
    public List<VFC01_ProductDetailDTO> basketDetails {get; set;}
    
    public void addBasketDetail(VFC01_ProductDetailDTO basket){
        
        if(basketDetails == null){
            
            basketDetails = new List<VFC01_ProductDetailDTO>();
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
        system.debug('####deleteBasketDetail start');
        integer listIndex = -1;
        integer newIndex = -1;
        boolean found = false;
        system.debug('####deleteBasketDetail ####deleteBasketDetail >> index>>'+index);

        for(integer i = basketDetails.size()-1; i > -1; i--){
            
            VFC01_ProductDetailDTO detail = basketDetails.get(i);
            system.debug('####deleteBasketDetail >> found>>'+found);
            if(found==true){
                system.debug('####deleteBasketDetail >> newIndex>>'+newIndex);
                basketDetails.get(i).index=newIndex;
                newIndex++;
            }

            if(detail.index == index && !found){
                system.debug('####deleteBasketDetail >> Found>>'+detail.index);
                found=true;
                newIndex= index;
                listIndex = i;
            }
        }

        
        basketDetails.remove(listIndex);

        // Sort using the custom compareTo() method
        basketDetails.sort();
        system.debug('####deleteBasketDetail End');
    }
    
    public VFC01_ProductDetailDTO getProductDetailByIndex(integer index){
        
        VFC01_ProductDetailDTO result = new VFC01_ProductDetailDTO();
        
        for(VFC01_ProductDetailDTO basketDetail : basketDetails){
            
            if(basketDetail.index == index){
                
                result = basketDetail;
            }
        }
        return result;
    }
    
    public void preDeleteBasketDetail(integer index){
        
        for(VFC01_ProductDetailDTO detail : basketDetails){
            
            if(detail.index == index){
                
                detail.isDeleted = true;
            }   
        }
    }
    
    
    private void setIndexToBasket(VFC01_ProductDetailDTO basket){
        
        basket.index = basketDetails.size();
        
    }
    
    public void updateTotalArticle(){
        
        totalArticle = 0;
        
        for(VFC01_ProductDetailDTO detail : basketDetails){
            
            if(!detail.isDeleted){
                totalArticle += integer.valueOf(detail.quantity);
            }
        }
    
    }
    
    
    public boolean validateStock(){
        
        boolean result = true ;
        
        for(VFC01_ProductDetailDTO detail : basketDetails){
            
            if(!detail.getIsInStock() && !detail.isDeleted){
                result = false;
            }
        }
        
        return result;
    }
    

    public boolean validateCatalogArticle(){
        
        boolean result = true ;
        validateInactive=':<br/>';
        for(VFC01_ProductDetailDTO detail : basketDetails){
            
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
        for(VFC01_ProductDetailDTO detailList : basketDetails){
          if(detailList.CTA.MaximumQuantity__c!=null  && !detailList.isDeleted){ 
            maxQtyCounter=0;
            for(VFC01_ProductDetailDTO detail : basketDetails){
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
        for(VFC01_ProductDetailDTO detail : basketDetails){
            
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
        for(VFC01_ProductDetailDTO detail : basketDetails){
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
        for(VFC01_ProductDetailDTO detail : basketDetails){
          if(!detail.isDeleted){
              catalogIds.add(detail.CTA.Catalog__c);
          }
        }
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
        
        for(VFC01_ProductDetailDTO detail : basketDetails){
            
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
        
        this.totalPriceByBrandOthers = 0;
        
        for(VFC01_ProductDetailDTO detail : basketDetails){
            
            if(!detail.isDeleted && detail.subTotal != null ){
        
                updateEachSubTotalPrice(detail);
            }           
        }       
    }
    
    private void updateEachSubTotalPrice(VFC01_ProductDetailDTO detail){
        
        totalPrice += detail.subTotal;
                
        if(detail.isValidTotalAmountBase){
            this.totalPriceForValidBase += detail.subTotal;
        }
            
        if(detail.isValidTotalHomeCare()){
            
            this.totalPriceByBrandHomeCare += detail.subTotal;
            
        }else if(detail.isValidTotalFamilyCare()){
            
            this.totalPriceByBrandFamilyCare += detail.subTotal;
            
        }else if(detail.isValidTotalBeautyCare()){
            
            this.totalPriceByBrandBeautyCare += detail.subTotal;
            
        }else{
            
            this.totalPriceByBrandOthers += detail.subTotal;
        }
        
    }
    
    public void emptyBasket(){
      
      basketDetails = new List<VFC01_ProductDetailDTO>();
      
      updateTotalPrice();
      updateTotalArticle();
    }
    
    public boolean validateOrderlineQtyOnlineOrder(){
      return(totalArticle<100);
    }
    
}