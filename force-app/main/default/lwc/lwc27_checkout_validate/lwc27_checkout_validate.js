import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/* IMPORT METHODS */
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import validate from '@salesforce/apex/lwc27_order_validation.validateOrderOnValidation';
import getUserCountry from '@salesforce/apex/LWC01_ListView_Ctrl.getUserCountry';

/* IMPORT LABELS */
import lbl_ChooseDeliveryMode from '@salesforce/label/c.LU_Checkout_Validation_Error_DeliveryChoice';
import lbl_BtnValidateAndPay from '@salesforce/label/c.LU_Checkout_Validation_Btn_ValidateAndPay';
import lbl_Stock_Title from '@salesforce/label/c.LU_Stock_Checkout_Error_Title';
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Stock_ButtonUpdate from '@salesforce/label/c.LU_Stock_Checkout_Button_UpdateOrder';
import lbl_Stock_Popup_Msg from '@salesforce/label/c.LU_Stock_Checkout_Error_Popup_Message';

export default class Lwc27_checkout_validate extends NavigationMixin(LightningElement) {

    /* LABELS */
    labels = {
        lbl_ChooseDeliveryMode,
        lbl_Stock_Title,
        lbl_Close,
        lbl_Stock_ButtonUpdate,
        lbl_Stock_Popup_Msg,
        lbl_BtnValidateAndPay
    }

    /* VARIABLES */
    @api orderId; // parameter orderId in the url
    parameters = {}; // URL parameters
    ordermode = '';
    orderstreet = '';
    orderpostalcode = '';
    ordercity = '';
    ordercountry = '';
    orderfee = '';
    ordermodelabel = '';
    orderexceptionaladdress = '';
    @track error = null;

    @track displayPopUpStock = false;
    @track lOffersWithProblem = [];

    @track loading = true;

    @track isopenbtn = false;
    @track validated = false;

    @track isITA;


    /* INIT */
    @wire(CurrentPageReference) pageRef; // Required by pubsub
	connectedCallback() {
        getUserCountry()
            .then(results => {
                if(results === "FRA"){
                    this.isITA = false;
                } else {
                    this.isITA = true;
                }
            })
            .catch(error => {
                console.log('>>>> error LWC27 CHeckout Validate :');
                console.log(error);
            });

        // Register event
        registerListener('checkout_openValidateButton', this.handleEvtOpenValidationButton, this);
        
        this.parameters = this.getQueryParameters();

        // Get the order id
        for (var key in this.parameters) {
            if (key == 'orderId') {
                this.orderId = this.parameters[key];
            }
        }
        console.log('>>>> this.orderId :' + this.orderId);
        // subscribe to events
        // registerListener('deliveryModeSelected', this.handleDeliveryModeSelected, this);

        

	}
	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }
    

    /* EVENTS HANDLER */
    handleEvtOpenValidationButton(value) {
        console.log('handleEvtOpenValidationButton ' + value);
        this.loading = true;
        // if(this.isITA){
        //     setTimeout(() => {
        //         this.isopenbtn = value;}
        //     , 3000);
        // }
        // else 
        this.isopenbtn = value;
        this.loading = false;
    }

    // Handle the validation of the order
    handleValidateOrder(value) {
        // Display the spinner
        this.loading = true;

        validate( { orderId: this.orderId, commitToDB: true})
            .then(result => {
                console.log('result');
                console.log(result);
                if (result) {
                    // IF the order is successfully validated
                    if (result.success) {
                        // Navigate to the confirmation page
                        this[NavigationMixin.Navigate]({
                            type: 'standard__namedPage',
                            attributes: {
                                pageName: 'order-validation',
                            },
                            state: {
                                orderId: this.orderId
                            },
                        });
    
                    } else { // If the order is not successfully validated
                        // If the type of the error is stock
                        if (result.type == 'stock') {
                            this.displayPopUpStock = true;
                            this.lOffersWithProblem = result.lOffersWithProblem;
                        } else {
                            this.error = result.message;
                        }
                    }
                }
                // Hide the spinner
                this.loading = false;

            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
                this.validated = false;
                this.error = error;

                // Hide the spinner
                this.loading = false;
            });

    }


    /* UI METHODS */
    goBackToOrder(event) {
        // Navigate to the page in url
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'order-view',
            },
            state: {
                orderId: this.orderId
            },
        });
    }

    close(event) {
        this.displayPopUpStock = false;
        this.error = '';
    }

    /* BUSINESS METHODS */

    // Put args of the URL in a map
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
    
}