public class CreateUsers {
    @future 
    public static void createUser(String contact_ID){
        Profile p = [SELECT Id FROM Profile WHERE Name='FRA_LU_DEALER_MEMBER'];
        UserRole role = [select id from UserRole where Name = '6562-CTL ALLAIN STEPHANIE Customer User'];
        User testUser = new User(
            UserRoleId = role.id,
            FirstName = 'TestoptinUser2',
            LastName = 'TestoptinUser22',
            Email = 'TestoptinUser222@example.com',
            Username = 'TestoptinUser2222@example.com',
            Alias = 'tuser2',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id,
            contactId = contact_ID
        );
        insert testUser;
    }
}