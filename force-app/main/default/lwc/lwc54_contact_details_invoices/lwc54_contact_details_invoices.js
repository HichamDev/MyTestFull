import { LightningElement, track, wire } from 'lwc';

import INVOICE_OBJECT from '@salesforce/schema/INV_Invoice__c';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* APEX METHODS */
import getInvoices from '@salesforce/apex/lwc54_contact_details_invoices_ctrl.getInvoices';
import getUserType from '@salesforce/apex/lwc54_contact_details_invoices_ctrl.getUserType';

/* LABEL */
import lbl_Title_Invoice from '@salesforce/label/c.LU_Contact_Detail_Invoice_Title';

export default class Lwc54_contact_details_invoices extends LightningElement {

    @track labels = {
        lbl_Title_Invoice
    }

    @track l_invoices = [];
    @track l_invoicesDisplayed = [];
    @track totalNumberOfRows = 0;

    @track invoiceObj;

    @track idContact = "";
    @track l_columns = [];

    @track displayComponent = false;

    /* INIT */
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

        getInvoices({ idContact : parameters.id })
        .then(results => {
            this.l_invoices = results;

            this.l_invoices = results;
            this.totalNumberOfRows = results.length;
            this.l_invoicesDisplayed = this.l_invoices.slice(0, 10);
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    @wire(getObjectInfo, { objectApiName: INVOICE_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.invoiceObj = data;

            this.l_columns = [
                            {
                                label: this.invoiceObj.fields.Name.label,
                                fieldName: 'LU_Url_Detail_Community__c',
                                type: 'url',
                                typeAttributes: {label: { fieldName: 'Name' }, 
                                target: '_blank'},
                                sortable: true
                            },
                            {label : this.invoiceObj.fields.InvoiceDate__c.label, fieldName : "InvoiceDate__c", type : "date-local", typeAttributes: {year:"2-digit", month:"2-digit", day:"2-digit"}},
                            {label : this.invoiceObj.fields.InvoiceNumber__c.label, fieldName : "InvoiceNumber__c", type : "Text"},
                            {label : this.invoiceObj.fields.PaymentDate__c.label, fieldName : "PaymentDate__c", type : "date-local", typeAttributes: {year:"2-digit", month:"2-digit", day:"2-digit"}},
                            {label : this.invoiceObj.fields.Total__c.label, fieldName : "Total__c", type: 'currency', typeAttributes: { currencyCode: 'EUR'}}, 
                            {label : this.invoiceObj.fields.Status__c.label, fieldName : "Status__c", type : "Text"}
                        ];
        }
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
        if (this.l_invoicesDisplayed.length >= this.totalNumberOfRows) {
            event.target.enableInfiniteLoading = false;
            this.loadMoreStatus = 'No more data to load';
        } else {
            this.l_invoicesDisplayed = this.l_invoicesDisplayed.concat( this.l_invoices.slice( this.l_invoicesDisplayed.length, this.l_invoicesDisplayed.length + 10) );
        }
        event.target.isLoading = false;
    }

}