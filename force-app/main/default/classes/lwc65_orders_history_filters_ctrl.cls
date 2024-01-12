public without sharing class lwc65_orders_history_filters_ctrl {

    public class Filters {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }
	
    @AuraEnabled(cacheable=true)
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }
    
    @AuraEnabled(cacheable=true)
    public static Contact getCurrentContact() {
        return AP1002_Utils_User.getConnectedUserContact();
    }

    @AuraEnabled(cacheable=true)
    // public static List<Filters> getDealerManagerSegmentationOptions(){
    public static String getDealerManagerSegmentationOptions() {

        List<Filters> l_Filters = new List<Filters>();
        Filters f;

        User currentUser = [SELECT Id, ContactId, TECH_ExternalId__c FROM User WHERE Id = :UserInfo.getUserId()];

        Contact c = AP1002_Utils_User.getConnectedUserContact();

        List<Account> l_acc = AP1003_Utils_Contact.searchManagerTeamAccount(currentUser, c);
        Map<Filters, String> m_filters = new Map<Filters, String>();

        if (l_acc != null) {

            Map<String, String> m_idUserPerIdAccount = new Map<String, String>();
            for(User u : [SELECT Id, TECH_AccountID__c FROM User WHERE Contact.AccountId IN :l_acc]){
                m_idUserPerIdAccount.put(u.TECH_AccountID__c, u.Id);
            }

            f = new Filters();
            f.label = c.LastName;
            if (currentUser.TECH_ExternalId__c.left(3) == 'ITA') {

                Integer level = 0;
                for(Account acc : l_acc){
                    if(acc.Type.right(1).isNumeric() && acc.Type != null && Integer.valueOf(acc.Type.right(1)) > level){
                        level = Integer.valueOf(acc.Type.right(1));
                    }
                }

                f.value = c.AccountId;
                m_filters.put(f, getDealerManagerSegmentationOptions(f, l_acc, level, m_idUserPerIdAccount, 'ita'));

            }
            else if(currentUser.TECH_ExternalId__c.left(3) == 'FRA' && c.Title.contains('Animatrice')){
                f.value = c.Account.ParentId;
                m_filters.put(f, getDealerManagerSegmentationOptions(f, l_acc, 0, m_idUserPerIdAccount, 'fra'));
            }
            else if(currentUser.TECH_ExternalId__c.left(3) == 'FRA'){

                Integer level = 0;
                for(Account acc : l_acc) {
                    if (acc.Type == 'Country') {
                        level = 7; break;
                    }
                    if(acc.Type.right(1).isNumeric() && acc.Type != null && Integer.valueOf(acc.Type.right(1)) > level) {
                        level = Integer.valueOf(acc.Type.right(1));
                    }
                }
                system.debug('>>>>>< level : ' + level);

                //Integer level = c.Account.Type.isNumeric() ? Integer.valueOf(c.Account.Type.right(1)) : 0;
                f.value = UserInfo.getUserId();
                m_filters.put(f, getDealerManagerSegmentationOptions(f, l_acc, level, m_idUserPerIdAccount, 'fra'));

                Filters f2 = new Filters();
                f2.label = c.LastName;
                //f2.value = c.AccountId;
                f2.value = null;

                m_filters.put(f2, m_filters.get(f));
                m_filters.remove(f);
            }

        }

        return JSON.serialize(m_filters);

    }

    private static String getDealerManagerSegmentationOptions(Filters f, List<Account> l_acc, Integer level, Map<String, String> m_idUserPerIdAccount, String country) {

        Map<Filters, String> m_filters = new Map<Filters, String>();

        Filters childFilter;

        if (country == 'ita' && level == 4) {
            level = 3;
        }

        for (Account acc : l_acc) {
            if (acc.ParentId == f.value || acc.OwnerId == f.value || acc.OwnerId == m_idUserPerIdAccount.get(f.value)) {
                Integer lvlAcc = (acc.Type.right(1).isNumeric() ? Integer.valueOf(acc.Type.right(1)) : 7);
                if (level == 0 || level == lvlAcc) {
                    childFilter = new Filters();
                    childFilter.label = acc.Name;
                    childFilter.value = acc.Id;

                    m_filters.put(childFilter, getDealerManagerSegmentationOptions(childFilter, l_acc, level == 0 ? level : level - 1, m_idUserPerIdAccount, country));
                }
            }
        }
        return JSON.serialize(m_filters);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, string> getOptionsTimePeriod(String label){
        Map<String, String> mapOptions = new Map<String, String>();
        if(label == System.Label.LU_Order_Filter_Time_Period_last_week){
            //Récupérer le jour actuel et aller chercher le mardi
            Date today = Date.today();
            Date weekStart = today.toStartofWeek().addDays(1);
            // mapOptions.put(weekStart.format() + ' - ' + weekStart.addDays(6).format(), weekStart.format());

            List<Commercial_Periods__mdt> lWeeks = null;
            // Get the cycles in the last year
            for(Commercial_Periods__mdt week : [SELECT MasterLabel, DeveloperName, Startdate__c, Enddate__c, Description__c  
                        FROM Commercial_Periods__mdt 
                        WHERE TECH_External_Id__c LIKE 'ITA%'
                        AND Startdate__c <=: System.now() 
                        AND Type__c = 'Week'
                        ORDER BY Startdate__c DESC Limit 50]){

                Date previousWeekStartDate = Date.newinstance(week.Startdate__c.year(), week.Startdate__c.month(), week.Startdate__c.day());
                Date previousWeekEndDate = Date.newinstance(week.Enddate__c.year(), week.Enddate__c.month(), week.Enddate__c.day());
                mapOptions.put(previousWeekStartDate.format() + ' - ' + previousWeekEndDate.format(), previousWeekStartDate.format() + 'week' + previousWeekEndDate.format());
                // mapOptions.put(weekStart.addDays(-7*i).format() + ' - ' + weekStart.addDays(-7*i + 6).format(), weekStart.addDays(-7*i).format());
            }
        }
        else if(label == System.Label.LU_Order_Filter_Time_Period_last_month){
            //Récupérer le jour actuel
            Date today = Date.today();
            Date monthStart = today.toStartOfMonth();
            mapOptions.put(monthStart.format() + ' - ' + monthStart.addMonths(1).addDays(-1).format(), monthStart.format()+'month'+ monthStart.addMonths(1).addDays(-1).format());

            for(Integer i = 1; i < 5; i++){
                mapOptions.put(monthStart.addMonths(-i).format() + ' - ' + monthStart.addMonths(-i+1).addDays(-1).format(), monthStart.addMonths(-i).format()+'month' + monthStart.addMonths(-i+1).addDays(-1).format());
            }
        }
        else if(label == System.Label.LU_Order_Filter_Time_Period_last_cycle){
            for (Commercial_Periods__mdt previousCycle : AP1001_Cycle_Utils.getUserPreviousCycles(UserInfo.getUserId())){
                if(previousCycle.Startdate__c != null && previousCycle.Enddate__c != null){
                    Date previousCycleStartDate = Date.newinstance(previousCycle.Startdate__c.year(), previousCycle.Startdate__c.month(), previousCycle.Startdate__c.day());
                    Date previousCycleEndDate = Date.newinstance(previousCycle.Enddate__c.year(), previousCycle.Enddate__c.month(), previousCycle.Enddate__c.day());
                    mapOptions.put('C' + previousCycle.Description__c.right(2) + ' ' + previousCycleStartDate.format() + ' - ' + previousCycleEndDate.format(), previousCycleStartDate.format() + 'cycle' + previousCycleEndDate.format());
                }
            }
        }
        return mapOptions;
    }
}