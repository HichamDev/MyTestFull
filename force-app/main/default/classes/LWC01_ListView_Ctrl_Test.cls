@IsTest
public class LWC01_ListView_Ctrl_Test {

    @IsTest
    static void testGetContactList() {
        String userId = AP01_TestDataFactory.createPortalUserWithClients();

        User u = [SELECT Id FROM User WHERE Id = :userId];

        LWC01_ListView_Ctrl.getContactConnected();

        Map<String, List<String>> m_filters = new Map<String, List<String>>();

        m_filters.put('active', new List<String>());
        m_filters.get('active').add('active');

        // m_filters.put('inactive', new List<String>());
        // m_filters.get('inactive').add('oneY');

        m_filters.put('effectifDormant', new List<String>());
        m_filters.get('effectifDormant').add('4;6');
        m_filters.get('effectifDormant').add('7;10');
        m_filters.get('effectifDormant').add('10;11');
        m_filters.get('effectifDormant').add('oneY');

        m_filters.put('inactive6weeks', new List<String>());
        m_filters.get('inactive6weeks').add(
            System.now().year() + '-' + 
            ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
            ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
            ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
            ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
            ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
            + ';' +
            System.now().year() + '-' + 
            ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
            ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
            ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
            ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
            ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
        );

        m_filters.put('inactiveITA', new List<String>());
        m_filters.get('inactiveITA').add(
            System.now().year() + '-' + 
            ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
            ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
            ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
            ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
            ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
            + ';' +
            System.now().year() + '-' + 
            ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
            ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
            ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
            ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
            ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
        );

        m_filters.put('baddept', new List<String>());
        m_filters.get('baddept').add('true');

        m_filters.put('segmentation', new List<String>());
        m_filters.get('segmentation').add('Topazio');

        m_filters.put('focusOnNewUsers', new List<String>());
        m_filters.get('focusOnNewUsers').add('Codificate');

        m_filters.put('segmentation2', new List<String>());
        m_filters.get('segmentation2').add('DF');
        m_filters.get('segmentation2').add('Capogruppo');
        m_filters.put('seniorSegmentation', new List<String>());
        m_filters.get('seniorSegmentation').add('Nuova');

        m_filters.put('newCoach', new List<String>());
        m_filters.get('newCoach').add('AUTO ENREGISTREMENT');

        m_filters.put('source', new List<String>());
        m_filters.get('source').add('Personnel');

        m_filters.put('typo', new List<String>());
        m_filters.get('typo').add('Coach');
        m_filters.get('typo').add('Leader 35');


        m_filters.put('contacttype', new List<String>());
        m_filters.get('contacttype').add('ZM_DD');

        System.runAs(u){
            LWC01_ListView_Ctrl.getContactList(userId, 'My contacts', '', 'LastName', 'ASC', '');
            LWC01_ListView_Ctrl.getContactList(userId, 'My Team', JSON.serialize(m_filters), 'LastName', 'ASC', '');
            LWC01_ListView_Ctrl.getUserCountry();
        }

        m_filters.put('active', new List<String>());
        m_filters.get('active').add('inactive');

        m_filters.put('inactive', new List<String>());
        m_filters.get('inactive').add(
            System.now().year() + '-' + 
            ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
            ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
            ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
            ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
            ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
            + ';' +
            System.now().year() + '-' + 
            ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
            ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
            ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
            ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
            ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
        );

        m_filters.put('segmentation', new List<String>());
        m_filters.get('segmentation').add('Smile');

        m_filters.put('focusOnNewUsers', new List<String>());
        m_filters.get('focusOnNewUsers').add('Nuova');

        m_filters.put('contacttype', new List<String>());
        m_filters.get('contacttype').add('LDS');

        System.runAs(u){
            LWC01_ListView_Ctrl.getContactList(userId, 'My Team', JSON.serialize(m_filters), 'ActivitySegment__c', 'ASC', '');
        }

        m_filters.put('segmentation', new List<String>());
        m_filters.get('segmentation').add('Nouveau < 1 an');

        m_filters.put('contacttype', new List<String>());
        m_filters.get('contacttype').add('Leader');

        System.runAs(u){
            LWC01_ListView_Ctrl.getContactList(userId, 'My Team', JSON.serialize(m_filters), 'ActivitySegment__c', 'ASC', '');
        }

        m_filters.put('segmentation', new List<String>());
        m_filters.get('segmentation').add('Nouveau < 6 mois');

        m_filters.put('contacttype', new List<String>());
        m_filters.get('contacttype').add('Inactif du cycle');

        System.runAs(u){
            LWC01_ListView_Ctrl.getContactList(userId, 'My Team', JSON.serialize(m_filters), 'ActivitySegment__c', 'ASC', '');
        }

        m_filters.put('postalCode', new List<String>());
        m_filters.get('postalCode').add('44');

        System.runAs(u){
            LWC01_ListView_Ctrl.getContactList(userId, 'My Team', JSON.serialize(m_filters), 'ActivitySegment__c', 'ASC', '');
        }

        m_filters.put('resigned', new List<String>());
        m_filters.get('resigned').add('Label.LU_ListViewFilters_NonResigned');

        System.runAs(u){
            LWC01_ListView_Ctrl.getContactList(userId, 'My Team', JSON.serialize(m_filters), 'ActivitySegment__c', 'ASC', '');
        }

        m_filters.put('lastCycleRevenues', new List<String>());
        m_filters.get('lastCycleRevenues').add('1');

        m_filters.put('dealerManagerSermentation', new List<String>());
        m_filters.get('dealerManagerSermentation').add(Label.LU_Dealer_Manager_Seg_Zero);

        System.runAs(u){
            LWC01_ListView_Ctrl.getContactList(userId, 'My Team', JSON.serialize(m_filters), 'ActivitySegment__c', 'ASC', '');
        }

        m_filters.put('dealerManagerSermentationITA', new List<String>());
        m_filters.get('dealerManagerSermentationITA').add(Label.LU_Dealer_Manager_Seg_Zero);

        System.runAs(u){
            Test.startTest();
            LWC01_ListView_Ctrl.getContactList(userId, 'My Team', JSON.serialize(m_filters), 'ActivitySegment__c', 'ASC', '');
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetContactListMinMaxAmount() {

        String userId = AP01_TestDataFactory.createPortalUserWithClients();

        User u = [SELECT Id FROM User WHERE Id = :userId];

        Map<String, List<String>> m_filters = new Map<String, List<String>>();

        m_filters.put('searchedAmountMin', new List<String>());
        m_filters.get('searchedAmountMin').add('0');

        m_filters.put('searchedAmountMax', new List<String>());
        m_filters.get('searchedAmountMax').add('1000000');

        m_filters.put('attivitaIn', new List<String>());
        m_filters.get('attivitaIn').add(
            System.now().year() + '-' + 
            ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
            ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
            ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
            ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
            ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
            + ';' +
            System.now().year() + '-' + 
            ( System.now().month() < 10 ? '0' + System.now().month() : '' + System.now().month() ) + '-' + 
            ( System.now().day() < 10 ? '0' + System.now().day() : '' + System.now().day() ) + 'T' + 
            ( System.now().hour() < 10 ? '0' + System.now().hour() : '' + System.now().hour() ) + ':' + 
            ( System.now().minute() < 10 ? '0' + System.now().minute() : '' + System.now().minute() ) + ':' + 
            ( System.now().second() < 10 ? '0' + System.now().second() : '' + System.now().second() ) +'Z'
        );

        System.runAs(u){
            List<Contact> lcontacts = LWC01_ListView_Ctrl.getContactList(userId, 'My Team', JSON.serialize(m_filters), 'ActivitySegment__c', 'ASC', '');
            List<String> l_contactIdsToRemove = new List<String>();
            for( Contact con : lcontacts){
                l_contactIdsToRemove.add((String)con.Id);
            }
            LWC01_ListView_Ctrl.removeContacts(lcontacts, l_contactIdsToRemove);
        }
    }
}