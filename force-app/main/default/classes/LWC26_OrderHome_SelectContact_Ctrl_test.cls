@IsTest
private class LWC26_OrderHome_SelectContact_Ctrl_test {
    
    @isTest 
    static void test_getContacts() {

        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        User u = [SELECT Id FROM User WHERE Id = :userId];
        system.runAs(u) {
            LWC26_OrderHome_SelectContact_Ctrl.getContacts(Label.LU_TECH_Contact_Customer);
            LWC26_OrderHome_SelectContact_Ctrl.getContacts(Label.LU_TECH_Contact_Team);

            LWC26_OrderHome_SelectContact_Ctrl.CurrentUserInfo ci = LWC26_OrderHome_SelectContact_Ctrl.getCurrentUserInformation();
            Contact con = LWC26_OrderHome_SelectContact_Ctrl.getMyContact();
            String country = LWC26_OrderHome_SelectContact_Ctrl.getUserCountry();
            con = LWC26_OrderHome_SelectContact_Ctrl.getContactById(con.Id);
            User us = LWC26_OrderHome_SelectContact_Ctrl.getConnectedUser();
            String title = LWC26_OrderHome_SelectContact_Ctrl.getUserContactTitle();
        }
    }
}