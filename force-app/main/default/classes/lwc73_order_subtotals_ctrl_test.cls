@IsTest
public class lwc73_order_subtotals_ctrl_test {

    @IsTest
    public static void getUserCountryTest(){

        User u = AP01_TestDataFactory.createPortalUser();
        insert u;

        System.runAs(u){
            lwc73_order_subtotals_ctrl.getUserCountry();
        }
    }
	
    @IsTest
    public static void getUserCountryTestFra(){

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA';
        insert u;

        System.runAs(u){
            lwc73_order_subtotals_ctrl.getUserCountry();
        }
    }

    @IsTest
    public static void getUserCountryTestIta(){

        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Smile%' LIMIT 1].Id;

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA';
        u.ProfileId = profileId;
        insert u;

        System.runAs(u){
            lwc73_order_subtotals_ctrl.getUserCountry();
        }
    }
    
    @IsTest
    public static void getOrderTest(){
        
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;
        
        Account a = [SELECT Id FROM Account LIMIT 1];
        
        Order ord = new Order();
        ord.EffectiveDate = Date.today();
        ord.AccountId = a.Id;
        ord.Status = 'Draft';
        ord.BillToContactId = u.ContactId;
        insert ord;
        
        lwc73_order_subtotals_ctrl.getOrder(ord.Id, false);
        lwc73_order_subtotals_ctrl.getOrder(ord.Id, true);
    }
    @IsTest
    public static void getChallengesTest(){
        
        User u = AP01_TestDataFactory.createPortalUser();

        System.runAs(u){
            Test.startTest();
        lwc73_order_subtotals_ctrl.getChallenges();
        Test.stopTest();
        }
    }
}