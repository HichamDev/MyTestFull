@IsTest
public class lwc10_community_header_CtrlTest {

    @IsTest
    static void getUserInfo() {
		
        String userId = AP01_TestDataFactory.createPortalUserWithClients();
        User u = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(u) {
            User currentUser = u = lwc10_community_header_Ctrl.getUserInfo(u.id);
            system.assert(currentUser != null, 'ASSERT ERROR : Current User is null');
        }
        
        /*User u = new User(
            ProfileId = [SELECT Id FROM Profile LIMIT 1].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;

        u = lwc10_community_header_Ctrl.getUserInfo(u.id);
		*/
    }
}