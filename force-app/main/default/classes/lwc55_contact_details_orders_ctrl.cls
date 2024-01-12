public without sharing class lwc55_contact_details_orders_ctrl {
    
    @AuraEnabled
    public static List<ORD_Order__c> getOrders(String idContact){

        return [SELECT Name 
                      ,OrderDate__c 
                      ,toLabel(OrderType__c) 
                      ,toLabel(Status__c)
                      ,TECH_TotalPrice__c
                      ,TotalAmountToPay__c
                      ,LU_Url_Detail_Community__c
                FROM ORD_Order__c
                WHERE Dealer__c = :idContact
                ORDER BY OrderDate__c DESC
                LIMIT 20000];
    }

    @AuraEnabled
    public static String getUserType(String idContact){
        return [SELECT RecordType.DeveloperName FROM Contact WHERE Id = :idContact].RecordType.DeveloperName;
    }
}