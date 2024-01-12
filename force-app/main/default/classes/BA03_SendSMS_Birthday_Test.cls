@isTest(SeeAllData=True)
public with sharing class BA03_SendSMS_Birthday_Test {
    public TestMethod static void BA03_SendSMS_Birthday_Test_Method()
    {
        List<Contact> lContacts = New List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact contact = new Contact();
            contact.LastName = 'LastName_' + i;
            contact.birthdate = Date.today();
            contact.TECH_ExternalId__c = 'Test_ITA_' + i;
            contact.MobilePhone = '33360123456' + i;
            contact.OptinNewsletter1__c = true;
            contact.HasOptedOutOfFax = false;
            lContacts.add(contact);
        }
        insert lContacts;
        system.assertEquals(10, lContacts.size());
        
        // Datetime today = Date.today();	//to be sure to get all periods concerned in the future, not in the past
        // Commercial_Periods__mdt[] commPeriodStartingToday = [SELECT Description__c, Startdate__c, Enddate__c ,Parent_Id__c, TECH_External_Id__c, Type__c 
        // FROM Commercial_Periods__mdt 
        // WHERE Startdate__c >= :today
        // AND Type__c = :PType];
        // return commPeriodStartingToday[0];
        
        BA03_SendSMS_Birthday ba03 = New BA03_SendSMS_Birthday();
        ba03.commPeriodToday = new Commercial_Periods__mdt();
        ba03.commPeriodToday.label = 'Test';
        ba03.commPeriodToday.Type__c = 'Week';
        ba03.commPeriodToday.Startdate__c = Date.today();
        ba03.commPeriodToday.Enddate__c = Date.today() + 10;     
        
        Test.startTest();
        Database.executeBatch(ba03);
        Test.stopTest();
    }
    
    public TestMethod static void AP48_WS_Utils_Send_SMS_OK(){
        Test.startTest();
        AP48_WS_Utils.setWSMocks(true, true);
        String idTpl = 'bidon';
        String strContacts = '{"logic": "duplicate", "logic_param" : "4aa623ab-0178-424c-a107-326cd1119337","name":"Argento", "send_date":"2021-04-20 15:57" , "contacts" : [["3392854005","0035r000008byiIAAQ","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3491674199","0035r000008byioAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3498196735","0035r000008byknAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3333697095","0035r000008bypjAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""]]';
        AP48_WS_Utils.sendSMS(idTpl, strContacts, false, null, null);
        Test.stopTest();
    }
    
    public TestMethod static void AP48_WS_Utils_Send_SMS_NOK(){
        Test.startTest();
        AP48_WS_Utils.setWSMocks(true, false);
        String idTpl = 'bidon';
        String strContacts = '{"logic": "duplicate", "logic_param" : "4aa623ab-0178-424c-a107-326cd1119337","name":"Argento", "send_date":"2021-04-20 15:57" , "contacts" : [["3392854005","0035r000008byiIAAQ","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3491674199","0035r000008byioAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3498196735","0035r000008byknAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3333697095","0035r000008bypjAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""]]';
        AP48_WS_Utils.sendSMS(idTpl, strContacts, false, null, null);
        Test.stopTest();
    }

    public TestMethod static void AP48_WS_Utils_Send_SMS_Login_KO(){
        Test.startTest();
        AP48_WS_Utils.setWSMocks(false, false);
        String idTpl = 'bidon';
        String strContacts = '{"logic": "duplicate", "logic_param" : "4aa623ab-0178-424c-a107-326cd1119337","name":"Argento", "send_date":"2021-04-20 15:57" , "contacts" : [["3392854005","0035r000008byiIAAQ","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3491674199","0035r000008byioAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3498196735","0035r000008byknAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3333697095","0035r000008bypjAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""]]';
        AP48_WS_Utils.sendSMS(idTpl, strContacts, false, null, null);
        Test.stopTest();
    }
    
}