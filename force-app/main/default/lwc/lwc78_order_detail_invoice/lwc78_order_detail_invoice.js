import { LightningElement, track, wire } from 'lwc';

import getOrder from '@salesforce/apex/lwc78_order_detail_invoice_ctrl.getOrder';

/* IMPORT OBJECT */
import ORDER_OBJECT from '@salesforce/schema/Order';
/* IMPORT STANDARD METHODS */
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import lbl_Title from '@salesforce/label/c.LU_Order_Invoice_Title';

export default class Lwc78_order_detail_invoice extends LightningElement {

    labels = {
        lbl_Title
    }


    @track displayBlock = false;
    @track orderId;
    @track ord;
    @track orderObj;
    @track orderFieldInvoiceDate = "";
    @track orderFieldInvoiceStatus = "";
    @track orderFieldInvoiceNumber = "";

    path_OrderObject = "/order/";

    /* INIT */
    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    contactInfo({ data, error }) {
        try{
            if (data) {
                this.orderObj = data;

                this.orderFieldInvoiceDate = this.orderObj.fields.LU_Invoice_Date__c.label;
                this.orderFieldInvoiceStatus = this.orderObj.fields.LU_Invoice_Status__c.label;
                this.orderFieldInvoiceNumber = this.orderObj.fields.LU_Invoice_Number__c.label;
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

                if (this.ord.Status != 'Draft' && this.ord.LU_Invoice_Status__c != '') {
                    this.displayBlock = true;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

}