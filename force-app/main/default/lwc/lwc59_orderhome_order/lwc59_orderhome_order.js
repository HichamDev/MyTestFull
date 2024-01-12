import { LightningElement, track, api } from 'lwc';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

import getPersonalMessage from '@salesforce/apex/lwc59_orderhome_order_ctrl.getPersonalMessage';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

export default class Lwc59_orderhome_order extends LightningElement {

    iconBoxOrder = LogoBtn + '/icons/icon-boxOrder.svg';

    @track mess;
    @track gotOrderTypeDone = false;
    @track isWebOnly = false;
    @api isShow;
    @track isdisplay;
    @track isSearchdisplay;

    @track isOrderDetailPage = false;
    @track isOrderCheckoutPage = false;
    @track showTitleLwc26 = true;

    connectedCallback(){
        //registerListener('ShowProductSelection', this.displayProduct, this);
        registerListener('hideCardComponent', this.hideCardComponent, this);

        if(this.isShow) {
            this.isdisplay = 'display:block;';
        } else {
            this.isdisplay = 'display:none;';
        }
        getPersonalMessage()
            .then(results => {
                this.mess = results;
            })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        let pathname = window.location.href;

        if (pathname.includes(this.path_OrderObject)) {
            let indexOf_OrderObject = pathname.indexOf(this.path_OrderObject);
            let str_withId = pathname.substr(indexOf_OrderObject + this.path_OrderObject.length);
            let indexOf_slash = str_withId.indexOf("/");
            this.orderId = str_withId.substring(0, indexOf_slash);

            this.isOrderDetailPage = true;
            this.showTitleLwc26 = true;
        }
        else if (pathname.includes(this.path_OrderCheckout)) {
            let parameters = this.getQueryParameters();
            if(parameters.orderId){
                this.orderId = parameters.orderId;
            }

            this.isOrderCheckoutPage = true;
            this.showTitleLwc26 = false;
        }
    }

    hidelwc16(event){
        this.isdisplay = 'display:none;';
        this.isSearchdisplay = 'display:none;';
        fireEvent(this.pageRef, 'HideProductSelection', event.target.value);
    }

    displayProduct(nextStep) {
        this.isdisplay = 'display:block;';
        this.isSearchdisplay = 'display:none;';
    }

    hideCardComponent() {
        this.isdisplay = 'display:none;';
    }

    gotOrderType(event) {
        console.log('gotOrderType ', event);
        console.log(event.detail);
        if(event.detail == 'B2B2C') this.isWebOnly = true;
        this.gotOrderTypeDone = true;
    }
}