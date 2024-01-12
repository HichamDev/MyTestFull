@isTest
private class VFC01_AutoCompleteController_France_TEST {
/*
----------------------------------------------------------------------
-- - Name          : VFC01_OrderBasket_TEST 
-- - Author        : AMU
-- - Description   : This class contains unit tests for validating the 
--                   behavior of controller VFC01_OrderBasket
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 12-NOV-2012  AMU    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/
    static testMethod void autoCompleteTest() {
        System.Debug('## >>>>> Start VFC01_AutoCompleteController_TEST >>> autoCompleteTest <<<<<'+UserInfo.getUserName());
        
        //Test all posibilities
        List<SObject> SObjectList = new list<SObject>();        
        SObjectList = VFC01_AutoCompleteController_France.findSObjects('CTA_CatalogArticle__c', 'Sham','Id','System','Online', null);
        SObjectList = VFC01_AutoCompleteController_France.findSObjects('CTA_CatalogArticle__c', 'Sham','Id','System','Offline', null);
        system.debug('>>>>>>>>SObjectList : ' + SObjectList);
    }
}