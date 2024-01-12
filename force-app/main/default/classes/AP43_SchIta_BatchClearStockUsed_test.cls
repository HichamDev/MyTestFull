@IsTest
public class AP43_SchIta_BatchClearStockUsed_test {
	
    @IsTest
    public static void test(){
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';

        String jobId = System.schedule('test_AP43_SchIta_BatchClearStockUsed_test', CRON_EXP, new AP43_SchIta_BatchClearStockUsed());
    }
}