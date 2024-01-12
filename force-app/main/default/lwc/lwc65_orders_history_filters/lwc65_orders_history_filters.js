import { LightningElement, track } from 'lwc';
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

import { fireEvent } from 'c/pubsub';

import getUserCountry from '@salesforce/apex/lwc65_orders_history_filters_ctrl.getUserCountry';
import getCurrentContact from '@salesforce/apex/lwc65_orders_history_filters_ctrl.getCurrentContact';
import getDealerManagerSegmentationOptions from '@salesforce/apex/lwc65_orders_history_filters_ctrl.getDealerManagerSegmentationOptions';
import getOptionsTimePeriod from '@salesforce/apex/lwc65_orders_history_filters_ctrl.getOptionsTimePeriod';

import lbl_orderFilterTitle from '@salesforce/label/c.LU_Order_Filter_Title';
import lbl_search from '@salesforce/label/c.LU_Order_Filter_Search';

import lbl_timePeriod from '@salesforce/label/c.LU_Order_Filter_Time_Period';
import lbl_timePeriod_today from '@salesforce/label/c.LU_Order_Filter_Time_This_Day';
import lbl_timePeriod_yesterday from '@salesforce/label/c.LU_Order_Filter_Time_This_Two_Days';
import lbl_timePeriod_thisWeek from '@salesforce/label/c.LU_Order_Filter_Time_Period_this_week';
import lbl_timePeriod_thisMonth from '@salesforce/label/c.LU_Order_Filter_Time_Period_this_month';
import lbl_timePeriod_thisCycle from '@salesforce/label/c.LU_Order_Filter_Time_Period_this_cycle';
import lbl_timePeriod_lastWeek from '@salesforce/label/c.LU_Order_Filter_Time_Period_last_week';
import lbl_timePeriod_lastMonth from '@salesforce/label/c.LU_Order_Filter_Time_Period_last_month';
import lbl_timePeriod_lastCycle from '@salesforce/label/c.LU_Order_Filter_Time_Period_last_cycle';


import lbl_orderStatus from '@salesforce/label/c.LU_Order_Filter_Order_Status';
import lbl_orderStatus_draft from '@salesforce/label/c.LU_Order_Filter_Order_Status_Draft';
import lbl_orderStatus_draft_fra from '@salesforce/label/c.LU_Order_Filter_Order_Status_Draft_Fra';
import lbl_orderStatus_invoiced from '@salesforce/label/c.LU_Order_Filter_Order_Status_Invoiced';
import lbl_orderStatus_cancelled from '@salesforce/label/c.LU_Order_Filter_Order_Status_Cancelled';
import lbl_orderStatus_cancelled_fra from '@salesforce/label/c.LU_Order_Filter_Order_Status_Cancelled_Fra';
import lbl_orderStatus_pending from '@salesforce/label/c.LU_Order_Filter_Order_Status_Pending';
import lbl_orderStatus_pending_fra from '@salesforce/label/c.LU_Order_Filter_Order_Status_Pending_Fra';
import lbl_orderStatus_processing from '@salesforce/label/c.LU_Order_Filter_Order_Status_Processing';
import lbl_orderStatus_processing_fra from '@salesforce/label/c.LU_Order_Filter_Order_Status_Processing_Fra';
import lbl_orderStatus_shipped from '@salesforce/label/c.LU_Order_Filter_Order_Status_Shipped';
import lbl_orderStatus_shipped_fra from '@salesforce/label/c.LU_Order_Filter_Order_Status_Shipped_Fra';
import lbl_orderStatus_blocked from '@salesforce/label/c.LU_Order_Filter_Order_Status_Blocked';
import lbl_orderStatus_blocked_fra from '@salesforce/label/c.LU_Order_Filter_Order_Status_Blocked_Fra';
import lbl_orderStatus_sentOrders from '@salesforce/label/c.LU_Order_Filter_Order_Status_Sent_Orders';
import lbl_orderStatus_processingOrders from '@salesforce/label/c.LU_Order_Filter_Order_Status_Processing_Orders';
import lbl_orderStatus_packing from '@salesforce/label/c.LU_Order_Filter_Order_Status_Packing';
import lbl_DealerManagerSegmentation from '@salesforce/label/c.LU_TeamFilters_Dealer_Manager_Segmentation';

import lbl_dealerCode from '@salesforce/label/c.LU_Order_Filter_Dealer_Code';

import lbl_orderType from '@salesforce/label/c.LU_Order_Filter_Order_Type';
import lbl_orderType_ordersOfTheDay from '@salesforce/label/c.LU_Order_Filter_Order_Type_day_order';
import lbl_orderType_draft from '@salesforce/label/c.LU_Order_Filter_Order_Type_draft';
import lbl_orderType_validated from '@salesforce/label/c.LU_Order_Filter_Order_Type_validated';
import lbl_orderType_stanhomeFr from '@salesforce/label/c.LU_Order_Filter_Order_Type_stanhomefr';
import lbl_orderType_ipaper from '@salesforce/label/c.LU_Order_Filter_Order_Type_ipaper';
import lbl_orderType_blocked from '@salesforce/label/c.LU_Order_Filter_Order_Type_blocked';

import lbl_orderType_myStan from '@salesforce/label/c.LU_Order_Filter_Order_Type_myStan';
import lbl_orderType_B2B2C from '@salesforce/label/c.LU_Order_Filter_Order_Type_B2B2C';
import lbl_orderType_B2C from '@salesforce/label/c.LU_Order_Filter_Order_Type_B2C';
import lbl_orderType_nouveauClient from '@salesforce/label/c.LU_Order_Filter_Order_Type_nouveauClient';


import lbl_forWho from '@salesforce/label/c.LU_Order_Filter_For_Who';
import lbl_forWho_me from '@salesforce/label/c.LU_Order_Filter_For_Who_me';
import lbl_forWho_myTeam from '@salesforce/label/c.LU_Order_Filter_For_Who_my_team';
import lbl_forWho_all from '@salesforce/label/c.LU_Order_Filter_For_Who_all';
import lbl_forWho_clientStanhome from '@salesforce/label/c.LU_Order_Filter_For_Who_clientStanhome';
import lbl_forWho_nouveauClient from '@salesforce/label/c.LU_Order_Filter_For_Who_nouveauClient';

import lbl_invoiceStatus from '@salesforce/label/c.LU_Order_Filter_Invoice_Status';
import lbl_invoiceStatus_paid from '@salesforce/label/c.LU_Order_Filter_Invoice_Status_Paid';
import lbl_invoiceStatus_unpaid from '@salesforce/label/c.LU_Order_Filter_Invoice_Status_Unpaid';

export default class Lwc65_orders_history_filters extends LightningElement {
    iconUp = LogoBtn + '/icons/arrow-up.svg';
    iconDown = LogoBtn + '/icons/arrow-down.svg';

    @track contact;
    @track userCountry;

    @track isFRA = false;
    @track isITA = false;

    @track orderSearchedTerms = "";
    @track dealerSearchedTerms = "";
    @track timePeriod = [];
    @track orderStatus = [];
    @track orderType = [];
    @track forWho = [];
    @track invoiceStatus = [];

    @track displayDealerCodeFilter = false;
    @track displayforWhoFilter = false;

    @track displayTimePeriod = false;
    @track displayOrderStatus = false;
    @track displayOrderType = false;
    @track displayForWho = false;
    @track displayOrderStatusFra = false;
    @track displayInvoiceStatus = false;

    @track displayDealerManagerSegmentationMap = false;
    @track optionsDealerManagerSegmentationMap = [];
    @track displayTeamFilter = false;
    @track dmSegmentationOpen = false;
    @track valueDealerManagerSegmentation = [];
    
    @track timePeriodOptionSelected;

    labels = {
        lbl_orderFilterTitle,
        lbl_search,
        lbl_timePeriod,
        lbl_timePeriod_today,
        lbl_timePeriod_yesterday,
        lbl_timePeriod_thisWeek,
        lbl_timePeriod_thisMonth,
        lbl_timePeriod_thisCycle,
        lbl_timePeriod_lastWeek,
        lbl_timePeriod_lastMonth,
        lbl_timePeriod_lastCycle,
        lbl_orderStatus,
        lbl_orderStatus_draft,
        lbl_orderStatus_invoiced,
        lbl_dealerCode,
        lbl_orderType,
        lbl_orderType_ordersOfTheDay,
        lbl_orderType_draft,
        lbl_orderType_validated,
        lbl_orderType_stanhomeFr,
        lbl_orderType_ipaper,
        lbl_orderType_blocked,
        lbl_orderType_myStan,
        lbl_orderType_B2B2C,
        lbl_orderType_B2C,
        lbl_orderType_nouveauClient,
        lbl_forWho,
        lbl_forWho_me,
        lbl_forWho_myTeam,
        lbl_forWho_all,
        lbl_forWho_clientStanhome,
        lbl_forWho_nouveauClient,
        lbl_orderStatus_sentOrders,
        lbl_orderStatus_processingOrders,
        lbl_invoiceStatus,
        lbl_invoiceStatus_paid,
        lbl_invoiceStatus_unpaid,
        lbl_orderStatus_pending,
        lbl_orderStatus_processing,
        lbl_orderStatus_shipped,
        lbl_orderStatus_blocked,
        lbl_orderStatus_draft_fra,
        lbl_orderStatus_pending_fra,
        lbl_orderStatus_processing_fra,
        lbl_orderStatus_shipped_fra,
        lbl_orderStatus_blocked_fra,
        lbl_orderStatus_cancelled,
        lbl_orderStatus_cancelled_fra,
        lbl_orderStatus_packing,
        lbl_DealerManagerSegmentation
    };

    connectedCallback(){

        getUserCountry()
        .then(results => {
            this.userCountry = results;
            if (results === 'FRA'){
                this.isFRA = true;
            } 
            else if (results === 'ITA'){
                this.isITA = true;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        getDealerManagerSegmentationOptions()
        .then(results => {
            this.optionsDealerManagerSegmentationMap = this.getJsonFromMap(JSON.parse(results));

            if(this.optionsDealerManagerSegmentationMap.length > 0){
                this.displayTeamFilter = true;
                this.dmSegmentationOpen = true;
            }

            getCurrentContact() 
            .then(results => {
                this.contact = results;

                if(this.contact.Title === "Direttore di Filiale" || this.contact.Title === "Star Leader" 
                        || this.contact.Title === "Group Sales Consultant" || this.contact.Title === "Zone Manager"
                        || this.contact.Title === "Direttore di Zona"){
                    this.displayDealerCodeFilter = true;
                }
                if(this.contact.LU_Is_Manager__c === true && (this.isITA || !this.displayTeamFilter)){
                    this.displayforWhoFilter = true;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    updateOrderSearchedTerms(event){
        this.orderSearchedTerms = event.target.value;
        fireEvent(this.pageRef, 'lwc65_searchOrder', this.orderSearchedTerms);
    }
    updateDealerSearchedTerms(event){
        this.dealerSearchedTerms = event.target.value;
        fireEvent(this.pageRef, 'lwc65_searchSthid', this.dealerSearchedTerms);
    }

    sendFiltersITA(){
        let filters = {
            timePeriod : this.timePeriod,
            orderStatus : this.orderStatus
        };

        fireEvent(this.pageRef, 'lwc65_filters_order', JSON.stringify(filters));
    }
    sendFiltersFRA(){

        let filters = {
            orderType : this.orderType,
            orderStatus : this.orderStatus,
            forWho : this.forWho,
            invoiceStatus : this.invoiceStatus,
            dealerManagerSegmentation : this.valueDealerManagerSegmentation
        };
        console.log('>>filters');
        console.log(filters);
        fireEvent(this.pageRef, 'lwc65_filters_order', JSON.stringify(filters));
    }

    updateDisplayTimePeriod(event){
        if(this.displayTimePeriod === true){
            this.displayTimePeriod = false;
            event.target.src = this.iconDown;
        }
        else{
            this.displayTimePeriod = true;
            event.target.src = this.iconUp;
        }
    }
    updateDisplayChooseTimePeriod(event){
        //T1680 si besoin, afficher liste déroulante
        let listBoxes = this.template.querySelectorAll(".timePeriodList");
        for (let i = 0; i < listBoxes.length; i++) {
            if(listBoxes[i].name == event.target.className 
             && (listBoxes[i].options.length == 0)) {
                 getOptionsTimePeriod({label : event.target.className})
                 .then(result => {
                     console.log(result);
                     let options = [];
                     for(var key in result){
                         options.push({label:key, value:result[key]});
                        }
                        listBoxes[i].options = options;
                        listBoxes[i].className = listBoxes[i].className.replace('slds-hide', '');
                        event.target.src = this.iconUp;
                    })
                    .catch(error => {
                        console.log('>>>> error lwc65_order_history_filters retreive timeoptions :');
                        console.log(error);
                    });
            }
            else {
                console.log('clique sur la flèche');
                if(!listBoxes[i].className.includes('slds-hide')) {
                    listBoxes[i].className = listBoxes[i].className + ' ' + 'slds-hide';
                }
                listBoxes[i].options = [];
                event.target.src = this.iconDown;
            }
        }
    }
    updateDisplayDealerManagerSegmentationMap(event){
        if(this.displayDealerManagerSegmentationMap === true){
            this.displayDealerManagerSegmentationMap = false;
            event.target.src = this.iconDown;
        }
        else{
            this.displayDealerManagerSegmentationMap = true;
            event.target.src = this.iconUp;
        }
    }
    updateDisplayOrderStatus(event){
        if(this.displayOrderStatus === true){
            this.displayOrderStatus = false;
            event.target.src = this.iconDown;
        }
        else{
            this.displayOrderStatus = true;
            event.target.src = this.iconUp;
        }
    }
    updateDisplayOrderType(event){
        if(this.displayOrderType === true){
            this.displayOrderType = false;
            event.target.src = this.iconDown;
        }
        else{
            this.displayOrderType = true;
            event.target.src = this.iconUp;
        }
    }
    updateDisplayForWho(event){
        if(this.displayForWho === true){
            this.displayForWho = false;
            event.target.src = this.iconDown;
        }
        else{
            this.displayForWho = true;
            event.target.src = this.iconUp;
        }
    }
    updateDisplayOrderStatusFra(event){
        if(this.displayOrderStatusFra === true){
            this.displayOrderStatusFra = false;
            event.target.src = this.iconDown;
        }
        else{
            this.displayOrderStatusFra = true;
            event.target.src = this.iconUp;
        }
    }
    updateDisplayInvoiceStatus(event){
        if(this.displayInvoiceStatus === true){
            this.displayInvoiceStatus = false;
            event.target.src = this.iconDown;
        }
        else{
            this.displayInvoiceStatus = true;
            event.target.src = this.iconUp;
        }
    }

    get optionsTimePeriod(){
        let tableauOptions = [];
        tableauOptions.push({ label : this.labels.lbl_timePeriod_today});
        tableauOptions.push({ label : this.labels.lbl_timePeriod_yesterday});
        tableauOptions.push({ label : this.labels.lbl_timePeriod_thisWeek});
        tableauOptions.push({ label : this.labels.lbl_timePeriod_thisMonth});
        tableauOptions.push({ label : this.labels.lbl_timePeriod_thisCycle});
        tableauOptions.push({ label : this.labels.lbl_timePeriod_lastWeek, islist : true});
        tableauOptions.push({ label : this.labels.lbl_timePeriod_lastMonth, islist : true});
        tableauOptions.push({ label : this.labels.lbl_timePeriod_lastCycle, islist : true});
        return tableauOptions;
    }
    get optionsOrderStatus(){
        return [
            this.labels.lbl_orderStatus_draft,
            this.labels.lbl_orderStatus_invoiced,
            this.labels.lbl_orderStatus_blocked,
            this.labels.lbl_orderStatus_cancelled,
            this.labels.lbl_orderStatus_packing,
            this.labels.lbl_orderStatus_shipped,
            this.labels.lbl_orderStatus_pending,
            this.labels.lbl_orderStatus_processing
        ];
    }
    get optionsOrderType(){
        return [
            // this.labels.lbl_orderType_stanhomeFr,
            // this.labels.lbl_orderType_ipaper,
            // this.labels.lbl_orderType_blocked,            
            this.labels.lbl_orderType_myStan,
            this.labels.lbl_orderType_B2B2C,
            this.labels.lbl_orderType_B2C,
            //this.labels.lbl_orderType_nouveauClient,

        ];
    }
    get optionsForWho(){
        return [
            this.labels.lbl_forWho_me,
            this.labels.lbl_forWho_myTeam,
            this.labels.lbl_forWho_clientStanhome,
            this.labels.lbl_forWho_nouveauClient,
            //this.labels.lbl_forWho_all
        ];
    }
    get optionsOrderStatusFra(){
        return [
            {label : this.labels.lbl_orderType_ordersOfTheDay, value : this.labels.lbl_orderType_ordersOfTheDay},
            {label : this.labels.lbl_orderStatus_draft_fra, value : this.labels.lbl_orderStatus_draft},
            {label : this.labels.lbl_orderStatus_pending_fra, value : this.labels.lbl_orderStatus_pending},
            {label : this.labels.lbl_orderStatus_processing_fra, value : this.labels.lbl_orderStatus_processing},
            {label : this.labels.lbl_orderStatus_shipped_fra, value : this.labels.lbl_orderStatus_shipped},
            {label : this.labels.lbl_orderStatus_cancelled_fra, value : this.labels.lbl_orderStatus_cancelled},
            {label : this.labels.lbl_orderStatus_blocked_fra, value : this.labels.lbl_orderStatus_blocked}
        ];
    }
    get optionsInvoiceStatus(){
        return [
            this.labels.lbl_invoiceStatus_paid,
            this.labels.lbl_invoiceStatus_unpaid
        ];
    }
    get optionsInvoiceStatusITA(){
        return [
            this.labels.lbl_invoiceStatus_paid,
            this.labels.lbl_invoiceStatus_unpaid
        ];
    }

    selectionOptionTimePeriod(event){
        this.timePeriodOptionSelected = event.target.value;

        //vérifier si la checkbox est cochée, si oui uploader les valeurs
        let checkboxes = this.template.querySelectorAll(".timePeriod");
        for (let i = 0; i < checkboxes.length; i++) {
            if(checkboxes[i].value == event.target.name){
                checkboxes[i].checked = true
                this.timePeriod = [];
                this.timePeriod.push(this.timePeriodOptionSelected); 
                this.sendFiltersITA();
            }
            else checkboxes[i].checked = false
        }
    }

    updateTimePeriodValue(event){
        this.timePeriod = [];
        let checkboxes = this.template.querySelectorAll(".timePeriod");
        
        for (let i = 0; i < checkboxes.length; i++) {
            // T1680 JJE 08/07/2020 - décocher les autres cases si une est sélectionnée
            if(checkboxes[i].value != event.target.value) checkboxes[i].checked = false;
            if (checkboxes[i].checked === true) {

                //Aller chercher l'option qui correspond dans le composant list si applicable
                if(checkboxes[i].value == this.labels.lbl_timePeriod_lastWeek 
                 || checkboxes[i].value == this.labels.lbl_timePeriod_lastMonth 
                 || checkboxes[i].value == this.labels.lbl_timePeriod_lastCycle){
                    this.timePeriod.push(this.timePeriodOptionSelected);
                }
                else this.timePeriod.push(checkboxes[i].value);
            }
        }
        console.log('flitres : ' + this.timePeriod);
        
        this.sendFiltersITA();
    }
    updateOrderStatusValue(){
        this.orderStatus = [];
        let checkboxes = this.template.querySelectorAll(".orderStatus");

        for (let i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked === true) {
                this.orderStatus.push(checkboxes[i].value);
            }
        }

        this.sendFiltersITA();
    }
    updateOrderTypeValue(){
        this.orderType = [];
        let checkboxes = this.template.querySelectorAll(".orderType");

        for (let i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked === true) {
                this.orderType.push(checkboxes[i].value);
            }
        }

        console.log(this.orderType);
        this.sendFiltersFRA();
    }
    updateForWhoValue(){
        this.forWho = [];
        let checkboxes = this.template.querySelectorAll(".forWho");

        for (let i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked === true) {
                this.forWho.push(checkboxes[i].value);
            }
        }

        this.sendFiltersFRA();
    }
    updateOrderStatusValueFRA(){
        this.orderStatus = [];
        let checkboxes = this.template.querySelectorAll(".orderStatus");

        for (let i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked === true) {
                this.orderStatus.push(checkboxes[i].value);
            }
        }

        this.sendFiltersFRA();
    }
    updateInvoiceStatusValue(){
        this.invoiceStatus = [];
        let checkboxes = this.template.querySelectorAll(".invoiceStatus");

        for (let i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked === true) {
                this.invoiceStatus.push(checkboxes[i].value);
            }
        }

        this.sendFiltersFRA();
    }
    updateDealerManagerSegmentation(){
        this.valueDealerManagerSegmentation = [];

        let checkboxes = this.template.querySelectorAll(".accordeonCheckbox");

        for (let i = 0 ; i < checkboxes.length ; i++) {
            if(checkboxes[i].checked === true){
                this.valueDealerManagerSegmentation.push(checkboxes[i].dataset.id);
            }
        }

        this.sendFiltersFRA();
    }

    getJsonFromMap(myMap){
        let regexLabel = /label=(.*?),/;// /(?<=label=)(.*?)(?=,)/;
        let regexValue = /value=(.*?)]/;// /(?<=value=)(.*?)(?=])/;
        let array = [];
        for(let key of Object.keys(myMap) ){
            
            let a = {
                label: regexLabel.exec(key)[1],
                value: regexValue.exec(key)[1],
                childs: this.getJsonFromMap(JSON.parse(myMap[key]))
            };
            array.push(a);
        }
        return array;
    }
}