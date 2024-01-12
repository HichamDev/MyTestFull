public class VFC_MonEquipeLandingPage{


/* 
----------------------------------------------------------------------
-- - Name          : VFC_MonEquipeLandingPage 
-- - Author        : AAT
-- - Description   : Controller for VFP_MonEquipeLandingPage Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 16-FEV-2017  AAT    1.0      Initial version   
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
    public Id contactIdLvl1 {get;set;}
    
    public List<Contact> reportsToId {get;set;}
    
    //Global String
    public String userId {get;set;}
    public String userType {get;set;}
    public String techExternalId {get;set;}
    public String techExternalIdLvl1 {get;set;}
    public string coachParentName{get;set;}
    public List<String> contacts = new List<String>();
    public string contactParent{get;set;}
    public List<Contact> leaderList = new List<Contact>();
    public List<Contact> coachListLevel1 = new List<Contact>();
    public List<Contact> coachListLevel2 = new List<Contact>();
    public List<Contact> coachListLevel1and2 = new List<Contact>();
    public List<Contact> coachLevel2 = new List<Contact>();
    public CONTACT numberCoachsLevel {get;set;}
    public String contactFirstName {get;set;}
    public String contactLastName {get;set;}
    public String contactName {get;set;}
    public VFC01_ProductBasketDTO basketDetail {get; set;}
    //filter
    public final List<SelectOption> filterOptions {get;set;}
    public String selectedOption {get;set;}
    public List<CONTACT> theCoachContactList {get;set;}
    
    
    
    
    /*****************************************************************/
    /******************** Page Constructor ***************************/
    /*****************************************************************/
    public VFC_MonEquipeLandingPage (){
        system.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<<'+UserInfo.getUserName()); 
    
        //Retrieving User ID, USer Type
        userId = UserInfo.getUserId();
        userType = UserInfo.getUserType();
        
        //Checks if Portal User
        //CheckUser(userType, userId);
        selectedOption='0';
        
        filterOptions = new List<SelectOption>();

        filterOptions.add(new SelectOption(system.label.RCO00028+'#0#',system.label.ORD00174));
        filterOptions.add(new SelectOption(system.label.RCO00023+'#1#',system.label.RCO00023));
        filterOptions.add(new SelectOption(system.label.RCO00024+'#2#',system.label.RCO00024));
        filterOptions.add(new SelectOption(system.label.RCO00028+'#3#',system.label.RCO00028));
        
        system.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<< filterOptions: '+filterOptions);
        filterOptions.sort();

        getNumberCoachsLevel();
        
    }
    
    /*****************************************************************/
    /******************** ControllerSet Init *************************/
    /*****************************************************************/
    
    public ApexPages.StandardSetController contactCoachsSet {   
        get {
            if(contactCoachsSet == null) {
                
                User usr= [SELECT TECH_ExternalId__c,TECH_ContactTechExternalId__c
                           FROM User
                           WHERE id = :userId
                           LIMIT 1];//.TECH_ExternalId__c;
              
                techExternalId = usr.TECH_ExternalId__c;
                          
                System.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<< techExternalId: '+techExternalId);
                           
                leaderList = [SELECT  FirstName, LastName, Email, MobilePhone, Start_date__c, 
                                      Success_Bearing__c,Turnover_Current_Period__c,Coach_Parent_ID__c,Coach_Parent_Name__c,TECH_ExternalId__c
                              FROM CONTACT 
                              WHERE Account.TECH_ACCOwnerExternalId__c =: techExternalId 
                              AND ActivityStatus__c = true
                              AND Contact_Type__c='Leader'];

                system.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<< leaderList: '+leaderList);            
                Set<String> setExternalId = new Set<String>();
                if(techExternalId != null && techExternalId != ''){      
                   /* NAK 03-04-2017 <<START>>
                    coachListLevel1 = [SELECT  FirstName, LastName, Email, MobilePhone, Start_date__c, Contact_Type__c,
                                               Success_Bearing__c,Turnover_Current_Period__c,Coach_Parent_ID__c,Coach_Parent_Name__c,TECH_ExternalId__c
                                      FROM CONTACT 
                                      WHERE Coach_Parent_ID__c=:usr.TECH_ContactTechExternalId__c];*/
                   
                    for (Contact con : [SELECT  FirstName, LastName, Email, MobilePhone, Start_date__c, Contact_Type__c,
                                               Success_Bearing__c,Turnover_Current_Period__c,Coach_Parent_ID__c,Coach_Parent_Name__c,TECH_ExternalId__c
                                      FROM CONTACT 
                                      WHERE Coach_Parent_ID__c=:usr.TECH_ContactTechExternalId__c
                                      AND ActivityStatus__c = true]){
                        coachListLevel1.add(con);
                        setExternalId.add(con.TECH_ExternalId__c);
                    }
                    //NAK 03-04-2017 <<END>>
                                              
                    system.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<< coachListLevel1: '+coachListLevel1);
                }

                //NAK 03-04-2017 <<START>>
                 Map<String,List<Contact>> mapCoachLevel2 = new Map<String,List<Contact>>();
                 for (Contact newContact : [SELECT FirstName, LastName, Email, MobilePhone, Start_date__c, Success_Bearing__c,Contact_Type__c,
                                                  Turnover_Current_Period__c,Coach_Parent_ID__c,Coach_Parent_Name__c
                                            FROM CONTACT 
                                            WHERE Coach_Parent_ID__c IN :setExternalId
                                            AND ActivityStatus__c = true]){

                    if (mapCoachLevel2.containskey(newContact.Coach_Parent_ID__c)){
                      mapCoachLevel2.get(newContact.Coach_Parent_ID__c).add(newContact);
                    }else{
                      mapCoachLevel2.put(newContact.Coach_Parent_ID__c,new list<Contact>{newContact});
                    }
                 }
                 //NAK 03-04-2017 <<END>>  

                for(Contact c : coachListLevel1){
                  techExternalIdLvl1 = c.TECH_ExternalId__c;
                  System.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<< techExternalIdLvl1: '+techExternalIdLvl1);

                  if(techExternalIdLvl1 != null && techExternalIdLvl1 != ''){
                     /* NAK 03-04-2017 <<START>>
                      coachLevel2 = [SELECT FirstName, LastName, Email, MobilePhone, Start_date__c, Success_Bearing__c,Contact_Type__c,
                                           Turnover_Current_Period__c,Coach_Parent_ID__c,Coach_Parent_Name__c
                                     FROM CONTACT 
                                     where Coach_Parent_ID__c=:techExternalIdLvl1];
                      for(Contact clvl2 : coachLevel2){
                                coachListLevel2.add(clvl2);
                                conSet.add(clvl2.Coach_Parent_ID__c);
                      }*/

                      if (mapCoachLevel2.containskey(techExternalIdLvl1)){
                        coachListLevel2.addAll(mapCoachLevel2.get(techExternalIdLvl1));
                      }
                       //NAK 03-04-2017 <<END>>
                  }      
                }
               
                leaderList = new list<Contact>();
                for(Contact cListLvl1 : coachListLevel1){
                    coachListLevel1and2.add(cListLvl1);
                      if(cListLvl1.Contact_Type__c=='Leader'){
                          leaderList.add(cListLvl1);
                      }
                }
                       
                for(Contact cListLvl2 : coachListLevel2){
                    coachListLevel1and2.add(cListLvl2);
                    if(cListLvl2.Contact_Type__c=='Leader'){
                      leaderList.add(cListLvl2 );
                    }
                }
                
                system.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<< coachListLevel1and2: '+coachListLevel1and2);
                
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
            system.debug('>>>>>> refreshPageMyNetwork: selectedOption: '+selectedOption);
            if(selectedOption.contains('#0#')){
                system.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<< selectedOption: Choix 0');
                contactCoachsSet = new  ApexPages.StandardSetController(coachListLevel1and2);
            }else if(selectedOption.contains('#1#')){
                system.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<< selectedOption: Choix 1');
               contactCoachsSet = new  ApexPages.StandardSetController(coachListLevel1);
            }else if(selectedOption.contains('#2#')){
                system.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<< selectedOption: Choix 2');
               contactCoachsSet = new  ApexPages.StandardSetController(coachListLevel2);
            }else if(selectedOption.contains('#3#')){
                system.debug('## Class VFC_MonEquipeLandingPage - START VFC_MonEquipeLandingPage <<<<< selectedOption: Choix 3');
               contactCoachsSet = new  ApexPages.StandardSetController(leaderList);
            }    
        
        } catch (Exception e){
            ApexPages.addMessages(e);          
        }
        
        return null;
    } 
    
   
    public Contact getNumberCoachsLevel(){
        if(techExternalId != null && techExternalId != ''){
            numberCoachsLevel = [SELECT NB_Recruits_Level1__c, NB_Recruits_Level2__c FROM CONTACT where TECH_ExternalId__c=:techExternalId limit 1];
        }
          system.debug('## Class VFC_MonEquipeLandingPage - function getNumberCoachsLevel numberCoachsLevel:<<<<<'+numberCoachsLevel);
         return numberCoachsLevel;
    }
     


}