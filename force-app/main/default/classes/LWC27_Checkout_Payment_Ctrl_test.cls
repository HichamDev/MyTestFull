@IsTest
public class LWC27_Checkout_Payment_Ctrl_test {
    
    @IsTest
    public static void test_initPayment(){
        
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA';
        insert u;
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft'
        );
        insert ord;
        
        ord = LWC27_Checkout_Payment_Ctrl.initPayment(ord.Id);
    }

}