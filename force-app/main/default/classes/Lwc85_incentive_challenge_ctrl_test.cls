@IsTest
public class Lwc85_incentive_challenge_ctrl_test {

    @IsTest
    public static void testChallenges(){

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA';
        insert u;

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Contact con = [SELECT Id, LU_Challenge_1_Id__c, LU_Challenge_2_Id__c, LU_Challenge_3_Id__c
                       FROM Contact WHERE Id = :u.ContactId];
        
        con.LU_Challenge_1_Id__c = '1';
        con.LU_Challenge_1_Turnover__c = 10;
        con.LU_Challenge_2_Id__c = '2';
        con.LU_Challenge_2_Turnover__c = 20;
        con.LU_Challenge_4_Id__c = '4';
        con.LU_Challenge_4_Turnover__c = 20;
        update con;

        AP1000_Utils_Test.generateOffers();

        PriceBook2 pb = [SELECT Id FROM PriceBook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1'];
        
        Product2 prod = new Product2(
            Name = 'prod',
            Lu_Country__c = 'FRA',
            isActive = true
        );
        insert prod;
        Product2 prod2 = new Product2(
            Name = 'prod2',
            Lu_Country__c = 'FRA',
            isActive = true
        );
        insert prod2;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1.00, LU_Valid_For_Challenge__c = true, LU_Challenges_Ids__c = '1#2#3#5', LU_TECH_External_Id__c = 'bundleExtId',
                                                isActive = true, LU_Counter_Value__c = '-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2'
        );
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod2.Id, UnitPrice = 1.00, LU_Valid_For_Challenge__c = true, LU_Challenges_Ids__c = '1#2#3#4#5', LU_TECH_External_Id__c = 'bundleExtId2',
                                                  isActive = true, LU_Counter_Value__c = '-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2#-2'
        );
        insert pbe2;

        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft',
            BillToContactId = u.ContactId,
            PriceBook2Id = pbe.PriceBook2Id
        );
        insert ord;

        Order oldOrd = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Pending',
            BillToContactId = u.ContactId,
            PriceBook2Id = pbe.PriceBook2Id
        );
        insert oldOrd;
        
        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            PriceBookEntryId = pbe.Id,
            Product2Id = pbe.Product2Id,
            UnitPrice = 50.00,
            Quantity = 3
        );
        insert oi;

        OrderItem oldOi = new OrderItem(
            OrderId = oldOrd.Id,
            PriceBookEntryId = pbe.Id,
            Product2Id = pbe.Product2Id,
            UnitPrice = 50.00,
            Quantity = 3
        );
        insert oldOi;

        Product2 child = new Product2(
            Name = 'prod',
            Lu_Country__c = 'FRA',
            isActive = true,
            LU_Parent_Product__c = prod.Id,
            LU_Child_Start_date__c = Datetime.now().addMonths(-1),
            LU_Child_End_date__c = Datetime.now().addMonths(1)
        );
        insert child;

        OrderItem oiChild = new OrderItem(
            OrderId = ord.Id,
            PriceBookEntryId = pbe.Id,
            Product2Id = pbe.Product2Id,
            UnitPrice = 50.00,
            Quantity = 3
        );
        insert oiChild;

        String rtId = [SELECT Id FROM RecordType WHERE SobjectType = 'LU_Order_Rule__c' AND DeveloperName = 'Challenge'].Id;

        LU_Order_Rule__c oRuleGift = new LU_Order_Rule__c(
            LU_Active__c = true,
            LU_Segmentation_For__c = '*',
            LU_Criteria_Value_1__c = 100,
            LU_Criteria_Value_2__c = 200,
            LU_Criteria_On__c = 'TURNOVER_CURRENT_ORDER',
            LU_External_Id__c = '1',
            LU_Content_Img__c = '',
            LU_Content_Text__c = 'Gift',
            LU_Result_Text1__c = 'Congrats',
            LU_Result_Type__c = 'GIFT',
            LU_Result_Gift__c = 'bundleExtId',
            LU_End_Date__c = System.Now().addMonths(1),
            LU_Type__c = 'PUSH',
            LU_Country__c = 'FRA',
            LU_Start_Date__c = System.Now().addMonths(-1),
            RecordTypeId = rtId
        );
        LU_Order_Rule__c oRuleGift2 = new LU_Order_Rule__c(
            LU_Active__c = true,
            LU_Segmentation_For__c = '*',
            LU_Criteria_Value_1__c = 100,
            LU_Criteria_Value_2__c = 200,
            LU_Criteria_On__c = 'TURNOVER_CURRENT_ORDER_AND_CUMULATED',
            LU_External_Id__c = '4',
            LU_Content_Img__c = '',
            LU_Content_Text__c = 'Gift',
            LU_Result_Text1__c = 'Congrats',
            LU_Result_Type__c = 'GIFT',
            LU_Result_Gift__c = 'bundleExtId2',
            LU_End_Date__c = System.Now().addMonths(1),
            LU_Type__c = 'PUSH',
            LU_Country__c = 'FRA',
            LU_Start_Date__c = System.Now().addMonths(-1),
            RecordTypeId = rtId
        );
        LU_Order_Rule__c oRuleFee = new LU_Order_Rule__c(
            LU_Active__c = true,
            LU_Segmentation_For__c = '*',
            LU_Criteria_Value_1__c = 100,
            LU_Criteria_Value_2__c = 200,
            LU_Criteria_On__c = 'TURNOVER_CURRENT_ORDER',
            LU_External_Id__c = '2',
            LU_Content_Text__c = 'Shipping fee',
            LU_Result_Text1__c = 'Congrats',
            LU_Result_Type__c = 'FREE_SHIPPING_FEE',
            LU_End_Date__c = System.Now().addMonths(1),
            LU_Type__c = 'PUSh',
            LU_Country__c = 'FRA',
            LU_Start_Date__c = System.Now().addMonths(-1),
            RecordTypeId = rtId
        );
        LU_Order_Rule__c oRuleDiscount = new LU_Order_Rule__c(
            LU_Active__c = true,
            LU_Segmentation_For__c = '*',
            LU_Criteria_Value_1__c = 100,
            LU_Criteria_On__c = 'TURNOVER_CURRENT_ORDER',
            LU_External_Id__c = '3',
            LU_Content_Text__c = 'Discount',
            LU_Result_Text1__c = 'Congrats',
            LU_Result_Type__c = 'DISCOUNT_ON_ORDER',
            LU_Result_Gift__c = '0.1',
            LU_End_Date__c = System.Now().addMonths(1),
            LU_Type__c = 'PUSH',
            LU_Country__c = 'FRA',
            LU_Start_Date__c = System.Now().addMonths(-1),
            RecordTypeId = rtId
        );
        LU_Order_Rule__c oRuleDiscountITA = new LU_Order_Rule__c(
            LU_Active__c = true,
            LU_Segmentation_For__c = '*',
            LU_Criteria_Value_1__c = 100,
            LU_Criteria_On__c = 'TURNOVER_CURRENT_ORDER',
            LU_External_Id__c = '5',
            LU_Content_Text__c = 'Discount',
            LU_Result_Text1__c = 'Congrats',
            LU_Result_Type__c = 'DISCOUNT_ON_ORDER',
            LU_Result_Gift__c = '0.1',
            LU_End_Date__c = System.Now().addMonths(1),
            LU_Type__c = 'PUSH',
            LU_Country__c = 'ITA',
            LU_Start_Date__c = System.Now().addMonths(-1),
            RecordTypeId = rtId
        );
        insert new list<LU_Order_Rule__c>{oRuleGift, oRuleGift2, oRuleFee, oRuleDiscount, oRuleDiscountITA};
        
        System.runAs(u){
            String ser = Lwc85_incentive_challenge_ctrl.getChallenges(ord.Id);

            System.Debug(ser);

            List<Lwc85_incentive_challenge_ctrl.Challenge> l_chall = (List<Lwc85_incentive_challenge_ctrl.Challenge>) JSON.deserialize(ser, List<Lwc85_incentive_challenge_ctrl.Challenge>.class);

            String country = Lwc85_incentive_challenge_ctrl.getUserCountry();

            String isActivated =  Lwc85_incentive_challenge_ctrl.getIsChallengeActivated();

            System.Debug('1234567890123456789012345678901234567890123456789012345678901234567890');
            System.debug(l_chall);

            for(Lwc85_incentive_challenge_ctrl.Challenge chall : l_chall){
                if(!chall.isWon){
                    if(chall.resultType == 'GIFT'){
                        chall.isWon = true;
                        chall.l_child = new List<AP1002_LookupSearchResult>();
                        
                        AP1002_LookupSearchResult lsr = new AP1002_LookupSearchResult();
                        lsr.quantity = 1;

                        chall.l_child.add(lsr);
                    }
                }
            }

            Lwc85_incentive_challenge_ctrl.applyChallenges(l_chall);
        }

        acc.Country_Code__c = 'ITA';
        update acc;

        System.runAs(u){
            String ser = Lwc85_incentive_challenge_ctrl.getChallenges(ord.Id);
        }

    }
}