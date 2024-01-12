@IsTest
public class AP42_BatchSuperMemberMigration_Test {

    @IsTest
    public static void testBatchWithParameter(){

        Id idProfileFra = [SELECT Id FROM Profile WHERE Name = 'FRA_LU_DEALER_LOGIN'].Id;

        User u = AP01_TestDataFactory.createPortalUser();
        u.ProfileId = idProfileFra;
        u.TECH_ExternalId__c = 'FRA_1234';
        u.LU_Monthly_Logins__c = 3;
        insert u;

        Test.startTest();

        AP42_BatchSuperMemberMigration batch = new AP42_BatchSuperMemberMigration('ITA');
        Id batchId = Database.executeBatch(batch);

        Test.stopTest();

        u = [SELECT Id, Profile.Name FROM User WHERE Id = :u.Id];
        System.Debug(u.Profile.Name);
    }
    
    @IsTest
    public static void testScheduler() {
        
        String chron = '0 0 23 * * ?';    
        
        Test.startTest();
        
        AP42_SchFra_BatchSuperMemberMigration obj = new AP42_SchFra_BatchSuperMemberMigration();     
        String jobid = System.schedule('AP42_SchFra_BatchSuperMemberMigration', chron, obj);
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);
        
        AP42_SchIta_BatchSuperMemberMigration obj1 = new AP42_SchIta_BatchSuperMemberMigration();        
        String jobid1 = System.schedule('AP42_SchIta_BatchSuperMemberMigration', chron, obj1);
        CronTrigger ct1 = [Select id , CronExpression from CronTrigger where id = :jobid1];
        System.assertEquals(chron,ct1.CronExpression);
		
        Test.stopTest();
    }
    
    @IsTest
    public static void testException() {
        
        Test.startTest();
        
        try {
            throw new EXC_LU_Test_Licence_Exceeded_Exception('LICENSE_LIMIT_EXCEEDED');
        } catch (Exception e) {
            
        }
        
        Test.stopTest();
    }
}