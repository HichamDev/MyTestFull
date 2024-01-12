@IsTest
public class lwc24_managerinformations_ctrlTest {

    @IsTest
    public static void getManagerTest(){
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
                Contact manager = lwc24_managerinformations_ctrl.getManager();
                String country = lwc24_managerinformations_ctrl.getUserCountry();
            Test.stopTest();
        }
    }
}