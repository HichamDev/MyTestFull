@isTest
public class lwc71_statement_list_ctrl_TEST {
    
    @testSetup static void test_setup() {
        // Generate Data
        AP1000_Utils_Test.generateOffers();

        // FRANCE
        // Generate Contact / User
        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        Contact con = AP1002_Utils_User.getContactFromUser(userId);
        AP1000_Utils_Test.setContactForNewOrderTunnel(con.Id, 'FRA');

        List<RecordType> lRt = [select id, developername from recordtype where sobjecttype = 'STA_Statement__c' and developername = 'Statement'];
        List<STA_Statement__c> lStat = new List<STA_Statement__c>();
        // Generate statements for this user
        STA_Statement__c stat1 = new STA_Statement__c(Label_1__c='TEST_STATEMENT2'
                                                        , Status__c='Validated'
                                                        , TECH_ExternalId__c='TEST_STATEMENT_ORDER'
                                                        , Contact__c=con.Id
                                                        , TransDesc__c = 'COMMANDE MYSTAN'
                                                        ,recordTypeId=lRt[0].Id);
        lStat.add(stat1);
        STA_Statement__c stat2 = new STA_Statement__c(Label_1__c='TEST_STATEMENT2'
                                                        , Status__c='Validated'
                                                        , TECH_ExternalId__c='TEST_STATEMENT_REGULARISATION'
                                                        , Contact__c=con.Id
                                                        , TransDesc__c = 'REGULARISATION'
                                                        ,recordTypeId=lRt[0].Id);
        lStat.add(stat2);
        STA_Statement__c stat3 = new STA_Statement__c(Label_1__c='TEST_STATEMENT2'
                                                        , Status__c='Validated'
                                                        , TECH_ExternalId__c='TEST_STATEMENT_PAIEMENT'
                                                        , Contact__c=con.Id
                                                        , TransDesc__c = 'PAIEMENT'
                                                        ,recordTypeId=lRt[0].Id);
        lStat.add(stat3);
        STA_Statement__c stat4 = new STA_Statement__c(Label_1__c='TEST_STATEMENT2'
                                                        , Status__c='Validated'
                                                        , TECH_ExternalId__c='TEST_STATEMENT_PUP'
                                                        , Contact__c=con.Id
                                                        , TransDesc__c = 'PUP'
                                                        ,recordTypeId=lRt[0].Id);
        lStat.add(stat4);

        insert lStat;
           
    }

    @isTest static void test_unit_1_utils() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            Contact con1 = lwc71_statement_list_ctrl.getContact();
            system.assert(con1 != null, 'ERROR GETCONTACT');

            String country = lwc71_statement_list_ctrl.getUserCountry();
            system.assert(country != null, 'ERROR GETCOUNTRY');
        }
    }

    @isTest static void test_unit_1_list() {
        User u = [SELECT Id FROM User WHERE TECH_ExternalId__c = 'FRA_1234567890'];
        Contact con = AP1002_Utils_User.getContactFromUser(u.Id);
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE LU_Tech_External_Id__c = 'FRA_Pricebook_1' LIMIT 1];
        system.runAs(u) {
            Map<String, List<String>> mFilters = new Map<String, List<String>>();
            mFilters.put('statementType', new List<String>{Label.LU_Statement_Filter_Type_Order,Label.LU_Statement_Filter_Type_Regularisation,Label.LU_Statement_Filter_Type_Credit,Label.LU_Statement_Filter_Type_Pup});
            mFilters.put('forWho', new List<String>{Label.LU_Order_Filter_For_Who_me, Label.LU_Order_Filter_For_Who_my_team, Label.LU_Order_Filter_For_Who_all});
            
            List<STA_Statement__c> lStat = lwc71_statement_list_ctrl.getStatements(JSON.serialize(mFilters));
            system.assert(lStat != null, 'ERROR getStatements');
        }
    }

}