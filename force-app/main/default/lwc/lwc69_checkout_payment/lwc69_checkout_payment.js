import { LightningElement, track, api } from 'lwc';

import getOrderInfo from '@salesforce/apex/lwc69_checkout_payment_ctrl.getOrderInfo';

// IMPORT RESOURCES
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';


import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

/* IMPORT CUSTOM LABELS */
import lbl_Title from '@salesforce/label/c.LU_Checkout_Payment_Title';
import lbl_paymentCash from '@salesforce/label/c.LU_Checkout_Payment_Cash';
import lbl_paymentDDR from '@salesforce/label/c.LU_Checkout_Payment_DDR';
import lbl_paymentCBP from '@salesforce/label/c.LU_Checkout_Payment_CBP';
import lbl_communityURL from '@salesforce/label/c.LU_Payline_URLCallback';

export default class Lwc69_checkout_payment extends LightningElement {

    /* ICONS */
    iconPayment = LogoBtn + '/icons/checkout-payment.png';

    /* VARIABLES */
    @track orderid;
    @track order;
    @track init = false;

    @track displayMode = false;
    // CASH
    @track displayCash = false;
    @track bpChoosed = false;
    // DDR
    @track displayDDR = false;
    @track ddrChoosed = false;
    // CBP
    @track displayCBP = false;
    @track cbpChoosed = false;

    @track urlPaymentVF = null;
    
    @track isOpen = false;
    @track displayValidateBtn = false;

    @track bpDisabled = true;
    @track cbpDisabled = true;
    @track ddrDisabled = true;

    labels = {
        lbl_paymentCash,
        lbl_paymentDDR,
        lbl_paymentCBP,
        lbl_Title
    }

    connectedCallback(){
        let parameters = this.getQueryParameters();

        if(parameters.orderId !== undefined && parameters.orderId !== ""){
            this.orderid = parameters.orderId;
        }

        // Register event
        registerListener('checkout_openPaymentMode', this.handleEvtOpenClose, this);

        getOrderInfo({orderId : this.orderid})
        .then(results => {
            this.order = results;
            this.displayValidateBtn = true;
            

            let allowedPaymentModeLowerCase = this.order.BillToContact.AllowedPaymentMode__c.toLowerCase();
            // Conditional display of payment mode
            if (allowedPaymentModeLowerCase == "cb" && this.order.BillToContact.AccountCountryCode__c === "ITA") {
                this.displayCBP = true;
                this.displayMode = true;
                this.cbpDisabled = true;
                this.displayValidateBtn = false;
                // Set the URL of the credit card iframe
                this.urlPaymentVF = lbl_communityURL + '/apex/VFP33_Order_Payment_CreditCard?id=' + this.orderid;
                console.log('>>> urlPaymentVF : ' + this.urlPaymentVF);
            } else {
                if (allowedPaymentModeLowerCase.includes("cash")&& this.order.BillToContact.AccountCountryCode__c === "ITA") {
                    this.displayCash = true;
                    this.displayMode = true;
                }
                if (allowedPaymentModeLowerCase.includes("ddr") && this.order.BillToContact.AccountCountryCode__c === "ITA") {
                    this.displayDDR = true;
                    this.displayMode = true;
                }
                if (allowedPaymentModeLowerCase.includes("cbp")) {
                    this.displayCBP = true;
                    this.displayMode = true;
                    this.cbpDisabled = false;
                    this.displayValidateBtn = false;
                    // Set the URL of the credit card iframe
                    this.urlPaymentVF = lbl_communityURL + '/apex/VFP33_Order_Payment_CreditCard?id=' + this.orderid;
                    console.log('>>> urlPaymentVF : ' + this.urlPaymentVF);
                }
            }

            // Default mode selected
            if (allowedPaymentModeLowerCase == "cb" && this.order.BillToContact.AccountCountryCode__c === "ITA") {
                this.cbpChoosed = true;
            } else {
                if (this.order.BillToContact.AccountCountryCode__c === "FRA") {
                    this.cbpChoosed = true;
                } else if (this.order.BillToContact.AccountCountryCode__c === "ITA") {
                    this.displayCash = true;
                    this.displayCBP = true;
                    if (this.displayDDR == true) {
                        this.ddrChoosed = true;
                        this.bpDisabled = true;
                        this.cbpDisabled = true;
                        this.ddrDisabled = false; 
                    } else {
                        this.displayValidateBtn = true;
                        this.bpChoosed = true;
                        this.displayDDR = true;
                        this.bpDisabled = false;
                        this.cbpDisabled = false;
                        this.ddrDisabled = true;
                    }
                }
            }
            
            //SFT-1694, Blocking this card option when product is order by Some else except Interface.
            if(this.order.BillToContactId == this.order.CreatedBy.ContactId || this.order.CreatedBy.Name == 'Interface') {
                this.cbpDisabled = false;
            } else {
                this.cbpDisabled = true;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

    }
    disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }


    /* INIT */
    renderedCallback() {

        if (this.isInit) {
            return;
        }

        this.isInit = true;

        
    }

    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    /* EVENT HANDLER */
    handleEvtOpenClose(value) {
        console.log('>>>> handleEvtOpenClose');
        console.log(value);
        this.isOpen = value;

        if (value === true) {
            fireEvent(null, 'checkout_openValidateButton', this.displayValidateBtn);
            console.log('>>> event fired');
        }
        
        
    }

    handleClickCash(event) {
        if (this.bpChoosed == false) {
            this.bpChoosed = true;
            this.cbpChoosed = false;
            fireEvent(null, 'checkout_openValidateButton', true);
        } else {
            this.bpChoosed = false;
        }
    }

    handleClickCBP(event) {
        if (this.cbpChoosed == false) {
            this.cbpChoosed = true;
            this.bpChoosed = false;
            fireEvent(null, 'checkout_openValidateButton', false);
        } else {
            this.cbpChoosed = false;
        }
    }
}