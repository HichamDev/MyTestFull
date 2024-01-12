public class AP54_LeadHandler {
    
    public static void handleQuickContract(List<Id> l_idLead){
        List<Lead> l_lead = [SELECT Id, Email, FirstName, LastName FROM Lead WHERE Id IN :l_idLead];
        
        for(Lead l : l_lead){
            AP53_QuickContractCallout.pushFilesForSignature(l.Id, l.Email, l.FirstName, l.LastName);
        }
    }
}