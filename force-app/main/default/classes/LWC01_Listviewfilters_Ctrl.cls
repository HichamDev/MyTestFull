public without sharing class LWC01_Listviewfilters_Ctrl {
    
    public class Filters {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static Contact getCurrentContact() {
        return AP1002_Utils_User.getConnectedUserContact();
    }

    @AuraEnabled(cacheable=true)
    public static String getUserCountry() {
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Filters>> getFilterInactiveSince(){
        
        /* Variables */
        Map<String, List<Filters>> mFilters = new Map<String, List<Filters>>();

        String userCountry = getUserCountry();

        Integer currentYear = Date.today().year();

        // Get the last cycles of the current user
        List<Commercial_Periods__mdt> lCycles = AP1001_Cycle_Utils.getUserPreviousCycles(UserInfo.getUserId());

        if (lCycles != null) {

            if (userCountry == 'ITA') {

                // Filters on cycle of the current year
                List<Filters> lCyclesCurrentYear = new List<Filters>();
                for (Commercial_Periods__mdt cycle : lCycles) {
                    if (cycle.Startdate__c.year() == currentYear || cycle.Enddate__c.year() == currentYear) {
                        Filters f = new Filters();
                        f.label = cycle.MasterLabel + ' (' + cycle.Startdate__c.format('dd/MM/yyyy') + ' - ' + cycle.Enddate__c.format('dd/MM/yyyy') + ')';
                        //f.value = cycle.Enddate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                        f.value = cycle.Startdate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ';' + cycle.Enddate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                        lCyclesCurrentYear.add(f);
                    }
                }
                mFilters.put('currentYear', lCyclesCurrentYear);

                // Filters on the last 6 cycles
                List<Filters> lCyclesAll = new List<Filters>();
                List<Filters> lCycles6 = new List<Filters>();
                List<Filters> lCycles4 = new List<Filters>();
                
                for (Commercial_Periods__mdt cycle : lCycles) {

                    Filters f = new Filters();
                    f.label = cycle.MasterLabel + ' (' + cycle.Startdate__c.format('dd/MM/yyyy') + ' - ' + cycle.Enddate__c.format('dd/MM/yyyy') + ')';
                    //f.value = cycle.Enddate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                    f.value = cycle.Startdate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ';' + cycle.Enddate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                    lCyclesAll.add(f);

                    if(lCycles4.size() < 4){
                        lCycles4.add(f);
                    }

                    if(lCycles6.size() < 6){
                        lCycles6.add(f);
                    }

                }
                mFilters.put('all', lCyclesAll);
                mFilters.put('last6', lCycles6);
                mFilters.put('last4', lCycles4);


            } else {

                List<Filters> lFilters = new List<Filters>();

                for (Commercial_Periods__mdt cycle : lCycles) {
                
                    if(userCountry == 'FRA' && lFilters.size() >= 4){
                        break;
                    }

                    Filters f = new Filters();
                    f.label = cycle.MasterLabel + ' (' + cycle.Startdate__c.format('dd/MM/yyyy') + ' - ' + cycle.Enddate__c.format('dd/MM/yyyy') + ')';
                    //f.value = cycle.Enddate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                    f.value = cycle.Startdate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ';' + cycle.Enddate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                    lFilters.add(f);
                }
                //system.assert(false, lFilters);

                if(userCountry == 'FRA'){
                    if(lFilters.size() > 0){
                        lFilters.get(0).label = 'Actif';
                        for(Integer i = 1; i < lFilters.size(); i++){
                            //lFilters.get(i).label = i + ' cycles';

                            String labelFiltre = Label.LU_Label_Number_Inactifs_Cycles.replace('x', String.valueOf(i) );
                            if(i > 1){
                                labelFiltre += 's';
                            }
                            lFilters.get(i).label = labelFiltre;
                            // Changement T1944, plus besoin de cherche par cycle, on fait LU_Sleep_Nb_Period_No_Activity__c
                            lFilters.get(i).value = labelFiltre;
                        }
                    }

                    lFilters.get(0).value = lFilters.get(0).label + 'zzzzz' + lFilters.get(0).value;
                }

                mFilters.put('fra', lFilters);
            }
        }
        
        return (mFilters);
    }

    /* Get My Team list with filters */
    @AuraEnabled
    public static List<Filters> getContactTypePicklistValue() {

        String title;
        List<Filters> l_Filters = new List<Filters>();
        LU_Contact_Equipe_Filter__mdt meta;

        //User u = [SELECT ContactId, Contact.Title FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());

        if(c != null) {
            if (c.Title.toLowerCase() == 'direction nationale') {
                title = 'DNV';
            } else if(c.Title == 'Direction de Région') {
                title = 'DR';
            } else if(c.Title == 'Directrice de Division' || c.Title == 'Zone Manager') {
                title = 'DD_ZM';
            } else if(c.Title == 'Animatrice') {
                title = 'AA';
            } else if(c.Title == 'Animatrice de Secteur') {
                title = 'LDS';
            } else if(c.Title == 'Conseillère' && c.Contact_Type__c == 'Leader') {
                title = 'Leader';
            }
        }
        else{
            return l_Filters;
        }

        
        try{
            meta = [SELECT Contact_List__c FROM LU_Contact_Equipe_Filter__mdt WHERE DeveloperName = :title ORDER BY MasterLabel ASC];
        } catch(Exception e){
            return l_Filters;
        }

        Filters f = new Filters();
        f.label = 'Tous';
        f.value = 'Tous';
        l_Filters.add(f);

        for(String s : meta.Contact_List__c.split(';')){
            f = new Filters();
            f.label = s;
            f.value = s;
            l_Filters.add(f);
        }


        return l_Filters;
    }
    @AuraEnabled
    public static List<Filters> getEffectifDormantValues() {

        List<Filters> l_Filters = new List<Filters>();
        Filters f;

        for(LU_Effectif_Dormant_filters__mdt meta : [SELECT MasterLabel, DeveloperName, Order__c, Nb_preriodes_min__c, Nb_preriodes_max__c FROM LU_Effectif_Dormant_filters__mdt
                                                 ORDER BY Order__c]){
            f = new Filters();
            f.label = meta.MasterLabel;
            f.value = meta.Nb_preriodes_min__c + ';' + meta.Nb_preriodes_max__c;
            l_Filters.add(f);
        }

        // T-1944 ajouter inactif 1 a dans les effectif dormant
        Filters f2 = new Filters();
        f2.label = Label.LU_Inactif_more_14_weeks;
        f2.value = 'oneY';
        l_Filters.add(f2);

        return l_Filters;
    }

    @AuraEnabled(cacheable=true)
    public static List<Filters> getSegmentationPicklistValue(){

        List<Filters> l_Filters = new List<Filters>();
        Filters f;

        for(LU_Contact_Segmentation_Filter__mdt meta : [SELECT Label__c, Value__c, Order__c FROM LU_Contact_Segmentation_Filter__mdt
                                                        ORDER BY Order__c ]){
            system.debug('>>>> LU_Contact_Segmentation_Filter__mdt : ' + meta);
            f = new Filters();
            f.label = meta.Label__c;
            f.value = meta.Value__c;
            l_Filters.add(f);
        }

        return l_Filters;
    }

    @AuraEnabled(cacheable=true)
    public static List<Filters> getNewCoachPicklistValue(){

        List<Filters> l_Filters = new List<Filters>();
        Filters f = new Filters();
        f.label = Label.LU_TeamFilters_NewCoach_Auto;
        f.value = 'AUTO ENREGISTREMENT';
        l_Filters.add(f);
		
        f = new Filters();
        f.label = Label.LU_TeamFilters_NewCoach_Manager;
        f.value = 'AUTRE';
        l_Filters.add(f);

        return l_Filters;
    }

    @AuraEnabled(cacheable=true)
    public static List<Filters> getTypoPicklistValue(){

        List<Filters> l_Filters = new List<Filters>();
        Filters f;

        for(LU_Contact_Typo_Filter__mdt meta : [SELECT Label__c, Value__c, Order__c FROM LU_Contact_Typo_Filter__mdt
                                                 ORDER BY Order__c]){
            f = new Filters();
            f.label = meta.Label__c;
            f.value = meta.Value__c;
            l_Filters.add(f);
        }

        return l_Filters;
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
}