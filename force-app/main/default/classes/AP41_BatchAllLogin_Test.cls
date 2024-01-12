@IsTest
public class AP41_BatchAllLogin_Test {

   
    @IsTest
    public static void testBatchWithParameter(){

        Id idProfileFra = [SELECT Id FROM Profile WHERE Name = 'FRA_LU_DEALER_MEMBER'].Id;

        User u = AP01_TestDataFactory.createPortalUser();
        u.ProfileId = idProfileFra;
        u.Title = 'CONSEILLÈRE';
        u.TECH_ExternalId__c = 'FRA_1234';
        u.IsActive = true;
        insert u;

        u = [SELECT Id, UserType FROM User WHERE Id = :u.Id];
        System.Debug(u.UserType);

        Test.startTest();

        AP41_BatchAllLogin batch = new AP41_BatchAllLogin('FRA');
        Id batchId = Database.executeBatch(batch);

        Test.stopTest();

        u = [SELECT Id, Profile.Name FROM User WHERE Id = :u.Id];
        System.Debug(u.Profile.Name);
    }
    
    @IsTest
    public static void testScheduler() {
        
        String chron = '0 0 23 * * ?';    
        
        Test.startTest();
        
        AP41_SchFra_BatchAllLogin obj = new AP41_SchFra_BatchAllLogin();     
        String jobid = System.schedule('AP41_SchFra_BatchAllLogin', chron, obj);
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);
        
        AP41_SchIta_BatchAllLogin obj1 = new AP41_SchIta_BatchAllLogin();        
        String jobid1 = System.schedule('AP41_SchIta_BatchAllLogin', chron, obj1);
        CronTrigger ct1 = [Select id , CronExpression from CronTrigger where id = :jobid1];
        System.assertEquals(chron,ct1.CronExpression);
		
        Test.stopTest();
    }
}