public without sharing class Lwc62_orderhome_fidelity_ctrl {

    public class CounterCategory {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String text {get;set;}
        @AuraEnabled
        public Boolean isDisplayed {get;set;}
        @AuraEnabled
        public Boolean isValuesTopLeftAndTopRightDisplayed {get;set;}
        @AuraEnabled
        public String chartType {get;set;}
        @AuraEnabled
        public String chartCSS {get;set;}
        @AuraEnabled
        public List<AP1010_Counters_Utils.Counter> l_counters {get;set;}
    }

    @AuraEnabled
    public static Boolean getHasDraftOrder(){
        String idUserContact = [SELECT TECH_MergeContactID__c FROM User WHERE Id = :Userinfo.getUserId()].TECH_MergeContactID__c;

        List<Order> l_order = [SELECT Id FROM Order WHERE BillToContactId = :idUserContact AND Order.Status = 'Draft'];

        return !l_order.isEmpty();
    }

    @AuraEnabled
    public static List<CounterCategory> getCountersByCategory(String json_l_products, String json_l_idProducts, String idContactFor) {

        User currentUser = [SELECT TECH_MergeContactID__c, TECH_ExternalId__c FROM User WHERE Id = :Userinfo.getUserId()];
        String idUserContact = currentUser.TECH_MergeContactID__c;
        String userCountry = currentUser.TECH_ExternalId__c.left(3);

        List<OrderItem> lLines = null;
        Map<Integer, AP1010_Counters_Utils.Counter> m_countersByNumber = null;

        if(userCountry == 'FRA'){
            lLines = [SELECT OrderId
                        FROM OrderItem
                        WHERE Order.BillToContactId = :idUserContact
                        AND LU_Child_Product__c = null 
                        AND Order.Status = 'Draft' ];

            m_countersByNumber = AP1010_Counters_Utils.getCounters(
                                lLines.isEmpty() ? null : lLines.get(0).OrderId,
                                String.IsBlank(json_l_products) ? null : (List<AP1002_LookupSearchResult>) System.JSON.deserialize(json_l_products, List<AP1002_LookupSearchResult>.class), 
                                String.IsBlank(json_l_idProducts) ? null : (List<String>) System.JSON.deserialize(json_l_idProducts, List<String>.class));
        }
        else if(userCountry == 'ITA'){
            lLines = [SELECT OrderId
                        FROM OrderItem
                        WHERE LU_Contact_For__c = :idContactFor
                        AND LU_Child_Product__c = null 
                        AND Order.Status = 'Draft' ];

            m_countersByNumber = AP1010_Counters_Utils.getCounters(
                                lLines.isEmpty() ? null : lLines.get(0).OrderId,
                                String.IsBlank(json_l_products) ? null : (List<AP1002_LookupSearchResult>) System.JSON.deserialize(json_l_products, List<AP1002_LookupSearchResult>.class), 
                                String.IsBlank(json_l_idProducts) ? null : (List<String>) System.JSON.deserialize(json_l_idProducts, List<String>.class),
                                idContactFor);
        }

        List<LU_Order_Rule__c> l_categories = Lwc62_orderhome_fidelity_ctrl.getCounterCategory();

        List<CounterCategory> l_counterCategory = new List<CounterCategory>();

        for(LU_Order_Rule__c cat : l_categories){

            CounterCategory cc = new CounterCategory();
            cc.isDisplayed = false;
            cc.name = cat.LU_Name__c;
            cc.description = cat.LU_Description__c;
            cc.text = cat.LU_Text__c;
            cc.chartType = cat.LU_Chart_Type__c;
            cc.chartCSS = (cc.chartType == 'bar' ? 
                            'text-align: center; height: 100px; position: relative; top: 15px;' :
                            'text-align: center; height: 130px; position: relative; top: -25px;');
            cc.isValuesTopLeftAndTopRightDisplayed = (cc.chartType == 'doughnut' ? true : false);
            cc.l_counters = new List<AP1010_Counters_Utils.Counter>();

            for(String counterNumber : cat.LU_Description__c.split('#')){ // LU_Counter_Number__c
                if(m_countersByNumber.containsKey(Integer.valueOf(counterNumber))){
                    cc.l_counters.add(m_countersByNumber.get(Integer.valueOf(counterNumber)));
                    if(m_countersByNumber.get(Integer.valueOf(counterNumber)).isDisplayed){
                        cc.isDisplayed = true;
                    }
                }
            }

            l_counterCategory.add(cc);
        }
        
        return l_counterCategory;
    }

    @AuraEnabled
    public static List<LU_Order_Rule__c> getCounterCategory(){

        String country = AP1002_Utils_User.getUserCountry(Userinfo.getUserId());

        return [SELECT Id, LU_Text__c, LU_Name__c, LU_Description__c, LU_Country__c, LU_Counter_Number__c, LU_Chart_Type__c 
                    FROM LU_Order_Rule__c
                    WHERE LU_Country__c = :country
                    AND RecordType.DeveloperName = 'Counter_Category'
                    AND LU_Description__c != ''
                    AND LU_Active__c = true 
                    ORDER BY LU_Name__c];
    }

    @AuraEnabled
    public static Map<Integer, AP1010_Counters_Utils.Counter> getCounters(String json_l_products, String json_l_idProducts, String idContactFor){
        
        String idUserContact = [SELECT TECH_MergeContactID__c FROM User WHERE Id = :Userinfo.getUserId()].TECH_MergeContactID__c;

        List<OrderItem> lLines = [SELECT OrderId
                                    FROM OrderItem
                                   WHERE Order.BillToContactId = :idUserContact
                                     AND LU_Contact_For__c = :idContactFor
                                     AND LU_Child_Product__c = null 
                                     AND Order.Status = 'Draft' ];
        
        return AP1010_Counters_Utils.getCounters(
            lLines.isEmpty() ? null : lLines.get(0).OrderId,
            String.IsBlank(json_l_products) ? null : (List<AP1002_LookupSearchResult>) System.JSON.deserialize(json_l_products, List<AP1002_LookupSearchResult>.class), 
            String.IsBlank(json_l_idProducts) ? null : (List<String>) System.JSON.deserialize(json_l_idProducts, List<String>.class));
    }

    @AuraEnabled
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

}