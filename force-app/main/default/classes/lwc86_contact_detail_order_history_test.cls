@IsTest
public class lwc86_contact_detail_order_history_test {
	
    @IsTest
    public static void testFRA(){
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA';
        insert u;
        
        System.runAs(u){
            Contact con = lwc86_contact_detail_order_history_ctrl.getContact();
            
            String country = lwc86_contact_detail_order_history_ctrl.getUserCountry();
            
            List<Order> l_orders = lwc86_contact_detail_order_history_ctrl.getOrders(con.Id);
            List<Order> l_orders2 = lwc86_contact_detail_order_history_ctrl.getOrdersForContact(con.Id);
        }
    }
    
    @IsTest
    public static void testITADirettore(){
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA';
        insert u;
        
        Contact con = [SELECT Id FROM Contact WHERE Id = :u.ContactId];
        con.Title = 'Direttore di Filiale';
        update con;
        
        System.runAs(u){
            con = lwc86_contact_detail_order_history_ctrl.getContact();
            
            String country = lwc86_contact_detail_order_history_ctrl.getUserCountry();
            
            List<Order> l_orders = lwc86_contact_detail_order_history_ctrl.getOrders(con.Id);
        }
    }
    
    @IsTest
    public static void testITASmile(){
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA';
        insert u;
        
        Contact con = [SELECT Id FROM Contact WHERE Id = :u.ContactId];
        con.Title = 'Smile';
        update con;
        
        System.runAs(u){
            con = lwc86_contact_detail_order_history_ctrl.getContact();
            
            String country = lwc86_contact_detail_order_history_ctrl.getUserCountry();
            
            List<Order> l_orders = lwc86_contact_detail_order_history_ctrl.getOrders(con.Id);
        }
    }
}