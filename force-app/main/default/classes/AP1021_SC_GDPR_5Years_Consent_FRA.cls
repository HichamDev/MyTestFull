global with sharing class AP1021_SC_GDPR_5Years_Consent_FRA implements Schedulable {
    
    global void execute (SchedulableContext sc) {       
        system.debug('## Start scheduler AP1021_Batch_GDPR_5Years_Consent<<<<<');
        AP1021_Batch_GDPR_5Years_Consent batch = new AP1021_Batch_GDPR_5Years_Consent('FRA');
        database.executebatch(batch);
        system.debug('## End scheduler AP1021_Batch_GDPR_5Years_Consent <<<<<');
    }

}