@IsTest
public class LWC03_EmailForm_Ctrl_Test {

    @IsTest
    static void testGetCurrentContact() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        LWC03_EmailForm_Ctrl.BackgroundImage bck = new LWC03_EmailForm_Ctrl.BackgroundImage();

        System.RunAs(u){
            LWC03_EmailForm_Ctrl.getCurrentContact();
        }
    }

    @IsTest
    static void testSearch() {

        String userId = AP01_TestDataFactory.createPortalUserWithClients();

        User u = [SELECT Id FROM User WHERE Id = :userId];

        System.RunAs(u){
            LWC03_EmailForm_Ctrl.search(Label.LU_TECH_Contact_Team, 'Jibz', new List<String>());
            LWC03_EmailForm_Ctrl.search('Clients', 'Jibz', new List<String>());
        }
    }

    @IsTest
    static void testSendEmailUser() {

        String userId = AP01_TestDataFactory.createPortalUserWithClients();

        User u = [SELECT Id FROM User WHERE Id = :userId];

        List<AP1002_LookupSearchResult> l_sentTo = new List<AP1002_LookupSearchResult>();

        for(Contact c : [SELECT Id, LastName FROM Contact]){
            AP1002_LookupSearchResult lsr = new AP1002_LookupSearchResult();
            lsr.id = c.Id;
            lsr.title = c.LastName;
            l_sentTo.add(lsr);
        }

        ContentVersion cv = new ContentVersion();
        cv.Title = 'title cv';
        cv.PathOnClient = 'abc';
        cv.VersionData = Blob.valueof('azertyuiop');
        insert cv;

        cv = [SELECT ContentDocumentId FROM ContentVersion];

        List<String> l_idCd = new List<String>();
        l_idCd.add(cv.ContentDocumentId);

        System.RunAs(u){
            LWC03_EmailForm_Ctrl.sendEmail('Subject', 'body', l_sentTo, l_idCd, true, Label.LU_TECH_Contact_Team);
        }
    }

    @IsTest
    static void testSendEmailContact() {

        String userId = AP01_TestDataFactory.createPortalUserWithClients();

        User u = [SELECT Id FROM User WHERE Id = :userId];

        List<AP1002_LookupSearchResult> l_sentTo = new List<AP1002_LookupSearchResult>();

        for(Contact c : [SELECT Id, LastName FROM Contact]){
            AP1002_LookupSearchResult lsr = new AP1002_LookupSearchResult();
            lsr.id = c.Id;
            lsr.title = c.LastName;
            l_sentTo.add(lsr);
        }

        ContentVersion cv = new ContentVersion();
        cv.Title = 'title cv';
        cv.PathOnClient = 'abc';
        cv.VersionData = Blob.valueof('azertyuiop');
        insert cv;

        cv = [SELECT ContentDocumentId FROM ContentVersion];

        List<String> l_idCd = new List<String>();
        l_idCd.add(cv.ContentDocumentId);

        System.RunAs(u){
            LWC03_EmailForm_Ctrl.sendEmail('Subject', 'body', l_sentTo, l_idCd, true, Label.LU_TECH_Contact_RT_Customer);
        }
    }

    @IsTest
    static void testDeleteContentDocument() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'title cv';
        cv.PathOnClient = 'abc';
        cv.VersionData = Blob.valueof('azertyuiop');
        insert cv;

        cv = [SELECT ContentDocumentId FROM ContentVersion];

        List<String> l_idCd = new List<String>();
        l_idCd.add(cv.ContentDocumentId);

        System.RunAs(u){
            LWC03_EmailForm_Ctrl.deleteContentDocument(l_idCd);
        }
    }

    @IsTest
    static void testgetEmailTemplate() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        System.RunAs(u){
            LWC03_EmailForm_Ctrl.getEmailTemplate();
        }
    }
    @IsTest
    static void testgetEmailTemplateBackgroundImages() {

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA_00009999';
        insert u;

        System.RunAs(u){
            LWC03_EmailForm_Ctrl.getEmailTemplateBackgroundImages();
        }
    }

}