@IsTest //(seeAllData=true)
public class lwc16_catalogchoice_ctrlTest {

    @IsTest
    static void myUnitTest() {
        
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA';
        insert u;
        
        AP1000_Utils_Test.generateOffers();
		
        System.runAs(u){
        	lwc16_catalogchoice_ctrl.getCatalogList(u.Id);
        	lwc16_catalogchoice_ctrl.getCurrentContact();
        }
    }
}