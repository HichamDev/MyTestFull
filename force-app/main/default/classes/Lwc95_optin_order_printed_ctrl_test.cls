@isTest
private class Lwc95_optin_order_printed_ctrl_test {

    @isTest
    static void testGetContactIdFromUser() {
        // Test Setup
        Account acc = new Account (
        Name = 'newAcc1'
        );  
        insert acc;
        Contact testContact = new Contact(
            AccountId = acc.Id,
            FirstName = 'Test',
            LastName = 'Contact',
            OptinNewsletter3__c = false
   	     );
       	 insert testContact;
        User u = AP01_TestDataFactory.createPortalUser();
        u.ContactId = testContact.Id;
        insert u;
        // Set the current user context
        Test.startTest();
        System.runAs(u) {
            String ContactIdFromUser = Lwc95_optin_order_printed_ctrl.getContactIdFromUser();
            Assert.areEqual(ContactIdFromUser, String.valueOf(u.contactId), 'ContactId From User not equal contactId');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetContactInfo() {
        //Contact
        Account acc = new Account (
        Name = 'newAcc1'
        );  
        insert acc;
        Contact testContact = new Contact(
            AccountId = acc.Id,
            FirstName = 'Test',
            LastName = 'Contact',
            OptinNewsletter3__c = false
   	     );
       	 insert testContact;
        User u = AP01_TestDataFactory.createPortalUser();
        u.ContactId = testContact.Id;
        insert u;
        
        Test.startTest();
        // Set the current user context
        System.runAs(u) {
            Contact resultContact = Lwc95_optin_order_printed_ctrl.getContactInfo();
            Assert.areEqual(u.contactId, resultContact.Id, 'Contact should not be null');
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateContactOptin() {
        //Contact
        Account acc = new Account (
        Name = 'newAcc1'
        );  
        insert acc;
        Contact testContact = new Contact(
            AccountId = acc.Id,
            FirstName = 'Test',
            LastName = 'Contact',
            OptinNewsletter3__c = false
   	     );
       	 insert testContact;
        User u = AP01_TestDataFactory.createPortalUser();
        u.ContactId = testContact.Id;
        insert u;
        
        Test.startTest();
        // Set the current user context
        System.runAs(u) {
            Lwc95_optin_order_printed_ctrl.updateContactOptin(testContact.Id, true);
            Contact updatedContact = [SELECT Id, OptinNewsletter3__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
            System.assertEquals(true, updatedContact.OptinNewsletter3__c, 'OptinNewsletter3__c should be true');
        }
		Test.stopTest();

    }

     @IsTest
    public static void getContactInfoTest(){

        Account acc = new Account (
        Name = 'newAcc1'
        );  
        insert acc;
        
        Contact parent = new Contact(
            FirstName = 'parent',
            LastName = 'parent'
        );
        insert parent;

        Contact enfant = new Contact(
            FirstName = 'enfant',
            LastName = 'enfant',
            ReportsToId = parent.Id,
            AccountId = acc.Id
        );
        insert enfant;

        User u = AP01_TestDataFactory.createPortalUser();
        u.ContactId = enfant.Id;
        insert u;

        System.runAs(u){
            Test.startTest();
                Contact con = Lwc95_optin_order_printed_ctrl.getContactInformations();
                System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
                System.debug(con);
            Test.stopTest();
        }
    }
    
	@IsTest
    public static void getUserCountryTest(){

        User u = AP01_TestDataFactory.createPortalUser();

        System.runAs(u){
            Lwc95_optin_order_printed_ctrl.getUserCountry();
        }
    }

    // Similar test methods for getContactInformations and getUserCountry can be added as needed.*/
}