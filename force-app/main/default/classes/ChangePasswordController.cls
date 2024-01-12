/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    public String currentURL {get; set;} 
    
    public PageReference changePassword() {
    	PageReference redirectedPage = null;
    	String errorMessage='';
    	if(String.isBlank(newPassword) || String.isBlank(verifyNewPassword) || (Site.isPasswordExpired() ? false : String.isBlank(oldpassword))){
    		errorMessage=errorMessage+((Site.isPasswordExpired() ? false : String.isBlank(oldpassword))? '* '+system.label.site_old_password+' '+system.label.site_changepassword_field_blank+'<br/>' : '')+(String.isBlank(newPassword)? '* '+system.label.site_new_password+' '+system.label.site_changepassword_field_blank+'<br/>' : '')+(String.isBlank(verifyNewPassword)? '* '+system.label.site_verify_new_password+' '+system.label.site_changepassword_field_blank+'<br/>' : '');
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
    	}else{
    		try{
	    	   PageReference changePasswordOK=Site.changePassword(newPassword, verifyNewPassword, oldpassword); 
	    	   System.debug('##changePasswordOK'+ changePasswordOK);
	    	   if(changePasswordOK!=null){
	    	   		redirectedPage = new PageReference(system.label.site_login_startUrl);
	    	   }
	    	}
	       catch(exception e){
	
	        	System.debug('##Error'+ e.getMessage());
	        	
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	        	
	        	return null;
	   		
	   		}
    	}
       
   		return redirectedPage;
    }     
    
   	public ChangePasswordController() {}
    
    public PageReference redirect() {
    	if((ApexPages.currentPage().getParameters().get('lang')==null && Site.getSiteId()!=null) || Test.isRunningTest() ){
		   String currentBaseUrl=URL.getSalesforceBaseUrl().toExternalForm();
		   currentURL = Site.getPathPrefix();
		   system.debug('currentURL:'+currentURL);
		   String language = currentURL==null || currentURL.equals('') ? 'fr' : (currentURL.substring(1,3)=='mx' ? 'es_mx' : currentURL.substring(1,3));
		   String pageLanguage=currentURL==null || currentURL.equals('') ? 'fr' :currentURL.substring(1,3);
		   String redirectedToPageLang=currentBaseUrl+'/'+pageLanguage+'/'+'ChangePassword';
		   //String redirectedToPageLang=currentBaseUrl+'/'+'ChangePassword';
		   PageReference homePage = new PageReference(redirectedToPageLang);
		   homePage.getParameters().put('lang', language);
		  return homePage;
	   }
	   currentURL = ApexPages.currentPage().getParameters().get('lang');
	   return null;
    }
    
   	@IsTest(SeeAllData=true) public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);  
           
        controller.oldPassword = '';
        controller.newPassword = ''; 
        controller.verifyNewPassword = '';   
        controller.changePassword();
        controller.redirect();                      
    }    
}