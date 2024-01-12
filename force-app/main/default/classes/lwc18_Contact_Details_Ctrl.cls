public without sharing class lwc18_Contact_Details_Ctrl {
	
    @AuraEnabled
    public static Contact getContactInfos(String contactId) {
        //return AP1003_Utils_Contact.getContactInfo(contactId);

        Contact con = [SELECT Id, Name
                        ,Title
                        ,Coach_Parent_Name__c
                        ,Last_invoiced_order_date__c
                        ,Parent_STH_Name__c
                        ,Parent_STH_Id__r.STHID__c
                        ,LU_Sponsor_Level_1_Name__c
                        ,LU_Number_Of_Inactive_Weeks__c
                        ,STHID__c
                        ,Lu_Notes__c
                        ,LU_Consent_Answer_Date__c
                        ,LU_GDPR_Customer_Informed__c
                        ,HasOptedOutOfEmail
                        ,AccountName__c
                        ,ReportsToName__c
                        ,Sponsor1stLevel__c
                        ,Sponsor1stLevel__r.STHID__c
                        ,Contact_Type__c
                        ,MailingAddressComment__c
                        ,OtherAddress
                        ,OtherAddressComment__c
                        ,OtherPhone
                        ,Email
                        ,Phone
                        ,HomePhone
                        ,MobilePhone
                        ,Fax
                        ,MailingAddress
                        ,Birthdate
                        ,ActivityStatus__c
                        ,DirectCommissionRate__c
                        ,CurrentBalance__c
                        ,CurrentBusinessPeriod__c
                        ,CurrentCommercialCycle__c
                        ,PersonalMessage__c
                        ,DealerSenioritySegment__c
                        ,ActivitySegment__c
                        ,SalesSegment__c
                        ,SalesMgtSegment__c
                        ,LocalAttribute1__c
                        ,LocalAttribute2__c
                        ,LocalAttribute3__c
                        ,LocalAttribute5__c
                        ,OptinNewsletter1__c
                        ,MinOrder__c
                        ,MinOrderFreeTransportFees__c
                        ,InvoicingDate__c
                        ,LastOrderDate__c
                        ,Last_Order_Total_Amount__c
                        ,toLabel(AllowedPaymentMode__c)
                        ,NoCreditLine__c
                        ,NbDaysForCreditLine__c
                        ,LoyaltyProgram1Balance__c
                        ,LoyaltyProgram3Balance__c
                        ,LoyaltyProgram2Balance__c
                        ,CreatedByName__c
                        ,CreatedDate
                        ,TECH_ExternalId__c
                        ,LastModifiedByName__c
                        ,LastModifiedDate
                        ,TECH_CONOwnerExternalId__c
                        ,LU_Tech_Sales_Segment__c
                        ,Parent_STH_Id__c
                        ,BadDebt__c
                        ,Start_date__c
                        ,MailingPostalCode
                        ,MailingCity
                        ,MailingStreet
                        ,Account.Name
                        ,FirstName
                        ,LastName
                        ,RecordTypeId
                        ,RecordType.Name
                        ,LU_TECH_ProfilePicture__c
                        ,AccountCountryCode__c
                        ,LU_Consent_Resend_Email_Date__c
                        ,LU_Counter_2_Name__c
                        ,LU_Counter_2__c
                        ,LU_Counter_1__c
                        ,LU_Counter_1_Name__c
                        ,LU_Counter_3_Name__c
                        ,LU_Counter_3__c
                        ,LU_Counters_Unit__c
                        ,LU_Counters_Unit_Bis__c
                        ,LU_LastOrderDate__c
                        ,LU_Sum_My_OrderItems_Last_Order__c
                        ,(SELECT Id, LU_Use_New_Order_v2__c FROM Contact.Users)
                    FROM Contact WHERE id = : contactId LIMIT 1];

        try{
            List<User> vListUser = [SELECT SmallPhotoUrl FROM User WHERE ContactId = :contactId];
            if(vListUser.size() > 0) {
                con.LU_TECH_ProfilePicture__c = vListUser[0].SmallPhotoUrl;
            }
            
            Map<Id, Date> vMapConIdLastOrderDate = AP1003_Utils_Contact.getContactsLastOrderDate(new List<Contact>{con});
            if(vMapConIdLastOrderDate != null){
                Date vLastOrderDate = vMapConIdLastOrderDate.get(con.Id);
                if(vLastOrderDate != null){
                    con.LastDateToOrder__c = vLastOrderDate;
                }
            }
        } catch (Exception e){
            return con;
        }

        return con;
    }

    @AuraEnabled
    public static List<lwc05_home_dashboard_Ctrl.Indicator> getContactIndicator(String contactId) {
        
        List<lwc05_home_dashboard_Ctrl.Indicator> l_indic = new List<lwc05_home_dashboard_Ctrl.Indicator>();
        if(String.isNotBlank(contactId)) {
            // Get the current contact
            Contact con = AP1003_Utils_Contact.getContactInfo(contactId);
            /* User u = [SELECT Id, TECH_MergeContactID__c, LU_Use_New_Order_v2__c FROM User WHERE AccountID = :con.AccountID LIMIT 1]; */
            User u = [SELECT Id, TECH_MergeContactID__c, LU_Use_New_Order_v2__c FROM User WHERE ContactId = :contactId LIMIT 1];
            
            // Get the current cycle of the contact
            AP1001_Cycle_Utils.CycleInfo currentCycle = AP1001_Cycle_Utils.getCountryCurrentCycle(con.AccountCountryCode__c);
            AP1001_Cycle_Utils.CycleInfo currentWeek = AP1001_Cycle_Utils.getCountryCurrentCycleWeek(con.AccountCountryCode__c);

            l_indic.add(lwc05_home_dashboard_Ctrl.getPurchaseAmountByContactBetweenTwoDates(u, con, currentCycle.startdate, currentCycle.enddate, Label.LU_Dashboard_CA_Perso_Cycle));

            if(con.AccountCountryCode__c == 'FRA'){
                lwc05_home_dashboard_Ctrl.Indicator ind = null;
                ind = new lwc05_home_dashboard_Ctrl.Indicator();
                ind.isNumber = true;
                ind.label = Label.LU_Dashboard_CA_Perso_Year;
                ind.vDecimal1 = con.LU_Cumulated_Turnover_Year__c;
                if(ind.vDecimal1 == null){
                    ind.vDecimal1 = 0;
                }
                ind.isCurrencyDecimal1 = true;

                l_indic.add(ind);
            }
        }

        return l_indic;
    }
}