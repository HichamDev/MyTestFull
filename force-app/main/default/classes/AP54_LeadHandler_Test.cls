@IsTest
public class AP54_LeadHandler_Test {
    
    @IsTest
    public static void handleQuickContract(){
        
        Lead l = new Lead(
            LastName = 'test',
            Company = 'company'
        );
        insert l;
    }
}