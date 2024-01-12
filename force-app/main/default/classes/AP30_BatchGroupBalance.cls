global class AP30_BatchGroupBalance implements Database.Batchable<sobject>, Database.Stateful{
/*
// AP30_BatchGroupBalance
----------------------------------------------------------------------
-- - Name          : AP30_BatchGroupBalance
-- - Author        : YGO
-- - Description   : Batch class to group all statements of type validated
--           and consolidate their balance according to the code.
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 20-MAY-2013  YGO    1.0      Intitial version
-- 22-APR-2014  NGO     2.0      Refactoring to treat batch per contact instead per statement.  
----------------------------------------------------------------------
**********************************************************************
*/
  public set<id> contactIdSet = new set<id>();
    
  public STA_Statement__c statementToUpdate;
  public STA_Statement__c statementToCreate;
  public STA_Statement__c balance;
  
  
  public list<STA_Statement__c> statementList = new list<STA_Statement__c>();
  
  public map<id, STA_Statement__c> statementContactMap = new map<id, STA_Statement__c>();
  
  public decimal lp1, lp2, lp3, lp4, lp5, lp6, lp7, lp8, lp9, lp10, lp11, lp12, lp13, lp14, lp15, lp16, lp17, lp18, lp19, lp20, adm, com;

  public string country;
  public dateTime timeStarted;
  public Set<Id> transactionListToBeDeleted= new set<id>();
  
  public string sta_LoyaltyProgRecTypeId =  [SELECT r.id FROM RecordType r WHERE DeveloperName = :system.label.STA_LoyaltyProgramRecType and SObjectType = 'STA_Statement__c' Limit 1].id;

  public static final String STA_STATUS_VALIDATED = 'Validated';
  
  public static final String STA_TYPE_BALANCE = 'Balance';
  
  public static final String STA_TYPE_TRANSACTION = 'Transaction';
  
  /* Happy project */
  public Set<String> lpToVerifySet = new Set<String>();

  public Set<Id> setInterfaceUserIdOrProfileId = new Set<Id>();
  // Map<Id, Decimal> mapContactIdOrdersTotalAmount = new Map<Id, Decimal>();
  
  global AP30_BatchGroupBalance(String forCountry){
    
    country = forCountry;
    timeStarted = system.now();

    /* Happy project */
    for (LP_Statement_Summerize__mdt lpStatementSummerize : [SELECT MasterLabel, QualifiedApiName, Country__c, LP_Name__c, Is_Verified__c 
                                                             FROM LP_Statement_Summerize__mdt WHERE Country__c = :forCountry AND Is_Verified__c = true]) {
      lpToVerifySet.add(lpStatementSummerize.LP_Name__c);
    }

    /* Need to bypass the minimun transaction verifiaction when a statement is inserted by interface from back office */
    for (User__c userCountrySetting : [SELECT SetupOwnerId FROM User__c WHERE isInterfaceUser__c = true]) {
      setInterfaceUserIdOrProfileId.add(userCountrySetting.SetupOwnerId);
    }    
}

  
  global Database.QueryLocator start(Database.batchableContext info)
{
    
    system.debug('## start country ' + country);
     
    // String query = 'select  AmountLP1__c ,  AmountLP2__c ,  AmountLP3__c ,  AmountLP4__c ,  AmountLP5__c ,  AmountLP6__c ,  AmountLP7__c ,  AmountLP8__c ,  AmountLP9__c ,  AmountLP10__c ,  AmountLP11__c ,  AmountLP12__c ,  AmountLP13__c ,  AmountLP14__c ,  AmountLP15__c ,  AmountLP16__c ,  AmountLP17__c ,  AmountLP18__c ,  AmountLP19__c ,  AmountLP20__c ,  AmountAdminFees__c ,  AmountCommissions__c , Contact__c,Contact__r.Id,LpCode__c  From STA_Statement__c where Contact__r.AccountCountryCode__c = \''+country+'\' and Status__c = \'Validated\' and Type__c = \'Transaction\' and RecordTypeId = \''+sta_LoyaltyProgRecTypeId+'\' and LpCode__c!=\'\' order by Contact__c,LpCode__c ';
    /* Happy project */
    String query = 
      'SELECT  AmountLP1__c, AmountLP2__c, AmountLP3__c, AmountLP4__c, AmountLP5__c, AmountLP6__c, AmountLP7__c, AmountLP8__c, AmountLP9__c, AmountLP10__c, AmountLP11__c, AmountLP12__c, AmountLP13__c, AmountLP14__c, AmountLP15__c, AmountLP16__c, AmountLP17__c, AmountLP18__c, AmountLP19__c, AmountLP20__c, ' + 
              'AmountAdminFees__c, AmountCommissions__c, Contact__c, Contact__r.Id, LpCode__c, OrderLine__r.Order__r.TECH_TotalPrice__c, ' +
              'CreatedById, CreatedBy.ProfileId, Contact__r.OrderAmountLimitForLp1__c, Contact__r.OrderAmountLimitForLp2__c, Contact__r.OrderAmountLimitForLp3__c, Contact__r.OrderAmountLimitForLp4__c, Contact__r.OrderAmountLimitForLp5__c, Contact__r.OrderAmountLimitForLp6__c, Contact__r.OrderAmountLimitForLp7__c, Contact__r.OrderAmountLimitForLp8__c, Contact__r.OrderAmountLimitForLp9__c, Contact__r.OrderAmountLimitForLp10__c, Contact__r.OrderAmountLimitForLp11__c, Contact__r.OrderAmountLimitForLp12__c, Contact__r.OrderAmountLimitForLp13__c, Contact__r.OrderAmountLimitForLp14__c, Contact__r.OrderAmountLimitForLp15__c, Contact__r.OrderAmountLimitForLp16__c, Contact__r.OrderAmountLimitForLp17__c, Contact__r.OrderAmountLimitForLp18__c, Contact__r.OrderAmountLimitForLp19__c, Contact__r.OrderAmountLimitForLp20__c ' +
      'FROM STA_Statement__c ' +
      'WHERE Contact__r.AccountCountryCode__c = \'' + country + '\' ' +
      'AND Status__c = \'Validated\' and Type__c = \'Transaction\' ' +
      'AND RecordTypeId = \'' + sta_LoyaltyProgRecTypeId + '\' ' + 
      'AND LpCode__c!=\'\' ' +
      // 'AND Contact__c = \'003D000001FLgREIA1\'' +
      'ORDER BY Contact__c,LpCode__c ';
     
     
     if(Test.isRunningTest()){
       //query = 'select  AmountLP1__c ,  AmountLP2__c ,  AmountLP3__c ,  AmountLP4__c ,  AmountLP5__c ,  AmountLP6__c ,  AmountLP7__c ,  AmountLP8__c ,  AmountLP9__c ,  AmountLP10__c ,  AmountLP11__c ,  AmountLP12__c ,  AmountLP13__c ,  AmountLP14__c ,  AmountLP15__c ,  AmountLP16__c ,  AmountLP17__c ,  AmountLP18__c ,  AmountLP19__c ,  AmountLP20__c ,  AmountAdminFees__c ,  AmountCommissions__c , Contact__c,Contact__r.Id,LpCode__c  From STA_Statement__c where Contact__r.AccountCountryCode__c = \''+country+'\' and Status__c = \'Validated\' and Type__c = \'Transaction\' and RecordTypeId = \''+sta_LoyaltyProgRecTypeId+'\' and LpCode__c!=\'\' order by CreatedDate desc limit 25';
       /* Happy project */
       query = 
        'SELECT  AmountLP1__c, AmountLP2__c, AmountLP3__c, AmountLP4__c, AmountLP5__c, AmountLP6__c, AmountLP7__c, AmountLP8__c, AmountLP9__c, AmountLP10__c, AmountLP11__c, AmountLP12__c, AmountLP13__c, AmountLP14__c, AmountLP15__c, AmountLP16__c, AmountLP17__c, AmountLP18__c, AmountLP19__c, AmountLP20__c, ' + 
                'AmountAdminFees__c, AmountCommissions__c, Contact__c, Contact__r.Id, LpCode__c, OrderLine__r.Order__r.TECH_TotalPrice__c, ' +
                'CreatedById, CreatedBy.ProfileId, Contact__r.OrderAmountLimitForLp1__c, Contact__r.OrderAmountLimitForLp2__c, Contact__r.OrderAmountLimitForLp3__c, Contact__r.OrderAmountLimitForLp4__c, Contact__r.OrderAmountLimitForLp5__c, Contact__r.OrderAmountLimitForLp6__c, Contact__r.OrderAmountLimitForLp7__c, Contact__r.OrderAmountLimitForLp8__c, Contact__r.OrderAmountLimitForLp9__c, Contact__r.OrderAmountLimitForLp10__c, Contact__r.OrderAmountLimitForLp11__c, Contact__r.OrderAmountLimitForLp12__c, Contact__r.OrderAmountLimitForLp13__c, Contact__r.OrderAmountLimitForLp14__c, Contact__r.OrderAmountLimitForLp15__c, Contact__r.OrderAmountLimitForLp16__c, Contact__r.OrderAmountLimitForLp17__c, Contact__r.OrderAmountLimitForLp18__c, Contact__r.OrderAmountLimitForLp19__c, Contact__r.OrderAmountLimitForLp20__c ' +
        'FROM STA_Statement__c ' +
        'WHERE Contact__r.AccountCountryCode__c = \'' + country + '\' ' +
        'AND Status__c = \'Validated\' and Type__c = \'Transaction\' ' +
        'AND RecordTypeId = \'' + sta_LoyaltyProgRecTypeId + '\' ' + 
        'AND LpCode__c!=\'\' ' +
        'ORDER BY CreatedDate desc limit 25';
     }
     
     return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Sobject> scope)
    {
      system.debug('>>>> start Execute <<<<<<');
      // Retrieving contact ID to proccess statements      
      
      List<AggregateResult> aggregates = new List<AggregateResult>();
		set<String> lpContactSet = new set<String>();
		List<STA_Statement__c> transactionsList = new List<STA_Statement__c>();
		map<id, set<String>> theLpContactMap = new map<id, set<String>>();
		//map<id, List<double>> theSumLpContactMap = new map<id, List<double>>();
		map<id, map<String, double>> theContactMapLpSumMap = new map<id, map<String, double>>();

      /*for (Sobject so : scope)  {
          AggregateResult ar = (AggregateResult) so;
          aggregates.add(ar);
          Id contactID = string.valueof(ar.get('ContactId'));
          system.debug('#### retrieving contact IDs');
          contactIdSet.add(contactID);      
          contactSetToBeDeleted.add(contactID);
      }   */
      //fetch all contacts
	  system.debug('#### scope.size(): ' + scope.size());
      for (Sobject so : scope)  {
      	STA_Statement__c currentSTA = (STA_Statement__c) so;
      	contactIdSet.add(currentSTA.Contact__c);
      	transactionsList.add(currentSTA);
      	//transactionListToBeDeleted.add(currentSTA.Id);
      }
      system.debug('#### transactionsList.size() ' + transactionsList.size());
      system.debug('#### contactIdSet ' + contactIdSet);
      //fetch all lps per contact
      for(Id theContact : contactIdSet)  {
      	set<String> contactLpSet = new set<String>();
      	for (STA_Statement__c theTransaction : transactionsList)  {
      		if(theContact==theTransaction.Contact__c){
	      	  contactLpSet.add(theTransaction.LpCode__c);
      		}
      	}
      	theLpContactMap.put(theContact,contactLpSet);
      }
      
      system.debug('#### contactIdSet.size() '+ contactIdSet.size());

      /* For LP3, the minimun amount, to enable the statement to be summed, is compared to the total amount of all orders linked to the statements and by contacts*/
      Map<Id, Decimal> mapContactIdOrdersTotalAmount = new Map<Id, Decimal>();
      if (country == 'FRA') {
        for (AggregateResult ar : [SELECT order__c, order__r.Dealer__c dealer, MAX(order__r.TECH_TotalPrice__c) total
                                  FROM ORL_OrderLine__c
                                  WHERE ID IN 
                                  (
                                    SELECT OrderLine__c
                                    FROM STA_Statement__c 
                                    WHERE Contact__r.AccountCountryCode__c = :country 
                                    AND Status__c = 'Validated' and Type__c = 'Transaction'
                                    AND LpCode__c != ''
                                    AND RecordTypeId = :sta_LoyaltyProgRecTypeId
                                    AND Contact__c IN :contactIdSet
                                  )
                                  GROUP BY order__c, order__r.Dealer__c]) 
        {
          Id dealerId = (Id)ar.get('dealer');
          if (mapContactIdOrdersTotalAmount.containsKey(dealerId)) {
            Decimal currentTotal = mapContactIdOrdersTotalAmount.get(dealerId);
            mapContactIdOrdersTotalAmount.put(dealerId, currentTotal + (Decimal)ar.get('total'));
          } else {
            mapContactIdOrdersTotalAmount.put(dealerId, (Decimal)ar.get('total'));
          }
        }
      }
      
      //summing all each lps of each contact
      for(Id theContact : contactIdSet)  {
      	map<String, double> currentLPSumMap = new map<String, double>();
      	//List<double> theSumLPContact = new List<double>();
      	for(String theLP : theLpContactMap.get(theContact))  {
	      	double theLPSum=0;
	      	if(theLP!=null){
		      	for (STA_Statement__c theTransaction : transactionsList)  {
		      		if(theContact==theTransaction.Contact__c && theLP==theTransaction.LpCode__c){
		      			if(theLP.equals('ADM'))
		      				theLPSum=theLPSum+theTransaction.AmountAdminFees__c;
			      	  	else if(theLP.equals('COM'))
			      	  		theLPSum=theLPSum+theTransaction.AmountCommissions__c;
			      	  	else if(theLP.equals('LP1') 
                          && ((lpToVerifySet.contains('LP1') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp1__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp1__c)
                              || !lpToVerifySet.contains('LP1'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP1__c;
			      	  	else if(theLP.equals('LP2') 
                          && ((lpToVerifySet.contains('LP2') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp2__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp2__c)
                              || !lpToVerifySet.contains('LP2'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP2__c;
			      	  	else if(theLP.equals('LP3') 
                          && ((lpToVerifySet.contains('LP3')                           
                              && theTransaction.Contact__r.OrderAmountLimitForLp3__c != null
                              // && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp3__c)
                              && mapContactIdOrdersTotalAmount.get(theTransaction.Contact__c) >= theTransaction.Contact__r.OrderAmountLimitForLp3__c)
                              || !lpToVerifySet.contains('LP3')
                              || setInterfaceUserIdOrProfileId.contains(theTransaction.CreatedById) 
                              || setInterfaceUserIdOrProfileId.contains(theTransaction.CreatedBy.ProfileId))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP3__c;
			      	  	else if(theLP.equals('LP4') 
                          && ((lpToVerifySet.contains('LP4') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp4__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp4__c)
                              || !lpToVerifySet.contains('LP4'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP4__c;
			      	  	else if(theLP.equals('LP5') 
                          && ((lpToVerifySet.contains('LP5') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp5__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp5__c)
                              || !lpToVerifySet.contains('LP5'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP5__c;
			      	  	else if(theLP.equals('LP6') 
                          && ((lpToVerifySet.contains('LP6') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp6__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp6__c)
                              || !lpToVerifySet.contains('LP6'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP6__c;
			      	  	else if(theLP.equals('LP7') 
                          && ((lpToVerifySet.contains('LP7') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp7__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp7__c)
                              || !lpToVerifySet.contains('LP7'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP7__c;
			      	  	else if(theLP.equals('LP8') 
                          && ((lpToVerifySet.contains('LP8') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp8__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp8__c)
                              || !lpToVerifySet.contains('LP8'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP8__c;
			      	  	else if(theLP.equals('LP9') 
                          && ((lpToVerifySet.contains('LP9') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp9__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp9__c)
                              || !lpToVerifySet.contains('LP9'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP9__c;
			      	  	else if(theLP.equals('LP10') 
                          && ((lpToVerifySet.contains('LP10') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp10__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp10__c)
                              || !lpToVerifySet.contains('LP10'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP10__c;
			      	  	else if(theLP.equals('LP11') 
                          && ((lpToVerifySet.contains('LP11') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp11__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp11__c)
                              || !lpToVerifySet.contains('LP11'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP11__c;
			      	  	else if(theLP.equals('LP12') 
                          && ((lpToVerifySet.contains('LP12') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp12__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp12__c)
                              || !lpToVerifySet.contains('LP12'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP12__c;
			      	  	else if(theLP.equals('LP13') 
                          && ((lpToVerifySet.contains('LP13') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp13__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp13__c)
                              || !lpToVerifySet.contains('LP13'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP13__c;
			      	  	else if(theLP.equals('LP14') 
                          && ((lpToVerifySet.contains('LP14') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp14__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp14__c)
                              || !lpToVerifySet.contains('LP14'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP14__c;
			      	  	else if(theLP.equals('LP15') 
                          && ((lpToVerifySet.contains('LP15') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp15__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp15__c)
                              || !lpToVerifySet.contains('LP15'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP15__c;
			      	  	else if(theLP.equals('LP16') 
                          && ((lpToVerifySet.contains('LP16') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp16__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp16__c)
                              || !lpToVerifySet.contains('LP16'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP16__c;
			      	  	else if(theLP.equals('LP17') 
                          && ((lpToVerifySet.contains('LP17')
                              && theTransaction.Contact__r.OrderAmountLimitForLp17__c != null 
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp17__c)
                              || !lpToVerifySet.contains('LP17'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP17__c;
			      	  	else if(theLP.equals('LP18') 
                          && ((lpToVerifySet.contains('LP18') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp18__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp18__c)
                              || !lpToVerifySet.contains('LP18'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP18__c;
			      	  	else if(theLP.equals('LP19') 
                          && ((lpToVerifySet.contains('LP19') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp19__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp19__c)
                              || !lpToVerifySet.contains('LP19'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP19__c;
			      	  	else if(theLP.equals('LP20') 
                          && ((lpToVerifySet.contains('LP20') 
                              && theTransaction.Contact__r.OrderAmountLimitForLp20__c != null
                              && theTransaction.OrderLine__r.Order__r.TECH_TotalPrice__c >= theTransaction.Contact__r.OrderAmountLimitForLp20__c)
                              || !lpToVerifySet.contains('LP20'))
                          )
			      	  		theLPSum=theLPSum+theTransaction.AmountLP20__c;
			      	  	else{
			      	  		//do nothing
			      	  	}
			      	  	transactionListToBeDeleted.add(theTransaction.Id);		
		      		}//endof contact and LP match
		      	}//endof theTransaction
      	}
	      	currentLPSumMap.put(theLP,theLPSum);
      	}//endof theContact
      	theContactMapLpSumMap.put(theContact,currentLPSumMap);
      } 
     system.debug('#### theContactMapLpSumMap ' + theContactMapLpSumMap);   
    
     // initialize balance if not already existed
        initializeBalance(contactIdSet);
        
       
         for(STA_Statement__c statement: [SELECT id,
                            AmountLP1__c, 
                            AmountLP2__c, 
                            AmountLP3__c, 
                            AmountLP4__c,
                            AmountLP5__c,
                            AmountLP6__c,
                            AmountLP7__c,
                            AmountLP8__c,
                            AmountLP9__c,
                            AmountLP10__c,
                            AmountLP11__c,
                            AmountLP12__c,
                            AmountLP13__c,
                            AmountLP14__c,
                            AmountLP15__c,
                            AmountLP16__c,
                            AmountLP17__c,
                            AmountLP18__c,
                            AmountLP19__c,
                            AmountLP20__c,
                            AmountAdminFees__c,
                            AmountCommissions__c,
                            Contact__c,
                            Type__c
                        FROM STA_Statement__c
                        WHERE Contact__c IN :contactIdSet
                        AND Type__c =: STA_TYPE_BALANCE order by LastModifiedDate asc])       
         {
           statementContactMap.put(statement.Contact__c, statement);
         } 
         system.debug('#### statementContactMap.size() '+ statementContactMap.size());
       
      for(Id theContact : contactIdSet)  {
      	
        statementToUpdate = new STA_Statement__c();
        statementToUpdate = statementContactMap.get(theContact);
        system.debug('#### Updating balance');
        for(String theLP : theLpContactMap.get(theContact))  {
          if(theContactMapLpSumMap.get(theContact)!=null && theLP!=null){
        	double theLPSum = theContactMapLpSumMap.get(theContact).get(theLP)==null ? 0 : theContactMapLpSumMap.get(theContact).get(theLP);
        	if(theLP.equals('ADM'))
  				statementToUpdate.AmountAdminFees__c = (statementToUpdate.AmountAdminFees__c==null ? 0 : statementToUpdate.AmountAdminFees__c)+ theLPSum;
      	  	else if(theLP.equals('COM'))
      	  		statementToUpdate.AmountCommissions__c = (statementToUpdate.AmountCommissions__c==null ? 0 : statementToUpdate.AmountCommissions__c)+ theLPSum;
      	  	else if(theLP.equals('LP1'))
      	  		statementToUpdate.AmountLP1__c = (statementToUpdate.AmountLP1__c==null ? 0 : statementToUpdate.AmountLP1__c)+ theLPSum;
      	  	else if(theLP.equals('LP2'))
      	  		statementToUpdate.AmountLP2__c = (statementToUpdate.AmountLP2__c==null ? 0 : statementToUpdate.AmountLP2__c)+ theLPSum;
      	  	else if(theLP.equals('LP3'))
      	  		statementToUpdate.AmountLP3__c = (statementToUpdate.AmountLP3__c==null ? 0 : statementToUpdate.AmountLP3__c)+ theLPSum;
      	  	else if(theLP.equals('LP4'))
      	  		statementToUpdate.AmountLP4__c = (statementToUpdate.AmountLP4__c==null ? 0 : statementToUpdate.AmountLP4__c)+ theLPSum;
      	  	else if(theLP.equals('LP5'))
      	  		statementToUpdate.AmountLP5__c = (statementToUpdate.AmountLP5__c==null ? 0 : statementToUpdate.AmountLP5__c)+ theLPSum;
      	  	else if(theLP.equals('LP6'))
      	  		statementToUpdate.AmountLP6__c = (statementToUpdate.AmountLP6__c==null ? 0 : statementToUpdate.AmountLP6__c)+ theLPSum;
      	  	else if(theLP.equals('LP7'))
      	  		statementToUpdate.AmountLP7__c = (statementToUpdate.AmountLP7__c==null ? 0 : statementToUpdate.AmountLP7__c)+ theLPSum;
      	  	else if(theLP.equals('LP8'))
      	  		statementToUpdate.AmountLP8__c = (statementToUpdate.AmountLP8__c==null ? 0 : statementToUpdate.AmountLP8__c)+ theLPSum;
      	  	else if(theLP.equals('LP9'))
      	  		statementToUpdate.AmountLP9__c = (statementToUpdate.AmountLP9__c==null ? 0 : statementToUpdate.AmountLP9__c)+ theLPSum;
      	  	else if(theLP.equals('LP10'))
      	  		statementToUpdate.AmountLP10__c = (statementToUpdate.AmountLP10__c==null ? 0 : statementToUpdate.AmountLP10__c)+ theLPSum;
      	  	else if(theLP.equals('LP11'))
      	  		statementToUpdate.AmountLP11__c = (statementToUpdate.AmountLP11__c==null ? 0 : statementToUpdate.AmountLP11__c)+ theLPSum;
      	  	else if(theLP.equals('LP12'))
      	  		statementToUpdate.AmountLP12__c = (statementToUpdate.AmountLP12__c==null ? 0 : statementToUpdate.AmountLP12__c)+ theLPSum;
      	  	else if(theLP.equals('LP13'))
      	  		statementToUpdate.AmountLP13__c = (statementToUpdate.AmountLP13__c==null ? 0 : statementToUpdate.AmountLP13__c)+ theLPSum;
      	  	else if(theLP.equals('LP14'))
      	  		statementToUpdate.AmountLP14__c = (statementToUpdate.AmountLP14__c==null ? 0 : statementToUpdate.AmountLP14__c)+ theLPSum;
      	  	else if(theLP.equals('LP15'))
      	  		statementToUpdate.AmountLP15__c = (statementToUpdate.AmountLP15__c==null ? 0 : statementToUpdate.AmountLP15__c)+ theLPSum;
      	  	else if(theLP.equals('LP16'))
      	  		statementToUpdate.AmountLP16__c = (statementToUpdate.AmountLP16__c==null ? 0 : statementToUpdate.AmountLP16__c)+ theLPSum;
      	  	else if(theLP.equals('LP17'))
      	  		statementToUpdate.AmountLP17__c = (statementToUpdate.AmountLP17__c==null ? 0 : statementToUpdate.AmountLP17__c)+ theLPSum;
      	  	else if(theLP.equals('LP18'))
      	  		statementToUpdate.AmountLP18__c = (statementToUpdate.AmountLP18__c==null ? 0 : statementToUpdate.AmountLP18__c)+ theLPSum;
      	  	else if(theLP.equals('LP19'))
      	  		statementToUpdate.AmountLP19__c = (statementToUpdate.AmountLP19__c==null ? 0 : statementToUpdate.AmountLP19__c)+ theLPSum;
      	  	else if(theLP.equals('LP20'))
      	  		statementToUpdate.AmountLP20__c = (statementToUpdate.AmountLP20__c==null ? 0 : statementToUpdate.AmountLP20__c)+ theLPSum;
      	  	else{
      	  		//do nothing
      	  	}
          }		
        }
		
        system.debug('#### statementToUpdate : ' + statementToUpdate);
        statementList.add(statementToUpdate);
        }//for
              
      system.debug('#### statementList.size() ' + statementList);
      if(statementList.size()>0){
        update statementList;
        statementList = new list<STA_Statement__c>();
      }
      contactIdSet = new set<id>();
        //contactSetToBeDeleted=contactIdSet;
        //deleteTransaction(contactTransactionToDelete);

    }
    
    /*
    * Delete statements of type Transaction which have been processed
    */
    /*private void deleteTransaction( Set<Id> contactSet){
      //country,timeStarted,contactList
      List<Id> contactList = new List<Id>(contactSet);
      AP30_BatchGroupDeleteTransaction batch = new AP30_BatchGroupDeleteTransaction('FRA',contactList,timeStarted);
      database.executebatch(batch, 10000);
    }*/
    
    /*
    * Initialize balance if doesnot exist for the processed contact
    */
    private void initializeBalance(Set<Id> contactIdSet){
      
      set<id> allBalancesSet = new set<id>();
      
      set<id> balanceToBeCreated = new set<id>();
      
      list<STA_Statement__c> balanceList = new list<STA_Statement__c>();
      
      //retrieving all statements of type balance.
        for(STA_Statement__c allBalances: [select id,
                              Contact__c,
                              Type__c
                              FROM STA_Statement__c
                              WHERE Type__c = :STA_TYPE_BALANCE and Contact__c IN : contactIdSet])
    {
      allBalancesSet.add(allBalances.Contact__c);
    }
        
        system.debug('### allBalancesSet.size() ' + allBalancesSet.size());
          
         for(id i: contactIdSet)
        {
            if(!allBalancesSet.contains(i))
            {
                balanceToBeCreated.add(i);
            }
        }
        
        system.debug('### balanceToBeCreated.size() ' + balanceToBeCreated.size());
        
        for(id toCreate: balanceToBeCreated){
            balance = new STA_Statement__c();
            
            balance.Contact__c = toCreate;
            balance.Status__c = STA_STATUS_VALIDATED;
            balance.Type__c = STA_TYPE_BALANCE;
            balance.RecordTypeId = sta_LoyaltyProgRecTypeId;
            
            balanceList.add(balance);
        }
        
        system.debug('### balanceList.size() ' + balanceList.size());
        
        if(balanceList.size()>0)
            insert balanceList;
      
      
    }
    
 
    global void finish(Database.BatchableContext BC){
      List<Id> transactionList = new List<Id>(transactionListToBeDeleted);
      system.debug('### transactionList.size()  ' + transactionList.size());
      system.debug('### transactionList  ' + transactionList);
      system.debug('### country ' + country);
      system.debug('### timeStarted ' + timeStarted);
      AP30_BatchGroupDeleteTransaction batch = new AP30_BatchGroupDeleteTransaction(country,transactionList,timeStarted);
      database.executebatch(batch, 10000);
    }

}