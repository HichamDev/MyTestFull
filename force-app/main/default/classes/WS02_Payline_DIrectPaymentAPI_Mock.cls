@isTest
public class WS02_Payline_DIrectPaymentAPI_Mock implements WebServiceMock {

    public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

            if (soapAction == 'doWebPayment') {

                WS01_Payline_WebPaymentAPI.doWebPaymentResponse_element respElement = new WS01_Payline_WebPaymentAPI.doWebPaymentResponse_element();
                system.debug('>>>> DoWebPayment : request : ' + request);
                
                // Success return 
                if (String.valueOf(request).contains('120') || String.valueOf(request).contains('20402') || String.valueOf(request).contains('202')) {
    
                    respElement.result = new WS02_Payline_Object.result();
                    respElement.result.code = '00000';
                    respElement.result.longMessage = 'Transaction approved';
                    respElement.token = '1111111111';
    
                } else if (String.valueOf(request).contains('121')) { // Error code
    
                    respElement.result = new WS02_Payline_Object.result();
                    respElement.result.code = '01000';
                    respElement.result.longMessage = 'Transaction not approved';
                    respElement.token = '2222222222';
    
                } else { // Technical error
    
                    throw new DMLException('Technical error'); 
    
                }
    
                // return the result
                response.put('response_x', respElement); 
            }
    
    // GETWEBPAYMENTDETAILS
            if (soapAction == 'getWebPaymentDetails') {
    
                WS01_Payline_WebPaymentAPI.getWebPaymentDetailsResponse_element respElement = new WS01_Payline_WebPaymentAPI.getWebPaymentDetailsResponse_element();
    
                // Success return
                if (String.valueOf(request).contains('1111111111')) {
    
                    respElement.result = new WS02_Payline_Object.result();
                    respElement.result.code = '00000'; 
                    respElement.result.longMessage = 'Transaction approved';
                    respElement.transaction_x = new WS02_Payline_Object.transaction_x();
                    respElement.transaction_x.Id = '1111111111';
    
                } else if (String.valueOf(request).contains('2222222222')) { // Refused return
    
                    respElement.result = new WS02_Payline_Object.result();
                    respElement.result.code = '04002'; 
                    respElement.result.longMessage = 'Fraud detected';
                    respElement.transaction_x = new WS02_Payline_Object.transaction_x();
                    respElement.transaction_x.Id = 'LF2222222222';
    
                } else if (String.valueOf(request).contains('33333333333')) { // Technical error return
    
                    respElement.result = new WS02_Payline_Object.result();
                    respElement.result.code = '05000'; 
                    respElement.result.longMessage = 'Transaction error';
                    respElement.transaction_x = new WS02_Payline_Object.transaction_x();
                    respElement.transaction_x.Id = '33333333333';
    
                } else if (String.valueOf(request).contains('44444444444')) { // Technical error return
    
                    respElement.result = new WS02_Payline_Object.result();
                    respElement.result.code = '1100'; 
                    respElement.result.longMessage = 'Transaction error';
                    respElement.transaction_x = new WS02_Payline_Object.transaction_x();
                    respElement.transaction_x.Id = '44444444444';
    
                } else if (String.valueOf(request).contains('55555555555')) { // Technical error return

                    respElement.result = new WS02_Payline_Object.result();
                    respElement.result.code = '1116'; 
                    respElement.result.longMessage = 'Transaction error';
                    respElement.transaction_x = new WS02_Payline_Object.transaction_x();
                    respElement.transaction_x.Id = '55555555555';
    
                } else if (String.valueOf(request).contains('66666666666')) { // Technical error return
    
                    respElement.result = new WS02_Payline_Object.result();
                    respElement.result.code = '3022'; 
                    respElement.result.longMessage = 'Transaction error';
                    respElement.transaction_x = new WS02_Payline_Object.transaction_x();
                    respElement.transaction_x.Id = '66666666666';
    
                } else { // Technical exception return
    
                    throw new DMLException('Technical error 2'); 
                }
                
    
                // return the result
                response.put('response_x', respElement); 
            }
// DORESET
        else if (soapAction == 'doReset') {
            
            WS02_Payline_DIrectPaymentAPI.doResetResponse_element ret = new WS02_Payline_DIrectPaymentAPI.doResetResponse_element();

            // Success return
            if (String.valueOf(request).contains('1111111111') || String.valueOf(request).contains('20402') || String.valueOf(request).contains('202')) {

                ret.result = new WS02_Payline_Object.result();
                ret.result.code = '00000'; 
                ret.result.longMessage = 'Transaction approved';

            } else if (String.valueOf(request).contains('22222222')) { // Error code

                ret.result = new WS02_Payline_Object.result();
                ret.result.code = '05000'; 
                ret.result.longMessage = 'Transaction approved';

            } else { // Technical error

                throw new DMLException('Technical error'); 
            
            }

            // end
            response.put('response_x', ret); 
        }

    }
}