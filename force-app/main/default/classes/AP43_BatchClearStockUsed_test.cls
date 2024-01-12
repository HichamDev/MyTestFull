@IsTest
public class AP43_BatchClearStockUsed_test {
    
	@IsTest
    public static void testBatch(){
        
        Product2 p = new Product2(
            Name = 'product name',
            LU_Tech_External_Id__c = 'FRA',
            Lu_country__c = 'FRA'
        );
        insert p;
        
        LU_Stock_Used__c su = new LU_Stock_Used__c(
            Lu_Product__c = p.Id
        );
        insert su;
        	
        AP43_BatchClearStockUsed batch = new AP43_BatchClearStockUsed('FRA');
        database.executebatch(batch);
    }
}