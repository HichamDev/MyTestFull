public without sharing class VFC18_ConseillereInfo {
/*
// VFC18_ConseillereInfo
---------------------------------------------------------------------
-- - Name          : VFC18_ConseillereInfo
-- - Author        : YGO
-- - Description   : Controller for VFP18_ConseillereInfo
           To display contact info
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  --------------------------------------
-- 11-JUL-2013  YGO    1.0      Initial version
-- 02-OCT-2013	HDU    1.1      Implement without sharing for class.
---------------------------------------------------------------------
**********************************************************************
*/

  public Contact con1 {get;set;}
  public Contact conManager {get;set;}
  public string errMsg {get; set;}
  public boolean dsp {get;set;}
  public boolean dspMgr {get;set;}
  
  public VFC18_ConseillereInfo ()
  {
    conManager = new Contact();
    con1 = new Contact();
    list<Contact> conMgrList = new list<Contact>();
    
    con1 = SHW_IBZ_Utils.getConnectedUserContact();
    system.debug('con1 contact : ' + con1);
    errMsg = '';
    dsp = true;
    dspMgr = false;
    
    system.debug('### con1 = ' + con1);
    if(con1 != null)
    {
      conMgrList = [select Name
			   , MailingStreet
			   , MailingPostalCode
			   , MailingCountry
			   , MailingCity
               , PersonalMessage__c
               , Phone
               , Email
            from Contact
            where id =: con1.ReportsToId
            limit 1];
            
            
            
    }
    
    //verify if the contact is the top level of the hierachy
    system.debug('### conMgrList.size() : ' + conMgrList.size());
    if(conMgrList.size() > 0){
   		conManager = conMgrList[0];
   		dspMgr = true;
    }//end if conMgrList.size() >0
    else if (conMgrList.size() == 0 ||conMgrList == null){
    	dspMgr = false;
    }
    if(con1 == Null)
    {
      errMsg = system.label.ORD00103;
      dsp = false;
    }
    
    system.debug('### errMsg ' + errMsg);
    system.debug('### dsp ' + dsp);
  }
}