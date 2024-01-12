public without sharing class lwc54_contact_details_invoices_ctrl {
    
    @AuraEnabled
    public static List<INV_Invoice__c> getInvoices(String idContact){

        return [SELECT Name 
                      ,InvoiceDate__c 
                      ,InvoiceNumber__c 
                      ,PaymentDate__c
                      ,Total__c
                      ,toLabel(Status__c)
                      ,LU_Url_Detail_Community__c
                FROM INV_Invoice__c 
                WHERE Dealer__c = :idContact
                ORDER BY InvoiceDate__c DESC
                LIMIT 20000];
    }

    @AuraEnabled
    public static String getUserType(String idContact){
        return [SELECT RecordType.DeveloperName FROM Contact WHERE Id = :idContact].RecordType.DeveloperName;
    }
}