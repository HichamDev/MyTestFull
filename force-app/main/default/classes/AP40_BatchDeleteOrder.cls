global class AP40_BatchDeleteOrder implements Database.Batchable<sobject>{

    private DateTime currentCycleStartDate;
    private String countryOrder;

    global AP40_BatchDeleteOrder(String country){

        AP1001_Cycle_Utils.CycleInfo ci = AP1001_Cycle_Utils.getCountryCurrentCycle(country);
        system.debug('>>>> ci');
        system.debug(ci);
        currentCycleStartDate = ci.startdate;
        countryOrder = country;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        // (ITA) We remove the Effective Date filter. (Ticket#10835)
        // Date dt = Date.newInstance(currentCycleStartDate.year(), currentCycleStartDate.month(), currentCycleStartDate.day());     
        //String query = 'SELECT Id FROM Order WHERE EffectiveDate < :dt AND Status = \'Draft\' AND Type=\'LineUP\' AND Tech_External_Id__c LIKE \'' + countryOrder + '%\' ';
        String query = 'SELECT Id FROM Order WHERE Status = \'Draft\' AND Type=\'LineUP\' AND Tech_External_Id__c LIKE \'' + countryOrder + '%\' ';
        
        if (countryOrder == 'FRA'){
            // (FRA) We remove the Effective Date filter. (Ticket#10673)
           system.debug('>>>> COUNTRY (FRA)');            
            query = 'SELECT Id FROM Order WHERE Status = \'Draft\' AND Type=\'LineUP\' AND Tech_External_Id__c LIKE \'' + countryOrder + '%\' ';
        }
        
        system.debug('>>>> Query : '+ query);
                
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sobject> scope){

        delete scope;
    }

    global void finish(Database.BatchableContext BC){}
}