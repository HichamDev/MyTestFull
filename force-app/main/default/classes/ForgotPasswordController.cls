/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController {
    public String username {get; set;}   
    public String currentURL {get; set;}  
    public String thePageLanguage {get; set;} 
    public String blabl {get; set;} 
    public ForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.ForgotPasswordConfirm;
  		pr.getParameters().put('lang', currentURL);
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
  	public PageReference redirect() {
  		currentURL = Site.getPathPrefix();
  		String language=currentURL==null || currentURL.equals('') ? 'fr' : ( currentURL.substring(1,3)=='mx'? 'es_mx' : currentURL.substring(1,3));
    	if(ApexPages.currentPage().getParameters().get('lang')==null && Site.getSiteId()!=null || Test.isRunningTest() ){
		   String currentBaseUrl=URL.getSalesforceBaseUrl().toExternalForm();
		   currentURL = Site.getPathPrefix();
		   language=currentURL==null || currentURL.equals('') ? 'fr' : ( currentURL.substring(1,3)=='mx'? 'es_mx' : currentURL.substring(1,3));
		   thePageLanguage=currentURL==null || currentURL.equals('') ? 'fr' : currentURL.substring(1,3);
		   String redirectedToPageLang=currentBaseUrl+'/'+thePageLanguage+'/'+'ForgotPassword';
		   //String redirectedToPageLang=currentBaseUrl+'/'+'ForgotPassword';
		   PageReference homePage = new PageReference(redirectedToPageLang);
		   homePage.getParameters().put('lang', language);
		  return homePage;
	   }
	   currentURL = language;
	   return null;
    }
    
  	 @IsTest(SeeAllData=true) public static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    	controller.redirect();
    }
}