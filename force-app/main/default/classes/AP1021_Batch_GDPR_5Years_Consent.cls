global without sharing class AP1021_Batch_GDPR_5Years_Consent implements Database.Batchable<sobject> {
    
    /* VARIABLES */
    global string country; 
    
    /* CONSTRUCTOR */
    /* Parameter : 
        - country : country for which the batch runs*/
    public AP1021_Batch_GDPR_5Years_Consent(String forCountry) {
        this.country = forCountry;
    }

    /* BATCH METHOD : START */
    global Database.QueryLocator start(Database.BatchableContext BC) {
	 	
        system.debug('>> AP1021_Batch_GDPR_5Years_Consent - Country : ' + country);
        DateTime dt = DateTime.now().addYears(-5).addMonths(1);
        String formattedDt = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String query = 'SELECT Id, HasOptedOutOfEmail, LU_Consent_Answer_Date__c FROM Contact WHERE Contact.Owner.TECH_ExternalId__c LIKE \'' + country + '%\' ' +
                        ' AND RecordType.DeveloperName = \'LU_Personal_Contact\' ' +
                        ' AND Contact.LU_Consent_Answer_Date__c <= ' + formattedDt + ' AND Contact.HasOptedOutOfEmail = false '; 
        system.debug('>>> query: ' + query);
        return Database.getQueryLocator(query);
    }

    /* BATCH METHOD : EXECUTE */
    global void execute(Database.BatchableContext BC, List<sobject> scope){
	 	
        system.debug('>> START AP1021_Batch_GDPR_5Years_Consent');
        system.debug('>>> scope : ' + scope.size());
        
        /* Variables */
        List<Contact> lContacts = new list<Contact>();
        for (sobject so : scope) {
            Contact c = (Contact) so;
            c.HasOptedOutOfEmail = true;
            c.LU_Consent_Answer_Date__c = null;
            lContacts.add(c);
        }
        
        update lContacts;
    }

    /* BATCH METHOD : FINISH */
    global void finish(Database.BatchableContext BC){ }

}