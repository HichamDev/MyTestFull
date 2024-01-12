@IsTest
public class AP1003_Utils_Contact_Test {

    @IsTest
    static void test_ITA_LEVEL5() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'ITA_00009999';
        insert u;

        Contact c = [SELECT Id, Title, AccountId, Account.Type FROM Contact WHERE Id = :u.ContactId];
        c.Title = 'Diretore de filiale';
        update c;
        Account acc = new Account(Id = c.AccountId, Type = 'LEVEL5');
        update acc;

        Map<String, List<String>> m_filters = new Map<String, List<String>>();

        m_filters.put('active', new List<String>());
        m_filters.get('active').add('active');

        m_filters.put('inactive', new List<String>());
        m_filters.get('inactive').add(
            System.now().year() + '-' + 
            ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
            ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
            ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
            ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
            ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
        );
        
        System.RunAs(u){
            
            c = AP1003_Utils_Contact.getContactInfo(u.ContactId);
            User u2 = AP1003_Utils_Contact.getContactUserAssociated(u.ContactId);

            List<Account> l_acc = AP1003_Utils_Contact.searchManagerTeamAccount(u, c);

            l_acc = AP1003_Utils_Contact.checkParentIdOnChildCaseSensitive(l_acc, new Set<String>());

            u = [SELECT Id, TECH_MergeContactID__c FROM User WHERE Id = :u.Id];

            List<Contact> l_con = AP1003_Utils_Contact.searchMyTeam(u, JSON.serialize(m_filters), 'LastName', 'ASC');

            l_con = AP1003_Utils_Contact.searchMyCustomers(u, JSON.serialize(m_filters), 'LastName', 'ASC');
            
            Id idManager = AP1003_Utils_Contact.getDirectManagerContactid(c);
            
            Map<Id, Date> m = AP1003_Utils_Contact.getContactsLastOrderDate(l_con);
        }
    }

    @IsTest
    static void test_FRA_LEVEL3() {
        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        Contact c = [SELECT Id, Title, AccountId, Account.Type FROM Contact WHERE Id = :u.ContactId];
        c.Title = 'ANIMATRICE DE SECTEUR';
        update c;
        Account parentAccount = new Account(
            Name = 'TestAccount_LEVEL1',
            TECH_ACCOwnerExternalId__c = '3334',
            Country_Code__c = 'FRA'
        );
        insert parentAccount;
        Account acc = new Account(Id = c.AccountId, Type = 'LEVEL3', ParentId = parentAccount.Id);
        update acc;

        Map<String, List<String>> m_filters = new Map<String, List<String>>();

        m_filters.put('active', new List<String>());
        m_filters.get('active').add('active');

        m_filters.put('inactive', new List<String>());
        m_filters.get('inactive').add(
            System.now().year() + '-' + 
            ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
            ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
            ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
            ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
            ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
        );
        
        System.RunAs(u){
            
            c = AP1003_Utils_Contact.getContactInfo(u.ContactId);
            User u2 = AP1003_Utils_Contact.getContactUserAssociated(u.ContactId);

            List<Account> l_acc = AP1003_Utils_Contact.searchManagerTeamAccount(u, c);

            l_acc = AP1003_Utils_Contact.checkParentIdOnChildCaseSensitive(l_acc, new Set<String>());

            u = [SELECT Id, TECH_MergeContactID__c FROM User WHERE Id = :u.Id];

            List<Contact> l_con = AP1003_Utils_Contact.searchMyTeam(u, JSON.serialize(m_filters), 'LastName', 'ASC');

            l_con = AP1003_Utils_Contact.searchMyCustomers(u, JSON.serialize(m_filters), 'LastName', 'ASC');
        }
    }
}


// @IsTest
// public class AP1003_Utils_Contact_Test {

//     @IsTest
//     static void testGetFiltersInactiveITA() {
//         User u = AP01_TestDataFactory.createPortalUser();
//         u.TECH_ExternalId__c = 'ITA_00009999';
//         insert u;

//         Contact c = [SELECT Id, Title, Account.Type FROM Contact WHERE Id = :u.ContactId];
//         c.Title = 'ANIMATRICE DE SECTEUR';
//         update c;

//         Map<String, List<String>> m_filters = new Map<String, List<String>>();

//         m_filters.put('active', new List<String>());
//         m_filters.get('active').add('active');

//         m_filters.put('inactive', new List<String>());
//         m_filters.get('inactive').add(
//             System.now().year() + '-' + 
//             ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
//             ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
//             ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
//             ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
//             ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
//         );
        
//         System.RunAs(u){
            
//             c = AP1003_Utils_Contact.getContactInfo(u.ContactId);
//             User u2 = AP1003_Utils_Contact.getContactUserAssociated(u.ContactId);

//             List<Account> l_acc = AP1003_Utils_Contact.searchManagerTeamAccount(u, c);

//             l_acc = AP1003_Utils_Contact.checkParentIdOnChildCaseSensitive(l_acc, new Set<String>());

//             u = [SELECT Id, TECH_MergeContactID__c FROM User WHERE Id = :u.Id];

//             List<Contact> l_con = AP1003_Utils_Contact.searchMyTeam(u, JSON.serialize(m_filters), 'LastName', 'ASC');

//             l_con = AP1003_Utils_Contact.searchMyCustomers(u, JSON.serialize(m_filters), 'LastName', 'ASC');
//         }
//     }
// }