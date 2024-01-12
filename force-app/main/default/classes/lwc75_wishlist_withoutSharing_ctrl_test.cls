@IsTest
public class lwc75_wishlist_withoutSharing_ctrl_test {

    @testSetup static void test_setup() {
        // Generate Data
        AP1000_Utils_Test.generateOffers();

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        con.Ecommerce_Role__c = 'e-dealer';
        update con;
        AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');
    }

    @IsTest
    public static void getDealerTest(){
        
        User u = [SELECT Id, TECH_MergeContactID__c FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        
        u = [SELECT TECH_MergeContactID__c FROM User WHERE Id = :u.Id];
        PricebookEntry pbe = [SELECT Id, LU_TECH_External_Id__c FROM Pricebookentry where LU_TECH_External_Id__c LIKE :'FRA_96992_%' LIMIT 1];
        lwc75_wishlist_ctrl.ItemWishlist itemWlist = new lwc75_wishlist_ctrl.ItemWishlist();
        itemWlist.productId = pbe.LU_TECH_External_Id__c;
        itemWlist.name = 'abcd';
        itemWlist.quantity = '2';
        itemWlist.price = 5;
        itemWlist.isBundle = true;
        itemWlist.bundleText = 'abcd';
        
        lwc75_wishlist_ctrl.Wishlist wList = new lwc75_wishlist_ctrl.Wishlist();
        wList.l_itemWishlist = new List<lwc75_wishlist_ctrl.ItemWishlist>();
        wList.l_itemWishlist.add(itemWlist);
        wList.idDealer = u.TECH_MergeContactID__c;
        wList.contactFirstName = 'fistn';
        wList.contactLastName = 'lastn';
        wList.contactEmail = 'test@mail.com';
        wList.contactMobile = '0987654321';
        
        lwc75_wishlist_withoutSharing_ctrl.getDealer('Test');
        lwc75_wishlist_withoutSharing_ctrl.createOrder(wList);
    }
}