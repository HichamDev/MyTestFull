@isTest
private class VFC07_AgendaPeriod_TEST { 
    
    static testMethod void testAgendaPeriod() {
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
            ApexPages.currentPage().getParameters().put('id',period[0].Id);
            
            // Instantiate a new controller with all parameters in the page      
            VFC07_AgendaPeriod  controller = new VFC07_AgendaPeriod();
            list <PER_Period__c> period2 = controller.periodList;            
        Test.stopTest();
        
        
        list<PER_Period__c> period4 = [select id, RecordTypeId from PER_Period__c where RecordTypeId  = :recTypeBusinessPeriod];
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>period4[0].RecordTypeId: '+period4[0].RecordTypeId);
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>period2[0].RecordTypeId: '+period2[0].RecordTypeId);
        system.assertEquals(period4[0].RecordTypeId,period2[0].RecordTypeId );    
             
                      
  }
}