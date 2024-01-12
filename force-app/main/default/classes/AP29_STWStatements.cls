public without sharing class AP29_STWStatements {
/*
// AP29_STWStatements
---------------------------------------------------------------------
-- - Name          : AP29_STWStatements
-- - Author        : YGO
-- - Description   : Class to create and update statements
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  --------------------------------------
-- 02-MAY-2013  YGO    1.0      Initial version
-- 04-SEP-2014  NGO    2.0      Refractor class and add logic to create inverse LP  
---------------------------------------------------------------------
**********************************************************************
*/

     public static Id loyaltyProgramRecType;
 
     public static Id getLPRecordTypeId(){
            
          if(AP29_STWStatements.loyaltyProgramRecType == null){
            
               AP29_STWStatements.loyaltyProgramRecType = [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.STA_LoyaltyProgramRecType and SObjectType = 'STA_Statement__c' Limit 1].id;
          }
          return AP29_STWStatements.loyaltyProgramRecType ;
    }

    
    /*
    * Delete statement 
    */
    public static void deleteStatement (map<id, ORL_OrderLine__c> orderLineMap){
        
        Id recordTypeLoyaltyPrg = getLPRecordTypeId();
        
        list <STA_Statement__c>  statementsToBeDeleted = [Select OrderLine__c, Id , TECH_ExternalId__c From STA_Statement__c where OrderLine__c in: orderLineMap.keySet() and recordTypeId =: recordTypeLoyaltyPrg];

        if(statementsToBeDeleted.size() > 0){
            
            delete statementsToBeDeleted;
        } 
    }
    
    /**
    * Split LPcode and LPAmount and store in a List of LProgram
    */
    private static List<LProgram> getLPrograms(String lpCode, String lpAmount){
        
        List<LProgram> lps = new List<LProgram>();
        
        if(lpCode != null && lpCode.length() > 0){
            
            List<string> lpCodes = lpCode.split(';');
            
            List<string> lpAmounts = lpAmount.split(';');
            
            for(integer i = 0; i < lpCodes.size(); i++){
                
                lps.add(new LProgram(lpCodes[i], lpAmounts[i]));
                
            }
        }
        
        return lps;
        
    }
    
    
    private static void createStatement(list<ORL_OrderLine__c> orderLineList, integer factor)
    {
        STA_Statement__c newStatement;
        
        list<STA_Statement__c> statementList = new list <STA_Statement__c>();
        
        Id lPRecType = getLPRecordTypeId();

        for(integer i=0; i < orderLineList.size(); i++){
            
            List<LProgram> lps = getLPrograms(orderLineList[i].LPCode__c, orderLineList[i].LPAmount__c);
            
            for(LProgram lp : lps){
                
                
                    
                    system.debug('>>>List LP ' + lps);
                    newStatement = new STA_Statement__c();
                    
                    if(lp.lpCode == 'LP1')
                        newStatement.AmountLP1__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP2')
                        newStatement.AmountLP2__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP3')
                        newStatement.AmountLP3__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP4')
                        newStatement.AmountLP4__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP5')
                        newStatement.AmountLP5__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP6')
                        newStatement.AmountLP6__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP7')
                        newStatement.AmountLP7__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP8')
                        newStatement.AmountLP8__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP9')
                        newStatement.AmountLP9__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP10')
                        newStatement.AmountLP10__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP11')
                        newStatement.AmountLP11__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP12')
                        newStatement.AmountLP12__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP13')
                        newStatement.AmountLP13__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP14')
                        newStatement.AmountLP14__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP15')
                        newStatement.AmountLP15__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP16')
                        newStatement.AmountLP16__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP17')
                        newStatement.AmountLP17__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP18')
                        newStatement.AmountLP18__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP19')
                        newStatement.AmountLP19__c = lp.getLpAmount() * factor;
                    
                    if(lp.lpCode == 'LP20')
                        newStatement.AmountLP20__c = lp.getLpAmount() * factor;
                        
                    if(lp.lpCode == 'Com')
                        newStatement.AmountCommissions__c = lp.getLpAmount() * factor;
                        
                    if(lp.lpCode == 'Adm')
                        newStatement.AmountAdminFees__c = lp.getLpAmount() * factor; 

                    if(lp.lpCode == 'DIS')
                        newStatement.AmountDiscount__c = lp.getLpAmount() * factor; 
                    
                    newStatement.OrderLine__c = orderLineList[i].id;
                    
                    newStatement.TECHOrderLineExternalId__c = orderLineList[i].TECH_ExternalId__c;
                    
                    newStatement.Contact__c = orderLineList[i].TECH_DealerOrder__c;
                    
                    newStatement.Type__c = 'Transaction';
                
                    newStatement.RecordTypeId = lPRecType;
                    
                    newStatement.LpCode__c = lp.lpCode;
                    
                    system.debug('### Statement contact : ' + newStatement.Contact__c);
                    
                    statementList.add(newStatement);

                
            }
        }
        system.debug('## AP29_STWStatements createStatement statementList <<<<<'+statementList.size()); 
        
        if(statementList.size() > 0){
           
            insert statementList;
        }
            
    }
    
    /**
    * This method is called when an OrderLine status move from draft to pending.
    * LP 2 is reinitialize
    * Update Ordeline status 
    */
    public static void updateStatementFromOrderLine(list<ORL_OrderLine__c> orderLineListOld, list<ORL_OrderLine__c> orderLineListNew){
        
        system.debug('<<<< START updateStatementFromOrderLine >>>>');
        
        list<ORL_OrderLine__c> orderlineToCreated = new List<ORL_OrderLine__c>();
        
        list<ORL_OrderLine__c> orderlineToDelete = new List<ORL_OrderLine__c>();
        
        for(integer i=0; i < orderLineListNew.size(); i++){
            
            string orderStatusOld = orderLineListOld[i].TECH_OrderStatus__c;    
            
            string orderStatusNew = orderLineListNew[i].TECH_OrderStatus__c;
            
            if(orderStatusOld == null){
                
                orderStatusOld = '';
            }
            
            if(orderStatusNew == null){
                
                orderStatusNew = '';
            }
            
            system.debug('### trigger OrderLineAfterUpdate trigger.old[i].LPAmount__c'+ orderLineListOld[i].LPAmount__c);
            
            system.debug('### trigger OrderLineAfterUpdate trigger.new[i].LPCode__c'+ orderLineListNew[i].LPCode__c);
            
            system.debug('### trigger OrderLineAfterUpdate trigger.new[i].TECH_OrderStatus__c'+ orderStatusNew);
            
            system.debug('### trigger OrderLineAfterUpdate trigger.old[i].TECH_OrderStatus__c'+ orderStatusOld);
            
            if(string.isNotBlank(orderLineListNew[i].LPAmount__c) && isDraftToPending(orderStatusOld, orderStatusNew)){
                    
                orderlineToCreated.add(orderLineListNew[i]);
                
            }else if(string.isNotBlank(orderLineListNew[i].LPAmount__c) && isPendingToDraft(orderStatusOld, orderStatusNew)){
                
                orderlineToDelete.add(orderLineListNew[i]);
                
            }else{
                
            }
        }


        if(orderlineToCreated.size() > 0){
            
            createStatement(orderlineToCreated, 1);
        }
        
        if(orderlineToDelete.size() > 0){
            
            createStatement(orderlineToDelete, -1);
        }
        
        system.debug('<<<< END updateStatementFromOrderLine >>>>');
        
    }
    
    private static boolean isPendingToDraft(String oldStatus, String newStatus){
        
        return newStatus.equalsIgnoreCase(SHW_IBZ_Constants.ORDER_STATUS_DRAFT) && oldStatus.equalsIgnoreCase(SHW_IBZ_Constants.ORDER_STATUS_PENDING);
        
    } 
    
    private static boolean isDraftToPending(String oldStatus, String newStatus){
        
        return oldStatus.equalsIgnoreCase(SHW_IBZ_Constants.ORDER_STATUS_DRAFT) && newStatus.equalsIgnoreCase(SHW_IBZ_Constants.ORDER_STATUS_PENDING);
        
    } 
    
    
    /**
    * This method is called when an Order status is changedg.
    * LP 2 is reinitialize
    * Update Ordeline status 
    */
    public static void updateStatementFromOrder(map<id, string> orderMap){

        list<ORL_OrderLine__c> orderlinesToBeModified = new list<ORL_OrderLine__c>();
             
        system.debug('<<<< START updateStatementFromOrder >>>>');
        
        // re initialise LP2
        reinitailiseLP2(orderMap.keySet());
        
        for(ORL_OrderLine__c orderLine:[select id, Order__c from ORL_OrderLine__c where Order__c IN:orderMap.keySet()]){
            
            orderline.TECH_OrderStatus__c = orderMap.get(orderLine.Order__c);
            
            orderlinesToBeModified.add(orderline);
            
        }
       
        if(orderlinesToBeModified.size() > 0){
            
            update orderlinesToBeModified;
        }
        
        system.debug('<<<< END updateStatementFromOrder >>>>');
    }
    
    private static void reinitailiseLP2(Set<Id> orderIds){
        
        system.debug('<<<< START reinitailiseLP2 >>>>');
        Set<String> allActiveResets= new Set<String>();
        Set<String> allInvolvedResetCountry= new Set<String>();
        Map<String, Set<String>> countryMapLP= new Map<String, Set<String>>();
        Map<String, LP_Reset_Per_Country__c> allCountryResets = LP_Reset_Per_Country__c.getAll();
        for(String theReset : allCountryResets.keySet()){
            if(allCountryResets.get(theReset).LP_isReset__c){
                allActiveResets.add(theReset);
                List<String> tempCountry = theReset.split('_');
                allInvolvedResetCountry.add(tempCountry[1]);
                if(countryMapLP.containsKey(tempCountry[1])){
                    countryMapLP.get(tempCountry[1]).add(tempCountry[0]);
                }else{
                    countryMapLP.put(tempCountry[1], new Set<String>{tempCountry[0]});   
                }
            }
        }
        system.debug('<<<< reinitailiseLP2 allInvolvedResetCountry>>>>'+allInvolvedResetCountry);
        system.debug('<<<< reinitailiseLP2 allActiveResets>>>>'+allActiveResets);
        system.debug('<<<< reinitailiseLP2 countryMapLP>>>>'+countryMapLP);
        if(orderIds != null){
            
            Set<Id> dealers = new Set<Id>();
            
            List<STA_Statement__c> toBeUpdated = new List<STA_Statement__c>();
            
            List<STA_Statement__c> toBeDeleted = new List<STA_Statement__c>();
        
            for( ORD_Order__c myOrder : [select id , dealer__c, Country_Code__c from ORD_Order__c where id in : orderIds]){
                if(allInvolvedResetCountry.contains(myOrder.Country_Code__c)){
                    dealers.add(myOrder.dealer__c);
                }
            }
            
            system.debug('<<<<  reinitailiseLP2 dealers >>>>' + dealers);

            for(STA_Statement__c s: [select LpCode__c,Country_code__c,Type__c, Contact__c from STA_Statement__c where Type__c = 'Balance' and Contact__c in :dealers])
            {
                if(allActiveResets.contains(s.LpCode__c+'_'+s.Country_code__c)){
                    if(s.LpCode__c.equals('LP1')){
                        s.AmountLP1__c = 0;
                    }
                    if(s.LpCode__c.equals('LP2')){
                        s.AmountLP2__c = 0;
                    }
                    if(s.LpCode__c.equals('LP3')){
                        s.AmountLP3__c = 0;
                    }
                    if(s.LpCode__c.equals('LP4')){
                        s.AmountLP4__c = 0;
                    }
                    if(s.LpCode__c.equals('LP5')){
                        s.AmountLP5__c = 0;
                    }
                    if(s.LpCode__c.equals('LP6')){
                        s.AmountLP6__c = 0;
                    }
                    if(s.LpCode__c.equals('LP7')){
                        s.AmountLP7__c = 0;
                    }
                    if(s.LpCode__c.equals('LP8')){
                        s.AmountLP8__c = 0;
                    }
                    if(s.LpCode__c.equals('LP9')){
                        s.AmountLP9__c = 0;
                    }
                    if(s.LpCode__c.equals('LP10')){
                        s.AmountLP10__c = 0;
                    }
                    if(s.LpCode__c.equals('LP11')){
                        s.AmountLP11__c = 0;
                    }
                    if(s.LpCode__c.equals('LP12')){
                        s.AmountLP12__c = 0;
                    }
                    if(s.LpCode__c.equals('LP13')){
                        s.AmountLP13__c = 0;
                    }
                    if(s.LpCode__c.equals('LP14')){
                        s.AmountLP14__c = 0;
                    }
                    if(s.LpCode__c.equals('LP15')){
                        s.AmountLP15__c = 0;
                    }
                    if(s.LpCode__c.equals('LP16')){
                        s.AmountLP16__c = 0;
                    }
                    if(s.LpCode__c.equals('LP17')){
                        s.AmountLP17__c = 0;
                    }
                    if(s.LpCode__c.equals('LP18')){
                        s.AmountLP18__c = 0;
                    }
                    if(s.LpCode__c.equals('LP19')){
                        s.AmountLP19__c = 0;
                    }
                    if(s.LpCode__c.equals('LP20')){
                        s.AmountLP20__c = 0;
                    }
                    if(s.LpCode__c.equals('ADM')){
                        s.AmountAdminFees__c = 0;
                    }
                    if(s.LpCode__c.equals('COM')){
                        s.AmountCommissions__c = 0;
                    }
                    if(s.LpCode__c.equals('DIS')){
                        s.AmountDiscount__c = 0;
                    }
                    toBeUpdated.add(s);
                }
            }

            String querySTAToDelete='select Type__c, Contact__c from STA_Statement__c where Type__c = \'Transaction\' and Contact__c in :dealers and ( ';

            if(countryMapLP.size()>0){
                integer counter=0;
                for(String theCountry : countryMapLP.keySet()){
                    Set<String> theCountryLPs= countryMapLP.get(theCountry);
                    if(counter<1){
                        querySTAToDelete=querySTAToDelete+' (Country_code__c=\''+theCountry+'\' and  LpCode__c =: theCountryLPs) ';
                    }else{
                        querySTAToDelete=querySTAToDelete+' or (Country_code__c=\''+theCountry+'\' and  LpCode__c =: theCountryLPs) ';
                    }
                    system.debug('<<<<  reinitailiseLP2 theCountryLPs >>>>' + theCountryLPs);
                    counter++;
                }
                querySTAToDelete=querySTAToDelete+' ) ';
                //fetch all statements that have to be deleted to reinitialise the correct LP and for the correct country code
                system.debug('<<<<  reinitailiseLP2 Query for STA to be deleted >>>>' + querySTAToDelete);
                List<STA_Statement__c> listTemptoBeDeleted = new list<STA_Statement__c>();
                listTemptoBeDeleted =   database.query(querySTAToDelete);
                toBeDeleted.addAll(listTemptoBeDeleted);
            }
            


            system.debug('<<<<  reinitailiseLP2 toBeUpdated >>>>' + toBeUpdated);
            
            system.debug('<<<<  reinitailiseLP2 toBeDeleted >>>>' + toBeDeleted);
            
            if(toBeDeleted.size() > 0)
                delete toBeDeleted;
                
            if(toBeUpdated.size() > 0)
                update toBeUpdated;
        }
        
        system.debug('<<<< END reinitailiseLP2 >>>>');
    }
    
    
    /**
    *Method to delete transaction corresponding to a balance 
    */
    public static void deleteAllTransactionStatement(List<StatementLPCode> statements, String sta_LoyaltyProgRecTypeId){
        
        List<STA_Statement__c> staToBeDel = new List<STA_Statement__c>();
        
        Set<String> lpcodes = new Set<String>(); 
        
        Set<Id> contacts = new Set<Id>(); 
        
        for(StatementLPCode sta : statements){
            
            lpcodes.add(sta.lp_code);
            contacts.add(sta.statement.Contact__c);
            
        }
       
        List<STA_Statement__c> transactions = [select id, Contact__c, LpCode__c from STA_Statement__c where Type__c = 'Transaction' 
                and recordTypeId =: sta_LoyaltyProgRecTypeId
                and LpCode__c in :lpcodes
                and Contact__c in :contacts
                ];
        
        for(StatementLPCode sta : statements){
            
            system.debug('### deleteAllTransactionStatement statements.size(): ' + statements);
            
            for(STA_Statement__c transactionStatement : transactions){
            
                if(transactionStatement.Contact__c == sta.statement.Contact__c &&  transactionStatement.LpCode__c == sta.lp_code){
                
                    staToBeDel.add(transactionStatement);
                
                }
            }
        }
        delete staToBeDel;
    }
    
    
    public static void updateStatementFromBO(List<STA_Statement__c> statements, Map<Id, STA_Statement__c> mapOld){
        
       system.debug('### updateStatementFromBO statements ' + statements);
       
        Double STATEMENT_BYPASS_VALUE = null;
        
        List<statementLPCode> transactionToBeDeleted = new List<statementLPCode>();
        
        string sta_LoyaltyProgRecTypeId =  getLPRecordTypeId();
        
        system.debug('### updateStatementFromBO sta_LoyaltyProgRecTypeId ' + sta_LoyaltyProgRecTypeId);
        
        for(STA_Statement__c statement : statements){
            
            system.debug('### updateStatementFromBO statement.Type__c ' + statement.Type__c);
            
            if(statement.RecordTypeId == sta_LoyaltyProgRecTypeId ){
                
                if(statement.Type__c != null && statement.Type__c.equals('Balance')){
         
                    if(statement.AmountLP1__c == STATEMENT_BYPASS_VALUE){
                    
                        statement.AmountLP1__c = mapOld.get(statement.Id).AmountLP1__c;
                    
                    }else if(statement.AmountLP1__c != mapOld.get(statement.Id).AmountLP1__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP1'));
                    }
                    
                    if(statement.AmountLP2__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP2__c = mapOld.get(statement.Id).AmountLP2__c;
                        
                    }else if(statement.AmountLP2__c != mapOld.get(statement.Id).AmountLP2__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP2'));
                    }
                    
                    if(statement.AmountLP3__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP3__c = mapOld.get(statement.Id).AmountLP3__c;
                        
                    }else if(statement.AmountLP3__c != mapOld.get(statement.Id).AmountLP3__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP3'));
                    }
                    
                    if(statement.AmountLP4__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP4__c = mapOld.get(statement.Id).AmountLP4__c;
                        
                    }else if(statement.AmountLP4__c != mapOld.get(statement.Id).AmountLP4__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP4'));
                    }
                    
                    if(statement.AmountLP5__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP5__c = mapOld.get(statement.Id).AmountLP5__c;
                        
                    }else if(statement.AmountLP5__c != mapOld.get(statement.Id).AmountLP5__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP5'));
                    }
                    
                    if(statement.AmountLP6__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP6__c = mapOld.get(statement.Id).AmountLP6__c;
                        
                    }else if(statement.AmountLP6__c != mapOld.get(statement.Id).AmountLP6__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP6'));
                    }
                    
                    if(statement.AmountLP7__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP7__c = mapOld.get(statement.Id).AmountLP7__c;
                        
                    }else if(statement.AmountLP7__c != mapOld.get(statement.Id).AmountLP7__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP7'));
                    }
                    
                    if(statement.AmountLP8__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP8__c = mapOld.get(statement.Id).AmountLP8__c;
                        
                    }else if(statement.AmountLP8__c != mapOld.get(statement.Id).AmountLP8__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP8'));
                    }
                    
                    if(statement.AmountLP9__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP9__c = mapOld.get(statement.Id).AmountLP9__c;
                        
                    }else if(statement.AmountLP9__c != mapOld.get(statement.Id).AmountLP9__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP9'));
                    }
                    
                    if(statement.AmountLP10__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP10__c = mapOld.get(statement.Id).AmountLP10__c;
                        
                    }else if(statement.AmountLP10__c != mapOld.get(statement.Id).AmountLP10__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP10'));
                    }
                    
                    if(statement.AmountLP11__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP11__c = mapOld.get(statement.Id).AmountLP11__c;
                        
                    }else if(statement.AmountLP11__c != mapOld.get(statement.Id).AmountLP11__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP11'));
                    }
                    
                    if(statement.AmountLP12__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP12__c = mapOld.get(statement.Id).AmountLP12__c;
                        
                    }else if(statement.AmountLP12__c != mapOld.get(statement.Id).AmountLP12__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP12'));
                    }
                    
                    if(statement.AmountLP13__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP13__c = mapOld.get(statement.Id).AmountLP13__c;
                        
                    }else if(statement.AmountLP13__c != mapOld.get(statement.Id).AmountLP13__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP13'));
                    }
                    
                    if(statement.AmountLP14__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP14__c = mapOld.get(statement.Id).AmountLP14__c;
                        
                    }else if(statement.AmountLP14__c != mapOld.get(statement.Id).AmountLP14__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP14'));
                    }
                    
                    if(statement.AmountLP15__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP15__c = mapOld.get(statement.Id).AmountLP15__c;
                        
                    }else if(statement.AmountLP15__c != mapOld.get(statement.Id).AmountLP15__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP15'));
                    }
                    
                    if(statement.AmountLP16__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP16__c = mapOld.get(statement.Id).AmountLP16__c;
                        
                    }else if(statement.AmountLP16__c != mapOld.get(statement.Id).AmountLP16__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP16'));
                    }
                    
                    if(statement.AmountLP17__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP17__c = mapOld.get(statement.Id).AmountLP17__c;
                        
                    }else if(statement.AmountLP17__c != mapOld.get(statement.Id).AmountLP17__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP17'));
                    }
                    
                    if(statement.AmountLP18__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP18__c = mapOld.get(statement.Id).AmountLP18__c;
                        
                    }else if(statement.AmountLP18__c != mapOld.get(statement.Id).AmountLP18__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP18'));
                    }
                    
                    if(statement.AmountLP19__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP19__c = mapOld.get(statement.Id).AmountLP19__c;
                        
                    }else if(statement.AmountLP19__c != mapOld.get(statement.Id).AmountLP19__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP19'));
                    }
                    
                    if(statement.AmountLP20__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountLP20__c = mapOld.get(statement.Id).AmountLP20__c;
                        
                    }else if(statement.AmountLP20__c != mapOld.get(statement.Id).AmountLP20__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'LP20'));
                    }
                           
                    if(statement.AmountCommissions__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountCommissions__c = mapOld.get(statement.Id).AmountCommissions__c;
                        
                    }else if(statement.AmountCommissions__c != mapOld.get(statement.Id).AmountCommissions__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'Com'));
                    }
                    
                    
                    if(statement.AmountAdminFees__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountAdminFees__c = mapOld.get(statement.Id).AmountAdminFees__c;
                        
                    }else if(statement.AmountAdminFees__c != mapOld.get(statement.Id).AmountAdminFees__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'Adm'));
                    } 

                    if(statement.AmountDiscount__c == STATEMENT_BYPASS_VALUE){
                        
                        statement.AmountDiscount__c = mapOld.get(statement.Id).AmountDiscount__c;
                        
                    }else if(statement.AmountDiscount__c != mapOld.get(statement.Id).AmountDiscount__c){
                        
                        transactionToBeDeleted.add(new StatementLPCode(statement, 'DIS'));
                    } 
                }     
            }
        }
       
        if(transactionToBeDeleted.size() > 0){
            deleteAllTransactionStatement(transactionToBeDeleted, sta_LoyaltyProgRecTypeId);
        }
    }
    
    public class StatementLPCode {
        
        public statementLPCode(STA_Statement__c statement, String lp_code){
            
            this.statement = statement;
            
            this.lp_code = lp_code;
            
        }
        
        STA_Statement__c statement {get; set;}
        
        String lp_code {get; set;}
    }
    
    public class LProgram {
        
        public String lpCode {get;set;}
        
        public String lpAmount {get;set;}
        
        LProgram(String lpCode, String lpAmount){
            
            this.lpCode = lpCode;
            this.lpAmount = lpAmount;
        }
        
        public decimal getLpAmount(){
            
            return  decimal.valueOf(lpAmount);
            
        }
        
    }
}