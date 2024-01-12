import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/* IMPORT METHOD */
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import validate from '@salesforce/apex/lwc27_order_validation.validateOrderOnCheckout';
import controlBundle from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.controlBundle';

/* IMPORT LABELS */
import lbl_txtInProgress from '@salesforce/label/c.LU_Checkout_ValidationOrder_InProgress';
import lbl_Stock_Title from '@salesforce/label/c.LU_Stock_Checkout_Error_Title';
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Stock_ButtonUpdate from '@salesforce/label/c.LU_Stock_Checkout_Button_UpdateOrder';
import lbl_Stock_Popup_Msg from '@salesforce/label/c.LU_Stock_Checkout_Error_Popup_Message';
import lbl_orderIsKo from '@salesforce/label/c.LU_Checkout_ValidationOrder_Ko';


export default class Lwc27_checkout_validationorder extends NavigationMixin(LightningElement) {

    /* LABELS */
    labels = {
        lbl_txtInProgress,
        lbl_Stock_Title,
        lbl_Close,
        lbl_Stock_ButtonUpdate,
        lbl_Stock_Popup_Msg,
        lbl_orderIsKo
    }

    /* VARIABLES */
    @api orderId;
    @track loading = true;
    @track orderValidated = false;
    @track displayPopUpStock = false;
    @track lOffersWithProblem = [];
    @track error = null;


    /* INIT */
    connectedCallback() {

        // Get the orderId to validate
        let parameters = this.getQueryParameters();
        for (var key in parameters) {
            if (key == 'orderId') {
                this.orderId = parameters[key];
            }
        }

        controlBundle({ orderId : this.orderId })
        .then(resultBundle => {
            console.log("resultBundleresultBundleresultBundleresultBundleresultBundleresultBundleresultBundleresultBundleresultBundle");
            console.log(resultBundle);
            if (resultBundle) {
                if (resultBundle === "OK") {
                    
                    validate( { orderId : this.orderId } )
                    .then(result => {

                        if (result) {
                            
                            // IF the order is ok
                            if (result.success) {
                                
                                this.orderValidated = true;
                                this.loading = false;

                                // Fire event : to shipping mode component lwc67_checkout_shipping
                                fireEvent(null, 'checkout_openShippingMode', true);
                                // Fire event : to shipping mode component lwc69_checkout_payment
                                fireEvent(null, 'checkout_openPaymentMode', false);

                            } else { // If the order is not ok

                                // If the type of the error is status
                                if (result.type == 'status') {
                                    //back to homepage
                                    this[NavigationMixin.Navigate]({
                                        type: 'standard__namedPage',
                                        attributes: {
                                            pageName: 'home',
                                        },
                                    });
                                    return;
                                }

                                this.orderValidated = false;
                                this.loading = false;

                                // If the type of the error is stock
                                if (result.type == 'stock') {
                                    
                                    this.displayPopUpStock = true;
                                    this.lOffersWithProblem = result.lOffersWithProblem;

                                } else {
                                    this.error = result.message;
                                }


                                
                                console.log("result.lOffersWithProblem");
                                console.log(result);

                                // Fire event : to shipping mode component lwc67_checkout_shipping
                                fireEvent(null, 'checkout_openShippingMode', false);
                                // Fire event : to shipping mode component lwc69_checkout_payment
                                fireEvent(null, 'checkout_openPaymentMode', false);
                                
                            }

                        }
                        
                        // Hide the spinner
                        this.loading = false;

                    })
                    .catch(error => {
                        console.log('>>>> error :');
                        console.error(error);
                        this.validated = false;
                        this.error = error;

                        // Hide the spinner
                        this.loading = false;
                    });

                }
                else {

                    this.orderValidated = false;
                    this.loading = false;

                    this.error = resultBundle.split('###')[0] + " : " + resultBundle.split('###')[1];
                }
            }
        })
        .catch(error => {
            console.log(">>>error");
            console.log(error);
            // Hide the spinner
            this.isLoading = false;
        });

    }


    /* UI METHODS */
    goBackToOrder(event) {
        console.log('>>>> gobacktoorder');
        // Navigate to the page in url
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.orderId,
                actionName: 'view'
            }
        });
    }


    /* EVENT HANDLER */


    /* TECH METHODS */
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