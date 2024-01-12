public without sharing class lwc93_discount_banner_ctrl {

    @AuraEnabled
    public static Contact getContactFromUser(Id userId){
        Contact c = AP1002_Utils_User.getContactFromUser(userid);
        return c;
    }

    @AuraEnabled
    public static List<LU_Order_Rule__c> getOrderRuleDiscount(Id userId){
        List<LU_Order_Rule__c> lRules = new List<LU_Order_Rule__c>();
        Contact c = getContactFromUser(userId);
        System.debug('################################################################');
        System.debug(c);
        if (c != null) {
            String title = getContactFromUser(userId).title;
            System.debug(title);
            lRules = [SELECT discount__c, LU_Criteria_Value_1__c, LU_Criteria_Value_2__c, title__c from LU_Order_Rule__c where RecordType.Name='Order - Discount' and title__c includes (:title) order by discount__c];
        }
        System.debug(lRules);
        return lRules;
    }
    
}