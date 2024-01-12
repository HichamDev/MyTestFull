/* eslint-disable no-undef */
/* eslint-disable radix */
/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

/* APEX */
import getUserCountry from '@salesforce/apex/Lwc17_fastordersearchbar_ctrl.getUserCountry';
import addToBasket from '@salesforce/apex/Lwc17_fastordersearchbar_ctrl.addToBasket';
import getBundleContent from '@salesforce/apex/Lwc17_fastordersearchbar_ctrl.getPorductListOfBundle'
// import getBundleContentITA from '@salesforce/apex/Lwc17_fastordersearchbar_ctrl.getPorductListOfBundle'
// import getBundleContentFRA from '@salesforce/apex/lwc17_searchProduct.getPorductListOfBundle'
import getOrderIdWithoutPricebook from '@salesforce/apex/Lwc17_fastordersearchbar_ctrl.getOrderIdWithoutPricebook';
import getPriceBookEntry from '@salesforce/apex/Lwc17_fastordersearchbar_ctrl.getPriceBookEntry';
import getCurrentContact from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getMyContact';

/* IMPORT FIELDS */
import CONTACT_ID from '@salesforce/schema/Contact.Id';

/* LABEL */
import lbl_bundlemaxqty from '@salesforce/label/c.LU_Basket_Bundle_MaxQuantity_Info';
import lbl_bundlemaxreaded from '@salesforce/label/c.LU_Basket_Bundle_MaxQuantityReached';
import lbl_bundle_save from '@salesforce/label/c.LU_Basket_Bundle_Selection_Save';
import lbl_bundle_title from '@salesforce/label/c.LU_Basket_Bundle_Selection_Title';
import lbl_bundle_cancel from '@salesforce/label/c.LU_Basket_Bundle_Selection_Cancel';
import lbl_minus_quantity from '@salesforce/label/c.LU_Basket_Minus_Quantity';
import lbl_plus_quantity from '@salesforce/label/c.LU_Basket_Plus_Quantity';
import lbl_delete_line from '@salesforce/label/c.LU_Basket_Delete_Line';
import lbl_bundlemaxnotreached from '@salesforce/label/c.LU_Basket_Bundle_MaxQuantityNotReached';
import lbl_qtyExceeded from '@salesforce/label/c.LU_Basket_MaxQuantityExceeded';
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Bundle_Txt from '@salesforce/label/c.LU_Basket_Bundle_Txt';
import lbl_column_description from '@salesforce/label/c.LU_Basket_Column_Description';
import lbl_column_quantity from '@salesforce/label/c.LU_Basket_Column_Quantity';
import lbl_column_unitprice from '@salesforce/label/c.LU_Basket_Column_UnitPrice';
import lbl_bundle_choose from '@salesforce/label/c.LU_Basket_Bundle_Choose_Button';
import lbl_bundle_visualize from '@salesforce/label/c.LU_Basket_Bundle_Visualize_Button';
import lbl_Title_Popup_Push from '@salesforce/label/c.LU_Push_Popup_Title';
import lbl_text_success_push from '@salesforce/label/c.LU_Push_Popup_Text_Success';
import lbl_text_search_product_limited_quantity from '@salesforce/label/c.LU_SearchProductLimitedQuantity';
import lbl_choixproduit from '@salesforce/label/c.LU_LWC41_ChoixProduit';
import lbl_childmaxreached from '@salesforce/label/c.LU_Basket_Child_MaxQuantityReached';
import lbl_stock_checkout_error_left from '@salesforce/label/c.LU_Stock_Checkout_Error_Nb_Left';

export default class Lwc16_orderhome_basket extends NavigationMixin(LightningElement){

    iconDelete = LogoBtn + '/icons/icon_delete.PNG';
    iconError = LogoBtn + '/icons/error.svg';
    iconWarning = LogoBtn + '/icons/warning.svg';
    iconAdd = LogoBtn + '/icons/icon-add.svg';
    iconLess = LogoBtn + '/icons/icon-less.svg';

    /* LABELS */
    labels = {
        lbl_column_description,
        lbl_column_quantity,
        lbl_column_unitprice,
        lbl_Close,
        lbl_bundle_title,
        lbl_bundlemaxreaded,
        lbl_bundlemaxqty,
        lbl_bundle_save,
        lbl_bundle_cancel,
        lbl_minus_quantity,
        lbl_plus_quantity,
        lbl_delete_line,
        lbl_bundlemaxnotreached,
        lbl_qtyExceeded,
        lbl_bundle_choose,
        lbl_bundle_visualize,
        lbl_Title_Popup_Push,
        lbl_text_success_push,
        lbl_text_search_product_limited_quantity,
        lbl_choixproduit,
        lbl_childmaxreached,
        lbl_stock_checkout_error_left
    }

    /* VARIABLES */
    @api selection = [];
    @track selectedtargets = [];
    @track m_productList = new Map();
    @track processedArray = new Map();
    @track m_productChosenFromBundle = new Map();
    @track isModalOpen = false;
    @track m_bundleProductList = new Map();
    @track bundleTxt = '';
    @track offerType;
    @track updateItems = 0;
    @track bundleNbArticles = 0;
    @track bundleOfferOpened = null;
    @track bundleProductId = null;
    @track contact = null;
    @track amount = 0;
    @track m_productInModal = new Map();
    @track errormessage = '';
    @track openPopupPush = false;

    @track isFRA = false;
    @track isITA = false;

    @track openPopupPush = false;
    @track txtResultPush;
    @track pushedProductTitle;
    @track isLoading = false;
    @track orderIdFromUrl;
    @api isShow;
    @api isdisplay;
    @api isOrderHome;
    @track dontCallDirectly = false;

    /* INIT */
    @wire(CurrentPageReference) pageRef; // Required by pubsub
	connectedCallback() {

        registerListener('lwc16_addBasket', this.addtobasket, this);
        registerListener('showOpenSetBundlePopUp', this.showOpenSetBundlePopUp, this);        

        registerListener('lwc16_addBasket_go_to_order', this.addtobasket, this);

        registerListener('lwc17_handleSelectionChange', this.handleSelectionChange, this);

        // EVENT : Subscribe to contact selection on the popup
        registerListener('orderHomeContactSelected', this.handleContactSelection, this);

        registerListener('lwc68_orderhome_pushproducts', this.handlePushProduct, this);

        registerListener('lwc83_pushProduct', this.addPushProductToSelection, this);
        registerListener('lwc88_pushProduct', this.deleteExistingLine, this);
        registerListener('ShowProductSelection', this.showProductSelection, this);

        this.parameters = this.getQueryParameters();
        for (let key in this.parameters) {
            if (key === 'idContact') {
                this.contactIdPreselected = this.parameters[key];
            }
            if (key === 'push') {
                this.isPushOfferOpened = true;
            }
            if (key === 'orderId') {
                this.orderIdFromUrl = this.parameters[key];
            }
        }

        getUserCountry()
        .then(results => {

            if(results === 'FRA'){
                this.isFRA = true;
            }
            else if(results === 'ITA'){
                this.isITA = true;
            }
        })
        .catch(error => {
            console.log('>>>> error lwc16_orderhomebasket:');
            console.log(error);
        });

        // Get a selected contact
        this.parameters = this.getQueryParameters();

        // Get the order id
        for (let key in this.parameters) {
            if (key == 'idContact') {
                let con = { [CONTACT_ID.fieldApiName] : this.parameters[key] };
                this.contact = con;                
            }
        }
        if(this.contact == null){ // Ajout JJE 04/02/2021 suite ticket Redmine 10890
            getCurrentContact()
            .then(currentContact => {                
                this.contact = currentContact;
            });
        }

	}

    showProductSelection() {
        this.dontCallDirectly = true;
    }

    disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
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

    renderedCallback(){
        if(this.processedArray.size > 0){
            this.template.querySelector('[data-id="inputQuantity"]').focus();
        }
    }

    /* EVENTS HANDLER */
    handleKeyPress(code){
        //if enter is pressed//
        if(code.which === 13){

            fireEvent(this.pageRef, 'lwc16_focuslookup', "");

            this.template.querySelector('c-lwc04_lookup').focusSearchField();
        }
        else{
            this.template.querySelector('[data-item="' + this.template.activeElement.dataset.item + '"]').blur();
            this.template.querySelector('[data-item="' + this.template.activeElement.dataset.item + '"]').focus();
        }
    }

    handlePreselection(preselection){

        if(preselection){
            this.m_productList = new Map();

            for(let i = 0; i < preselection.length; i++){
                this.m_productList.set(preselection[i].Id, preselection[i]);
            }

            this.processedArray = new Map();
            this.processedArray = this.m_productList;

            this.calculateAmountBasket();
        }
    }

    // Event - add product from push
    handlePushProduct(selection) {

        fireEvent(this.pageRef, 'lwc16_orderhome_basket_PushProductResult', 'success');

        this.handleSelectionChange(selection);
        
    }

    // Event - Lookup selection changes
    handleSelectionChange(selection) {
        
        if (selection) {
                
            this.selectedtarget = selection;

            this.m_productList = new Map();

            for(let i = 0; i < selection.length; i++){

                if( this.processedArray.length === 0 || !this.processedArray.has(selection[i].id) ){
                    
                    // IF the new line is a bundle, calculate the child
                    if (selection[i].isInBundle) {
                        this.calculateBundleChild(selection[i], false);
                    }

                    if (selection[i].dealerPrice) {
                        selection[i].priceNotDiscounted = selection[i].dealerPrice.toFixed(2);
                    }
                    
                    if(selection[i].id){
                        this.m_productList.set(selection[i].id, selection[i]);
                    }
                    else if(selection[i].Id){
                        this.m_productList.set(selection[i].Id, selection[i]);
                    }
                }
            }

            for (let [k, v] of this.processedArray) {
                this.m_productList.set(k, v);
            }

            this.processedArray = new Map();
            this.processedArray = this.m_productList;

            // Update the amount of the basket
            this.calculateAmountBasket();

        }

        // Rerender the view
        this.updateItems = this.updateItems + 1;
        //fireEvent(this.pageRef, 'lwc16_addBasket', "continue");
    }

    // Contact selection handle
    handleContactSelection(value) {

        this.contact = value.contact;
    }

    updateAmount(event) {

        var product = this.processedArray.get(event.target.dataset.item);
        var cloneProduct = Object.assign({}, product);

        let value = event.target.value;
        if(value < 0){
            event.target.value = 1;
            value = 1;
        }
        else if(value > 999){
            event.target.value = 999;
            value = 999;
        }

        cloneProduct.quantity = value;
        cloneProduct.isBundleValidated = false;
        cloneProduct.priceHT = (cloneProduct.quantity * cloneProduct.unitPrice).toFixed(2);
        if (cloneProduct.dealerPrice) {
            cloneProduct.priceNotDiscounted = (cloneProduct.quantity * cloneProduct.dealerPrice).toFixed(2);
        }

        // recalculate if a bundle
        if (product.isInBundle) {
            this.calculateBundleChild(cloneProduct, false);
        }

        this.processedArray.set(cloneProduct.id, cloneProduct);

        this.updateItems = this.updateItems + 1;

        // Calculate basket amount
        this.calculateAmountBasket();
    }

    handleQuantityUp(event) {

        if (event.target.dataset.item < 999) {
            let product = this.processedArray.get(event.target.dataset.id);
            let cloneProduct = Object.assign({}, product);

            let q = event.target.dataset.item;
            q++;
            cloneProduct.quantity = q;
            cloneProduct.isBundleValidated = false;
            cloneProduct.priceHT = (cloneProduct.quantity * cloneProduct.unitPrice).toFixed(2);
            if (cloneProduct.dealerPrice) {
                cloneProduct.priceNotDiscounted = (cloneProduct.quantity * cloneProduct.dealerPrice).toFixed(2);
            }

            // recalculate if a bundle
            if (product.isInBundle) {
                this.calculateBundleChild(cloneProduct, false);
            }

            this.processedArray.set(cloneProduct.id, cloneProduct);

            this.updateItems = this.updateItems + 1;

            // Calculate basket amount
            this.calculateAmountBasket();
        }
    }
    handleQuantityDown(event) {

        if(event.target.dataset.item > 1){
            let product = this.processedArray.get(event.target.dataset.id);
            let cloneProduct = Object.assign({}, product);
            
            cloneProduct.quantity = event.target.dataset.item - 1;
            cloneProduct.isBundleValidated = false;
            cloneProduct.priceHT = (cloneProduct.quantity * cloneProduct.unitPrice).toFixed(2);
            if (cloneProduct.dealerPrice) {
                cloneProduct.priceNotDiscounted = (cloneProduct.quantity * cloneProduct.dealerPrice).toFixed(2);
            }
            
            // recalculate if a bundle
            if (product.isInBundle) {
                this.calculateBundleChild(cloneProduct, false);
            }

            this.processedArray.set(cloneProduct.id, cloneProduct);

            this.updateItems = this.updateItems + 1;

            // Calculate basket amount
            this.calculateAmountBasket();
        }
    }

    deleteLine(event){       

        this.processedArray.delete(event.target.dataset.id);

        fireEvent(this.pageRef, 'lwc16_deleteLine', event.target.dataset.id);

        this.updateItems = this.updateItems + 1;

        // Calculate basket amount
        this.calculateAmountBasket();
    }

    deleteExistingLine(event){       
        let productId;
        for (const [key, value] of this.processedArray) {
            productId = key;
            this.processedArray.delete(productId);

            fireEvent(this.pageRef, 'lwc16_deleteLine', productId);

            this.updateItems = this.updateItems + 1;

            // Calculate basket amount
            this.calculateAmountBasket();
        }
        
        this.addPushProductToSelection(event);
    }

    calculateBundleChild(product, openModalBundleSelection) {

        getBundleContent({idProductOffer : product.productId, idpbentry: product.id, idPb: product.priceBook})
        .then(results => {

            var l_productInModal = JSON.parse(results);

            let lBundleAlreadySet = null;
            this.m_productInModal = new Map();

            // Check if the bundle was already set
            if (this.m_bundleProductList.has(product.productId)) {
                lBundleAlreadySet = this.m_bundleProductList.get(product.productId);
            }

            for (let p of l_productInModal) {

                // Check the quantity if bundle already set
                if (lBundleAlreadySet) {
                    for (let pAlreadySet of lBundleAlreadySet.values()) {
                        if (pAlreadySet.productId == p.productId) {
                            p.quantity = pAlreadySet.quantity;
                        }
                    }
                }

                // Check if the children is a close set
                if (p.isReadOnly) {
                    p.quantity = p.minQuantity * product.quantity;
                }

                if(!p.isSelectable){
                    p.quantity = p.maxQuantity * product.quantity;
                }

                // if(p.stockAvailable < 0 || p.stockAvailable === 0){
                //     p.isReadOnly = true;
                // }

                this.m_productInModal.set(p.productId, p);
            }

            this.m_bundleProductList.set(product.productId, this.m_productInModal);

            if (openModalBundleSelection) {
                this.isModalOpen = true;
            }
            
        })
        .catch(error => {
            console.log('>>>> error lwc16_orderhomebasket:');
            console.log(error);
        });

    }


    showBundlePopUp(event) {


        let productId = event.target.dataset.item;
        let product = this.processedArray.get(event.target.dataset.item);

        this.bundleProductId = productId;
        this.bundleNbArticles = product.numberOfArticle * product.quantity;

        this.bundleOfferOpened = product;
        this.bundleTxt = lbl_Bundle_Txt;
        this.bundleTxt = this.bundleTxt.replace('$REF', product.title);
        this.bundleTxt = this.bundleTxt.replace('$QUANTITYTOCHOOSE ', this.bundleNbArticles + ' ');        

        
        this.calculateBundleChild(product, true);

    }

    showOpenSetBundlePopUp(nextStep) {
        let productId;

        for (const [key, value] of this.processedArray) {
            productId = key;
        }

        let product = this.processedArray.get(productId);

        this.bundleProductId = productId;
        this.bundleNbArticles = product.numberOfArticle * product.quantity;

        this.bundleOfferOpened = product;
        this.bundleTxt = lbl_Bundle_Txt;
        this.bundleTxt = this.bundleTxt.replace('$REF', product.title);
        this.bundleTxt = this.bundleTxt.replace('$QUANTITYTOCHOOSE ', this.bundleNbArticles + ' ');        

        
        this.calculateBundleChild(product, true);

    }

    closeBundlePopUp(event) {

        this.isModalOpen = false;

        let bundleTotalQuantity = 0;
        let pId = null;

        for (let x of this.m_productInModal.values()) {
            let qtyLine = 0;
            qtyLine = parseInt(x.quantity);
            bundleTotalQuantity += qtyLine;
            pId = x.idBundle;
        }

        if (bundleTotalQuantity !== this.bundleNbArticles) {
            this.processedArray.get(pId).isBundleValidated = false;
        } else {
            this.processedArray.get(pId).isBundleValidated = true;
        }
    }

    closelwc16(event){
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("closelwc16");
    
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    updateAmountInBundle(event){

        let productId = event.target.dataset.item;
        let product = this.m_productInModal.get(productId);

        /** 
        if(product.stockAvailable !== null && event.target.value > product.stockAvailable){
            const evt = new ShowToastEvent({
                title: product.title + ' - ' + this.labels.lbl_stock_checkout_error_left + ' ' + product.stockAvailable,
                message: "",
                variant: "warning",
            });
            this.dispatchEvent(evt);

            event.target.value = product.quantity;
            return;
        }*/

        var bundleTotalQuantity = 0;
        
        for (let x of this.m_productInModal.values()) {

            let qtyLine = 0;

            if (product.productId === x.productId) {
                qtyLine = parseInt(event.target.value);
            } else {
                qtyLine = parseInt(x.quantity);
            }

            bundleTotalQuantity += qtyLine;
        }

        if (bundleTotalQuantity > this.bundleNbArticles && event.target.value > product.quantity) {
            const evt = new ShowToastEvent({
                title: this.labels.lbl_bundlemaxreaded,
                message: "",
                variant: "warning",
            });
            this.dispatchEvent(evt);

            event.target.value = product.quantity;
            return;
        }

        product.quantity = parseInt(event.target.value);
        // if(this.isFRA){
        //     product.quantityDisplayed = product.quantity;
        //     if(product.stockAvailable != null && product.quantity > product.stockAvailable && product.subsituteArticle != null){
        //         product.quantityDisplayed = product.stockAvailable;
        //         product.subsituteArticle.quantity = product.quantity - product.stockAvailable;
        //         product.isSubstituteArtile = true;
        //     }
        //     else if(product.subsituteArticle != null){
        //         product.isSubstituteArtile = false;
        //         product.subsituteArticle.quantity = 0;
        //     }
        // }

        this.m_productInModal.set(product.id, product);
        let a = this.m_productInModal;
        this.m_productInModal = null;
        this.m_productInModal = a;
    }

    saveBundle(event) {

        try {

            let bundleTotalQuantity = 0;
            let pId;

            for (let x of this.m_productInModal.values()) {
                let qtyLine = 0;
                qtyLine = parseInt(x.quantity);
                bundleTotalQuantity += qtyLine;
                pId = x.idBundle;
            }
    
            if (bundleTotalQuantity !== this.bundleNbArticles) {
                let product = this.processedArray.get(this.bundleProductId);
                const evt = new ShowToastEvent({
                    title: this.labels.lbl_bundlemaxnotreached,
                    message: product.title,
                    variant: "warning",
                });
                this.dispatchEvent(evt);
    
                return;
            }

            this.processedArray.get(pId).isBundleValidated = true;

            // Save the changes applied           
            this.m_bundleProductList.delete(this.bundleProductId);
            this.m_bundleProductList.set(this.bundleProductId, new Map(JSON.parse(JSON.stringify(Array.from(this.m_productInModal)))));
            this.m_productInBundle = new Map();
            this.isModalOpen = false;

            if(!this.isShow) {
                fireEvent(this.pageRef, 'showLoading88', null);
                setTimeout(function(){ fireEvent(this.pageRef, 'lwc16_addBasket', "continue"); setTimeout(function(){ fireEvent(this.pageRef, 'updateChallenge', null); fireEvent(this.pageRef, 'hideLoading88', null);}, 1000) }, 1000);
            }
        } catch (error) {
            console.error(error);
        }

    }

    /* BUSINESS METHODS */
    calculateAmountBasket() {
        let amount = 0;
        let articleCount = 0;

        if (this.processedArray) {
            for (let [k, v] of this.processedArray){
                amount += parseFloat(v.priceTTC);
                articleCount += parseFloat(v.quantity);
            }
        }

        fireEvent(this.pageRef, 'updatedBasket', this.processedArray);

        fireEvent(this.pageRef, 'updatePurchaseAmount', amount);

        fireEvent(this.pageRef, 'updateArticleCount', articleCount);

        fireEvent(this.pageRef, 'updateLoyalty', this.processedArray);

        this.updateCountersString();

    }

    // Method which add the basket to the current order
    addtobasket(nextStep) {
        if (nextStep === 'straighttoorder') {
            let idContact = null;
            if (this.contact) {
                idContact = this.contact.Id;
            }

            if(this.orderIdFromUrl) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.orderIdFromUrl,
                        actionName: 'view',
                    }
                });
            }else{
                getOrderIdWithoutPricebook( { contactId : idContact })
                .then(results2 => {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: results2,
                            actionName: 'view',
                        }
                    });
                })
                .catch(error => {
                    console.log('>>>> error lwc16_orderhomebasket:');
                    console.log(error);
                    fireEvent(this.pageRef, 'hideSpinner', null);
                });
            }
            
        }
        else {
            
            if(this.processedArray.size === 0){
                fireEvent(this.pageRef, 'hideSpinner', null);
                return;
            }

            let l_productToAddToBasket = [];
            for (let [productId, product] of this.processedArray){

                l_productToAddToBasket.push( product );

                let nbArticlesInBundle = product.numberOfArticle * product.quantity;

                let bundleTotalQuantity = 0;
                
                if(!this.isITA){
                    var vMaxQty = product.maxQuantity;
                    if(vMaxQty == 1) {
                        if(product.quantity != vMaxQty) {
                            const evt = new ShowToastEvent({
                                title: this.labels.lbl_qtyExceeded,
                                message: product.title + ' - ' + lbl_text_search_product_limited_quantity.replace("{MAX}", vMaxQty),
                                variant: "warning",
                            });
                            this.dispatchEvent(evt);
                            
                            fireEvent(this.pageRef, 'hideSpinner', null);

                            return;
                        }
                    }
                }

                if (product.isInBundle) {
                    
                    // A bundle has not been set : choice not made
                    if (!this.m_bundleProductList.has(product.productId)) {

                        const evt = new ShowToastEvent({
                            title: this.labels.lbl_bundlemaxnotreached,
                            message: product.title,
                            variant: "warning",
                        });
                        this.dispatchEvent(evt);

                        fireEvent(this.pageRef, 'hideSpinner', null);

                        return;
                    }

                    for(let [bundleItemId, bundleItem] of this.m_bundleProductList.get(product.productId)) {

                        l_productToAddToBasket.push(bundleItem);

                        let qtyLine = 0;
                        
                        qtyLine = parseInt(bundleItem.quantity);

                        bundleTotalQuantity += qtyLine;

                    }


                    if (bundleTotalQuantity !== nbArticlesInBundle && (!this.isFRA || !product.isBundleClosed) ) {
                        const evt = new ShowToastEvent({
                            title: this.labels.lbl_bundlemaxnotreached,
                            message: product.title,
                            variant: "warning",
                        });
                        this.dispatchEvent(evt);

                        fireEvent(this.pageRef, 'hideSpinner', null);
                        return;
                    }
                }
            }

            if (l_productToAddToBasket.length != 0) {
            addToBasket( { l_product : l_productToAddToBasket, 
                                idOrder : this.orderIdFromUrl, 
                                idPriceBook : l_productToAddToBasket[0].priceBook,
                                contactLine : this.contact } )
                .then(results2 => {
                    
                    if(results2.includes("Error - ")){
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: results2.substring(8, results2.length),
                            variant: "Error",
                        });
                        this.dispatchEvent(evt);
                        alert(results2);
                    }
                    else{
                        this.m_productChosenFromBundle = new Map();
                        this.processedArray = new Map();
                        this.m_productList = new Map();
                        this.m_bundleProductList = new Map();

                        this.updateItems = this.updateItems + 1;

                        fireEvent(this.pageRef, 'basketUpdated', this.updateItems);
                        fireEvent(this.pageRef, 'OrderHomeResetTotals', null);
                        fireEvent(this.pageRef, 'updateArticleCount', 0);
                        if (nextStep === 'order') {
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: results2,
                                    actionName: 'view',
                                }
                            });
                        } else if (nextStep == 'continue-popup-contact-opens') {
                            fireEvent(this.pageRef, 'orderHomeContactSelectionToBeOpened', null);
                        }
                        if(!this.isShow) {
                            fireEvent(this.pageRef, 'hideCardComponent', null);
                        }
                    }
                    fireEvent(this.pageRef, 'hideSpinner', null);
                })
                .catch(error => {
                    console.log('>>>> error lwc16_orderhomebasket addToBasket:');
                    console.log(error);
                    if(error.body != null && error.body.fieldErrors != null && error.body.fieldErrors.PricebookEntryId[0] != null) {
                        alert(error.body.fieldErrors.PricebookEntryId[0].message);
                    }
                    fireEvent(this.pageRef, 'hideSpinner', null);
                });
            }
            else{
                if (nextStep === 'order') {
                    getOrderIdWithoutPricebook( { contactId : this.contact.Id })
                    .then(results2 => {

                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: results2,
                                actionName: 'view',
                            }
                        });
                    })
                    .catch(error => {
                        console.log('>>>> error lwc16_orderhomebasket:');
                        console.log(error);
                        fireEvent(this.pageRef, 'hideSpinner', null);
                    });
                } else if (nextStep == 'continue-popup-contact-opens') {
                    fireEvent(this.pageRef, 'orderHomeContactSelectionToBeOpened', null);
                }
            }
        }
    }

    // Put args of the URL in a map
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

    updateCountersString(){
        
        // Modif JJE 12/08/2021 T1716
        // if(!this.isITA){
            for(let [x, item] of this.processedArray){
                var vMaxQty = this.processedArray.get(x).maxQuantity;
                if(vMaxQty == 1) {
                    let counters = lbl_text_search_product_limited_quantity.replace("{MAX}", vMaxQty);

                    for(let cou of item.l_counters){

                        if(counters !== ""){
                            counters += " - ";
                        }
                        counters += cou.name + " : " + Math.round(cou.value * item.quantity * 100) / 100 + " " + cou.unit;
                    }
                    
                    this.processedArray.get(x).counters = counters;
                }
            }
        // }
    }

    addPushProductToSelection(event){
        // if(this.isITA){
        //     this.openPopupPush = true;
        //     this.isLoading = true;
        // }

        let thisVar = this;
        getPriceBookEntry({pbeId : event, orderContact : this.contact})
        .then(results => {

            let prod = results[0];
            for (const [key, value] of this.processedArray) {
                if(key === prod.id){
                    this.openPopupPush = false;
                    this.isLoading = false;
                    return;
                }
            }

            /* this.processedArray.set(prod.id, prod);

            // Rerender the view
            this.updateItems = this.updateItems + 1; */

            this.handleSelectionChange(results);

            // if(this.isITA){
            //     this.txtResultPush = lbl_text_success_push;
            //     this.pushedProductTitle = prod.title;
            //     this.isLoading = false;
            // }
        }).then(results => {
            if(!this.isShow) {
                if(!this.dontCallDirectly) {
                    setTimeout(function(){ fireEvent(this.pageRef, 'lwc16_addBasket', "continue"); setTimeout(function(){ fireEvent(this.pageRef, 'updateChallenge', null); fireEvent(this.pageRef, 'hideLoading88', null);}, 1000) }, 1000);
                } else {
                    setTimeout(function(){ fireEvent(this.pageRef, 'showOpenSetBundlePopUp', "continue"); }, 1000);
                    this.dontCallDirectly = false;
                }
            }
        })
        .catch(error => {
            console.log('>>>> error lwc16_orderhomebasket:');
            console.log(error);
        });
    }

    closePopupPush(){
        this.openPopupPush = false;
    }
}