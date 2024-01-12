public class AP01_TestDataFactory {

    /* CONSTANTS */
    // public final String ITA_PRODUCT_SIMPLE_1_NAME = 'ITASimple1';
    // public final String ITA_PRODUCT_SIMPLE_1_LOCALCODE = '101';
    // public final String ITA_PRODUCT_SIMPLE_2_NAME = 'ITASimple2';
    // public final String ITA_PRODUCT_SIMPLE_2_LOCALCODE = '102';


    public static User createPortalUser(){
        
        Profile p = [select Id,name from Profile where Name = 'FRA_Leader' limit 1];
        
        Account portalAccount1 = new Account(
            Name = 'TestAccount',
            TECH_ACCOwnerExternalId__c = '123456',
            Country_Code__c = 'FRA'
        );
        Database.insert(portalAccount1);

        Contact contact1 = new Contact(
            LastName = 'Jibz 1',
            firstName = 'Test',
            Birthdate = system.today(),
            email = 'jibz1@mail.com',
            Contact_Type__c='Leader',
            accountid = portalAccount1.id,
            TECH_ExternalId__c = '123456',
            MinOrderFreeTransportFees__c = 10.50,
            STHID__c = '9898',
            ActivityStatus__c = true,
            Title = 'Leader'
        );
        Database.insert(contact1); 

        User newUser = new User(
            profileId = p.id,
            username = 'newPortalUser@yahoo.com',
            email = 'pb@ff.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'fr_FR',
            languagelocalekey = 'fr',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            ContactId = contact1.Id
        );

        return newUser;
    }

    public static Id createPortalUserWithClients(){
        Account portalAccount1 = new Account(
            Name = 'TestAccount',
            TECH_ACCOwnerExternalId__c = '123456'
        );
        Database.insert(portalAccount1);
      
        //Create contact for the account, which will enable partner portal for account
        Contact contact1 = new Contact(
            LastName = 'Jibz 1'
                           ,firstName = 'Test'
                           ,Birthdate = system.today()
                           ,email = 'jibz1@mail.com'
                           ,Contact_Type__c='Leader'
                           ,accountid = portalAccount1.id
                           ,TECH_ExternalId__c = '123456'
                           ,MinOrderFreeTransportFees__c = 10.50
                           ,STHID__c = '9898'
            				,ActivityStatus__c = true
        );
        Database.insert(contact1); 
        
        //Create user for the contact
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'FRA_Leader' Limit 1];
        User user1 = new User(
            Username = 'test12345test@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TECH_ExternalId__c = 'FRA_1234567890'
        );
        Database.insert(user1); 
        
        List<Contact> childContactList = new list<contact>{
            new Contact(LastName = 'Jibz 2'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz2@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 111.50
                        ,STHID__c = '8888'
                        ,TECH_ExternalId__c = '9879'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true
                    )

            ,new Contact(LastName = 'Jibz 3'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz3@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 150.20
                        ,STHID__c = '7777'
                        ,TECH_ExternalId__c = '4567'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true)
        };
        insert childContactList;

        List<Contact> colleagueContactList = new list<contact>{
            new Contact(LastName = 'Jibz 4'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz4@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 111.50
                        ,STHID__c = '6666'
                        ,TECH_ExternalId__c = '66666'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true
                    )

            ,new Contact(LastName = 'Jibz 5'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz5@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 150.20
                        ,STHID__c = '5555'
                        ,TECH_ExternalId__c = '55555'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true)
        };
        insert colleagueContactList;

        return user1.Id;
    }


    /* Create a manager with title in parameter for the country in parameter */
    public static Id createCommunityManagerWithTeam(String countryCode, String titleManager, String contactType, String profileName, String successBearing) {
        Account portalAccount1 = new Account(
            Name = 'TestAccount',
            TECH_ACCOwnerExternalId__c = '123456',
            Country_Code__c = countryCode
        );
        Database.insert(portalAccount1);
      
        //Create contact for the account, which will enable partner portal for account
        Contact contact1 = new Contact(
            LastName = 'Jibz 1'
            ,firstName = 'Test'
            ,Birthdate = system.today()
            ,email = 'jibz1@mail.com'
            ,Contact_Type__c= contactType
            ,accountid = portalAccount1.id
            ,TECH_ExternalId__c = (countryCode == 'FRA' ? 'FRA_123456' : 'ITA_123456')
            ,MinOrderFreeTransportFees__c = 10.50
            ,STHID__c = '9898'
            ,ActivityStatus__c = true
            ,Success_Bearing__c = successBearing
            ,Title = titleManager
        );
        Database.insert(contact1); 
        
        //Create user for the contact
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name =: profileName Limit 1];
        User user1 = new User(
            Username = 'test12345test@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TECH_ExternalId__c = (countryCode == 'FRA' ? 'FRA_1234567890' : 'ITA_1234567890')
        );
        Database.insert(user1); 
        
        List<Contact> childContactList = new list<contact>{
            new Contact(LastName = 'Jibz 2'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz2@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 111.50
                        ,STHID__c = '8888'
                        ,TECH_ExternalId__c = '9879'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true
                    )

            ,new Contact(LastName = 'Jibz 3'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz3@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 150.20
                        ,STHID__c = '7777'
                        ,TECH_ExternalId__c = '4567'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true)
        };
        insert childContactList;

        List<Contact> colleagueContactList = new list<contact>{
            new Contact(LastName = 'Jibz 4'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz4@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 111.50
                        ,STHID__c = '6666'
                        ,TECH_ExternalId__c = '66666'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true
                    )

            ,new Contact(LastName = 'Jibz 5'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz5@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 150.20
                        ,STHID__c = '5555'
                        ,TECH_ExternalId__c = '55555'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true)
        };
        insert colleagueContactList;

        return user1.Id;
    }

    /* Create a manager with title in parameter for the country in parameter for new order tunnel */
    public static Id createCommunityManagerWithTeamNewOrderTunnel(String countryCode, String titleManager, String contactType, String profileName, String successBearing) {
        Account portalAccount1 = new Account(
            Name = 'TestAccount',
            TECH_ACCOwnerExternalId__c = '123456',
            Country_Code__c = countryCode
        );
        Database.insert(portalAccount1);
      
        //Create contact for the account, which will enable partner portal for account
        Contact contact1 = new Contact(
            LastName = 'Jibz 1'
            ,firstName = 'Test'
            ,Birthdate = system.today()
            ,email = 'jibz1@mail.com'
            ,Contact_Type__c= contactType
            ,accountid = portalAccount1.id
            ,TECH_ExternalId__c = (countryCode == 'FRA' ? 'FRA_123456' : 'ITA_123456')
            ,MinOrderFreeTransportFees__c = 10.50
            ,STHID__c = '9898'
            ,ActivityStatus__c = true
            ,Success_Bearing__c = successBearing
            ,Title = titleManager
        );
        Database.insert(contact1); 
        
        //Create user for the contact
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name =: profileName Limit 1];
        User user1 = new User(
            Username = 'test12345test@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TECH_ExternalId__c = (countryCode == 'FRA' ? 'FRA_1234567890' : 'ITA_1234567890'),
            LU_Use_New_Order_v2__c = true
        );
        Database.insert(user1); 
        
        List<Contact> childContactList = new list<contact>{
            new Contact(LastName = 'Jibz 2'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz2@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 111.50
                        ,STHID__c = '8888'
                        ,TECH_ExternalId__c = '9879'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true
                    )

            ,new Contact(LastName = 'Jibz 3'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz3@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 150.20
                        ,STHID__c = '7777'
                        ,TECH_ExternalId__c = '4567'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true)
        };
        insert childContactList;

        List<Contact> colleagueContactList = new list<contact>{
            new Contact(LastName = 'Jibz 4'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz4@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 111.50
                        ,STHID__c = '6666'
                        ,TECH_ExternalId__c = '66666'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true
                    )

            ,new Contact(LastName = 'Jibz 5'
                        ,firstName = 'Test'
                        ,Birthdate = system.today()
                        ,email = 'jibz5@mail.com'
                        ,Contact_Type__c = 'Leader'
                        ,MinOrderFreeTransportFees__c = 150.20
                        ,STHID__c = '5555'
                        ,TECH_ExternalId__c = '55555'
                        ,Parent_STH_Id__c = contact1.id
                        ,ActivityStatus__c = true)
        };
        insert colleagueContactList;

        return user1.Id;
    }

    // Get simple contact
    public static Contact getContact(String pName, String pRtId){
        return new Contact(LastName = pName, RecordTypeId = pRtId);
    }


    /*****  OFFERS ******/
    /* OFFERS : GENERAL METHODS */
    // public static void generateOffers() {
        
    //     generateOffersForFrance();
    //     /* ITALY */
    //     // Pricebook
    //     // Pricebook2 pbIta = createPricebookByCountry('ITA', 'Pricebook Italy TEST', Datetime.now().addDays(-1), Datetime.now().addDays(5));
    //     // insert pbIta;

    //     // Product
    //     // List<Product2> lProductIta = createProductsByCountry(pbIta);
    //     // insert lProductIta;   
    // }

    /* OFFERS : OFFERS FOR FRANCE FROM CSV FILE IN STATIC RESOURCES */
    // public static void generateOffersForFrance() {
    //     // Load Pricebook CSV File
    //     List<sObject> lPricebook = Test.loadData(Pricebook2.sObjectType, 'TESTDATA_FRANCE_Pricebook');
    //     system.debug('>>>> lPricebook');
    //     system.debug(lPricebook);

    // }

    /* OFFERS : UTILITY METHODS */
    // public static Pricebook2 createPricebookByCountry(String countryCode, String name, Datetime startDate, Datetime endEndate) {
    //     Pricebook2 pb = new Pricebook2();
    //     pb.IsActive = true;
    //     pb.Name = name;
    //     pb.LU_Start_Date__c = startDate;
    //     pb.LU_End_date__c = endDate;
    //     pb.LU_Tech_External_Id__c = countryCode + '_' + name; 
    // }

    // public static List<Product2> createProductsByCountry(Pricebook2 pb, Set<String> productTypes) {
    //     List<Product2> lProducts = new List<Product2>();

    //     // Get RecordType ids
    //     List<RecordType> lRtProduct = [SELECT Id, DeveloperName FROM RecordType WHERE Sobjecttype = 'Product2' AND isActive = true];

    //     // Simple Products
    //     Product2 pSimple1 = new Product2();
    //     pSimple1.Name = ITA_PRODUCT_SIMPLE_1_NAME;
    //     pSimple1.LU_Local_Name__c = ITA_PRODUCT_SIMPLE_1_NAME;
    //     pSimple1.LU_Local_Code__c = ITA_PRODUCT_SIMPLE_1_LOCALCODE;
    //     pSimple1.RecordType = getRecordTypeIdByDeveloperName('LU_Product', lRtProduct);
    //     pSimple1.IsActive = true;

    //     Product2 pSimple2 = new Product2();
    //     pSimple2.Name = ITA_PRODUCT_SIMPLE_2_NAME;
    //     pSimple2.LU_Local_Name__c = ITA_PRODUCT_SIMPLE_2_NAME;
    //     pSimple2.LU_Local_Code__c = ITA_PRODUCT_SIMPLE_2_LOCALCODE;
    //     pSimple2.RecordType = getRecordTypeIdByDeveloperName('LU_Product', lRtProduct);
    //     pSimple2.IsActive = true;
    // }


    // public static Id getRecordTypeIdByDeveloperName(String rtDevName, List<RecordType> lRts) {
    //     Id rtId = null;
    //     for (RecordType rt : lRts) {
    //         if (rt.DeveloperName == rtDevName) {
    //             rtId = rt.Id; break;
    //         }
    //     }
    //     return (rtId);
    // }
}