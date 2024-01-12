/*
----------------------------------------------------------------------
-- - Name          : VFC01_ProductOffer 
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
public with sharing class VFC01_ProductOfferDTO {

	//bundle or offer	
	public string typeOffer {get; set;}
    
    public List<VFC01_ProductOfferDetailDTO> offerDetails {get; set;}
    
    public string name {get; set;}
    
    public integer total {get; set;}
    
    //public integer numberOfArticle {get; set;}
    
    public integer minQtyOrderable {get; set;}
    
    public integer maxQtyOrderable {get; set;}
    
    public integer actualQtyOrdered {get; set;}
    
    public Id article {get; set;}
     
    public boolean isParent {get; set;}
    
    public VFC01_ProductOfferDTO(string typeOffer){
    	
    	this.typeOffer = typeOffer;
    	
    	this.actualQtyOrdered = 0;
    	
    	isParent = false;
    	
    }
    
    public void addOfferDetails(VFC01_ProductOfferDetailDTO details){
    	
    	if(offerDetails == null){
    		
    		offerDetails = new List<VFC01_ProductOfferDetailDTO>();
    	}
    	
    	offerDetails.add(details);
    	
    	//if(details.isChecked)
    	//	actualQtyOrdered += details.quantity;
    	
    }

}