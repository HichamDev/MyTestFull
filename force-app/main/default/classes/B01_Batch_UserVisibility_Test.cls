@isTest
public with sharing class B01_Batch_UserVisibility_Test {
    @TestSetup
    static void makeData(){
        //Créer un compte avec un nom de groupe
        Account acc = new Account();
        acc.Name = 'Gruppo-9999';
        acc.Country_Code__c = 'ITA';
        // acc.LU_Out_Of_Business__c = true;
        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'Filiale-999';
        acc2.Country_Code__c = 'ITA';
        // acc2.LU_Out_Of_Business__c = true;
        insert acc2;

        Account acc3 = new Account();
        acc3.Name = 'Zona-2';
        acc3.Country_Code__c = 'ITA';
        // acc3.LU_Out_Of_Business__c = true;
        insert acc3;

        Account acc4 = new Account();
        acc4.Name = 'Area-3';
        acc4.Country_Code__c = 'ITA';
        // acc4.LU_Out_Of_Business__c = true;
        insert acc4;
    }

    @isTest
    public static void TestBatch(){
        Test.startTest();

        B01_Batch_UserVisibility batchVisibility = new B01_Batch_UserVisibility();
        Id batchVisibilityId = Database.executeBatch(batchVisibility);

        Account acc5 = new Account();
        acc5.Name = 'Gruppo-999';
        acc5.Country_Code__c = 'ITA';
        // acc5.LU_Out_Of_Business__c = true;
        insert acc5;

        User u = [SELECT Id, 
            MultiPick_Level3_3__c, MultiPick_Level3_4__c, MultiPick_Level3_5__c, MultiPick_Level3_6__c, MultiPick_Level3_7__c, MultiPick_Level3_8__c, MultiPick_Level3_9__c, MultiPick_Level3_10__c,  MultiPick_Level3_11__c, MultiPick_Level3_12__c, MultiPick_Level3_13__c, MultiPick_Level3_14__c, MultiPick_Level3_15__c, MultiPick_Level3_16__c, MultiPick_Level3_17__c, MultiPick_Level3_18__c, MultiPick_Level3_19__c, MultiPick_Level3_20__c,
            MultiPick_Level5_1__c, MultiPick_Level5_2__c,
            MultiPick_Level6__c, MultiPick_Level7__c,
            MultiPick_LevelCountry__c
            FROM User WHERE Id =: UserInfo.getUserId()];


        B01_Batch_UserVisibility batchVisibility2 = new B01_Batch_UserVisibility();
        Map<Id, Map<String, String>> mapOwnerpicklist = new  Map<Id, Map<String, String>>();

        Map<String, String> mapPicklists = new Map<String, String>();
        mapPicklists.put('MultiPick_Level7', 'Area-4');
        mapOwnerpicklist.put(u.Id, mapPicklists);
        batchVisibility2.mapOwnerpicklist = mapOwnerpicklist;
        Id batchVisibility2Id = Database.executeBatch(batchVisibility2);
        
        Test.StopTest(); 
    }
}