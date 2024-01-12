@isTest
public class AP52_SingleRequestMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;

        public AP52_SingleRequestMock(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsString = body;
            this.bodyAsBlob = null;
            this.responseHeaders = responseHeaders;
        }
 
        public HTTPResponse respond(HTTPRequest req) {
            if(code == null && status == null && bodyAsString == null && responseHeaders == null)
            {
                System.debug('SingleMock send null');
                HttpResponse resp = null;
                return resp;
            } else {
                System.debug('SingleMock send response');
                HttpResponse resp = new HttpResponse();
                resp.setStatusCode(code);
                resp.setStatus(status);
                if (bodyAsBlob != null) {
                    resp.setBodyAsBlob(bodyAsBlob);
                } else {
                    resp.setBody(bodyAsString);
                }
    
                if (responseHeaders != null) {
                    for (String key : responseHeaders.keySet()) {
                        resp.setHeader(key, responseHeaders.get(key));
                    }
                }
                return resp;
            }
        }
}