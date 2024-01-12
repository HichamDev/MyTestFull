public  class lwc61_orerhome_nbarticles_ctrl {
    
    @AuraEnabled
    public static Contact getUserInformation() {
        return (AP1002_Utils_User.getConnectedUserContact());
    }

    @AuraEnabled
    public static Order getArticleInCurrentDraftOrder(Id contactId, Id orderId){
        
        //Decimal nb = 0;
        Order vOrder;
        Contact con = null;
        if (contactId != null) {
            con = AP1003_Utils_Contact.getContactInfo(contactId);
            if (con.RecordType.DeveloperName == 'LU_Personal_Contact') {
                con = AP1002_Utils_User.getConnectedUserContact();
            }
        } else {
            con = AP1002_Utils_User.getConnectedUserContact();
        }

        List<Order> lOrder = new List<Order>();
        if(orderId == null){
            lOrder = [SELECT Id, LU_Number_Of_Articles__c, LU_Total_Amount_For_Valid_Base__c, Type
                                  FROM Order
                                  WHERE BillToContactId = :con.Id 
                                  AND Status = 'Draft' AND Type='LineUp'];
        }else{
            lOrder = [SELECT Id, LU_Number_Of_Articles__c, LU_Total_Amount_For_Valid_Base__c, LU_Total_Amount_To_Pay__c, Type
                                  FROM Order
                                  WHERE Id = :orderId];
        }        
        
        /* if (!lOrder.isEmpty()) {
            nb = lOrder[0].LU_Number_Of_Articles__c;
        } */

        if(lOrder.size() > 0){
            vOrder = lOrder[0];
        }

        //return (nb);
        return vOrder;
    }

}