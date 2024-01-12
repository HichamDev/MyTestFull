@isTest
private class SiteLogoutControllerMain_TEST {
/*
// SiteLogoutControllerMain_TEST 
----------------------------------------------------------------------
-- - Name          : SiteLogoutControllerMain_TEST 
-- - Author        : WCHY
-- - Description   : Test method for SiteLogoutControllerMain_TEST 
--                  
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 15-JUL-2015  WCHY    1.0      Initial version 
---------------------------------------------------------------------
**********************************************************************
*/  

    static testMethod void SiteLogoutControllerMainTesting() {
        test.startTest();
        // Instantiate a new controller with all parameters in the page
        SiteLogoutControllerMain logoutMainController = new SiteLogoutControllerMain();
        logoutMainController.redirect() ; 
        logoutMainController.theLanguage='fr';
        logoutMainController.username='fr';
        logoutMainController.password='***';
        logoutMainController.theRedirecturl='http://devbd-mystan.cs7.force.com/es';
        
        Cookie RememberMeCookie = ApexPages.currentPage().getCookies().get('RememberMeCookie');
        String cookieData='usernameTest'+'##'+logoutMainController.password+'##'+logoutMainController.theRedirecturl;
        Blob encryptedValue = Crypto.encryptWithManagedIV('AES256', EncodingUtil.base64decode('7wsIsQO482gwinalKhw0fW87B0AM/JXP4gFQiEzGMTI='), Blob.valueOf(cookieData));
        if (RememberMeCookie == null) {
            RememberMeCookie = new Cookie('RememberMeCookie',EncodingUtil.base64encode(encryptedValue),null,-1,false);
        }
        // Set the new cookie for the page
        ApexPages.currentPage().setCookies(new Cookie[]{RememberMeCookie});
        
        logoutMainController.redirect() ;      
        
       
        
        
        test.stopTest();
    }
}