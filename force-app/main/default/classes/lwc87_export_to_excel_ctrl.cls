public with sharing class lwc87_export_to_excel_ctrl {
    public lwc87_export_to_excel_ctrl() {
        String orders = ApexPages.currentPage().getParameters().get('orders');
        // system.assert(false, orders);
    }
}