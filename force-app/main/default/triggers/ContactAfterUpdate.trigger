trigger ContactAfterUpdate on Contact (after update) {
/*
// ContactAfterUpdate
----------------------------------------------------------------------
-- - Name          : ContactAfterUpdate
-- - Author        : YGO
-- - Description   : 
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 26-AUG-2013  YGO    1.0      Initial version 
---------------------------------------------------------------------
**********************************************************************
*/
	
	
	System.debug('## START Trigger ContactAfterUpdate <<<<<'+UserInfo.getUserName());
	if(PAD.cantrigger('Bypass_AP22_1')){
		set<id> changedReportsToContact = new set<id>();
		
		for (integer i = 0 ; i<trigger.size;i++){
			if(trigger.new[i].ReportsToId != trigger.old[i].ReportsToId){
				changedReportsToContact.add(trigger.new[i].id);		
			}//end if reports to have change
		}//end of loop trigger
		
		System.debug('## changedReportsToContact.size() : '+changedReportsToContact.size());
		if(changedReportsToContact.size()>0){
			AP22_WeeklyActivity.updateApproverOnContactChange(changedReportsToContact);
		}
	}

	//JJE - 08/04/2021 - changer aussi le mobilephone sur le user
	List<Id> conToUpdate = new List<Id>();
	if(!SHW_IBZ_Utils.isInterfaceUser()){
		for(Contact con : Trigger.new){
			System.debug(Trigger.oldMap.get(con.Id).MobilePhone + ' ' + con.MobilePhone);
			if(Trigger.oldMap.get(con.Id).MobilePhone != null && con.MobilePhone != Trigger.oldMap.get(con.Id).MobilePhone){
				conToUpdate.add(con.Id);
			}
		}
		if(conToUpdate.size() >= 1){
			List<User> usersToUpdate = [SELECT ID,TECH_MergeContactID__c, MobilePhone FROM USER WHERE TECH_MergeContactID__c IN: conToUpdate
															AND IsActive = true LIMIT 10];
			for(User u : usersToUpdate){
				for(Contact con : Trigger.new){
					if(u.TECH_MergeContactID__c == con.Id){
						u.MobilePhone = con.MobilePhone;
					}
				}
			}
			update usersToUpdate;
		}
	}

	List<Contact> l_contactToCreateLead = new List<Contact>();
	// Aller chercher le record type Personnal contact
	for(Contact con : Trigger.new){
		if(con.LastModifiedById == Label.PardotUserId 
		&& con.RecordTypeId == Label.Rt_Personal_COntact_Id
		&& con.TECH_Owner_country__c == 'FRA'){
			l_contactToCreateLead.add(con);
		}
	}
	if(!l_contactToCreateLead.isEmpty()){
		AP55_ContactHandler.createLeadFromContact(l_contactToCreateLead);
	}

	//JJE - 28/01/2022 - trigger au cas où le contact change de région / besoin de recalculer les sharing
	Map<Id, Contact> m_contactToChangeSharing = new Map<Id, Contact>();
	for(Contact con : Trigger.new){
		if(con.AccountId != Trigger.oldMap.get(con.Id).AccountId) m_contactToChangeSharing.put(con.Id, con);
	}

	//S'il y a des contacts dont le compte a changé, aller chercher les enfants qui ont besoin d'être changés
	if(m_contactToChangeSharing.size() > 0){
		List<Order> ordersToUpdate = new List<Order>([SELECT ID, Tech_IsOwnerActive__c, BillToContactId, Status FROM Order WHERE BillToContactId In: m_contactToChangeSharing.keySet()]);
		List<Case> casesToUpdate = new List<Case>([SELECT ID, OwnerId, Owner.isActive, ContactId FROM Case WHERE ContactId In: m_contactToChangeSharing.keySet()]);
		
		//Désactiver les commandes pour pouvoir les modifier
		Map<Id, String> m_OrdersToDesactivate = new Map<Id, String>();
		for(Order ord : ordersToUpdate){
			if(ord.Tech_IsOwnerActive__c == true){
				m_OrdersToDesactivate.put(ord.Id, ord.Status);
				ord.Status = 'Draft';
			}
		}
		if(!Test.isRunningTest()) update ordersToUpdate;

		for(Order ord : ordersToUpdate){
			if(ord.Tech_IsOwnerActive__c == true){
				ord.AccountId = m_contactToChangeSharing.get(ord.BillToContactId).AccountId;
				ord.Status = m_OrdersToDesactivate.get(ord.Id) ;
			}
		}
		if(!Test.isRunningTest()) update ordersToUpdate;

		for(Case cas : casesToUpdate){
			if(cas.Owner.isActive == true) cas.AccountId = m_contactToChangeSharing.get(cas.ContactId).AccountId;
		}
		if(!Test.isRunningTest()) update casesToUpdate;

	}

	System.debug('## END Trigger ContactAfterUpdate <<<<<'+UserInfo.getUserName());
}