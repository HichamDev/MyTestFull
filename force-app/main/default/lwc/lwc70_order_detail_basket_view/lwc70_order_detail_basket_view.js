/* eslint-disable guard-for-in */
/* eslint-disable no-console */
/* eslint-disable vars-on-top */
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/*pubsub*/
import { fireEvent, registerListener } from 'c/pubsub';

/* IMPORT STATIC RESSOURCES */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';


/* IMPORT APEX METHODS */
// import emptyBasket from '@salesforce/apex/LWC22_Basket_View_Ctrl.emptyOrder';
// import deleteBasket from '@salesforce/apex/LWC22_Basket_View_Ctrl.deleteLineItemFromContact';
// import getUserCountry from '@salesforce/apex/LWC22_Basket_View_Ctrl.getCurrentUserCountry';
import getBasket from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.getOrderById';
import updateBasketLineQuantity from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.updateLineQuantityById';
import deleteLineBasket from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.deleteLineById';
import deleteBasket from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.deleteLinesAssociatedToContactId';
import deleteOrder from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.deleteOrderById';
import getUserConnectedAbilitation from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.getUserConnectedRights';
import getUserCountry from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.getUserCountry';
// import deleteBasketWithoutType from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.deleteLinesAssociatedToContactIdWithoutOfferType';
import updateStatusDeleteStockUsed from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.updateStatusDeleteStockUsed';
import controlBundle from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.controlBundle';
import putOrderOnNewCase from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.putOrderOnNewCase';
import validateOrderOLA from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.validateOrderOLA';
import getCounters from '@salesforce/apex/Lwc62_orderhome_fidelity_ctrl.getCountersByCategory';
import getHasDraftOrder from '@salesforce/apex/Lwc62_orderhome_fidelity_ctrl.getHasDraftOrder';

/* IMPORT VARIABLES */
import USER_ID from '@salesforce/user/Id';

/* IMPORT LABELS */
import lbl_Img_Basket_Delete from '@salesforce/label/c.LU_Img_Basket_Delete';
import lbl_Empty_Success from '@salesforce/label/c.LU_Basket_Empty_Success';
import lbl_Basket_Empty from '@salesforce/label/c.Lu_Basket_Empty';
import lbl_no_order_found from '@salesforce/label/c.Lu_No_Order_Found';
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Empty_Sure_Question from '@salesforce/label/c.LU_Basket_Empty_Sure_Question';
import lbl_Empty_Order_Question from '@salesforce/label/c.LU_Basket_Order_Empty_Sure_Question';
import lbl_Empty_Order_Confirmation from '@salesforce/label/c.LU_Basket_Order_Empty_Confirmation';
import lbl_Empty_Order_Delete from '@salesforce/label/c.LU_Order_Empty';
import lbl_NoBasket from '@salesforce/label/c.LU_Basket_NoBasket';
import lbl_Img_Basket_Checkout from '@salesforce/label/c.LU_Img_Basket_Checkout';
import lbl_Total_ValidAmountBase from '@salesforce/label/c.LU_Basket_Total_TotalValidAmountBase';
import lbl_Total_WithoutTaxes from '@salesforce/label/c.LU_Basket_Total_WithoutTax';
import lbl_Total_Total from '@salesforce/label/c.LU_Basket_Total_Total';
import lbl_minus_quantity from '@salesforce/label/c.LU_Basket_Minus_Quantity';
import lbl_plus_quantity from '@salesforce/label/c.LU_Basket_Plus_Quantity';
import lbl_delete_line from '@salesforce/label/c.LU_Basket_Delete_Line';
import lbl_continue_basket from '@salesforce/label/c.LU_Basket_Continue_Basket';
import lbl_delete_basket from '@salesforce/label/c.LU_Basket_Delete_Basket';
import lbl_order_continue from '@salesforce/label/c.LU_Order_Continue';
import lbl_order_delete from '@salesforce/label/c.LU_Order_Delete';
import lbl_order_confirm from '@salesforce/label/c.LU_Order_Confirm';
import lbl_basket_total from '@salesforce/label/c.LU_Basket_Total';
import lbl_HT from '@salesforce/label/c.LU_HT';
import lbl_TTC from '@salesforce/label/c.LU_TTC';
import lbl_title from '@salesforce/label/c.LU_Order_Title_Recap';
import lbl_picklist_order_by_title from '@salesforce/label/c.LU_0rder_Detail_Picklist_Order_By_Title';
import lbl_by_catalog from '@salesforce/label/c.LU_0rder_Detail_By_Catalog';
import lbl_by_customer from '@salesforce/label/c.LU_0rder_Detail_By_Customer';
import lbl_order_complement from '@salesforce/label/c.LU_Order_Detail_Button_Order_Complement';
import lbl_bundle_title from '@salesforce/label/c.LU_Basket_Bundle_Selection_Title';
import lbl_bundle_cancel from '@salesforce/label/c.LU_Basket_Bundle_Selection_Cancel';
import lbl_bundle_save from '@salesforce/label/c.LU_Basket_Bundle_Selection_Save';
import lbl_accepted_cdv from '@salesforce/label/c.LU_Basket_Checkbox_Accept_CDV';
import lbl_page_order_tab from '@salesforce/label/c.LU_TECH_Community_Page_Order_Tab';
import lbl_bundlemaxnotreaded from '@salesforce/label/c.LU_Basket_Bundle_MaxQuantityNotReached';
import lbl_basketWarning from '@salesforce/label/c.LU_Basket_Warning';
import lbl_basketNotPending from '@salesforce/label/c.LU_Basket_NotPendingMsg';
import lbl_basketNotUsingPoints from '@salesforce/label/c.LU_Basket_NotUsingPoints';
import lbl_newCase from '@salesforce/label/c.SAV_NewCase';


export default class Lwc70_order_detail_basket_view extends NavigationMixin(LightningElement) {

    /* LABELS */
    labels = {
        lbl_HT,
        lbl_title,
        lbl_TTC,
        lbl_Img_Basket_Delete,
        lbl_Empty_Order_Question,
        lbl_Empty_Order_Confirmation,
        lbl_Empty_Success,
        lbl_Basket_Empty,
        lbl_Empty_Order_Delete,
        lbl_Close,
        lbl_Empty_Sure_Question,
        lbl_NoBasket,
        lbl_Img_Basket_Checkout,
        lbl_Total_ValidAmountBase,
        lbl_Total_WithoutTaxes,
        lbl_Total_Total,
        lbl_minus_quantity,
        lbl_plus_quantity,
        lbl_delete_line,
        lbl_continue_basket,
        lbl_basket_total,
        lbl_delete_basket,
        lbl_no_order_found,
        lbl_order_continue,
        lbl_order_delete,
        lbl_order_confirm,
        lbl_picklist_order_by_title,
        lbl_by_catalog,
        lbl_by_customer,
        lbl_order_complement,
        lbl_bundle_title,
        lbl_bundle_cancel,
        lbl_bundle_save,
        lbl_accepted_cdv,
        lbl_newCase,
        lbl_bundlemaxnotreaded
    }

    /* ICONS */
    iconEdit = LogoBtn + '/icons/icon-edit.svg';
    iconDelete = LogoBtn + '/icons/icon-delete.svg';
    iconAdd = LogoBtn + '/icons/icon-add.svg';
    iconLess = LogoBtn + '/icons/icon-less.svg';

    @api recordId;

    /* VARIABLES */
    currentUserId = USER_ID;
    orderStatus;
    orderType;
    @track orderId;
    orderDate;
    orderTotal;
    orderTotalWithoutVAT;
    orderTotalValidBase;
    orderBoTotalWithoutTaxes;
    orderBoTotalWithTaxes;
    @track baskets = [];
    @track basketsByType = [];
    @track basketsByPerson = [];
    @track basketsByCatalog = [];
    @track error;
    @track openDelete;
    @track openDeleteOrder;
    @track deleteBasketOfContactId = null;
    @track deleteBaskttOfOfferType = null;
    @track displayWithoutTax = false;
    @track isOrderValidated = true;
    @track canOrderOnBehalf = false;
    @track canEditOrder = false;
    @track isOLA = false;
    @track connectedContact = null;

    path_OrderObject = "/order/";
    @track isLoading = false;
    @track displayVAT = false;

    @track userCountry;
    @track isFRA = false;
    @track isITA = false;
    @track displayByCustomerFRA = false;
    @track displayByCustomerITA = false;
    @track displayByCatalog = false;

    @track isFRAOrderValidated = false;

    @track displayOrderComplementButton = false;

    @track valueOrderBy = this.labels.lbl_by_customer;

    @track acceptedCDV = true;
    @track displayCGV = false;

    @track displayBoTotal = false;
    @track smartPTSCreditValueOnOrder = 0;
    @track smartPTSDebitValueOnOrder = 0;
    @track hotesseCreditValueOnOrder = 0;
    @track hotesseDebitValueOnOrder = 0;

    /* INIT */
    connectedCallback() {
        registerListener('updateLoyalty', this.updateCounters, this);


        //Display the spinner
        this.isLoading = true;

        //Get order id in the URL
        // let pageUrl = new URL(window.location.href);
        // let pathname = pageUrl.pathname;

        let pathname = window.location.href;

        if (pathname.includes(this.path_OrderObject)) {

            let indexOf_OrderObject = pathname.indexOf(this.path_OrderObject);
            let str_withId = pathname.substr(indexOf_OrderObject + this.path_OrderObject.length);
            let indexOf_slash = str_withId.indexOf("/");
            this.orderId = str_withId.substring(0, indexOf_slash);
            console.log("this.orderId");
            console.log(this.orderId);
        }

        getUserCountry()
        .then(result => {
            this.userCountry = result;
            console.log("this.userCountry");
            console.log(this.userCountry);

            if(this.userCountry === 'FRA'){
                this.displayByCustomerFRA = true;
                this.isFRA = true;
            }
            else if(this.userCountry === 'ITA'){
                this.displayByCustomerITA = true;
                this.isITA = true;
            }
        })
        .catch(error => {
            console.log(">>>error");
            console.log(error);

            // Hide the spinner
            this.isLoading = false;
        });

        // Get current user abilitation to order on behalf
        getUserConnectedAbilitation()
        .then(data => {
            if (data) {
                console.log('>>> data connected user');
                console.log(data);
                this.connectedContact = data.connectedContact;
                this.canOrderOnBehalf = data.canOrderOnBehalf;
            }

            console.log("this.orderId");
            console.log(this.orderId);
            if (this.orderId != null) {
                this.fetchBasket();
            }
        })
        .catch(error => {
            console.log(">>>error");
            console.log(error);

            // Hide the spinner
            this.isLoading = false;
        });

        getCounters()
        .then(results => {
            console.log('>>> lwc70: getCounters 1');
            console.log('>>> COUNTERS: ');
            console.log(results);
            // this.l_counterCategories = results.filter( category => (category.name === '1. Comptes'));
            results.forEach((category) => {
                if(category.name === 'Comptes') {
                    console.log(category.l_counters);
                    category.l_counters.forEach((counter) => {
                        if (counter.id == 'counter1') {
                            this.smartPTSCreditValueOnOrder = counter.creditValueOnOrder;
                            this.smartPTSDebitValueOnOrder = counter.debitValueOnOrder;
                        } else if (counter.id == 'counter2') {
                            this.hotesseCreditValueOnOrder = counter.creditValueOnOrder;
                            this.hotesseDebitValueOnOrder = counter.debitValueOnOrder;
                        }
                    });
                }
            });
            console.log('smartPTS creditValueOnOrder: ' + this.smartPTSCreditValueOnOrder);
            console.log('smartPTS debitValueOnOrder: ' + this.smartPTSDebitValueOnOrder);
            console.log('hotesse creditValueOnOrder: ' + this.hotesseCreditValueOnOrder);
            console.log('hotesse debitValueOnOrder: ' + this.hotesseDebitValueOnOrder);
            })
        .catch(error => {
            console.log('>>>> error lwc70_order_detail_basket_views :');
            console.log(error);
        });

    }


    /* BUSINESS METHODS */

    // Get the baskets of the order of this.orderId
    fetchBasket() {

        // Display the spinner
        this.isLoading = true;
        this.displayOrderComplementButton = false;
        this.displayCGV = false;
        this.acceptedCDV = true;

        getBasket({ orderId: this.orderId, orderBy: this.valueOrderBy })
            .then(data => {

                console.log("data");
                console.log(data);

                if (data) {

                    if(data.status == "Pending" && data.allowedPaymentMode != null && 
                        !data.allowedPaymentMode.includes("CBP") && this.userCountry == 'FRA'){
                        this.displayOrderComplementButton = true;
                    }

                    if(this.valueOrderBy === this.labels.lbl_by_customer && this.userCountry === 'ITA'){

                        // for (const [type, baskets] of data.mBasketsByType.entries()) {
                        //     for (const [id, basket] of baskets.entries()) {
                        //         for(const line of basket.lines){
                        //             for (let i = 0; i < 21; i++) {
                        //                 let fie = "LU_Counter_" + i + "_Value__c";
                        //                 if(this.connectedContact[fie] === null || line[fie] === null || line[fie] < 0){
                        //                     delete line[fie];
                        //                 }
                        //             }
                        //         }
                        //     }
                        // }

                        this.orderStatus = null;
                        this.orderType = null;
                        this.orderDate = null;
                        this.orderTotal = null;
                        this.orderTotalWithoutVAT = null;
                        this.orderTotalValidBase = null;
                        let cpt = 0;

                        // Manage the baskets' type
                        this.basketsByType = [];
                        this.basketsByCatalog = [];
                        this.basketsByPerson = [];
                        let var_basketByType = data.mBasketsByType;
                        for (let key in var_basketByType) {

                            let baskets = var_basketByType[key].baskets;

                            let mBasket = [];
                            for (let keyBasket in baskets) {

                                for(let parent in baskets[keyBasket].lines){
                                    let l_childs = [];
                                    for(let child in baskets[keyBasket].l_childs){
                                        if(baskets[keyBasket].l_childs[child].Product2Id === baskets[keyBasket].lines[parent].Product2Id){
                                            l_childs.push(baskets[keyBasket].l_childs[child]);
                                            console.log(baskets[keyBasket].l_childs[child]);
                                        }
                                    }
                                    baskets[keyBasket].lines[parent].l_childs = l_childs;
                                }

                                mBasket.push( { value : baskets[keyBasket], key : baskets[keyBasket].contact } );
                            }

                            cpt++;
                            this.basketsByType.push( { value : mBasket, key : var_basketByType[key].basketType } );

                        }
                        this.orderStatus = data.status;
                        this.orderType = data.orderType;
                        this.orderDate = data.dateOrder;
                        this.orderTotal = data.totalOrder;
                        this.orderTotalWithoutVAT = data.totalWithoutVATOrder;
                        this.orderTotalValidBase = data.totalValidForTotalBase;
                        if (data.externalId != null) {
                            if (data.externalId.startsWith('FRA')) {
                                this.displayVAT = true;
                            }
                        }

                        if (this.orderStatus !== 'Draft') {
                            this.isOrderValidated = true;
                            this.canEditOrder = false;
                            this.isOLA = false;
                        } 
                        else if(this.orderType === 'B2C'){
                            this.isOrderValidated = false;
                            this.canEditOrder = false;
                            this.isOLA = true;
                        }
                        else {
                            this.isOrderValidated = false;
                            if (this.connectedContact.Id === data.dealerOfOrder || this.canOrderOnBehalf) {
                                this.canEditOrder = true;
                            }

                        }
                    }
                    else if(this.valueOrderBy === this.labels.lbl_by_customer && this.userCountry === 'FRA'){
                        this.orderStatus = null;
                        this.orderType = null;
                        this.orderDate = null;
                        this.orderTotal = null;
                        this.orderTotalWithoutVAT = null;
                        this.orderTotalValidBase = null;
                        let cpt = 0;

                        // Manage the baskets' type
                        this.basketsByPerson = [];
                        this.basketsByType = [];
                        this.basketsByCatalog = [];

                        for (var key in data.mBasketsByPerson) {

                            if(!this.displayCGV && data.status == "Draft" ){
                                for(let line in data.mBasketsByPerson[key].basket.lines){
                                    if(data.mBasketsByPerson[key].basket.lines[line].PricebookEntry.LU_Offer_type__c.includes('PUP')){
                                        this.displayCGV = true;
                                        this.acceptedCDV = false;
                                    }
                                }
                            }

                            for(let parent in data.mBasketsByPerson[key].basket.lines){
                                data.mBasketsByPerson[key].basket.lines[parent].l_childs = [];
                                let l_childs = [];
                                for(let child in data.mBasketsByPerson[key].basket.l_childs){
                                    if(data.mBasketsByPerson[key].basket.l_childs[child].Product2Id === data.mBasketsByPerson[key].basket.lines[parent].Product2Id){
                                        l_childs.push(data.mBasketsByPerson[key].basket.l_childs[child]);
                                    }
                                }
                                data.mBasketsByPerson[key].basket.lines[parent].l_childs = l_childs;
                            }

                            cpt++;

                          /*  if(data.clientFirstName && data.clientLastName){
                                data.mBasketsByPerson[key].person.firstname = data.clientFirstName;
                                data.mBasketsByPerson[key].person.lastname = data.clientLastName;
                            } */
                            console.log(data.mBasketsByPerson[key]);
                            this.basketsByPerson.push( { value : data.mBasketsByPerson[key].basket, key : data.mBasketsByPerson[key].person, isChall : data.mBasketsByPerson[key].person.lastname == 'Challenge'});

                        }
                        console.log('xxxxxx basketsByPerson xxxxxxx', this.basketsByPerson);
                        
                        this.orderStatus = data.status;
                        this.orderDate = data.dateOrder;
                        this.orderTotal = data.totalOrder;
                        this.orderTotalWithoutVAT = data.totalWithoutVATOrder;
                        this.orderTotalValidBase = data.totalValidForTotalBase;
                        this.orderBoTotalWithoutTaxes = data.bo_total_without_taxes;
                        this.orderBoTotalWithTaxes = data.bo_total_with_taxes;
                        if (data.externalId != null) {
                            if (data.externalId.startsWith('FRA')) {
                                this.displayVAT = true;
                            }
                        }

                        if(this.orderStatus === 'Invoiced' || this.orderStatus === 'Shipped' || this.orderStatus === 'Archived' || this.orderStatus === 'Cancelled' || this.orderStatus === 'Blocked'){
                            if(this.userCountry === 'FRA' && data.orderType === 'LineUp'){
                                this.displayBoTotal = true;
                            }
                        }
                        if (this.orderStatus !== 'Draft') {
                            if(this.orderStatus !== 'Pending' && this.orderStatus !== 'Processing' && this.orderStatus !== 'Blocked')this.isFRAOrderValidated = true;
                            this.isOrderValidated = true;
                            this.canEditOrder = false;
                        }
                        else {
                            this.isOrderValidated = false;
                            if (this.connectedContact.Id === data.dealerOfOrder || this.canOrderOnBehalf) {
                                this.canEditOrder = true;
                            }
                        }
                    }
                    else{
                        this.orderStatus = null;
                        this.orderType = null;
                        this.orderDate = null;
                        this.orderTotal = null;
                        this.orderTotalWithoutVAT = null;
                        this.orderTotalValidBase = null;
                        let cpt = 0;

                        // Manage the baskets' type
                        this.basketsByCatalog = [];
                        this.basketsByType = [];
                        this.basketsByPerson = [];
                        console.log('basket catalog : ' + JSON.stringify(data.mBasketsByCatalog));
                        console.log(data.mBasketsByCatalog);
                        for (var key in data.mBasketsByCatalog) {
                            if(!this.displayCGV && this.userCountry === 'FRA' && data.status == "Draft" ){

                                for(let line in data.mBasketsByCatalog[key].basket.lines){

                                    if (data.mBasketsByCatalog[key].basket.lines[line].PricebookEntry.LU_Offer_type__c.includes('PUP')) {
                                    // if(line.PricebookEntry.LU_Offer_Type__c.contains('PUP')){
                                        this.displayCGV = true;
                                        this.acceptedCDV = false;
                                    }
                                }
                            }

                            for(let parent in data.mBasketsByCatalog[key].basket.lines){
                                data.mBasketsByCatalog[key].basket.lines[parent].l_childs = [];
                                let l_childs = [];
                                for(let child in data.mBasketsByCatalog[key].basket.l_childs){
                                    if(data.mBasketsByCatalog[key].basket.l_childs[child].Product2Id === data.mBasketsByCatalog[key].basket.lines[parent].Product2Id){
                                        l_childs.push(data.mBasketsByCatalog[key].basket.l_childs[child]);
                                    }
                                }
                                data.mBasketsByCatalog[key].basket.lines[parent].l_childs = l_childs;
                            }

                            cpt++;
                            this.basketsByCatalog.push( { value : data.mBasketsByCatalog[key].basket, key : data.mBasketsByCatalog[key].basketType} );

                        }
                        
                        this.orderStatus = data.status;
                        this.orderType = data.orderType;
                        this.orderDate = data.dateOrder;
                        this.orderTotal = data.totalOrder;
                        this.orderTotalWithoutVAT = data.totalWithoutVATOrder;
                        this.orderTotalValidBase = data.totalValidForTotalBase;
                        this.orderBoTotalWithoutTaxes = data.bo_total_without_taxes;
                        this.orderBoTotalWithTaxes = data.bo_total_with_taxes;
                        if (data.externalId != null) {
                            if (data.externalId.startsWith('FRA')) {
                                this.displayVAT = true;
                            }
                        }
                        
                        if(this.orderStatus === 'Processing' || this.orderStatus === 'Invoiced' || this.orderStatus === 'Shipped' || this.orderStatus === 'Archived' || this.orderStatus === 'Cancelled' || this.orderStatus === 'Blocked'){
                            if(this.userCountry === 'FRA' && data.orderType === 'LineUp'){
                                this.displayBoTotal = true;
                            }
                        }
                        if (this.orderStatus !== 'Draft') {
                            this.isFRAOrderValidated = true;
                            this.isOrderValidated = true;
                            this.canEditOrder = false;
                        } 
                        else if(this.orderType === 'B2C' && this.userCountry === 'ITA'){
                            this.isOrderValidated = false;
                            this.canEditOrder = false;
                            this.isOLA = true;
                        }
                        else {
                            this.isOrderValidated = false;
                            if (this.connectedContact.Id === data.dealerOfOrder || this.canOrderOnBehalf) {
                                this.canEditOrder = true;
                            }

                        }
                    }

                } else {
                    this.basketsByType = null;
                }
                
                // Recalculate the subtotals
                fireEvent(null, 'basketUpdated', null);

                // Hide the spinner
                this.isLoading = false;

            })
            .catch(error => {
                console.log(">>>error");
                console.log(error);

                // Hide the spinner
                this.isLoading = false;
            });

    }

    /* UI METHODS */

    // Decrease by 1 the quantity amount of a line
    handleQuantityDown(event) {

        // Display the spinner
        this.isLoading = true;
        
        let lineId = event.target.dataset.id;
        let lineQuantity = event.target.dataset.quantity;

        console.log(lineId);
        
        // if the quantity is more than 1
        if (lineQuantity - 1 >= 1) {

            updateBasketLineQuantity({ lineId: lineId, q: lineQuantity - 1 })
            .then(result => {
                // if(result !== ""){
                //     alert(result);
                // }
                // else{
                    this.fetchBasket();
                    fireEvent(this.pageRef, 'basketUpdated', "");
                    fireEvent(this.pageRef, 'updateLoyalty', null);
                    fireEvent(this.pageRef, 'lwc80_refresh', lineId);
                    // Hide the spinner
                    this.isLoading = false;
                //}
            })
            .catch(error => {
                console.log(">>>error");
                console.log(error);

                // Hide the spinner
                this.isLoading = false;
            });
        } else {
            // Hide the spinner
            this.isLoading = false;
        }
    }

    // Increase by 1 the quantity amount of a line
    handleQuantityUp(event) {

        // Display the spinner
        this.isLoading = true;

        let lineId = event.target.dataset.id;
        let lineQuantity = event.target.dataset.quantity;
        
        lineQuantity ++;

        updateBasketLineQuantity({ lineId: lineId, q: lineQuantity})
        .then(result => {
            // if(result !== ""){
            //     alert(result);
            // }
            // else{
                this.fetchBasket();
                fireEvent(this.pageRef, 'basketUpdated', "");
                fireEvent(this.pageRef, 'updateLoyalty', null);
                fireEvent(this.pageRef, 'lwc80_refresh', lineId);
                // Hide the spinner
                this.isLoading = false;
            //}
        })
        .catch(error => {
            console.log(">>>error");
            console.log(error);
            // Hide the spinner
            this.isLoading = false;
        });
    }

    // Delete a line of basket
    handleLineDelete(event) {

        // Display the spinner
        this.isLoading = true;

        let lineId = event.target.dataset.id;

        deleteLineBasket({ lineId: lineId })
        .then(result => {
            
            this.fetchBasket();
            fireEvent(this.pageRef, 'updateLoyalty', null);
            // loading hiden in the fetchbasket method
        })
        .catch(error => {
            console.log(">>>error");
            console.log(error);
            // Display the spinner
            this.isLoading = false;
        });
    }

    // Open the delete popup
    handleOpenDelete(event) {
        this.deleteBasketOfContactId = event.target.dataset.contactid;
        this.deleteBaskttOfOfferType = event.target.dataset.offertype;
        this.openDelete = true;
    }

    // Close delete popup
    handleCloseDeletePopup(event) {
        this.openDelete = false;
    }

    // Delete the basket
    handleDeleteValidation(event) {
        
        // Display the spinner
        this.isLoading = true;

        deleteBasket({ contactId: this.deleteBasketOfContactId, 
                        offerType: this.deleteBaskttOfOfferType,
                        orderId: this.orderId })
            .then(result => {

                this.openDelete = false;
                this.deleteBasketOfContactId = null;
                this.deleteBaskttOfOfferType = null;
                this.fetchBasket();
                fireEvent(this.pageRef, 'updateLoyalty', null);
                // Spinner is hidden in the fetchbasket method
            })
            .catch(error => {
                console.log(">>>error");
                console.log(error);
                // Hide the spinner
                this.isLoading = false;
            });
    }

    // Delete the basket
    // handleDeleteValidationWithoutType(event) {

    //     console.log("without type");

    //     // Display the spinner
    //     this.isLoading = true;

    //     deleteBasketWithoutType({ contactId: this.deleteBasketOfContactId, 
    //                               orderId: this.orderId })
    //         .then(result => {

    //             this.openDelete = false;
    //             this.deleteBasketOfContactId = null;
    //             this.deleteBaskttOfOfferType = null;
    //             this.fetchBasket();
    //             // Spinner is hidden in the fetchbasket method
    //         })
    //         .catch(error => {
    //             console.log(">>>error");
    //             console.log(error);
    //             // Hide the spinner
    //             this.isLoading = false;
    //         });
    // }

    // Navigate to order-home page
    handleNavigateToOrderHome(event) {

        //window.location.href = "?orderId=" + this.orderId;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'order-home',
            },
            state: {
                orderId: this.orderId
            },
        });
    }

    // Continue basket of contact
    handleNavigateToOrderHomeWithContactId(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'order-home',
            },
            state: {
                idContact: event.target.dataset.contactid,
                orderId: this.orderId
            },
        });
    }

    // Navigate to checkout page
    async handleGoToCheckoutPage(event) {
        console.log('user country '+ this.userCountry);
        if(this.userCountry == 'FRA' ) {
            console.log('display popup');
            console.log((this.smartPTSCreditValueOnOrder > 0 && this.smartPTSDebitValueOnOrder == 0) ||
            (this.hotesseCreditValueOnOrder > 0 && this.hotesseDebitValueOnOrder == 0));
            if ((this.smartPTSCreditValueOnOrder > 0 && this.smartPTSDebitValueOnOrder == 0) ||
            (this.hotesseCreditValueOnOrder > 0 && this.hotesseDebitValueOnOrder == 0)) {
                console.log('display popup');
                const evt = new ShowToastEvent({
                    title: lbl_basketNotUsingPoints,
                    message: "",
                    variant: "success"
                });
                this.dispatchEvent(evt);
                await new Promise(r => setTimeout(r, 6000));
            } 
        }

        controlBundle({ orderId : this.orderId })
        .then(result => {
            if (result) {
                if (result === "OK") {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'order-checkout',
                        },
                        state: {
                            orderId: this.orderId
                        },
                    });
                }
                else { // If the order is not ok

                    const evtError = new ShowToastEvent({
                        title: result.split('###')[0],
                        message: result.split('###')[1],
                        variant: 'error'
                    });
                    this.dispatchEvent(evtError);
                }
            }
        })
        .catch(error => {
            console.log(">>>error");
            console.log(error);
            // Hide the spinner
            this.isLoading = false;
        });
    }

    // Open popup delete order
    handleCancelOrder(event) {
        this.openDeleteOrder = true;
    }

    // Close popup delete order
    handleCloseCancelOrder(event) {
        this.openDeleteOrder = false;
    }

    // Handle the deletion of the order
    handleDeleteOrderValidation(event) {

        // Display the spinner
        this.isLoading = true;

        deleteOrder({ orderId: this.orderId })
        .then(result => {
            // Navigate to order tab
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: lbl_page_order_tab,
                }
            });
        })
        .catch(error => {
            console.log(">>>error");
            console.log(error);
            // Hide the spinner
            this.isLoading = false;
        });

    }

    handleChangeSortBaskets(event){
        this.valueOrderBy = event.target.value;

        if(this.valueOrderBy === this.labels.lbl_by_customer && this.userCountry === 'FRA'){
            this.displayByCustomerFRA = true;
            this.displayByCustomerITA = false;
            this.displayByCatalog = false;
        }
        else if(this.valueOrderBy === this.labels.lbl_by_customer && this.userCountry === 'ITA'){
            this.displayByCustomerFRA = false;
            this.displayByCustomerITA = true;
            this.displayByCatalog = false;
        }
        else{
            this.displayByCustomerFRA = false;
            this.displayByCustomerITA = false;
            this.displayByCatalog = true;
        }

        this.fetchBasket();
    }

    handleOrderComplement(event){
        getBasket({ orderId: this.orderId, orderBy: this.valueOrderBy })
            .then(data => {                
                if (data) {
                    if(data.status != "Pending") {
                        this.showToast();
                    } else {
                        this.isLoading = true;

                        updateStatusDeleteStockUsed({ orderId: this.orderId })
                        .then(result => {
                            this.isLoading = false;
                            //eval("$A.get('e.force:refreshView').fire();");
                            this.fetchBasket();
                            fireEvent(this.pageRef, 'updateLoyalty', null);
                        })
                        .catch(error => {
                            console.log(">>>error");
                            console.log(error);
                            // Hide the spinner
                            this.isLoading = false;
                        });
                    }
                }
            })
            .catch(error => {
                console.log(">>> error handleOrderComplement");
                console.log(error);
            });
    }

    handleNouvelleDemande(event){
        putOrderOnNewCase({orderId : this.orderId})
        .then(results => {
            if(results === "OK"){
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'nouvelle-demande',
                    },
                    state: {
                        orderId: this.orderId
                    },
                });
                console.log('>>>> error lwc70_Handle nouvelle demande:');
                console.log(results);
            }
        })
        .catch(error => {
            console.log('>>>> error lwc70_Handle nouvelle demande:');
            console.log(error);
        });


    }

    showToast() {
        const event = new ShowToastEvent({
            title: lbl_basketWarning,
            message: lbl_basketNotPending,
            variant : 'warning'
        });
        this.dispatchEvent(event);
    }

    updateCDV(event){
        if(this.acceptedCDV){
            this.acceptedCDV = false;
        }
        else{
            this.acceptedCDV = true;
        }
    }

    onCloseBundleModal(event){
        this.fetchBasket();
    }

    handleValidateOrderOLA(){

        this.isLoading = true;

        validateOrderOLA({orderId : this.orderId})
        .then(results => {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'order-validation',
                },
                state: {
                    orderId: this.orderId
                },
            });
        })
        .catch(error => {
            console.log('>>>> error lwc70_Handle nouvelle demande:');
            console.log(error);

            this.isLoading = false;
        });
    }

    updateCounters(event){

        getHasDraftOrder()
            .then(results => {

                this.hasDraftOrders = results;

                let arrayProduct = event;
                let l_products = [];
                let l_idProducts = [];

                if (arrayProduct != null && arrayProduct != undefined) {
                    for( let [key, value] of arrayProduct ){
                        l_products.push(value);
                        l_idProducts.push(value.id);
                    }
                }
                
                if (this.hasDraftOrders == false && l_products != null && l_products.length > 0) {
                    this.hasDraftOrders = true;
                }

                getCounters({json_l_products : JSON.stringify(l_products), 
                            json_l_idProducts : JSON.stringify(l_idProducts),
                            idContactFor : this.idContact})
                    .then(results => {
                        console.log('>>> lwc70: getCounters 2');
                        this.l_counterCategories = results;
                        console.log('***************************Updated********************');
                        results.forEach((category) => {
                            if(category.name === 'Comptes') {
                                console.log(category.l_counters);
                                category.l_counters.forEach((counter) => {
                                    if (counter.id == 'counter1') {
                                        this.smartPTSCreditValueOnOrder = counter.creditValueOnOrder;
                                        this.smartPTSDebitValueOnOrder = counter.debitValueOnOrder;
                                    } else if (counter.id == 'counter2') {
                                        this.hotesseCreditValueOnOrder = counter.creditValueOnOrder;
                                        this.hotesseDebitValueOnOrder = counter.debitValueOnOrder;
                                    }
                                });
                            }
                        });
                        console.log('smartPTS creditValueOnOrder: ' + this.smartPTSCreditValueOnOrder);
                        console.log('smartPTS debitValueOnOrder: ' + this.smartPTSDebitValueOnOrder);
                        console.log('hotesse creditValueOnOrder: ' + this.hotesseCreditValueOnOrder);
                        console.log('hotesse debitValueOnOrder: ' + this.hotesseDebitValueOnOrder);
                    })
                    .catch(error => {
                        console.log('>>>> error lwc70_order_detail_basket_views :');
                        console.log(error);
                    });

            })
        .catch(error => {
            console.log('>>>> error lwc70_order_detail_basket_views :');
            console.log(error);
        });
    }
}