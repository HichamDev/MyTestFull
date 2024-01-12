@IsTest
public class AP40_BatchDeleteOrderTest {

    @TestSetup
    public static void createData(){
        Account acc = new Account (
        Name = 'newAcc1'
        );  
        insert acc;
        Contact con = new Contact (
        AccountId = acc.id,
        LastName = 'portalTestUser'
        );
        insert con;
        Profile p = [select Id,name from Profile where Name = 'FRA_LU_DEALER_MANAGER' limit 1];
        
        User newUser = new User(
            profileId = p.id,
            username = 'newPortalUser@yahoo.com',
            email = 'pb@ff.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            contactId = con.id,
            TECH_ContactID__c = con.Id
        );
        insert newUser;

        Order ord = new Order();
        ord.EffectiveDate = Date.today();
        ord.AccountId = con.AccountId;
        ord.Status = 'Draft';
        ord.BillToContactId = con.Id;
        insert ord;
    }

    @IsTest
    public static void testIta(){
        Test.startTest();
        
        AP40_SchIta_BatchDeleteOrder schIta = new AP40_SchIta_BatchDeleteOrder ();
        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing AP40_SchIta_BatchDeleteOrder', sch, schIta);
        
        Test.stopTest();
    }

    @IsTest
    public static void testFra(){
        Test.startTest();
        
        AP40_SchFra_BatchDeleteOrder schFra = new AP40_SchFra_BatchDeleteOrder ();
        
        //Create a test scheduler using a CRON
        String sch = '0 0 12 * * ?';
        
        //Schedule the batch process using the scheduler sch
        system.schedule('Testing AP40_SchFra_BatchDeleteOrder', sch, schFra);
        
        Test.stopTest();
    }
}