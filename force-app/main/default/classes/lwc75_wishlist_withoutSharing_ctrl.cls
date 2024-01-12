public without sharing class lwc75_wishlist_withoutSharing_ctrl {
    
    @AuraEnabled
    public static List<Contact> getDealer(String searchedTerm) {
        searchedTerm = '%' + searchedTerm + '%';
        
        System.Debug(searchedTerm);
        
        return [SELECT Id, Name, MailingPostalCode, MailingCity 
                FROM Contact 
                WHERE ( Name LIKE :searchedTerm
                OR STHID__c LIKE :searchedTerm
                OR Email LIKE :searchedTerm
                OR MobilePhone LIKE :searchedTerm )
                AND Ecommerce_Role__c in ('e-dealer', 'e-shop owner') 
                ORDER BY Name
                LIMIT 20];
    }
    
    @AuraEnabled
    public static List<Contact> createOrder(lwc75_wishlist_ctrl.Wishlist wList) {
        
        Contact con;
        Order ord;
        List<String> l_idPbe = new List<String>();
        List<OrderItem> l_orderItem = new List<OrderItem>();
        
        // Find contact, if not found create it
        String searchedEmail = '%' + wList.contactEmail + '%';
        String searchedMobile = '%' + wList.contactMobile + '%';
        try {
            con = [SELECT Id, AccountId 
                   FROM Contact 
                   WHERE ( Email LIKE :searchedEmail
                   OR MobilePhone LIKE :searchedMobile )
                   AND RecordType.DeveloperName = 'LU_Personal_Contact'];
        }
        catch(Exception e) {
            RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'LU_Personal_Contact'];
            
            User dealerUser = [SELECT Id FROM User WHERE TECH_MergeContactID__c = :wList.idDealer];
            
            con = new Contact(
                FirstName = wList.contactFirstName,
                LastName = wList.contactLastName,
                MobilePhone = wList.contactMobile,
                Email = wList.contactEmail,
                RecordTypeId = rt.Id,
                OwnerId = dealerUser.Id
            );
            insert con;
        }
        
        // find dealer
        Contact dealer = [SELECT Id, AccountId 
                          FROM Contact 
                          WHERE Id = :wList.idDealer];
        
        // get id pbe
        for(lwc75_wishlist_ctrl.ItemWishlist item : wList.l_itemWishlist){
            l_idPbe.add(item.productId);
        }
        
        // find pricebookentries
        Map<String, PriceBookEntry> m_pbePerExternalId = new Map<String, PriceBookEntry>();
        
        
        
        for(PriceBookEntry pbe : [SELECT Id, LU_TECH_External_Id__c, Product2Id, UnitPrice, LU_Valid_For_Total_Amount_Base__c, LU_TaxRate__c, Product2.LU_Brand__c,
                                  Product2.LU_Brand_Territory__c, LU_Offer_type__c, Product2.LU_Type__c, Product2.RecordType.DeveloperName, PriceBook2Id, LU_Counter_value__c
                                  FROM PriceBookEntry
                                  WHERE LU_TECH_External_Id__c IN :l_idPbe]){
                                      m_pbePerExternalId.put(pbe.LU_TECH_External_Id__c, pbe);
                                  }
        
        // create order
        ord = new Order(
            BillToContactId = dealer.Id,
            EffectiveDate = System.Today(),
            AccountId = dealer.AccountId,
            Type = 'Online',
            Status = 'Draft',
            LU_Online_Customer__c = con.Id
        );

        if(m_pbePerExternalId.size() > 0){
            ord.PriceBook2Id = m_pbePerExternalId.values().get(0).PriceBook2Id;
        }
        insert ord;
        
        // create orderitems
        OrderItem oi;
        for(lwc75_wishlist_ctrl.ItemWishlist item : wList.l_itemWishlist){
            if(m_pbePerExternalId.containsKey(item.productId)){
                oi = new OrderItem(
                    orderId = ord.Id,
                    PriceBookEntryId = m_pbePerExternalId.get(item.productId).Id,
                    Product2Id = m_pbePerExternalId.get(item.productId).Product2Id,
                    Quantity = Decimal.valueOf(item.quantity),
                    UnitPrice = m_pbePerExternalId.get(item.productId).UnitPrice,
                    LU_Valid_For_Total_Amount_Base__c = m_pbePerExternalId.get(item.productId).LU_Valid_For_Total_Amount_Base__c,
                    LU_Tax_Rate__c = m_pbePerExternalId.get(item.productId).LU_TaxRate__c,
                    LU_Contact_For__c = con.Id,
                    LU_Brand_Territory__c = m_pbePerExternalId.get(item.productId).Product2.LU_Brand_Territory__c,
                    LU_Brand__c = m_pbePerExternalId.get(item.productId).Product2.LU_Brand__c,
                    LU_Offer_type__c = m_pbePerExternalId.get(item.productId).LU_Offer_type__c,
                    LU_Is_A_Sell__c = true,
                    LU_Product_Type__c = m_pbePerExternalId.get(item.productId).Product2.LU_Type__c,
                    LU_Online_Child_Wanted__c = (item.isBundle ? item.bundleText : null),
                    LU_Counter_1_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[0] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[0]) * Decimal.valueOf(item.quantity),
                    LU_Counter_2_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[1] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[1]) * Decimal.valueOf(item.quantity),
                    LU_Counter_3_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[2] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[2]) * Decimal.valueOf(item.quantity),
                    LU_Counter_4_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[3] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[3]) * Decimal.valueOf(item.quantity),
                    LU_Counter_5_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[4] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[4]) * Decimal.valueOf(item.quantity),
                    LU_Counter_6_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[5] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[5]) * Decimal.valueOf(item.quantity),
                    LU_Counter_7_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[6] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[6]) * Decimal.valueOf(item.quantity),
                    LU_Counter_8_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[7] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[7]) * Decimal.valueOf(item.quantity),
                    LU_Counter_9_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[8] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[8]) * Decimal.valueOf(item.quantity),
                    LU_Counter_10_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[9] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[9]) * Decimal.valueOf(item.quantity),
                    LU_Counter_11_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[10] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[10]) * Decimal.valueOf(item.quantity),
                    LU_Counter_12_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[11] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[11]) * Decimal.valueOf(item.quantity),
                    LU_Counter_13_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[12] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[12]) * Decimal.valueOf(item.quantity),
                    LU_Counter_14_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[13] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[13]) * Decimal.valueOf(item.quantity),
                    LU_Counter_15_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[14] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[14]) * Decimal.valueOf(item.quantity),
                    LU_Counter_16_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[15] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[15]) * Decimal.valueOf(item.quantity),
                    LU_Counter_17_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[16] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[16]) * Decimal.valueOf(item.quantity),
                    LU_Counter_18_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[17] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[17]) * Decimal.valueOf(item.quantity),
                    LU_Counter_19_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[18] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[18]) * Decimal.valueOf(item.quantity),
                    LU_Counter_20_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[19] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[19]) * Decimal.valueOf(item.quantity),
                    LU_Counter_21_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[20] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[20]) * Decimal.valueOf(item.quantity),
                    LU_Counter_22_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[21] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[21]) * Decimal.valueOf(item.quantity),
                    LU_Counter_23_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[22] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[22]) * Decimal.valueOf(item.quantity),
                    LU_Counter_24_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[23] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[23]) * Decimal.valueOf(item.quantity),
                    LU_Counter_25_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[24] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[24]) * Decimal.valueOf(item.quantity),
                    LU_Counter_26_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[25] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[25]) * Decimal.valueOf(item.quantity),
                    LU_Counter_27_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[26] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[26]) * Decimal.valueOf(item.quantity),
                    LU_Counter_28_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[27] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[27]) * Decimal.valueOf(item.quantity),
                    LU_Counter_29_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[28] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[28]) * Decimal.valueOf(item.quantity),
                    LU_Counter_30_new__c = m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[29] == '' ? 0 : Decimal.valueOf(m_pbePerExternalId.get(item.productId).LU_Counter_value__c.split('#')[29]) * Decimal.valueOf(item.quantity)
                );
                l_orderItem.add(oi);
            }
        }
        
        insert l_orderItem;
        
        return null;
    }
}