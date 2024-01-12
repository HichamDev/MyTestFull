@isTest
private class VFC01_PersonalContactListView_TEST {
/*
----------------------------------------------------------------------
-- - Name          : VFC01_PersonalContactListView
-- - Author        : 
-- - Description   : This class contains unit tests for validating the 
--                   behavior of controller VFC01_PersonalContactListView
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 10-FEB-2013         1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/
 	 static List<Account> accountList;
     static List<Contact> contactList;
     static List<User> userList;
     static List<ART_Article__c> articleList;
     static List<KIT_Kit__c> kitList;
     static List<CAT_Catalog__c> catalogueList;
     static List<CTA_CatalogArticle__c> catArticleList;
     static Id contactDealerRecordTypeID, DealerProfileId, offerRecordTypeID, bundleRecordTypeID, productRecordTypeID;
     static Id chequeRecordTypeID;
    
     static {
        System.Debug('## >>>>> Start VFC01_PersonalContactListView >>> Inserting Data for Tests <<<<<'+UserInfo.getUserName());
        
        //Retrieving Record Type related to Contact
        contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
        system.debug('>>>>>> contactDealerRecordTypeID : ' + contactDealerRecordTypeID);
        
        //Retrieving Record Type related to Article
        
        //Statement of Type=Cheque
         chequeRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = 'Cheque' and SObjectType = 'STA_Statement__c' Limit 1].id;
        //Offer
        offerRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00001 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Bundle
        bundleRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00002 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        //Product
        productRecordTypeID = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.ART00003 and SObjectType = 'ART_Article__c' Limit 1].id;
        
        
        //Retrieving Profile Ids
        DealerProfileId = [select id from Profile where Name= :system.label.CON00001].Id;
        system.debug('>>>>>> DealerProfileId : ' + DealerProfileId);
        
        //Creating new accounts
        accountList = new List<Account>{
            new Account(Name='AccountTest1'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test1'
                        , Country_Code__c = 'FRA'),
            new Account(Name='AccountTest2'
                        , AccountType__c = 'Level 2'
                        , TypeLabel__c = 'Test2'
                        , Country_Code__c = 'FRA')
        };
        insert (accountList);
        system.debug('>>>>>> accountList : ' + accountList);
        
        //Creating new contacts
        contactList = new List<Contact>{
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest1'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test1.com'
                        , AccountId = accountList[0].id
                        , CurrentBalance__c = 100
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , ActivityStatus__c = true
                        , AllowedPaymentMode__c='Cheque'
                        ,STHID__c = 'Test12234'),
            new Contact(RecordTypeId = contactDealerRecordTypeID
                        , LastName = 'ContactTest2'
                        , Birthdate = system.Today() - 3650
                        , email = 'a@test2.com'
                        , AccountId = accountList[1].id
                        , CurrentBalance__c = -5
                        , MinOrder__c=50
                        , MinOrderFreeTransportFees__c=50
                        , ActivityStatus__c = true
                        ,STHID__c = 'Test12235'
                        )         
        };
        insert (contactList);
        system.debug('>>>>>> contactList : ' + contactList);
        
        //Creating new users
        userList = new List<User>{
            new User(Username ='testemail1@test.com'
                     , LastName = 'TestLastName1'
                     , Email = 'TestEmail1@test.com'
                     , alias = 'testAl1'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , ContactId = contactList[0].Id),
            new User(Username ='testemail2@test.com'
                     , LastName = 'TestLastName1'
                     , Email = 'TestEmail2@test.com'
                     , alias = 'testAl2'
                     , TimeZoneSidKey = 'America/New_York'
                     , EmailEncodingKey = 'ISO-8859-1'
                     , ProfileId = DealerProfileId
                     , LanguageLocaleKey = 'en_US'
                     , Localesidkey='en_US'
                     , ContactId = contactList[1].Id)        
        };
        insert (userList);
        system.debug('>>>>>> userList : ' + userList);
    }
        
    static testMethod void personalContactTest() {
        System.Debug('## >>>>> Start VFC01_PersonalContactListView - <<<<<'+UserInfo.getUserName());
      
         system.runAs(userList[0]){
           system.debug('>>>>>> userList[0].LastName: ' + userList[0].LastName);
           List<PCT_PersonalContact__c> personalContactList = new List<PCT_PersonalContact__c>{
             new PCT_PersonalContact__c(
	          Salutation__c='M.'
             , FirstName__c='TEST first name'
             , Name='TEST last name'
             , Phone__c='1234567'
             , PersonalCity__c= 'Test Personal City'
             ,PersonalCountry__c='France'
           )
           };
        insert(personalContactList);
        
        CountryCode_Name__c countryCodeNameMapping = new CountryCode_Name__c();
        countryCodeNameMapping.Name='FRA';
        countryCodeNameMapping.CountryName__c='France';
        insert(countryCodeNameMapping);
        test.startTest();
            PageReference personalContactListPage = Page.VFP01_PersonalContactListView;
            Test.setCurrentPage( personalContactListPage );
            
            ApexPages.StandardSetController ssc = new ApexPages.Standardsetcontroller(personalContactList);
            VFC01_PersonalContactListView ord = new VFC01_PersonalContactListView();
            ord.contactCountryCode='FRA';
            ord.personalContactSet = null;
            
            ord.getPersonalContact();
            ord.getNumberCurrencyFormat();
            ord.getFieldLabel(new list<string>{'Customer__c','Customer_prospect__c','Dealer_prospect__c','Competitive_dealer__c','Hostess__c','Hostess_prospect__c','OtherPersonalContactType__c','Competitive_hostess__c'});
            list<string> theOptions= new list<string>{'#1#','#2#','#3#','#4#','#5#','#6#','#7#','#8#','#9#','#10#','#11#','#12#','#13#','#14#','#15#','#16#'};
            for(string option : theOptions){
            	ord.generateQuery(option);
            }
            ord.refreshPagePC();
         test.stopTest();
         }
    }
}