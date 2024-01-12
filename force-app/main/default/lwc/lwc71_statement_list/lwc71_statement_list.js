import { LightningElement, track, wire } from 'lwc';

import { registerListener, unregisterAllListeners } from 'c/pubsub';

import STATEMENT_OBJECT from '@salesforce/schema/STA_Statement__c';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* APEX METHODS */
import getStatements from '@salesforce/apex/lwc71_statement_list_ctrl.getStatements';
import getContact from '@salesforce/apex/lwc71_statement_list_ctrl.getContact';

/* LABEL */
import lbl_Title_Statement from '@salesforce/label/c.LU_Contact_Detail_Statement_Title';
import lbl_Record_Type from '@salesforce/label/c.WAT00002';
import lbl_Max_Statements_Per_Page from '@salesforce/label/c.LU_Order_History_Max_Statements_Per_Page';
import lbl_pagination_postion from '@salesforce/label/c.LU_Pagination_Position';

export default class Lwc71_statement_list extends LightningElement {

    @track labels = {
        lbl_Title_Statement,
        lbl_Record_Type,
        lbl_pagination_postion,
        lbl_Max_Statements_Per_Page
    }

    @track l_statements = [];
    @track l_statementsToDisplay = null;
    @track totalNumberOfRows = 0;
    
    @track l_columns;

    @track isSales = false;
    @track l_salesTitle = ["Sales Consultant", "Group Sales Consultant", "Incaricata", "Incaricata con Gruppo"];

    @track isDirettore = false;
    @track l_directoreTitle = ["Direttore di Filiale", "Direttore di Zona", "Direttore di Regione"];

    @track isFRA = false;

    @track currentPage = 1;
    @track maxPage = 1;

    @track searchedTerms = "";

    /* INIT */
    // @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    // contactObj;

    @wire(getObjectInfo, { objectApiName: STATEMENT_OBJECT })
    callbackStatementInfo({ error, data }) {
        console.log('>>> callbackStatementInfo');
        if (data) {
            this.statementObj = data;

            this.l_columnsDirettore = [
                this.statementObj.fields.Name.label,
                this.statementObj.fields.Contact__c.label,
                this.statementObj.fields.TransType__c.label,
                this.statementObj.fields.TransRefID__c.label,
                this.statementObj.fields.TransDate__c.label,
                this.statementObj.fields.TransDebit__c.label,
                this.statementObj.fields.TransCredit__c.label,
                this.statementObj.fields.TransAmount__c.label,
                this.statementObj.fields.TransDueDate__c.label
            ];

            this.l_columnsSales = [
                this.statementObj.fields.Name.label,
                this.statementObj.fields.TransType__c.label,
                this.statementObj.fields.TransDate__c.label,
                this.statementObj.fields.TransDebit__c.label,
                this.statementObj.fields.TransCredit__c.label,
            ];

            this.l_columnsFra = [
                this.statementObj.fields.TransDate__c.label,
                this.statementObj.fields.TECH_Account_Name__c.label,
                this.statementObj.fields.Contact__c.label,
                this.statementObj.fields.TransRefID__c.label,
                this.statementObj.fields.TransDebit__c.label,
                this.statementObj.fields.TransCredit__c.label,
                this.statementObj.fields.TransDesc__c.label,
                this.statementObj.fields.TransDueDate__c.label
            ];
        }
        else if(error){
            console.log("ERROR ==> ");
            console.log(error);
        }
    }


    connectedCallback() {
        console.log('>>> connected callback');

        registerListener('lwc76_searchStatement', this.updateSearchTerms, this);
        
        getContact()
        .then(results => {

            this.contact = results;
            console.log('>>>contact');
            console.log(this.contact);
            if( this.l_directoreTitle.includes(this.contact.Title) ){
                this.isDirettore = true;
            }
            else if( this.l_salesTitle.includes(this.contact.Title) ){
                this.isSales = true;
            } else if ( this.contact.AccountCountryCode__c == 'FRA') {
                console.log('>>> IS FRENCH');
                this.isFRA = true;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        getStatements()
        .then(results => {

            console.log("getStatements");
            console.log(results);

            if(results){
                this.l_statements = results;

                this.refreshPagination();
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        registerListener('lwc76_statement_list_filters', this.updateStatementsToDisplay, this);

    }

    updateSearchTerms(value){
        this.searchedTerms = value.toLowerCase();

        this.applySearch();
    }

    applySearch(){
        if(this.searchedTerms === ""){
            this.l_statementsToDisplay = this.l_statements;
        }
        else{
            this.l_statementsToDisplay = [];
            for(let stat of this.l_statements){
                if(this.searchedTerms !== ""){
                    if(stat.Contact__r.STHID__c && stat.Contact__r.STHID__c.toLowerCase().includes(this.searchedTerms)){
                        this.l_statementsToDisplay.push(stat);
                    }
                    else if(stat.Contact__r.Name && stat.Contact__r.Name.toLowerCase().includes(this.searchedTerms)){
                        this.l_statementsToDisplay.push(stat);
                    }
                }
            }
        }
    }

    disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
	}

    updateStatementsToDisplay(value){
        
        getStatements({filters : value})
            .then(results => {
                if(results){
                    this.l_statements = results;
                    this.refreshPagination();
                }
            })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    refreshPagination(){
        console.log('>>> refreshPagination');
        this.maxPage = Math.floor( this.l_statements.length / this.labels.lbl_Max_Statements_Per_Page ) + 1;
        this.l_statementsToDisplay = this.l_statements.slice(0, this.labels.lbl_Max_Statements_Per_Page);
        this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
        console.log('>>> this.maxPage : ' + this.maxPage);
        console.log(this.l_statementsToDisplay);
    }
    nextPage(){
        if(this.currentPage < this.maxPage){
            this.currentPage++;
            this.l_statementsToDisplay = this.l_statements.slice(this.currentPage * this.labels.lbl_Max_Statements_Per_Page - this.labels.lbl_Max_Statements_Per_Page, this.currentPage * this.labels.lbl_Max_Statements_Per_Page);
            this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
        }
    }
    previousPage(){
        if(this.currentPage > 1){
            this.currentPage--;
            this.l_statementsToDisplay = this.l_statements.slice(this.currentPage * this.labels.lbl_Max_Statements_Per_Page - this.labels.lbl_Max_Statements_Per_Page, this.currentPage * this.labels.lbl_Max_Statements_Per_Page);
            this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
        }
    }
    firstPage(){
        this.currentPage = 1;
        this.l_statementsToDisplay = this.l_statements.slice(this.currentPage * this.labels.lbl_Max_Statements_Per_Page - this.labels.lbl_Max_Statements_Per_Page, this.currentPage * this.labels.lbl_Max_Statements_Per_Page);
        this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
    }
    lastPage(){
        this.currentPage = this.maxPage;
        this.l_statementsToDisplay = this.l_statements.slice(this.currentPage * this.labels.lbl_Max_Statements_Per_Page - this.labels.lbl_Max_Statements_Per_Page, this.currentPage * this.labels.lbl_Max_Statements_Per_Page);
        this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
    }
}