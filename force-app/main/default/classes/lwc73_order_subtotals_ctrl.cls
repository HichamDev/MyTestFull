public without sharing class lwc73_order_subtotals_ctrl {
	
    @AuraEnabled
    public static String getUserCountry() {
        String country = AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
        String profileNAme = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        
        if(country == 'FRA'){
            return country;
        }
        else if(country == 'ITA' && !profileName.contains('Smile')){
            return 'ITA';
        }
        return null;
    }

    @AuraEnabled
    public static Order getOrder(String orderId, Boolean isITA) {
        //SFT-1661, Added LU_Total_Amount_Material_Work__c to below query
        //JJE 30/11/2022 - T1985 - difference if is ITA
        if(isITA){
            List<Order> orderToReturn = [SELECT Id, LU_Fiscal_Payment_Total_Amount__c, LU_Total_Amount_Material_Work__c, LU_Number_Of_Articles__c, LU_Total_Price_Without_Taxes__c, Total_Amount_Brand_Family_Expert__c, Total_Amount_Brand_Kiotis__c, 
                            LU_Total_Amount_Brand_Flormar__c, Total_Amount_Others__c, LU_Total_Amount_For_Valid_Base__c, LU_Total_Amount_Brand_Stanhome__c, 
                            TotalAmount, LU_Commission_Total_Amount__c, LU_Tax_Amount__c, LU_Admin_Fees_Total_Amount__c, LU_Transport_Fees__c,
                           Total_Amount_Total_Sell__c, Total_Amount_Total_Personal_Use__c, LU_Total_Amount_Gifts__c, LU_Total_Amount_Discount_Personal_Use__c,
                           LU_Total_Amount_With_Taxes__c, LU_Total_Amount_To_Pay__c, LU_Total_Amount_Professional_Use__c, Rebate_Discount_Personal_Use__c, Discount__c,LU_TECH_AmountForMinimumOrder__c, Status, LU_Challenge_Discount_Applied__c,
                            BO_TAXES__c, BO_COMMISSION__c, BO_TOTAL_AMOUNT_TO_PAY__c, Type, BO_TOTAL_WITHOUT_TAXES__c,
                                         BillToContactId,
                            (SELECT ID, 
                            LU_TECH_UsedForMinAmount__c, LU_Total_Price__c,
                            PricebookEntry.LU_Challenges_Ids__c,
                            PricebookEntry.LU_Challenges_Ids_Bis__c,
                            PricebookEntry.LU_Valid_For_Challenge__c,
                            PricebookEntry.LU_Offer_type__c 
                            FROM OrderItems ) // Pas de condition Valid for challenge pour l'italie
                      FROM Order
                     WHERE Id = :orderId];
            if (orderToReturn.size() == 1) return orderToReturn[0];
            else return null;
        }
        else {
            List<Order> orderToReturn = [SELECT Id, LU_Fiscal_Payment_Total_Amount__c, LU_Total_Amount_Material_Work__c, LU_Number_Of_Articles__c, LU_Total_Price_Without_Taxes__c, Total_Amount_Brand_Family_Expert__c, Total_Amount_Brand_Kiotis__c, 
                            LU_Total_Amount_Brand_Flormar__c, Total_Amount_Others__c, LU_Total_Amount_For_Valid_Base__c, LU_Total_Amount_Brand_Stanhome__c, 
                            TotalAmount, LU_Commission_Total_Amount__c, LU_Tax_Amount__c, LU_Admin_Fees_Total_Amount__c, LU_Transport_Fees__c,
                           Total_Amount_Total_Sell__c, Total_Amount_Total_Personal_Use__c, LU_Total_Amount_Gifts__c, LU_Total_Amount_Discount_Personal_Use__c,
                           LU_Total_Amount_With_Taxes__c, LU_Total_Amount_To_Pay__c, LU_Total_Amount_Professional_Use__c, Status, LU_Challenge_Discount_Applied__c,
                            BO_TAXES__c, BO_COMMISSION__c, BO_TOTAL_AMOUNT_TO_PAY__c, Type, BO_TOTAL_WITHOUT_TAXES__c,
                            (SELECT ID, 
                            LU_TECH_UsedForMinAmount__c, 
                            PricebookEntry.LU_Challenges_Ids__c,
                            PricebookEntry.LU_Challenges_Ids_Bis__c,
                            PricebookEntry.LU_Valid_For_Challenge__c 
                            FROM OrderItems 
                            WHERE OrderItem.PricebookEntry.LU_Valid_For_Challenge__c = true)
                      FROM Order
                     WHERE Id = :orderId];
            if (orderToReturn.size() == 1) return orderToReturn[0];
            else return null;
        }
    }
    @AuraEnabled
    public static Map<String, String> getChallenges() {
        User u = [SELECT TECH_MergeContactID__c, TECH_ExternalId__c FROM User WHERE Id = :UserInfo.getUserId()];
        Contact con = [SELECT LU_Challenge_1_Id__c, LU_Challenge_2_Id__c, LU_Challenge_3_Id__c, LU_Challenge_4_Id__c,
                              LU_Challenge_5_Id__c, LU_Challenge_6_Id__c, LU_Challenge_7_Id__c, LU_Challenge_8_Id__c, 
                              LU_Challenge_1_Turnover__c, LU_Challenge_2_Turnover__c, LU_Challenge_3_Turnover__c, LU_Challenge_4_Turnover__c,
                              LU_Challenge_5_Turnover__c, LU_Challenge_6_Turnover__c, LU_Challenge_7_Turnover__c, LU_Challenge_8_Turnover__c,
                              AccountCountryCode__c, LU_TECH_Contact_Segment__c, LU_Tech_Sales_Segment__c, MinOrderFreeTransportFees__c, TransportFeesApplicable__c
                         FROM Contact 
                        WHERE Id = :u.TECH_MergeContactID__c];
        
        //Récupérer les challenges inscrits sur le contact
        Map<String, Decimal> m_contactChallengesPerExtId = new Map<String, Decimal>();
        m_contactChallengesPerExtId.put(con.LU_Challenge_1_Id__c, con.LU_Challenge_1_Turnover__c == null ? 0 : con.LU_Challenge_1_Turnover__c);
        m_contactChallengesPerExtId.put(con.LU_Challenge_2_Id__c, con.LU_Challenge_2_Turnover__c == null ? 0 : con.LU_Challenge_2_Turnover__c);
        m_contactChallengesPerExtId.put(con.LU_Challenge_3_Id__c, con.LU_Challenge_3_Turnover__c == null ? 0 : con.LU_Challenge_3_Turnover__c);
        m_contactChallengesPerExtId.put(con.LU_Challenge_4_Id__c, con.LU_Challenge_4_Turnover__c == null ? 0 : con.LU_Challenge_4_Turnover__c);
        m_contactChallengesPerExtId.put(con.LU_Challenge_5_Id__c, con.LU_Challenge_5_Turnover__c == null ? 0 : con.LU_Challenge_5_Turnover__c);
        m_contactChallengesPerExtId.put(con.LU_Challenge_6_Id__c, con.LU_Challenge_6_Turnover__c == null ? 0 : con.LU_Challenge_6_Turnover__c);
        m_contactChallengesPerExtId.put(con.LU_Challenge_7_Id__c, con.LU_Challenge_7_Turnover__c == null ? 0 : con.LU_Challenge_7_Turnover__c);
        m_contactChallengesPerExtId.put(con.LU_Challenge_8_Id__c, con.LU_Challenge_8_Turnover__c == null ? 0 : con.LU_Challenge_8_Turnover__c);

        Map<String, String> challenges = new Map<String,String>();
        for(LU_Order_Rule__c ordRule : [SELECT Id, Name, LU_Criteria_Value_1__c, LU_Criteria_Value_2__c, LU_Criteria_On__c, Segmentation4__c, Segmentation4_Operator__c, LU_External_Id__c,
                        LU_Content_Img__c, LU_Content_Text__c, LU_Result_Text1__c, LU_Result_Type__c, LU_Result_Gift__c,
                        LU_End_Date__c, LU_Type__c, LU_Display_Left_To_Goal__c, LU_Name__c, LU_Segmentation_For__c
                   FROM LU_Order_Rule__c
                  WHERE RecordType.DeveloperName = 'Challenge'
                    AND LU_Active__c = true
                    AND LU_Country__c = :con.AccountCountryCode__c 
                    AND LU_Start_Date__c <=: Datetime.now()
                    AND LU_End_Date__c >=: Datetime.now()
                    AND ((LU_Type__c = 'CHALLENGE' AND LU_External_Id__c IN: m_contactChallengesPerExtId.keySet())
                       OR LU_Type__c = 'PUSH' )
                    AND ( (LU_Segmentation_For__c = :con.LU_Tech_Sales_Segment__c AND LU_Country__c = 'FRA')
                        OR (LU_Country__c = 'ITA')
                        OR LU_Segmentation_For__c = '*' )
                    ORDER BY LU_Priority__c, LU_Criteria_Value_1__c ASC
               ]){
                if(!String.isBlank(ordRule.LU_Segmentation_For__c) && ordRule.LU_Segmentation_For__c != '*' && !ordRule.LU_Segmentation_For__c.split(';').contains(con.LU_Tech_Sales_Segment__c)){
                    continue;
                }
                challenges.put(ordRule.LU_External_Id__c, ordRule.LU_Content_Text__c == null ? ordRule.LU_Name__c : ordRule.LU_Content_Text__c);
               }
        return challenges;
    }
}