/**
 * An apex page controller that exposes the site login functionality
 */
global without sharing class SiteLoginControllerMain {
    global String currentURL {get; set;}
    global String password {get; set;}
    global String theLanguage{get; set;}

    global SiteLoginControllerMain () {
    }
    public PageReference redirect() {
      
      
	    system.debug('Site.isPasswordExpired()'+Site.isPasswordExpired());
	    system.debug('UserInfo.getUserType()'+UserInfo.getUserType());
	    system.debug('Test.isRunningTest()'+Test.isRunningTest());
	    PageReference redirectedPage=null;
	    
	   if(UserInfo.getUserType()!='Guest' && !Test.isRunningTest() && Site.getSiteId()!=null){
	   		redirectedPage = new PageReference(system.label.site_login_startUrl);
			system.debug('UserInfo.getUserType()!=\'Guest\' && !Test.isRunningTest() ok');
		}
		else{

   			//check if encrypted cookie is present
   			if(ApexPages.currentPage().getCookies().get('RememberMeCookie') != null) {
	      		Cookie RememberMeCookie = ApexPages.currentPage().getCookies().get('RememberMeCookie');
	      		Blob encryptedValue = EncodingUtil.base64decode(RememberMeCookie.getValue());
	      		Blob decryptedValue = Crypto.decryptWithmanagedIV('AES256', EncodingUtil.base64decode('7wsIsQO482gwinalKhw0fW87B0AM/JXP4gFQiEzGMTI='), encryptedValue);
	      		String[] cookieDataAll= decryptedValue.toString().split('##');
		    	pageReference homePage = Site.login(cookieDataAll[0], cookieDataAll[1], system.label.site_login_startUrl);
		    	return homePage;
		    }else{
		    	PageReference homePage=null;
		    	if((ApexPages.currentPage().getParameters().get('lang')==null && Site.getSiteId()!=null) ||  Test.isRunningTest() ){
		           String currentBaseUrl=URL.getSalesforceBaseUrl().toExternalForm();
		           currentURL = Site.getPathPrefix()==null || Site.getPathPrefix().equals('') ? '*fr' : Site.getPathPrefix();
		           theLanguage=currentURL.substring(1);
		           String language=(currentURL.substring(1)=='mx' ? 'es_mx' : currentURL.substring(1));
		           String redirectedToPageLang=currentBaseUrl+'/'+currentURL.substring(1);
		           homePage = new PageReference(redirectedToPageLang);
		           homePage.getParameters().put('lang', language);
		       }
		       //currentURL = ApexPages.currentPage().getParameters().get('lang');
		       return homePage;
		    }
	   }
	   system.debug('redirectedPage'+redirectedPage);
	   return redirectedPage;
    }
    
}