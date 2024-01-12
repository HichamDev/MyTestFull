@isTest
public with sharing class lwc93_discount_banner_ctrl_test {

    private final static String CONTACT_NAME = 'Test Rebate';
    private final static String CONTACT_EMAIL = 'email@test.com';
    private final static String CONTACT_Title = 'Smile';
    private final static String ORDER_RULE_NAME = 'Test REBATE';

    @testSetup 
    static void dataCreation() {
        Account vAcc = new Account();
        vAcc.Name = 'Account Name';
        Database.insert(vAcc);

        Contact c = new Contact();
        Id dealer=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        c.RecordtypeId=dealer;
        c.AccountId=vAcc.Id;
        c.email=CONTACT_EMAIL;
        c.birthDate=System.today();
        c.STHID__c='457811';
        c.MinOrder__c = 50;
        c.title=CONTACT_Title;
        c.LastName=CONTACT_NAME;
        Database.insert(c);

        User u = AP01_TestDataFactory.createPortalUser();
        u.ContactId = c.Id;
        u.email = CONTACT_EMAIL;
        insert u;

        LU_Order_Rule__c rule = new LU_Order_Rule__c();
        Id discount=Schema.SObjectType.LU_Order_Rule__c.getRecordTypeInfosByName().get('Order - Discount').getRecordTypeId();
        rule.RecordtypeId=discount;
        rule.LU_Name__c=ORDER_RULE_NAME;
        rule.LU_Criteria_Value_1__c=0.00;
        rule.Title__c=CONTACT_Title;
        rule.LU_Country__c='ITA';
        rule.Discount__c=18;
        insert rule;
    }
    
    @IsTest
    public static void testGetContactFromUser(){
        Contact c = [Select Id, Email, Title
        From Contact 
        Where Name = :CONTACT_NAME limit 1];

        User u =[Select Id, Email, Title
        From User 
        Where email = :CONTACT_EMAIL limit 1];

        Contact con = lwc93_discount_banner_ctrl.getContactFromUser(u.id);

        System.assertEquals(c.id, con.id);
        System.assertEquals(c.email, con.email);
        System.assertEquals(c.title, con.title);
    }

    @IsTest
    public static void testGetOrderRuleDiscount(){
        User u =[Select Id, Email, Title
        From User 
        Where email = :CONTACT_EMAIL limit 1];

        List<LU_Order_Rule__c> lRules =  lwc93_discount_banner_ctrl.getOrderRuleDiscount(u.Id);
        LU_Order_Rule__c rule = lRules[0];
        
        System.assertEquals('Smile', rule.Title__c);
        System.assertEquals(0.00, rule.LU_Criteria_Value_1__c);
        System.assertEquals(18, rule.Discount__c);
    }
}