@IsTest
public class lwc83_push_product_ctrl_test {
	
    @IsTest
    public static void testGetPushedProducts(){
        
        LU_Pushed_Product__mdt pushedProduct = new LU_Pushed_Product__mdt(LU_Display_Order__c = 1, 
                                                                            LU_TECH_External_Id__c = 'FRA_Pricebook_1', 
                                                                            LU_Image_Url__c = 'myImage', 
                                                                            LU_Country__c = 'FRA',
                                                                            LU_Group__c = 'A');
        
        AP1000_Utils_Test.generateOffers();
        
        PriceBook2 pb = [SELECT Id FROM PriceBook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1'];
        
        Product2 prod = new Product2(
            Name = 'prod',
            Lu_Country__c = 'FRA',
            isActive = true
        );
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(LU_TECH_External_Id__c = pushedProduct.LU_TECH_External_Id__c,Pricebook2Id = pb.Id, Product2Id = prod.Id, LU_Dealer_Price__c = 1.00, UnitPrice = 1.00,
                                                  isActive = true, LU_Offer_type__c = 'Personal Use',
                                                  LU_Counter_Value__c = '-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2'
        );
        insert pbe;

        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        User u = [SELECT Id FROM User WHERE Id =: userId];
        System.runAs(u){
            List<lwc83_push_product_ctrl.PushedProductWrapper> l_pushedProductWrapper2 = lwc83_push_product_ctrl.getPushedProducts('Italy', 'A', '', false);
            List<lwc83_push_product_ctrl.PushedProductWrapper> l_pushedProductWrapper3 = lwc83_push_product_ctrl.getPushedProductsITA('A', 'Smile');
        }
        
        List<lwc83_push_product_ctrl.PushedProductWrapper> l_pushedProductWrapper = lwc83_push_product_ctrl.getPushedProducts('France', 'A', '', true);
    }

    @IsTest
    public static void getUserCountry(){
        lwc83_push_product_ctrl.getUserCountry();
    }
    @IsTest
    public static void getCurrentorderType(){
        lwc83_push_product_ctrl.getCurrentOrderType();
    }
}