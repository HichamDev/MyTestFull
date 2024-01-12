@IsTest
public with sharing class BA08_ValidateEshopOrders_Scheduler_test {
    
    @TestSetup
    public static void createData(){
        Account acc = new Account (
        Name = 'newAcc1'
        );  
        insert acc;
        Account acc2 = new Account (
            Name = 'newAcc2'
            );  
        insert acc2;
        Contact con = new Contact (
        AccountId = acc.id,
        LastName = 'portalTestUser',
        Email = 'test@mail.com'
        );
        insert con;

        Profile p = [SELECT id, Name FROM Profile where name = 'Dealer Manager'].get(0);  

        User u = new User( //STHUniqueID__c= sthId,
            firstname= 'BR04',
            lastname='XXXX',
            Alias='BR04',
            email = 'BR04@XXXXX.com',
            username= 'a01_sth_digitalit@mystan.it.test', 
            profileId= p.id, 
            emailencodingkey='UTF-8',
            languagelocalekey='en_US',
            localesidkey='en_US',
            timezonesidkey='America/Los_Angeles'
        );
        insert u;
        
        Order ord = new Order();
        ord.EffectiveDate = Date.today();
        ord.AccountId = con.AccountId;
        ord.Status = 'Draft';
        ord.BillToContactId = con.Id;
        ord.OwnerId = u.Id;
        ord.type = 'B2C';
        ord.Tech_External_Id__c = 'ITA123';
        insert ord;
    }

    @IsTest
    public static void test_BA08_ValidateEshopOrders_Scheduler_test() {

        String sch = '0 0 12 * * ?';

        Test.startTest();
        //Schedule the batch process using the scheduler sch
        System.schedule('Testing BA08', sch, new BA08_ValidateEshopOrders_Scheduler());
        
        Test.stopTest();
    }
}