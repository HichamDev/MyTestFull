public with sharing class AP1001_Cycle_Utils {
    
    public class CycleInfo {
        @AuraEnabled
        public String cycleInfo {get;set;}
        @AuraEnabled
        public Datetime startdate {get;set;}
        @AuraEnabled
        public Datetime enddate {get;set;}
        @AuraEnabled
        public String weekInfo {get;set;}
        @AuraEnabled  
        public Integer nbDaysInCycle {get;set;}
        @AuraEnabled
        public String daysleft {get;set;}
        @AuraEnabled
        public String hoursleft {get;set;}
        @AuraEnabled
        public String minutesleft {get;set;}
        @AuraEnabled
        public String country {get;set;}
    }

    /* GET THE PREVIOUS CYCLE OF THE LAST 12 MONTHS OF A USER */
    public static List<Commercial_Periods__mdt> getUserPreviousCycles(Id userId) {

        // Get user country
        String country = AP1002_Utils_User.getUserCountry(userId);

        return getCountryPreviousCycles(country);
        
    }

    /* GET THE PREVIOUS CYCLE OF THE LAST 12 MONTHS OF A USER */
    public static List<Commercial_Periods__mdt> getCountryPreviousCycles(String country) {

        List<Commercial_Periods__mdt> lCycles = new List<Commercial_Periods__mdt>();

        if (country != '') {
            country += '%';
            // Get the cycles in the last year
            lCycles = [SELECT MasterLabel, DeveloperName, Startdate__c, Enddate__c, Description__c  
                        FROM Commercial_Periods__mdt 
                        WHERE TECH_External_Id__c LIKE : country
                        AND Startdate__c <=: System.now() 
                        AND Type__c = 'Cycle'
                        ORDER BY Startdate__c DESC Limit 12];
            system.debug(lCycles);
        }

        return (lCycles);
    }

    @AuraEnabled(cacheable=true)
    public static CycleInfo getCurrentCycleByUser(Id userId) {

        String country = '';
        CycleInfo info = new CycleInfo();

        /* Get User country */
        User currentUser = [SELECT Id, TECH_ExternalId__c FROM User WHERE Id =: userId];
        if (currentUser != null && currentUser.TECH_ExternalId__c != null && currentUser.TECH_ExternalId__c != '') {
            country = currentUser.TECH_ExternalId__c.left(3);
            //country += '%';
        }

        return getCountryCurrentCycle(country);
    }

    @AuraEnabled(cacheable=true)
    public static CycleInfo getCountryCurrentCycle(String country) {

        CycleInfo info = new CycleInfo();
        info.country = country;
        Datetime now = Datetime.now();
        String fCountry = country + '%';

        List<Commercial_Periods__mdt> lCycle = [SELECT Type__c, Startdate__c, Enddate__c, Description__c 
                                                FROM Commercial_Periods__mdt 
                                                WHERE TECH_External_Id__c LIKE : fCountry
                                                AND Startdate__c <=: now 
                                                AND Enddate__c >=: now];



        if (!lCycle.isEmpty()) {
            for (Commercial_Periods__mdt data : lCycle) {

                // If Cycle, get the description
                if (data.Type__c == 'Cycle') {

                    info.cycleInfo = data.Description__c;

                    info.startdate = data.Startdate__c;
                    info.enddate = data.Enddate__c;

                    // Calculate number of days in cycle
                    Long millisecondsCycle = info.enddate.getTime() - info.startdate.getTime();
                    info.nbDaysInCycle = (integer)((((millisecondsCycle / 1000) / 60) / 60) / 24);

                    // Caculate days, hours et minutes left between end date and now
                    Long milliseconds = info.enddate.getTime() - now.getTime();
                    Long seconds = milliseconds / 1000;
                    Long minutes = seconds / 60;
                    Long hours = minutes / 60;
                    Long days = hours / 24;

                    Long hoursleft = (hours - (days * 24));
                    Long minutesLeft = (minutes - ((hoursleft * 60) + (days * 24 * 60)));

                    info.daysleft = days + '';
                    info.hoursleft = hoursleft + '';
                    info.minutesLeft = minutesLeft + '';

                } else if (data.Type__c == 'Week') { // If Period, get description

                    info.weekInfo = data.Description__c;

                }

            }

        }

        return (info);
    }

    @AuraEnabled(cacheable=true)
    public static CycleInfo getCountryCurrentCycleWeek(String country) {

        CycleInfo info = new CycleInfo();
        info.country = country;
        Datetime now = Datetime.now();
        String fCountry = country + '%';

        List<Commercial_Periods__mdt> lCycle = [SELECT Type__c, Startdate__c, Enddate__c, Description__c 
                                                FROM Commercial_Periods__mdt 
                                                WHERE TECH_External_Id__c LIKE : fCountry
                                                AND Startdate__c <=: now 
                                                AND Enddate__c >=: now];



        if (!lCycle.isEmpty()) {
            for (Commercial_Periods__mdt data : lCycle) {

                // If Cycle, get the description
                if (data.Type__c == 'Cycle') {

                    info.cycleInfo = data.Description__c + ' du ' + data.Startdate__c.format('dd/MM/yyyy') + ' au ' + data.Enddate__c.format('dd/MM/yyyy');


                } else if (data.Type__c == 'Week') { // If Period, get description

                    info.weekInfo = data.Description__c;

                    info.startdate = data.Startdate__c;
                    info.enddate = data.Enddate__c;

                    // Calculate number of days in cycle
                    Long millisecondsCycle = info.enddate.getTime() - info.startdate.getTime();
                    info.nbDaysInCycle = (integer)((((millisecondsCycle / 1000) / 60) / 60) / 24);

                    // Caculate days, hours et minutes left between end date and now
                    Long milliseconds = info.enddate.getTime() - now.getTime();
                    Long seconds = milliseconds / 1000;
                    Long minutes = seconds / 60;
                    Long hours = minutes / 60;
                    Long days = hours / 24;

                    Long hoursleft = (hours - (days * 24));
                    Long minutesLeft = (minutes - ((hoursleft * 60) + (days * 24 * 60)));

                    info.daysleft = days + '';
                    info.hoursleft = hoursleft + '';
                    info.minutesLeft = minutesLeft + '';
                }

            }

        }

        return (info);
    }

}