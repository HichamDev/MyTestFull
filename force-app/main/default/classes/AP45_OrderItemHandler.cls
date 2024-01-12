/******************************************************************************
*   @author Simon Gourreau
*   @date 05/01/2021
*   @description OrderItem trigger handler
*
*/
public with sharing class AP45_OrderItemHandler {

    /**
     * @description Set the orderitem fields ids with tech external ids when interface user create them
     * @param List<OrderItem>
     *
     */
    public static void setIdsWithExternalIdInfo(List<OrderItem> pListOrderItems) {
        if(SHW_IBZ_Utils.isInterfaceUser()){
            Map<String, String> vExtMap = new Map<String, String>();
            Set<String> vProdExtIdSet = new Set<String>();
            Set<String> vPbeExtIdSet = new Set<String>();
            for(OrderItem vOrderItem : pListOrderItems){
                String vTechChildProdId = vOrderItem.LU_Child_Product_TECH_ID__c;
                String vTechProdId = vOrderItem.Product2Id_TECH_ID__c;
                String vTechPbeId = vOrderItem.PricebookEntryId_TECH_ID__c;
                if(String.isNotBlank(vTechChildProdId)) {
                    vProdExtIdSet.add(vTechChildProdId);
                }

                if(String.isNotBlank(vTechProdId)) {
                    vProdExtIdSet.add(vTechProdId);
                }

                if(String.isNotBlank(vTechPbeId)) {
                    vPbeExtIdSet.add(vTechPbeId);
                }
            }

            for(Product2 vProd : [Select Id, LU_TECH_External_Id__c From Product2 Where LU_TECH_External_Id__c IN :vProdExtIdSet]){
                vExtMap.put(vProd.LU_TECH_External_Id__c, vProd.Id);
            }

            for(PricebookEntry vPbe : [Select Id, LU_TECH_External_Id__c From PricebookEntry Where LU_TECH_External_Id__c IN :vPbeExtIdSet]){
                vExtMap.put(vPbe.LU_TECH_External_Id__c, vPbe.Id);
            }

            for(OrderItem vOrderItem : pListOrderItems){
                String vTechChildProdId = vOrderItem.LU_Child_Product_TECH_ID__c;
                String vTechProdId = vOrderItem.Product2Id_TECH_ID__c;
                String vTechPbeId = vOrderItem.PricebookEntryId_TECH_ID__c;
                String vMapTechChildProdId = vExtMap.get(vTechChildProdId);
                String vMapTechProdId = vExtMap.get(vTechProdId);
                String vMapTechPbeId = vExtMap.get(vTechPbeId);
                if(String.isNotBlank(vTechChildProdId) && vMapTechChildProdId != null) {
                    vOrderItem.LU_Child_Product__c = vMapTechChildProdId;
                }

                if(String.isNotBlank(vTechProdId) && vMapTechProdId != null) {
                    vOrderItem.Product2Id = vMapTechProdId;
                }

                if(String.isNotBlank(vTechPbeId) && vMapTechPbeId != null) {
                    vOrderItem.PricebookEntryId = vMapTechPbeId;
                }
            }
        }
    }
}