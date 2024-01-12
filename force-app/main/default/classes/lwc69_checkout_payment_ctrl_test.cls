@IsTest
public class lwc69_checkout_payment_ctrl_test {
	
    @IsTest 
    public static void testGetOrderInfo() {
        User u = AP01_TestDataFactory.createPortalUser();
        insert u;
        
        Account a = [SELECT Id FROM Account WHERE TECH_ACCOwnerExternalId__c = '123456'];
        
        Order o = new Order(
            BillToContactId = u.ContactId,
            Status = 'Draft',
            AccountId = a.Id,
            EffectiveDate = System.Today()
        );
        insert o;

        System.RunAs(u){
            o = lwc69_checkout_payment_ctrl.getOrderInfo(o.Id);
        }
    }
}