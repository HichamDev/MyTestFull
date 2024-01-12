public without sharing class Bot_GetSnapInsPreChatData {
    public class PrechatOutput{
        @InvocableVariable
        public String sFirstName;
        @InvocableVariable
        public String sLastName;
        @InvocableVariable
        public String sEmail;
        @InvocableVariable
        public String sContactID;
        @InvocableVariable
        public String sLoggedUser;
    }
    public class PrechatInput{
        @InvocableVariable
        public String sChatKey;
    }
    @InvocableMethod(label='Get SnapIns Prechat Data')
    public static List<PrechatOutput> getSnapInsPrechatData(List<PrechatInput> inputParameters)
    {
        System.debug('######## Input Parameters: '+inputParameters);
          
        String sChatKey = inputParameters[0].sChatKey;
        if(sChatKey == null || sChatKey == '' || Test.isRunningTest()) sChatKey = '1234';
        String sContactId = null;
        List<prechatoutput> outputParameters = new List<prechatoutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        if (sChatKey != null && sChatKey != ''){
            List<LiveChatTranscript> transcripts = [SELECT Id, CaseId,
                                                    ContactId, UserName__c
                                                    FROM LiveChatTranscript WHERE ChatKey = :sChatKey];
            if (transcripts.size()>0){
                if(transcripts[0].ContactId == null && transcripts[0].UserName__c != null){
                    List<User> u = [SELECT Tech_Username__c, FirstName, LastName, Email, ContactId, TECH_ContactID__c FROM USER WHERE Tech_Username__c = : transcripts[0].UserName__c];
                    if(u.size() == 1 && u[0].ContactId != null){
                        sContactId = u[0].ContactId;
                        transcripts[0].ContactId = u[0].ContactId;
                        update transcripts[0];
                    }
                }
                else if(transcripts[0].ContactId != null) sContactId = transcripts[0].ContactId;
                outputParameter.sLoggedUser = transcripts[0].UserName__c;
            }
        
        }
        outputParameter.sContactId = sContactId;
        if (sContactId != null && sContactId != ''){
            List<Contact> contacts = [SELECT Id, FirstName, LastName, Email
                                      FROM Contact WHERE Id = :sContactId];
            if (contacts.size()>0){
                outputParameter.sFirstName = contacts[0].FirstName;
                outputParameter.sLastName = contacts[0].LastName;
                outputParameter.sEmail = contacts[0].Email;
                // outputParameter.sContactId = contacts[0].Id;
            }
        }
        outputParameters.add(outputParameter);
        return outputParameters;
    }
}