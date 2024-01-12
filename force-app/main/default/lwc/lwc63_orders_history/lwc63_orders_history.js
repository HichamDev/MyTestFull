import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { registerListener, unregisterAllListeners } from 'c/pubsub';

import getOrders from '@salesforce/apex/lwc63_orders_history_ctrl.getOrders';
import updateOrderStatus from '@salesforce/apex/lwc63_orders_history_ctrl.updateOrderStatus';
import getContact from '@salesforce/apex/lwc63_orders_history_ctrl.getContact';
import getUserCountry from '@salesforce/apex/lwc63_orders_history_ctrl.getUserCountry';

/* IMPORT RESOURCES */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

/* IMPORT OBJECT */
import ORDER_OBJECT from '@salesforce/schema/Order';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* IMPORT CUSTOM LABEL */
import lbl_search from '@salesforce/label/c.LU_Contat_Search';
import lbl_Title from '@salesforce/label/c.LU_Order_History_Title';
import lbl_Max_Orders_Per_Page from '@salesforce/label/c.LU_Order_History_Max_Orders_Per_Page';
import lbl_pagination_postion from '@salesforce/label/c.LU_Pagination_Position';
import LU_Order_Column_Contact from '@salesforce/label/c.LU_Order_Column_Contact';
import LU_Order_Column_Account from '@salesforce/label/c.LU_Order_Column_Account';
import LU_Order_Column_Action from '@salesforce/label/c.LU_Order_Column_Action';
import LU_Order_Action_Transferer from '@salesforce/label/c.LU_Order_Action_Transferer';
import LU_Order_Action_Cloturer from '@salesforce/label/c.LU_Order_Action_Cloturer';
import lbl_orderType_whishlist from '@salesforce/label/c.LU_Order_Filter_Order_Type_whishlist';
import lbl_orderStatus_cancelled_fra from '@salesforce/label/c.LU_Order_Filter_Order_Status_Cancelled_Fra';
import lbl_orderStatus_cancelled from '@salesforce/label/c.LU_Order_Filter_Order_Status_Cancelled';

export default class Lwc63_orders_history extends NavigationMixin(LightningElement) {

    iconFilter = LogoBtn + '/icons/btn_filters.png';

    @track l_orders = [];
    @track l_ordersToDisplay = [];
    @track orderObject = {};
    @track searchedTerms = "";
    @track searchedSthid = "";
    @track isDirector = false;
    @track contact;
    @track isITA = false;
    @track isFRA = false;

    @track currentPage = 1;
    @track maxPage = 1;
    @track appliedFilters;

    /* LABELS */
    labels = {
        lbl_search,
        lbl_Title,
        lbl_Max_Orders_Per_Page,
        lbl_pagination_postion,
        LU_Order_Column_Contact,
        LU_Order_Column_Account,
        LU_Order_Column_Action,
        LU_Order_Action_Transferer,
        LU_Order_Action_Cloturer,
        lbl_orderType_whishlist,
        lbl_orderStatus_cancelled_fra,
        lbl_orderStatus_cancelled
    }

    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.orderObject.Name = data.fields.Name.label;
            this.orderObject.AccountId = data.fields.AccountId.label;
            this.orderObject.Type = data.fields.Type.label;
            this.orderObject.Status = data.fields.Status.label;
            this.orderObject.EffectiveDate = data.fields.EffectiveDate.label;
            this.orderObject.LU_TECH_Order_Date__c = data.fields.LU_TECH_Order_Date__c.label;
            this.orderObject.LU_Number_Of_Articles__c = data.fields.LU_Number_Of_Articles__c.label;
            this.orderObject.TotalAmount = data.fields.TotalAmount.label;
            //this.orderObject.BillToContactId = data.fields.BillToContactId.label;
            this.orderObject.BillToContactId = "Contact";
            this.orderObject.LU_Invoice_Date__c = data.fields.LU_Invoice_Date__c.label;
            this.orderObject.LU_Invoice_Number__c = data.fields.LU_Invoice_Number__c.label;
            this.orderObject.LU_Transporter__c = data.fields.LU_Transporter__c.label;
            this.orderObject.CreatedDate = data.fields.CreatedDate.label;
            this.orderObject.LU_Shipping_Date__c = data.fields.LU_Shipping_Date__c.label;
            this.orderObject.LU_Shipment_Ref__c = data.fields.LU_Shipment_Ref__c.label;
            this.orderObject.LU_Total_Price_Without_Taxes__c = data.fields.LU_Total_Price_Without_Taxes__c.label;
            this.orderObject.LU_Total_Amount_For_Valid_Base__c = data.fields.LU_Total_Amount_For_Valid_Base__c.label;
            this.orderObject.LU_Amount_To_Pay__c = data.fields.LU_Amount_To_Pay__c.label;
            this.orderObject.LU_Invoice_Status__c = data.fields.LU_Invoice_Status__c.label;
            this.orderObject.CreatedBy = "Creato da";
        }
        else if (error){
            console.log('>>>> error wire contactinfo lwc63:');
            console.log(error);
        }
    }
    connectedCallback(){
        console.log('connected callback lwc63');
        registerListener('lwc65_searchOrder', this.updateSearchTerms, this);
        registerListener('lwc65_searchSthid', this.updateSearchSthid, this);
        registerListener('lwc65_filters_order', this.updateOrdersToDisplay, this);

        getUserCountry()
            .then(results => {
                if(results === "FRA"){
                    this.isFRA = true;
                }
                else if(results === "ITA"){
                    this.isITA = true;
                }
            })
        .catch(error => {
            console.log('>>>> error get usercountry lwc63:');
            console.log(error);
        });

        getOrders({filters : null}) //Récupération en without sharing
            .then(results => {
                this.l_orders = results;
                console.log('lorders :');
                console.log(results);
                for(const o of results){
                    console.log(o.Status);
                    o.href = 'order/' + o.Id;
                    o.displayBoTotal = false;
                    if(o.Status === 'Invoiced' || o.Status === 'Shipped' || o.Status === 'Archived' || o.Status === 'Cancelled' || o.Status === 'Blocked'
                    || o.Status === 'Expédiée' || o.Status === 'Archivée' || o.Status === 'Annulée' || o.Status === 'Bloquée'){
                        o.displayBoTotal = true;
                    }
                }
                this.l_ordersToDisplay = results;
                this.parseDisplayedOrders(this.l_ordersToDisplay);
                for(let ord of this.l_ordersToDisplay){
                    if(ord.LU_TECH_Order_Date__c === "" || ord.LU_TECH_Order_Date__c === null || ord.LU_TECH_Order_Date__c === undefined){
                        ord.LU_TECH_Order_Date__c = ord.EffectiveDate;
                    }
                }
                
                this.l_ordersToDisplay.sort((a, b) => (a.LU_TECH_Order_Date__c > b.LU_TECH_Order_Date__c) ? -1 : 1);
                this.refreshPagination();
            })
        .catch(error => {
            console.log('>>>> error get orders :');
            console.log(error);
        });

        getContact()
            .then(results => {
                this.contact = results;
                console.log("result contact:");
                console.log(this.contact);
                if(this.contact.Is_Manager_Order_View__c == true) {
                    this.isDirector = true;
                }
            })
        .catch(error => {
            console.log('>>>> error get contact lwc63 :');
            console.log(error);
        });
    }
	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
	}

    updateOrdersToDisplay(value){
        console.log('>>>> filters to update :');
        console.log(value);
        this.appliedFilters = value;
        getOrders({filters : value})
            .then(results => {
                console.log({results})
                for(const o of results){
                    console.log(o.Status);
                    o.href = 'order/' + o.Id;
                    o.displayBoTotal = false;
                    if(o.Status === 'Invoiced' || o.Status === 'Shipped' || o.Status === 'Archived' || o.Status === 'Cancelled' || o.Status === 'Blocked'
                    || o.Status === 'Expédiée' || o.Status === 'Archivée' || o.Status === 'Annulée' || o.Status === 'Bloquée'){
                        o.displayBoTotal = true;
                    }
                }
                this.l_orders = results;
                this.l_ordersToDisplay = results;
                this.parseDisplayedOrders(this.l_ordersToDisplay);
				for(let ord of this.l_ordersToDisplay){
                    if(ord.LU_TECH_Order_Date__c === "" || ord.LU_TECH_Order_Date__c === null || ord.LU_TECH_Order_Date__c === undefined){
                        ord.LU_TECH_Order_Date__c = ord.EffectiveDate;
                    }
                }
            })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    updateSearchSthid(value){
        this.searchedSthid = value.toLowerCase();

        this.applySearch();
    }

    updateSearchTerms(value){
        this.searchedTerms = value.toLowerCase();

        this.applySearch();
    }

    applySearch(){
        if(this.searchedTerms === "" && this.searchedSthid === "" ){
            this.l_ordersToDisplay = this.l_orders;
        }
        else{
            if(this.isITA){
                this.l_ordersToDisplay = [];
                if(this.isDirector){
                    for(let ord of this.l_orders){
                        if(this.searchedTerms !== ""){
                            if(ord.Name && ord.Name.toLowerCase().includes(this.searchedTerms) || ord.BillToContact.Name && ord.BillToContact.Name.toLowerCase().includes(this.searchedTerms)){
                                this.l_ordersToDisplay.push(ord);
                            }
                        }
                        if(this.searchedSthid !== ""){
                            if(ord.BillToContact.STHID__c && ord.BillToContact.STHID__c.toLowerCase().includes(this.searchedSthid)){
                                this.l_ordersToDisplay.push(ord);
                            }
                        }
                    }
                }
                else{
                    for(let ord of this.l_orders){
                        if(this.searchedTerms !== ""){
                            if(ord.Name && ord.Name.toLowerCase().includes(this.searchedTerms)){
                                this.l_ordersToDisplay.push(ord);
                            }
                        }
                        if(this.searchedSthid !== ""){
                            if(ord.BillToContact.STHID__c && ord.BillToContact.STHID__c.toLowerCase().includes(this.searchedSthid)){
                                this.l_ordersToDisplay.push(ord);
                            }
                        }
                    }
                }
            }
            else if(this.isFRA){
                this.l_ordersToDisplay = [];
                for(let ord of this.l_orders){
                    if(this.searchedTerms !== ""){
                        if(ord.Name && ord.Name.toLowerCase().includes(this.searchedTerms)){
                            this.l_ordersToDisplay.push(ord);
                        }
                        else if(ord.BillToContact.STHID__c && ord.BillToContact.STHID__c.toLowerCase().includes(this.searchedTerms)){
                            this.l_ordersToDisplay.push(ord);
                        }
                        else if(ord.BillToContact.Name && ord.BillToContact.Name.toLowerCase().includes(this.searchedTerms)){
                            this.l_ordersToDisplay.push(ord);
                        }
                    }
                }
            }
        }

        // alert(this.l_ordersToDisplay);
    }

    /* UI METHODS */
    navigateToOrder(event) {
        console.log(event.target.dataset.id);
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'Order',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url);
       });
    }

    navigateToUser(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });
    }

    renderedCallback(){
        console.log('rendered callbak lwc63');
        let l_spanStatus = this.template.querySelectorAll(".statusSpan");

        for (let i = 0; i < l_spanStatus.length; i++) {
            let statusOrder = l_spanStatus[i].id.substring(0, l_spanStatus[i].id.length - 3);

            console.log(statusOrder);

            if(statusOrder === "Validated"){
                l_spanStatus[i].classList.add('received');
            }
            else if(statusOrder === "Received"){
                l_spanStatus[i].classList.add('received');
            }
            else if(statusOrder === "Shipped"){
                l_spanStatus[i].classList.add('shipped');
            }
            else if(statusOrder === "Sent"){
                l_spanStatus[i].classList.add('sent');
            }
            else if(statusOrder === "Draft"){
                l_spanStatus[i].classList.add('draft');
            }
            else if(statusOrder === "Suspended"){
                l_spanStatus[i].classList.add('suspended');
            }
        }
    }

    refreshPagination(){
        if (this.l_orders != null) {
            this.maxPage = Math.floor( this.l_orders.length / this.labels.lbl_Max_Orders_Per_Page ) + 1;
            this.l_ordersToDisplay = this.l_orders.slice(0, this.labels.lbl_Max_Orders_Per_Page);
            this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
        }
        
    }
    nextPage(){
        if(this.currentPage < this.maxPage){
            this.currentPage++;
            this.l_ordersToDisplay = this.l_orders.slice(this.currentPage * this.labels.lbl_Max_Orders_Per_Page - this.labels.lbl_Max_Orders_Per_Page, this.currentPage * this.labels.lbl_Max_Orders_Per_Page);
            this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
        }
    }
    previousPage(){
        if(this.currentPage > 1){
            this.currentPage--;
            this.l_ordersToDisplay = this.l_orders.slice(this.currentPage * this.labels.lbl_Max_Orders_Per_Page - this.labels.lbl_Max_Orders_Per_Page, this.currentPage * this.labels.lbl_Max_Orders_Per_Page);
            this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
        }
    }
    firstPage(){
        this.currentPage = 1;
        this.l_ordersToDisplay = this.l_orders.slice(this.currentPage * this.labels.lbl_Max_Orders_Per_Page - this.labels.lbl_Max_Orders_Per_Page, this.currentPage * this.labels.lbl_Max_Orders_Per_Page);
        this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
    }
    lastPage(){
        this.currentPage = this.maxPage;
        this.l_ordersToDisplay = this.l_orders.slice(this.currentPage * this.labels.lbl_Max_Orders_Per_Page - this.labels.lbl_Max_Orders_Per_Page, this.currentPage * this.labels.lbl_Max_Orders_Per_Page);
        this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
    }

    parseDisplayedOrders(ordersToDisplay){
        for(let ord of ordersToDisplay){            
            ord.showActions = false;
            if(ord.Type === "B2B2C" && ![this.labels.lbl_orderStatus_cancelled_fra, this.labels.lbl_orderStatus_cancelled, "Delegated"].includes(ord.Status)){
                ord.showActions = true;
            }
        }
    }

    onActionTransfererClick(event){
        const orderId = event.target.dataset.id;
        updateOrderStatus({orderId: orderId, status: 'Delegated'})
            .then(() => {
                console.log('UPDATED !!')
                getOrders({filters : this.appliedFilters})
                    .then(results => {
                        /*this.l_orders = results;
                        this.l_ordersToDisplay = results;
                        this.parseDisplayedOrders(this.l_ordersToDisplay);
                        this.refreshPagination();*/
                        location.reload();
                    })
                    .catch(err => {
                        console.log(err);
                    });
            })
            .catch(error => {
                console.error(error);
            });
    }

    onActionCloturerClick(event){
        const orderId = event.target.dataset.id;
        updateOrderStatus({orderId: orderId, status: 'Cancelled'})
            .then(() => {
                console.log('UPDATED !!')
                getOrders({filters : this.appliedFilters})
                    .then(results => {
                        /*this.l_orders = results;
                        this.l_ordersToDisplay = results;
                        this.parseDisplayedOrders(this.l_ordersToDisplay);
                        this.refreshPagination();*/
                        location.reload();
                    })
                    .catch(err => {
                        console.log(err);
                    });
            })
            .catch(error => {
                console.error(error);
            });
    }
}