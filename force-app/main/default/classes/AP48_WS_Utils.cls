public with sharing class AP48_WS_Utils {
    
    private static String token = '' ;
    
    public AP48_WS_Utils(){
        AP46_Sinch.WSReturn vWSReturn = setSinchToken();
        if (vWSReturn.isSuccess){
            token = (String) vWSReturn.wsResponse;
        }
        System.debug('constructeur ' + token);
    }
    
    //get current environment (demo/prod)
    private static Boolean isSandbox(){
        List <Organization> lOrg = [SELECT IsSandbox FROM Organization LIMIT 1];
        return lOrg[0].IsSandbox;
    }
    
    public static String getWSKey(String ws){
        String key = '';
        String env =  isSandbox() ? 'Demo' : 'Prod';
        List<WS_Info__mdt> wsinfos = [
        SELECT Id, Environment__c, Key__c, WS_Name__c 
        FROM WS_Info__mdt 
        WHERE WS_Name__c =: ws and Environment__c =: env limit 1
        ];
        if(wsinfos.size() > 0){
            key = wsinfos[0].Key__c;
        }
        return key;
    }
    
    public static AP46_Sinch.WSReturn setSinchToken() {
        
        Datetime vStartWS = Datetime.now();
        // WS Response
        AP46_Sinch.WSReturn vWSReturn = new AP46_Sinch.WSReturn();
        HttpRequest req = new HttpRequest();
        
        Boolean isSandbox = [select isSandbox from Organization LIMIT 1].IsSandbox;
        String namedString = isSandbox ? 'callout:SinchDemo_BaseURL/' : 'callout:SinchProd_BaseURL/';
        String WSInfoName = isSandbox ? 'Sinch' : 'SinchProd';
        req.setEndpoint(namedString + 'token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        String authorizationHeader = 'Bearer ' + getWSKey(WSInfoName);
        req.setHeader('Authorization', authorizationHeader);
        //iterate through they keys, and populate your map

        
        System.debug('>> Authorization ' + req.getHeader('Authorization'));

        Http vHttp = new Http();
        HttpResponse resToken = vHttp.send(req);
        System.debug('res token' + resToken);
        // Parse the JSON response
        if (resToken.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + resToken.getStatusCode() + ' ' + resToken.getStatus());
            vWSReturn.isSuccess = false;
            vWSReturn.errorCode = resToken.getStatusCode();
            vWSReturn.errorMessage = resToken.getStatus();
        } else {
            AP46_Sinch.SinchAuthRes sar = new AP46_Sinch.SinchAuthRes();
            sar = sar.parse(resToken.getBody());
            vWSReturn.isSuccess = true;
            vWSReturn.wsResponse = sar.access_token;
            token = sar.access_token;
        }
        return vWSReturn;
    }
    
    public static AP46_Sinch.WSReturn sendSMS(String idSinchCampaign, String JSONContacts, Boolean isTestButton, String timeSending, String nomCampagne){
        String sendDateFormat =  isTestButton ? 'yyyy-MM-dd HH:MM' : 'yyyy-MM-dd 10:00';
        List<Sinch_time_SMS_sent__mdt> hours = new List<Sinch_time_SMS_sent__mdt>([SELECT DeveloperName, Heure_envoi__c FROM Sinch_time_SMS_sent__mdt LIMIT 1]);
        if(hours.size() > 0) sendDateFormat = 'yyyy-MM-dd ' + hours[0].Heure_envoi__c;
        if(timeSending != null) sendDateFormat = 'yyyy-MM-dd ' + timeSending;
        
        setSinchToken();
        // JJE 07/09/2023 Ne plus utiliser la map
        // Map<String, String> mIdSinchTplDealerSeniorities = BA02_Utils.getMapIdSinchTemplateDealerSeniorities();
        String nomCampaign = '';
        if (nomCampagne != null && nomCampagne != '') { nomCampaign = nomCampagne;
        }
        if (nomCampaign == '' && idSinchCampaign == Birthday_Settings__mdt.getInstance('Birthday_current').SinchTemplateId__c) {
            nomCampaign = Birthday_Settings__mdt.getInstance('Birthday_current').Label;
        }
        if (nomCampaign == '' && idSinchCampaign == Anniversary_Settings__mdt.getInstance('Anniversary_current').SinchTemplateId__c) {
            nomCampaign = Anniversary_Settings__mdt.getInstance('Anniversary_current').Label;
        }
        System.debug('idSinchCampaign ' + idSinchCampaign);
        AP46_Sinch.WSReturn vWSReturn = new AP46_Sinch.WSReturn();
        if(token != ''){
            HttpRequest req = new HttpRequest();
            Boolean isSandbox = [select isSandbox from Organization LIMIT 1].IsSandbox;
            String namedString = isSandbox ? 'callout:SinchDemo_BaseURL/' : 'callout:SinchProd_BaseURL/';
            req.setEndpoint(namedString + 'campaign/create');            
            req.setMethod('POST');
            String authorizationHeader = 'Bearer ' + token;
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            String strBody = '{"logic": "duplicate", "logic_param" : "' + idSinchCampaign + '","name":"' + nomCampaign + '", "send_date":"' + Datetime.now().format(sendDateFormat) + '" , "contacts" : ' + JSONContacts + '}';
            req.setBody(strBody);
            System.debug('strBody ' + strBody);
            Http http = new Http();
            req.setTimeout(50000);
            HTTPResponse res = http.send(req);
            if (res.getStatusCode() != 200) {
                System.debug('sendSMS - idSinchCampaign ' +idSinchCampaign);
                System.debug('sendSMS - JSONContacts ' +JSONContacts);
                System.debug('sendSMS - res.getBody ' + res.getBody());
                // vWSReturn.wsResponse = (AP46_Sinch.SinchCampaign) System.JSON.deserialize(res.getBody(), AP46_Sinch.SinchCampaign.class);
            }
            else{
                vWSReturn.wsResponse = 'Send ok';
            }
        }
        System.debug('vWSReturn ' + vWSReturn);
        return vWSReturn;
    }

    // @isTest
    public static void setWSMocks(Boolean isLoginSuccess, Boolean isResponseSuccess){
        Integer statusCodeLogin = isLoginSuccess ? 200 : 500;
        Integer statusCoderesponse = isResponseSuccess ? 200 : 500;
        Map<String, HttpCalloutMock> endpointsResp = new Map<String,HttpCalloutMock>();
        /** set mock for token */
        StaticResource srToken = [SELECT Id, Body FROM StaticResource WHERE Name ='STH_Sinch_Token' LIMIT 1];
        Blob bodyBlobToken = srToken.Body;
        String reponsetoken = bodyBlobToken.toString();
        AP52_SingleRequestMock fakeRespToken = new AP52_SingleRequestMock(statusCodeLogin, 'Success', reponsetoken, null );
        //endpointsResp.put(tokenURL,fakeRespToken);
        Boolean isSandbox = [select isSandbox from Organization LIMIT 1].IsSandbox;
        String namedString = isSandbox ? 'callout:SinchDemo_BaseURL/token' : 'callout:SinchProd_BaseURL/token';
        endpointsResp.put(namedString,fakeRespToken);
        
        /** set mock for response to send SMS */
        StaticResource srSendSMS = [SELECT Id, Body FROM StaticResource WHERE Name = 'STH_Sinch_send_SMS' LIMIT 1];
        Blob bodyBlobsrSendSMS = srSendSMS.Body;
        String responseSendSMS = bodyBlobsrSendSMS.toString();
        AP52_SingleRequestMock fakeRespSendSMS = new AP52_SingleRequestMock(statusCoderesponse, 'Success', responseSendSMS, null);
        String endPointAsset = isSandbox ? 'callout:SinchDemo_BaseURL/campaign/create' : 'callout:SinchProd_BaseURL/campaign/create';
        endpointsResp.put(endPointAsset, fakeRespSendSMS);
        
        /** init and set multiCalloutMock with all mocks */
        HttpCalloutMock multiCalloutMock = new AP51_MultiRequestMock(endpointsResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    }
}