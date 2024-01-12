public with sharing class AP49_ReadCustomMetadatas {
    public static List <Commercial_Periods__mdt> lCommPeriods = new List <Commercial_Periods__mdt>();
    
    
    public AP49_ReadCustomMetadatas(String PType) {
        lCommPeriods = getCommercialPeriods_mdt(PType);
    }
    
    public static Integer getDelay(String delayPurpose){
        MiscDelay__mdt[] delay = [SELECT delay__c FROM 	MiscDelay__mdt where DeveloperName = :delayPurpose limit 1];
        Integer delayVal = 0;
        if(delay.size() > 0){
            delayVal = delay[0].delay__c.intValue();
        }
        return delayVal;
    }
    
    //get all dealerSeniorities at a beginning commercial period
    //used by BA02_SendSMS_ToSinch
    public static List<DealerSeniority__mdt> getAllDealerSenioritiesAtBeginnningPeriod(){
        List<DealerSeniority__mdt> lDealerSenioritiesAtBeginnningPeriod = new List<DealerSeniority__mdt>();
        for (DealerSeniority__mdt ds : getDealerSeniorities_mdt()){
            Commercial_Periods__mdt cpmdt = AP49_ReadCustomMetadatas.isPeriodBeginning(ds.Delay__c.intValue());
            if(cpmdt != null){
                lDealerSenioritiesAtBeginnningPeriod.add(ds);    
            }
        }
        System.debug('AP49_ReadCustomMetadatas lDealerSenioritiesAtBeginnningPeriod ' + lDealerSenioritiesAtBeginnningPeriod);
        return lDealerSenioritiesAtBeginnningPeriod;
    }
    
    //if we are at a beginning of a today minus delay, to manage campaign members, send sms, ...
    public static Commercial_Periods__mdt isPeriodBeginning(Integer delay){
        Date today = convertToDate(Datetime.now());
        Commercial_Periods__mdt ret = null;
        for(Commercial_Periods__mdt cp : lCommPeriods){
            if(today - delay  == convertToDate(cp.Startdate__c)){
                ret = cp;
            }
        }
        return ret;
    }
    
    //used to know essentially if we are at the beginning of a period
    //for the moment only take care of ITA commercial periods
    public static List <Commercial_Periods__mdt> getCommercialPeriods_mdt(String PType){
        Datetime today = Date.today() - 31;	//to be sure to get all periods concerned in the future - one month, not in the past
        Commercial_Periods__mdt[] commPeriods = [SELECT Description__c, Startdate__c, Enddate__c ,Parent_Id__c, TECH_External_Id__c, Type__c 
        FROM Commercial_Periods__mdt 
        WHERE Startdate__c >= :today
        AND Type__c = :PType
        AND TECH_External_Id__c like 'ITA%'
        ];
        return commPeriods;
    }    
    
    //used to know essentially if we are at the Startdate of a commercial period, for Birthday of commPeriod 'Week'
    //for the moment only take care of ITA commercial periods    
    public static Commercial_Periods__mdt getStartingTodayCommercialPeriod_mdt(String PType, Integer days){
        Commercial_Periods__mdt retCommPeriod = null;
        Commercial_Periods__mdt[] commPeriodStartingToday = [SELECT Description__c,Label, Startdate__c, Enddate__c ,Parent_Id__c, TECH_External_Id__c, Type__c 
        FROM Commercial_Periods__mdt 
        WHERE Startdate__c = TODAY
        AND Type__c = :PType
        AND TECH_External_Id__c like 'ITA%'
        ];

        if(days != null && days == 3){
            commPeriodStartingToday = [SELECT Description__c,Label, Startdate__c, Enddate__c ,Parent_Id__c, TECH_External_Id__c, Type__c 
        FROM Commercial_Periods__mdt 
        WHERE Startdate__c = N_DAYS_AGO:3
        AND Type__c = :PType
        AND TECH_External_Id__c like 'ITA%'
        ];
        }
        else if(days != null && days == 1){
            commPeriodStartingToday = [SELECT Description__c,Label, Startdate__c, Enddate__c ,Parent_Id__c, TECH_External_Id__c, Type__c 
        FROM Commercial_Periods__mdt 
        WHERE Startdate__c = N_DAYS_AGO:1
        AND Type__c = :PType
        AND TECH_External_Id__c like 'ITA%'
        ];
        }

        if(commPeriodStartingToday.size() > 0){
            retCommPeriod = commPeriodStartingToday[0];
        }
        
        return retCommPeriod;
    }        
    
    //map of maps like this {Argento={Startdate__c=28/12/2019, Enddate__c=10/01/2020}, Bronzo={Startdate__c=28/12/2019, Enddate__c=10/01/2020}} in case we have fields of Commercial_Periods__mdt used in mapping
    public static Map<String, Map<String, String>> get_m_dealerSeniority_commercialPeriodFieldsValues(Boolean isTest){
        Map<String, Map<String, String>> m_dealerSeniority_commercialPeriodFieldsValues = new Map<String, Map<String, String>>();
        Date today = convertToDate(Datetime.now());
        //get dealesSeniorities cmdt
        List<DealerSeniority__mdt> lDS = getDealerSeniorities_mdt();
        //get commercialPeriods cmdt
        List<Commercial_Periods__mdt> lCP = getCommercialPeriods_mdt('Cycle');
        //make map like {Argento={Startdate__c=28/12/2019, Enddate__c=10/01/2020}, Bronzo={Startdate__c=28/12/2019, Enddate__c=10/01/2020}}
        for(DealerSeniority__mdt ds : lDS){
            for(Commercial_Periods__mdt cp : lCP){
                if(isTest || (today - ds.Delay__c.intValue()  == convertToDate(cp.Startdate__c))){
                    Map<String, String> commercialPeriodFieldsValues = new Map<String, String>();
                    commercialPeriodFieldsValues.put('Startdate__c', cp.Startdate__c.format('dd MM yyyy'));
                    commercialPeriodFieldsValues.put('Enddate__c', cp.Enddate__c.format('dd MM yyyy'));
                    m_dealerSeniority_commercialPeriodFieldsValues.put(ds.SegmentName__c, commercialPeriodFieldsValues);
                }
            }
        }
        System.debug('AP49_ReadCustomMetadatas m_dealerSeniority_commercialPeriodFieldsValues ' + m_dealerSeniority_commercialPeriodFieldsValues);
        return m_dealerSeniority_commercialPeriodFieldsValues;
    }    
    
    //get al Dealer seniorities mdt
    public static List <DealerSeniority__mdt> getDealerSeniorities_mdt(){
        DealerSeniority__mdt[] dealerSeniorities = [SELECT SegmentName__c, Delay__c, Mapping__c, SinchTemplateId__c FROM DealerSeniority__mdt];
        return dealerSeniorities;
    }
    
    //get al Dealer seniorities mdt
    public static Birthday_Settings__mdt getCurrentBirthdayMdt(){
        Birthday_Settings__mdt[] currentBirthday = [SELECT Delay__c, Mapping__c, SinchTemplateId__c FROM Birthday_Settings__mdt];
        return currentBirthday[0];
    }
    
    public static Date convertToDate(Datetime d){
        return(date.newinstance(d.year(), d.month(), d.day()));
    }    
}