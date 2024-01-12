@isTest
public with sharing class lwc90_list_payroll_tax_slips_test {
    
    @IsTest
    public static void testGetPayrollTaxList(){

        User u = AP01_TestDataFactory.createPortalUser();
        u.TECH_ExternalId__c = 'FRA';
        insert u;

        u = [SELECT Id, TECH_MergeContactID__c FROM User WHERE Id = :u.Id];

        NT_Note__c note = new NT_Note__c(
            Name = 'testmb',
            Dealer__c = u.TECH_MergeContactID__c
        );
        insert note;

        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = note.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        
        System.runAs(u){
            List<lwc90_list_payroll_tax_slips_ctrl.WrapperPayroll> l = lwc90_list_payroll_tax_slips_ctrl.getPayrollTaxList();
        }
    }
}