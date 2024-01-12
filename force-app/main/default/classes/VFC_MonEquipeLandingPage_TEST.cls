@isTest
private class VFC_MonEquipeLandingPage_TEST {
/*
----------------------------------------------------------------------
-- - Name          : VFC_MonEquipeLandingPage_TEST 
-- - Author        : 
-- - Description   : This class contains unit tests for validating the 
--                   behavior of controller 
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 06-APR-2014   NAK     1.0      Initial version                           
----------------------------------------------------------------------
*/
    static user mainUser;
    static list <Account> acctList;
    static list <Contact> contactList;
    static list <Contact> childContactList;

    static{
        mainUser = new User(Username = 'MonEquipeLanding@test.com'
                           ,LastName = 'testuserInsert'
                           ,LanguageLocaleKey = 'en_US'
                           ,FirstName = 'test'
                           ,Email = 'test@test.com'
                           ,Alias = 'XXX'
                           ,TimeZoneSidKey = 'Europe/Dublin'
                           ,LocaleSidKey = 'en_US'
                           ,IsActive = true
                           ,EmailEncodingKey = 'UTF-8'
                           ,ProfileId = UserInfo.getProfileId()
                           ,TECH_ExternalId__c = '123456');
        insert mainUser;

        System.runAs(mainUser){

            acctList = new list<Account>{
                new Account(Name = 'Acc 1'
                           ,TECH_ACCOwnerExternalId__c = '123456')
            };
            insert acctList;

            contactList = new list<contact>{
                new Contact(LastName = 'Jibz 1'
                           ,firstName = 'Test'
                           ,Birthdate = system.today()
                           ,email = 'jibz1@gmail.com'
                           ,Contact_Type__c='Leader'
                           ,accountid = acctList[0].id
                           ,TECH_ExternalId__c = '123456'
                           ,MinOrderFreeTransportFees__c = 10.50
                           ,STHID__c = '9898')};
            insert contactList;

            childContactList = new list<contact>{
               new Contact(LastName = 'Jibz 2'
                           ,firstName = 'Test'
                           ,Birthdate = system.today()
                           ,email = 'jibz2@gmail.com'
                           ,Contact_Type__c = 'Leader'
                           ,MinOrderFreeTransportFees__c = 111.50
                           ,STHID__c = '8888'
                           ,TECH_ExternalId__c = '9879'
                           ,Parent_STH_Id__c = contactList[0].id)

               ,new Contact(LastName = 'Jibz 3'
                           ,firstName = 'Test'
                           ,Birthdate = system.today()
                           ,email = 'jibz3@gmail.com'
                           ,Contact_Type__c = 'Leader'
                           ,MinOrderFreeTransportFees__c = 150.20
                           ,STHID__c = '7777'
                           ,TECH_ExternalId__c = '4567'
                           ,Parent_STH_Id__c = contactList[0].id)
            };
            insert childContactList;

        }
    }
    
    @isTest 
    static void monEquipe_Test() {
        System.runAs(mainUser) {
            Test.setCurrentPage(Page.VFP_MonEquipeLandingPage);
            test.startTest();
                VFC_MonEquipeLandingPage controller = new VFC_MonEquipeLandingPage();
                controller.getContactCoachs();
                controller.isPortal = true;
                controller.coachParentName = contactList[0].Name;
                controller.contactParent = contactList[0].Id;
                controller.contactId = contactList[0].id;
                controller.contactFirstName = contactList[0].firstName;
                controller.contactLastName = contactList[0].lastName;
                controller.contactName = contactList[0].name;
                controller.theCoachContactList  = childContactList;
                controller.reportsToId = childContactList;
                controller.refreshPageMyNetwork();
            test.stopTest();
        }

    }
}