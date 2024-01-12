@IsTest
private class lwc59_orderhome_order_ctrl_test {
    
    @isTest 
    static void test_getPersonalMessage() {

        Id userId = AP01_TestDataFactory.createCommunityManagerWithTeam('FRA', 'Animatrice de Secteur', 'Leader', 'FRA_LU_DEALER_MANAGER', '');
        User u = [SELECT Id, ContactId FROM User WHERE Id = :userId];

        Contact con = [SELECT Id, PersonalMessage__c FROM Contact WHERE Id = :u.ContactId];
        con.PersonalMessage__c = 'test';
        update con;

        system.runAs(u) {
            String s = lwc59_orderhome_order_ctrl.getPersonalMessage();
        }
    }
}