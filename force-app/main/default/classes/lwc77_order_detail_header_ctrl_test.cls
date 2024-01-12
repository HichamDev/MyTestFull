@IsTest
public class lwc77_order_detail_header_ctrl_test {
	
    @IsTest
    public static void testGetOrder(){
        
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
        
        lwc77_order_detail_header_ctrl.getOrder(ord.Id);
    }
}