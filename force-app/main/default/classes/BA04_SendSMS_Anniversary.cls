global class BA04_SendSMS_Anniversary implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    //map where we will save all contacts as values with Id Sinch Template as key
    //in the finish method we will use it to send contacts to Sinch WS
    global Map<String, List<Contact>> mIdSinchTplContacts = new Map<String, List<Contact>>();
    
    //get a map of maps like this {idSinchTpl={C=FirstName, D=CurrentCommercialCycle__c}}
    global Map<String, Map<String, String>> mMappingFields = BA04_Utils.getMappingFieldsFromAnniversaryCmdt();
    //get current anniversary settings from metadata
    global Anniversary_Settings__mdt currentAnniversary = BA04_Utils.getCurrentAnniversaryMdt();
    
    //Is there a commercial period of type 'Cycle' beginning today ?
    public Commercial_Periods__mdt commPeriodToday = AP49_ReadCustomMetadatas.getStartingTodayCommercialPeriod_mdt('Cycle', 1);

    global Database.QueryLocator start(Database.BatchableContext bc) {

        if(!Test.isRunningTest()){AP48_WS_Utils forSinchTokenInit = new AP48_WS_Utils();}
        
        //get contacts with their anniversary between 
        String query = '';
        if(commPeriodToday != null){
            System.debug('BA04_SendSMS_Anniversary commPeriodToday ' + commPeriodToday);
            System.debug('Startdate__c ' + commPeriodToday.Startdate__c.month() + ' ' + commPeriodToday.Startdate__c.day());
            System.debug('Enddate__c ' + commPeriodToday.Enddate__c.month() + ' ' + commPeriodToday.Enddate__c.day());
            Date oneYearAgo = AP49_ReadCustomMetadatas.convertToDate(Date.today().addYears(-1));

            //Nouvelle règle prendre que les SuccessBearing 2022C13 avec 13 = n° du cycle
            query = 'SELECT Id, MobilePhone FROM Contact ' +
                    'WHERE (LU_Anniversary_Flags__c  LIKE \'' + commPeriodToday.Label.substring(0,4) + '%\' '+ 
                    'AND LU_Anniversary_Flags__c  LIKE \'%' + commPeriodToday.Description__c + '\' ' +
                    ') AND MobilePhone != \'\' AND TECH_ExternalId__c like \'%ITA%\' ' +
                    'AND OptinNewsletter1__c = true AND HasOptedOutOfFax = false ' +
                    'AND Title NOT IN (\'Area Manager\', \'Sales Area Supervisor\', \'Zone Manager\', \'Star Leader\')';
                    
        } else {
            System.debug('BA04_SendSMS_Anniversary NO commPeriodToday');
            // condition never true, as we don't want to have any contact in scope because there is no commPeriodToday
            query = 'SELECT Id,MobilePhone from Contact WHERE Id = \'003D000001sv4W2IAI\'';
        }
        if(Test.isRunningTest()){
            query +=' limit 200';
        }
        else {
            query +=' AND TECH_MAX_LastOrderDate__c >= :oneYearAgo';
        }
        System.debug('query ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Contact> contactsScope) {
        System.debug('BA04_SendSMS_Anniversary contacts contactsScope ' + contactsScope.size());
        try{
            //List of contact we have to send SMS if they have their anniversary month and day in the beginning commercial period 'Week'
            // List <Id> lContacts = new List<Id>(new Map<Id, Contact>([select Id from Contact where Id in :contactsScope]).keySet());
            
            //créer liste mobilephone à partir des contacts du scope
            List<String> lContactsMobilePhone = new list<String>();
            for(Contact c:contactsScope){
                lContactsMobilePhone.add(c.MobilePhone);
            }
            
            //la passer à la méthode getContactWithoutDuplicateMobilePhone
            Set<Id> lContactWithoutDuplicateMobilePhone = BA02_Utils.getContactsWithoutDuplicateMobilePhone(lContactsMobilePhone); 
            // List <Contact> lContacts = new List<Contact>([
            //     SELECT Id, Start_date__c 
            //     FROM Contact 
            //     WHERE Id IN :lContactWithoutDuplicateMobilePhone
            // ]);
            
            System.debug('BA04_SendSMS_Anniversary contactsScope ' + contactsScope);
            System.debug('BA04_SendSMS_Anniversary lContactsMobilePhone ' + lContactsMobilePhone);
            System.debug('BA04_SendSMS_Anniversary lContactWithoutDuplicateMobilePhone ' + lContactWithoutDuplicateMobilePhone);
            //System.debug('BA04_SendSMS_Anniversary lContacts ' + lContacts);
            
            // //We have to keep only contacts with anniversary between Startdate and Enddate
            // List <Contact> lContactsFilteredOnAnniversary = new List<Contact>();
            // for (Contact c : lContacts){
            //     lContactsFilteredOnAnniversary.add(c);
            // }
            // System.debug('BA04_SendSMS_Anniversary lContacts ' + ' ' + lContacts.size() + lContacts);
            // System.debug('BA04_SendSMS_Anniversary lContactsFilteredOnAnniversary ' + ' ' + lContactsFilteredOnAnniversary.size() + lContactsFilteredOnAnniversary);
            
            System.Debug('mMappingFields ' + mMappingFields);
            // map of maps like this {idSinchTpl={C=FirstName, D=CurrentCommercialCycle__c}}
            // Map<String, Map<String, String>> mFieldToKey = new Map<String, Map<String, String>>();
            String fieldsToQuery = '';
            if((lContactWithoutDuplicateMobilePhone.size() != 0) && (mMappingFields.size() != 0)){
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
            String contactsQuery = 'SELECT Mobilephone, Id ' + fieldsToQuery + ' FROM Contact where Id in :lContactWithoutDuplicateMobilePhone';
            System.debug('fieldsToQuery ' + fieldsToQuery);
            System.debug('contactsQuery ' + contactsQuery);
            List<Contact> lContactsToSendSMS = Database.query(contactsQuery);
            System.debug('BA04_SendSMS_Anniversary contacts lContactsToSendSMS ' + String.valueOf(lContactsToSendSMS.size()) + lContactsToSendSMS);
            Map<String, List<Contact>> mContacts = new Map<String, List<Contact>>();
            for(Contact c : lContactsToSendSMS) {
                if(mIdSinchTplContacts.containsKey(currentAnniversary.SinchTemplateId__c)) {
                    List<Contact> lC = mIdSinchTplContacts.get(currentAnniversary.SinchTemplateId__c);
                    lC.add(c);
                    mIdSinchTplContacts.put(currentAnniversary.SinchTemplateId__c, lC);
                } else {
                    mIdSinchTplContacts.put(currentAnniversary.SinchTemplateId__c, new List<Contact> {c});
                }
            }
            System.debug('BA04_SendSMS_Anniversary contacts mIdSinchTplContacts ' + mIdSinchTplContacts);
        }
        catch(Exception error){
            System.debug('An error occured in batch BA04_SendSMS_Anniversary ' + error);
        }  
    }
    global void finish(Database.BatchableContext bc) {
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
                for(String letter : mMappingFields.get(currentAnniversary.SinchTemplateId__c).keySet()){
                    try{
                        //if field is a contact field
                        String fieldValue = '';
                        if(BA02_Utils.hasSObjectField(mMappingFields.get(currentAnniversary.SinchTemplateId__c).get(letter), c)){
                            if (c.get(mMappingFields.get(currentAnniversary.SinchTemplateId__c).get(letter)) instanceof DateTime) {
                                Datetime dtValue = (Datetime) c.get(mMappingFields.get(currentAnniversary.SinchTemplateId__c).get(letter));
                                fieldValue = dtValue.format('yyyy-MM-dd');
                            } else {
                                fieldValue = (String)c.get(mMappingFields.get(currentAnniversary.SinchTemplateId__c).get(letter));
                            }
                            contactValues[letter.charAt(0)-65] = fieldValue;
                        }
                        //if field is a Commercial_Periods__mdt field
                        else if(BA02_Utils.hasSObjectField(mMappingFields.get(currentAnniversary.SinchTemplateId__c).get(letter), commPeriodTest)){
                            if (commPeriodToday.get(mMappingFields.get(currentAnniversary.SinchTemplateId__c).get(letter)) instanceof Datetime) {
                                Datetime dtValue = (Datetime) commPeriodToday.get(mMappingFields.get(currentAnniversary.SinchTemplateId__c).get(letter));
                                fieldValue = dtValue.format('yyyy-MM-dd');
                            }
                            else{
                                fieldValue = (String) commPeriodToday.get(mMappingFields.get(currentAnniversary.SinchTemplateId__c).get(letter));
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
                AP48_WS_Utils.sendSMS(idTpl, strContacts, false, null, null);
            }
        }
        
        System.debug('Limits.getHeapSize() ' + Limits.getHeapSize());
        System.debug('Limits.getLimitHeapSize() ' + Limits.getLimitHeapSize());    
    }
}