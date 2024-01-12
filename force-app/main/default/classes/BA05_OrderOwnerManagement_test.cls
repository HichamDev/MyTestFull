@IsTest
private class BA05_OrderOwnerManagement_test {

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
            username= 'BR04@XXXXX.com', 
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
        insert ord;

        Case cas = new Case();
        cas.ContactId = con.Id;
        cas.Type = 'Livraisons';
        cas.Sous_type__c = 'Je veux mettre à jour ma décharge transport';
        insert cas;

        con.AccountId = acc2.Id;
        update con;

        
    }

    @IsTest
    public static void testBA05_OrderOwnerManagement(){
        
        Test.startTest();        
        BA05_OrderOwnerManagement batch = new BA05_OrderOwnerManagement ();    
        Id batchId = Database.executeBatch(batch);    
        Test.stopTest();
    }
}