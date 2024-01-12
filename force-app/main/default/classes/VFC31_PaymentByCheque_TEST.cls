@isTest
public class VFC31_PaymentByCheque_TEST
{
    static list<Account> accountList;
    static list<Contact> contactList;
    static Id contactDealerRecordTypeID, DealerProfileId;

    static testMethod void VFC31_PaymentByCheque_TEST()
    {
        System.Debug('## >>>>> Start VFC31_PaymentByCheque_TEST >>> Inserting Data for Tests <<<<<' + UserInfo.getUserName());
        
        try
        {
            String  nextPage = '';
            
            //Retrieving Record Type related to Contact
            contactDealerRecordTypeID = [Select r.id From RecordType r Where DeveloperName = :system.label.CON00003 and SObjectType = 'Contact' Limit 1].id;
            system.debug('>>>>>> contactDealerRecordTypeID : ' + contactDealerRecordTypeID);
           
            //Retrieving Profile Ids
            DealerProfileId = [select id from Profile where Name= :system.label.CON00001].Id;
            system.debug('>>>>>> DealerProfileId : ' + DealerProfileId);
    
                    //Creating new accounts
            accountList = new List<Account>{
                new Account(Name='AccountTest1'
                            , AccountType__c = 'Level 2'
                            , TypeLabel__c = 'Test1'
                            , Country_Code__c ='FRA'
                            ),
                new Account(Name='AccountTest2'
                            , AccountType__c = 'Level 2'
                            , TypeLabel__c = 'Test2'
                            , Country_Code__c = 'FRA'
                            )
            };
            insert (accountList);
            system.debug('>>>>>> accountList : ' + accountList);
            
            //Creating new contacts
            contactList = new List<Contact>{
                new Contact(RecordTypeId = contactDealerRecordTypeID
                            , LastName = 'ContactTest1'
                            , Birthdate = system.Today() - 3650
                            , email = 'a@test1.com'
                            , STHID__c = 'test1'
                            , AccountId = accountList[0].id
                            , CurrentBalance__c = 100
                            , MinOrder__c=50
                            , MinOrderFreeTransportFees__c=50),
                new Contact(RecordTypeId = contactDealerRecordTypeID
                            , LastName = 'ContactTest2'
                            , Birthdate = system.Today() - 7300
                            , email = 'a@test2.com'
                            , STHID__c = 'test2'
                            , AccountId = accountList[1].id
                            , CurrentBalance__c = -5
                            , MinOrder__c=50
                            , MinOrderFreeTransportFees__c=50
                            , AllowedPaymentMode__c = 'Cash'),
                new Contact(RecordTypeId = contactDealerRecordTypeID
                            , LastName = 'ContactTest3'
                            , Birthdate = system.Today() - 7300
                            , email = 'a@test3.com'
                            , STHID__c = 'test3'
                            , AccountId = accountList[1].id
                            , CurrentBalance__c = -5
                            , MinOrder__c=50
                            , MinOrderFreeTransportFees__c=50
                            , AllowedPaymentMode__c = 'Cheque')                                  
            };
            insert (contactList);
            system.debug('>>>>>> contactList : ' + contactList);
    
            Contact c2 = [SELECT Id, AllowedPaymentMode__c FROM Contact WHERE LastName = 'ContactTest3'];
            
            RecordType rtCheque = [SELECT Id FROM RecordType WHERE Name = 'cheque' LIMIT 1];
            
            test.startTest();   
            PageReference pageRef = Page.VFP31_PaymentByChequeManagers; 
            Test.setCurrentPage(pageRef);
            
            VFC31_PaymentByCheque controller = new VFC31_PaymentByCheque();
            
            // Fail
            controller.pc = new STA_Statement__c();
            controller.contactId = null;
            controller.pc.Cheque_Date__c = null;
            controller.pc.Cheque_Amount__c=null;
            controller.pc.Contact__c=null;
            
            try
            {
                controller.savePaymentByChequeManagers();
            } catch (Exception e)
            { }
            
            
            
           
            controller.pc = new STA_Statement__c();
            controller.pc.Contact__c= c2.Id;
            controller.pc.Cheque_Amount__c = 12.00;
            controller.pc.Cheque_Date__c = Date.newInstance(2013, 12, 12);
            controller.sthid = 'test3';
            
            controller.ChangeDealerDetails();
            
            
            
            /* Test Method: savePaymentByCheque(); */
            // Success
            controller.savePaymentByChequeManagers();
            
            
            try
            {
                STA_Statement__c sta2 = [SELECT Id FROM STA_Statement__c WHERE Contact__c =: c2.Id AND RecordTypeId =: rtCheque.Id LIMIT 1];
            } catch (Exception e)
            {
                // If le SOQL request returns no result, the insertion failed.
                system.assert(false, 'Payment By Cheque not inserted.');
            }
            
           
            
            
            
            // Fail
            controller.contactId = null;
            controller.pc = null;
            
            try
            {
                controller.savePaymentByChequeManagers();
            } catch (Exception e)
            { }
            
            
            
            
            /* Test Method: savePaymentByChequeAndNew(); */
            // Success
            
            controller.pc = new STA_Statement__c();
            controller.pc.Contact__c = c2.Id;
            controller.pc.Cheque_Amount__c = 12.00;
            controller.pc.Cheque_Date__c = Date.newInstance(2013, 12, 12);
            nextPage = controller.savePaymentByChequeAndNewManagers().getUrl();
            //System.assertEquals('/apex/VFP31_PaymentByChequeNew', nextPage);
            STA_Statement__c sta3;
            try
            {
                sta3 = [SELECT Id FROM STA_Statement__c WHERE Contact__c =: c2.Id AND RecordTypeId =: rtCheque.Id LIMIT 1];
            } catch (Exception e)
            {
                // If le SOQL request returns no result, the insertion failed.
                system.assert(false, 'Payment By Cheque not inserted.');
            }           
            // Fail
            controller.contactId = null;
            controller.pc = new STA_Statement__c();
            try
            {
                controller.savePaymentByChequeAndNewManagers();
            } catch (Exception e)
            { }
            
            
            /* Test Method: cancel(); */
            nextPage = controller.cancel().getUrl();
            //System.assertEquals('/apex/vfp31_paymentbycheque', nextPage);
            
            
            /* Test Method: getChequePayments */
            // success
            controller.contactId = c2.Id;
            List<STA_Statement__c> lSta = controller.getChequePayments();
            system.assert(lSta.size() != 0, 'Fail to list the Payment by cheque.');
            // fail
            controller.contactId = null;
            try
            {
                controller.getChequePayments();
            } catch (Exception e)
            { }
            
            
            /* Test Method: getPbc() */
            //system.assert(controller.getPbc() != null, 'Failed to get the Statement object out of the Controller');
            
            
            /* Test Method: getisAllowedToPayByCheque() */
            controller.contactId = c2.Id;
            system.assert(controller.getisAllowedToPayByCheque(), 'Should be allowed to pay by cheque');
            c2.AllowedPaymentMode__c = '';
            update c2;
            system.assert(!controller.getisAllowedToPayByCheque(), 'Should not be allowed to pay by cheque');
            controller.contactId = null;
            system.assert(!controller.getisAllowedToPayByCheque(), 'Contact null: nothing to return.');
            
            
            /* Test Method: getNumberCurrencyFormat() */
            system.assert(controller.getNumberCurrencyFormat() != '', 'Failed to return the Currency Format');
            
            
            /* Test Method: VFC31_PaymentByCheque(ApexPages.StandardController); */
            ApexPages.CurrentPage().getparameters().put('id', sta3.Id);
            ApexPages.StandardController sc = new ApexPages.standardController(sta3);
            VFC31_PaymentByCheque controllerS = new VFC31_PaymentByCheque(sc);
            system.assert(controllerS != null, 'Failed to create object PaymentByCheque with StandardController');
            
            
            ApexPages.CurrentPage().getparameters().put('id', sta3.Id);
            VFC31_PaymentByCheque controllerdelete = new VFC31_PaymentByCheque();
            controllerdelete.editPaymentByChequeManagers();
            ApexPages.CurrentPage().getparameters().put('id', sta3.Id);
            controllerdelete.deletePaymentByChequeManagers();
            
            controllerdelete.deletePaymentByChequeManagers();

            test.stopTest();
        }
        catch (Exception e)
        {
            // An unwanted error occured
            system.assert(false, 'An unwanted error occured: ' + e.getMessage());
        }
    }    
}