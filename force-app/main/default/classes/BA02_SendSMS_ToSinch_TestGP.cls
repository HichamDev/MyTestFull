@IsTest(SeeAllData=true)
public with sharing class BA02_SendSMS_ToSinch_TestGP {

    @Istest 
    public static void runAllSegment(){
        Set<String> segments = new Set<String>{
        'Argento Sales Consultant Argento', 
        'Argento Smile',
        'Argento Stanlover',
        'Bronzo Sales Consultant Bronzo',
        'Bronzo Smile',
        'Bronzo Stanlover',
        'Oro Sales Consultant Oro',
        'Oro Smile',
        'Oro Stanlover',
        'Platino Sales Consultant Platino',
        'Platino Smile',
        'Platino Stanlover',
        'Superstar Sales Consultant Superstar',
        'Superstar Smile',
        'Superstar Stanlover'
        };
        
        Test.startTest();
        for(String seg : segments){
            BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{seg});
            Database.executeBatch(smsBatch, 100 );
        }
        Test.stopTest();
    }


    @IsTest 
    public static void testBatchWithOrgDataBronzoSalesSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Bronzo_SALES');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSalesSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Bronzo Sales Consultant Bronzo' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
        
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSalesSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSalesSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();


    }
    @IsTest 
    public static void testBatchWithOrgDataBronzoSmileSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Bronzo_SMILE');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSmileSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Bronzo Smile' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
           
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSmileSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSmileSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();


    }
    @IsTest 
    public static void testBatchWithOrgDataBronzoStanloverSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Bronzo_Stanlover');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoStanloverSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Bronzo Stanlover' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoStanloverSegment - contactCheckList.size] ' + contactCheckList.size());                                          
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoStanloverSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataArgentoSalesSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Argento');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataArgentoSalesSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Argento Sales Consultant Argento' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
           
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataArgentoSalesSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataArgentoSalesSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataArgentoSmileSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Argento_Smile');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataArgentoSmileSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Argento Smile' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
         
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataArgentoSmileSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataArgentoSmileSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }
    
    @IsTest 
    public static void testBatchWithOrgDataArgentoStanloverSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Argento_Stanlover');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataArgentoStanloverSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Argento Stanlover' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
           
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataArgentoStanloverSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataArgentoStanloverSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataOroSalesSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Oro');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataOroSalesSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Oro Sales Consultant Oro' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
           
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataOroSalesSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataOroSalesSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataOroSmileSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Oro_Smile');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataOroSmileSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Oro Smile' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
                                          
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataOroSmileSegment - contactCheckList.size] ' + contactCheckList.size());                                          
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataOroSmileSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataOroStanloverSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Oro_Stanlover');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataOroStanloverSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Oro Stanlover' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];

        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataOroStanloverSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataOroStanloverSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataPlatinoSalesSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Platinium');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataPlatinoSalesSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Platino Sales Consultant Platino' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
 
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataPlatinoSalesSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataPlatinoSalesSegment - DealerSenioritymdt] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataPlatinoSmileSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Platinium_Smile');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataPlatinoSmileSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Platino Smile' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
          
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataPlatinoSmileSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataPlatinoSmileSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataPlatinoStanloverSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Platinium_Stanlover');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataPlatinoStanloverSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Platino Stanlover' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
                                           
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataPlatinoStanloverSegment - contactCheckList.size] ' + contactCheckList.size());                                   
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataPlatinoStanloverSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataSuperstarSalesSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Superstar');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataSuperstarSalesSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Superstar Sales Consultant Superstar' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
         
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataSuperstarSalesSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataSuperstarSalesSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataSuperstarSmileSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Superstar_Smile');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Superstar Smile' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
                                           
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }

    @IsTest 
    public static void testBatchWithOrgDataSuperstarStanloverSegment(){
        //getting segment metadata
        DealerSeniority__mdt mdt = DealerSeniority__mdt.getInstance('Superstar_Stanlover');
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSegment - DealerSenioritymdt] ' + mdt);


        //check start batch query 
        List<Contact> contactCheckList = [ SELECT Id, Name , Email,  MobilePhone , Tech_Sinch_Field__c , DealerSenioritySegment__c, SalesSegment__c , Tech_Pardot_Send_SMS__c  
                                           FROM Contact 
                                           WHERE  Tech_Sinch_Field__c = 'Superstar Stanlover' AND MobilePhone != '' AND TECH_ExternalId__c like '%ITA%' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false AND LU_Available_for_Pardot__c = 1 AND Tech_Pardot_Send_SMS__c = true ];
                                           
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSegment - contactCheckList.size] ' + contactCheckList.size());
        System.debug('[BA02_SendSMS_ToSinch_TestGP - testBatchWithOrgDataBronzoSegment - contactCheckList] ' + contactCheckList);

        Test.startTest();
        BA02_SendSMS_ToSinch smsBatch = new BA02_SendSMS_ToSinch(new List<String>{mdt.SegmentName__c});
        Database.executeBatch(smsBatch, 100 );
        Test.stopTest();

    }
}