@IsTest
public class lwc75_wishlist_ctrl_test {

    @IsTest
    public static void getProductWithBundleTest(){
        
        User u = AP01_TestDataFactory.createPortalUser();
        insert u;
        
        u = [SELECT TECH_MergeContactID__c FROM User WHERE Id = :u.Id];
        
        lwc75_wishlist_ctrl.ItemWishlist itemWlist = new lwc75_wishlist_ctrl.ItemWishlist();
        itemWlist.productId = '1234567890';
        itemWlist.name = 'abcd';
        itemWlist.quantity = '2';
        itemWlist.price = 5;
        itemWlist.isBundle = true;
        itemWlist.bundleText = 'abcd';
        
        lwc75_wishlist_ctrl.getProductWithBundle(new List<lwc75_wishlist_ctrl.ItemWishlist>{itemWlist});
    }
}