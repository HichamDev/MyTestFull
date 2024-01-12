public without sharing class lwc46_homepage_reminders_ctrl {

    static final String LOGO_NEXTEVENT = Label.LU_Reminder_Agenda;
    static final String LOGO_COMMUNICATION = Label.LU_Reminder_Com;
    static final String LOGO_INACTIVEMEMBER = Label.LU_Reminder_Inactive;
    static final String LOGO_INACTIVECLIENTS = Label.LU_Reminder_Inactive;
    static final String LOGO_BIRTHDAY = Label.LU_Reminder_Birthday;
    static final String LOGO_BADDEPT = Label.LU_Reminder_BadDept;
    static final String LOGO_ISLASTWEEK = Label.LU_Reminder_IsLastWeek;

    @AuraEnabled
    public static List<AP1006_Reminder> getReminders() {

        String country = AP1002_Utils_User.getUserCountry(UserInfo.getUserId());

        // Get current user
        User u = [SELECT Id, LU_Use_New_Order_v2__c FROM User WHERE Id =: UserInfo.getUserId() ];
        // Get current contact
        Contact c = AP1002_Utils_User.getContactFromUser(u.Id);

        List<AP1006_Reminder> l_reminder = new List<AP1006_Reminder>();

        if(country == 'ITA'){
            
            l_reminder.addAll( getNextEvent() );
            // l_reminder.addAll( getCommunication() );
            l_reminder.addAll( getInactivTeamMembers(u) );
            // Remove for the minor release of the 13/05/2020
            //l_reminder.addAll( getBirthday() );
            
        } else if(country == 'FRA') {

            // l_reminder.addAll( getNextEvent() );
            // l_reminder.addAll( getCommunication() );
            l_reminder.addAll( getInactivTeamMembers(u) );
            // if (u.LU_Use_New_Order_v2__c) {
            //     l_reminder.addAll( getInactivClients() );
            // }
            l_reminder.addAll( getBirthday() );

            // Display BadDept only for top manager
            if (c.LU_TECH_Top_Manager__c) {
                l_reminder.addAll( getBadDept() );
                l_reminder.addAll( getImpaye() );
            }
            
            l_reminder.addAll( getIsLastWeekCycle() );
        }

        return l_reminder;
    }

    @AuraEnabled(cacheable=true)
    public static List<AP1006_Reminder> getNextEvent() {

        Id userId = UserInfo.getUserId();

        User u = [SELECT Id, TECH_MergeContactID__c FROM User WHERE Id =: userId];

        List<AP1006_Reminder> l_reminder = new List<AP1006_Reminder>();

        for(Event e : [SELECT Subject, StartDateTime 
                         FROM Event 
                        WHERE OwnerId = :userId
                          AND StartDateTime > :System.now() ]){
            l_reminder.add(new AP1006_Reminder(LOGO_NEXTEVENT, Label.LU_Reminder_Event_Title, e.Subject));
        }

        for (AGI_AgendaItem__c e : [SELECT Name, Start__c
                                    FROM AGI_AgendaItem__c
                                    WHERE TECH_Contact__c =: u.TECH_MergeContactID__c
                                    AND Start__c >: System.now()]) {
            l_reminder.add(new AP1006_Reminder(LOGO_NEXTEVENT, Label.LU_Reminder_Event_Title, e.Name));
        }

        return l_reminder;
    }

    @AuraEnabled(cacheable=true)
    public static List<AP1006_Reminder> getCommunication() {
        
        List<AP1006_Reminder> l_reminder = new List<AP1006_Reminder>();

        l_reminder.add(new AP1006_Reminder(LOGO_COMMUNICATION, Label.LU_Reminder_Communication_Title, 'azertyuiop'));

        return l_reminder;
    }

    @AuraEnabled(cacheable=true)
    public static List<AP1006_Reminder> getInactivTeamMembers(User currentUser) {

        User u = [SELECT Id, STHID__c, TECH_MergeContactID__c FROM User WHERE Id =: UserInfo.getUserId()];

        AP1001_Cycle_Utils.CycleInfo ci = AP1001_Cycle_Utils.getCurrentCycleByUser(u.Id);

        List<AP1006_Reminder> l_reminder = new List<AP1006_Reminder>();

        String contacts = '';

        List<Id> l_contactsWithOrder = new List<Id>();

        // Get Managers team
        List<Contact> managerTeam = AP1003_Utils_Contact.searchMyTeam(u, null, 'LastName', 'ASC');

        if (currentUser.LU_Use_New_Order_v2__c) {
            /*
                for(AggregateResult ag : [SELECT count(Id), LU_Contact_For__c
                                            FROM OrderItem
                                            WHERE CreatedDate > :ci.startdate
                                            AND CreatedDate < :ci.enddate
                                            AND LU_Contact_For__c IN (SELECT Id 
                                                                        FROM Contact
                                                                        WHERE RecordType.DeveloperName != 'LU_Personal_Contact' 
                                                                        AND ActivityStatus__c = true 
                                                                        AND ( Parent_STH_Id__c = :u.TECH_MergeContactID__c OR ReportsToId = :u.TECH_MergeContactID__c ) )
                                            GROUP BY LU_Contact_For__c
                          ]){
            */

            Date startDate = Date.newInstance(ci.startdate.year(), ci.startdate.month(), ci.startdate.day());
            Date endDate = Date.newInstance(ci.enddate.year(), ci.enddate.month(), ci.enddate.day());
            
            
            /*
                [SELECT count(Id), BillToContactId
                                        FROM Order
                                        WHERE EffectiveDate > : startDate
                                        AND EffectiveDate < : endDate
                                        AND BillToContactId IN (SELECT Id 
                                                                FROM Contact
                                                                WHERE RecordType.DeveloperName != 'LU_Personal_Contact' 
                                                                AND ActivityStatus__c = true 
                                                                AND ( Parent_STH_Id__c = :u.TECH_MergeContactID__c OR ReportsToId = :u.TECH_MergeContactID__c ) )
                                GROUP BY BillToContactId
                          ]
            */
            for(AggregateResult ag : [SELECT count(Id), BillToContactId
                                        FROM Order
                                        WHERE EffectiveDate > : startDate
                                        AND EffectiveDate < : endDate
                                        AND BillToContactId IN: managerTeam
                                        GROUP BY BillToContactId
                          ]){
                l_contactsWithOrder.add( (Id) ag.get('BillToContactId'));
            }

        } else {
            /* (SELECT Id 
                                                                FROM Contact
                                                                WHERE RecordType.DeveloperName != 'LU_Personal_Contact' 
                                                                AND ActivityStatus__c = true 
                                                                AND ( Parent_STH_Id__c = :u.TECH_MergeContactID__c OR ReportsToId = :u.TECH_MergeContactID__c ) )
            */
            for(AggregateResult ag : [SELECT count(Id), Dealer__c
                                        FROM ORD_Order__c
                                        WHERE OrderDate__c > :ci.startdate
                                        AND OrderDate__c < :ci.enddate
                                        AND Dealer__c IN: managerTeam 
                                GROUP BY Dealer__c
                          ]){
                l_contactsWithOrder.add( (Id) ag.get('Dealer__c'));
            }

        }

        /*
        [SELECT Id, FirstName, LastName, Email
                           FROM Contact
                          WHERE RecordType.DeveloperName != 'LU_Personal_Contact' 
                            AND ActivityStatus__c = true 
                            AND Id NOT IN :l_contactsWithOrder
                            AND ( Parent_STH_Id__c = :u.TECH_MergeContactID__c OR ReportsToId = :u.TECH_MergeContactID__c )]
        */
        List<Contact> l_contacts = new List<Contact>();
        for(Contact c : managerTeam) {
            Boolean isActive = false;
            for (Id cActive : l_contactsWithOrder) {
                if (cActive == c.Id) {
                    isActive = true; break;
                }
            }
            if (isActive == false) {
                contacts += c.FirstName + ' ' + c.LastName + ' - ';
                l_contacts.add(c);
            }
        }

        if(contacts.length() > 0){
            contacts = contacts.left(contacts.length() - 3);
            AP1006_Reminder rem = new AP1006_Reminder(LOGO_INACTIVEMEMBER, Label.LU_Reminder_Inactiv_Contacts_Title, contacts);
            rem.l_contacts = l_contacts;
            rem.displayEmailButton = true;
            l_reminder.add(rem);
        }

        return l_reminder;
    }

    // @AuraEnabled(cacheable=true)
    // public static List<AP1006_Reminder> getInactivClients() {

    //     User u = [SELECT Id, STHID__c, TECH_MergeContactID__c FROM User WHERE Id =: UserInfo.getUserId()];

    //     List<AP1006_Reminder> l_reminder = new List<AP1006_Reminder>();

    //     String contacts = '';

    //     List<Id> l_contactsWithOrder = new List<Id>();

    //     for(AggregateResult ag : [SELECT count(Id), LU_Contact_For__c
    //                                 FROM OrderItem
    //                                WHERE CreatedDate > :System.today().addMonths(-2)
    //                                  AND LU_Contact_For__c IN (SELECT Id 
    //                                                              FROM Contact
    //                                                             WHERE RecordType.DeveloperName = 'LU_Personal_Contact' 
    //                                                               AND OwnerId = :u.Id 
    //                                                               AND LU_Is_Deleted__c = false )
    //                             GROUP BY LU_Contact_For__c
    //                       ]){
    //         l_contactsWithOrder.add( (Id) ag.get('LU_Contact_For__c'));
    //     }

    //     for(Contact c : [SELECT Id, FirstName, LastName
    //                        FROM Contact
    //                       WHERE RecordType.DeveloperName = 'LU_Personal_Contact' 
    //                         AND OwnerId = :u.Id 
    //                         AND Id NOT IN :l_contactsWithOrder
    //                         AND LU_Is_Deleted__c = false]){
    //         contacts += c.FirstName + ' ' + c.LastName + ' - ';
    //     }

    //     if(contacts.length() > 0){
    //         contacts = contacts.left(contacts.length() - 3);
    //         l_reminder.add(new AP1006_Reminder(LOGO_INACTIVECLIENTS, Label.LU_Reminder_Inactiv_Clients_Title, contacts));
    //     }

    //     return l_reminder;
    // }

    @AuraEnabled(cacheable=true)
    public static List<AP1006_Reminder> getBirthday() {

        User u = [SELECT Id, STHID__c, TECH_MergeContactID__c FROM User WHERE Id =: UserInfo.getUserId()];
        // Get team of the manager
        List<Contact> managerTeam = AP1003_Utils_Contact.searchMyTeam(u, null, 'LastName', 'ASC');

        List<AP1006_Reminder> l_reminder = new List<AP1006_Reminder>();

        String contacts = '';
        
        List<Contact> l_contacts = new List<Contact>();

        for(Contact c : [SELECT Id, LastName, FirstName, Email 
                         FROM Contact
                         WHERE LU_Birthday_This_Week__c = true
                         AND Id in: managerTeam]){
            contacts += c.FirstName + ' ' + c.LastName + ' - ';
            l_contacts.add(c);
        }

        if(contacts.length() > 0){
            contacts = contacts.left(contacts.length() - 3);
            AP1006_Reminder rem = new AP1006_Reminder(LOGO_BIRTHDAY, Label.LU_Reminder_Birthday_Title, contacts);
            rem.l_contacts = l_contacts;
            rem.displayEmailButton = true;
            l_reminder.add(rem);
        }

        return l_reminder;
    }

    @AuraEnabled(cacheable=true)
    public static List<AP1006_Reminder> getBadDept() {

        User u = [SELECT Id, STHID__c, TECH_MergeContactID__c FROM User WHERE Id =: UserInfo.getUserId()];

        // Get team of the manager
        List<Contact> managerTeam = AP1003_Utils_Contact.searchMyTeam(u, null, 'LastName', 'ASC');

        List<AP1006_Reminder> l_reminder = new List<AP1006_Reminder>();

        String contacts = '';

        List<Contact> l_contacts = new List<Contact>();
        for(Contact c : [SELECT Id, LastName, FirstName , Email
                         FROM Contact
                        WHERE RecordType.DeveloperName != 'LU_Personal_Contact' 
                          AND (Bad_Card_Status__c =: AppConstants.Bad_Card_Status_BadDebit OR Bad_Card_Status__c =: AppConstants.Bad_Card_Status_Block)
                          AND Id in: managerTeam ]){
            contacts += c.FirstName + ' ' + c.LastName + ' - ';
            l_contacts.add(c);

        }

        if(contacts.length() > 0){
            contacts = contacts.left(contacts.length() - 3);
            AP1006_Reminder rem = new AP1006_Reminder(LOGO_BADDEPT, Label.LU_Reminder_BadDept_Title, contacts);
            rem.l_contacts = l_contacts;
            rem.displayEmailButton = true;
            l_reminder.add(rem);
        }

        return l_reminder;
    }
    @AuraEnabled(cacheable=true)
    public static List<AP1006_Reminder> getImpaye() {

        User u = [SELECT Id, STHID__c, TECH_MergeContactID__c FROM User WHERE Id =: UserInfo.getUserId()];

        // Get team of the manager
        List<Contact> managerTeam = AP1003_Utils_Contact.searchMyTeam(u, null, 'LastName', 'ASC');

        List<AP1006_Reminder> l_reminder = new List<AP1006_Reminder>();

        String contacts = '';

        List<Contact> l_contacts = new List<Contact>();
        for(Contact c : [SELECT Id, LastName, FirstName , Email
                         FROM Contact
                        WHERE RecordType.DeveloperName != 'LU_Personal_Contact' 
                          AND Bad_Card_Status__c =: AppConstants.Bad_Card_Status_Notpayed
                          AND Id in: managerTeam ]){
            contacts += c.FirstName + ' ' + c.LastName + ' - ';
            l_contacts.add(c);

        }

        if(contacts.length() > 0){
            contacts = contacts.left(contacts.length() - 3);
            AP1006_Reminder rem = new AP1006_Reminder(LOGO_BADDEPT, Label.LU_Reminder_Unpaid, contacts);
            rem.l_contacts = l_contacts;
            rem.displayEmailButton = true;
            l_reminder.add(rem);
        }

        return l_reminder;
    }

    @AuraEnabled(cacheable=true)
    public static List<AP1006_Reminder> getIsLastWeekCycle() {

        User u = [SELECT Id, STHID__c, TECH_MergeContactID__c FROM User WHERE Id =: UserInfo.getUserId()];

        AP1001_Cycle_Utils.CycleInfo ci = AP1001_Cycle_Utils.getCurrentCycleByUser(u.Id);

        List<AP1006_Reminder> l_reminder = new List<AP1006_Reminder>();

        if(ci.enddate < System.today().addDays(7)){
            l_reminder.add( new AP1006_Reminder(LOGO_ISLASTWEEK, Label.LU_Reminder_LastWeekCycle_Title, Label.LU_Reminder_EndOfCycle) );
        }

        return l_reminder;
    }
}