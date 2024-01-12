/**
 * An apex page controller that exposes the site logout functionality
 */
global without sharing class SiteLogoutControllerMain {
    global String username {get; set;}
    global String password {get; set;}
    global String theLanguage{get; set;}
    global String theRedirecturl{get; set;}
    
    global SiteLogoutControllerMain () {
      getURLParameters();
    }

    public PageReference redirect() {
    	if(ApexPages.currentPage().getCookies().get('RememberMeCookie') != null) {
	    	Cookie RememberMeCookie = ApexPages.currentPage().getCookies().get('RememberMeCookie');
	    	Blob encryptedValue = EncodingUtil.base64decode(RememberMeCookie.getValue());
	  		Blob decryptedValue = Crypto.decryptWithmanagedIV('AES256', EncodingUtil.base64decode('7wsIsQO482gwinalKhw0fW87B0AM/JXP4gFQiEzGMTI='), encryptedValue);
	  		String[] cookieDataAll= decryptedValue.toString().split('##');
	
	    	PageReference homePage = new PageReference(cookieDataAll[2]);
	    	//clear cookie
			RememberMeCookie = new Cookie('RememberMeCookie','',null,0,false);
			ApexPages.currentPage().setCookies(new Cookie[]{RememberMeCookie});
		   return homePage;
    	}else{
    		
    		if(theRedirecturl!=null && Site.getSiteId()!=null){
    			//return the page specified in the parameter
    			return (new PageReference(theRedirecturl));
    		}
			return null;
    	}
    }
    
    private void getURLParameters() {
	    theRedirecturl = System.currentPagereference().getParameters().get('redirecturl');
    }
}