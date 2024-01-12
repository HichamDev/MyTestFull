public without sharing class AP1000_Utils {

    public static final String REBATE_JOB_TITLE = 'Stanlover';
	
    @AuraEnabled(cacheable=true)
    public static String rebateJobTitle() {
        return 'Stanlover';
    }
    
    public static List<SelectOption> getPicklistOptions(sObject objObject, string fld) {
        List<SelectOption> allOpts = new List<SelectOption>();

        Schema.DescribeSObjectResult objDescribe = objObject.getSObjectType().getDescribe();

        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        System.debug(LoggingLevel.ERROR, '*** fieldMap.get(fld): ' + fieldMap.get(fld));
        List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a: values) {
            allOpts.add(new SelectOption(a.getLabel(), a.getValue()));
        }
        allOpts.sort();
        System.debug(LoggingLevel.ERROR, '*** allOpts: ' + allOpts);
        return allOpts;
    }

    public static Id getRecordTypeId(Id idObject) {
        
        String objName = idObject.getSObjectType().getDescribe().getName();
        
        String query = 'SELECT RecordTypeId FROM ' + objName + ' WHERE Id = \'' + idObject + '\'';

        return (String) Database.query(query).get(0).get('RecordTypeId');
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordTypeName(Id idObject) {

        // idObject = '0031j00000D55lyAAB';
        
        system.debug(idObject);
        String objName = idObject.getSObjectType().getDescribe().getName();
        
        String query = 'SELECT RecordType.DeveloperName FROM ' + objName + ' WHERE Id = \'' + idObject + '\'';

        Contact con = (Contact) Database.query(query);

        return con.RecordType.DeveloperName;
    }

    @AuraEnabled
    public static Boolean isManager(Id userId){
           User userManager = [SELECT Id, Profile.Name From User WHERE ID =: userId LIMIT 1];
           if(userManager != null && userManager.Profile.Name.contains('MANAGER')) return true;
           else return false;
    }
}