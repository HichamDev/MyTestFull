@IsTest
public class lwc55_contact_details_orders_ctrl_Test {
    
    @IsTest
    public static void getOrdersTest(){
        
        // String idContact = '0031j00000EEahI';
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        String idContact = con.id;

        List<ORD_Order__c> l = lwc55_contact_details_orders_ctrl.getOrders(idContact);
        lwc55_contact_details_orders_ctrl.getUserType(idContact);
    }
}