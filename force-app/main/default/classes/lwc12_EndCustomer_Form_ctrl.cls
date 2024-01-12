public class lwc12_EndCustomer_Form_ctrl {
	
    @AuraEnabled
    public static void createContact(Contact con) {
        insert con;
    }
}