import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getOrders from '@salesforce/apex/lwc86_contact_detail_order_history_ctrl.getOrders';
//import getOrdersForContact from '@salesforce/apex/lwc86_contact_detail_order_history_ctrl.getOrdersForContact';
import getContact from '@salesforce/apex/lwc86_contact_detail_order_history_ctrl.getContact';
import getUserCountry from '@salesforce/apex/lwc86_contact_detail_order_history_ctrl.getUserCountry';

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

export default class Lwc86_contact_detail_new_order_history extends NavigationMixin(LightningElement) {
    iconFilter = LogoBtn + '/icons/btn_filters.png';

    @track displayComponent = false;

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

    /* LABELS */
    labels = {
        lbl_search,
        lbl_Title,
        lbl_Max_Orders_Per_Page,
        lbl_pagination_postion,
        LU_Order_Column_Contact,
        LU_Order_Column_Account
    }

    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.orderObject.Name = data.fields.Name.label;
            this.orderObject.AccountId = data.fields.AccountId.label;
            this.orderObject.Type = data.fields.Type.label;
            this.orderObject.Status = data.fields.Status.label;
            this.orderObject.EffectiveDate = data.fields.EffectiveDate.label;
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
        }
        else if (error){
            console.log('>>>> error lwc86 contactInfo:');
            console.log(error);
        }
    }
    connectedCallback(){
        let parameters = this.getQueryParameters();

        getUserCountry()
            .then(results => {
                
                if(results === "FRA"){
                    this.isFRA = true;
                    console.log('contact Id : ');
                    console.log(parameters.id);
                }
                else if(results === "ITA"){
                    this.isITA = true;
                }
            })
        .catch(error => {
            console.log('>>>> error lwc86 getUserCountry :');
            console.log(error);
        });

        getOrders({idContact : parameters.id})
            .then(results => {
                if(this.l_orders){
                    this.displayComponent = true;
                }

                this.l_orders = results;
                this.l_ordersToDisplay = results;

                this.refreshPagination();
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        getContact()
            .then(results => {
                this.contact = results;
                console.log("result contact:");
                console.log(this.contact);
                if(this.contact.Title === "Direttore di Filiale" || this.contact.Title == 'Star Leader' || this.contact.Title == 'Zone Manager') {
                    this.isDirector = true;
                }
            })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    /* UI METHODS */
    navigateToOrder(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'Order',
                actionName: 'view'
            }
        });
    }

    renderedCallback(){
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
}