import { LightningElement, track, wire } from 'lwc';

import STATEMENT_OBJECT from '@salesforce/schema/STA_Statement__c';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* APEX METHODS */
import getStatements from '@salesforce/apex/lwc56_contact_details_statements_ctrl.getStatements';
import getUserType from '@salesforce/apex/lwc56_contact_details_statements_ctrl.getUserType';

/* LABEL */
import lbl_Title_Statement from '@salesforce/label/c.LU_Contact_Detail_Statement_Title';
import lbl_Record_Type from '@salesforce/label/c.WAT00002';

export default class Lwc56_contact_details_statements extends LightningElement {

    @track labels = {
        lbl_Title_Statement,
        lbl_Record_Type
    }

    @track l_statements = [];
    @track l_statementsDisplayed = [];
    @track totalNumberOfRows = 0;
    @track statementObj;
    
    @track idContact = "";
    @track l_columns;

    @track displayComponent = false;

    /* INIT */
    @wire(getObjectInfo, { objectApiName: STATEMENT_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.statementObj = data;

            this.l_columns = [
                {
                    label: this.statementObj.fields.Name.label,
                    fieldName: 'LU_Url_Detail_Community__c',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'Name' }, 
                    target: '_blank'},
                    sortable: true
                },
                {label : this.statementObj.fields.TransDate__c.label, fieldName : "TransDate__c", type : "date-local", typeAttributes: {year:"2-digit", month:"2-digit", day:"2-digit"}},
                {label : this.statementObj.fields.TransDesc__c.label, fieldName : "TransDesc__c", type : "Text"},
                {label : this.statementObj.fields.TransDebit__c.label, fieldName : "TransDebit__c", type: 'currency', typeAttributes: { currencyCode: 'EUR'}},
                {label : this.statementObj.fields.TransCredit__c.label, fieldName : "TransCredit__c", type: 'currency', typeAttributes: { currencyCode: 'EUR'}},
                {label : this.labels.lbl_Record_Type, fieldName : "RecordType", type: 'Text'}
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

        getStatements({ idContact : parameters.id })
        .then(results => {

            this.l_statements = results;
            this.l_statements.forEach(function(statement){
                //to show the record type name 
                statement.RecordType = statement.RecordType.Name;
            });

            this.totalNumberOfRows = this.l_statements.length;
            this.l_statementsDisplayed = this.l_statements.slice( 0, 10);
            console.log(this.l_statementsDisplayed);
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
        if (this.l_statementsDisplayed.length >= this.totalNumberOfRows) {
            event.target.enableInfiniteLoading = false;
            this.loadMoreStatus = 'No more data to load';
        } else {
            this.l_statementsDisplayed = this.l_statementsDisplayed.concat( this.l_statements.slice( this.l_statementsDisplayed.length, this.l_statementsDisplayed.length + 10) );
        }
        event.target.isLoading = false;
    }

}