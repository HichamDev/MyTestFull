/* eslint-disable guard-for-in */
/* eslint-disable no-undef */
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

/* Import APEX Methods */
import searchProduct from '@salesforce/apex/lwc17_searchProduct.searchProduct';
// import getOrderId from '@salesforce/apex/Lwc17_fastordersearchbar_ctrl.getOrder';
import addToBasket from '@salesforce/apex/Lwc17_fastordersearchbar_ctrl.addToBasket';
import getBundleContent from '@salesforce/apex/Lwc17_fastordersearchbar_ctrl.getPorductListOfBundle'

/* IMPORT LABELS */
import lbl_bundlemaxqty from '@salesforce/label/c.LU_Basket_Bundle_MaxQuantity_Info';
import lbl_bundlemaxreaded from '@salesforce/label/c.LU_Basket_Bundle_MaxQuantityReached';
import lbl_bundle_save from '@salesforce/label/c.LU_Basket_Bundle_Selection_Save';
import lbl_bundle_cancel from '@salesforce/label/c.LU_Basket_Bundle_Selection_Cancel';
import lbl_basket_addtobasketcontinue from '@salesforce/label/c.LU_Basket_AddToBasket_Continue';
import lbl_basket_addtobasketorder from '@salesforce/label/c.LU_Basket_AddToBasket_Order';
import lbl_searchbar_placeholder from '@salesforce/label/c.LU_Basket_Search_Placeholder';
import lbl_searchbar_error from '@salesforce/label/c.LU_FastOrder_Search_Error';
import lbl_TECH_OfferType_PersonalUse from '@salesforce/label/c.LU_Offer_Type_PersonalUse';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

export default class Lwc17_fastordersearchbar extends NavigationMixin(LightningElement) {

    /* LABELS */
    labels = {
        lbl_bundlemaxreaded,
        lbl_bundlemaxqty,
        lbl_bundle_save,
        lbl_bundle_cancel,
        lbl_basket_addtobasketcontinue,
        lbl_basket_addtobasketorder,
        lbl_searchbar_placeholder
    }

    /* VARIABLES */
    @track selectedtargets = [];
    @track m_productList = new Map();
    @track processedArray = new Map();
    @track m_productChosenFromBundle = new Map();
    @track isModalOpen = false;
    @track m_bundleProductList = new Map();
    @track offerType = lbl_TECH_OfferType_PersonalUse;
    @track updateItems = 0;
    @track bundleNbArticles = 0;
    @track dealerOfOrder = null;
    @api webonly = false;
    @api selection = [];
    
    /* INIT */
    @wire(CurrentPageReference) pageRef; // Required by pubsub
	connectedCallback() {
        // subscribe to events
        registerListener('catalogChange', this.handleCatalogChange, this);

        registerListener('lwc16_focuslookup', this.handleKeyPress, this);

        registerListener('lwc16_addBasket', this.addtobasket, this);

        registerListener('lwc16_deleteLine', this.deleteLine, this);

        // EVENT : Subscribe to contact selection on the popup
        registerListener('orderHomeContactSelected', this.handleContactSelection, this);
	}

    @api
    getSelection() {
        return this.selection;
    }

	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }
    
    /* EVENTS HANDLER */
    handleKeyPress(){
        //if enter is pressed//
        this.template.querySelector('c-lwc04_lookup').focusSearchField();
    }

    addtobasket(value){
        this.template.querySelector('c-lwc04_lookup').setSelectionManual([]);
    }

    // When event 'catalogchange' is reveived
    handleCatalogChange(value){
        console.log('handleCatalogChange');
        console.log(value);
        this.offerType = value;
        this.template.querySelector('c-lwc04_lookup').clearSearch();
    }

    // Event - Search event lookup
    handleSearch(event) {

        //fireEvent(this.pageRef, 'lwc17_sendErrorNoResult', '');
        this.template.querySelector('c-lwc04_lookup').sendErrorNoResult('');

        let param = event.detail;
        param.offerType = this.offerType;
        if(this.webonly == true) {
            param.offerType = 'WEB';   
        }     
        param.contactStr = JSON.stringify(this.dealerOfOrder);

        searchProduct(param)
            .then(results => {
                console.log(results);
                if(results.length == 0){
                    //fireEvent(this.pageRef, 'lwc17_sendErrorNoResult', lbl_searchbar_error);
                    this.template.querySelector('c-lwc04_lookup').sendErrorNoResult(lbl_searchbar_error);
                } else {
                    this.template.querySelector('c-lwc04_lookup').setSearchResults(results);
                }
            })
            .catch(error => {
                console.log('>>>> error handleSearch:');
                console.log(error);
            });
    }

    // Event - Lookup selection changes
    handleSelectionChange() {

        const selection = this.template.querySelector('c-lwc04_lookup').getSelection();

        fireEvent(this.pageRef, 'lwc17_handleSelectionChange', selection);
        
    }

    // Event - contact selection (dealer)
    handleContactSelection(contact) {
        this.dealerOfOrder = contact;
    }

    deleteLine(value){
    console.log('Lwc04 lookup deleteLine');
        let newSelectedTargets = [];

        for(let s of this.selection){
            if( String(s.id) !== String(value) ){
                newSelectedTargets.push(s);
            }
        }
        this.selection = newSelectedTargets;
    }

}