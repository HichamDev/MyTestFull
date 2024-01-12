/**
 * An apex page controller that exposes the site login functionality
 */
global without sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}
    global String theLanguage{get; set;}
     global boolean theErrorMessageLoginFailed{get; set;}
     global boolean theErrorMessageBlank{get; set;}
     global boolean theErrorMessageLoginLockedOut{get; set;}
     global boolean rememberMe{get; set;}
    
    global SiteLoginController () {
        resetAllErrors();
        rememberMe=false;
    }
    global void resetAllErrors(){
        this.theErrorMessageLoginFailed=false;
        this.theErrorMessageBlank=false;
        this.theErrorMessageLoginLockedOut=false;
    }
    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        
        PageReference portalLoginPage = null;
        
        //String startUrl = system.label.site_login_startUrl;
        
        System.debug('###############startUrl : '+ startUrl);
        
        PageReference pageReference;
        
        if(String.isBlank(username) || String.isBlank(password)){
            
            //either username or password blank
            
            resetAllErrors(); theErrorMessageBlank=true;
            
        }else{
            
            pageReference = Site.login(username, password, startUrl);
            
            if(pageReference==null){
                String loginStatus='';
                List<LoginHistory> lastLoginList = new List<LoginHistory>();
	        	lastLoginList = [select Id, UserId, LoginTime, Status from LoginHistory where UserId in (select id from User where Username= : username) order by LoginTime desc limit 1];
	        	loginStatus= lastLoginList==null || lastLoginList.size()==0 ? '' : lastLoginList[0].Status;
				
				if(loginStatus.equals('Password Lockout')){
                    //user has been locked out
                    resetAllErrors(); theErrorMessageLoginLockedOut=true;
                }else{
                    //user login attempt failed
                    resetAllErrors();
                    theErrorMessageLoginFailed=true;
                }
                
                //ApexPages.getMessages().clear();
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'username or password incorrect. please try again'));
                return null;
                
            }else if(rememberMe) {
                // creates encrypted cookie if cookie doesn't exist
                Cookie RememberMeCookie = ApexPages.currentPage().getCookies().get('RememberMeCookie');
                String cookieData=username+'##'+password+'##'+Site.getCurrentSiteUrl();
                Blob encryptedValue = Crypto.encryptWithManagedIV('AES256', EncodingUtil.base64decode('7wsIsQO482gwinalKhw0fW87B0AM/JXP4gFQiEzGMTI='), Blob.valueOf(cookieData));
                if (RememberMeCookie == null) { RememberMeCookie = new Cookie('RememberMeCookie',EncodingUtil.base64encode(encryptedValue),null,7776000,false); }
                // Set the new cookie for the page
                ApexPages.currentPage().setCookies(new Cookie[]{RememberMeCookie});
            }else{
                //login as usual
            }
        }
        return pageReference; 
    }
    
    @IsTest(SeeAllData=true) global static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'dealer@stanhome.fr.dev';
        controller.password = 'welcome2'; 
                
        System.assertEquals(controller.login(),null);   
        controller.theLanguage='fr';  
        controller.getURLParameters();   
        controller.username = 'dealer@stanhome.fr.dev';
        controller.password = 'blabla';  
        controller.login();              
    }    
    //pass language as parameter lang
    private void getURLParameters(){
      
      try { 
      
          theLanguage = System.currentPagereference().getParameters().get('lang');
          
        }catch(Exception e) { theLanguage='fr'; }
    }
}