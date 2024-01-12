/*
----------------------------------------------------------------------
-- - Name          : VFC01_ProductOfferDetail 
-- - Author        : NGO
-- - Description   : Object which contain information about ProductOfferDetail
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
public with sharing class VFC01_ProductOfferDetailDTO {
    
    public string name {get; set;}
    
    public string smartCode {get; set;}
    
    public string localCode {get; set;}
    
    public boolean isRequired {get; set;}
    
    public string quantity {get; set;}
    
    public integer minQtyOrderable {get; set;}
    
    public integer maxQtyOrderable {get; set;}
    
    public boolean isClosedSet {get; set;}
    
    public Id article {get; set;}
    
    public Id orderline {get; set;}
    
    public boolean getIsSelected(){
    	
    	return integer.valueOf(quantity) > 0;
    }
    
    
}