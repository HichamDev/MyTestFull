global class ColissimoService_HttpMock implements WebServiceMock, HttpCalloutMock  {

   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

   		pointretraitGeopostCom.Conges cong = new pointretraitGeopostCom.Conges();
   		cong.calendarDeDebut = Datetime.now();
   		cong.calendarDeFin = Datetime.now().addDays(5);
   		cong.numero = 1;
   		cong.formatDebut();
   		cong.formatFin();
   		
        v2PointretraitGeopostCom.pointRetraitAcheminement pt1 = new v2PointretraitGeopostCom.pointRetraitAcheminement();
        pt1.accesPersonneMobiliteReduite = true;
        pt1.adresse1 = '24 mail pablo picasso';
        pt1.codePostal = '44000';
        pt1.congesPartiel = false;
        pt1.congesTotal = true;
        pt1.coordGeolocalisationLatitude = '47.2149102';
        pt1.coordGeolocalisationLongitude = '-1.537473699999964';
        pt1.listeConges = new List<pointretraitGeopostCom.Conges>();
        pt1.listeConges.add(cong);
        pt1.distanceEnMetre = 100;
        pt1.identifiant = '19199284';
        pt1.localite = 'Nantes';
        pt1.nom = 'IK';
        pt1.typeDePoint = 'A2P';
        pt1.codePays = 'FR';
        pt1.libellePays = 'France';

        v2PointretraitGeopostCom.rdvPointRetraitAcheminementResult res = new v2PointretraitGeopostCom.rdvPointRetraitAcheminementResult();
        res.errorCode = 0;
        res.errorMessage = 'Code retour OK';
        res.listePointRetraitAcheminement = new List<v2PointretraitGeopostCom.pointRetraitAcheminement>();
        res.listePointRetraitAcheminement.add(pt1);
        res.qualiteReponse = 1;
        res.wsRequestId = 'requestTest1878';
        res.rdv = false;

        v2PointretraitGeopostCom.findRDVPointRetraitAcheminementResponse result = new v2PointretraitGeopostCom.findRDVPointRetraitAcheminementResponse();
        result.return_x = res;

        response.put('response_x', result); 
   	}

   	global HTTPResponse respond(HTTPRequest req) {
        HttpResponse ret = new HTTPResponse();
        ret.setBody('[OK]');
        ret.setStatusCode(200);
        return (ret);
    }
}