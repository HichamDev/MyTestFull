public class C08_PaylinePayment_Ctr_Italy {


	public static String param_orderId {get;set;}
	public static Boolean param_approved {get;set;}

	public static Boolean isError {get;set;}

	public static Boolean isInit {get;set;}

	public static ORD_Order__c order {get;set;}

	public static Decimal amount {get;set;}
	public static Integer amountPayline {get;set;}

	public static String status {get;set;}
	public static String message {get;set;}

	public static VFC01_OrderRecap_Italy ctrlParent {get;set;}

	public static STHEndpoints__c serviceConfig {get;set;}

	// public PageReference initComponent() {
	public void initComponent() {
		
        try
		{
			if (ctrlParent != null) {ctrlParent.displayValidateOrderBtn = false; ctrlParent.isCardInitialized = true;}
			isInit = false;
			isError = false;
			status = 'NONE';
			message = '';

			param_orderId = ApexPages.currentPage().getParameters().get('orderId');

			order = [SELECT Id, TECH_ExternalId__c, Dealer__c, TECH_TotalPrice__c, TotalCommision__c, Taxes__c, TECH_TotalPriceWithTax__c, TotalAmountToPayOnScreen__c,
							TotalAdministrativeFee__c, TransportFees__c, PaymentTransactionId__c, Payment_Transaction_Status__c, Payment_Transaction_Message__c,
							Payment_Transaction_Details_Date__c, Payment_Transaction_Token__c, LocalAttribute10__c , Dealer__r.AccountCountryCode__c, Payment_Transaction_Reset__c 
					FROM ORD_Order__c
					WHERE Id =: param_orderId];
            system.debug('>>> ORDER init: ' + order);

			serviceConfig = [SELECT Id, Card_Payment_Endpoint__c, Card_Payment_Merchant_Id__c, Card_Payment_API_Key__c, Card_Payment_Shop_Id__c, Card_Payment_Coef__c,
							Card_Payment_Max_Amount_Allowed__c 
	                       	FROM STHEndpoints__c
	                        WHERE Name = 'ITA' ];

	        // Calculate amount to pay
			calculateAmount();

			// Check if the amount is ok for card payment
			if (amount > serviceConfig.Card_Payment_Max_Amount_Allowed__c) {

				status = 'AMOUNTNOTALLOWED';
				message = Label.ORD00312 + ' ' + serviceConfig.Card_Payment_Max_Amount_Allowed__c + ' €';
				if (ctrlParent != null) {ctrlParent.paymentStatus = 'AmountNotAllowed';}
				isInit = true;
				
			} else {

				// If the status = None (first time on the step 3)
				if (order.Payment_Transaction_Status__c == 'None') {
					
					// Do the webservice callout to create the payment
					isInit = initPayment();

				} else {
					system.debug('>>> test amount : ' + amount);
                    system.debug('>>> test order.LocalAttribute10__c : ' + order.LocalAttribute10__c);
					// If the amount changed, then reset the transaction and create a new one
					if (amount != Decimal.valueOf(order.LocalAttribute10__c)) {
						AP36_Payline_Handler.Result res = AP36_Payline_Handler.ws_doReset(order.Id, false);
		          		if (res.isSuccess == false) {
		          			AP37_ErrorLog_Utils.add_errorLog(order.Id, AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
												'Reset Transaction because amount changed : ' + order.Payment_Transaction_Token__c , res.code = ' : ' + res.message);
		          		} else {
		          			// Init the payment to represent the new amount
		          			isInit = initPayment();
		          		}
					} else {
						// Check status
						checkStatus();
						isInit = true;
					}
				}

			}

		} catch (Exception e) {
            system.debug('>>>>>> EXCEPTION Init card payment component: ' + e.getMessage());
			AP37_ErrorLog_Utils.add_errorLog(order.Id, AP37_ErrorLog_Utils.FEATURE_CREDITCARD, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 
											'Init card payment component : ' + order.Payment_Transaction_Token__c , e.getMessage());
		}
		


		// return (null);
	}

	

	public static void checkStatus() {
 
		if (order.Payment_Transaction_Status__c == 'Draft') {

			// Calculate the amount of the transaction
			calculateAmount();

			// Do the callout to get payment status
			AP36_Payline_Handler.Result res = AP36_Payline_Handler.ws_getPaymentDetails(param_orderId);
			ORD_Order__c ord = [SELECT Id, LastModifiedDate FROM ORD_Order__c WHERE Id = :param_orderId];
			if (ctrlParent != null) {
				ctrlParent.globalOrderLastModifiedDate = ord.LastModifiedDate; 
			}
		
			// Parse the result
			if (res.isSuccess == true) {

				if (res.code == '00000') {
					status = 'APPROVED'; message = res.message;
					if (ctrlParent != null) {ctrlParent.displayValidateOrderBtn = true;}
					if (ctrlParent != null) {ctrlParent.paymentStatus = 'Approved';}

				} else if (res.code == AP36_Payline_Handler.PAYMENTDETAILS_MISSINGCARD ) {
					isInit = true; status = 'DRAFT';
					if (ctrlParent != null) {ctrlParent.paymentStatus = 'Draft';}
				} else {
					status = 'REFUSED'; message = res.message;
					if (ctrlParent != null) {ctrlParent.paymentStatus = 'Refused';}
				}
			} else { 

				if (res.code == AP36_Payline_Handler.PAYMENTDETAILS_NOTREDIRECTED) {
					isInit = true; status = 'DRAFT'; if (ctrlParent != null) {ctrlParent.paymentStatus = 'Draft';}
				} else {
                    system.debug('>>>>>> ERROR getwebpaymentdetails : ' + res.message);
					status = 'ERROR';
					message = (res.code == 'EXCEPTION' ? Label.ORD00307 : res.message);
                    if (ctrlParent != null) {ctrlParent.paymentStatus = 'Error';}
				}

			}

			
		} else if (order.Payment_Transaction_Status__c == 'Approved') {
			status = 'APPROVED';
			message = order.Payment_Transaction_Message__c;
			if (ctrlParent != null) {ctrlParent.paymentStatus = 'Approved';}
            if (ctrlParent != null) {ctrlParent.displayValidateOrderBtn = true; ctrlParent.paymentChoice = 'CARD';}
		} else if (order.Payment_Transaction_Status__c == 'Refused') {
			status = 'REFUSED';
			message = order.Payment_Transaction_Message__c;
			if (ctrlParent != null) {ctrlParent.paymentStatus = 'Refused'; ctrlParent.paymentChoice = 'CARD';}
		} else if (order.Payment_Transaction_Status__c == 'Error') {
			status = 'ERROR';
			message = Label.ORD00307;
			if (ctrlParent != null) {ctrlParent.paymentStatus = 'Error'; ctrlParent.paymentChoice = 'CARD';}
		}

	}

	public static void calculateAmount() {

		// Calculate the amount to send to Payline service
		// Arrondi (Montant HT - Commission  + TVA + Retenue + Frais de transport) * Coef)

		// Decimal total = order.TECH_TotalPrice__c + order.TotalCommision__c + order.Taxes__c + order.TotalAdministrativeFee__c + order.TransportFees__c;
		Decimal total = order.TotalAmountToPayOnScreen__c + order.TransportFees__c;
		total = total * serviceConfig.Card_Payment_Coef__c;
		total = total.setScale(2, System.RoundingMode.HALF_UP);

		// Amount payline : 100 = 1€
		amountPayline = Integer.valueOf(total * 100);
		amount = total;

	}

	public static Boolean initPayment() {
		
        system.debug('>>> initPayment : order.Id : ' +order.Id);
		system.debug('>>> initPayment : amountPayline : ' +amountPayline);
		system.debug('>>> initPayment : order.Dealer__r.AccountCountryCode__c : ' +order.Dealer__r.AccountCountryCode__c);

        AP36_Payline_Handler.Result ret = AP36_Payline_Handler.ws_doWebPayment(order.Id, amountPayline, order.Dealer__r.AccountCountryCode__c);
		if (ret.isSuccess) {

			order = [SELECT Id, TECH_ExternalId__c, Dealer__c, TECH_TotalPrice__c, TotalCommision__c, Taxes__c, TECH_TotalPriceWithTax__c, 
							TotalAdministrativeFee__c, TransportFees__c, PaymentTransactionId__c, Payment_Transaction_Status__c, Payment_Transaction_Message__c,
							Payment_Transaction_Details_Date__c, Payment_Transaction_Token__c, LocalAttribute10__c , Dealer__r.AccountCountryCode__c, LastModifiedDate
						FROM ORD_Order__c
						WHERE Id =: order.Id];
			isInit = true;
			status = 'DRAFT';
			if (ctrlParent != null) {
				ctrlParent.paymentStatus = 'Draft'; 
				ctrlParent.globalOrderLastModifiedDate = order.LastModifiedDate; 
			}

		}
		else {
			system.debug('>>>>>> ERROR dowebpayment : ' + ret.message);
			isError = true;
			isInit = false;
			message = (ret.code == 'EXCEPTION' ? Label.ORD00307 : ret.message );
			if (ctrlParent != null) {ctrlParent.paymentStatus = 'Error';}
		}

		return (ret.isSuccess);
	}
 
	public PageReference navigateToPaymentPage() {

		PageReference pageRef = new PageReference('/apex/VFP01_OrderRecap_PaylinePage');
		pageRef.getParameters().put('token', order.PaymentTransactionId__c);
		pageRef.setRedirect(true);

		return (pageRef);
	}

}