@IsTest
public class lwc78_order_detail_invoice_ctrl_test {
	
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
        
        lwc78_order_detail_invoice_ctrl.getOrder(ord.Id);
    }
}