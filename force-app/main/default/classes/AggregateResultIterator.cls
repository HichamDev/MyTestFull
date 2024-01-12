global class AggregateResultIterator implements Iterator<AggregateResult> {
/*
// AggregateResultIterator
----------------------------------------------------------------------
-- - Name          : AggregateResultIterator
-- - Author        : YGO
-- - Description   : Iterator for batch AP30_BatchGroupBalance
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 20-MAY-2013  YGO    1.0      Intitial version
----------------------------------------------------------------------
**********************************************************************
*/
   AggregateResult [] results {get;set;}
   
   // tracks which result item is returned
   Integer index {get; set;}
          
   global AggregateResultIterator(Set<id> contactIds) {
      index = 0;
      // Fire query here to load the results
     
      String query = 'select SUM(AmountLP1__c) amt1, SUM(AmountLP2__c) amt2, SUM(AmountLP3__c) amt3, SUM(AmountLP4__c) amt4, SUM(AmountLP5__c) amt5, SUM(AmountLP6__c) amt6, SUM(AmountLP7__c) amt7, SUM(AmountLP8__c) amt8, SUM(AmountLP9__c) amt9, SUM(AmountLP10__c) amt10, SUM(AmountLP11__c) amt11, SUM(AmountLP12__c) amt12, SUM(AmountLP13__c) amt13, SUM(AmountLP14__c) amt14, SUM(AmountLP15__c) amt15, SUM(AmountLP16__c) amt16, SUM(AmountLP17__c) amt17, SUM(AmountLP18__c) amt18, SUM(AmountLP19__c) amt19, SUM(AmountLP20__c) amt20, SUM(AmountAdminFees__c) adm, SUM(AmountCommissions__c) com, Contact__c From STA_Statement__c where Contact__c in : contactIds and Status__c = \'Validated\' and Type__c = \'Transaction\' Group by Contact__c';
      
      String queryTest = 'select SUM(AmountLP1__c) amt1, SUM(AmountLP2__c) amt2, SUM(AmountLP3__c) amt3, SUM(AmountLP4__c) amt4, SUM(AmountLP5__c) amt5, SUM(AmountLP6__c) amt6, SUM(AmountLP7__c) amt7, SUM(AmountLP8__c) amt8, SUM(AmountLP9__c) amt9, SUM(AmountLP10__c) amt10, SUM(AmountLP11__c) amt11, SUM(AmountLP12__c) amt12, SUM(AmountLP13__c) amt13, SUM(AmountLP14__c) amt14, SUM(AmountLP15__c) amt15, SUM(AmountLP16__c) amt16, SUM(AmountLP17__c) amt17, SUM(AmountLP18__c) amt18, SUM(AmountLP19__c) amt19, SUM(AmountLP20__c) amt20, SUM(AmountAdminFees__c) adm, SUM(AmountCommissions__c) com, Contact__c From STA_Statement__c where Contact__c in : contactIds and Status__c = \'Validated\' and Type__c = \'Transaction\' Group by Contact__c limit 10';
      
      if(Test.isRunningTest()){
        results = Database.query(queryTest); 
      }else{
        
        results = Database.query(query); 
      }
      
      system.debug('### Result of query: ' + results);   
   }
    
   global boolean hasNext(){
      return results != null && !results.isEmpty() && index < results.size();
   }   
    
   global AggregateResult next(){       
      return results[index++];           
   }      
}