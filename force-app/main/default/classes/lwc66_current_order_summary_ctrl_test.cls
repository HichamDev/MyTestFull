@IsTest
public class lwc66_current_order_summary_ctrl_test {
	
    @IsTest 
    public static void getDraftOrders() {
        User u = AP01_TestDataFactory.createPortalUser();
        insert u;
        
        Account a = [SELECT Id FROM Account WHERE TECH_ACCOwnerExternalId__c = '123456'];
        
        Order o = new Order(
            BillToContactId = u.ContactId,
            Status = 'Draft',
            AccountId = a.Id,
            EffectiveDate = System.Today()
        );
        insert o;

        System.RunAs(u){
            o = lwc66_current_order_summary_ctrl.getDraftOrder();
        }
    }
    
    @IsTest 
    public static void getDraftOrdersException() {
        User u = AP01_TestDataFactory.createPortalUser();
        insert u;

        System.RunAs(u){
            Order o = lwc66_current_order_summary_ctrl.getDraftOrder();
        }
    }
    
    @IsTest 
    public static void test_wishlist() {
        
        User u = AP01_TestDataFactory.createPortalUser();
        insert u;
        
        Contact con = [SELECT Id, TECH_Wishlist_Open__c, TECH_ExternalId__c, Ecommerce_Role__c FROM Contact WHERE Id = :u.ContactId];
        con.TECH_ExternalId__c = 'FRA';
        con.Ecommerce_Role__c = 'e-dealer';
        update con;
        
        Account a = [SELECT Id FROM Account WHERE TECH_ACCOwnerExternalId__c = '123456'];
        
        Order wishlist = new Order(
            BillToContactId = u.ContactId,
            Status = 'Draft',
            Type = 'Type',
            AccountId = a.Id,
            EffectiveDate = System.Today()
        );
        insert wishlist;
        
        Order o = new Order(
            BillToContactId = u.ContactId,
            Status = 'Draft',
            AccountId = a.Id,
            EffectiveDate = System.Today()
        );
        insert o;

        System.RunAs(u){
            List<Order> l = lwc66_current_order_summary_ctrl.getWishlist();
            lwc66_current_order_summary_ctrl.addWishlistToOrder(wishlist.Id);
        }
    }
    
    @IsTest 
    public static void delete_wishlist() {
        
        User u = AP01_TestDataFactory.createPortalUser();
        insert u;
        
        Contact con = [SELECT Id, TECH_Wishlist_Open__c, TECH_ExternalId__c, Ecommerce_Role__c FROM Contact WHERE Id = :u.ContactId];
        con.TECH_ExternalId__c = 'FRA';
        con.Ecommerce_Role__c = 'e-dealer';
        update con;
        
        Account a = [SELECT Id FROM Account WHERE TECH_ACCOwnerExternalId__c = '123456'];
        
        Order wishlist = new Order(
            BillToContactId = u.ContactId,
            Status = 'Draft',
            Type = 'Type',
            AccountId = a.Id,
            EffectiveDate = System.Today()
        );
        insert wishlist;
        
        Order o = new Order(
            BillToContactId = u.ContactId,
            Status = 'Draft',
            AccountId = a.Id,
            EffectiveDate = System.Today()
        );
        insert o;

        System.RunAs(u){
            List<Order> l = lwc66_current_order_summary_ctrl.getWishlist();
            lwc66_current_order_summary_ctrl.deleteWishlist(wishlist.Id);
        }
    }
    
    @IsTest 
    public static void update_wishlist() {
        
        User u = AP01_TestDataFactory.createPortalUser();
        insert u;
        
        Contact con = [SELECT Id, TECH_Wishlist_Open__c, TECH_ExternalId__c, Ecommerce_Role__c FROM Contact WHERE Id = :u.ContactId];
        con.TECH_ExternalId__c = 'FRA';
        con.Ecommerce_Role__c = 'e-dealer';
        update con;
        
        Account a = [SELECT Id FROM Account WHERE TECH_ACCOwnerExternalId__c = '123456'];
        
        Order wishlist = new Order(
            BillToContactId = u.ContactId,
            Status = 'Draft',
            Type = 'Type',
            AccountId = a.Id,
            EffectiveDate = System.Today()
        );
        insert wishlist;
        
        Order o = new Order(
            BillToContactId = u.ContactId,
            Status = 'Draft',
            AccountId = a.Id,
            EffectiveDate = System.Today()
        );
        insert o;

        System.RunAs(u){
            List<Order> l = lwc66_current_order_summary_ctrl.getWishlist();
            lwc66_current_order_summary_ctrl.updateWishlistStatus(wishlist.Id, 'Draft');
        }
    }
}