public with sharing class RecaptchaHandler {
   public RecaptchaHandler(){

   }


   @AuraEnabled
   public static Boolean isReCAPTCHAValid(String tokenFromClient) {
        //this is not safe, consider putting it in a custom metadata type of securing it in some other way
        String SECRET_KEY = Label.LU_recaptchaSecretKey;
        String RECAPTCHA_SERVICE_URL = 'https://www.google.com/recaptcha/api/siteverify';
        Http http = new Http();

        HttpRequest request = new HttpRequest();

        request.setEndpoint(RECAPTCHA_SERVICE_URL + '?secret=' + SECRET_KEY + '&response=' + tokenFromClient);
        request.setMethod('POST');
        request.setHeader('Content-Length', '0');
        HttpResponse response = http.send(request);

        Map<String, Object> mapOfBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        Boolean success = (Boolean) mapOfBody.get('success');
        Decimal score = (Decimal) mapOfBody.get('score');

        //You'll receive a score and success message. Create your own logic on how to handle this score.
        if(score > 0.5){
            //score passed the treshold, sending success back to component
            success = true;
        } else {
            success = false;
        }

        return success;
   }
}