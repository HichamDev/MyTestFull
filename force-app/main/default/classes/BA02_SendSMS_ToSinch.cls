global class BA02_SendSMS_ToSinch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    //map where we will save all contacts as values with Id Sinch Template as key
    //in the finish method we will use it to send contacts to Sinch WS
    global Map<String, List<contact>> mIdSinchTplContacts = new Map<String, List<contact>>();
    
    //map of maps like this {Argento={Startdate__c=28/12/2019, Enddate__c=10/01/2020}, Bronzo={Startdate__c=28/12/2019, Enddate__c=10/01/2020}} in case we have fields of Commercial_Periods__mdt used in mapping
    global Map<String, Map<String, String>> m_dealerSeniority_commercialPeriodFieldsValues = AP49_ReadCustomMetadatas.get_m_dealerSeniority_commercialPeriodFieldsValues(false);
    
    global Map<String, String> mDealerSenioritiesIdSinchTemplate = BA02_Utils.getMapDealerSenioritiesIdSinchTemplate();
    
    global List<String> lDealerSeniorities = new List<String>();

    global BA02_SendSMS_ToSinch (List<String> lDealerSeniorities){
        this.lDealerSeniorities = lDealerSeniorities; 
    }
    
    //get a map of maps like this {Argento={C=FirstName, D=CurrentCommercialCycle__c}, Bronzo={C=LastName, D=CurrentCommercialCycle__c}}
    global Map<String, Map<String, String>> mMappingFields = BA02_Utils.getMappingFieldsFromDealerSenioritySegments();   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        AP49_ReadCustomMetadatas rcmdt = new AP49_ReadCustomMetadatas('Cycle'); //init with 'Cycle' as this batch will deal with sales commercial periods
        System.debug('BA0BA02_SendSMS_ToSinch rcmdt ' + rcmdt);
        System.debug('BA0BA02_SendSMS_ToSinch m_dealerSeniority_commercialPeriodFieldsValues ' + m_dealerSeniority_commercialPeriodFieldsValues);
        System.debug('BA0BA02_SendSMS_ToSinch mDealerSenioritiesIdSinchTemplate ' + mDealerSenioritiesIdSinchTemplate);
        System.debug('BA0BA02_SendSMS_ToSinch AP49_ReadCustomMetadatas.getAllDealerSenioritiesAtBeginnningPeriod() ' + AP49_ReadCustomMetadatas.getAllDealerSenioritiesAtBeginnningPeriod());
        //as we can have different delays before send a sms after a comm period beginning, we have to filter on delayseniority.delay + period.start

        String query = '';
        query = 'SELECT Id, MobilePhone from Contact WHERE Tech_Sinch_Field__c in :lDealerSeniorities';
        query += ' AND MobilePhone != \'\' AND TECH_ExternalId__c like \'%ITA%\'';
        query += ' AND OptinNewsletter1__c = true AND  HasOptedOutOfFax = false';
        query += ' AND Tech_Pardot_Send_SMS__c = true';
        if(!Test.isRunningTest()) query += ' AND LU_Available_for_Pardot__c = 1';
        return Database.getQueryLocator(query);    
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> contactsScope){
        System.debug('BA0BA02_SendSMS_ToSinch contacts contactsScope ' + contactsScope.size());
        try{
            //List of contact we have to send SMS if they have 
            //  - LU_Available_for_Pardot__c = 0 
            //  - Tech_Sinch_Field__c in 'Cycle Push' Campaign
            //  - DealerSeniority is at a beginning commercial period
            
            //créer liste mobilephone à partir des contacts du scope
            List<String> lContactsMobilePhone = new list<String>();
            for(Contact c:contactsScope){
                lContactsMobilePhone.add(c.MobilePhone);
            }
            
            //la passer à la méthode getContactWithoutDuplicateMobilePhone
            Set<Id> lContactWithoutDuplicateMobilePhone = BA02_Utils.getContactsWithoutDuplicateMobilePhone(lContactsMobilePhone);  
            
            //Edit JJE 13/04 : pas besoin de cette liste
            // List <Id> lContactsNotAvailableForPardot = new List<Id>(new Map<Id, Contact>([select Id from Contact WHERE TECH_ExternalId__c LIKE '%ITA%' AND LU_Available_for_Pardot__c = 0 AND Id in :lContactWithoutDuplicateMobilePhone]).keySet());
            System.debug('BA0BA02_SendSMS_ToSinch contactsScope ' + contactsScope);
            System.debug('BA0BA02_SendSMS_ToSinch lContactsMobilePhone ' + lContactsMobilePhone.size());
            System.debug('BA0BA02_SendSMS_ToSinch lContactsMobilePhone ' + lContactsMobilePhone);
            System.debug('BA0BA02_SendSMS_ToSinch lContactWithoutDuplicateMobilePhone ' + lContactWithoutDuplicateMobilePhone.size());
            System.debug('BA0BA02_SendSMS_ToSinch lContactWithoutDuplicateMobilePhone ' + lContactWithoutDuplicateMobilePhone);
            for(Id theId : lContactWithoutDuplicateMobilePhone){
                System.debug(theId);
            }
            // System.debug('BA0BA02_SendSMS_ToSinch lContactsNotAvailableForPardot ' + lContactsNotAvailableForPardot);
            // System.debug('BA0BA02_SendSMS_ToSinch contacts lContactsNotAvailableForPardot ' + lContactsNotAvailableForPardot.size());
            
            // //List of contact  we have to send SMS 
            // //  - LU_Available_for_Pardot__c = 1
            // //  - Tech_Sinch_Field__c in 'Cycle Push' Campaign
            // //  - DealerSeniority is at a beginning commercial period
            // //  - Linked Campaignmember with status != 'Push Email Open' 
            Set <Id> lContactsAvailableForPardot = new Set<Id>();
            Map<Id, Contact> contactsToSend = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Id in :lContactWithoutDuplicateMobilePhone AND Tech_Pardot_Send_SMS__c = true]); 
            lContactsAvailableForPardot = contactsToSend.keySet();

            //Edit JJE 13/04 : On ne passe plus par campaign members
            // List <CampaignMember> lCampMembersNotPushEmailOpen = [select contactId, Name from CampaignMember where  status != 'Push Email Open' and contactId in :lContactsAvailableForPardot];
            // List<Id> lContactIdNotPushEmailOpen = new List<Id>();
            // for(CampaignMember idC : lCampMembersNotPushEmailOpen){
            //     lContactIdNotPushEmailOpen.add(idC.contactId);
            // }

            //all contacts we have to send SMS to
            // List<Id> allContactsIdToSendSMS = new List<Id>();
            // allContactsIdToSendSMS.addAll(lContactsNotAvailableForPardot);
            // allContactsIdToSendSMS.addAll(lContactIdNotPushEmailOpen);
            // System.debug('BA0BA02_SendSMS_ToSinch contacts allContactsIdToSendSMS ' + allContactsIdToSendSMS.size() + ' ' + allContactsIdToSendSMS);
            System.Debug('mMappingFields ' + mMappingFields);
            // map of maps like this {Argento={FirstName=C, CurrentCommercialCycle__c=D}, Bronzo={LastName=C, CurrentCommercialCycle__c=d}}
            String fieldsToQuery = '';
            if((lContactsAvailableForPardot.size() != 0) && (mMappingFields.size() != 0)){
                Contact contactTest = new Contact();
                Commercial_Periods__mdt cmdcpTest = new Commercial_Periods__mdt();
                for(String seniority : mMappingFields.keySet()){
                    for(String letter : mMappingFields.get(seniority).keySet()){
                        if(!fieldsToQuery.contains(mMappingFields.get(seniority).get(letter))){
                            //if field is a contact field
                            if(BA02_Utils.hasSObjectField(mMappingFields.get(seniority).get(letter), contactTest)){
                                fieldsToQuery += ', ' + mMappingFields.get(seniority).get(letter);
                            }
                        }
                    }
                }
            }
            
            //set the query to get fields value to send them to Sinch for custom fields
            String contactsQuery = 'SELECT Mobilephone, Id, Tech_Sinch_Field__c ' + fieldsToQuery + ' FROM contact WHERE TECH_ExternalId__c LIKE \'%ITA%\' AND Id in :lContactsAvailableForPardot';
            List <contact> lContacts = Database.query(contactsQuery);
            System.debug('BA0BA02_SendSMS_ToSinch contacts allContactsIdToSendSMS ' + String.valueOf(lContacts.size()));
            Map<String, List<Contact>> mContacts = new  Map<String, List<Contact>>();
            for(Contact c : lContacts) {
                if(mIdSinchTplContacts.containsKey(c.Tech_Sinch_Field__c)) {
                    List<Contact> lC = mIdSinchTplContacts.get(c.Tech_Sinch_Field__c);
                    lC.add(c);
                    mIdSinchTplContacts.put(c.Tech_Sinch_Field__c, lC);
                } 
                else {
                    mIdSinchTplContacts.put(c.Tech_Sinch_Field__c, new List<Contact> {c});
                }
            }
            System.debug('BA02_SendSMS_ToSinch contacts mIdSinchTplContacts ' + mIdSinchTplContacts);

            // A la fin du batch, mettre à jour la liste des contacts
            // 10-08-2022 : plus besoin car automatisme dans Pardot à J+1
                // for(Contact c : contactsScope){
                //     c.Tech_Pardot_Send_SMS__c = false;
                // }
                // update new List<Contact>(lContacts);

        }
        catch(Exception error){
            System.debug('An error occured in batch BA01_CleanCampaignMembers ' + error);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        String [] contactEmptyValues = BA02_Utils.getEmptyContactValues();   // contactValues = ['', '', '', '', '', '', '', '', 26*] pour toutes les lettres de l'alphabet, potentielles champs de fusion pour Sinch
        Commercial_Periods__mdt commPeriodTest = new Commercial_Periods__mdt();
        //for each id Sinch template we set contacts array as a string
        Integer cptContactsTotal = 0;
        Integer cptContacts = 0;
        Set<Contact> contactsToUpdate = new Set<Contact>();
        for(String idTpl : mIdSinchTplContacts.keySet()){
            //for each contacts we have to send, with this id Sinch template
            cptContactsTotal = mIdSinchTplContacts.get(idTpl).size();
            cptContacts = 0;
            String strContacts = '[';
            for(Contact c : mIdSinchTplContacts.get(idTpl)){
                String [] contactValues = contactEmptyValues;
                contactValues[0] = c.MobilePhone;
                contactValues[1] = c.Id;
                if(mMappingFields.containsKey(c.Tech_Sinch_Field__c)){
                    for(String letter : mMappingFields.get(c.Tech_Sinch_Field__c).keySet()){
                        // System.debug('c letter ' + c + ' ' + letter);
                        //if field is a contact field
                        if(BA02_Utils.hasSObjectField(mMappingFields.get(c.Tech_Sinch_Field__c).get(letter), c)){
                            contactValues[letter.charAt(0)-65] = (String)c.get(mMappingFields.get(c.Tech_Sinch_Field__c).get(letter));
                        }
                        //if field is a Commercial_Periods__mdt field
                        else if(BA02_Utils.hasSObjectField(mMappingFields.get(c.Tech_Sinch_Field__c).get(letter), commPeriodTest)){
                            contactValues[letter.charAt(0)-65] = (String)m_dealerSeniority_commercialPeriodFieldsValues?.get(c.Tech_Sinch_Field__c)?.get(mMappingFields?.get(c.Tech_Sinch_Field__c)?.get(letter));
                        }                    
                    }
                }
                strContacts += BA02_Utils.listToStr(contactValues);
                if(cptContacts++ < cptContactsTotal - 1){
                    strContacts += ',';
                }
                contactsToUpdate.add(c);
            }
            strContacts += ']';
            
            // System.debug('+++ strContacts ' + mIdSinchTplContacts.get(idTpl).size());
             System.debug('+++ strContacts ' + mIdSinchTplContacts.get(idTpl).size() + ' ' + strContacts+ ' ' + cptContacts);
            if(!Test.isRunningTest()){
                AP48_WS_Utils.sendSMS(mDealerSenioritiesIdSinchTemplate.get(idTpl), strContacts, false, '10:00', idTpl);

                //Inutile car la synchro se fera sur Pardot
                // BatchContacts batch = new BatchContacts();
                // database.executebatch(batch, 200);
            }            
        }
        
        
        System.debug(Limits.getHeapSize());
        System.debug(Limits.getLimitHeapSize());    
        
    }
    
}