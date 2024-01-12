public with sharing class VFC01_OrderView {
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
    public User u {get;set;}
    public Id orderID {get;set;}
    //order just validated, display message custom label ORD00047
    public String ojv {get;set;}

    public User__c userCustomSettings { get; set; }
        
    /*****************************************************************/
    /******************** Page Constructor ***************************/
    /*****************************************************************/
    public VFC01_OrderView (ApexPages.Standardcontroller controller){
        system.debug('## Class VFC01_OrderView - START VFC01_OrderView <<<<<'+UserInfo.getUserName());
        
        orderID   = ApexPages.currentPage().getParameters().get('Id');
        ojv = ApexPages.currentPage().getParameters().get('ojv');
        system.debug('##### orderID: ' + orderID);

        userCustomSettings = User__c.getInstance();
        
        u = [SELECT Id, Use_New_Oder__c, User_Country__c FROM User WHERE Id =: UserInfo.getUserId()];

        RedirectOrder();
    } 
    
    /*****************************************************************/
    /************************ RedirectOrder **************************/
    /*****************************************************************/
    public PageReference RedirectOrder() {
        system.debug('## Class VFP01_OrderView - START RedirectOrder <<<<<'+UserInfo.getUserName());
        PageReference pageRef;
        
        for (ORD_Order__c o : [Select Id
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
        
        if (String.isBlank(orderStatus)) {

           // pageRef = (userCustomSettings.redirectToNewOrderTunnelIta__c ? Page.VFP01_OrderBasket_Italy : Page.VFP01_OrderBasket);
           pageRef = getOrderTunelVersionForUser(u, userCustomSettings, 'basket');

        } else if (orderStatus == SHW_IBZ_Constants.ORDER_STATUS_DRAFT || orderStatus =='Brouillon'){
            
            //pageRef = (userCustomSettings.redirectToNewOrderTunnelIta__c ? Page.VFP01_OrderBasket_Italy : Page.VFP01_OrderBasket);
            pageRef = getOrderTunelVersionForUser(u, userCustomSettings, 'basket');
            pageRef.getParameters().put('orderId',orderID);
            pageRef.getParameters().put('dealerId',dealerId);
            

        }else {

            //pageRef = (userCustomSettings.redirectToNewOrderTunnelIta__c ? Page.VFP01_OrderRecap_Italy : Page.VFP01_OrderRecap);
            pageRef = getOrderTunelVersionForUser(u, userCustomSettings, 'recap');
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

    public static PageReference getOrderTunelVersionForUser(User u, User__c userCustomSettings, String step) {

        PageReference pageRef = null;
        // FRANCE
        if (u.User_Country__c == 'FRA') {
            system.debug('>> FRA');
            // New version of FRA tunnel
            if (u.Use_New_Oder__c) {
                system.debug('>> new rder tunnel');
                if (step == 'basket') { pageRef = Page.VFP01_OrderBasket_France; }
                if (step == 'recap') { pageRef = Page.VFP01_OrderRecap_France; }
            } else {
                system.debug('>> ancien order tunnel');
                if (step == 'basket') { pageRef = Page.VFP01_OrderBasket; }
                if (step == 'recap') { pageRef = Page.VFP01_OrderRecap; }
            }

        } 
        // Italie
        else if (u.User_Country__c == 'ITA') {

            if (userCustomSettings.redirectToNewOrderTunnelIta__c) {
                if (step == 'basket') { pageRef = Page.VFP01_OrderBasket_Italy; }
                if (step == 'recap') { pageRef = Page.VFP01_OrderRecap_Italy; }
            } else {
                if (step == 'basket') { pageRef = Page.VFP01_OrderBasket; }
                if (step == 'recap') { pageRef = Page.VFP01_OrderRecap; }
            }
        } else {
            if (step == 'basket') { pageRef = Page.VFP01_OrderBasket; }
            if (step == 'recap') { pageRef = Page.VFP01_OrderRecap; }
        }

        return (pageRef);
    }
}