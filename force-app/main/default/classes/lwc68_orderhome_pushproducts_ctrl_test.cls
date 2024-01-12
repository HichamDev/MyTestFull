@IsTest
public class lwc68_orderhome_pushproducts_ctrl_test {
    
    @testSetup static void test_setup() {
        // Generate Data
        AP1000_Utils_Test.generateOffers();

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');
    }

    @isTest static void test_unit_1_order() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        system.runAs(u) {
            String extId = 'FRA_1001_%';
            Pricebookentry pbe = [SELECT Id, LU_TECH_External_Id__c FROM pricebookentry where LU_TECH_External_Id__c LIKE :extId LIMIT 1];
            system.debug(pbe.LU_TECH_External_Id__c);
            lwc68_orderhome_pushproducts_ctrl.getUserInformation();
			lwc68_orderhome_pushproducts_ctrl.getPriceBookEntry(pbe.LU_TECH_External_Id__c);
        }
    }

    // @IsTest
    // public static void test_getPriceBookEntry(){
    //     User u = AP01_TestDataFactory.createPortalUser();
    //     u.TECH_ExternalId__c = 'FRA';
    //     insert u;

    //     Contact c = [SELECT Id FROM Contact WHERE firstName = 'Test' LIMIT 1];
    //     c.LU_Eligibility_Groups__c = '*';
        
    //     Account cuenta = new Account();
    // 	cuenta.Name='Test1';
   	// 	cuenta.CurrencyIsoCode = 'MXN';
   	// 	insert cuenta;
   		
   	// 	Account cuenta2 = new Account();
    // 	cuenta2.Name='Test1';
   	// 	cuenta2.CurrencyIsoCode = 'MXN';
   	// 	insert cuenta2;
   		
    //     Opportunity oportunidadNueva = new Opportunity();
    //     oportunidadNueva.Name = 'TEst';
    //     oportunidadNueva.StageName='Contratada';
    //     oportunidadNueva.CloseDate=Date.today();
    //     oportunidadNueva.CurrencyIsoCode='MXN';
    //     oportunidadNueva.AccountId = cuenta.Id;
    //     insert oportunidadNueva;
        
    //     Product2 producto =new Product2();
    //     producto.Name='test';
    //     producto.productCode='1234';
    //     producto.isActive = true;
    //     producto.CurrencyIsoCode='MXN';
    //     producto.LU_Country__c = 'FRA';
    //     insert producto;
        
    //     Id idPbStandard = Test.getStandardPricebookId();
        
    //    	PricebookEntry pbe = new PricebookEntry();
	//     pbe.pricebook2Id = idPbStandard;
	//     pbe.product2id = producto.id;
	//     pbe.unitprice = 1250.0;
	//     pbe.isactive = true;
    //     pbe.LU_Offer_type__c = 'test';
    //     pbe.LU_Eligibility_Segments__c = '*';
    //     pbe.LU_TECH_External_Id__c = 'azertyuiop';
	//     insert pbe;
        
    //     String rtOruleId = [SELECT Id FROM RecordType WHERE DeveloperName = 'LU_Stock_Low_Limit_Threshold'].Id;
        
    //     LU_Order_Rule__c oRule = new LU_Order_Rule__c(
    //         LU_Value__c = 1,
    //         LU_Description__c = 'b',
    //         RecordTypeId = rtOruleId,
    //         LU_Country__c = 'FRA'
    //     );
    //     insert oRule;
        
    //     System.RunAs(u){
    //         lwc68_orderhome_pushproducts_ctrl.getUserInformation();
	// 		lwc68_orderhome_pushproducts_ctrl.getPriceBookEntry(pbe.LU_TECH_External_Id__c);
    //     }
    // }
}