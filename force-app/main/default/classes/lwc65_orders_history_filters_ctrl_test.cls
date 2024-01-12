@IsTest
public class lwc65_orders_history_filters_ctrl_test {
	
    @IsTest 
    public static void getContactTest() {
        User u = AP01_TestDataFactory.createPortalUser();
        insert u;

        System.RunAs(u){
            Contact c = lwc65_orders_history_filters_ctrl.getCurrentContact();
            String userCountry = lwc65_orders_history_filters_ctrl.getUserCountry();
        }
    }
    @IsTest 
    public static void getOptionsTimePeriodTest() {
        lwc65_orders_history_filters_ctrl.getOptionsTimePeriod(Label.LU_Order_Filter_Time_Period_last_week);
        lwc65_orders_history_filters_ctrl.getOptionsTimePeriod(Label.LU_Order_Filter_Time_Period_last_month);
        lwc65_orders_history_filters_ctrl.getOptionsTimePeriod(Label.LU_Order_Filter_Time_Period_last_cycle);
    }
    
    @IsTest
    static void testGetDealerManagerSegmentationOptionsFRA() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        Contact c = [SELECT Id, AccountId, Title FROM Contact WHERE Id = :u.ContactId];
        c.Title = 'ANIMATRICE DE SECTEUR';
        update c;

        Account acc = new Account();
        acc.Name = 'Test';
        acc.ParentId = c.AccountId;
        acc.Type = 'Country';
        insert acc;

        System.RunAs(u){
            String serializedFilters = lwc65_orders_history_filters_ctrl.getDealerManagerSegmentationOptions();
        }
    }
    
    @IsTest
    static void testGetDealerManagerSegmentationOptionsITA() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;
        
        Contact c = [SELECT Id, accountid, Title FROM Contact WHERE Id = :u.ContactId];
        
        Account acc = new Account(
            Name = 'lastname',
            ParentId = c.accountid,
            Country_Code__c = 'ITA'
        );
        insert acc;

        System.RunAs(u){
            String serializedFilters = lwc65_orders_history_filters_ctrl.getDealerManagerSegmentationOptions();
        }
    }
    
    @IsTest
    static void testGetDealerManagerSegmentationOptionsFRAAnimatrice() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;
        
        Contact c = [SELECT Id, accountid, Title FROM Contact WHERE Id = :u.ContactId];
        c.Title = 'Animatrice';
        update c;

        System.RunAs(u){
            String serializedFilters = lwc65_orders_history_filters_ctrl.getDealerManagerSegmentationOptions();
        }
    }
}