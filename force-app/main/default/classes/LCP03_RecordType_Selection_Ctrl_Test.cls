@isTest
public class LCP03_RecordType_Selection_Ctrl_Test {
	
    static testMethod void test_unit1() {
        Test.startTest();
        LCP03_RecordType_Selection_Ctrl.fetchRecordTypeValues();
        
        LCP03_RecordType_Selection_Ctrl.getRecTypeId('Event');
        
        Test.stopTest();
    }
    
}