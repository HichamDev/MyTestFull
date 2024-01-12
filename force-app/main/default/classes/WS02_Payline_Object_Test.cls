@isTest
private class WS02_Payline_Object_Test {
	
	@isTest static void test_objects() {
		
		WS02_Payline_Object.bankAccountData bank = new WS02_Payline_Object.bankAccountData();
		bank.countryCode = 'FRA';
		bank.bankCode = 'BNP';
		bank.accountNumber = 'HJDFHJHSDF';
		bank.key = 'JFHDHJ';

		WS02_Payline_Object.extendedCardType ext = new WS02_Payline_Object.extendedCardType();
		ext.country = 'FRA';
		ext.isCvd = 'FRA';
		ext.bank = 'FRA';
		ext.type_x = 'FRA';
		ext.network = 'FRA';
		ext.product = 'FRA';

		WS02_Payline_Object.authorization auth = new WS02_Payline_Object.authorization();
		auth.number_x = 'FRA';
		auth.date_x = 'FRA';

		WS02_Payline_Object.subMerchant subm = new WS02_Payline_Object.subMerchant();
		subm.subMerchantId = 'FRA';
		subm.subMerchantName = 'FRA';
		subm.subMerchantMCC = 'FRA';
		subm.subMerchantSIRET = 'FRA';
		subm.subMerchantTaxCode = 'FRA';
		subm.subMerchantStreet = 'FRA';
		subm.subMerchantCity = 'FRA';
		subm.subMerchantZipCode = 'FRA';
		subm.subMerchantCountry = 'FRA';
		subm.subMerchantState = 'FRA';
		subm.subMerchantEmailAddress = 'FRA';
		subm.subMerchantPhoneNumber = 'FRA';


		WS02_Payline_Object.contractNumberWalletList con = new WS02_Payline_Object.contractNumberWalletList();
		con.contractNumberWallet = new List<String>();
		con.contractNumberWallet.add('TEST');

		WS02_Payline_Object.cardOut card = new WS02_Payline_Object.cardOut();
		card.number_x = 'FRA';
		card.type_x = 'FRA';
		card.expirationDate = 'FRA';
		card.cardholder = 'FRA';
		card.token = 'FRA';

		WS02_Payline_Object.recurring rec = new WS02_Payline_Object.recurring();
		rec.firstAmount = 'FRA';
		rec.amount = 'FRA';
		rec.billingCycle = 'FRA';
		rec.billingLeft = 'FRA';
		rec.billingDay = 'FRA';
		rec.startDate = 'FRA';
		rec.endDate = 'FRA';
		rec.newAmount = 'FRA';
		rec.amountModificationDate = 'FRA';

		WS02_Payline_Object.fraudResultDetails fr = new WS02_Payline_Object.fraudResultDetails();
		fr.code = 'FRA';
		fr.shortMessage = 'FRA';
		fr.longMessage = 'FRA';

		WS02_Payline_Object.privateData pr = new WS02_Payline_Object.privateData();
		pr.key = 'FRA';
		pr.value = 'dsg';


		WS02_Payline_Object.billingRecord b = new WS02_Payline_Object.billingRecord();
		b.date_x = 'FRA';
		b.amount = 'FRA';
		b.status = 'FRA';
		b.result = new WS02_Payline_Object.result();
		b.transaction_x = new WS02_Payline_Object.transaction_x();
		b.authorization = new WS02_Payline_Object.authorization();
		b.nbTry = 'FRA';
		b.rank = 'FRA';


		WS02_Payline_Object.paymentAdditionalList pal = new WS02_Payline_Object.paymentAdditionalList();
		pal.paymentAdditional = new List<WS02_Payline_Object.paymentAdditional>();


		WS02_Payline_Object.card c = new WS02_Payline_Object.card();
		c.encryptionKeyId = 'sdgd';
        c.encryptedData = 'sdgd';
        c.number_x = 'sdgd';
        c.type_x = 'sdgd';
        c.expirationDate = 'sdgd';
        c.cvx = 'sdgd';
        c.ownerBirthdayDate = 'sdgd';
       	c.password = 'sdgd';
        c.cardPresent = 'sdgd';
        c.cardholder = 'sdgd';
        c.token = 'sdgd';
        c.paymentData = new WS02_Payline_Object.paymentData();

        WS02_Payline_Object.privateDataList pdl = new WS02_Payline_Object.privateDataList();
        pdl.privateData = new List<WS02_Payline_Object.privateData>();

        WS02_Payline_Object.billingRecordList brl = new WS02_Payline_Object.billingRecordList();
        brl.billingRecord = new List<WS02_Payline_Object.billingRecord>();

        WS02_Payline_Object.paymentAdditional pa = new WS02_Payline_Object.paymentAdditional();
        pa.transaction_x = new WS02_Payline_Object.transaction_x();
        pa.payment = new WS02_Payline_Object.payment();
        pa.authorization = new WS02_Payline_Object.authorization();
        pa.authentication3DSecure = new WS02_Payline_Object.authentication3DSecure();
        pa.card = new WS02_Payline_Object.cardOut();
        pa.extendedCard = new WS02_Payline_Object.extendedCardType();

        WS02_Payline_Object.authentication3DSecure a3s = new WS02_Payline_Object.authentication3DSecure();
        a3s.md = 'FDF';
        a3s.pares = 'FDF';
        a3s.xid = 'FDF';
        a3s.eci = 'FDF';
        a3s.cavv = 'FDF';
        a3s.cavvAlgorithm = 'FDF';
        a3s.vadsResult = 'FDF';
        a3s.typeSecurisation = 'FDF';
        a3s.PaResStatus = 'FDF';
        a3s.VeResStatus = 'FDF';

        WS02_Payline_Object.avs av = new WS02_Payline_Object.avs();
        av.result = 's';
        av.resultFromAcquirer = 'sd';

        WS02_Payline_Object.owner o = new WS02_Payline_Object.owner();
        o.lastName = 'sdf';
        o.firstName = 'sdg';
        o.billingAddress = new WS02_Payline_Object.addressOwner();
        o.issueCardDate = 'sd';

        WS02_Payline_Object.wallet w = new WS02_Payline_Object.wallet();
        w.walletId = 'gd';
        w.lastName = 'dsg';
        w.firstName = 'sg';
        w.email = 'sd';
        w.shippingAddress = new WS02_Payline_Object.address();
        w.card = new WS02_Payline_Object.card();
        w.comment = 'sg';
        w.default_x = 'sd';
        w.cardStatus = 'sd';
        w.cardBrand = 'sdg';

        WS02_Payline_Object.paymentData pd = new WS02_Payline_Object.paymentData();
        pd.transactionID = 'sdf';
        pd.network = 'dsgd';
        pd.tokenData = 'sdf';

        WS02_Payline_Object.addressOwner ao = new WS02_Payline_Object.addressOwner();
        ao.street = 'sdf';
        ao.cityName = 'sdf';
        ao.zipCode = 'sdf';
        ao.country = 'sdf';
        ao.phone = 'qsf';
	}
	

	
}