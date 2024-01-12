/*
----------------------------------------------------------------------
-- - Name          : AP16_LoyaltyProgramService.cls
-- - Author        : NGO
-- - Description   : Retrieving loyalty program.
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 06-MAY-2013  NGO    1.0      Initial version
-- 11-MAR-2015  NGO    1.0      Add LP to online orders ticket 300144
-- 18-MAR-2015  WCHY   1.0      Add function recalculateLPForOnlineOrder
----------------------------------------------------------------------
*/
public with sharing class AP16_LoyaltyProgramService {

  /**
  * Loyalty base credit or debit values
  */
  public static String LP_BASE_REGULAR_PRICE = 'RegularPrice__c';
  public static String LP_BASE_PUBLIC_PRICE = 'PublicPrice__c';
  public static String LP_BASE_DEALER_PRICE = 'DealerPrice__c';
  public static String LP_BASE_NET_PRICE = 'NetPrice__c';
  public static String LP_BASE_LP_VALUE_1 = 'LoyaltyPrgVal1__c';
  public static String LP_BASE_LP_VALUE_2 = 'LoyaltyPrgVal2__c';
  public static String LP_BASE_LP_VALUE_3 = 'LoyaltyPrgVal3__c';

  public static String LP_1 = 'LP1';
  public static String LP_2 = 'LP2';
  public static String LP_3 = 'LP3';
  public static String LP_4 = 'LP4';
  public static String LP_5 = 'LP5';
  public static String LP_6 = 'LP6';
  public static String LP_7 = 'LP7';
  public static String LP_8 = 'LP8';
  public static String LP_9 = 'LP9';
  public static String LP_10 = 'LP10';
  public static String LP_11 = 'LP11';
  public static String LP_12 = 'LP12';
  public static String LP_13 = 'LP13';
  public static String LP_14 = 'LP14';
  public static String LP_15 = 'LP15';
  public static String LP_16 = 'LP16';
  public static String LP_17 = 'LP17';
  public static String LP_18 = 'LP18';
  public static String LP_19 = 'LP19';
  public static String LP_20 = 'LP20';


  /**
  * Retrive from Loyalty programs
  */	
  public List<LYP_LoyaltyProgram__c> getLP(String country, List<String> lpCodes, Set<String> categoryLevels, String rateRange) {

    system.debug('## filterLP  country<<<<<' + country);
    system.debug('## filterLP  lpCode<<<<<' + lpCodes);
    system.debug('## filterLP  categoryLevel<<<<<' + categoryLevels);
    system.debug('## filterLP  rateRange<<<<<' + rateRange);
    List<LYP_LoyaltyProgram__c> lps = [select LPDebitBase__c
                                       , LPDebitFactor__c
                                       , LPCreditBase__c
                                       , LPCreditFactor__c
                                       , FromDate__c, ToDate__c
                                       , LPCode__c, TO_LPCode__c
                                       , CategoryLevelCommission__c
                                       from LYP_LoyaltyProgram__c
                                       where Country__c = : country
                                           and LPCode__c in : lpCodes
                                           and (CategoryLevelCommission__c in : categoryLevels or CategoryLevelCommission__c = '*')
                                           and (CommissionRateRange__c = :  rateRange or CommissionRateRange__c = '*')
                                      ];

    return filterLPByFromToDate(lps);
  }
  

  public List<LYP_LoyaltyProgram__c> filterLPByFromToDate(List<LYP_LoyaltyProgram__c> lps) {

    List<LYP_LoyaltyProgram__c> filteredLP = new List<LYP_LoyaltyProgram__c>();

    Datetime todayDate = System.now();

    for (LYP_LoyaltyProgram__c lp : lps) {

      boolean isFromDateNull = lp.FromDate__c == null;
      boolean isToDateNull = lp.ToDate__c == null;

      if (isFromDateNull && isToDateNull) {
        //when fromDate and toDate is null
        filteredLP.add(lp);

      } else if (isFromDateNull && ! isToDateNull) {
        //when fromDate is null and toDate is not null
        if (lp.ToDate__c >= todayDate) {
          filteredLP.add(lp);
        }

      } else if (!isFromDateNull && isToDateNull) {
        //when fromDate is not null and toDate is null
        if (lp.FromDate__c <= todayDate) {
          filteredLP.add(lp);
        }

      } else {
        //when fromDate and toDate is not null
        if (lp.FromDate__c <= todayDate && lp.ToDate__c >= todayDate) {
          filteredLP.add(lp);
        }
      }
    }

    return filteredLP;

  }



  private String getCountry(Contact contact) {
    Account account = [select Country_Code__c from Account where id = : contact.AccountId limit 1];
    return account.Country_Code__c;
  }

  private String getCommissionRateRange(Contact contact) {
    return contact.CommissionRateRange__c;
  }


  /**
  * Method that calculates the loyalty program for each ligne item.
  * if allLps is being passed, then the calcutaion with take values from the list instead of a soql query
  */
  public AP16_LoyaltyProgram getLPAmount(List<String> lpCodes, Integer quantity, CTA_CatalogArticle__c cta, Contact contact, List<LYP_LoyaltyProgram__c> allLps) {

    system.debug('## START AP16_LoyaltyProgramService getLPAmount <<<<<' + UserInfo.getUserName());
    AP16_LoyaltyProgram dto = new AP16_LoyaltyProgram();
    if (cta != null) {

      String country = getCountry(contact);
      String commissionRateRange = getCommissionRateRange(contact);
      if (cta.AdminFees__c) {
        //Add adm fees
        lpCodes.add(system.label.LYP00001);
      }
      if (cta.Commissionable__c) {
        //Add commision
        lpCodes.add(system.label.LYP00002);
      }
      List<LYP_LoyaltyProgram__c> lps;
	  if(allLps == null){ //from offline order
      	lps = getLP(country, lpCodes, new Set<String>{cta.CategoryLevelCommission__c} , commissionRateRange);
      	
	  }else{ //from online order
	  	lps = allLps;
	  }
	  
      system.debug('## START AP16_LoyaltyProgramService lps <<<<<' + lps);
      for (LYP_LoyaltyProgram__c lp : lps) {
        double creditBase = getBaseValue(cta, lp.LPCreditBase__c);
        double debitBase = getBaseValue(cta, lp.LPDebitBase__c);     
        double credit = (creditBase * (lp.LPCreditFactor__c == null ? 0 : lp.LPCreditFactor__c)) ;       
        double debit = (debitBase * (lp.LPDebitFactor__c == null ? 0 : lp.LPDebitFactor__c));       
        double result = credit - debit;       
        result = quantity * result;
        
        system.debug('## START AP16_LoyaltyProgramService credit <<<<<' + credit);
        system.debug('## START AP16_LoyaltyProgramService debitBase <<<<<' + debitBase);
        system.debug('## START AP16_LoyaltyProgramService quantity <<<<<' + quantity);
        system.debug('## START AP16_LoyaltyProgramService creditBase <<<<<' + creditBase);
        system.debug('## START AP16_LoyaltyProgramService debitBase <<<<<' + debitBase);
        system.debug('## START AP16_LoyaltyProgramService lp.LPCreditFactor__c <<<<<' + lp.LPCreditFactor__c);
        system.debug('## START AP16_LoyaltyProgramService lp.LPDebitFactor__c <<<<<' + lp.LPDebitFactor__c);
        system.debug('## START AP16_LoyaltyProgramService result <<<<<' + result);
		
        if (lp.TO_LPCode__c != null && lp.TO_LPCode__c.length() > 0 && result != 0) {
          List<string> toLpCodes = lp.TO_LPCode__c.split('##');
          for (String toLpCode : toLpCodes) {
            dto.addToLpCode(toLpCode);
            dto.addLpAmount(String.valueOf((double)((Integer) Math.round(result * 100)) / 100));
          }
        }
      }
    }
    system.debug('## START AP16_LoyaltyProgramService dto <<<<<' + dto);
    return dto;
  }
  
  
  /**
  * Method that calculates the loyalty program for each ligne item.
  */
  public AP16_LoyaltyProgram getLPAmount(List<String> lpCodes, Integer quantity, CTA_CatalogArticle__c cta, Contact contact) {
   	
   	return getLPAmount(lpCodes,quantity,cta,contact,null);
   	
  }
  
  /**
  * Method to re calculate loyalty program for existing Orderline
  */
  public void recalculateLPForOnlineOrder(List<VFC01_ProductDetailDTO> details, Contact contact, Map<Id, String> orderlinesOnline){
  	
  	//TODO Loop in each deatils to get all LP and category level
  	List<List<String>> detailsLpCodes= new List<List<String>>();
  	List<String> detailsLpCodesAll=new List<String>();
  	Set<String> detailsCategoryLevels=new Set<String>();
  	boolean theCOM=false,theADM=false;
  	system.debug('## Class AP16_LoyaltyProgramService - START function recalculateLPForOnlineOrder details <<<<<' + details);
      for (VFC01_ProductDetailDTO theProductDetail : details) {
      	//to do add if lp already exist
      	if(!String.isNotBlank(orderlinesOnline.get(theProductDetail.orderline))){
	      	List<String> lpcodesEach = new List<String>();
		    lpcodesEach=extractMeansOfPaymentList(theProductDetail);
			detailsLpCodesAll.addall(lpcodesEach);
			if (theProductDetail.cta.AdminFees__c) {
		        //Add adm fees
				theADM=true;
	        }
	        if (theProductDetail.cta.Commissionable__c) {
		        //Add commision
		        theCOM=true;
	        }
		    system.debug('## Class AP16_LoyaltyProgramService - function recalculateLPForOnlineOrder  lpcodesEach <<<<<' + lpcodesEach);
		    if(lpcodesEach != null && lpcodesEach.size() > 0){
		    	detailsLpCodes.add(lpcodesEach);
		    	system.debug('## Class AP16_LoyaltyProgramService - function recalculateLPForOnlineOrder  detailsLpCodes <<<<<' + detailsLpCodes);
		    }
	      	detailsCategoryLevels.add(theProductDetail.cta.CategoryLevelCommission__c);
      	}
      }
      if(theCOM){
      	detailsLpCodesAll.add(system.label.LYP00002);
      }
      if(theADM){
      	detailsLpCodesAll.add(system.label.LYP00001);
      }
  	  system.debug('## Class AP16_LoyaltyProgramService - function recalculateLPForOnlineOrder  detailsLpCodes <<<<<' + detailsLpCodes);
  	//TODO retrieve all LPCode from database 
    List<LYP_LoyaltyProgram__c> standardTemplateAllLP =  getLP(getCountry(contact), detailsLpCodesAll, detailsCategoryLevels, getCommissionRateRange(contact));
   
  	//TODO on each detail call getLPAmount(with 5 parameters) 
  	Integer counter=0;
  	for (VFC01_ProductDetailDTO theProductDetail : details) {
  		//to do add if lp already exist
  		system.debug('## Class AP16_LoyaltyProgramService - function recalculateLPForOnlineOrder  String.isNotBlank(orderlinesOnline.get(theProductDetail.orderline)) <<<<<' + String.isNotBlank(orderlinesOnline.get(theProductDetail.orderline)));
  		if(!String.isNotBlank(orderlinesOnline.get(theProductDetail.orderline))){
  				List<LYP_LoyaltyProgram__c> standardTemplateEachLP = new List<LYP_LoyaltyProgram__c>();
		  		for (LYP_LoyaltyProgram__c eachLP : standardTemplateAllLP) {
		  			system.debug('## Class AP16_LoyaltyProgramService - function recalculateLPForOnlineOrder  detailsLpCodes <<<<<' + detailsLpCodes);
		  			if((eachLP.CategoryLevelCommission__c.equals(theProductDetail.cta.CategoryLevelCommission__c) || eachLP.CategoryLevelCommission__c.equals('*')) && (theProductDetail.CTA.MeansPayment__c.indexOf(eachLP.LPCode__c)!=-1)){
		  				standardTemplateEachLP.add(eachLP);
		  			}else if(theProductDetail.CTA.Commissionable__c && eachLP.LPCode__c.equals(system.label.LYP00002)){
		  				standardTemplateEachLP.add(eachLP);
		  			}else if(theProductDetail.CTA.AdminFees__c && eachLP.LPCode__c.equals(system.label.LYP00001)){
		  				standardTemplateEachLP.add(eachLP);
		  			}
		  		}
		  		theProductDetail.loyaltyProgramDTO=getLPAmount(detailsLpCodes[counter], integer.valueOf(theProductDetail.quantity), theProductDetail.CTA, contact,standardTemplateEachLP);
		  		counter++;
  	    }
  	}
  }
 
  private double getBaseValue(CTA_CatalogArticle__c cta, String lpBase) {

    if (lpBase != null) {

      if (lpBase.equalsIgnoreCase(LP_BASE_REGULAR_PRICE) && cta.RegularPrice__c != null) {
        return cta.RegularPrice__c;

      } else if (lpBase.equalsIgnoreCase(LP_BASE_PUBLIC_PRICE) && cta.PublicPrice__c != null) {
        return cta.PublicPrice__c;

      } else if (lpBase.equalsIgnoreCase(LP_BASE_DEALER_PRICE) && cta.DealerPrice__c != null) {
        return cta.DealerPrice__c;

      } else if (lpBase.equalsIgnoreCase(LP_BASE_NET_PRICE) && cta.NetPrice__c != null) {
        return cta.NetPrice__c;

      } else if (lpBase.equalsIgnoreCase(LP_BASE_LP_VALUE_1) && cta.LoyaltyPrgVal1__c != null) {
        return cta.LoyaltyPrgVal1__c;

      } else if (lpBase.equalsIgnoreCase(LP_BASE_LP_VALUE_2) && cta.LoyaltyPrgVal2__c != null) {
        return cta.LoyaltyPrgVal2__c;

      } else if (lpBase.equalsIgnoreCase(LP_BASE_LP_VALUE_3) && cta.LoyaltyPrgVal3__c != null) {
        return cta.LoyaltyPrgVal3__c;

      } else {
        return 0;
      }
    } else {
      return 0;
    }

  }

  public List<VFC01_LoyaltyProgramRecapDTO> getLoyaltyProgramRecap(Id orderId, List<VFC01_LoyaltyProgramRecapDTO> loyaltyProgramRecaps, boolean isFinal) {

    system.debug('## START AP16_LoyaltyProgramService getLoyaltyProgramRecap <<<<<' + loyaltyProgramRecaps);
    if (loyaltyProgramRecaps != null && loyaltyProgramRecaps.size() > 0 && orderId != null) {
      List<ORL_OrderLine__c> orderlines = [Select
                                           name
                                           , Amount__c
                                           , Article__c
                                           , RegularPrice__c
                                           , Qty__c
                                           , Order__c
                                           , ArticleDescription__c
                                           , ArticleInternationalCode__c
                                           , ArticleLocalCode__c
                                           , ArticleLocalName__c
                                           , ArticleName__c
                                           , TECH_OfferBundleID__c
                                           , TECH_ArticleDescription__c
                                           , TECH_ArticleType__c
                                           , LPCode__c
                                           , LPAmount__c

                                           From ORL_OrderLine__c
                                           Where Order__c = :orderId];

      system.debug('## START AP16_LoyaltyProgramService orderlines <<<<<' + orderlines);

      for (ORL_OrderLine__c orderline : orderlines) {
        if ( String.isNotBlank(orderline.LpCode__c)) {
          AP16_LoyaltyProgram lps = new AP16_LoyaltyProgram(orderline.LpCode__c, orderline.LPAmount__c);
          for (String lpCode : lps.toLpCodes) {
            for (VFC01_LoyaltyProgramRecapDTO loyaltyProgramRecap : loyaltyProgramRecaps) {
              if (loyaltyProgramRecap.lpCode != null && loyaltyProgramRecap.lpCode.equalsIgnoreCase(lpCode)) {
                Double value = Double.valueOf(lps.mapLpCodeToLpAmount.get(lpCode));
                if (!isFinal) {
                  loyaltyProgramRecap.totalPoint = loyaltyProgramRecap.totalPoint + value;
                }
                if (value < 0) {
                  loyaltyProgramRecap.pointDebited = loyaltyProgramRecap.pointDebited + value;
                } else {
                  loyaltyProgramRecap.pointCredited = loyaltyProgramRecap.pointCredited + value;
                }
              }
            }
          }
        }
      }
    }
    return populateLoyaltyProgramName(loyaltyProgramRecaps);
  }

  public List<VFC01_LoyaltyProgramRecapDTO> getLoyaltyProgramMouvement(AP16_LoyaltyProgram dto, List<VFC01_LoyaltyProgramRecapDTO> loyaltyProgramRecaps, boolean isReverse) {

    system.debug('## START AP16_LoyaltyProgramService getLoyaltyProgramRecap <<<<<' + loyaltyProgramRecaps);
    system.debug('## START AP16_LoyaltyProgramService dto <<<<<' + dto);
    dto.constructMap();

    if (loyaltyProgramRecaps != null && loyaltyProgramRecaps.size() > 0 ) {
      if (dto != null && dto.toLpCodes != null) {
        for (String lpCode : dto.toLpCodes) {
          for (VFC01_LoyaltyProgramRecapDTO loyaltyProgramRecap : loyaltyProgramRecaps) {
            if (loyaltyProgramRecap.lpCode != null && loyaltyProgramRecap.lpCode.equalsIgnoreCase(lpCode)) {
              //BUG get first value each time
              Double value = Double.valueOf(dto.mapLpCodeToLpAmount.get(lpCode));
              loyaltyProgramRecap.totalPoint = loyaltyProgramRecap.totalPoint + value;
              if (isReverse) {
                if (value > 0) {
                  loyaltyProgramRecap.pointDebited += value;
                } else {
                  loyaltyProgramRecap.pointCredited += value;
                }
              } else {
                if (value < 0) {
                  loyaltyProgramRecap.pointDebited += value;
                } else {
                  loyaltyProgramRecap.pointCredited += value;
                }
              }
            }
          }
        }
      }
    }
    return loyaltyProgramRecaps;
  }


  /*
  * Get name from custom settings LPCode_Name__c
  */
  public List<VFC01_LoyaltyProgramRecapDTO>  populateLoyaltyProgramName(List<VFC01_LoyaltyProgramRecapDTO> loyaltyProgramRecaps) {
  	//fetch user country code User.User_Country__c
	List<User> theUser = [Select Id,User_Country__c From User Where Id = :UserInfo.getUserId()];
	String theUserCountry='';
	if(theUser!= null && theUser.size() > 0)
		theUserCountry=theUser[0].User_Country__c.equals('SYSTEM') ? 'FRA' : theUser[0].User_Country__c;
    //retrieve lp names from custom settings
    system.debug('## START AP16_LoyaltyProgramService populateLoyaltyProgramName theUserCountry <<<<<' + theUserCountry);
    Map<String, LPCode_Name__c> lpNameCodeMap = LPCode_Name__c.getAll();
    system.debug('## START AP16_LoyaltyProgramService populateLoyaltyProgramName lpNameCodeMap <<<<<' + lpNameCodeMap); 
    for (VFC01_LoyaltyProgramRecapDTO loyaltyProgramRecap : loyaltyProgramRecaps) {
      if (lpNameCodeMap.containsKey(loyaltyProgramRecap.lpCode.toUpperCase()+'_'+theUserCountry) && !String.isBlank(lpNameCodeMap.get(loyaltyProgramRecap.lpCode.toUpperCase()+'_'+theUserCountry).LPCountry__c)) {
      		loyaltyProgramRecap.lpName = lpNameCodeMap.get(loyaltyProgramRecap.lpCode.toUpperCase()+'_'+theUserCountry).LPName__c;
      } else {

        loyaltyProgramRecap.lpName = loyaltyProgramRecap.lpCode;
      }
    }
    return loyaltyProgramRecaps;
  }
  
  private List<String> extractMeansOfPaymentList(VFC01_ProductDetailDTO productDetail) {
    List<String> lpcodes = new List<String>();
    productDetail.isLoyalProgram = true;
    if (productDetail.CTA.MeansPayment__c != null && productDetail.CTA.MeansPayment__c.length() > 0) {
      String[] payments = productDetail.CTA.MeansPayment__c.split(';');
      system.debug('## Class VFC01_OrderBasket - START extractMeansOfPaymentList  payments <<<<<' + payments);
      for (String val : payments) {
        lpcodes.add(val);
        if (val.equalsIgnoreCase('Cash')) {
          productDetail.isLoyalProgram = false;
        }
      }
    } else {
      productDetail.isLoyalProgram = false;
    }
    return lpcodes;
  }

}