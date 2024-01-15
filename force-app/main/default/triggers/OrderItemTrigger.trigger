trigger OrderItemTrigger on OrderItem (before insert, before update) {
    List<OrderItem> vListNewOrderItems = trigger.new;

    if(trigger.isBefore) {
        if(trigger.isInsert) {
            AP45_OrderItemHandler.setIdsWithExternalIdInfo(vListNewOrderItems);
            // calculate commission and admin fees
            OrderItemBeforeInsertTriggerHandler.calculateCommissionRate(vListNewOrderItems);
        }

        if(trigger.isUpdate) {
            List<OrderItem> listOrderItemsToCalculate = new List<OrderItem>();
            for(OrderItem oi : Trigger.new){
                if(oi.OrderId != Trigger.oldMap.get(oi.Id).OrderId 
                || oi.PricebookEntryId != Trigger.oldMap.get(oi.Id).PricebookEntryId
                || oi.Quantity != Trigger.oldMap.get(oi.Id).Quantity){
                    listOrderItemsToCalculate.add(oi);
                }
            }
            if(listOrderItemsToCalculate.size() > 0)OrderItemBeforeInsertTriggerHandler.calculateCommissionRate(listOrderItemsToCalculate);
        }
    }
}