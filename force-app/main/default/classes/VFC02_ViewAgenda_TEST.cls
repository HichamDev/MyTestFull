@isTest(SeeAllData = true)
private class VFC02_ViewAgenda_TEST {
    
/*
// VFC02_ViewAgenda_TEST
----------------------------------------------------------------------
-- - Name          : VFC02_ViewAgenda_TEST
-- - Author        : ASE 
-- - Description   : Test Class for Class VFC02_ViewAgenda 
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 29-AUG-2012  ASE    1.0      Intitial version
----------------------------------------------------------------------
**********************************************************************
 */ 
      
    static testMethod void testAgendaItem_repeatCon() {
        
        System.runAs(createUser('TestManager') ){
        
	        system.debug('>>>>>>>>>>>>>>START OF TEST CLASS testAgendaItem_repeatCon<<<<<<<<<<<<<<<<');
	
	        List<AGI_AgendaItem__c> events = new List<AGI_AgendaItem__c>();
	        
	        Id recTypeAgenda = [select Id from RecordType where DeveloperName =: system.label.AGI00001
	                                                       and SobjectType=: SHW_IBZ_Constants.AGI].Id;
	                                                       
	        AGI_AgendaItem__c agenda1 = new AGI_AgendaItem__c(  RecordTypeId= recTypeAgenda, TaskType__c='Event',Name='Event 1',
	                                                            Start__c= datetime.newInstance(2012, 08, 1, 12, 30, 2), 
	                                                            End__c=datetime.newInstance(2012, 08, 1, 13, 30, 2));
	        //insert agenda1;
	        events.add(agenda1);
	        insert events;
	        
	        
	        system.debug('>>>>>>>>>agenda1 inserted: '+events);
	        account testAccount = new account(TypeLabel__c= 'test', Name= 'test Account', CurrencyIsoCode= 'EUR', AccountType__c= 'Level 2',Country_Code__c='FRA');
	        insert testAccount;
	        
	        List<PER_Period__c> period = new List<PER_Period__c>();
	        
	        Id recTypeBusinessPeriod = [select Id from RecordType 
	                                    where DeveloperName =: system.label.PER00001
	                                    and SobjectType=: SHW_IBZ_Constants.PER].Id;
	                                                       
	        PER_Period__c period1 = new PER_Period__c(  RecordTypeId= recTypeBusinessPeriod,  Name = 'testPeriod', 
	                                                    StartDate__c= system.today(),
	                                                    EndDate__c= system.today()+10, ColourCode__c= 'blue', Account__c= testAccount.id);                                                           
	                                                    
	        period.add(period1);
	        insert period;
	        
	                       
	        Test.startTest();   
	            //new page reference
	            PageReference pageRef1 = Page.VFP02_ViewAgenda;
	            Test.setCurrentPage(pageRef1);          
	            ApexPages.currentPage().getParameters().put('id',events[0].Id);
	            
	            // Instantiate a new controller with all parameters in the page       
	            VFC02_ViewAgenda  controller = new VFC02_ViewAgenda();
	            
	            controller.initializePage();
	            
	            controller.getContactListOptions();
	            
	            controller.getIsError();
	            
	            controller.getSelectedContact();
	            
	            AP02_AgendaItem_Month month1= controller.getMonth();
	            
	            month1.getfirstDate();                       
	            month1.getMonthName();
	            month1.getWeekdayNames();
	            month1.getYearName();
	            
	            controller.getWeeks(); 
	            system.debug('controller.getWeeks: '+controller.getWeeks()); 
	            
	            AP02_AgendaItem_Month.Week w2 = new AP02_AgendaItem_Month.Week();
	            
	            //w2.getStartingDate();
	            //w2.getWeekNumber();
	            //w2.getDays();
	                        
	                       
	            AP02_AgendaItem_Month.Day d3 = new AP02_AgendaItem_Month.Day(system.today(), 8, period);
	            d3.getDate();
	            d3.getFormatedDate();
	           	
	            d3.getDayNumber();
	            d3.getDayOfMonth2();
	            d3.getDayOfMonth();
	            d3.getDayOfYear();
	            d3.getCSSName();

	            controller.next();
	            controller.prev();
	            
	            
	            //AP02_AgendaItem_Event event1= new AP02_AgendaItem_Event(agenda1, 'Contact Name');
	            //event1.getEv();
	            
	            //event1.getFormatedDate();
	            
	       Test.stopTest();
	        
	       // AGI_AgendaItem__c agendaItem = event1.ev; 
	       // string fd= event1.formatedDate;
	       // string expectedFD = '12:30 PM - 1:30 PM';
	               
	       // system.debug('>>>>>>>>>>>>>>>>Actual formatedDate: '+fd);          
	       // system.assertEquals(expectedFD,fd);
        }
             
        
    }
    
    static  User createUser(String sthId){
        
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator'].get(0);  
        
        User u = new User( //STHUniqueID__c= sthId,
                          firstname= 'BR04',
                          lastname='XXXX',
                          Alias='BR04',
                          email = 'BR04@XXXXX.com',
                          username= 'BR04@XXXXX.com', 
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles',
                          TECH_ContactID__c = createDealer('testContact').Id,
                          Phone = '123456789'
                          );
        insert u;
                
        return u;
    }
  
    
    static  Contact createDealer(String sthId){

        Contact contact = new Contact(STHID__c=sthId, AccountId=createAccount(), lastname='br04Contact',firstname='br04Contact', MinOrder__c=50, MinOrderFreeTransportFees__c=50);
        
        insert contact;
       
        return contact;
    }
    
    static Id createAccount(){
    
        String acc_name = 'Test Account BR04';
        
        Account acct = new Account(name=acc_name, Country_Code__c='FRA');
        insert acct;
        
        return acct.Id;
    }
    
    
}