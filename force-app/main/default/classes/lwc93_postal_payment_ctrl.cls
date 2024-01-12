public without sharing class lwc93_postal_payment_ctrl {
   
    @AuraEnabled
    public static String sendPostalPaymentEmail(Decimal amount) {

        User us;
        try{
            us = [SELECT Id, STHID__c FROM User WHERE Id = :Userinfo.getUserId()];
        } catch(Exception e){
            return 'KO USER';
        }

        Httprequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://api7.stanhomeitalia.it/bol-01/boll-23.php');   
        request.setHeader('Api-Key', '1k9n8edyTh5h58fj32s');
        request.setHeader('Content-Type', HttpFormBuilder.GetContentType());

        String body = '';
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('soggetto', us.STHID__c);
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('cifra', '' + amount);
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('timestamp_mystan', '\'' + System.now() + '\'');
        body += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);

        Blob formBlob = EncodingUtil.base64Decode(body);

        request.setHeader('Content-Length', String.valueOf(formBlob.size()));
        request.setBodyAsBlob(formBlob);

        Http http = new Http();
        HttpResponse resp = http.send(request);

        if(resp.getBody() == 'Record inserito correttamente'){

            return 'OK';
        }

        return 'KO';
    }
}