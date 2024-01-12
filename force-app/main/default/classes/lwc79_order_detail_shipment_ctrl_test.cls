@IsTest
public class lwc79_order_detail_shipment_ctrl_test {
	
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
        
        lwc79_order_detail_shipment_ctrl.getOrder(ord.Id);
    }
}