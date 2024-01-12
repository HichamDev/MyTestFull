public without sharing class AP41_PickUpStationHandler {

    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){

                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }

    public static AP40_MondialRelayWebservice.ret_WSI3_PointRelais_Recherche findPickUpStations(String postalCode, String selectedShippingModeId) {//Shipping_Mode__c selectedShippingMode) {

        String enseigne = '';
        String privateKey = '';
        Integer nbPickUpStationReturned = 0;
        String action = '';
        String countryIsoCode2Char = '';

        if (findObjectNameFromRecordIdPrefix(selectedShippingModeId) == 'LU_Order_Rule__c') {
            LU_Order_Rule__c orShippingMode = [SELECT Id, LU_Country__c, LU_Service_Login__c, LU_Service_Password__c, LU_Service_Param_Text_1__c, LU_Service_Param_Text_2__c
                                                FROM LU_Order_Rule__c
                                                WHERE Id =: selectedShippingModeId
                                                LIMIT 1];
            enseigne = orShippingMode.LU_Service_Login__c;
            privateKey = orShippingMode.LU_Service_Password__c;
            nbPickUpStationReturned = Integer.valueOf(orShippingMode.LU_Service_Param_Text_1__c);
            action = orShippingMode.LU_Service_Param_Text_2__c;
            countryIsoCode2Char = orShippingMode.LU_Country__c.left(2);
            
        } else { // Old order tunnel : custom setting
            Shipping_Mode__c shippingMode = [SELECT Enseigne__c, Cle_privee__c, Action__c, Nombre_de_resultats__c, Country__c, Mode__c
                                            FROM Shipping_Mode__c
                                            WHERE Active__c = true
                                            AND Id =: selectedShippingModeId
                                            LIMIT 1];

            if (shippingMode.Mode__c == 'Standard') { return null ;}

            enseigne = shippingMode.Enseigne__c;
            privateKey = shippingMode.Cle_privee__c;
            nbPickUpStationReturned = Integer.valueOf(shippingMode.Nombre_de_resultats__c);
            action = shippingMode.Action__c;
            countryIsoCode2Char = shippingMode.Country__c;
            
        }

        if(Test.isRunningTest()){
            Test.setMock(WebServiceMock.class, new AP40_MondialRelayWebservice_Mock());
        }

        AP40_MondialRelayWebservice.Web_ServicesSoap ws = new AP40_MondialRelayWebservice.Web_ServicesSoap();
        Blob targetBlob = Blob.valueOf(enseigne + countryIsoCode2Char + postalCode + action + nbPickUpStationReturned + privateKey);//'BDTEST13FR4400024R30PrivateK');
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        String security = EncodingUtil.convertToHex(hash);
        security = security.toUpperCase();
        //System.debug('security: ' + security);
        return ws.WSI4_PointRelais_Recherche(
            enseigne,//'BDTEST13',//String Enseigne,
            countryIsoCode2Char,//'FR',//String Pays,
            '',//String NumPointRelais,
            '',//String Ville,
            postalCode,//'44000',//String CP,
            '',//String Latitude,
            '',//String Longitude,
            '',//String Taille,
            '',//String Poids,
            action,//'24R',//String Action,
            '',//String DelaiEnvoi,
            '',//String RayonRecherche,
            '',//String TypeActivite,
            '',//String NACE,
            nbPickUpStationReturned,//30,//Integer NombreResultats,
            security//String Security
        );
    }
}