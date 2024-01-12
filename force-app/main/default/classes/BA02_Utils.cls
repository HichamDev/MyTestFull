public with sharing class BA02_Utils {
    
    public BA02_Utils() {
        
    }
    
    //extract contact fields from Mapping__c like "{FirstName} = {C}, {CurrentCommercialCycle__c} = {D}"
    //return a map of maps like 
    //  Map<nomSeniorite, Map<lettreAMapper, nomFieldSF>>
    //      Ex : {Argento={C=FirstName, D=CurrentCommercialCycle__c}, Bronzo={C=LastName, D=CurrentCommercialCycle__c}}
    public static Map<String, Map<String, String>> getMappingFieldsFromDealerSenioritySegments(){
        Map<String, Map<String, String>> mMappingFields = new Map<String, Map<String, String>>();
        for(DealerSeniority__mdt dsmdt : [select Mapping__c, SegmentName__c, SinchTemplateId__c from DealerSeniority__mdt]){
            Map<String,String> m = new Map<String,String>();
            if(dsmdt.Mapping__c != null && dsmdt.Mapping__c != ''){
                mMappingFields.put(dsmdt.SegmentName__c, getMappingFields(dsmdt.Mapping__c));
            }
        }
        return mMappingFields;
    }
    
    //return a map like 
    //  Map<nomSeniorite, SinchTemplateId>
    //      Ex : {Argento=4aa623ab-0178-424c-a107-326cd1119337, Bronzo=xxxxxxxx-xxxx-xxxx-xxxx-326cd1119337}
    public static Map<String, String> getMap_kSeniority_vSinchTplId(){
        Map<String, String> m_kSeniority_vSinchTplId = new Map<String, String>();
        for(DealerSeniority__mdt dsmdt : [select SegmentName__c, SinchTemplateId__c from DealerSeniority__mdt]){
            if(dsmdt.SegmentName__c != null && dsmdt.SegmentName__c != ''){
                m_kSeniority_vSinchTplId.put(dsmdt.SegmentName__c, dsmdt.SinchTemplateId__c);
            }
        }
        return m_kSeniority_vSinchTplId;
    }    
    
    //param mappingfields = "{FirstName} = {C}, {CurrentCommercialCycle__c} = {D}"
    public static Map<String, String> getMappingFields(String mappingfields){
        List<String> lmapping = mappingfields.split(',');
        Map<String, String> mMapping = new Map<String, String>();
        for(String letter : lmapping){
            List<String> fields = letter.split('=');
            mMapping.put(fields[1].trim().replace('{','').replace('}',''), fields[0].trim().replace('{','').replace('}',''));
        }
        return mMapping;
    }
    
    //make an array ['', '', * 26] to prepare datas to send to Sinch, as we have to put each contact value at its letter position. C=Lastname =>x [33600000000, ID, Dupont, ...]
    public static List<String> getEmptyContactValues(){
        String [] cv = new List<String>();
        for(Integer i =0; i<26;i++){
            cv.add('');
        }
        return cv;
    }
    
    // from contact values list to str made with these values. return this strinf '["33600000000", "xxxxxxxxxx as Id", "Dupont", ...]''
    public static String listToStr(List<String> l){
        String res = '[';
        for(String str : l){
            if(res != '['){
                res += ',';
            }
            res += '\"' + str + '\"';
        }
        res += ']';
        return res;
    }    
    
    //return a Map with DealerSeniority as key and idSinchTpl as value
    public static Map<String, String> getMapDealerSenioritiesIdSinchTemplate(){ 
        List<DealerSeniority__mdt> lDealerSeniorities = AP49_ReadCustomMetadatas.getDealerSeniorities_mdt();
        Map<String, String> mapRet = new Map<String, String>();
        for(DealerSeniority__mdt ds : lDealerSeniorities){
            if(ds.SinchTemplateId__c != ''){
                mapRet.put(ds.SegmentName__c, ds.SinchTemplateId__c);
            }
        }
        return mapRet;
    }
    
    //return a Map with idSinchTpl as key and DealerSeniority as value
    public static Map<String, String> getMapIdSinchTemplateDealerSeniorities(){ 
        List<DealerSeniority__mdt> lDealerSeniorities = AP49_ReadCustomMetadatas.getDealerSeniorities_mdt();
        Map<String, String> mapRet = new Map<String, String>();
        for(DealerSeniority__mdt ds : lDealerSeniorities){
            if(ds.SinchTemplateId__c != ''){
                mapRet.put(ds.SinchTemplateId__c, ds.SegmentName__c);
            }
        }
        return mapRet;
    }
    
    public static Set<Id> getContactsWithoutDuplicateMobilePhone(List<String> lMobilePhone){
        List<AggregateResult> aggregUniqueMobilePhone=[SELECT MobilePhone, count(Id) FROM Contact WHERE MobilePhone in :lMobilePhone GROUP BY MobilePhone HAVING count(MobilePhone) = 1];
        List<String> lUniqueMobilephone = new List<String>();
        for(AggregateResult aggres : aggregUniqueMobilePhone)
        {
            lUniqueMobilephone.add((String) aggres.get('MobilePhone'));
        }
        Set<Id> lContactWithoutDuplicateMobilePhone= new Map<Id, Contact>([SELECT Id from Contact WHERE MobilePhone in :lUniqueMobilephone]).keySet();
        System.debug('lUniqueMobilephone ' + lUniqueMobilephone);
        System.debug('lContactWithoutDuplicateMobilePhone ' + lContactWithoutDuplicateMobilePhone);
        return lContactWithoutDuplicateMobilePhone;
    }
    
    //true if so objetc contains fieldName field
    public static boolean hasSObjectField(String fieldName, SObject so){
        return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName.toLowerCase());
    }    
    
}