@IsTest
public class BatchOrders_Test {

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
        Tech_Pardot_Send_SMS__c = true,
        AccountId = acc.id,
        LastName = 'portalTestUser',
        Email = 'test@test.fr'
        );
        insert con;
        
        Order ord = new Order();
        ord.EffectiveDate = Date.today();
        ord.AccountId = con.AccountId;
        ord.Status = 'Draft';
        ord.BillToContactId = con.Id;
        insert ord;

        RecordType rc = [SELECT Id FROM RecordType where Name = 'ITA Case'];
        Case cas = new Case();
        cas.ContactId = con.Id;
        cas.RecordTypeId = rc.Id;
        insert cas;

        con.AccountId = acc2.Id;
        update con;

        
    }

    @IsTest
    public static void testBatchorder(){
        
        Test.startTest();        
        BatchOrders batch = new BatchOrders ();    
        Id batchId = Database.executeBatch(batch);    
        Test.stopTest();
    }

    @IsTest
    public static void testBatchCases(){
        
        Test.startTest();        
        BatchCases batch = new BatchCases (); 
        Id batchId = Database.executeBatch(batch);       
        Test.stopTest();
    }

    @IsTest
    public static void testBatchContacts(){
        
        Test.startTest();        
        BatchContacts batch = new BatchContacts (); 
        Id batchId = Database.executeBatch(batch);       
        Test.stopTest();
    }
}