global with sharing class AP50_Btn_Test_Sinch_Templates {
    
    
    @AuraEnabled
    public static String sendTests(){
        AP46_Sinch.WSReturn vWSReturn = new AP46_Sinch.WSReturn();
        Map<String, contact> mIdSinchTplContacts = new Map<String, contact>();
        //get current birthday settings from metadata
        Birthday_Settings__mdt currentBirthday = AP49_ReadCustomMetadatas.getCurrentBirthdayMdt();        
        Map<String, String> m_kSeniority_vSinchTplId = BA02_Utils.getMap_kSeniority_vSinchTplId();        
        Map<String, Map<String, String>> mMappingFieldsDS = BA02_Utils.getMappingFieldsFromDealerSenioritySegments();  
        
        Map<String, Map<String, String>> mMappingFieldsBirthday = BA03_Utils.getMappingFieldsFromBirthdayCmdt();  
        
        //map of maps like this {Argento={Startdate__c=28/12/2019, Enddate__c=10/01/2020}, Bronzo={Startdate__c=28/12/2019, Enddate__c=10/01/2020}} in case we have fields of Commercial_Periods__mdt used in mapping
        Map<String, Map<String, String>> m_dealerSeniority_commercialPeriodFieldsValues = AP49_ReadCustomMetadatas.get_m_dealerSeniority_commercialPeriodFieldsValues(true);
        Commercial_Periods__mdt commPeriodTest = new Commercial_Periods__mdt();

        //mMappingFields like   
        //{265f9fcd-9716-4ce6-8295-5943f42bb999={C=LastName, D=CurrentCommercialCycle__c}, 4aa623ab-0178-424c-a107-326cd1119337={D=CurrentCommercialCycle__c, F=Email}}
        Map<String, Map<String, String>> mMappingFields = new Map<String, Map<String, String>> ();
        for(String DSName : mMappingFieldsDS.keySet()){
            mMappingFields.put(m_kSeniority_vSinchTplId.get(DSName), mMappingFieldsDS.get(DSName));
        }
        mMappingFields.putAll(mMappingFieldsBirthday);
        Contact contactforType = new Contact();
        String fieldsToQuery = '';
        for(String seniority : mMappingFields.keySet()){
            for(String letter : mMappingFields.get(seniority).keySet()){
                if(!fieldsToQuery.contains(mMappingFields.get(seniority).get(letter))){
                    if(BA02_Utils.hasSObjectField(mMappingFields.get(seniority).get(letter), contactforType)){
                        fieldsToQuery += ', ' + mMappingFields.get(seniority).get(letter);
                    }
                }
            }
        }

        String contactsQuery = 'SELECT Mobilephone, Id, DealerSenioritySegment__c ' + fieldsToQuery + ' FROM contact where name like \'%TEST_TEMPLATE_SINCH%\'';
        List <Contact> contactTest = Database.query(contactsQuery);
        
        if(contactTest.size() > 0){
            
            for(String seniorityName : mMappingFieldsDS.keySet()){
                mIdSinchTplContacts.put(m_kSeniority_vSinchTplId.get(seniorityName), contactTest[0]);
            }
            for(String birthdayIdTpl : mMappingFieldsBirthday.keySet()){
                mIdSinchTplContacts.put(birthdayIdTpl, contactTest[0]);
            }    
            
            String [] contactEmptyValues = BA02_Utils.getEmptyContactValues();   
            //for each id Sinch template we set contacts array as a string
            for(String idTpl : mIdSinchTplContacts.keySet()){
                //for each contacts we have to send, with this id Sinch template
                String strContacts = '[';
                String [] contactValues = BA02_Utils.getEmptyContactValues();   // contactValues = ['', '', '', '', '', '', '', '', 26*] pour toutes les lettres de l'alphabet, potentielles champs de fusion pour Sinch
                contactValues[0] = mIdSinchTplContacts.get(idTpl).MobilePhone;
                contactValues[1] = mIdSinchTplContacts.get(idTpl).Id;
                
                for(String letter : mMappingFields.get(idTpl).keySet()){
                    //if field is a contact field
                    if(BA02_Utils.hasSObjectField(mMappingFields.get(idTpl).get(letter), contactTest[0])){
                        contactValues[letter.charAt(0)-65] = (String) contactTest[0].get(mMappingFields.get(idTpl).get(letter));
                    }
                    //if field is a Commercial_Periods__mdt field
                    else if(BA02_Utils.hasSObjectField(mMappingFields.get(idTpl).get(letter), commPeriodTest) &&
                    contactTest[0].DealerSenioritySegment__c != null &&
                    mMappingFields.get(idTpl) != null  && 
                    mMappingFields.get(idTpl).get(letter) != null  && 
                    m_dealerSeniority_commercialPeriodFieldsValues.get(contactTest[0].DealerSenioritySegment__c) != null ){
                        contactValues[letter.charAt(0)-65] = (String)m_dealerSeniority_commercialPeriodFieldsValues.get(contactTest[0].DealerSenioritySegment__c).get(mMappingFields.get(idTpl).get(letter));
                    }                    
                }
                
                strContacts += BA02_Utils.listToStr(contactValues);
                System.debug('AP50_Btn_Test_Sinch_Templates contactValues ' + BA02_Utils.listToStr(contactValues));
                // if(strContacts != '['){strContacts += ',';}
                // strContacts += '[\"' + c.MobilePhone + '\","' + c.Id + '\"]';
                
                strContacts += ']';
                
                if(!Test.isRunningTest()){
                    vWSReturn = AP48_WS_Utils.sendSMS(idTpl, strContacts, true, null, null);            
                }
                System.debug('+++ vWSReturn ' + vWSReturn);
            }
        }
        return 'Tests SMS sended.';
    }
}