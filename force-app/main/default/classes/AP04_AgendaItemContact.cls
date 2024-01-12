public class AP04_AgendaItemContact {
/*
----------------------------------------------------------------------
-- - Name          : AP04AgendaItemContact 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Class for Triggers insert,update,delete on objects
--                   AgendaItemContact for share Agenda BR 04.
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 21-AUG-2012  NGO    1.0      Initial version 
-- 28-AUG-2012	NGO	   1.1		Change implementation due to limitation of
								High volume customer portal license
-- 07-DEC-2012  NGO    1.2      Correction after salesforce review 
----------------------------------------------------------------------	
*/	
	
	public static Map<Id, AGI_AgendaItem__c> agendaItemsMap;
	
	public static Map<Id, User> usersMap;
	
	public static Map<String, Id> agendaRecordTypeByName;
	
	public static Map<Id, String> agendaRecordTypeById;
	
	public static String READ_ONLY_PREFIX = 'RO_';
	
	
	
	private static  void initializeRecordType(){
		
		List<RecordType> recordTypes = [select Name, Id from RecordType where SobjectType = 'AGI_AgendaItem__c'];
		
		agendaRecordTypeById = new Map<Id, String>();
		
		agendaRecordTypeByName = new Map<String, Id>();
		
		for(RecordType rc : recordTypes){
			
			agendaRecordTypeById.put(rc.Id, rc.Name);
			
			agendaRecordTypeByName.put(rc.Name, rc.Id);
			
		}
		
	}
	
	/**
	* Duplicate an agendaItem to share with the associated contacts in agendaItemContacts.
	*/
	public static void shareAgendaWithContact(List<AIC_AgendaItemContact__c> agendaItemContacts){
		
		System.Debug('## >>> shareAgendaWithContact >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> shareAgendaWithContact >>> list agendaItemContacts ' + agendaItemContacts);
		
		List<AGI_AgendaItem__c> agi_results = new List<AGI_AgendaItem__c>();
		
		initializeAgendaItemsMap(agendaItemContacts);
		
		initializeUserMap(getAgendasFromAICs(agendaItemContacts));
		
		initializeRecordType();
		
		for(AIC_AgendaItemContact__c agendaItemContact : agendaItemContacts){
		
			AGI_AgendaItem__c share = getAgendaItem_shareToCreate(agendaItemsMap.get(agendaItemContact.AgendaItem__c), agendaItemContact.Dealer__c, agendaItemContact.Dealer__c, agendaItemContact.Id);
			
			
			if(share != null){
				agi_results.add(share);
			}
		}
		
		// Insert all of the newly created Share records and capture save result
	    insert(agi_results);
	 
	 	System.Debug('## >>> shareAgendaWithContact >>> list agi_results ' + agi_results);
	 
	 	System.Debug('## >>> shareAgendaWithContact >>> END ' + UserInfo.getName());
	}
	
	/**
	* Duplicate an agendaItem to share with the reportsTo of the associated contacts in agendaItemContacts.
	*/
	public static void shareAgendaWithContactReportsTo(List<AIC_AgendaItemContact__c> agendaItemContacts){
		
		System.Debug('## >>> shareAgendaWithContactReportsTo AIC >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> shareAgendaWithContactReportsTo AIC >>> list agendaItemContacts ' + agendaItemContacts);
		
		List<AGI_AgendaItem__c> agi_results = new List<AGI_AgendaItem__c>();
		
		initializeAgendaItemsMap(agendaItemContacts);
		
		initializeUserMap(getAgendasFromAICs(agendaItemContacts));
		
		initializeRecordType();
		
		for(AIC_AgendaItemContact__c agendaItemContact : agendaItemContacts){
		
			if(!isPrivate(agendaItemContact.AgendaItem__c)){
				
				Id[] contacts = getContactHierarchy(agendaItemContact.Dealer__c, SHW_IBZ_Constants.REPORTS_TO_LEVEL_NBR);
				
				Id agendaItemContactOwnerId = getContactIdFromUser(agendaItemsMap.get(agendaItemContact.AgendaItem__c).OwnerId);
			
				for(Id contactId : contacts){
					
					if(!isInvitorAlsoManager(contactId, agendaItemContactOwnerId) ){
					
						AGI_AgendaItem__c share = getAgendaItem_shareToCreate(agendaItemsMap.get(agendaItemContact.AgendaItem__c), contactId, agendaItemContact.Dealer__c, agendaItemContact.Id);
	
						share.TECH_IsReportsTo__c = true;
						
						agi_results.add(share);
					}
				}
			}	
		}

	    insert(agi_results);
	    
	    System.Debug('## >>> shareAgendaWithContactReportsTo AIC >>> list agi_results ' + agi_results);
	 
	 	System.Debug('## >>> shareAgendaWithContactReportsTo AIC >>> END ' + UserInfo.getName());
	}
	
	
	/**
	* Duplicate an agendaItem to share with the reportsTo of contacts owner of the agendaItems.
	*/
	public static void shareAgendaWithContactReportsTo(List<AGI_AgendaItem__c> agendaItems){
		
		System.Debug('## >>> shareAgendaWithContactReportsTo AGI>>> START ' + UserInfo.getName());
		
		System.Debug('## >>> shareAgendaWithContactReportsTo AGI>>> list agendaItemContacts ' + agendaItems);
		
		List<AGI_AgendaItem__c> agi_results = new List<AGI_AgendaItem__c>();
		
		initializeUserMap(agendaItems);
		
		initializeRecordType();
		
		for(AGI_AgendaItem__c agendaItem : agendaItems){
			
			//make sure agendaItem is not child and is public
			if(isParent(agendaItem) && !isPrivate(agendaItem)){
				
				Id agendaItemContactOwnerId = getContactIdFromUser(agendaItem.OwnerId);
				
				Id[] contacts = getContactHierarchy(agendaItemContactOwnerId, SHW_IBZ_Constants.REPORTS_TO_LEVEL_NBR);
			
				for(Id contactId : contacts){
					
					if(!isInvitorAlsoManager(contactId, agendaItemContactOwnerId )){
						
						AGI_AgendaItem__c share = getAgendaItem_shareToCreate(agendaItem, contactId, agendaItemContactOwnerId ,null);
							
						share.TECH_IsReportsTo__c = true;
					
						agi_results.add(share);
					}
	
				}
			}
		}
	    insert(agi_results);
	    
	    System.Debug('## >>> shareAgendaWithContactReportsTo AGI >>> list agi_results ' + agi_results);
	 
	 	System.Debug('## >>> shareAgendaWithContactReportsTo AGI >>> END ' + UserInfo.getName());
	}
	
	private static boolean isInvitorAlsoManager(Id contactId, Id ownerContactId){
		
		if(contactId == ownerContactId){
			return true;
		}else{
			return false;
		}
		
	}
	
	/**
	* Remove the agendaItem child associated with the contacts in agendaItemContacts.
	*/
	public static void unShareAgendaWithContact(List<AIC_AgendaItemContact__c> agendaItemContacts){
		
		System.Debug('## >>> unShareAgendaWithContact >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> unShareAgendaWithContact >>> list agendaItemContacts ' + agendaItemContacts);
		
		List<AGI_AgendaItem__c> agi_results = new List<AGI_AgendaItem__c>();

		for(AIC_AgendaItemContact__c agendaItemContact : agendaItemContacts){
			
			agi_results.addAll(getAgendaItemShareByAIC(agendaItemContact.Id));
			
		}
		
		 // Insert all of the newly created Share records and capture save result
	    Database.DeleteResult[] agendaItemShareDeletedResult = Database.delete(agi_results, false);
	    
	    System.Debug('## >>> unShareAgendaWithContact >>> list agi_results ' + agi_results);
	 
	 	System.Debug('## >>> unShareAgendaWithContact >>> END ' + UserInfo.getName());
	    
	}
	
	
	/**
	* Remove the agendaItem child associated with the reportsTo for contacts in agendaItemContacts.
	*/
	public static void unShareAgendaWithContactReportsTo(List<AIC_AgendaItemContact__c> agendaItemContacts){
		
		System.Debug('## >>> unShareAgendaWithContactReportsTo >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> unShareAgendaWithContactReportsTo >>> list agendaItemContacts ' + agendaItemContacts);
		
		List<AGI_AgendaItem__c> agi_results = new List<AGI_AgendaItem__c>();
		
		for(AIC_AgendaItemContact__c agendaItemContact : agendaItemContacts){
	
			agi_results.addAll(getAgendaItemShareByAIC(agendaItemContact.Id));	
		}
		
	    delete(agi_results);
	    
	    System.Debug('## >>> unShareAgendaWithContactReportsTo >>> list agi_results ' + agi_results);
	 
	 	System.Debug('## >>> unShareAgendaWithContactReportsTo >>> END ' + UserInfo.getName());
	 
	}
	
	/**
	* Remove all the agendaItem child for the agendaItems.
	*/
	public static void unShareAgendaWithAllContacts(List<AGI_AgendaItem__c> agendaItems){
		
		System.Debug('## >>> unShareAgendaWithAllContacts >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> unShareAgendaWithAllContacts >>> list agendaItems ' + agendaItems);
		
		List<AGI_AgendaItem__c> agi_results = new List<AGI_AgendaItem__c>();
		
		for(AGI_AgendaItem__c agendaItem : agendaItems){
		
			if(isParent(agendaItem)){
				agi_results.addAll(getAgendaItemChildren(agendaItem.Id));
			}
		}
		
	    delete(agi_results);
	    
	    System.Debug('## >>> unShareAgendaWithAllContacts >>> list agi_results ' + agi_results);
	 
	 	System.Debug('## >>> unShareAgendaWithAllContacts >>> END ' + UserInfo.getName());
	}
	
	/**
	* Synchronize all the update done on the parent to its children.
	*/
	public static void updateAgendaItemChildren(List<AGI_AgendaItem__c> agendaItems){
		
		System.Debug('## >>> updateAgendaItemChildren >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> updateAgendaItemChildren >>> list agendaItems ' + agendaItems);
		
		List<AGI_AgendaItem__c> agi_results = new List<AGI_AgendaItem__c>();
		
		for(AGI_AgendaItem__c agendaItem : agendaItems){
		
			if(isParent(agendaItem)){
				agi_results.addAll(getAgendaItemUpdates(agendaItem));
			}
		}
		
	    update(agi_results);
	    
	    System.Debug('## >>> updateAgendaItemChildren >>> list agi_results ' + agi_results);
	 
	 	System.Debug('## >>> updateAgendaItemChildren >>> END ' + UserInfo.getName());
	}
	
	
	/**
	* Change an agendaItem state from public to private and vice versa.
	*/
	public static void updatePrivatePublicAgendaItem(Map<ID, sObject> oldAGIMap, List<AGI_AgendaItem__c> agendaItems){
		
		System.Debug('## >>> updatePrivatePublicAgendaItem >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> updatePrivatePublicAgendaItem >>> list agendaItems ' + agendaItems);
		
		for(AGI_AgendaItem__c agendaItem : agendaItems){
			
			if(isParent(agendaItem)){
				
				AGI_AgendaItem__c oldAGI = (AGI_AgendaItem__c)oldAGIMap.get(agendaItem.Id);
				//check if private field has been updated
				if(oldAGI.Private__c != agendaItem.Private__c){
					
					if(agendaItem.Private__c){//agi has become private
						
							unShareAgendaWithAllContacts(new List<AGI_AgendaItem__c> {agendaItem});
							
							shareAgendaWithContact(getAICbyAGI(agendaItem.Id));
							
					//agi has become public	
					}else{
						
						shareAgendaWithContactReportsTo(new List<AGI_AgendaItem__c> {agendaItem});
						
						shareAgendaWithContactReportsTo(getAICbyAGI(agendaItem.Id));
					}	
				}
			}
		}
		
	 	System.Debug('## >>> updatePrivatePublicAgendaItem >>> END ' + UserInfo.getName());
	}
	
	/**
	* Remove the child associated with the old contact and add child for the new one.
	*/
	public static void updateAgendaItemContact(Map<ID, sObject> oldAICMap, List<AIC_AgendaItemContact__c> aics){
		
		System.Debug('## >>> updateAgendaItemContact >>> START ' + UserInfo.getName());
		
		System.Debug('## >>> updateAgendaItemContact >>> list aics ' + aics);
		
		initializeAgendaItemsMap(aics);
		
		for(AIC_AgendaItemContact__c aic : aics){
			
			if(isParent(agendaItemsMap.get(aic.AgendaItem__c))){
				
				AIC_AgendaItemContact__c oldAIC = (AIC_AgendaItemContact__c)oldAICMap.get(aic.Id);
				//check if private field has been updated
				if(oldAIC.Dealer__c != aic.Dealer__c){
					
					unShareAgendaWithContact(new List<AIC_AgendaItemContact__c>{oldAIC});
					unShareAgendaWithContactReportsTo(new List<AIC_AgendaItemContact__c>{oldAIC});
					
					shareAgendaWithContact(new List<AIC_AgendaItemContact__c>{aic});
					shareAgendaWithContactReportsTo(new List<AIC_AgendaItemContact__c>{aic});
				}
			}
		}
		
		System.Debug('## >>> updateAgendaItemContact >>> END ' + UserInfo.getName());	
	}
	
	/**
	* Create an agendaItemContact for each EventAttendee (contact) of the event.
	* This method is part of BR10, it has been placed here due to the inability of 
	* testing this method because ot the restriction of the EventAttendee object.
	*/
	public static void createAICByEventAttendee(List<AGI_AgendaItem__c> agis){
		 
		List<AIC_AgendaItemContact__c> aics = new List<AIC_AgendaItemContact__c>();
	
		for(AGI_AgendaItem__c agi : agis){

			if(isParent(agi) && agi.TECH_Event_ID__c != null){
				for(EventAttendee attendee: [select Id, AttendeeId from EventAttendee where EventId = :agi.TECH_Event_ID__c]){
					
					AIC_AgendaItemContact__c aic = convertEventAttendeeToAIC(agi, attendee);
					
					if(aic != null){
						aics.add(aic);
					}
				}
			}
		}
		
		insert(aics);	
		
	}
	
	private static AIC_AgendaItemContact__c convertEventAttendeeToAIC(AGI_AgendaItem__c agendaItem, EventAttendee attendee){
		
		AIC_AgendaItemContact__c aic = null;
		
		if(isContact(attendee.AttendeeId)){
			
			aic = new AIC_AgendaItemContact__c(AgendaItem__c= agendaItem.Id, Dealer__c = attendee.AttendeeId);
			
		}
		
		return aic;
	}
	
	private static Boolean isContact(Id id){
	    		
    	String sId = id;
    	
    	Map<String,String> keyPrefixMap = SHW_IBZ_Utils.populateObjectNameByIdMap();
    	
    	String tPrefix = sId.subString(0,3);
    	
    	System.debug('Task Id[' + sId + ' - '+tPrefix+' ] is associated to Object of Type: ' + keyPrefixMap.get(tPrefix));
    	
    	if(keyPrefixMap.get(tPrefix) == SHW_IBZ_Constants.CONSTANT_CONTACT_OBJECT_NAME){
    		
    		return true;
    	}

		return false;
	}
	
	/**
	* Get all AgendaItemContact by AgendaItem
	*/
	private static AIC_AgendaItemContact__c[] getAICbyAGI(Id agendaItem){
		
		AIC_AgendaItemContact__c[] aics = [select Id, Dealer__c, AgendaItem__c from AIC_AgendaItemContact__c where AgendaItem__c =: agendaItem];
		
		return aics;
		
	}
	
	/**
	* Retrieve the list of all children and update it based on modification do on parent.
	*/
	private static AGI_AgendaItem__c[] getAgendaItemUpdates(AGI_AgendaItem__c agendaItem){
		
		List<AGI_AgendaItem__c> updates = new List<AGI_AgendaItem__c>();
	
		for(AGI_AgendaItem__c agiTobeUpdate : getAgendaItemChildren(agendaItem.Id)){
			
			updates.add(updateAllFieldsAGI(agiTobeUpdate, agendaItem));
			
		}
	
		return updates;	
	}
	
	/**
	* Update all non-readonly field. 
	*/
	private static AGI_AgendaItem__c updateAllFieldsAGI(AGI_AgendaItem__c  agiTobeUpdate, AGI_AgendaItem__c agendaItem){
		
		agiTobeUpdate.Name = agendaItem.Name;
		agiTobeUpdate.Description__c = agendaItem.Description__c;		 	
		agiTobeUpdate.DueDate__c = agendaItem.DueDate__c;
		agiTobeUpdate.End__c = agendaItem.End__c;
		agiTobeUpdate.Location__c =	agendaItem.Location__c;
		agiTobeUpdate.Priority__c	= agendaItem.Priority__c;
		agiTobeUpdate.Private__c = agendaItem.Private__c;
		agiTobeUpdate.ShowTimeAs__c = agendaItem.ShowTimeAs__c;	 
		agiTobeUpdate.Start__c = agendaItem.Start__c;
		agiTobeUpdate.Status__c = agendaItem.Status__c;
		agiTobeUpdate.TaskType__c = agendaItem.TaskType__c;
		
		return agiTobeUpdate;
		
	}
	
	/**
	* create agenda_item.
	*/
	private static AGI_AgendaItem__c getAgendaItem_shareToCreate(AGI_AgendaItem__c agendaItem, Id dealerOwner, Id contactRecipient, Id aic){
			
		if(dealerOwner <> null){
		
			AGI_AgendaItem__c agi_child = duplicateAGI(agendaItem);
			
			return configureChildAGI(agendaItem, agi_child, dealerOwner, contactRecipient, aic);
		
		}else{
			
			return null;
		}
			
	}
	
	/**
	* Configure the clone object to make it a good child.
	*/
	private static AGI_AgendaItem__c configureChildAGI(AGI_AgendaItem__c original, AGI_AgendaItem__c child, Id dealer, Id contactRecipient, Id aic){

		//set contact dealer
		child.TECH_Contact__c  = dealer;
		
		//set specific color code
		
		child.TECH_ColorCode__c =  system.label.AGI_SharedColorCode;
		
		if(contactRecipient != null){
			
			child.recipient__c = contactRecipient;
			
		}else{
			
			child.recipient__c = getContactIdFromUser(original.OwnerId);
		}
		
		if(aic != null){//case when a non high volume customer is creating an AGI aic is null
			
			child.TECH_Agenda_Item_Contact__c = aic;	
		}
		
		//set parent
		child.TECH_Parent_AGI__c = original.id;
		
		//change ReportType to RO
		child.RecordTypeId = getRORecordType(original.RecordTypeId);
		
		child.TECH_InvitationStatus__c = 'Pending';
		
		return child;
	}
	
	
	private static Id getRORecordType(Id id){
		
		String nameRc = agendaRecordTypeById.get(Id);
		
		return agendaRecordTypeByName.get(READ_ONLY_PREFIX + nameRc);
		
	}
	
	/**
	* Retrieve AgendaItem and clone it using the sObject api
	*/
	private static AGI_AgendaItem__c duplicateAGI(AGI_AgendaItem__c agendaItem){
		
		AGI_AgendaItem__c agi_child = agendaItem.clone(false, true);
		
		return agi_child;
	}
	
	
	/**
	* Get all AgendaItem children whose parent is agi.
	*/
	private static AGI_AgendaItem__c[] getAgendaItemChildren(Id agi){
											
		AGI_AgendaItem__c[] shares = [select id from AGI_AgendaItem__c a 
								where a.TECH_Parent_AGI__c = :agi ];
																				
		return shares;					
		
	}
	
	/**
	* Get in AgendaItem child for the corresponding AgendaItemContact.
	*/
	private static AGI_AgendaItem__c[] getAgendaItemShareByAIC(Id aic){
											
		AGI_AgendaItem__c[] shares = [select id from AGI_AgendaItem__c a 
								where a.TECH_Agenda_Item_Contact__c = :aic ];
																				
		return shares;					
		
	}
	
	/**
	* Recursively iterate through contact report_To to get the contact Id hierarchy
	*/
	private static Id[] getContactHierarchy(ID contact, Integer level){
		
		Id[] contacts = new List<Id>();
		
		if(contact != null){
			
			Id recursive = contact;
			
			for(Integer i = 0; i < level; i++){
				
				Contact con = [select Id, ReportsToId from contact where id = :recursive limit 1][0];
				
				if(con.ReportsToId != null){
					
					contacts.add(con.ReportsToId);
					
					recursive = con.ReportsToId;
					
				}else{
					
					break;
				}
			}
		}
		
		return contacts;
	}
	/**
	* Check if agenda item is a parent. 
	*/
	private static Boolean isParent(AGI_AgendaItem__c agi){
		
		return agi.TECH_Parent_AGI__c == null ? true : false;
	}
	
	
	/**
	* Check if agenda item is private or public. 
	*/
	private static Boolean isPrivate(AGI_AgendaItem__c agi){
		
		return agi.Private__c;
	}
	
	/**
	* Check if agenda item is private or public. 
	*/
	private static Boolean isPrivate(Id agi){
		
		return isPrivate([select Id, Private__c from AGI_AgendaItem__c where id =: agi]);
	}
	
	
	

	
	private static void initializeAgendaItemsMap(List<AIC_AgendaItemContact__c> aics){
		
		String sosql = SHW_IBZ_Utils.getCreatableFieldsSOQLByID('AGI_AgendaItem__c', getListAgendasFromAIC(aics));
		
		System.debug('sosql in initializeAgendaItemsMap'+sosql);
		
		List<AGI_AgendaItem__c> agis = Database.query(sosql);
		
		agendaItemsMap = new Map<Id,AGI_AgendaItem__c>(agis);
		
		
	}
	
	private static List<Id> getListAgendasFromAIC(List<AIC_AgendaItemContact__c> aics){
		
		List<Id> ids = new List<Id>();
		
		for(AIC_AgendaItemContact__c aic : aics){
			
			ids.add(aic.AgendaItem__c);
			
		}
		
		return ids;
		
	}
	
	/**
	* Get the contact from the userId 
	*/
	private static Id getContactIdFromUser(Id userId){
		
		//return [select ContactId from user where id =: userId limit 1][0].ContactId;
		return usersMap.get(userId).ContactId;
		
	}
	
	private static void initializeUserMap(List<AGI_AgendaItem__c> agis){
		
		
		usersMap = new Map<Id,User>([select contactId from user where id in :getListUserFromAGI(agis)]);
		
		
	}
	
	private static List<Id> getListUserFromAGI(List<AGI_AgendaItem__c> agis){
		
		List<Id> ids = new List<Id>();
		
		for(AGI_AgendaItem__c agi : agis){
			
			ids.add(agi.OwnerId);
			
		}
		
		return ids;
		
	}
	
	private static List<AGI_AgendaItem__c> getAgendasFromAICs(List<AIC_AgendaItemContact__c> agendaItemContacts){
		
		List<AGI_AgendaItem__c> agis = new List<AGI_AgendaItem__c>();
		
		for(AIC_AgendaItemContact__c aic :agendaItemContacts){
			
			agis.add(agendaItemsMap.get(aic.AgendaItem__c));
		}
		
		return agis;
	}
}