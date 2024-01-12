public class ColissimoService_Handler {
	
	public class ResultClass {
		public Boolean success {get;set;}
		public Integer errorCode {get;set;}
		public String errorMessage {get;set;}
		public v2PointretraitGeopostCom.pointRetraitAcheminement[] listPoints {get;set;}
	}


	public static Boolean checkServiceAvailability() {

		system.debug('>>> Colissimo_Handler: checkServiceAvailability' );
		Boolean ret = false;

		// Instantiate a new http object
	    Http h = new Http();

	     // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint('http://ws.colissimo.fr/supervision-wspudo/supervision.jsp');
	    req.setMethod('GET');

	    // Send the request, and return a response
	    HttpResponse res = h.send(req);
	    system.debug(res.getBody());

	    if (res.getBody().contains('[OK]')) {
	    	ret = true;
	    } 
	    system.debug('>>> Colissimo_Handler: checkServiceAvailability :' + res.getBody() );

	    return (ret);
	}


	public static ResultClass findPickUpStationNearAddress(Integer timeout, String endpoint,String login, String password, String address, String zipCode,String city,String countryCode,
			String weight, String shippingDate, String filterRelay,String requestId, String lang,String optionInter) {
		system.debug('>>> Colissimo_Handler: findPickUpStationNearAddress' );
		system.debug('>>> Colissimo_Handler: findPickUpStationNearAddress : weight :' + weight );
		// Result returned
		ResultClass result = new ResultClass();

		// Check if mandatory fields are there
		if (address == null || zipCode == null || city == null || countryCode == null || weight == null || shippingDate == null ||
			address == '' || zipCode == '' || city == '' || countryCode == '' || weight == '' || shippingDate == '') {
			result.success = false; result.errorCode = -1; result.errorMessage = Label.Colissimo_MandatoryFieldMissing; return (result);
		}


		// Check service availability
		Boolean available = ColissimoService_Handler.checkServiceAvailability();
		if (!available) {
			result.success = false; result.errorCode = -1; result.errorMessage = Label.Colissimo_Unavailable; return (result);
		}

		v2PointretraitGeopostCom.PointRetraitServiceWSPort service = new v2PointretraitGeopostCom.PointRetraitServiceWSPort();
		service.timeout_x = timeout;
		system.debug('>>>> shippingDate: ' + shippingDate);
		v2PointretraitGeopostCom.rdvPointRetraitAcheminementResult res = service.findRDVPointRetraitAcheminement(endpoint,
			login, password, address, zipCode, city, countryCode, weight, shippingDate, filterRelay, requestId, lang, optionInter);

		//system.debug(res);
		
		system.debug('>>>>>>>> res: ');
		system.debug(res);
		// Parse response
		if (res == null) {
			result.success = false; result.errorCode = -1; result.errorMessage = 'Unknown error happened'; result.listPoints = null;
		}
		// Success
		if (res.errorCode == 0) {
			result.success = true;
			result.errorCode = 0;
			result.errorMessage = '';
			result.listPoints = res.listePointRetraitAcheminement;
			// Put the marker letter in
			
		} else { // Error
			result.success = false; result.errorCode = res.errorCode; result.errorMessage = res.errorMessage; result.listPoints = null;
		}
		system.debug(result);		

		return (result);
	}
}