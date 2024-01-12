@isTest
global class MOCK_SthMainApiSoap_Test implements WebServiceMock {
    
    global void doInvoke(Object stub,
                        Object request,
                        Map<String, Object> response,
                        String endpoint,
                        String soapAction,
                        String requestName,
                        String responseNS,
                        String responseName,
                        String responseType) {
        
        if (requestName == 'GetApplicationsWithDelay') {

            apiStanhomeComSso.GetApplicationsWithDelayResponse_element ret = new apiStanhomeComSso.GetApplicationsWithDelayResponse_element();
            ret.GetApplicationsWithDelayResult = new apiStanhomeComSso.ApplicationReturn();
            ret.GetApplicationsWithDelayResult.countryCode = 'FRA';
            ret.GetApplicationsWithDelayResult.profileType = 'FRA_LU_DEALER_MANAGER';
            ret.GetApplicationsWithDelayResult.application = new apiStanhomeComSso.ArrayOfSthApplication();
            ret.GetApplicationsWithDelayResult.application.sthApplication = new List<apiStanhomeComSso.sthApplication>();

            apiStanhomeComSso.sthApplication link1 = new apiStanhomeComSso.sthApplication();
            link1.name = 'Stan\'Mag';
            link1.description = 'Stan\'Mag FRANCE';
            link1.url = 'http://stanmag.stanhome.fr/?token=-hV';
            link1.imageUrl = 'https://mystan--c.eu25.content.force.com/servlet/servlet.ImageServer?id=0152o000006fi1D&oid=00DD0000000rV9g';
            ret.GetApplicationsWithDelayResult.application.sthApplication.add(link1);

            apiStanhomeComSso.sthApplication link2 = new apiStanhomeComSso.sthApplication();
            link2.name = 'Link 2';
            link2.description = 'Description Link 2';
            link2.url = 'http://link2.fr';
            link2.imageUrl = 'https://mystan--c.eu25.content.force.com/servlet/servlet.ImageServer?id=0152o000006fi1D&oid=00DD0000000rV9g';
            ret.GetApplicationsWithDelayResult.application.sthApplication.add(link2);
            
            response.put('response_x', ret);
        }
     
    }

}