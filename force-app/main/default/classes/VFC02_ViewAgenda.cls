public with sharing class VFC02_ViewAgenda {
/* 
------------------------------------------------------------
-- - Name          : VFC02_ViewAgenda
-- - Author        : ASE
-- - Description   : Class used to view events of previous and next months
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 23-AUG-2012  ASE    1.0    Initial version
------------------------------------------------------------
*/
    public String country {get;set;}


    public void next() { 
        addMonth(1);
    }

    public void prev() { 
        addMonth(-1); 
    }
    
    public String selectedContact;
    
    public boolean isError ;
    
    
    public boolean getIsError(){
    	
    	return isError;
    }
    
    public Id getSelectedContact(){
        
        return selectedContact;
    }
    
     public void setSelectedContact(String selectedContact){
        
        this.selectedContact = selectedContact;
    }
    
   
    public VFC02_ViewAgenda() {
        
        system.debug('>>>>>>>>>>>>> 1. Start of VFC02_ViewAgenda '); 
        
        Contact contact = getConnectedUserContact();
        
        if(contact != null){
        	
        	selectedContact =  contact.Id;

            if (contact.TECH_ExternalId__c != null && contact.TECH_ExternalId__c != '') {
                this.country = contact.TECH_ExternalId__c.left(3);
                if (this.country == 'FRA' || this.country == 'fra') {
                    this.country = 'fra';
                } else if (this.country == 'ITA' || this.country == 'ita') {
                    this.country = 'ita';
                }
            }

       		initializePage();
       		
       		isError = false;
       		
        }else{
        	
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, system.label.dealer_agenda_error_contact);

			ApexPages.addMessage(myMsg);
        	
        	isError = true;
        }
        
        
    }
    
    public void initializePage(){
        
        system.debug('>>>>>>>>>>>>>>>>>>>>>>> initializePage');
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>selectedContact :'+selectedContact);
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>7. Start of constructor Day');
        
        Date d = system.today();  // default to today 
        
        Integer mo = d.month(); 
        
        Integer yr1 = d.year();
        
        system.debug('>>>>>>>>>>>>>month: '+mo);
        system.debug('>>>>>>>>>>>>>year: '+yr1);
        
        String m_param = system.currentPageReference().getParameters().get('mo');
        
        String y_param = system.currentPageReference().getParameters().get('yr1');
        
        system.debug('>>>>>>>>>>>>>m_param: '+m_param);
        system.debug('>>>>>>>>>>>>>y_param: '+y_param);

        setMonth(d);
        
    }
    
    
     private String getConnectedUserId(){
        
        return  UserInfo.getUserId();
        
    }
    
    private String getSelectedUser(){
    	
    		system.debug('>>>>>>>>>>>>> getSelectedUser getSelectedContact() : '+ getSelectedContact()); 
    	
    		User user = [select id, TECH_ExternalId__c from User where TECH_MergeContactID__c =: getSelectedContact() limit 1];
    	
    		return user.Id;

    }
    
    
    private  Contact getConnectedUserContact(){
        
        User user = [select id, TECH_ExternalId__c, TECH_MergeContactID__c from user where id =: Userinfo.getUserId() limit 1];
        
        system.debug('>>>>>>>>>>>>> getConnectedSFDUserContact TECH_ContactID__c : '+ user.TECH_MergeContactID__c);
        
        if(user.TECH_MergeContactID__c  != null){
        
            return [select id, TECH_ExternalId__c from Contact where id = : user.TECH_MergeContactID__c limit 1];
    
        }else{
            
            return null;
        }
  
    }
    
 
    public List<AP02_AgendaItem_Month.Week> getWeeks() { 
        system.debug('>>>>>>>>>>>>>  13. Start of List<AP02_AgendaItem_Month.Week> getWeeks() '); 
        system.assert(month!=null,'month is null');
        // call 14. AP02_AgendaItem_Month.List<Week> getWeeks()        
        system.debug('>>>>>>>>>>>>>  month.getWeeks() :'+month.getWeeks()); 
        return month.getWeeks();
    }
  
    public AP02_AgendaItem_Month getMonth() { 
        system.debug('>>>>>>>>>>>>>  16. Start of AP02_AgendaItem_Month getMonth() '); 
        system.debug('>>>>>>>>>>>>>  getMonth() :' +month); 
        return month; 
    } 
    
    /*public List<SelectOption> getContactListOptions(){
        
        List<Contact> contacts = [select Id, Name from Contact limit 1000];
        
        List<SelectOption> contactListOptions = new List<SelectOption>();
        
        for(Contact contact:contacts){
            
            contactListOptions.add(new Selectoption(Contact.Id, contact.Name));
            
        }
        
        return contactListOptions;
        
    }*/
    
     public List<SelectOption> getContactListOptions(){
        
        List<Contact> contacts = [select Id, Name from Contact where Id in :getContactHierarchy(getConnectedUserContact().Id, 5) LIMIT 1000];
        
        List<SelectOption> contactListOptions = new List<SelectOption>();
        
        for(Contact contact:contacts){
            
            contactListOptions.add(new Selectoption(Contact.Id, contact.Name));
            
        }
        
        return contactListOptions;
        
    }
    
    
    /**
	* Recursively iterate through contact report_To to get the contact Id hierarchy below
	*/
	private static Id[] getContactHierarchy(ID contactId, Integer level){
		
		Id[] contacts = new List<Id>();
		
		if(contactId != null){
			
			//own contact
			contacts.add(contactId);
			
			system.debug('>>>>>>>>>>>>>>>>>>> 1. contactId'+contactId);
			
			List<Contact> contactList1Result = [select Id, ReportsToId from contact where ReportsToId =:contactId]; 
			
			for(Contact con1 :contactList1Result){
				
				system.debug('>>>>>>>>>>>>>>>>>>> 2. contactId'+con1.Id);
				
				contacts.add(con1.Id);
			}
			
			for(Integer i = 1; i < level; i++){
				
                List<Id> l_idContactList1Result = new List<Id>();
				List<Contact> contactList2Result = new List<Contact>();
				
				for(Contact con : contactList1Result){
					//contactList2Result.addAll([select Id, ReportsToId from contact where ReportsToId =:con.Id]);
                    l_idContactList1Result.add(con.Id);
				}
                contactList2Result.addAll([select Id, ReportsToId from contact where ReportsToId IN :l_idContactList1Result]);
				
				contactList1Result = contactList2Result;
				
				for(Contact con2 : contactList2Result){
					
					contacts.add(con2.Id);
				}
				
			}
		}
		
		system.debug('>>>>>>>>>>>>>>>>>>> 3 contacts'+contacts);
		
		return contacts;
	}


    private void setMonth(Date d) { 
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>2. Start of setMonth of date: '+d);        
        month = new AP02_AgendaItem_Month(d);  // 3. call public AP02_AgendaItem_Month( Date value )
        system.debug('>>>>>>>>>>>>>>>>>>>>>>> month: '+month);
        system.assert(month != null); 

        Date[] da = month.getValidDateRange();  // gather events that fall in this month and 9.call public List<Date> getValidDateRange()
       
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>10 .Querying events');

        boolean isConnectedContact =  isConnectedContact();
         
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>isConnectedContact: '+isConnectedContact);  
        
        if(isConnectedContact){
        	events = [  select id,Name,Description__c,Start__c,End__c, Priority__c, OwnerId, Location__c, AllDayEvent__c, TECH_ColorCode__c,
                    TECH_IsReportsTo__c, TECH_Contact__c , TECH_Parent_AGI__c, TECH_InvitationStatus__c,TECH_RecipientName__c
                    from AGI_AgendaItem__c
                    where 
                    Start__c >= :da[0] 
                    AND Start__c <= :da[1] 
                    AND ( Recipient__c = : getSelectedContact() or  Recipient__c = null )
                    AND (TECH_Contact__c =: getSelectedContact()  or TECH_Contact__c = null)
                    order by Start__c];
                    
          List<AGI_AgendaItem__c> tasks = [  select id,Name,Description__c,Start__c,End__c, DueDate__c, Priority__c, OwnerId, Location__c, AllDayEvent__c, TECH_ColorCode__c,
                    TECH_IsReportsTo__c, TECH_Contact__c , TECH_Parent_AGI__c, TECH_InvitationStatus__c,TECH_RecipientName__c
                    from AGI_AgendaItem__c
                    where 
                    DueDate__c >= :da[0] 
                    AND DueDate__c <= :da[1] 
                    AND ( Recipient__c = : getSelectedContact() or  Recipient__c = null )
                    AND (TECH_Contact__c =: getSelectedContact()  or TECH_Contact__c = null)
                    AND RecordTypeId in (SELECT r.id FROM RecordType r WHERE DeveloperName = 'AGI_Task' and SObjectType = 'AGI_AgendaItem__c' )
                    order by Start__c
                    ];
                    
                    for(AGI_AgendaItem__c task : tasks){
                    	task.Start__c = task.DueDate__c;
                    	task.End__c = task.DueDate__c;
                    	events.add(task);
                    }
                    
        	
        }else{
        	
        	 events = [  select id,Name,Description__c,Start__c,End__c, Priority__c, OwnerId, Location__c, AllDayEvent__c, TECH_ColorCode__c,
                    TECH_IsReportsTo__c, TECH_Contact__c , TECH_Parent_AGI__c, TECH_InvitationStatus__c,TECH_RecipientName__c
                    from AGI_AgendaItem__c
                    where 
                    Start__c >= :da[0] 
                    AND Start__c <= :da[1] 
                    AND Recipient__c = : getSelectedContact()
                    /*AND TECH_Contact__c = :getConnectedUserContact().Id*/
                    order by Start__c];
        }
                 
                    
       
        
        system.debug('>>>>>>>>>>>>>>>>events:' +events); 
        
        Map<Id, User> usersMap = getUserMap(events);
        
        month.setEvents(events, usersMap);  // merge those events into the month class and 11. call setEvents(List<AGI_AgendaItem__c> ev)
        
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>End of setMonth of date: ');
        
    }
    
    private  boolean isConnectedContact(){
    	
    	return getConnectedUserContact().Id == getSelectedContact();
    }
    
    private Map<Id, User> getUserMap(List<AGI_AgendaItem__c> agis){
        
        Map<Id, User> userMap = new Map<Id, User>();    
        
        List<User> users = [select Name, Id from User where Id in :getListOwnerfromEvent(agis)];
        
        system.debug('>>>>>>>>>>>>>>>>users:' +users);      
        
        for(User user : users){
            
            userMap.put(user.Id, user);
            
        }      
                     
        system.debug('>>>>>>>>>>>>>>>>usersMap:' +userMap.values());
        
        return userMap; 
    }
    
    private List<Id>  getListOwnerfromEvent(List<AGI_AgendaItem__c> agis){
        
        List<Id> ids = new List<Id>();
        
        for(AGI_AgendaItem__c agi : agis){
            
             system.debug('>>>>>>>>>>>>>>>> User Ids in where clause' + agi.OwnerId); 
            
            ids.add(agi.OwnerId);
        }
        
        return ids;
    }
  
    private void addMonth(Integer val) { 
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>Start of addMonth: '+val);
        Date d = month.getFirstDate();
        d = d.addMonths(val);
        setMonth(d);
    }
    
    private List<AGI_AgendaItem__c> events; // call public void setEvents(List<AGI_AgendaItem__c> ev)
    private AP02_AgendaItem_Month month; // call public String getMonthName() 
      
}