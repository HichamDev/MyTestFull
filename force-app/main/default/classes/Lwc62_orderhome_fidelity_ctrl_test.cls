@IsTest
public class Lwc62_orderhome_fidelity_ctrl_test {
	
    @IsTest 
    public static void getCounters() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_1234';
        insert u;
        
        Id idRecordTypeOrderRule = [SELECT Id FROM RecordType WHERE DeveloperName = 'Counter_Category'].Id;
        
        LU_Order_Rule__c oRule = new LU_Order_Rule__c(
            LU_Country__c = 'FRA',
            RecordTypeId = idRecordTypeOrderRule,
            LU_Description__c = '2',
            LU_Active__c = true
        );
        insert oRule;
        
        oRule = [SELECT Id, LU_Text__c, LU_Name__c, LU_Description__c, LU_Country__c, LU_Counter_Number__c 
                                     FROM LU_Order_Rule__c
                                    WHERE LU_Country__c = 'FRA'
                                      AND RecordType.DeveloperName = 'Counter_Category'
                                      AND LU_Description__c != ''];
		System.Debug(oRule);
		        
        Account a = [SELECT Id FROM Account WHERE TECH_ACCOwnerExternalId__c = '123456'];
        
        Order o = new Order(
            BillToContactId = u.ContactId,
            Status = 'Draft',
            AccountId = a.Id,
            EffectiveDate = System.Today()
        );
        insert o;

        System.RunAs(u){
            Map<Integer, AP1010_Counters_Utils.Counter> m = Lwc62_orderhome_fidelity_ctrl.getCounters(null, null, null);
            List<Lwc62_orderhome_fidelity_ctrl.CounterCategory> l = Lwc62_orderhome_fidelity_ctrl.getCountersByCategory(null, null, null);
            Boolean hasDraft = Lwc62_orderhome_fidelity_ctrl.getHasDraftOrder();
        }
    }
}