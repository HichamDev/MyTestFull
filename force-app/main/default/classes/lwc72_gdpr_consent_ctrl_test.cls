@IsTest
public class lwc72_gdpr_consent_ctrl_test {
	
    @isTest static void test_createContact() {
        Contact con = new Contact(
        	LastName = 'LastName'
        );
        insert con;
        
        lwc72_gdpr_consent_ctrl.updateContact(con.Id, true);
    }
}