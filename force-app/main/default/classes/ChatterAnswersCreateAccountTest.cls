@isTest
private class ChatterAnswersCreateAccountTest {
    static testMethod void validateAccountCreation() {
        Map<Id,Profile> profileIds = new Map<id,profile>([SELECT Id,UserLicenseId FROM Profile where UserLicenseId  in (SELECT Id FROM UserLicense where name ='Salesforce') limit 1]);
        
        User[] user = [SELECT Id, Firstname, Lastname from User where IsActive=true and profileId in:profileIds.Keyset() limit 1];
        // We cannot create account without a user.
        if (user.size() == 0) { return; }
        String firstName = user[0].FirstName;
        String lastName = user[0].LastName;
        String userId = user[0].Id;
        String accountId = new ChatterAnswers().createAccount(firstName, lastName, userId);
        Account account = [SELECT name, ownerId from Account where Id =: accountId];
        System.assertEquals(firstName + ' ' + lastName, account.name);
        System.assertEquals(userId, account.ownerId);
    }
}