@IsTest
public class lwc74_order_validation_test {
	
    @IsTest
    static void test_getOrderById() {
        Account acc = new Account(
        	Name = 'Lastname'
       	);
        insert acc;
        
        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft'
        );
        insert ord;
        
        ord = lwc74_order_validation.getOrderById(ord.Id);
    }
}