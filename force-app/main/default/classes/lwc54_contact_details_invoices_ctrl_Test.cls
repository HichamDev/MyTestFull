@IsTest
public class lwc54_contact_details_invoices_ctrl_Test {
	
    @IsTest
    public static void getInvoicesTest() {
        
        // String idContact = '0031j00000EEahI';
        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        String idContact = con.id;

        List<INV_Invoice__c> l = lwc54_contact_details_invoices_ctrl.getInvoices(idContact);
        lwc54_contact_details_invoices_ctrl.getUserType(idContact);
    }
}