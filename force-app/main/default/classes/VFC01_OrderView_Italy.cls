public with sharing class VFC01_OrderView_Italy {
/*
----------------------------------------------------------------------
-- - Name          : VFC01_OrderView 
-- - Author        : AMU
-- - Description   : Controller for VFP01_OrderView Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 23-NOV-2012  AMU    1.0      Initial version   
----------------------------------------------------------------------
**********************************************************************
*/
    /*****************************************************************/
    /***************** Instantiating Global Variable *****************/
    /*****************************************************************/
    //Global String
    public String orderStatus {get;set;}
    //Global Id
    public Id dealerId {get;set;}
    public Id orderID {get;set;}
    //order just validated, display message custom label ORD00047
    public String ojv {get;set;}
        
    /*****************************************************************/
    /******************** Page Constructor ***************************/
    /*****************************************************************/
    public VFC01_OrderView_Italy (ApexPages.Standardcontroller controller){
        system.debug('## Class VFC01_OrderView - START VFC01_OrderView <<<<<'+UserInfo.getUserName());
        
        orderID   = ApexPages.currentPage().getParameters().get('Id');
        ojv = ApexPages.currentPage().getParameters().get('ojv');
        system.debug('##### orderID: ' + orderID);
        
        RedirectOrder();
    } 
    
    /*****************************************************************/
    /************************ RedirectOrder **************************/
    /*****************************************************************/
    public PageReference RedirectOrder() {
        system.debug('## Class VFP01_OrderView - START RedirectOrder <<<<<'+UserInfo.getUserName());
        PageReference pageRef;
        
        for (ORD_Order__c o:[Select Id
                                    , Status__c
                                    , dealer__c
                                    , TECH_Status_state__c
                               From ORD_Order__c
                              Where id = :orderID
                              limit 1]){
                              
                              //orderStatus = o.TECH_Status_state__c;
                              orderStatus = o.Status__c;
                              dealerId = o.dealer__c;
        }
        
        if (orderStatus == SHW_IBZ_Constants.ORDER_STATUS_DRAFT || orderStatus =='Brouillon'){
            
            pageRef = Page.VFP01_OrderBasket_Italy;
            pageRef.getParameters().put('orderId',orderID);
            pageRef.getParameters().put('dealerId',dealerId);
            

        }else {

            pageRef = Page.VFP01_OrderRecap_Italy;
            pageRef.getParameters().put('orderId',orderID);
            pageRef.getParameters().put('dealerId',dealerId);
            if(!String.isblank(ojv)){
                pageRef.getParameters().put('ojv',ojv);
            }
            
        }
        
        /*
        if (orderStatus == 'Step_2'){
            
            pageRef = Page.VFP01_OrderAddress;
            pageRef.getParameters().put('orderId',orderID);
            pageRef.getParameters().put('dealerId',dealerId);
            

        }else if(orderStatus == 'Step_3'){

            pageRef = Page.VFP01_OrderRecap;
            pageRef.getParameters().put('orderId',orderID);
            pageRef.getParameters().put('dealerId',dealerId);
            
        }else{
            
            pageRef = Page.VFP01_OrderBasket;
            pageRef.getParameters().put('orderId',orderID);
            pageRef.getParameters().put('dealerId',dealerId);
            
        }*/
        system.debug('>>>>>> orderStatus: ' + orderStatus);
        system.debug('>>>>>> pageRef: ' + pageRef);
        return PageRef;
    }
}