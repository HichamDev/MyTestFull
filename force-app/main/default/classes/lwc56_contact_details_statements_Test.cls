@IsTest
public class lwc56_contact_details_statements_Test {
	
    @IsTest
    public static void getOrdersTest(){
        
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ContactID__c = u.ContactId;
        insert u;
    
        System.runAs(u){
            Contact con = lwc56_contact_details_statements_ctrl.getContact();
            List<STA_Statement__c> l = lwc56_contact_details_statements_ctrl.getStatements(con.Id);
            String type = lwc56_contact_details_statements_ctrl.getUserType(con.Id);
        }
    }
}