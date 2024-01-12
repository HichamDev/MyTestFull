@IsTest
public class ContactBeforeUpdate_test {
    
    @IsTest
    public static void test(){
        
        User__c userSettings = User__c.getInstance(UserInfo.getProfileId());
        userSettings.isInterfaceUser__c = true;
        upsert userSettings User__c.Id;
        
        Contact c = new Contact(
            LastName = 'lastname',
        	MobilePhone = '0987654312',
            Email = 'contactReforeUpdate@mail.com'
        );
        insert c;
        Contact c2 = new Contact(
            LastName = 'lastname2',
        	MobilePhone = '0987654314',
            Email = 'contactReforeUpdate2@mail.com'
        );
        insert c2;
        
        c.MobilePhone = '';
        c.ReportsToId = c2.Id;
        update c;
    }

    @isTest
    public static void testAfterUpdate(){
        
        User__c userSettings = User__c.getInstance(UserInfo.getProfileId());
        userSettings.isInterfaceUser__c = false;
        upsert userSettings User__c.Id;

        
        Contact c = new Contact(
            LastName = 'lastname',
        	MobilePhone = '0987654312',
            Email = 'contactReforeUpdate@mail.com'
            );
            insert c;

        c.MobilePhone = '0987654313';
        update c;

        AP1000_Utils_Test.generateOffers();

        PriceBook2 pb = [SELECT Id FROM PriceBook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1'];
        
        Product2 prod = new Product2(
            Name = 'prod',
            Lu_Country__c = 'FRA',
            isActive = true
        );
        insert prod;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1.00,
                                                  isActive = true, LU_TECH_External_Id__c = 'bundleExtId');
        insert pbe;

        

        Account vFakeAcc = new Account();
        vFakeAcc.Name = 'testAcc';
        insert vFakeAcc;

        Order ord = new Order(
            AccountId = vFakeAcc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft',
            BillToContactId = c.Id,
            PriceBook2Id = pbe.PriceBook2Id
        );
        insert ord;

        c.AccountId = vFakeAcc.Id;
        update c;
    }
}