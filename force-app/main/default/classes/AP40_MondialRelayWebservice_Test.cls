@isTest
private class AP40_MondialRelayWebservice_Test {
    
    @isTest 
    static void mondialRelayWebservice_Test() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new AP40_MondialRelayWebservice_Mock());
        
        // Call the method that invokes a callout
        // String output = WebSvcCallout.callEchoString('Hello World!');

        AP40_MondialRelayWebservice.Web_ServicesSoap ws = new AP40_MondialRelayWebservice.Web_ServicesSoap();
        Blob targetBlob = Blob.valueOf('BDTEST13FR4400024R30PrivateK');
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        String security = EncodingUtil.convertToHex(hash);
        security = security.toUpperCase();
        System.debug('security: ' + security);
        AP40_MondialRelayWebservice.ret_WSI3_PointRelais_Recherche test = ws.WSI4_PointRelais_Recherche(
            'BDTEST13',//String Enseigne,
            'FR',//String Pays,
            '',//String NumPointRelais,
            '',//String Ville,
            '44000',//String CP,
            '',//String Latitude,
            '',//String Longitude,
            '',//String Taille,
            '',//String Poids,
            '24R',//String Action,
            '',//String DelaiEnvoi,
            '',//String RayonRecherche,
            '',//String TypeActivite,
            '',//String NACE,
            30,//Integer NombreResultats,
            security//String Security
        );
        
        // Verify that a fake result is returned
        System.assertEquals('LE COMPTOIR DE LA RUE DU PORT', test.PointsRelais.PointRelais_Details[0].LgAdr1); 
    }
}