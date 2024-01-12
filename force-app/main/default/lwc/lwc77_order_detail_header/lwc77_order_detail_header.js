import { LightningElement, track, wire } from 'lwc';

import getOrder from '@salesforce/apex/lwc77_order_detail_header_ctrl.getOrder';

import lbl_Wishlist_title from '@salesforce/label/c.LU_Order_Deatil_Header_Wishlist';
import lbl_Wishlist_type from '@salesforce/label/c.LU_Order_Deatil_Header_Wishlist_Type';
import lbl_Wishlist_client from '@salesforce/label/c.LU_Order_Deatil_Header_Wishlist_Client';

/* IMPORT OBJECT */
import ORDER_OBJECT from '@salesforce/schema/Order';
/* IMPORT STANDARD METHODS */
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class Lwc77_order_detail_header extends LightningElement {

    labels = {
        lbl_Wishlist_title,
        lbl_Wishlist_type,
        lbl_Wishlist_client
    }

    @track orderId;
    @track ord = null;
    @track orderObj;
    @track orderFieldName = "";
    @track orderFieldStatus = "";
    @track orderFieldEffectiveDate = "";
    @track orderFieldBillToContactId = "";
    @track showOrderType = false;
    @track showOrderClient = false;

    @track compt = 0;

    path_OrderObject = "/order/";

    /* INIT */
    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    contactInfo({ data, error }) {
        try{
            if (data) {
                
                this.orderObj = data;
                
                this.orderFieldName = this.orderObj.fields.Name.label;
                this.orderFieldStatus = this.orderObj.fields.Status.label;
                this.orderFieldEffectiveDate = this.orderObj.fields.EffectiveDate.label;
                this.orderFieldBillToContactId = this.orderObj.fields.BillToContactId.label;

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

            }
            else if (error){
                console.error(error);
            }
        } catch(e){
            console.error(e);
        }
    }
    connectedCallback() {
        console.log('>>>> LWC77 connectedCAllback');
        // try {
        //     // Get order id in the URL
        //     let pageUrl = new URL(window.location.href);
        //     let pathname = pageUrl.pathname;

        //     console.log("this.pathname : " + pathname);

        //     if (pathname.includes(this.path_OrderObject)) {

        //         let indexOf_OrderObject = pathname.indexOf(this.path_OrderObject);
        //         let str_withId = pathname.substr(indexOf_OrderObject + this.path_OrderObject.length);
        //         let indexOf_slash = str_withId.indexOf("/");
        //         this.orderId = str_withId.substring(0, indexOf_slash);

        //         console.log("this.orderid : " + this.orderId);
        //     }

        //     if (this.orderId != null) {
        //         this.getOrderInfo();
        //     }

        // } catch(error){
        //     console.error(error);
        // }
    }

    getOrderInfo(){

        getOrder({idOrder : this.orderId})
            .then(results => {
                this.ord = results;

                if(this.ord.Type === "B2B2C") this.showOrderType = true;
                
                if((this.ord.Type === "B2B2C" || this.ord.Type === "B2C") && this.ord.LU_Online_Customer__r) this.showOrderClient = true;
                
                if(this.BillToContactId){
                    this.ord.FirstName = this.ord.BillToContact.FirstName;
                    this.ord.LastName = this.ord.BillToContact.LastName;
                }
                this.compt ++;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.error(error);
            });
    }

}