@isTest

public with sharing class BA06_UpdatePermissionSetUsersTest {
     
    static testMethod void test(){
        
        Account objAcc = new Account(name ='Test Account');
		insert objAcc; 

        Contact objContact = new Contact(LastName ='testCon',AccountId = objAcc.Id);
        insert objContact;  
        User userTest = new User(
            LastName = 'Test Code',
            Email = 'test@test.com',
            Alias = 'Tcode',
            Username = 'trtkjaioasjaweroij4@test.com',
            ProfileID = '00e2o000001pJCSAA2',
            isActive = true,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'GMT'
        );
        insert userTest;
        
        User userTest2 = new User(
            LastName = 'Test Code2',
            Email = 'test1@test.com',
            Alias = 'Tcoe',
            Username = 'trtkjaiosjaweroij4@test.com',
            ProfileID = '00e2o000001pJCSAA2',
            isActive = true,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'GMT'
            
        );
        insert userTest2;
        
       insert new Recap_Email__c(AddressEmail__c = 'Test@email.com');
        
        Test.startTest();
        BA07_DeletePermissionSetUsers ba = new BA07_DeletePermissionSetUsers();
        Database.executeBatch(ba,200);
        Test.stopTest();
        
       
        
    }
}