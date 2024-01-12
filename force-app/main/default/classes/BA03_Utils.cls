public with sharing class BA03_Utils {
    public BA03_Utils() {
        
    }
    
    //extract contact fields from Mapping__c like "{FirstName} = {C}, {CurrentCommercialCycle__c} = {D}"
    //return a map of maps like 
    //  Map<SinchTplId, Map<lettreAMapper, nomFieldSF>>
    //      Ex : {4aa623ab-0178-424c-a107-326cd1119337 = {C=FirstName, D=CurrentCommercialCycle__c}}
    public static Map<String, Map<String, String>> getMappingFieldsFromBirthdayCmdt(){
        Map<String, Map<String, String>> mMappingFields = new Map<String, Map<String, String>>();
        for(Birthday_Settings__mdt bsmdt : [select Mapping__c, SinchTemplateId__c from Birthday_Settings__mdt]){
            Map<String,String> m = new Map<String,String>();
            if(bsmdt.Mapping__c != null && bsmdt.Mapping__c != ''){
                mMappingFields.put(bsmdt.SinchTemplateId__c, BA02_Utils.getMappingFields(bsmdt.Mapping__c));
            }
        }
        return mMappingFields;
    }
}