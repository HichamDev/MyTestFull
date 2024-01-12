public without sharing class VFC19_ApplicationAccess {
    
    public List<AP19_ApplicationResponse> applications {get; set;}
    
    public Contact connectedContact {get; set;}
    
    public boolean isShowButton {get; set;}
    
    public string errMsg {get; set;}
    
    //Time delay in second
    public static long TIME_STAMP_DELAY = 1800;
    
    public static integer DEFAULT_SOAP_TIMEOUT = 120000;
    
    /**
    * Constructor 
    */ 
    public VFC19_ApplicationAccess(){
        
        system.debug('>>>>>>>>>>>>>  Start VFC19_ApplicationAccess Constructor <<<<<<<<<<<<<<<<<'); 
        
        getConnectedContactFromUser();
        
        system.debug('>>>>>>>>>>>>>  VFC19_ApplicationAccess connectedContact : ' + connectedContact); 
        
        if(connectedContact != null){
            if(checkValidity()){
                //deserialize list List<AP19_ApplicationResponse>
                
                applications = getStoredData();

                isShowButton = false;
            
            }else{
                
                isShowButton = true;
            }
            
        }else{
            
            isShowButton = false;
        }
        
        
        errMsg = null;
        
        system.debug('### isShowButton : ' + isShowButton);

        system.debug('>>>>>>>>>>>>>  End VFC19_ApplicationAccess <<<<<<<<<<<<<<'); 
        
    }// constructor
    
    public void synchronizeApps(){
        
        requestApplications();
    }
    
    public void requestApplications(){
        
        system.debug('>>>>>>>>>>>>> 1. Start requestApplications '); 
        if(connectedContact != null){
            if(checkValidity()){
            
                //deserialize list List<AP19_ApplicationResponse>
             
                applications = getStoredData();

                
                system.debug('### applications (deserialized data) : ' + applications);
                 
            }else{
                
                //call webservice and populate TECH_ApplicationAcessUrl__c
                List<AP19_ApplicationResponse> results = callWebservice();
                if(results != null && results.size()>0){
                    //serialize and store result            
                    connectedContact.TECH_ApplicationAcessUrl__c = System.JSON.serializePretty(results);
                    
                    connectedContact.TECH_ApplicationDateSent__c = Datetime.now();
                    
                    update connectedContact;
                }
                
                applications = results;
                
            }
        }
        
        isShowButton = false;
        system.debug('>>>>>>>>>>>>> 1. End requestApplications '); 
    } // requestApplications
    
    private List<AP19_ApplicationResponse> getStoredData(){
    
        system.debug('>>>>>>>>>>>>> 2. Start getStoredData '); 
        
        system.debug('>>>>>>>>>>>>> 2. serializedData ' + connectedContact.TECH_ApplicationAcessUrl__c); 
        
        List<AP19_ApplicationResponse> deserializedData = (List<AP19_ApplicationResponse>) System.JSON.deserialize(connectedContact.TECH_ApplicationAcessUrl__c, List<AP19_ApplicationResponse>.class);
        
        system.debug('>>>>>>>>>>>>> 2. deserializedData ' + deserializedData); 
        
        system.debug('>>>>>>>>>>>>> 2. End getStoredData '); 
        
        return  deserializedData;
        
    }
    
    private List<AP19_ApplicationResponse> callWebservice(){
        
        system.debug('>>>> Start call Webservice <<<<');
        
        //get parameters to call GetApplicationsWithDelay
        AP19_ApplicationRequest request = constructParameters();
        
        system.debug('>>>> callWebservice request <<<<' +request);
        
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
            errMsg = system.label.SSO00002;
            return requestObjectList;
            //return getMockData();
        }catch(Exception e){
            
            //errMsg = e.getMessage();
            errMsg = e.getMessage();
            return requestObjectList;
            //return getMockData();
        }
    
    }
    
    private  AP19_ApplicationRequest constructParameters(){
        
        list<Profile> profiles = [SELECT Id,Name FROM Profile WHERE Id =: UserInfo.getProfileId() limit 1];
        
        list<User> users = [select STHID__c, IsActive from User where id =: UserInfo.getUserId() limit 1];
        
        string country = connectedContact.AccountCountryCode__c;
        
        string informations = UserInfo.getUserName() + ';' + users[0].STHID__c + ';' + UserInfo.getLanguage()+';'
                            + users[0].IsActive + ';' + UserInfo.getUserEmail() + ';' + UserInfo.getFirstName()+';'+ UserInfo.getLastName();
            
                            
        //return new AP19_ApplicationRequest(country, 'FRA_Dealer', TIME_STAMP_DELAY, informations);
        return new AP19_ApplicationRequest(country, profiles[0].name, TIME_STAMP_DELAY, informations);
        
    }
    
    private apiStanhomeComSso.ApplicationReturn getWebServiceResponse(AP19_ApplicationRequest request){
        
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
            
            if(!test.isRunningTest()){
                    system.debug('>>>> Start call Webservice2 <<<<');
                    
                    response = yy.GetApplicationsWithDelay(request.country, request.profile, request.timeStampMax, request.informations); 
                    
                    system.debug('### response : ' + response);
            }else{
                
                //TODO for test case
            }
            
            system.debug(response);
            
            return response;
            
        }else{
            
            errMsg = system.label.SSO00003;
            
            return response;
        }
    }
    
    private boolean checkValidity(){
        
        system.debug('>>>>>>>>>>>>> 3. Start checkValidity '); 
        
        if(connectedContact.TECH_ApplicationDateSent__c == null){

            return false;
            
        }else{
            
            Datetime todayDateTime = Datetime.now(); 
            
            Datetime expirationDate = connectedContact.TECH_ApplicationDateSent__c;
            
            expirationDate = expirationDate.addSeconds(Integer.valueof(TIME_STAMP_DELAY));
            
            system.debug('>>>>>>>>>>>>> checkValidity expirationDate.getTime() '+expirationDate.getTime()); 
            
            system.debug('>>>>>>>>>>>>> checkValidity todayDateTime.getTime() '+todayDateTime.getTime()); 
            
            system.debug('>>>>>>>>>>>>> checkValidity expirationDate '+expirationDate); 
            
            system.debug('>>>>>>>>>>>>> checkValidity todayDateTime '+todayDateTime); 
            
            system.debug('>>>>>>>>>>>>> checkValidity '+ (expirationDate > todayDateTime)); 

            return expirationDate > todayDateTime ;     
        }
            
    }
    
    private void getConnectedContactFromUser(){
        
        if(connectedContact == null){
            
            connectedContact = SHW_IBZ_Utils.getConnectedUserContact();
            
        }
    }
    
    /*
    private List<AP19_ApplicationResponse> getMockData(){
        
        List<AP19_ApplicationResponse> applications = new List<AP19_ApplicationResponse>();
        
        String name = 'Url Access ';
        
        for(integer i = 1 ; i < 10; i++){
            
            AP19_ApplicationResponse app = new AP19_ApplicationResponse();
            
            app.name = name + i;
            
            app.imageUrl = '/resource/STH_Resources/STH_Resources/images/pictos/pi_enregistrer_commande.png';
            
            app.url = 'http://google.com';
            
            app.description = 'Connect to application ' + app.name;
            
            applications.add(app);
        }
        
        return applications;
        
    }*/
    
}