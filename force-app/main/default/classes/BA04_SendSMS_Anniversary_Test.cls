@isTest
public class BA04_SendSMS_Anniversary_Test {
    @isTest
    public static void BA04_SendSMS_Anniversary_Test_Method()
    {

        List<Contact> lContacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact contact = new Contact();
            contact.LastName = 'LastName_' + i;
            contact.Start_date__c = Date.today() - 365;
            contact.LU_LastOrderDate__c = Date.today() - 365;
            contact.TECH_ExternalId__c = 'Test_ITA_' + i;
            contact.MobilePhone = '39360123456' + i;
            contact.OptinNewsletter1__c = true;
            contact.HasOptedOutOfFax = false;
            contact.LU_Anniversary_Flags__c  = Date.today().year() + 'C01';
            contact.Title  = 'Smile';
            lContacts.add(contact);
        }
        insert lContacts;
        System.assertEquals(10, lContacts.size());
        
        BA04_SendSMS_Anniversary ba04 = new BA04_SendSMS_Anniversary();
        ba04.commPeriodToday = new Commercial_Periods__mdt();
        ba04.commPeriodToday.label = Date.today().year() + '01';
        ba04.commPeriodToday.Type__c = 'Cycle';
        ba04.commPeriodToday.Startdate__c = Date.today();
        ba04.commPeriodToday.Enddate__c = Date.today() + 10;     
        ba04.commPeriodToday.Description__c = 'C01';     
        
        Test.startTest();
        Database.executeBatch(ba04);
        Test.stopTest();
    }
    
    @isTest
    public static void AP48_WS_Utils_Send_SMS_OK(){
        Test.startTest();
        AP48_WS_Utils.setWSMocks(true, true);
        String idTpl = 'bidon';
        String strContacts = '{"logic": "duplicate", "logic_param" : "4aa623ab-0178-424c-a107-326cd1119337","name":"Argento", "send_date":"2021-04-20 15:57" , "contacts" : [["3392854005","0035r000008byiIAAQ","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3491674199","0035r000008byioAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3498196735","0035r000008byknAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3333697095","0035r000008bypjAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""]]';
        AP48_WS_Utils.sendSMS(idTpl, strContacts, false, null, null);
        Test.stopTest();
    }
    
    @isTest
    public static void AP48_WS_Utils_Send_SMS_NOK(){
        Test.startTest();
        AP48_WS_Utils.setWSMocks(true, false);
        String idTpl = 'bidon';
        String strContacts = '{"logic": "duplicate", "logic_param" : "4aa623ab-0178-424c-a107-326cd1119337","name":"Argento", "send_date":"2021-04-20 15:57" , "contacts" : [["3392854005","0035r000008byiIAAQ","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3491674199","0035r000008byioAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3498196735","0035r000008byknAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3333697095","0035r000008bypjAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""]]';
        AP48_WS_Utils.sendSMS(idTpl, strContacts, false, null, null);
        Test.stopTest();
    }

    @isTest
    public static void AP48_WS_Utils_Send_SMS_Login_KO(){
        Test.startTest();
        AP48_WS_Utils.setWSMocks(false, false);
        String idTpl = 'bidon';
        String strContacts = '{"logic": "duplicate", "logic_param" : "4aa623ab-0178-424c-a107-326cd1119337","name":"Argento", "send_date":"2021-04-20 15:57" , "contacts" : [["3392854005","0035r000008byiIAAQ","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3491674199","0035r000008byioAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3498196735","0035r000008byknAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""],["3333697095","0035r000008bypjAAA","","Ciclo C05","","fakeemail@test.com","","","","","","","","","","","","","","","","","","","",""]]';
        AP48_WS_Utils.sendSMS(idTpl, strContacts, false, null, null);
        Test.stopTest();
    }
}