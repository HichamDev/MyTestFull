public with sharing class lwc16_catalogchoice_ctrl {

    @AuraEnabled(cacheable=true)
    public static List<String> getCatalogList(Id userId) {

        List<String> l_offerTypeName = null;

        String techExternalId = AP1002_Utils_User.getUserCountry(userId) + '%';

        Contact con = AP1002_Utils_User.getConnectedUserContact();

        Set<String> sEligibilitySegmentOfContact = new Set<String>();
        if (con.LU_Eligibility_Groups__c != null && con.LU_Eligibility_Groups__c != '') {
            for (String groupEligibilty : con.LU_Eligibility_Groups__c.split('#')) {
                sEligibilitySegmentOfContact.add(groupEligibilty);
            }
        }

        // displays catalog only for france
        if (techExternalId == 'FRA%') {
            l_offerTypeName = new List<String>();
            for(AggregateResult pbe : [SELECT LU_Offer_type__c 
                                        FROM PriceBookEntry 
                                        WHERE LU_Start_Date__c <= :Date.today()
                                        AND LU_End_Date__c >= :Date.today()
                                        AND IsActive = true 
                                        AND LU_TECH_External_Id__c LIKE :techExternalId
                                        AND (
                                                LU_Eligibility_Segments__c = '*' 
                                                OR LU_Eligibility_Segments__c IN :sEligibilitySegmentOfContact
                                            )
                                        GROUP BY LU_Offer_type__c
                                    ]) {
                l_offerTypeName.add( (String) pbe.get('LU_Offer_type__c') );
            }

            l_offerTypeName.sort();
        }
        
        return l_offerTypeName;
    }

    @AuraEnabled(cacheable=true)
    public static Contact getCurrentContact() {
        return AP1002_Utils_User.getConnectedUserContact();
    }
}