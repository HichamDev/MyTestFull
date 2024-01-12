public without sharing class AP1005_ApplicationAccess {
    
/* CONSTANTS */ 
    public static long TIME_STAMP_DELAY = 1800;
    public static integer DEFAULT_SOAP_TIMEOUT = 120000;


/* METHODS */

    public static List<AP19_ApplicationResponse> getSSOLinksForContact(Contact con) {

        List<AP19_ApplicationResponse> applications = new List<AP19_ApplicationResponse>();

        // SSO links are still valids
        if (checkValidity(con)) {

            applications = (List<AP19_ApplicationResponse>) System.JSON.deserialize(con.TECH_ApplicationAcessUrl__c, List<AP19_ApplicationResponse>.class);

        } else { // Need to refresh the SSO links for the contact

            List<AP19_ApplicationResponse> results = handleWSSSO(con);
            if(results != null && results.size()>0) {
                //serialize and store result    
                Contact conUpdate = new Contact(Id = con.Id);       
                conUpdate.TECH_ApplicationAcessUrl__c = System.JSON.serializePretty(results);
                conUpdate.TECH_ApplicationDateSent__c = Datetime.now();
                update conUpdate;
            }
                
            applications = results;
        }

        return (applications);
    }



    public static boolean checkValidity(Contact con) {

        if (con.TECH_ApplicationDateSent__c == null) {

            return false;
            
        } else {
            
            Datetime todayDateTime = Datetime.now(); 
            
            Datetime expirationDate = con.TECH_ApplicationDateSent__c;
            
            expirationDate = expirationDate.addSeconds(Integer.valueof(TIME_STAMP_DELAY));
            
            return expirationDate > todayDateTime ;     
        }
    }

    public static List<AP19_ApplicationResponse> handleWSSSO(Contact connectedContact) {

        // Construct the header
        list<Profile> profiles = [SELECT Id,Name FROM Profile WHERE Id =: UserInfo.getProfileId() limit 1];
        list<User> users = [select STHID__c, IsActive from User where id =: UserInfo.getUserId() limit 1];
        string country = connectedContact.AccountCountryCode__c;
        string informations = UserInfo.getUserName() + ';' + users[0].STHID__c + ';' + UserInfo.getLanguage()+';'
                            + users[0].IsActive + ';' + UserInfo.getUserEmail() + ';' + UserInfo.getFirstName()+';'+ UserInfo.getLastName();
        AP19_ApplicationRequest request = new AP19_ApplicationRequest(country, profiles[0].name, TIME_STAMP_DELAY, informations);


        list<AP19_ApplicationResponse> requestObjectList = new list<AP19_ApplicationResponse>();
        try{
            
            //call GetApplicationsWithDelay
            apiStanhomeComSso.ApplicationReturn response = getWebServiceResponse(request);

            if(response != null && response.application != null && response.application.sthApplication != null && response.application.sthApplication.size() > 0){
                
                for(integer i=0; i<response.application.sthApplication.size(); i++ ){
                
                    AP19_ApplicationResponse requestObject = new AP19_ApplicationResponse();
                    
                    system.debug('>>>> Start call Webservice4 <<<<' + i);
                    
                    requestObject.name = response.application.sthApplication[i].name;
                    
                    requestObject.description = response.application.sthApplication[i].description;
                    
                    requestObject.url = response.application.sthApplication[i].url;
                    
                    requestObject.imageUrl = response.application.sthApplication[i].imageUrl;
                    
                    requestObjectList.add(requestObject);
                }
            }
            
        system.debug('### requestObjectList.size() : ' + requestObjectList.size());     
        
        return requestObjectList;
        //return getMockData();
        }catch(CalloutException e){
            
            //errMsg = e.getMessage();
            // errMsg = system.label.SSO00002;
            return requestObjectList;
            //return getMockData();
        }catch(Exception e){
            
            //errMsg = e.getMessage();
            // errMsg = e.getMessage();
            return requestObjectList;
            //return getMockData();
        }
    }

    public static apiStanhomeComSso.ApplicationReturn getWebServiceResponse(AP19_ApplicationRequest request){
        
        map <string, STHEndpoints__c> mapSTHEndPoints=  STHEndpoints__c.getAll();
        
        apiStanhomeComSso.ApplicationReturn  response;
        
        if(mapSTHEndPoints.containsKey(request.country)){
        
            String endpoint_x = mapSTHEndPoints.get(request.country).SSO_Endpoint__c;
            
            Integer timeout_x = DEFAULT_SOAP_TIMEOUT;
            
            if(mapSTHEndPoints.get(request.country).Timeout__c != null){
            
                timeout_x =  mapSTHEndPoints.get(request.country).Timeout__c.intValue();

            }
            
            apiStanhomeComSso.SthMainApiSoap  yy = new apiStanhomeComSso.SthMainApiSoap(endpoint_x, timeout_x);
            
            system.debug('>>>> Start call Webservice c <<<<');
            
            //if(!test.isRunningTest()){
                    system.debug('>>>> Start call Webservice2 <<<<');
                    
                    response = yy.GetApplicationsWithDelay(request.country, request.profile, request.timeStampMax, request.informations); 
                    
                    system.debug('### response : ' + response);
            //}else{
                
                //TODO for test case
            //}
        
            
            return response;
            
        }else{
            
            // errMsg = system.label.SSO00003;
            
            return response;
        }
    }
}