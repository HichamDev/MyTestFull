public class VFC_MyNetworkLandingPage{


/* 
----------------------------------------------------------------------
-- - Name          : VFC_MyNetworkLandingPage 
-- - Author        : AAT
-- - Description   : Controller for VFP_MyNetworkLandingPage Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 23-NOV-2016  AAT    1.0      Initial version   
----------------------------------------------------------------------
**********************************************************************
*/

  /*****************************************************************/
  /***************** Instantiating Global Variable *****************/
  /*****************************************************************/
  //Global Boolean
  public Boolean isPortal {get;set;}
  //Global Id
  public Id contactId {get;set;}
  public List<Contact> reportsToId {get;set;}
  
  //Global String
  public String userId {get;set;}
  public String userType {get;set;}
  public String techExternalId {get;set;}
  public String techExternalIdLvl1 {get;set;}
  public string coachParentName{get;set;}
  public List<String> contacts = new List<String>();
  public string contactParent{get;set;}
  public List<Contact> coachListLevel1 = new List<Contact>();
  public List<Contact> coachListLevel2 = new List<Contact>();
  public List<Contact> coachListLevel1and2 = new List<Contact>();
  public List<Contact> coachLevel2 = new List<Contact>();
  public CONTACT numberCoachsLevel {get;set;}
  public String contactFirstName {get;set;}
  public String contactLastName {get;set;}
  public String contactName {get;set;}
  public Contact currentDealer {get;set;}

  //filter
  public final List<SelectOption> filterOptions {get;set;}
  public String selectedOption {get;set;}
  public List<CONTACT> theCoachContactList {get;set;}
  
       
  /*****************************************************************/
  /******************** Page Constructor ***************************/
  /*****************************************************************/
  public VFC_MyNetworkLandingPage (){
     
    //Retrieving User ID, USer Type
    userId = UserInfo.getUserId();
    userType = UserInfo.getUserType();
    
    //Checks if Portal User
    CheckUser(userType, userId);
    
    currentDealer = [SELECT Id, AccountCountryCode__c FROM Contact WHERE Id =: contactId];

    filterOptions = new List<SelectOption>();

    filterOptions.add(new SelectOption(system.label.ORD00174+'#0#',system.label.ORD00174));
    filterOptions.add(new SelectOption(system.label.RCO00023+'#1#',system.label.RCO00023));
    filterOptions.add(new SelectOption(system.label.RCO00024+'#2#',system.label.RCO00024));
    
    selectedOption=system.label.ORD00174+'#0#';
    filterOptions.sort();

    getNumberCoachsLevel();
      
  }
     
     
  /*****************************************************************/
  /*********************** CheckUser *******************************/
  /*****************************************************************/
  public void CheckUser(String userType, String userId){
            
    //Retrieving Contact ID related to user
    contactId = [Select ContactID
                 From User
                 Where id = :userId
                 limit 1].ContactID;

    techExternalId = [Select TECH_ExternalId__c
                      From CONTACT
                      Where id = :contactId
                      limit 1].TECH_ExternalId__c;

  }
  
    
    /*****************************************************************/
    /******************** ControllerSet Init *************************/
    /*****************************************************************/
    
    public ApexPages.StandardSetController contactCoachsSet {   
      
      get {
        
        if(contactCoachsSet == null) {
                                          
          Set<String> setExternalId = new Set<String>();

          For (Contact con : [SELECT  FirstName, LastName, Email, MobilePhone, Start_date__c,  
                                     Success_Bearing__c,Turnover_Current_Period__c,Coach_Parent_ID__c,Coach_Parent_Name__c,TECH_ExternalId__c,
                                     STHID__c, Title, LastOrderDate__c, Last_Order_Total_Amount__c, SalesSegment__c, DealerSenioritySegment__c, 
                                     (SELECT Id, toLabel(Status__c) FROM Orders__r WHERE Status__c in ('Pending', 'Processing', 'Shipped') ORDER BY CreatedDate DESC LIMIT 1)
                              FROM CONTACT 
                              WHERE Coach_Parent_ID__c=:techExternalId 
                              AND ActivityStatus__c = true]){

            coachListLevel1.add(con);
            setExternalId.add(con.TECH_ExternalId__c);

          }

          Map<String,List<Contact>> mapCoachLevel2 = new Map<String,List<Contact>>();
          For (Contact newContact : [SELECT FirstName, LastName, Email, MobilePhone, Start_date__c, Success_Bearing__c, 
                                         Turnover_Current_Period__c,Coach_Parent_ID__c,Coach_Parent_Name__c,
                                         STHID__c, Title, LastOrderDate__c, Last_Order_Total_Amount__c, SalesSegment__c, DealerSenioritySegment__c, 
                                         (SELECT Id, toLabel(Status__c) FROM Orders__r WHERE Status__c in ('Pending', 'Processing', 'Shipped') ORDER BY CreatedDate DESC LIMIT 1)
                                     FROM CONTACT 
                                      WHERE Coach_Parent_ID__c IN :setExternalId]){
 
             if (mapCoachLevel2.containskey(newContact.Coach_Parent_ID__c)){
              mapCoachLevel2.get(newContact.Coach_Parent_ID__c).add(newContact);
             }else{
              mapCoachLevel2.put(newContact.Coach_Parent_ID__c,new list<Contact>{newContact});
             }
          }
                    
          For(Contact c : coachListLevel1){
                       
            techExternalIdLvl1 = c.TECH_ExternalId__c;

            if (mapCoachLevel2.containskey(techExternalIdLvl1)){
              coachListLevel2.addAll(mapCoachLevel2.get(techExternalIdLvl1));
            }
          }

          for(Contact cListLvl1 : coachListLevel1){
                  coachListLevel1and2.add(cListLvl1);
          }
          for(Contact cListLvl2 : coachListLevel2){
                  coachListLevel1and2.add(cListLvl2);
          }
                   
          contactCoachsSet = new  ApexPages.StandardSetController(coachListLevel1and2);
        }
        contactCoachsSet.setPageSize(1000); 
        return contactCoachsSet;
      }
        set;
    }
    
    public List<CONTACT> getContactCoachs() {
        return (List<CONTACT>) contactCoachsSet.getRecords();
    } 

    
   public PageReference refreshPageMyNetwork() {
       
       try
        {

            if(selectedOption.contains('#0#')){
                contactCoachsSet = new  ApexPages.StandardSetController(coachListLevel1and2);
            }else if(selectedOption.contains('#1#')){  contactCoachsSet = new  ApexPages.StandardSetController(coachListLevel1);
            }else if(selectedOption.contains('#2#')){ contactCoachsSet = new  ApexPages.StandardSetController(coachListLevel2); }    
        
        } catch (Exception e){ ApexPages.addMessages(e); }
        
        return null;
    } 
    
    public Contact getNumberCoachsLevel(){
      numberCoachsLevel = [SELECT NB_Recruits_Level1__c, NB_Recruits_Level2__c FROM CONTACT where TECH_ExternalId__c=:techExternalId limit 1];

      return numberCoachsLevel;
    }
     
}