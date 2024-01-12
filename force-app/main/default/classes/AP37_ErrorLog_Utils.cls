public class AP37_ErrorLog_Utils {
	
	public static final String WHERE_ORDERSTEP1 = 'Order Step 1';
	public static final String WHERE_ORDERSTEP2 = 'Order Step 2';
	public static final String WHERE_ORDERSTEP3 = 'Order Step 3';
	public static final String WHERE_OTHER = 'Other';
	public static final String FEATURE_COLISSIMO = 'Colissimo';
	public static final String FEATURE_CREDITCARD = 'Credit card payment';
	public static final String FEATURE_STOCK = 'Stock Management';
	public static final String FEATURE_OTHER = 'Other';

	public static void add_errorLog(Id orderId, String feature, String location, String request, String message) {

		String oId = orderId;

		Error_log__c log = new Error_log__c();
		log.Where__c = location;
		log.Feature__c = feature;
		if (oId.startsWith('801')) {
			log.LU_Order_LineUp_Related__c = orderId;
		} else {
			log.Order_related__c = orderId;
		}
		log.Request__c = request;
		log.Message__c = message;
		insert log;
	}

	public static Error_log__c create_errorLog(Id orderId, String feature, String location, String request, String message) {
		String oId = orderId;
		Error_log__c log = new Error_log__c();
		log.Where__c = location;
		log.Feature__c = feature;
		if (oId.startsWith('801')) {
			log.LU_Order_LineUp_Related__c = orderId;
		} else {
			log.Order_related__c = orderId;
		}
		log.Request__c = request;
		log.Message__c = message;
		return (log);
	}

}