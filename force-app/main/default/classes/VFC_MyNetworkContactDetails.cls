public class VFC_MyNetworkContactDetails {

/* 
----------------------------------------------------------------------
-- - Name          : VFC_MyNetworkContactDetails 
-- - Author        : AAT
-- - Description   : Controller for VFC_MyNetworkContactDetails Page
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

	//Global Id
//	public Id contactId {get;set;}
	//Global String
    public String contactId {get;set;}
    public CONTACT c {get;set;}
    public List<CONTACT> contactDetailsSet {get;set;}
    public String maillingAddress {get;set;}
    public CONTACT c1 {get;set;}
     public String techExternalId {get;set;}
     public Integer NBRecruits {get;set;}
     public Contact currentDealer {get;set;}

	/*****************************************************************/
	/******************** Page Constructor ***************************/
	/*****************************************************************/
	public VFC_MyNetworkContactDetails (){
	
	    contactId	= ApexPages.currentPage().getParameters().get('id');
	   	
	    User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
	    currentDealer = [SELECT Id, AccountCountryCode__c FROM Contact WHERE Id =: currentUser.ContactId];

	    techExternalId = [Select TECH_ExternalId__c
                           From CONTACT
                          Where id = :contactId
                          limit 1].TECH_ExternalId__c;
		
		c =  [SELECT  FirstName, LastName, Email, Phone, Success_Bearing__c, Start_Date__c,Birthdate, MobilePhone,MailingStreet,
						MailingPostalCode,MailingCity,Turnover_Current_Period__c,BadDebt__c,Turnover_Previous_Period__c,
						Number_of_recruits__c,Last_invoiced_order_date__c,Last_Invoiced_Order_Total_Amount__c, AccountCountryCode__c,
						ActivitySegment__c
					   FROM CONTACT 
					   where id=:contactId];
			
	   maillingAddress = c.MailingStreet+' \n'+c.MailingPostalCode+' '+c.MailingCity;
	   c.address__c = maillingAddress;
		
		NBRecruits =  [SELECT  count()
									   FROM CONTACT 
									   where Coach_Parent_ID__c=:techExternalId];
									   system.debug('## Class VFC_MyNetworkContactDetails - END VFC_MyNetworkContactDetails NBRecruits: <<<<<'+NBRecruits);
									   c.Number_of_recruits__c = NBRecruits;
    }
    
   	
     public PageReference cancel() 
    {
        try
        {
            PageReference pageRef = Page.VFP_MyNetworkLandingPage;
            return pageRef;
        } catch (Exception e)
        {
            ApexPages.addMessages(e);          
        }
        
        return (null);
    }
    
   
}