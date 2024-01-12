global class BA03_SendSMS_Birthday implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    //map where we will save all contacts as values with Id Sinch Template as key
    //in the finish method we will use it to send contacts to Sinch WS
    global Map<String, List<contact>> mIdSinchTplContacts = new Map<String, List<contact>>();
    
    //get a map of maps like this {idSinchTpl={C=FirstName, D=CurrentCommercialCycle__c}}
    global Map<String, Map<String, String>> mMappingFields = BA03_Utils.getMappingFieldsFromBirthdayCmdt();   
    //get current birthday settings from metadata
    global Birthday_Settings__mdt currentBirthday = AP49_ReadCustomMetadatas.getCurrentBirthdayMdt();
    
    //Is there a commercial period of type 'Week' beginning today ?
    public Commercial_Periods__mdt commPeriodToday = AP49_ReadCustomMetadatas.getStartingTodayCommercialPeriod_mdt('Week', null);   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        //AJOUTER CONDITIONS SUR
        //  - CONTACT OPTOUT NEWSLETTER ET FAX
        //  - CONTACT AVEC MSISDN UNIQUE    
        if(!Test.isRunningTest()){AP48_WS_Utils forSinchTokenInit = new AP48_WS_Utils();}
        
        //get contacts with their birthday between 
        String query = '';
        if(commPeriodToday != null){
            System.debug('BA03_SendSMS_Birthday commPeriodToday ' + commPeriodToday);
            System.debug('Startdate__c ' + commPeriodToday.Startdate__c.month() + ' ' + commPeriodToday.Startdate__c.day());
            System.debug('Enddate__c ' + commPeriodToday.Enddate__c.month() + ' ' + commPeriodToday.Enddate__c.day());
            String startDate = DateTime.newInstance(DateTime.now().year(), commPeriodToday.Startdate__c.month(), commPeriodToday.Startdate__c.day()).format('yyyy-MM-dd');         
            String endDate = DateTime.newInstance(DateTime.now().year(), commPeriodToday.Enddate__c.month(), commPeriodToday.Enddate__c.day()).format('yyyy-MM-dd');         
            query = 'SELECT Id, MobilePhone from Contact WHERE Birthdate != null AND Tech_Birthdate_month_day__c >= ' + startDate + ' AND Tech_Birthdate_month_day__c <= ' + endDate ;
            query += ' AND MobilePhone != \'\' AND TECH_ExternalId__c like \'%ITA%\' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false';
        }
        else{
            System.debug('BA03_SendSMS_Birthday NO commPeriodToday');
            query = 'SELECT Id,MobilePhone from Contact WHERE Birthdate != null AND Birthdate = null';  // condition never true, as we don't want to have any contact in scope because there is no commPeriodToday
        }
        if(Test.isRunningTest()){
            query +=' limit 200';
        }

        System.debug(query);
        return Database.getQueryLocator(query);    
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> contactsScope){
        System.debug('BA03_SendSMS_Birthday contacts contactsScope ' + contactsScope.size());
        try{
            //List of contact we have to send SMS if they have their birthday month and day in the beginning commercial period 'Week'
            // List <Id> lContacts = new List<Id>(new Map<Id, Contact>([select Id from Contact where Id in :contactsScope]).keySet());
            
            //créer liste mobilephone à partir des contacts du scope
            List<String> lContactsMobilePhone = new list<String>();
            for(Contact c:contactsScope){
                lContactsMobilePhone.add(c.MobilePhone);
            }
            
            //la passer à la méthode getContactWithoutDuplicateMobilePhone
            Set<Id> lContactWithoutDuplicateMobilePhone = BA02_Utils.getContactsWithoutDuplicateMobilePhone(lContactsMobilePhone);   
            
            List <Contact> lContacts = new List<Contact>([select Id, birthdate from Contact where Id in :lContactWithoutDuplicateMobilePhone]);
            
            System.debug('BA03_SendSMS_Birthday contactsScope ' + contactsScope);
            System.debug('BA03_SendSMS_Birthday lContactsMobilePhone ' + lContactsMobilePhone);
            System.debug('BA03_SendSMS_Birthday lContactWithoutDuplicateMobilePhone ' + lContactWithoutDuplicateMobilePhone);
            System.debug('BA03_SendSMS_Birthday lContacts ' + lContacts);
            
            //We have to keep only contacts with birthday between Startdate and Enddate
            List <Contact> lContactsFilteredOnBirthday = new List<Contact>();
            
            for(Contact c : lContacts){
                if( 
                c.Birthdate.month() == commPeriodToday.Startdate__c.month() && 
                c.Birthdate.month() == commPeriodToday.Enddate__c.month() && 
                c.Birthdate.day() >= commPeriodToday.Startdate__c.day() && 
                c.Birthdate.day() <= commPeriodToday.Enddate__c.day())
                {
                    lContactsFilteredOnBirthday.add(c);
                }
                else if(
                (
                c.Birthdate.month() == commPeriodToday.Startdate__c.month() && 
                c.Birthdate.month() == (commPeriodToday.Enddate__c.month() - 1) && 
                c.Birthdate.day() >= commPeriodToday.Startdate__c.day()) ||
                (
                c.Birthdate.month() == (commPeriodToday.Startdate__c.month() + 1) && 
                c.Birthdate.month() == commPeriodToday.Enddate__c.month() && 
                c.Birthdate.day() <= commPeriodToday.Enddate__c.day())
                )
                {
                    lContactsFilteredOnBirthday.add(c);
                }
            }
            System.debug('BA03_SendSMS_Birthday lContacts ' + ' ' + lContacts.size() + lContacts);
            System.debug('BA03_SendSMS_Birthday lContactsFilteredOnBirthday ' + ' ' + lContactsFilteredOnBirthday.size() + lContactsFilteredOnBirthday);
            
            
            System.Debug('mMappingFields ' + mMappingFields);
            // map of maps like this {idSinchTpl={C=FirstName, D=CurrentCommercialCycle__c}}
            // Map<String, Map<String, String>> mFieldToKey = new Map<String, Map<String, String>>();
            String fieldsToQuery = '';
            if((lContactsFilteredOnBirthday.size() != 0) && (mMappingFields.size() != 0)){
                Contact contactTest = new Contact();
                for(String sinchIdTpl : mMappingFields.keySet()){
                    System.Debug('sinchIdTpl ' + sinchIdTpl + ' ' + mMappingFields.get(sinchIdTpl).keySet());
                    for(String letter : mMappingFields.get(sinchIdTpl).keySet()){
                        System.Debug('letter ' + letter + mMappingFields.get(sinchIdTpl).get(letter));
                        if(!fieldsToQuery.contains(mMappingFields.get(sinchIdTpl).get(letter))){
                            if(BA02_Utils.hasSObjectField(mMappingFields.get(sinchIdTpl).get(letter), contactTest)){
                                fieldsToQuery += ', ' + mMappingFields.get(sinchIdTpl).get(letter);
                            }                            
                        }
                    }
                }
            }
            
            //set the query to get fields value to send them to Sinch for custom fields
            String contactsQuery = 'SELECT Mobilephone, Id ' + fieldsToQuery + ' FROM contact where Id in :lContactsFilteredOnBirthday';
            System.debug('fieldsToQuery ' + fieldsToQuery);
            System.debug('contactsQuery ' + contactsQuery);
            List <contact> lContactsToSendSMS = Database.query(contactsQuery);
            System.debug('BA03_SendSMS_Birthday contacts lContactsToSendSMS ' + String.valueOf(lContactsToSendSMS.size()) + lContactsToSendSMS);
            Map<String, List<Contact>> mContacts = new  Map<String, List<Contact>>();
            for(Contact c : lContactsToSendSMS) {
                if(mIdSinchTplContacts.containsKey(currentBirthday.SinchTemplateId__c)) {
                    List<Contact> lC = mIdSinchTplContacts.get(currentBirthday.SinchTemplateId__c);
                    lC.add(c);
                    mIdSinchTplContacts.put(currentBirthday.SinchTemplateId__c, lC);
                } else {
                    mIdSinchTplContacts.put(currentBirthday.SinchTemplateId__c, new List<Contact> {c});
                }
            }
            System.debug('BA0BA02_SendSMS_ToSinch contacts mIdSinchTplContacts ' + mIdSinchTplContacts);
        }
        catch(Exception error){
            System.debug('An error occured in batch BA03_SendSMS_Birthday ' + error);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        String [] contactEmptyValues = BA02_Utils.getEmptyContactValues();   // contactValues = ['', '', '', '', '', '', '', '', 26*] pour toutes les lettres de l'alphabet, potentielles champs de fusion pour Sinch
        Commercial_Periods__mdt commPeriodTest = new Commercial_Periods__mdt();
        //for each id Sinch template we set contacts array as a string
        Integer cptContactsTotal = 0;
        Integer cptContacts = 0;
        for(String idTpl : mIdSinchTplContacts.keySet()){
            //for each contacts we have to send, with this id Sinch template
            cptContactsTotal = mIdSinchTplContacts.get(idTpl).size();
            cptContacts = 0;
            String strContacts = '[';
            for(Contact c : mIdSinchTplContacts.get(idTpl)){
                String [] contactValues = contactEmptyValues;
                contactValues[0] = c.MobilePhone;
                contactValues[1] = c.Id;
                for(String letter : mMappingFields.get(currentBirthday.SinchTemplateId__c).keySet()){
                    try{
                        //if field is a contact field
                        String fieldValue = '';
                        if(BA02_Utils.hasSObjectField(mMappingFields.get(currentBirthday.SinchTemplateId__c).get(letter), c)){
                            contactValues[letter.charAt(0)-65] = (String)c.get(mMappingFields.get(currentBirthday.SinchTemplateId__c).get(letter));
                        }
                        //if field is a Commercial_Periods__mdt field
                        else if(BA02_Utils.hasSObjectField(mMappingFields.get(currentBirthday.SinchTemplateId__c).get(letter), commPeriodTest)){
                            If (commPeriodToday.get(mMappingFields.get(currentBirthday.SinchTemplateId__c).get(letter)) instanceof Datetime) {
                                Datetime dtValue = (Datetime) commPeriodToday.get(mMappingFields.get(currentBirthday.SinchTemplateId__c).get(letter));
                                fieldValue = dtValue.format('yyyy-MM-dd');
                            }
                            else{
                                fieldValue = (String) commPeriodToday.get(mMappingFields.get(currentBirthday.SinchTemplateId__c).get(letter));
                            }
                            contactValues[letter.charAt(0)-65] = fieldValue;
                        }    
                    }
                    catch(Exception e){
                        System.debug('Exception while mapping fields : ' + e);
                    }
                    
                    
                }
                strContacts += BA02_Utils.listToStr(contactValues);
                if(cptContacts++ < cptContactsTotal - 1){
                    strContacts += ',';
                }
            }
            strContacts += ']';
            
            System.debug('+++ strContacts ' + mIdSinchTplContacts.get(idTpl).size() + ' ' + strContacts+ ' ' + cptContacts);
            if(!Test.isRunningTest()){
                AP48_WS_Utils.sendSMS(idTpl, strContacts, false, '14:00', null);
            }
        }
        
        System.debug('Limits.getHeapSize() ' + Limits.getHeapSize());
        System.debug('Limits.getLimitHeapSize() ' + Limits.getLimitHeapSize());    
        
    }
    
}