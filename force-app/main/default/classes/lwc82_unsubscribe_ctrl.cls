/******************************************************************************
*   @author Simon Gourreau
*   @date 31/07/2020
*   @description Unsubscribe contact controler
*
*/
public without sharing class lwc82_unsubscribe_ctrl {
    
    /**
     * @description Unsubscribe contact
     * @param String : email
     * @param String : id
     * @return String
     *
     */
    @AuraEnabled
    public static String unsubscribeContact(String pEmail, String pId){
        List<Contact> vListCons = [Select Id 
                                    From Contact 
                                    Where Email = :pEmail 
                                    And RecordType.DeveloperName = :AppConstants.RT_CON_PERSONALCONTACT
                                    And HasOptedOutOfEmail = false
                                    And Id = :pId];

        if(vListCons.size() > 0){
            Contact vCon = vListCons[0];
            vCon.LU_ConsentUnsubscribeDate__c = Datetime.now();
            vCon.HasOptedOutOfEmail = true;
            try {
                Database.update(vCon);
            } catch(DmlException e) {
                return e.getMessage();
            }
        }

        return Label.LU_Unsubscribe_Done;
    }
}