@IsTest
public class AP1007_Batch_User_MonthlyLogin_Test {
	
    @IsTest
    public static void testBatch(){

        Id idProfileFra = [SELECT Id FROM Profile WHERE Name = 'FRA_LU_DEALER_LOGIN'].Id;

        User u = AP01_TestDataFactory.createPortalUser();
        u.ProfileId = idProfileFra;
        u.TECH_ExternalId__c = 'FRA_1234';
        u.IsActive = true;
        u.Title = 'CONSEILLÈRE';
        insert u;

        u = [SELECT Id, UserType FROM User WHERE Id = :u.Id];
        System.Debug(u.UserType);

        Test.startTest();

        AP1007_Batch_User_MonthlyLogin batch = new AP1007_Batch_User_MonthlyLogin('FRA');
        Id batchId = Database.executeBatch(batch);

        Test.stopTest();

        u = [SELECT Id, Profile.Name FROM User WHERE Id = :u.Id];
        System.Debug(u.Profile.Name);
    }
    
    @IsTest
    public static void testScheduler() {
        
        String chron = '0 0 23 * * ?';    
        
        Test.startTest();
        
        AP1007_SchFra_Batch_User_MonthlyLogin obj = new AP1007_SchFra_Batch_User_MonthlyLogin();     
        String jobid = System.schedule('AP1007_SchFra_Batch_User_MonthlyLogin', chron, obj);
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);
        
        AP1007_SchIta_Batch_User_MonthlyLogin obj1 = new AP1007_SchIta_Batch_User_MonthlyLogin();        
        String jobid1 = System.schedule('AP1007_SchIta_Batch_User_MonthlyLogin', chron, obj1);
        CronTrigger ct1 = [Select id , CronExpression from CronTrigger where id = :jobid1];
        System.assertEquals(chron,ct1.CronExpression);
		
        Test.stopTest();
    }
}