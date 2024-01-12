public without sharing class LCP03_RecordType_Selection_Ctrl {
   
   
    @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        system.debug('>>>>> fetchRecordTypeValues START');
        List<Schema.RecordTypeInfo> recordtypes = AGI_AgendaItem__c.SObjectType.getDescribe().getRecordTypeInfos();    
        Map<Id, String> recordtypemap = new Map<Id, String>();
        system.debug('>>>>> recordtypes');
        system.debug(recordtypes);
        for (RecordTypeInfo rt : recordtypes) {
            system.debug('>>>>> rt: ' + rt);
            if (rt.isMaster() == false && rt.isAvailable() == true && rt.isActive() == true){
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        }
        system.debug('>>>>> recordtypemap');
        system.debug(recordtypemap);
        return recordtypemap.values();
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.AGI_AgendaItem__c.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }     


}