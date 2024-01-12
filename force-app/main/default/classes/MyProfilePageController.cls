/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.
 */
public with sharing class MyProfilePageController {

    private User user;
    private Contact theContact;
    private boolean isEdit = false;
    
    public User getUser() {
        return user;
    }
    public Contact getContact() {
        return theContact;
    }

    public MyProfilePageController() {
        user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email,TECH_MergeContactID__c
                FROM User
                WHERE id = :UserInfo.getUserId()];
        List<Contact> theQueriedContactList= [SELECT id
                        , ActivityStatus__c
                        , CurrentBalance__c
                        , CurrentBusinessPeriod__c
                        , LastDateToOrder__c
                        , NbOrderForCurrentComCycle__c
                        , PersonalMessage__c
                        , DirectCommissionRate__c
                        , BadDebt__c
                        , CurrentCommercialCycle__c
                        , InvoicingDate__c
                        , MinOrder__c
                        , NoCreditLine__c
                        , TransportFeesApplicable__c
                        , AllowedPaymentMode__c
                        , NbDaysForCreditLine__c
                        , MinOrderFreeTransportFees__c
                        , MailingStreet
                        , MailingState
                        , MailingPostalCode
                        , MailingCountry
                        , MailingCity
                        , MailingAddressComment__c
                        , OtherAddressComment__c
                        , MobilePhone
                        , Phone
                        , Fax
                        , Extension__c
                        , Title
                        , Name
                        , LastOrderDate__c
                        , Account.Name
                        , Birthdate
                        , STHID__c
                        , ReportsToId
                        , Email
                FROM Contact
                WHERE id = :user.TECH_MergeContactID__c limit 1];
        if (theQueriedContactList != null && theQueriedContactList.size() > 0) 
			theContact = theQueriedContactList[0];       
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
    }
    
    public Boolean getIsEdit() {
        return isEdit;
    }
    
    public void edit() {
        isEdit=true;
    }    
    
    public void save() {
        if (user.contact != null) {              
            setContactFields(theContact, user);
        }
        
        try {
            update user;
            if (theContact != null) { 
                update theContact;
            }
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }
    
    public PageReference changePassword() {
        return Page.ChangePassword;
    }
    
    public void cancel() {
        isEdit=false;
        user = [SELECT id, email, username, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
    }
    
    private static void setContactFields(Contact c, User u) {
        /*c.title = u.title;
        c.firstname = u.firstname;
        c.lastname = u.lastname;*/
        c.email = u.email;//uncommented ticket 283181(TMA)+283455(V1.4)
        u.mobilephone = c.mobilephone;//uncommented ticket 283181(TMA)+283455(V1.4)
        /*c.phone = u.phone;
        c.fax = u.fax;
        c.mailingstreet = u.street;
        c.mailingcity = u.city;
        c.mailingstate = u.state;
        c.mailingpostalcode = u.postalcode;
        c.mailingcountry = u.country;*/
    }

    @IsTest(SeeAllData=true) static void testSave() {         
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT id, profileId, userRoleId FROM User WHERE UserRoleId <> null AND UserType='CustomerSuccess'];

        if (existingPortalUsers.isEmpty()) {
            User currentUser = [select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                                FROM User WHERE id =: UserInfo.getUserId()];
            MyProfilePageController controller = new MyProfilePageController();
            System.assertEquals(currentUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
            System.assert(controller.isEdit == false, 'isEdit should default to false');
            controller.edit();
            System.assert(controller.isEdit == true);
            controller.cancel();
            System.assert(controller.isEdit == false);
            
            Contact c = new Contact();
            c.LastName = 'TestContact';
            c.MinOrderFreeTransportFees__c = 100;
            c.STHID__c = 'Test123';
            insert c;
            
            setContactFields(c, currentUser);
            controller.save();
            System.assert(Page.ChangePassword.getUrl().equals(controller.changePassword().getUrl()));
        } else {
            User existingPortalUser = existingPortalUsers[0];
            String randFax = Math.rint(Math.random() * 1000) + '5551234';
            
            System.runAs(existingPortalUser) {
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(existingPortalUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                System.assert(controller.isEdit == false, 'isEdit should default to false');
                controller.edit();
                System.assert(controller.isEdit == true);
                
                controller.cancel();
                System.assert(controller.isEdit == false);
                
                controller.getUser().Fax = randFax;
                controller.save();
                System.assert(controller.isEdit == false);
            }
            
            // verify that the user and contact were updated
            existingPortalUser = [Select id, fax, Contact.Fax from User where id =: existingPortalUser.Id];
            System.assert(existingPortalUser.fax == randFax);
            System.assert(existingPortalUser.Contact.fax == randFax);
        }
    }

}