@IsTest
public class lwc81_personal_contact_details_orderTest {
    
	@IsTest
    public static void testGetOrders(){
        User u = AP01_TestDataFactory.createPortalUser();
        AP1000_Utils_Test.generateOffers();
        
        Account acc = new Account(
        	Name = 'Lastname'
       	);
        insert acc;

        String pbId = [SELECT Id FROM PriceBook2 LIMIT 1].Id;
        string pbeId = [SELECT Id FROM PriceBookEntry WHERE PriceBook2Id = :pbId LIMIT 1].Id;
        
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft',
            PriceBook2Id = pbId
        );
        insert ord;

        OrderItem oi = new OrderItem(
            Quantity = 5,
            PriceBookEntryId = pbeId,
            OrderId = ord.Id,
            UnitPrice = 5.00
        );
        insert oi;
        
        System.runAs(u){
            lwc81_personal_contact_details_order_ctr.getOrders(u.contactId);
            lwc81_personal_contact_details_order_ctr.getUserType(u.contactId);
        }
    }
}