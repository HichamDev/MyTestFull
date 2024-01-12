@IsTest
public class lwc26_deletecontactlist_ctrlTest {

    @IsTest
    public static void deleteSingleContactFromIdTest(){

        Contact con = new Contact(
            Firstname = 'zrbverb',
            Lastname = 'erberb',
            Phone = '0987654321',
            Email = 'segvzegezrhb@mail.com',
            MailingCity = 'zrvrvr',
            MailingState = 'fzrvrzv',
            MailingCountry = 'zsvzrb',
            MailingPostalCode = '12345',
            MailingStreet = 'azdefrvgbtn',
            Birthdate = Date.Today().addYears(-20),
            LU_Is_Deleted__c = false
        );
        insert con;

        lwc26_deletecontactlist_ctrl.deleteSingleContactFromId(con.Id);
    }
}