public class OrderItemBeforeInsertTriggerHandler {
    
    public static void calculateCommissionRate(List<OrderItem> l_orderItem){

        List<Id> l_idOrder = new List<Id>();
        List<Id> l_idPriceBookEntry = new List<Id>();

        for(OrderItem oi : l_orderItem){
            if(oi.OrderId != null) l_idOrder.add(oi.OrderId);
            if(oi.PricebookEntryId != null) l_idPriceBookEntry.add(oi.PricebookEntryId);
        }

        Map<Id, Order> m_order = new Map<Id, Order>([SELECT Id, BillToContact.CommissionRateRange__c, Status, BillToContact.AccountCountryCode__c 
                                                        FROM Order
                                                        WHERE Id IN :l_idOrder]);
        Map<Id, PricebookEntry> m_priceBookEntry = new Map<Id, PricebookEntry>([SELECT Id, LU_Commissionable__c, LU_Admin_Fees__c, LU_Category_Level_Commission__c 
                                                                                FROM PricebookEntry 
                                                                                WHERE Id IN :l_idPriceBookEntry]);

        List<LU_Order_Rule__c> l_orderRule = [SELECT LU_Value__c, LU_Country__c, LU_Text__c, RecordType.DeveloperName, LU_Description__c
                                                FROM LU_Order_Rule__c 
                                                WHERE RecordType.DeveloperName = 'LU_Order_Commission' OR RecordType.DeveloperName = 'LU_Order_Admin_Fees'];

        for (OrderItem oi : l_orderItem) {

            Order orderOfLine = null;

            if (
                ( m_priceBookEntry.get(oi.PricebookEntryId).LU_Commissionable__c || m_priceBookEntry.get(oi.PricebookEntryId).LU_Admin_Fees__c) 
                && !String.IsBlank(m_priceBookEntry.get(oi.PricebookEntryId).LU_Category_Level_Commission__c)
                && m_order.get(oi.OrderId).Status == 'Draft') {

                // Find Order of line
                for (Order ord : m_order.values()) {
                    if (ord.Id == oi.OrderId) {
                        orderOfLine = ord;
                    }
                }

                for (LU_Order_Rule__c oRule : l_orderRule) {

                    if(oRule.LU_Country__c == orderOfLine.BillToContact.AccountCountryCode__c
                        && !String.IsBlank(oRule.LU_Text__c)
                        && (oRule.LU_Text__c == '*' || oRule.LU_Text__c.contains(m_order.get(oi.OrderId).BillToContact.CommissionRateRange__c) )
                        && (oRule.LU_Description__c == '*' || oRule.LU_Description__c.contains(m_priceBookEntry.get(oi.PricebookEntryId).LU_Category_Level_Commission__c)) ) {
 
                            if (oRule.RecordType.DeveloperName == 'LU_Order_Commission') {
                                //oi.LU_Commission_Amount__c = oRule.LU_Value__c * (oi.UnitPrice * oi.Quantity);
                                //oi.LU_Commission_Amount__c = (oi.LU_Tax_Rate__c != 0) ? (oRule.LU_Value__c * (oi.TotalPrice/oi.LU_Tax_Rate__c)) : 0; //SFT-1700
                                if (oi.TotalPrice != null && oi.LU_Tax_Rate__c != null) {
                                
                                    //-- SFT1822 - Add Country condition     
                                    oi.LU_Commission_Amount__c = 0;
                                    if ( orderOfLine.BillToContact.AccountCountryCode__c == 'ITA' ) {
                                        oi.LU_Commission_Amount__c = oRule.LU_Value__c * oi.TotalPrice / (1 + (oi.LU_Tax_Rate__c/100)); //SFT-1700 
                                    } else {
                                        oi.LU_Commission_Amount__c = oRule.LU_Value__c * (oi.UnitPrice * oi.Quantity); // For FRANCE and Others Countries
                                    }
                                    //-- SFT1822 - END    
                                
                                } else oi.LU_Commission_Amount__c = 0;
                            }
                            else if (oRule.RecordType.DeveloperName == 'LU_Order_Admin_Fees') {
                                oi.LU_Admin_Fees_Amount__c = oRule.LU_Value__c * (oi.UnitPrice * oi.Quantity);
                            }
                    }
                }
            }
        }
    }
}