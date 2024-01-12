@isTest
private class SiteLoginControllerMain_TEST {
/*
// SiteLoginControllerMain_TEST 
----------------------------------------------------------------------
-- - Name          : SiteLoginControllerMain_TEST 
-- - Author        : WCHY
-- - Description   : Test method for SiteLoginControllerMain_TEST 
--                  
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 30-JUN-2015  WCHY    1.0      Initial version 
---------------------------------------------------------------------
**********************************************************************
*/  

    static testMethod void SiteLoginControllerMainTesting() {
        test.startTest();
        // Instantiate a new controller with all parameters in the page
        SiteLoginControllerMain loginMainController = new SiteLoginControllerMain();
        loginMainController.theLanguage='fr';
        loginMainController.currentURL='fr';
        loginMainController.password='***';
        loginMainController.redirect() ;      
        Cookie RememberMeCookie = ApexPages.currentPage().getCookies().get('RememberMeCookie');
        String cookieData='usernameTest'+'##'+'*******'+'##'+'http://devbd-mystan.cs7.force.com/es';
        Blob encryptedValue = Crypto.encryptWithManagedIV('AES256', EncodingUtil.base64decode('7wsIsQO482gwinalKhw0fW87B0AM/JXP4gFQiEzGMTI='), Blob.valueOf(cookieData));
        if (RememberMeCookie == null) {
            RememberMeCookie = new Cookie('RememberMeCookie',EncodingUtil.base64encode(encryptedValue),null,-1,false);
        }
        // Set the new cookie for the page
        ApexPages.currentPage().setCookies(new Cookie[]{RememberMeCookie});  
        loginMainController.redirect() ; 
        test.stopTest();
    }
}