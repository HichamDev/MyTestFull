/******************************************************************************
*   @author Simon Gourreau
*   @date 29/09/2020
*   @description Order trigger
*
*/
trigger OrderTrigger on Order (after insert, before insert, before update, after update) {

    System.debug('## START Trigger OrderTrigger on Order  <<<<<'+UserInfo.getUserName());

    if(trigger.isAfter) {
        if(trigger.isInsert) {
            System.debug('#### Order Trigger is after is insert');
            AP44_OrderHandler.setOrderItemSumPerContact(Trigger.new);
             //JJE - 05/09/2023 - Rebate en after insert car ne se met pas toujours à jour
             Map<Id, Order> m_ordersToSend = new Map<Id, Order>();
             for(Order ord : Trigger.new){
                if(ord.LU_Country_Code__c == 'ITA') m_ordersToSend.put(ord.Id, ord);
            }
            if(m_ordersToSend.size() > 0) AP44_OrderHandler.setRebateDiscountOnPersonalUse(m_ordersToSend);
        }
        else if(trigger.isUpdate) {
            System.debug('#### Order Trigger is after is update');
            AP44_OrderHandler.setOrderNumberWhenValidated(trigger.new, trigger.oldMap);
            AP44_OrderHandler.setOrderItemSumPerContact(trigger.new, trigger.oldMap);

            //JJE - 03/06/2021 - T-1693
            AP44_OrderHandler.setCommercialPeriod(trigger.new, trigger.oldMap);
            
            //JJE - 05/06/2021 - Rebate en after update pour avoir le temps de mettre à jour le rollupsummary
            Map<Id, Order> m_ordersToSend = new Map<Id, Order>();
            for(Order ord : Trigger.new){
                if(ord.LU_Country_Code__c == 'ITA' &&
                    (ord.Total_Amount_Total_Personal_Use__c != Trigger.oldMap.get(ord.Id).Total_Amount_Total_Personal_Use__c ||
                    ord.LU_TECH_AmountForMinimumOrder__c != Trigger.oldMap.get(ord.Id).LU_TECH_AmountForMinimumOrder__c) ) {
                    m_ordersToSend.put(ord.Id, ord);
                }
            }
            if(m_ordersToSend.size() > 0) {
                // AP44_OrderHandler.firstRun = false;
                AP44_OrderHandler.setRebateDiscountOnPersonalUse(m_ordersToSend);
            }
        }
    }
    else if(Trigger.isbefore){
        if(Trigger.isInsert) {
            system.debug('#### Order Trigger is before is insert');
            AP44_OrderHandler.setTechOrderDate(Trigger.new);
            AP44_OrderHandler.setIdsWithExternalIdInfo(Trigger.new);
        }
        else if(Trigger.isUpdate) {
            system.debug('#### Order Trigger is before is update');
            //Suppression du Rebate en before car déjà en after
            // if(AP44_OrderHandler.firstRun) {
            //     AP44_OrderHandler.firstRun = false;
            //     AP44_OrderHandler.setRebateDiscountOnPersonalUse(Trigger.new);
            // }
            AP44_OrderHandler.setTechOrderDate(Trigger.new, Trigger.oldMap);
        }
    }
}