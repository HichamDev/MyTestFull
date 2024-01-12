public without sharing class Lwc85_incentive_challenge_ctrl {

    public class Challenge {
        @AuraEnabled
        public Boolean isDateVisible {get;set;}
        @AuraEnabled
        public String orderId {get;set;}
        @AuraEnabled
        public String orderRuleId {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String externalId {get;set;}
        @AuraEnabled
        public Decimal criteria1 {get;set;}
        @AuraEnabled
        public Decimal criteria2 {get;set;}
        @AuraEnabled
        public Decimal segmentation4 {get;set;}
        @AuraEnabled
        public String segmentation4operator {get;set;}
        @AuraEnabled
        public String criteriaOn {get;set;}
        @AuraEnabled
        public Decimal actualScore {get;set;}
        @AuraEnabled
        public Decimal leftToGoal {get;set;}
        @AuraEnabled
        public Boolean isWon {get;set;}

        //1991
        @AuraEnabled
        public String campaign {get;set;}
       
        //1716
        @AuraEnabled
        public String techExternalIdOfferGroup {get;set;}
        @AuraEnabled
        public String contentText {get;set;}
        @AuraEnabled
        public String contentImg {get;set;}
        @AuraEnabled
        public Boolean hasContentImg {get;set;}
        @AuraEnabled
        public Boolean isWebmasterMessage {get;set;}
        @AuraEnabled
        public String resultType {get;set;}
        @AuraEnabled
        public String resultTextWon {get;set;}
        @AuraEnabled
        public String resultGift {get;set;}
        @AuraEnabled
        public Decimal giftQuantity {get;set;}
        @AuraEnabled
        public Datetime startDate {get;set;}
        @AuraEnabled
        public Datetime endDate {get;set;}
        @AuraEnabled
        public Boolean displayLeftToGoal {get;set;}
        @AuraEnabled
        public List<AP1002_LookupSearchResult> l_child {get;set;}
    }

    @AuraEnabled
    public static String getChallenges(String orderId) {
        Order orderEnCours = [SELECT BillToContactId, Type, Status
                       FROM Order
                      WHERE Id = :orderId];

        if(orderEnCours.Status != 'Draft'){
            return null;
        }

        if(orderEnCours.Type != 'LineUp') return null;

        Lwc85_incentive_challenge_ctrl.deleteChallenges(orderId);

        List<OrderItem> l_oItems = [SELECT Id, TotalPrice, LU_TECH_UsedForMinAmount__c, PricebookEntry.LU_Challenges_Ids__c, 
                                            PricebookEntry.LU_Challenges_Ids_Bis__c, PricebookEntry.LU_Dealer_Price__c, Quantity
                                      FROM OrderItem
                                     WHERE OrderItem.OrderId = :orderId 
                                       AND LU_Child_Product__c = null
                                       AND OrderItem.PricebookEntry.LU_Valid_For_Challenge__c = true
                                       AND OrderItem.PricebookEntry.LU_Challenges_Ids__c != null
                                       AND OrderItem.PricebookEntry.LU_Challenges_Ids__c != ''];

        List<OrderItem> l_oItemsNoCHallenge = [SELECT Id, TotalPrice, LU_TECH_UsedForMinAmount__c, PricebookEntry.LU_Challenges_Ids__c, 
                                                        PricebookEntry.LU_Challenges_Ids_Bis__c, PricebookEntry.LU_Dealer_Price__c, Quantity
                                      FROM OrderItem
                                     WHERE OrderItem.OrderId = :orderId 
                                       AND LU_Child_Product__c = null
                                       AND OrderItem.PricebookEntry.LU_Valid_For_Challenge__c = true];

        User user = [SELECT TECH_MergeContactID__c, TECH_ExternalId__c FROM User WHERE Id = :UserInfo.getUserId()];
        //Modification JJE 22/04/2021 - Jira 1615 - réupérer les challenges du contact en cours et non du manager
        Contact con = [SELECT LU_Tech_Success_Bearing__c, LU_Tech_Title__c, LU_Challenge_1_Id__c, LU_Challenge_2_Id__c, LU_Challenge_3_Id__c, LU_Challenge_4_Id__c,
                              LU_Challenge_5_Id__c, LU_Challenge_6_Id__c, LU_Challenge_7_Id__c, LU_Challenge_8_Id__c, LU_Tech_NbOrder__c,
                              LU_Challenge_1_Turnover__c, LU_Challenge_2_Turnover__c, LU_Challenge_3_Turnover__c, LU_Challenge_4_Turnover__c,
                              LU_Challenge_5_Turnover__c, LU_Challenge_6_Turnover__c, LU_Challenge_7_Turnover__c, LU_Challenge_8_Turnover__c,
                              AccountCountryCode__c, LU_TECH_Contact_Segment__c, LU_Tech_Sales_Segment__c, MinOrderFreeTransportFees__c, TransportFeesApplicable__c
                         FROM Contact 
                        WHERE Id = :orderEnCours.BillToContactId];
        String country = user.TECH_ExternalId__c.left(3);

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
        

        Set<String> s_challPreviouslyDone = new Set<String>();
        for(Order ord : [SELECT LU_Challenges_Applied__c FROM Order WHERE Id != :orderId AND BillToContactId = :orderEnCours.BillToContactId]){
            if(!String.IsBlank(ord.LU_Challenges_Applied__c)) s_challPreviouslyDone.addAll(ord.LU_Challenges_Applied__c.split('#'));
        }

        //Get order Rules de type challenges
        Map<String, Lwc85_incentive_challenge_ctrl.Challenge> m_challengesPerExternalId = getOrderRules(orderId, con, m_contactChallengesPerExtId, s_challPreviouslyDone);
        
        //Récupérer une map challenge/montant effectué sur toutes les commandes passées
        Map<String, Decimal> amountValidatedPerChallenge = new Map<String, Decimal>();
        for(Order ord : [SELECT Id, LU_Total_Amount_For_Valid_Base__c, EndDate,
                         (SELECT ID, LU_TECH_UsedForMinAmount__c, PricebookEntry.LU_Challenges_Ids__c, PricebookEntry.LU_Challenges_Ids_Bis__c FROM OrderItems WHERE OrderItem.PricebookEntry.LU_Valid_For_Challenge__c = true)
                          FROM Order 
                          WHERE BillToContactId = :orderEnCours.BillToContactId 
                          // JJE - 15/04/2021 On prend toutes les commandes qui sont != draft
                          AND Status =: AppConstants.ORDER_STATUS_PENDING
                        //   OR Status =: AppConstants.ORDER_STATUS_PROCESSING
                        //   OR Status =: AppConstants.ORDER_STATUS_INVOICED
                        //   OR Status =: AppConstants.ORDER_STATUS_SHIPPED
                        //   OR Status =: AppConstants.ORDER_STATUS_DELIVERED
                        //   OR Status =: AppConstants.ORDER_STATUS_PACKING
                          AND Id != :orderId]){
            // Pour chaque oderItem des commandes passées, récupérer ceux concernés par chaque challenge
            if(ord != null && ord.OrderItems != null){
                for(OrderItem oi : ord.OrderItems){
                    if(oi.PricebookEntry != null && oi.PricebookEntry.LU_Challenges_Ids__c != null){
                        List<String> l_challIds = oi.PricebookEntry.LU_Challenges_Ids__c.split('#');
                        if(oi.PricebookEntry.LU_Challenges_Ids_Bis__c != null){
                            l_challIds.addAll(oi.PricebookEntry.LU_Challenges_Ids_Bis__c.split('#'));
                        }
                        for(String challExtId : l_challIds){
                            //Vérifier que la commande est bien sur la date du chalenge
                            if(m_challengesPerExternalId.get(challExtId) != null 
                               && m_challengesPerExternalId.get(challExtId).startDate < ord.EndDate
                               && m_challengesPerExternalId.get(challExtId).endDate > ord.EndDate){
                                if(amountValidatedPerChallenge.get(challExtId) != null){
                                    Decimal amount = amountValidatedPerChallenge.get(challExtId);
                                    amount += oi.LU_TECH_UsedForMinAmount__c;
                                    amountValidatedPerChallenge.put(challExtId, amount);
                                }
                                else amountValidatedPerChallenge.put(challExtId, oi.LU_TECH_UsedForMinAmount__c);
                            } 
                        }
                    }
                }
            }
        }

        //Récupération des cadeaux & quantités associées (?)
        List<String> l_bundlesExternalId = new List<String>();
        for(Lwc85_incentive_challenge_ctrl.Challenge chal : m_challengesPerExternalId.values()){
            if(chal.resultType == 'GIFT' && !String.isBlank(chal.resultGift)){
                chal.l_child = new List<AP1002_LookupSearchResult>();
                l_bundlesExternalId.add(chal.resultGift);
            }
        }
        Map<Id, PricebookEntry> m_parentPbePerProductId = new Map<Id, PricebookEntry>();
        for(PricebookEntry pbe : [SELECT Id, LU_TECH_External_Id__c, 
                                    Product2Id, PriceBook2Id, Product2.LU_Number_Of_Articles__c, LU_Counter_Value__c 
                                    FROM PricebookEntry WHERE LU_TECH_External_Id__c IN :l_bundlesExternalId]){
            m_parentPbePerProductId.put(pbe.Product2Id, pbe);
            for(String key : m_challengesPerExternalId.keyset()){
                if(m_challengesPerExternalId.get(key).resultGift == pbe.LU_TECH_External_Id__c){
                    m_challengesPerExternalId.get(key).giftQuantity = pbe.Product2.LU_Number_Of_Articles__c == 0  || pbe.Product2.LU_Number_Of_Articles__c == null ? 1 : pbe.Product2.LU_Number_Of_Articles__c;
                    break;
                }
            }
        }
        
        Map<String, List<AP1002_LookupSearchResult>> m_childsPerParentExtId = Lwc85_incentive_challenge_ctrl.getProductListOfBundles(m_parentPbePerProductId);
        for(String extId : m_challengesPerExternalId.keyset()){
            if(m_challengesPerExternalId.get(extId).l_child != null){
                m_challengesPerExternalId.get(extId).l_child = m_childsPerParentExtId.get(m_challengesPerExternalId.get(extId).resultGift);
            }
        }

        // Pour les order items de la commande en cours, compléter la map challenge/montant associé --> VALABLE QUE POUR TURNOVER CUMULATED
        for(OrderItem oi : l_oItems){
            List<String> l_challIds = oi.PricebookEntry.LU_Challenges_Ids__c.split('#');
            if(oi.PricebookEntry.LU_Challenges_Ids_Bis__c != null){
                l_challIds.addAll(oi.PricebookEntry.LU_Challenges_Ids_Bis__c.split('#'));
            }
            for(String challExtId : l_challIds){
                if(m_challengesPerExternalId.containsKey(challExtId) && m_challengesPerExternalId.get(challExtId).criteriaOn == 'TURNOVER_CURRENT_ORDER_AND_CUMULATED'){
                    if(country == 'FRA') {
                        m_challengesPerExternalId.get(challExtId).actualScore += oi.LU_TECH_UsedForMinAmount__c;
                    }
                    else  m_challengesPerExternalId.get(challExtId).actualScore += oi.PricebookEntry.LU_Dealer_Price__c * oi.Quantity;
                }
            }
        }

        // On réutilise les OI de la commande en cours --> Calcul qui sert aux TURNOVER CURRENT ORDER
        for(OrderItem oi : l_oItemsNoCHallenge){
            for(String challExtId : m_challengesPerExternalId.keySet()){ // La différence est qu'on prend pas que les challenges indiqués sur les produits, on prend tous les challenges
                if(m_challengesPerExternalId.containsKey(challExtId) && m_challengesPerExternalId.get(challExtId).criteriaOn == 'TURNOVER_CURRENT_ORDER'){
                    if(country == 'FRA') {
                        m_challengesPerExternalId.get(challExtId).actualScore += oi.LU_TECH_UsedForMinAmount__c;
                    }
                    else  m_challengesPerExternalId.get(challExtId).actualScore += oi.PricebookEntry.LU_Dealer_Price__c * oi.Quantity;
                }
            }
        }

        // Construction des scores avec ajout des turnovers contact
        for(String challExtId : m_challengesPerExternalId.keySet()){
            if(m_challengesPerExternalId.get(challExtId) != null){
                //Ajout du turnover contact
                if(m_contactChallengesPerExtId.containsKey(challExtId)){
                    m_challengesPerExternalId.get(challExtId).actualScore += m_contactChallengesPerExtId.get(challExtId);
                }
                // Critère CUMULATED : ajout de toutes les commandes passées
                if(m_challengesPerExternalId.get(challExtId).criteriaOn == 'TURNOVER_CURRENT_ORDER_AND_CUMULATED'
                   && amountValidatedPerChallenge.get(challExtId) != null){ 
                        m_challengesPerExternalId.get(challExtId).actualScore += amountValidatedPerChallenge.get(challExtId);
                }
            }
        }

        //Construction des left to Goal - vérification si challenge gagné ou pas
        for(String challExtId : m_challengesPerExternalId.keyset()){
            m_challengesPerExternalId.get(challExtId).leftToGoal = m_challengesPerExternalId.get(challExtId).criteria1 - m_challengesPerExternalId.get(challExtId).actualScore;

            // TYPE FREE SHIPPING FEE --> NE dépend PLUS du contact (seulement order rule)
            if(m_challengesPerExternalId.get(challExtId).resultType == 'FREE_SHIPPING_FEE'){
                if(m_challengesPerExternalId.get(challExtId).criteria2 == null){
                    if(!con.TransportFeesApplicable__c || m_challengesPerExternalId.get(challExtId).actualScore >= m_challengesPerExternalId.get(challExtId).criteria1){
                        m_challengesPerExternalId.get(challExtId).isWon = true;
                    }
                }
                else{
                    if(!con.TransportFeesApplicable__c || (m_challengesPerExternalId.get(challExtId).actualScore >= m_challengesPerExternalId.get(challExtId).criteria1 && m_challengesPerExternalId.get(challExtId).actualScore <= m_challengesPerExternalId.get(challExtId).criteria2)){
                        m_challengesPerExternalId.get(challExtId).isWon = true;
                    }
                    else if(m_challengesPerExternalId.get(challExtId).actualScore > m_challengesPerExternalId.get(challExtId).criteria2){
                        m_challengesPerExternalId.remove(challExtId);
                    }
                }
            }

            //Vérification si maximum à atteindre -> si max dépassé, on retire le challenge
            else if(m_challengesPerExternalId.get(challExtId).criteria2 != null){
                if(m_challengesPerExternalId.get(challExtId).actualScore >= m_challengesPerExternalId.get(challExtId).criteria1 && m_challengesPerExternalId.get(challExtId).actualScore <= m_challengesPerExternalId.get(challExtId).criteria2){
                    m_challengesPerExternalId.get(challExtId).isWon = true;
                }
                else if(m_challengesPerExternalId.get(challExtId).actualScore > m_challengesPerExternalId.get(challExtId).criteria2){
                    m_challengesPerExternalId.remove(challExtId);
                }
            }

            //Si pas de maximum, challenge won si criteria 1 dépassé
            else if(m_challengesPerExternalId.get(challExtId).actualScore >= m_challengesPerExternalId.get(challExtId).criteria1){
                m_challengesPerExternalId.get(challExtId).isWon = true;
            }

            if(country == 'ITA' && m_challengesPerExternalId.containsKey(challExtId)) {
                if(m_challengesPerExternalId.get(challExtId).segmentation4 != null && m_challengesPerExternalId.get(challExtId).segmentation4operator != null){
                    switch on m_challengesPerExternalId.get(challExtId).segmentation4operator {
                        when '=' {
                            if(con.LU_Tech_NbOrder__c != m_challengesPerExternalId.get(challExtId).segmentation4){
                                m_challengesPerExternalId.remove(challExtId);
                            }
                        }
                        when '!='{
                            if(con.LU_Tech_NbOrder__c == m_challengesPerExternalId.get(challExtId).segmentation4){
                                m_challengesPerExternalId.remove(challExtId);
                            }
                        }
                        when '>'{
                            if(con.LU_Tech_NbOrder__c > m_challengesPerExternalId.get(challExtId).segmentation4){
                                m_challengesPerExternalId.remove(challExtId);
                            }
                        }
                        when '>='{
                            if(con.LU_Tech_NbOrder__c >= m_challengesPerExternalId.get(challExtId).segmentation4){
                                m_challengesPerExternalId.remove(challExtId);
                            }
                        }
                        when '<'{
                            if(con.LU_Tech_NbOrder__c < m_challengesPerExternalId.get(challExtId).segmentation4){
                                m_challengesPerExternalId.remove(challExtId);
                            }
                        }
                        when '<='{
                            if(con.LU_Tech_NbOrder__c <= m_challengesPerExternalId.get(challExtId).segmentation4){
                                m_challengesPerExternalId.remove(challExtId);
                            }
                        }
                    }
                }
            }

            //Arrondir le goal à 2 décimales
            if(m_challengesPerExternalId.containsKey(challExtId) && m_challengesPerExternalId.get(challExtId).leftToGoal != null){
                m_challengesPerExternalId.get(challExtId).leftToGoal = m_challengesPerExternalId.get(challExtId).leftToGoal.setScale(2);
            }

            //Pour tous les challenges qui ont le displayLeftToGoal
            if(m_challengesPerExternalId.containsKey(challExtId) && m_challengesPerExternalId.get(challExtId).displayLeftToGoal ){
                //removed && m_challengesPerExternalId.get(challExtId).resultType == 'FREE_SHIPPING_FEE' as part of SFT-1687
                if(!m_challengesPerExternalId.get(challExtId).isDateVisible ){
                    m_challengesPerExternalId.get(challExtId).contentText = '<span style="color: black;">' + Label.LU_Challenge_Left_To_Win.replace('$LEFT', '<b style="font-size: 18px;">' + m_challengesPerExternalId.get(challExtId).leftToGoal.toPlainString()) + '</b>' + '</span>' + '<br/>'
                                                                        + m_challengesPerExternalId.get(challExtId).contentText;
                }
                else if(m_challengesPerExternalId.get(challExtId).isDateVisible ){
					
					/*Start SFT-1687 */
					String optionalText = '';
					if(m_challengesPerExternalId.get(challExtId).endDate != null && m_challengesPerExternalId.get(challExtId).startDate != null) {
						optionalText = Label.LU_Challenge_Before_Start_And_End_Date.replace('$STARTDATE ', (m_challengesPerExternalId.get(challExtId).startDate.day() + '/' + m_challengesPerExternalId.get(challExtId).startDate.month() + '/' + m_challengesPerExternalId.get(challExtId).startDate.year())).replace('$ENDDATE', (m_challengesPerExternalId.get(challExtId).endDate.day() + '/' + m_challengesPerExternalId.get(challExtId).endDate.month() + '/' + m_challengesPerExternalId.get(challExtId).endDate.year()));
					} else if(m_challengesPerExternalId.get(challExtId).startDate == null && m_challengesPerExternalId.get(challExtId).endDate != null){
						optionalText = Label.LU_Challenge_Before_Date.replace('$ENDDATE', (m_challengesPerExternalId.get(challExtId).endDate.day() + '/' + m_challengesPerExternalId.get(challExtId).endDate.month() + '/' + m_challengesPerExternalId.get(challExtId).endDate.year()));
					} 
					/*END SFT-1687 */
					
					//SFT-1687, replaced enddateText with optionalText
                    m_challengesPerExternalId.get(challExtId).contentText = '<span style="color: black;">' + Label.LU_Challenge_Left_To_Win.replace('$LEFT', '<b style="font-size: 18px;">' + m_challengesPerExternalId.get(challExtId).leftToGoal.toPlainString()) + '</b>' + '</span>' + '<br/>'
                                                                        + '<span style="color: rgb(194, 57, 52);font-weight: bold;">' + optionalText + '</span>' + '<br/>'
                                                                        + m_challengesPerExternalId.get(challExtId).contentText;
                }
            }
        }

        // SFT-1991
        if(country == 'ITA') {
            for(Lwc85_incentive_challenge_ctrl.Challenge chall : m_challengesPerExternalId.values()){
                if(!chall.isWon){
                    for(Lwc85_incentive_challenge_ctrl.Challenge chall_2 : m_challengesPerExternalId.values()){
                        if(chall.orderRuleId != chall_2.orderRuleId && chall.campaign == chall_2.campaign && !chall_2.isWon){
                            if(chall.criteria1 < chall_2.criteria1){
                                m_challengesPerExternalId.remove(chall_2.externalId);
                            }
                        }
                    }
                }
            }
        }

        List<Lwc85_incentive_challenge_ctrl.Challenge> l_orderedChallenge = new List<Lwc85_incentive_challenge_ctrl.Challenge>();
        for(Lwc85_incentive_challenge_ctrl.Challenge chall : m_challengesPerExternalId.values()){
            if(chall.resultType == 'FREE_SHIPPING_FEE'){
                if(l_orderedChallenge.isEmpty()) l_orderedChallenge.add(chall);
                else l_orderedChallenge.add(0, chall);
            }
            else l_orderedChallenge.add(chall);
        }

        return JSON.serialize(l_orderedChallenge);
    }

    public static void deleteChallenges(String orderId){

        Order ord = [SELECT LU_Challenges_Applied__c, LU_Challenge_Free_Shipping_Fee_Applied__c, LU_Challenge_Discount_Applied__c
                       FROM Order
                      WHERE Id = :orderId];

        ord.LU_Challenges_Applied__c = '';
        ord.LU_Challenge_Free_Shipping_Fee_Applied__c = false;
        ord.LU_Challenge_Discount_Applied__c = 0;
        update ord;

        List<OrderItem> l_oItemsToDelete = [SELECT Id
                                              FROM OrderItem
                                             WHERE OrderId = :orderId
                                               AND LU_Challenge_Linked__c != ''];

        delete l_oItemsToDelete;
    }

    public static Map<String, Lwc85_incentive_challenge_ctrl.Challenge> getOrderRules(Id orderId, Contact con, Map<String, Decimal> m_contactChallengesPerExtId, Set<String> s_challPreviouslyDone){
        //1716, Added TECH_EXTERNAL_ID_OFFERS_GROUPS__c field
        List<LU_Order_Rule__c> l_oRules = [SELECT Id, Segmentation2__c, Segmentation3__c, TECH_EXTERNAL_ID_OFFERS_GROUPS__c, LU_Criteria_Value_1__c, LU_Criteria_Value_2__c, Segmentation4__c, Segmentation4_Operator__c, LU_Criteria_On__c, LU_External_Id__c,
                                                  LU_Content_Img__c, LU_Content_Text__c, LU_Result_Text1__c, LU_Result_Type__c, LU_Result_Gift__c,
                                                  LU_End_Date__c, LU_Type__c, LU_Display_Left_To_Goal__c, LU_Country__c,
                                                  LU_Start_Date__c, LU_DatesVisible__c, LU_Campaign_ID__c, LU_Segmentation_For__c
                                             FROM LU_Order_Rule__c
                                            WHERE RecordType.DeveloperName = 'Challenge' 
                                              AND LU_Active__c = true
                                              AND LU_External_Id__c NOT IN :s_challPreviouslyDone
                                              AND LU_Country__c = :con.AccountCountryCode__c 
                                              AND LU_Start_Date__c <=: Datetime.now()
                                              AND LU_End_Date__c >=: Datetime.now()
                                              AND ((LU_Type__c = 'CHALLENGE' AND LU_External_Id__c IN: m_contactChallengesPerExtId.keySet())
                                                    OR LU_Type__c = 'PUSH' )
                                              AND ((LU_Segmentation_For__c = :con.LU_Tech_Sales_Segment__c AND LU_Country__c = 'FRA')
                                                OR(LU_Country__c = 'ITA')
                                                OR LU_Segmentation_For__c = '*' ) 
                                              AND ( (Segmentation2__c = :con.LU_Tech_Success_Bearing__c AND LU_Country__c = 'FRA')
                                                OR(LU_Country__c = 'ITA')
                                                OR Segmentation2__c = '*' ) 
                                              AND ( (Segmentation3__c = :con.LU_Tech_Title__c AND LU_Country__c = 'FRA')
                                                OR(LU_Country__c = 'ITA')
                                                OR Segmentation3__c = '*' )                                              
                                         ORDER BY LU_Priority__c, LU_Criteria_Value_1__c ASC];

        Map<String, Lwc85_incentive_challenge_ctrl.Challenge> m_challengesPerExternalId = new Map<String, Lwc85_incentive_challenge_ctrl.Challenge>();

        for(LU_Order_Rule__c oRule : l_oRules){
            
            // SFT 1986
            if(oRule.LU_Country__c == 'ITA'){
                // Controls Italian LU_Segmentation_For__c
                if(!String.isBlank(oRule.LU_Segmentation_For__c) && oRule.LU_Segmentation_For__c != '*' && !oRule.LU_Segmentation_For__c.split(';').contains(con.LU_Tech_Sales_Segment__c)){
                    continue;
                }
                // Controls Italian Segmentation2__c
                if(!String.isBlank(oRule.Segmentation2__c) && oRule.Segmentation2__c != '*' && !oRule.Segmentation2__c.split(';').contains(con.LU_Tech_Success_Bearing__c)){
                    continue;
                }
                // Controls Italian Segmentation3__c
                if(!String.isBlank(oRule.Segmentation3__c) && oRule.Segmentation3__c != '*' && !oRule.Segmentation3__c.split(';').contains(con.LU_Tech_Title__c)){
                    continue;
                }
            }

            Lwc85_incentive_challenge_ctrl.Challenge chall = new Lwc85_incentive_challenge_ctrl.Challenge();
            chall.orderId = orderId;
            chall.orderRuleId = oRule.Id;
            chall.isDateVisible = oRule.LU_DatesVisible__c;
            chall.externalId = oRule.LU_External_Id__c;
            chall.criteria1 = oRule.LU_Criteria_Value_1__c;
            chall.criteria2 = oRule.LU_Criteria_Value_2__c;
            chall.segmentation4 = oRule.Segmentation4__c;
            chall.segmentation4operator = oRule.Segmentation4_Operator__c;
            chall.criteriaOn = oRule.LU_Criteria_On__c;
            chall.isWon = false;
            chall.techExternalIdOfferGroup = oRule.TECH_EXTERNAL_ID_OFFERS_GROUPS__c; //1716
            chall.actualScore = 0;
            chall.contentText = oRule.LU_Content_Text__c == null ? '' : oRule.LU_Content_Text__c;
            chall.contentImg = oRule.LU_Content_Img__c;
            chall.hasContentImg = oRule.LU_Content_Img__c != null ? true : false;
            chall.resultType = oRule.LU_Result_Type__c;
            chall.resultTextWon = oRule.LU_Result_Text1__c;
            chall.resultGift = oRule.LU_Result_Gift__c;
            chall.type = oRule.LU_Type__c;
            chall.startDate = oRule.LU_Start_Date__c;
            chall.endDate = oRule.LU_End_Date__c;
            chall.displayLeftToGoal = oRule.LU_Display_Left_To_Goal__c;
            chall.isWebmasterMessage = oRule.LU_Result_Type__c == 'WEBMASTER' ? true : false;

            chall.campaign = oRule.LU_Campaign_ID__c;

            m_challengesPerExternalId.put(chall.externalId, chall);
        }

        return m_challengesPerExternalId;

    }

    public static Map<String, List<AP1002_LookupSearchResult>> getProductListOfBundles(Map<Id, PriceBookEntry> m_parentPbePerProductId){
        
        Map<String, List<AP1002_LookupSearchResult>> m_childsPerParentExtId = new Map<String, List<AP1002_LookupSearchResult>>();
        Map<String, String> m_extIdPerProductId = new Map<String, String>();
        Map<String, String> m_PricebookPerProductId = new Map<String, String>();

        for(PricebookEntry pbe : m_parentPbePerProductId.values()){
            m_extIdPerProductId.put(pbe.Product2Id, pbe.LU_TECH_External_Id__c);
            m_PricebookPerProductId.put(pbe.Product2Id, pbe.Id);
        }

        Datetime vNow = Datetime.now();
        

        for(Product2 parentProduct : [SELECT Id, Name, LU_Local_Code__c, LU_Min_Qty_Orderable__c, LU_Max_Qty_Orderable__c, LU_Type_Child__c, 
                                     LU_TECH_External_Id__c, LU_Number_Of_Articles__c, LU_IMAGE1_URL__c,
                                     (SELECT Id, Name, LU_Local_Code__c, LU_Min_Qty_Orderable__c, LU_Max_Qty_Orderable__c, LU_Type_Child__c, 
                                     LU_TECH_External_Id__c, LU_Number_Of_Articles__c, LU_IMAGE1_URL__c, 
                                     LU_Parent_Product__c, LU_Parent_Product__r.LU_Number_Of_Articles__c
                                       FROM Products__r WHERE IsActive = true
                                       AND ( (LU_Child_Start_date__c <= :vNow AND LU_Child_End_date__c >= :vNow )
                                         OR (LU_Child_Start_date__c = null AND LU_Child_End_date__c = null))
                                      ) 
                                FROM Product2
                                WHERE Id IN :m_extIdPerProductId.keySet()]){
            // T-1431 JJE 18/06/2021
            //Identifier les résults gifts qui sont des openSet et ceux qui sont des produits simples
            if(parentProduct.Products__r.size() == 0){ // Cas d'un produit simple
                AP1002_LookupSearchResult res = new AP1002_LookupSearchResult(parentProduct.Id, 
                'PriceBookEntry', 'standard:PriceBookEntry',
                parentProduct.LU_Local_Code__c + ' - ' + parentProduct.Name, '');

                res.productId = parentProduct.Id;
                res.quantity = (parentProduct.LU_Min_Qty_Orderable__c == parentProduct.LU_Max_Qty_Orderable__c ? (integer)parentProduct.LU_Min_Qty_Orderable__c : 1);
                res.priceHT = 0;
                res.unitPrice = 0;
                res.priceTTC = 0;
                res.isInBundle = true;
                res.idBundle = null;
                res.displayInPreBasketList = false;
                // res.maxQuantity = parentProduct.LU_Max_Qty_Orderable__c;
                // res.minQuantity = parentProduct.LU_Min_Qty_Orderable__c;
                res.isReadOnly = false;
                res.isSelectable = true;
                res.numberOfArticle = 1;
                res.priceBook = m_PricebookPerProductId.get(parentProduct.Id);
                res.articleOfTheLine = parentProduct.LU_TECH_External_Id__c;
                res.imageUrl = parentProduct.LU_IMAGE1_URL__c;

                res.counterValuePricebookEntry = m_parentPbePerProductId.get(parentProduct.Id).LU_Counter_Value__c;
    
                if(!m_childsPerParentExtId.containsKey(m_extIdPerProductId.get(parentProduct.Id))){
                    m_childsPerParentExtId.put(m_extIdPerProductId.get(parentProduct.Id), new List<AP1002_LookupSearchResult>());
                }
                m_childsPerParentExtId.get(m_extIdPerProductId.get(parentProduct.Id)).add(res);
            }

            else { //cas d'un open set
                for(Product2 child : parentProduct.Products__r){
                    AP1002_LookupSearchResult res = new AP1002_LookupSearchResult(child.Id, 
                    'PriceBookEntry', 'standard:PriceBookEntry',
                    child.LU_Local_Code__c + ' - ' + child.Name, '');

                    res.productId = child.Id;
                    res.quantity = (child.LU_Min_Qty_Orderable__c == child.LU_Max_Qty_Orderable__c ? (integer)child.LU_Min_Qty_Orderable__c : 0);
                    res.priceHT = 0;
                    res.unitPrice = 0;
                    res.priceTTC = 0;
                    res.isInBundle = true;
                    res.idBundle = m_parentPbePerProductId.get(child.LU_Parent_Product__c).Id;
                    res.displayInPreBasketList = false;
                    res.maxQuantity = child.LU_Max_Qty_Orderable__c;
                    res.minQuantity = child.LU_Min_Qty_Orderable__c;
                    res.isReadOnly = false;
                    if(child.LU_Min_Qty_Orderable__c == child.LU_Max_Qty_Orderable__c || child.LU_Type_Child__c == 'NoSelect'){
                        res.isReadOnly = true;
                    }
                    res.isSelectable = child.LU_Type_Child__c == 'NoSelect' ? false : true;
                    res.numberOfArticle = child.LU_Parent_Product__r.LU_Number_Of_Articles__c;
                    res.priceBook = m_PricebookPerProductId.get(child.LU_Parent_Product__c);

                    res.articleOfTheLine = child.LU_TECH_External_Id__c;

                    res.imageUrl = child.LU_IMAGE1_URL__c;

                    if(!m_childsPerParentExtId.containsKey(m_extIdPerProductId.get(child.LU_Parent_Product__c))){
                        m_childsPerParentExtId.put(m_extIdPerProductId.get(child.LU_Parent_Product__c), new List<AP1002_LookupSearchResult>());
                    }
                    m_childsPerParentExtId.get(m_extIdPerProductId.get(child.LU_Parent_Product__c)).add(res);
                }
            }
        }

        //DEPRECATED SI Ticket 1431 ok
        // for(Product2 child : [SELECT Id, Name, LU_Local_Code__c, LU_Min_Qty_Orderable__c, LU_Max_Qty_Orderable__c, LU_Type_Child__c, 
        //                              LU_TECH_External_Id__c, LU_Parent_Product__c, LU_Parent_Product__r.LU_Number_Of_Articles__c, LU_IMAGE1_URL__c 
        //                         FROM Product2
        //                        WHERE (LU_Parent_Product__c IN :m_extIdPerProductId.keySet()
        //                                 OR Id IN :m_extIdPerProductId.keySet())
        //                          AND IsActive = true 
        //                          AND 
        //                          (
        //                             (LU_Child_Start_date__c <= :vNow AND LU_Child_End_date__c >= :vNow )
        //                              OR
        //                             (LU_Child_Start_date__c = null AND LU_Child_End_date__c = null)
        //                          )]){
            
        //     // T-1431 JJE 18/06/2021
        //     //Identifier les résults gifts qui sont des openSet et ceux qui sont des produits simples
        //     AP1002_LookupSearchResult res = new AP1002_LookupSearchResult(child.Id, 
        //         'PriceBookEntry', 'standard:PriceBookEntry',
        //         child.LU_Local_Code__c + ' - ' + child.Name, '');

        //     res.productId = child.Id;
        //     res.quantity = (child.LU_Min_Qty_Orderable__c == child.LU_Max_Qty_Orderable__c ? (integer)child.LU_Min_Qty_Orderable__c : 0);
        //     res.priceHT = 0;
        //     res.unitPrice = 0;
        //     res.priceTTC = 0;
        //     res.isInBundle = true;
        //     res.idBundle = m_parentPbePerProductId.get(child.LU_Parent_Product__c).Id;
        //     res.displayInPreBasketList = false;
        //     res.maxQuantity = child.LU_Max_Qty_Orderable__c;
        //     res.minQuantity = child.LU_Min_Qty_Orderable__c;
        //     res.isReadOnly = false;
        //     if(child.LU_Min_Qty_Orderable__c == child.LU_Max_Qty_Orderable__c || child.LU_Type_Child__c == 'NoSelect'){
        //         res.isReadOnly = true;
        //     }
        //     res.isSelectable = child.LU_Type_Child__c == 'NoSelect' ? false : true;
        //     res.numberOfArticle = child.LU_Parent_Product__r.LU_Number_Of_Articles__c;
        //     res.priceBook = m_PricebookPerProductId.get(child.LU_Parent_Product__c);

        //     res.articleOfTheLine = child.LU_TECH_External_Id__c;

        //     res.imageUrl = child.LU_IMAGE1_URL__c;

        //     if(!m_childsPerParentExtId.containsKey(m_extIdPerProductId.get(child.LU_Parent_Product__c))){
        //         m_childsPerParentExtId.put(m_extIdPerProductId.get(child.LU_Parent_Product__c), new List<AP1002_LookupSearchResult>());
        //     }
        //     m_childsPerParentExtId.get(m_extIdPerProductId.get(child.LU_Parent_Product__c)).add(res);
        // }


        return m_childsPerParentExtId;
    }

    @AuraEnabled
    public static void applyChallenges(List<Lwc85_incentive_challenge_ctrl.Challenge> l_challenges) {

        if(l_challenges.isEmpty()) return;

        Set<OrderItem> l_gift = new Set<OrderItem>();

        User u = [SELECT Id, TECH_MergeContactID__c FROM User WHERE Id = :UserInfo.getUserId()];

        Set<Id> s_idPbe = new Set<Id>();
        for(Challenge chall : l_challenges){
            if(chall.isWon){
                if(chall.resultType == 'GIFT'){
                    for(AP1002_LookupSearchResult lsr : chall.l_child){
                        s_idPbe.add(lsr.id);
                    }
                }
            }
        }

        Order ord = [SELECT Id, LU_Challenge_Free_Shipping_Fee_Applied__c, LU_Challenge_Discount_Applied__c, LU_Challenges_Applied__c FROM Order WHERE Id = :l_challenges.get(0).orderId];
        Boolean updateOrder = false;

        Set<String> s_parentPbeId = new Set<String>();

        for(Challenge chall : l_challenges){
            if(chall.isWon){
                if(chall.resultType == 'GIFT'){

                    Boolean hasItemsBeenSelected = false;

                    // child order item
                    for(AP1002_LookupSearchResult lsr : chall.l_child){

                        if(lsr.quantity > 0){
                            OrderItem item = new OrderItem(
                                OrderId = chall.orderId, 
                                PricebookEntryId = lsr.idBundle == null ? lsr.priceBook : lsr.idBundle,
                                Product2Id = lsr.productId, 
                                Quantity = lsr.quantity,
                                UnitPrice = lsr.unitPrice,
                                LU_Valid_For_Total_Amount_Base__c = lsr.validForTotalMountBase == true,
                                LU_Tax_Rate__c = lsr.taxRate,
                                LU_Contact_For__c = u.TECH_MergeContactID__c, //(contactLine != null ? contactLine.Id : null),
                                LU_Brand_Territory__c = lsr.brandTerritory,
                                LU_Brand__c = lsr.brand,
                                LU_Public_Price__c = lsr.priceTTC,
                                LU_Discount_Type__c = lsr.discountType,
                                LU_Dealer_Price__c = lsr.dealerPrice,
                                LU_Challenge_Linked__c = chall.externalId,
                                LU_Child_Product__c = lsr.id,
                                LU_Is_A_Sell__c = false,
                                LU_Is_A_Child_Line__c = true
                            );

                            s_parentPbeId.add(chall.resultGift);

                            hasItemsBeenSelected = true;

                            l_gift.add(item);
                        }
                    }

                    if(hasItemsBeenSelected){
                        ord.LU_Challenges_Applied__c = String.isBlank(ord.LU_Challenges_Applied__c) ? chall.externalId : ord.LU_Challenges_Applied__c + '#' + chall.externalId;
                    }
                }
                else if(chall.resultType == 'FREE_SHIPPING_FEE'){
                    ord.LU_Challenge_Free_Shipping_Fee_Applied__c = true;
                    ord.LU_Challenges_Applied__c = String.isBlank(ord.LU_Challenges_Applied__c) ? chall.externalId : ord.LU_Challenges_Applied__c + '#' + chall.externalId;
                }
                else if(chall.resultType == 'DISCOUNT_ON_ORDER'){
                    ord.LU_Challenge_Discount_Applied__c += Decimal.valueOf(chall.resultGift.replaceAll(',', '.'));
                    ord.LU_Challenges_Applied__c = String.isBlank(ord.LU_Challenges_Applied__c) ? chall.externalId : ord.LU_Challenges_Applied__c + '#' + chall.externalId;
                }
            }
        }



        Map<String, PriceBookEntry> m_parentPbePerExternalId = new Map<String, PriceBookEntry>();
        for(PriceBookEntry pbe : [SELECT Id, LU_TECH_External_Id__c, Product2Id, UnitPrice, LU_TaxRate__c, Product2.LU_Type__c, LU_Public_Price__c,
                                         LU_Dealer_Price__c, LU_Offer_type__c, LU_Counter_Value__c, Product2.LU_Local_Code__c, Product2.LU_Local_Name__c
                                    FROM PriceBookEntry WHERE LU_TECH_External_Id__c IN :s_parentPbeId]){
            m_parentPbePerExternalId.put(pbe.LU_TECH_External_Id__c, pbe);
        }

        for(Challenge chall : l_challenges){
            if(chall.resultType == 'GIFT' && m_parentPbePerExternalId.containsKey(chall.resultGift)){
                // parent order item
                OrderItem item = new OrderItem(
                    OrderId = chall.orderId, 
                    PricebookEntryId = m_parentPbePerExternalId.get(chall.resultGift).Id,
                    Product2Id = m_parentPbePerExternalId.get(chall.resultGift).Product2Id,
                    Quantity = 1,
                    UnitPrice = m_parentPbePerExternalId.get(chall.resultGift).UnitPrice,
                    LU_Valid_For_Total_Amount_Base__c = false,
                    LU_Tax_Rate__c = m_parentPbePerExternalId.get(chall.resultGift).LU_TaxRate__c,
                    LU_Contact_For__c = u.TECH_MergeContactID__c, //(contactLine != null ? contactLine.Id : null),
                    LU_Public_Price__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Public_Price__c,
                    LU_Dealer_Price__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Dealer_Price__c,
                    LU_Challenge_Linked__c = chall.externalId,
                    LU_Offer_Type__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Offer_type__c,
                    LU_Product_Type__c = m_parentPbePerExternalId.get(chall.resultGift).Product2.LU_Type__c,
                    LU_Is_A_Sell__c = false,
                    LU_Counter_1_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[0] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[0]),
                    LU_Counter_2_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[1] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[1]),
                    LU_Counter_3_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[2] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[2]),
                    LU_Counter_4_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[3] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[3]),
                    LU_Counter_5_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[4] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[4]),
                    LU_Counter_6_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[5] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[5]),
                    LU_Counter_7_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[6] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[6]),
                    LU_Counter_8_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[7] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[7]),
                    LU_Counter_9_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[8] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[8]),
                    LU_Counter_10_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[9] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[9]),
                    LU_Counter_11_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[10] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[10]),
                    LU_Counter_12_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[11] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[11]),
                    LU_Counter_13_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[12] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[12]),
                    LU_Counter_14_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[13] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[13]),
                    LU_Counter_15_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[14] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[14]),
                    LU_Counter_16_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[15] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[15]),
                    LU_Counter_17_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[16] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[16]),
                    LU_Counter_18_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[17] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[17]),
                    LU_Counter_19_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[18] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[18]),
                    LU_Counter_20_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[19] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[19]),
                    LU_Counter_21_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[20] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[20]),
                    LU_Counter_22_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[21] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[21]),
                    LU_Counter_23_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[22] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[22]),
                    LU_Counter_24_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[23] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[23]),
                    LU_Counter_25_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[24] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[24]),
                    LU_Counter_26_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[25] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[25]),
                    LU_Counter_27_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[26] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[26]),
                    LU_Counter_28_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[27] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[27]),
                    LU_Counter_29_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[28] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[28]),
                    LU_Counter_30_new__c = m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[29] == '' ? 0 : Decimal.valueOf(m_parentPbePerExternalId.get(chall.resultGift).LU_Counter_Value__c.split('#')[29])
                );
                System.debug('Id du pricebook : ' + item.PricebookEntryId);
                Boolean isInList = false;
                for(OrderItem oi : l_gift){
                    if(oi.LU_Challenge_Linked__c == item.LU_Challenge_Linked__c) {
                        isInList = true;
                        break;
                    }
                }
                if(isInList == true) l_gift.add(item);
            }
        }

        if(!l_gift.isEmpty() && !Test.isRunningTest()){
            System.debug(l_gift);
            insert new List<OrderItem>(l_gift);
            
            if(m_parentPbePerExternalId.values().get(0).LU_TECH_External_Id__c.left(3) == 'ITA'){
                List<LU_Stock_Used__c> l_stockUsedChallenges = new List<LU_Stock_Used__c>();
                for(OrderItem oi : l_gift){
                    LU_Stock_Used__c stUsed = new LU_Stock_Used__c(
                        LU_Order__c = oi.orderId, 
                        LU_Order_Line__c = oi.Id,
                        LU_Product__c = oi.Product2Id,
                        LU_Quantity_Ordered__c = oi.Quantity
                    );
                    for(PricebookEntry pbe : m_parentPbePerExternalId.values()){
                        if(pbe.Id == oi.PricebookEntryId){
                            stUsed.LU_Product_Local_Code__c = pbe.Product2.LU_Local_Code__c;
                            stUsed.LU_Product_Local_Name__c = pbe.Product2.LU_Local_Name__c;
                        }
                    }
                    l_stockUsedChallenges.add(stUsed);
                }
                if(!l_stockUsedChallenges.isEmpty()){
                    insert l_stockUsedChallenges;
                }
            }
        }

        if(ord.LU_Challenges_Applied__c != ''){
            ord.LU_Local_Attribute_9__c = ord.LU_Challenges_Applied__c;
        }
        update ord;
    }

    @AuraEnabled
    public static String getUserCountry(){
        return AP1002_Utils_User.getUserCountry(UserInfo.getUserId());
    }

    @AuraEnabled
    public static String getIsChallengeActivated(){
        return Label.LU_Incentive_And_Challenge_Activated;
    }
}