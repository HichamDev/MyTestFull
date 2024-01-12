@IsTest
public class lwc12_EndCustomer_Form_ctrl_test {
	
    @isTest static void test_createContact() {
        Contact con = new Contact(
        	LastName = 'LastName'
        );
        
        lwc12_EndCustomer_Form_ctrl.createContact(con);
    }
}