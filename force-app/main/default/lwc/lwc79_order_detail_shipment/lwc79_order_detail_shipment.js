import { LightningElement, track, wire } from 'lwc';

import getOrder from '@salesforce/apex/lwc79_order_detail_shipment_ctrl.getOrder';
import getUserCountry from '@salesforce/apex/lwc67_checkout_shipping_ctrl.getUserCountry';

/* IMPORT OBJECT */
import ORDER_OBJECT from '@salesforce/schema/Order';
/* IMPORT STANDARD METHODS */
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import lbl_Title from '@salesforce/label/c.LU_Order_Shipping_Title';
import lbl_fieldPrefix from '@salesforce/label/c.LU_Checkout_Shipping_ExceptionnalAddress_Prefix';
import lbl_subtitle_expedition from '@salesforce/label/c.LU_Order_Detail_Shipping_SubTitle';

export default class Lwc79_order_detail_shipment extends LightningElement {

    labels = {
        lbl_Title,
        lbl_fieldPrefix,
        lbl_subtitle_expedition
    }

    @track displayBlock = false;
    @track orderId;
    @track ord;
    @track orderObj;
    @track orderFieldShipmentRef = "";
    @track orderFieldTransporter = "";
    @track orderFieldShippingDate = "";
    @track orderFieldShippingAddress = "";

    @track isFRA = false;
    @track isITA = false;

    @track displaySenderName = false;

    path_OrderObject = "/order/";

    /* INIT */
    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    contactInfo({ data, error }) {
        try{
            if (data) {
                this.orderObj = data;

                this.orderFieldShipmentRef = this.orderObj.fields.LU_Shipment_Ref__c.label;
                this.orderFieldTransporter = this.orderObj.fields.LU_Transporter__c.label;
                this.orderFieldShippingDate = this.orderObj.fields.LU_Shipping_Date__c.label;
                this.orderFieldShippingAddress = this.orderObj.fields.ShippingAddress.label;
            }
            else if (error){
                console.log(error);
            }
        } catch(e){
            console.log(e);
        }
    }
    connectedCallback() {

        try{
            // Get order id in the URL
            let pageUrl = new URL(window.location.href);
            let pathname = pageUrl.pathname;

            if (pathname.includes(this.path_OrderObject)) {

                let indexOf_OrderObject = pathname.indexOf(this.path_OrderObject);
                let str_withId = pathname.substr(indexOf_OrderObject + this.path_OrderObject.length);
                let indexOf_slash = str_withId.indexOf("/");
                this.orderId = str_withId.substring(0, indexOf_slash);
            }

            if (this.orderId != null) {
                this.getOrderInfo();
            }
        } catch(error){
            console.log(error);
        }
    }

    getOrderInfo(){

        getOrder({idOrder : this.orderId})
            .then(results => {
                this.ord = results;

                if( this.ord.Status != 'Draft' ) {
                    this.displayBlock = true;
                }



                getUserCountry() 
                    .then(results => {
                        if(results === 'FRA'){
                            this.country = "France"
                            this.isFRA = true;

                            if(this.ord.BillToContact.Name !== this.ShippingStreet){
                                this.displaySenderName = true;
                            }
                        }
                        else if(results === 'ITA'){
                            this.country = "Italia"
                            this.isITA = true;
                        }
                        // Add an variable to show "Chez" based on CustomLabel
                        /* if(this.labels.lbl_fieldPrefix.length > 0 && this.labels.lbl_fieldPrefix && this.isFRA){
                            this.displayExceptionnalAdressPrefix = true;
                            this.prefixAndLastName = "(" + this.labelslbl_fieldPrefix + ") " + lbl_fieldLastname;
                        } */
                        })
                        .catch(error => {
                            console.log('>>>> error :');
                            console.log(error);
                        }
                    );

            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

}