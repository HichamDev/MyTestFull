@isTest
public class AP51_MultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;
 
    public AP51_MultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
        System.debug('### URL in multimock');
        for(String s:this.requests.KeySet())
        {
            System.debug('URL : ' + s);
        }
    }
 
    public HTTPResponse respond(HTTPRequest req) {
        // delete parameters after (remove after character ? + ?)
        System.debug('### call url : ' + req.getEndpoint());
        String urlReq = req.getEndpoint().SubStringBefore('?');
        System.debug(urlReq) ;
        System.debug('### endPoint Mock : ' + urlReq);
        System.debug(' ## multimock containsURL ? ' + requests.containsKey(urlReq));
        HttpCalloutMock mock = requests.get(urlReq);
        if (mock != null) {
            return mock.respond(req);
        } else {
            System.debug('[Exception] HTTP callout not supported for test methods');
        }
        return null;
    }
 
    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}