import { LightningElement, track, wire } from 'lwc';

import ORDORDER_OBJECT from '@salesforce/schema/ORD_Order__c';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* APEX METHODS */
import getOrders from '@salesforce/apex/lwc55_contact_details_orders_ctrl.getOrders';
import getUserType from '@salesforce/apex/lwc55_contact_details_orders_ctrl.getUserType';

/* LABEL */
import lbl_Title_Order from '@salesforce/label/c.LU_Contact_Detail_Order_Title';

export default class Lwc55_contact_details_orders extends LightningElement {

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
    @wire(getObjectInfo, { objectApiName: ORDORDER_OBJECT })
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
                {label : this.orderObj.fields.OrderDate__c.label, fieldName : "OrderDate__c", type : "date-local", typeAttributes: {year:"2-digit", month:"2-digit", day:"2-digit"}},
                {label : this.orderObj.fields.OrderType__c.label, fieldName : "OrderType__c", type : "Text"},
                {label : this.orderObj.fields.Status__c.label, fieldName : "Status__c", type : "text"},
                {label : this.orderObj.fields.TECH_TotalPrice__c.label, fieldName : "TECH_TotalPrice__c", type: 'currency', typeAttributes: { currencyCode: 'EUR'}}
            ];
        }
    }
    connectedCallback() {
        
        let parameters = this.getQueryParameters();

        getUserType({ idContact : parameters.id })
        .then(results => {
            if(results !== "LU_Personal_Contact"){
                this.displayComponent = true;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        getOrders({ idContact : parameters.id })
        .then(results => {
            console.log("azergtnydtbsrvgqefgrsbt");
            console.log(results);

            this.l_orders = results;

            console.log(this.l_orders);

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