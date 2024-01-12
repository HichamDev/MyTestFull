public without sharing class lwc66_current_order_summary_ctrl {

    @AuraEnabled
    public static Order getDraftOrder() {

        Contact c = AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());

        Order draftOrder = null;
        
        try{
            draftOrder = [SELECT Id, Name, EffectiveDate, TotalAmount, CreatedDate,
                            (SELECT Id FROM OrderItems)
                            FROM Order 
                            WHERE BillToContactId = :c.Id 
                            AND Status = 'Draft' 
                            AND Type = 'LineUp'
                            ORDER BY CreatedDate DESC 
                            LIMIT 1];
        }
        catch(Exception e){
            return null;
        }

        return draftOrder;
    }

    @AuraEnabled
    public static List<Order> getWishlist() {
        Contact con = AP1002_Utils_User.getConnectedUserContact();

        //if(con.TECH_Wishlist_Open__c){
            return [SELECT Id, Name, TECH_Formula_CSS_Status__c, LU_Online_Customer__r.FirstName, LU_Online_Customer__r.LastName, TotalAmount, Status,
                    (SELECT Id FROM OrderItems)
                      FROM Order
                     WHERE BillToContactId = :con.Id
                       AND Type = 'B2B2C'
                       AND Status = 'Draft'];
        //}

       // return null;
    }

    @AuraEnabled
    public static void addWishlistToOrder(String idWishlist){
        String idDraft = Lwc17_fastordersearchbar_ctrl.getOrderIdWithoutPricebook(null);

        List<OrderItem> l_orderItem = [SELECT Id, OrderId FROM OrderItem WHERE Id = :idWishlist];

        for(OrderItem oi : l_orderItem){
            oi.OrderId = idDraft;
        }

        update l_orderItem;

        Order wishlist = [SELECT Id FROM Order WHERE Id = :idWishlist];
        delete wishlist;
    }

    @AuraEnabled
    public static void deleteWishlist(String idWishlist){

        Order wishlist = [SELECT Id FROM Order WHERE Id = :idWishlist];
        delete wishlist;
    }
    
    @AuraEnabled
    public static void updateWishlistStatus(String idWishlist, String status){

        Order wishlist = [SELECT Id FROM Order WHERE Id = :idWishlist];
        wishlist.status = status;
        update wishlist;
    }
}