public without sharing class lwc90_list_payroll_tax_slips_ctrl {

    public class WrapperPayroll {
        @AuraEnabled
        public String createdDate {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String contentDocumentID {get;set;}
    }

    @AuraEnabled
    public static List<WrapperPayroll> getPayrollTaxList(){

        String contactId = AP1002_Utils_User.getContactFromUser(UserInfo.getUserId()).Id;

        List<WrapperPayroll> l_wrapperPayroll = new List<WrapperPayroll>();

        Datetime fiveYearsAgo = System.Now().addYears(-5);

        Map<Id, NT_Note__c> m_notes = new Map<Id, NT_Note__c>([SELECT Id, CreatedDate, Name FROM NT_Note__c WHERE Dealer__c = :contactId AND CreatedDate > :fiveYearsAgo ORDER BY CreatedDate DESC]);

        List<ContentDocumentLink> l_contentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :m_notes.keyset()];

        for(NT_Note__c note : m_notes.values()){

            WrapperPayroll wp = new WrapperPayroll();

            wp.name = note.Name;
            wp.createdDate = note.CreatedDate.Date().format();

            for(ContentDocumentLink cdl : l_contentDocumentLink){
                if(cdl.LinkedEntityId == note.Id){
                    wp.contentDocumentID = cdl.ContentDocumentId;
                }
            }

            l_wrapperPayroll.add(wp);
        }

        return l_wrapperPayroll;
    }
}