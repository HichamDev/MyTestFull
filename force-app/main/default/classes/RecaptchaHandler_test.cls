@IsTest
public with sharing class RecaptchaHandler_test {
    
    @isTest 
    static void testIsReCAPTCHAValid() {

        Test.setMock(HttpCalloutMock.class, new AP52_SingleRequestMock(1, 'Success', '{"success":true,"score":1}', null ));

        RecaptchaHandler.isReCAPTCHAValid('test');
    }
}