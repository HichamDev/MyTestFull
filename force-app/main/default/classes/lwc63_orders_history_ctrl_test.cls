@IsTest 
public with sharing class lwc63_orders_history_ctrl_test {

    @IsTest 
    public static void getContactTest() {
        User u = AP01_TestDataFactory.createPortalUser();
        insert u;

        System.RunAs(u){
            Contact c = lwc63_orders_history_ctrl.getContact();
            String userCountry = lwc63_orders_history_ctrl.getUserCountry();
        }
    }
    @IsTest 
    public static void updateOrderStatusTest() {
       lwc63_orders_history_ctrl.updateOrderStatus(null, null);
    }
    @IsTest 
    public static void lwc87_export_to_excel_ctrlTest() {
       lwc87_export_to_excel_ctrl ctrl = new lwc87_export_to_excel_ctrl();
    }

    @IsTest 
    public static void getOrdersTestFra() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        Contact c = [SELECT AccountId FROM Contact WHERE Id = :u.ContactId];
        
        System.RunAs(u){
            String week = Date.today().format() + 'week' + Date.today().addDays(2).format();
            String month = Date.today().addMonths(-1).format()+'month'+ Date.today().addMonths(2).format();
            String cycle = Date.today().format() + 'cycle' + Date.today().addDays(2).format();
            Map<String, List<String>> m_filters = new Map<String, List<String>>();
            m_filters.put('timePeriod', new List<String>{Label.LU_Order_Filter_Time_Period_this_week, 
                                                         Label.LU_Order_Filter_Time_Period_this_month, 
                                                         Label.LU_Order_Filter_Time_Period_this_cycle, 
                                                         Label.LU_Order_Filter_Time_Period_last_week, 
                                                         Label.LU_Order_Filter_Time_Period_last_month, 
                                                         Label.LU_Order_Filter_Time_Period_last_cycle,
                                                         week, month, cycle
                                                        });

            m_filters.put('orderStatus', new List<String>{Label.LU_Order_Filter_Order_Status_Draft, 
                                                          Label.LU_Order_Filter_Order_Status_Invoiced, 
                                                          Label.LU_Order_Filter_Order_Status_Pending,
                                                          Label.LU_Order_Filter_Order_Status_Packing,
                                                          Label.LU_Order_Filter_Order_Status_Sent_Orders, 
                                                          Label.LU_Order_Filter_Order_Status_Processing_Orders,
                										  Label.LU_Order_Filter_Order_Status_Processing,
                										  Label.LU_Order_Filter_Order_Status_Shipped,
                										  Label.LU_Order_Filter_Order_Status_Blocked,
                										  Label.LU_Order_Filter_Order_Type_draft,
                										  Label.LU_Order_Filter_Order_Type_validated,
                										  Label.LU_Order_Filter_Order_Status_Cancelled});

            m_filters.put('orderType', new List<String>{Label.LU_Order_Filter_Order_Type_day_order, 
                                                          Label.LU_Order_Filter_Order_Type_draft, 
                                                          Label.LU_Order_Filter_Order_Type_validated, 
                                                          Label.LU_Order_Filter_Order_Type_stanhomefr,
                                                          Label.LU_Order_Filter_Order_Type_myStan,
                                                          Label.LU_Order_Filter_Order_Type_whishlist,
                                                          Label.LU_Order_Filter_Order_Type_B2B2C,
                                                          Label.LU_Order_Filter_Order_Type_B2C,
                                                          Label.LU_Order_Filter_Order_Type_cbStanhome,
                                                          Label.LU_Order_Filter_Order_Type_nouveauClient,
                                                          Label.LU_Order_Filter_Order_Type_ipaper});

            m_filters.put('dealerManagerSegmentation', new List<String>{c.AccountId});

            m_filters.put('forWho', new List<String>{Label.LU_Order_Filter_For_Who_me, 
                                                          Label.LU_Order_Filter_For_Who_clientStanhome, 
                                                          Label.LU_Order_Filter_For_Who_nouveauClient, 
                                                          Label.LU_Order_Filter_For_Who_my_team, 
                                                          Label.LU_Order_Filter_For_Who_all});
            
            m_filters.put('invoiceStatus', new List<String>{Label.LU_Order_Filter_Invoice_Status_Paid, 
                                                          	Label.LU_Order_Filter_Invoice_Status_Unpaid});

            lwc63_orders_history_ctrl.getOrders(JSON.serialize(m_filters));
        }
    }

    @IsTest 
    public static void getOrdersTestItaDirectore() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;

        Contact c = [SELECT Title FROM Contact WHERE Id = :u.ContactId];
        c.Title = 'Dirretore de filiale';
        update c;

        System.RunAs(u){
            Map<String, List<String>> m_filters = new Map<String, List<String>>();
            m_filters.put('timePeriod', new List<String>{Label.LU_Order_Filter_Time_Period_this_week, 
                                                         Label.LU_Order_Filter_Time_Period_this_month, 
                                                         Label.LU_Order_Filter_Time_Period_this_cycle, 
                                                         Label.LU_Order_Filter_Time_Period_last_week, 
                                                         Label.LU_Order_Filter_Time_Period_last_month, 
                                                         Label.LU_Order_Filter_Time_Period_last_cycle});

            m_filters.put('orderStatus', new List<String>{Label.LU_Order_Filter_Order_Status_Draft, 
                                                          Label.LU_Order_Filter_Order_Status_Invoiced, 
                                                          Label.LU_Order_Filter_Order_Status_Sent_Orders, 
                                                          Label.LU_Order_Filter_Order_Status_Processing_Orders});

            m_filters.put('orderType', new List<String>{Label.LU_Order_Filter_Order_Type_day_order, 
                                                          Label.LU_Order_Filter_Order_Type_draft, 
                                                          Label.LU_Order_Filter_Order_Type_validated, 
                                                          Label.LU_Order_Filter_Order_Type_stanhomefr,
                                                          Label.LU_Order_Filter_Order_Type_ipaper});

            m_filters.put('forWho', new List<String>{Label.LU_Order_Filter_For_Who_me, 
                                                          Label.LU_Order_Filter_For_Who_my_team, 
                                                          Label.LU_Order_Filter_For_Who_all});

            lwc63_orders_history_ctrl.getOrders(JSON.serialize(m_filters));
        }
    }

    @IsTest 
    public static void getOrdersTestItaSmile() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;

        Contact c = [SELECT Title FROM Contact WHERE Id = :u.ContactId];
        c.Title = 'Smile';
        update c;

        System.RunAs(u){
            Map<String, List<String>> m_filters = new Map<String, List<String>>();
            m_filters.put('timePeriod', new List<String>{Label.LU_Order_Filter_Time_Period_this_week, 
                                                         Label.LU_Order_Filter_Time_Period_this_month, 
                                                         Label.LU_Order_Filter_Time_Period_this_cycle, 
                                                         Label.LU_Order_Filter_Time_Period_last_week, 
                                                         Label.LU_Order_Filter_Time_Period_last_month, 
                                                         Label.LU_Order_Filter_Time_Period_last_cycle});

            m_filters.put('orderStatus', new List<String>{Label.LU_Order_Filter_Order_Status_Draft, 
                                                          Label.LU_Order_Filter_Order_Status_Invoiced, 
                                                          Label.LU_Order_Filter_Order_Status_Sent_Orders, 
                                                          Label.LU_Order_Filter_Order_Status_Processing_Orders});

            m_filters.put('orderType', new List<String>{Label.LU_Order_Filter_Order_Type_day_order, 
                                                          Label.LU_Order_Filter_Order_Type_draft, 
                                                          Label.LU_Order_Filter_Order_Type_validated, 
                                                          Label.LU_Order_Filter_Order_Type_stanhomefr,
                                                          Label.LU_Order_Filter_Order_Type_ipaper});

            m_filters.put('forWho', new List<String>{Label.LU_Order_Filter_For_Who_me, 
                                                          Label.LU_Order_Filter_For_Who_my_team, 
                                                          Label.LU_Order_Filter_For_Who_all});

            lwc63_orders_history_ctrl.getOrders(JSON.serialize(m_filters));
        }
    }
}