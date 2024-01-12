import { LightningElement, track, wire } from 'lwc';

import ORDER_OBJECT from '@salesforce/schema/Order';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* APEX METHODS */
import getOrders from '@salesforce/apex/lwc81_personal_contact_details_order_ctr.getOrders';
import getUserType from '@salesforce/apex/lwc81_personal_contact_details_order_ctr.getUserType';

/* LABEL */
import lbl_Title_Order from '@salesforce/label/c.LU_Contact_Detail_Order_Title';

export default class Lwc81_personal_contact_details_order extends LightningElement {

    @track labels = {
        lbl_Title_Order
    }

    @track l_orders = [];
    @track l_ordersDisplayed = [];
    @track totalNumberOfRows = 0;
    @track orderObj;
    
    @track idContact = "";
    @track l_columns;

    @track displayComponent = false;

    /* INIT */
    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.orderObj = data;

            this.l_columns = [
                {
                    label: this.orderObj.fields.Name.label,
                    fieldName: 'LU_Url_Detail_Community__c',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'Name' }, 
                    target: '_blank'},
                    sortable: true
                },
                {label : this.orderObj.fields.EffectiveDate.label, fieldName : "EffectiveDate", type : "date-local", typeAttributes: {year:"2-digit", month:"2-digit", day:"2-digit"}},
                {label : this.orderObj.fields.Status.label, fieldName : "Status", type : "Text"},
                {label : this.orderObj.fields.LU_Transporter__c.label, fieldName : "LU_Transporter__c", type : "text"},
                {label : this.orderObj.fields.LU_Shipping_Date__c.label, fieldName : "LU_Shipping_Date__c", type : "date-local", typeAttributes: {year:"2-digit", month:"2-digit", day:"2-digit"}}
            ];
        }
    }
    connectedCallback() {
        
        let parameters = this.getQueryParameters();

        getUserType({ idContact : parameters.id })
        .then(results => {
            if(results === "LU_Personal_Contact"){
                this.displayComponent = true;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        getOrders({ idContact : parameters.id })
        .then(results => {

            this.l_orders = results;

            this.totalNumberOfRows = this.l_orders.length;
            this.l_ordersDisplayed = this.l_orders.slice( 0, 10);
            console.log(this.l_ordersDisplayed);
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
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

    loadMoreData (event) {
        
        event.target.isLoading = true;
        
        this.loadMoreStatus = 'Loading';
        if (this.l_ordersDisplayed.length >= this.totalNumberOfRows) {
            event.target.enableInfiniteLoading = false;
            this.loadMoreStatus = 'No more data to load';
        } else {
            this.l_ordersDisplayed = this.l_ordersDisplayed.concat( this.l_orders.slice( this.l_ordersDisplayed.length, this.l_ordersDisplayed.length + 10) );
        }
        event.target.isLoading = false;
    }

}