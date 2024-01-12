public without sharing class AP53_QuickContractCallout {
    
    @AuraEnabled
    public static void pushFilesForSignature(Id idLead){
        Lead l = [SELECT Id, email, LastName, FirstName FROM Lead WHERE Id = :idLead];

        executeCallout(idLead, l.email, l.firstName, l.lastName);
    }
    
    @future(callout=true)  
    public static void pushFilesForSignature(Id idLead, String email, String firstname, String lastname){
        executeCallout(idLead, email, firstname, lastname);
    }
    
      
    public static void executeCallout(Id idLead, String email, String firstname, String lastname){
        
        STHEndpoints__c cs = [SELECT Id, QuickContract_Endpoint__c, QuickContract_Token__c
                                FROM STHEndpoints__c
                                WHERE Name =: 'FRA' ];
        
        Httprequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(cs.QuickContract_Endpoint__c);   
        request.setHeader('Authorization', 'Bearer ' + cs.QuickContract_Token__c);
        request.setHeader('Content-Type', 'application/json');

        string body = '{'
        + '"addrEmail" : "' + email + '",'
        + '"firstName" : "' + Accents.removeDiacritics(firstname).toUpperCase() + '",'
        + '"lastName" : "' + Accents.removeDiacritics(lastname).toUpperCase() + '",'
        + '"hasRecruteuse" : false,'
        + '"codeCollaborateurRecruteuse" : "",'
        + '"captcha" : true'
        + '}';

        System.debug(body);

        request.setBody(body);

        Http http = new Http();
        HttpResponse resp = http.send(request);

        Lead l = new Lead(
            Id = idLead,
            QuickContract_StatusCode__c = String.valueOf(resp.getStatusCode()),
            QuickContract_Message__c = resp.getBody()
        );
        update l;
    }
}