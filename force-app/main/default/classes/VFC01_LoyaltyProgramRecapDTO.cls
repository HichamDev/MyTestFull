/*
----------------------------------------------------------------------
-- - Name          : VFC01_LoyaltyProgramRecapDTO 
-- - Author        : NGO
-- - Description   : Object DTO to store loyaltyProgram Recap
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
public class VFC01_LoyaltyProgramRecapDTO {

    public String lpName {get; set;} 
    
    public String lpCode {get; set;} 
    
    public Double totalPoint {get; set;}
    
    public Double pointCredited {get; set;} 
    
    public Double pointDebited {get; set;} 
    
    public Double lowerLimit {get; set;} 
    
    public integer quantity {get; set;}
    
    public boolean isDisplay {get;set;}

    public String helpText {get;set;}
    
    public boolean isChanged(){
    
        return pointCredited != 0 || pointDebited !=0;
    
    }

    public VFC01_LoyaltyProgramRecapDTO(){
        
        totalPoint = 0;
        
        pointCredited = 0;
        
        pointDebited = 0;
        
        lowerLimit = 0;
        
        quantity = 0;
        
        isDisplay = false;
        
        //isChanged = false;
        
    }
    
    public Double getPointDebitedDisplay(){
        
        return pointDebited;
    }
    
    public Double getPointCreditedDisplay(){

        return pointCredited;
    }

}