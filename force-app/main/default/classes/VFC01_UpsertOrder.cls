public class VFC01_UpsertOrder{
    
/*//  WS01_UpsertOrder 
----------------------------------------------------------------------
-- - Name          : VFC01_UpsertOrder
-- - Author        : ASE 
-- - Description   : Web Service that replaces the order intially created in Salesforce 
                     by the updated order obtained in response..
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 12-NOV-2012  ASE    1.0      Intitial version
----------------------------------------------------------------------
**********************************************************************
*/

    public VFC01_UpsertOrder(ApexPages.StandardController controller)
    {
        
    }
            
    /*****************************************************************/
    /*********************** UpsertOrder  ****************************/
    /*****************************************************************/
    public static void UpsertOrder(Id orderID){
        system.debug('## Class VFC01_UpsertOrder - START UpsertOrder <<<<<'+UserInfo.getUserName());
        ORD_Order__c order1, newOrder;
        ibiz.Orders_element response;
        list<ibiz.OrderLine> orderLineList = new list<ibiz.OrderLine>();
        ibiz.Orders_element wsOrders;
        string message;  

        system.debug('>>>>>>>>>>>>>>>>>Order ID: '  +orderID);
        
        order1 = [select    Catalog__c ,
                            ClosingDate__c ,
                            TECH_ExternalId__c ,
                            CommCycleEndDate__c  ,
                            CommCycleStartDate__c  ,
                            CommCycle__c  ,
                            Commission__c  ,
                            CurrencyIsoCode  ,
                            Dealer__c  ,
                            DeductedFromLoyaltyPrg1__c  ,
                            DeductedFromLoyaltyPrg2__c  ,
                            DeductedFromLoyaltyPrg3__c  ,
                            DeliveryCity__c  ,
                            DeliveryCountry__c  ,
                            DeliveryProvince__c  ,
                            DeliveryState__c  ,
                            DeliveryStreet__c  ,
                            DeliveryZipCode__c  ,
                            Description__c  ,
                            DistributionCenter__c  ,
                            InvoicingCity__c  ,
                            InvoicingCountry__c  ,
                            InvoicingProvince__c  ,
                            InvoicingState__c  ,
                            InvoicingStreet__c  ,
                            InvoicingZipCode__c  ,
                            LocalAttribute10__c  ,
                            LocalAttribute1__c  ,
                            LocalAttribute2__c  ,
                            LocalAttribute3__c  ,
                            LocalAttribute4__c  ,
                            LocalAttribute5__c  ,
                            LocalAttribute6__c  ,
                            LocalAttribute7__c  ,
                            LocalAttribute8__c  ,
                            LocalAttribute9__c  ,
                            NeedByDate__c  ,
                            OrderDate__c  ,
                            OrderNumber__c  ,
                            ShipmentFollowUp__c  ,
                            ShippingRef__c  ,
                            Status__c  ,
                            //Taxes__c  ,
                            //TotalAmountToPay__c  ,
                            Transporter__c  ,
                            TransportFees__c,
                            TECH_WS01_Status__c,
                            TECH_WS01_Message__c,
                            (Select Amount__c,
                                    AmountWihtoutTax__c,
                                    ArticleDescription__c,
                                    ArticleInternationalCode__c,
                                    ArticleLocalCode__c,
                                    ArticleLocalName__c,
                                    ArticleName__c,
                                    Comments__c,
                                    Commission__c,
                                    CurrencyIsoCode,
                                    InvoicedQuantity__c,
                                    OrderLineOrigin__c,
                                    PublicPrice__c,
                                    Qty__c,
                                    RegularPrice__c,
                                    TECH_ExternalId__c
                               From OrderLines__r) 
                          From ORD_Order__c 
                         Where id= : orderID limit 1]; 
             
        system.debug('>>>>>>>>>>>order1: '+order1); 
        system.debug('>>>>>>>>>>>OrderLines: '+order1.OrderLines__r); 
        
        
        //create new instance of global class Order from class Ibiz
        ibiz.Order wsOrder1= new ibiz.Order(); 
        wsOrder1.Catalog_xc  =order1.Catalog__c ;
        wsOrder1.ClosingDate_xc =order1.ClosingDate__c ;
        wsOrder1.CommCycle_xc =order1.CommCycle__c  ;
        wsOrder1.CommCycleEndDate_xc =order1.CommCycleEndDate__c  ;
        wsOrder1.CommCycleStartDate_xc =order1.CommCycleStartDate__c  ;
        wsOrder1.Commission_xc =order1.Commission__c  ;
        wsOrder1.CurrencyIsoCode =order1.CurrencyIsoCode  ;
        wsOrder1.Dealer_xc =order1.Dealer__c  ;
        wsOrder1.DeductedFromLoyaltyPrg1_xc =order1.DeductedFromLoyaltyPrg1__c  ;
        wsOrder1.DeductedFromLoyaltyPrg2_xc =order1.DeductedFromLoyaltyPrg2__c  ;
        wsOrder1.DeductedFromLoyaltyPrg3_xc =order1.DeductedFromLoyaltyPrg3__c  ;
        wsOrder1.DeliveryCity_xc =order1.DeliveryCity__c  ;
        wsOrder1.DeliveryCountry_xc =order1.DeliveryCountry__c  ;
        wsOrder1.DeliveryProvince_xc =order1.DeliveryProvince__c  ;
        wsOrder1.DeliveryState_xc =order1.DeliveryState__c  ;
        wsOrder1.DeliveryStreet_xc =order1.DeliveryStreet__c  ;
        wsOrder1.DeliveryZipCode_xc =order1.DeliveryZipCode__c  ;
        wsOrder1.Description_xc =order1.Description__c  ;
        wsOrder1.DistributionCenter_xc =order1.DistributionCenter__c  ;
        wsOrder1.InvoicingCity_xc =order1.InvoicingCity__c  ;
        wsOrder1.InvoicingCountry_xc  =order1.InvoicingCountry__c  ;
        wsOrder1.InvoicingProvince_xc =order1.InvoicingProvince__c  ;
        wsOrder1.InvoicingState_xc =order1.InvoicingState__c  ;
        wsOrder1.InvoicingStreet_xc =order1.InvoicingStreet__c  ;
        wsOrder1.InvoicingZipCode_xc =order1.InvoicingZipCode__c  ;
        wsOrder1.LocalAttribute10_xc =order1.LocalAttribute10__c  ;
        wsOrder1.LocalAttribute1_xc =order1.LocalAttribute1__c  ;
        wsOrder1.LocalAttribute2_xc =order1.LocalAttribute2__c  ;
        wsOrder1.LocalAttribute3_xc =order1.LocalAttribute3__c  ;
        wsOrder1.LocalAttribute4_xc =order1.LocalAttribute4__c  ;
        wsOrder1.LocalAttribute5_xc =order1.LocalAttribute5__c  ;
        wsOrder1.LocalAttribute6_xc =order1.LocalAttribute6__c  ;
        wsOrder1.LocalAttribute7_xc =order1.LocalAttribute7__c  ;
        wsOrder1.LocalAttribute8_xc =order1.LocalAttribute8__c  ;
        wsOrder1.LocalAttribute9_xc =order1.LocalAttribute9__c  ;
        wsOrder1.NeedByDate_xc =order1.NeedByDate__c  ;
        wsOrder1.OrderDate_xc =order1.OrderDate__c  ;
        wsOrder1.OrderNumber_xc =order1.OrderNumber__c  ;
        wsOrder1.ShipmentFollowUp_xc =order1.ShipmentFollowUp__c  ;
        wsOrder1.ShippingRef_xc =order1.ShippingRef__c  ;
        wsOrder1.Status_xc =order1.Status__c  ;
        //wsOrder1.Taxes_xc =order1.Taxes__c  ;
        wsOrder1.TECH_ExternalId_xc  =order1.TECH_ExternalId__c ;
        //wsOrder1.TotalAmountToPay_xc =order1.TotalAmountToPay__c  ;
        wsOrder1.Transporter_xc =order1.Transporter__c  ;
        wsOrder1.TransportFees_xc =order1.TransportFees__c  ;
        wsOrder1.OrderLines= orderLineList;
            
        system.debug('>>>>>>>>>>>>>wsOrder1: '+wsOrder1);
        system.debug('>>>>>>>>>>>>>order1.OrderLines__r.size(): '+order1.OrderLines__r.size());
        
        if(order1.OrderLines__r.size() > 0) {
            ibiz.OrderLine wsOrderLine = new ibiz.OrderLine();
            //create new instance of global class OrderLines from class Ibiz
            for(ORL_OrderLine__c orderLine : order1.OrderLines__r){                   
                wsOrderLine.Amount_xc =orderLine.Amount__c;
                wsOrderLine.AmountWihtoutTax_xc =orderLine.AmountWihtoutTax__c;
                wsOrderLine.ArticleDescription_xc =orderLine.ArticleDescription__c;
                wsOrderLine.ArticleInternationalCode_xc =orderLine.ArticleInternationalCode__c;
                wsOrderLine.ArticleLocalCode_xc =orderLine.ArticleLocalCode__c;
                wsOrderLine.ArticleLocalName_xc =orderLine.ArticleLocalName__c;
                wsOrderLine.ArticleName_xc =orderLine.ArticleName__c;
                wsOrderLine.Comments_xc =orderLine.Comments__c;
                wsOrderLine.Commission_xc =orderLine.Commission__c;
                wsOrderLine.CurrencyIsoCode =orderLine.CurrencyIsoCode;
                wsOrderLine.InvoicedQuantity_xc =orderLine.InvoicedQuantity__c;
                wsOrderLine.OrderLineOrigin_xc =orderLine.OrderLineOrigin__c;
                wsOrderLine.PublicPrice_xc =orderLine.PublicPrice__c;
                wsOrderLine.Qty_xc =orderLine.Qty__c;
                wsOrderLine.RegularPrice_xc =orderLine.RegularPrice__c;
                wsOrderLine.TECH_ExternalId_xc =orderLine.TECH_ExternalId__c;
                orderLineList.add(wsOrderLine);
            }
        }
        system.debug('>>>>>>>>>>>>>orderLineList: '+orderLineList);
        system.debug('>>>>>>>>>>>>>wsOrder1: '+wsOrder1);
        
        ibiz.IbizWsdl yy = new ibiz.IbizWsdl();
            
        ibiz.Header header1= new ibiz.Header();
            header1.Country = 'test';
            header1.MessageName = 'test';
            header1.SourceSystem = 'test';
        
        try{
            system.debug('>>>>>>>>>>>>wsOrder to call WS: '+wsOrder1);
            //call Webservice UpsertOrder
            if(!test.isRunningTest()){
                wsOrders = yy.UpsertOrder(header1,wsOrder1); 
            }
            
            else{
                ibiz.Orders_element OrdersElement= new ibiz.Orders_element();
                OrdersElement.Header = header1;
                OrdersElement.Orders = wsOrder1;
                wsOrders = OrdersElement; 
                }
            
            system.debug('>>>>>>>>>>>>wsOrders: '+wsOrders);
            /*convert response from Orders_element type to ORD_Order__c type and update received order and orderlines*/
           
             newOrder = new ORD_Order__c(Catalog__c =wsOrders.Orders.Catalog_xc,
                                                    ClosingDate__c =wsOrders.Orders.ClosingDate_xc,
                                                    TECH_ExternalId__c =wsOrders.Orders.TECH_ExternalId_xc,
                                                    CommCycleEndDate__c  =wsOrders.Orders.CommCycleEndDate_xc ,
                                                    CommCycleStartDate__c  =wsOrders.Orders.CommCycleStartDate_xc ,
                                                    CommCycle__c  =wsOrders.Orders.CommCycle_xc ,
                                                    Commission__c  =wsOrders.Orders.Commission_xc ,
                                                    CurrencyIsoCode  =wsOrders.Orders.CurrencyIsoCode ,
                                                    Dealer__c  =wsOrders.Orders.Dealer_xc ,
                                                    DeductedFromLoyaltyPrg1__c  =wsOrders.Orders.DeductedFromLoyaltyPrg1_xc ,
                                                    DeductedFromLoyaltyPrg2__c  =wsOrders.Orders.DeductedFromLoyaltyPrg2_xc ,
                                                    DeductedFromLoyaltyPrg3__c  =wsOrders.Orders.DeductedFromLoyaltyPrg3_xc ,
                                                    DeliveryCity__c  =wsOrders.Orders.DeliveryCity_xc ,
                                                    DeliveryCountry__c  =wsOrders.Orders.DeliveryCountry_xc ,
                                                    DeliveryProvince__c  =wsOrders.Orders.DeliveryProvince_xc ,
                                                    DeliveryState__c  =wsOrders.Orders.DeliveryState_xc ,
                                                    DeliveryStreet__c  =wsOrders.Orders.DeliveryStreet_xc ,
                                                    DeliveryZipCode__c  =wsOrders.Orders.DeliveryZipCode_xc ,
                                                    Description__c  =wsOrders.Orders.Description_xc ,
                                                    DistributionCenter__c  =wsOrders.Orders.DistributionCenter_xc ,
                                                    InvoicingCity__c  =wsOrders.Orders.InvoicingCity_xc ,
                                                    InvoicingCountry__c  =wsOrders.Orders.InvoicingCountry_xc ,
                                                    InvoicingProvince__c  =wsOrders.Orders.InvoicingProvince_xc ,
                                                    InvoicingState__c  =wsOrders.Orders.InvoicingState_xc ,
                                                    InvoicingStreet__c  =wsOrders.Orders.InvoicingStreet_xc ,
                                                    InvoicingZipCode__c  =wsOrders.Orders.InvoicingZipCode_xc ,
                                                    LocalAttribute10__c  =wsOrders.Orders.LocalAttribute10_xc ,
                                                    LocalAttribute1__c  =wsOrders.Orders.LocalAttribute1_xc ,
                                                    LocalAttribute2__c  =wsOrders.Orders.LocalAttribute2_xc ,
                                                    LocalAttribute3__c  =wsOrders.Orders.LocalAttribute3_xc ,
                                                    LocalAttribute4__c  =wsOrders.Orders.LocalAttribute4_xc ,
                                                    LocalAttribute5__c  =wsOrders.Orders.LocalAttribute5_xc ,
                                                    LocalAttribute6__c  =wsOrders.Orders.LocalAttribute6_xc ,
                                                    LocalAttribute7__c  =wsOrders.Orders.LocalAttribute7_xc ,
                                                    LocalAttribute8__c  =wsOrders.Orders.LocalAttribute8_xc ,
                                                    LocalAttribute9__c  =wsOrders.Orders.LocalAttribute9_xc ,
                                                    NeedByDate__c  =wsOrders.Orders.NeedByDate_xc ,
                                                    OrderDate__c  =wsOrders.Orders.OrderDate_xc ,
                                                    OrderNumber__c  =wsOrders.Orders.OrderNumber_xc ,
                                                    ShipmentFollowUp__c  =wsOrders.Orders.ShipmentFollowUp_xc ,
                                                    ShippingRef__c  =wsOrders.Orders.ShippingRef_xc ,
                                                    Status__c  =wsOrders.Orders.Status_xc ,
                                                    //Taxes__c  =wsOrders.Orders.Taxes_xc ,
                                                    //TotalAmountToPay__c  =wsOrders.Orders.TotalAmountToPay_xc ,
                                                    Transporter__c  =wsOrders.Orders.Transporter_xc ,
                                                    TransportFees__c  =wsOrders.Orders.TransportFees_xc,
                                                    TECH_WS01_Status__c= system.label.ORD00019,
                                                    TECH_WS01_Message__c = system.label.ORD00019,
                                                    TECH_Timestamp__c  = wsOrders.Header.MessageName.substringBetween('[', ']')
                                                    );
            system.debug('>>>>>>>>>>>>>>>>>>>>>> newOrder: '+newOrder); 
            try {
                system.debug('>>>>>>>>>>>>>>>>>>>>>> start of try <<<<<<<<<<<<<<<<< '); 
                upsert newOrder TECH_ExternalId__c;
                
                list<ORL_OrderLine__c> orderLineList1 = new list<ORL_OrderLine__c>(); 
                for(Ibiz.OrderLine wsOrderLines : wsOrders.Orders.OrderLines){
                    system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> wsOrderLines: '+wsOrderLines); 
                    ORL_OrderLine__c orderLine1= new ORL_OrderLine__c(  AmountWihtoutTax__c  = wsOrderLines.AmountWihtoutTax_xc ,
                                                                        Commission__c  = wsOrderLines.Commission_xc ,
                                                                        InvoicedQuantity__c  = wsOrderLines.InvoicedQuantity_xc ,
                                                                        PublicPrice__c  = wsOrderLines.PublicPrice_xc ,
                                                                        Qty__c  = wsOrderLines.Qty_xc ,
                                                                        RegularPrice__c  = wsOrderLines.RegularPrice_xc ,
                                                                        ArticleInternationalCode__c  = wsOrderLines.ArticleInternationalCode_xc ,
                                                                        ArticleLocalCode__c  = wsOrderLines.ArticleLocalCode_xc ,
                                                                        ArticleName__c  = wsOrderLines.ArticleName_xc ,
                                                                        ArticleLocalName__c  = wsOrderLines.ArticleLocalName_xc ,
                                                                        Comments__c  = wsOrderLines.Comments_xc ,
                                                                        CurrencyIsoCode  = wsOrderLines.CurrencyIsoCode ,
                                                                        OrderLineOrigin__c  = wsOrderLines.OrderLineOrigin_xc ,
                                                                        Order__c  = newOrder.Id,
                                                                        TECH_ExternalId__c  = wsOrderLines.TECH_ExternalId_xc 
                                                                    );
                                                        
                    //adds orderline in orderLineList   
                    orderLineList1.add(orderLine1);  
                    system.debug('>>>>>>>>>>>>>>>>>>>>>> orderLine1: '+orderLine1);     
                    system.debug('>>>>>>>>>>>>>>>>>>>>>> end of OrderLIne');            
                }
                if  (orderLineList1.size()> 0){  
                    Schema.SObjectField f = ORL_OrderLine__c.Fields.TECH_ExternalId__c;
                    Database.Upsertresult [] cr = Database.upsert(orderLineList1,f,false);
                } 
            }
            
            catch(system.DmlException e){
                /*Updating message and status of order when upsert is failed*/
                system.debug('>>>>>>>>>>>>>>>>>>>>>> start of catch <<<<<<<<<<<<<<<<< ');
                order1.TECH_WS01_Message__c =  e.getMessage();
                system.debug('>>>>>>>>>>>>message: '+order1.TECH_WS01_Message__c);
                order1.TECH_WS01_Status__c = system.label.ORD00016;
                update order1;
            }
        }
        catch(System.CalloutException s){
            /*Updating message and status of order when WS is not reachable*/
            system.debug('>>>>>>>>>>>>>>>>>>>>>> start of catch when WS is unreachable<<<<<<<<<<<<<<<<< ');
            order1.TECH_WS01_Status__c= system.label.ORD00018;
            order1.TECH_WS01_Message__c =  s.getMessage();
            system.debug('>>>>>>>>>>>>message: '+order1.TECH_WS01_Message__c);
            update order1;
        }
    }
}