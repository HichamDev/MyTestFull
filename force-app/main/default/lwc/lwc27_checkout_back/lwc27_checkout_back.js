import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/* Static Resources */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

import LU_Checkout_Back from '@salesforce/label/c.LU_Checkout_Back';

export default class lwc27_checkout_back extends NavigationMixin(LightningElement) {

    /* VARIABLES */
    @track orderId;

    /*labels*/
    labels = {
        LU_Checkout_Back
    }

    /* Icon */
    icon_back = LogoBtn + '/icons/icon_back.PNG';

    /* INIT */
    connectedCallback() { 

        // Get a selected contact
        this.parameters = this.getQueryParameters();

        // Get the order id
        for (let key in this.parameters) {
            if (key == 'orderId') {
                this.orderId = this.parameters[key];
            }
        }

    }

    /* EVENTS */
    handleBack(event) {

        // this[NavigationMixin.Navigate]({
        //     type: 'standard__namedPage',
        //     attributes: {
        //         pageName: 'order',
        //     }
        // });

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.orderId,
                objectApiName: 'order',
                actionName: 'view'
            }
        });

    }

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