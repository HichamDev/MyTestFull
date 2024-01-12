@IsTest
public class lwc28_myprofile_contactinfo_ctrlTest {

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
                String jsonContact = lwc28_myprofile_contactinfo_ctrl.getContactInfo();
                Contact con = lwc28_myprofile_contactinfo_ctrl.getContactInformations();
                System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
                System.debug(con);
                //AP1001_Cycle_Utils.CycleInfo cycle =  lwc28_myprofile_contactinfo_ctrl.getCurrentCycle();
                //lwc28_myprofile_contactinfo_ctrl.updateContact(con);
            Test.stopTest();
        }
    }

    @IsTest
    public static void getCurrentCycleTest(){

        USer u = AP01_TestDataFactory.createPortalUser();

        System.runAs(u){
            lwc28_myprofile_contactinfo_ctrl.getCurrentCycle();
        }
    }

    @IsTest
    public static void updateContactTest(){

        Contact con = new Contact(
            LastName = 'abc'
        );
        insert con;

        con.LastName = 'def';

        lwc28_myprofile_contactinfo_ctrl.updateContact(con);
    }

    @IsTest
    public static void getUserCountryTest(){

        User u = AP01_TestDataFactory.createPortalUser();

        System.runAs(u){
            lwc28_myprofile_contactinfo_ctrl.getUserCountry();
        }
    }

    @IsTest
    public static void getUserInfo(){

        User u = AP01_TestDataFactory.createPortalUser();

        System.runAs(u){
            lwc28_myprofile_contactinfo_ctrl.getUserInfo();
        }
    }
}