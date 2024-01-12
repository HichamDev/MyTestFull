/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';

//set to 3 as per SFT-1696
const MINIMAL_SEARCH_TERM_LENGTH = 3; // Min number of chars required to search
const SEARCH_DELAY = 300; // Wait 300 ms after user stops typing then, peform search

// IMPORT RESOURCES STATIC
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

/* IMPORT LABELS */
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Stock_Replace_Title from '@salesforce/label/c.LU_Stock_Replacement_Title';
import lbl_Stock_Replace_Txt from '@salesforce/label/c.LU_Stock_Replacement_Text';
import lbl_Stock_Replace_Btn_Yes from '@salesforce/label/c.LU_Stock_Replacement_Button_Yes';
import lbl_Stock_Replace_Btn_No from '@salesforce/label/c.LU_Stock_Replacement_Button_No';
import lbl_Stock_Replace_Msg from '@salesforce/label/c.LU_Stock_Replacement_PopUp_Message';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener } from 'c/pubsub';

export default class Lookup extends LightningElement {

    // Custom labels
    labels = {
        lbl_Close,
        lbl_Stock_Replace_Title,
        lbl_Stock_Replace_Txt,
        lbl_Stock_Replace_Btn_Yes,
        lbl_Stock_Replace_Btn_No,
        lbl_Stock_Replace_Msg
    }

    // ICONS
    iconError = LogoBtn + '/icons/error.svg';
    iconWarning = LogoBtn + '/icons/warning.svg';

    // VARIABLES
    @api label;
    @api selection = [];
    @api placeholder = '';
    @api isMultiEntry = false;
    @api errors = [];
    @api scrollAfterNItems;
    @api customKey;
    @api donotdisplayresults = false;

    @track searchTerm = '';
    @track searchResults = [];
    @track hasFocus = false;
    @track loading = false;

    @track indiceSelected = 0;

    @api searchType;

    @track errormessage = '';

    @track displayPopUpProductReplacement = false;
    @track productOfReplacement;

    isFRA = false;
    isITA = false;

    cleanSearchTerm;
    blurTimeout;
    searchThrottlingTimeout;

    @wire(CurrentPageReference) pageRef; // Required by pubsub
	connectedCallback() {
        // subscribe to events
        registerListener('lwc16_deleteLine', this.deleteLine, this);
        //registerListener('lwc17_sendErrorNoResult', this.sendErrorNoResult, this);

        let url = window.location.href;
        if(url.includes("/ita/")){
            this.isITA = true;
        }
        else if(url.includes("/fra/")){
            this.isFRA = true;
        }
	}

// EXPOSED FUNCTIONS

    @api
    setSearchResults(results) {

        this.loading = false;

        this.searchResults = results.map(result => {
            if (typeof result.icon === 'undefined') {
                result.icon = 'standard:default';
            }
            return result;
        });

        this.initCursor();

    }

    @api
    getSelection() {
        return this.selection;
    }

    @api
    clearSearch() {
        this.searchTerm = '';
        this.searchResults = [];
    }

    @api
    getkey(){
        return this.customKey;
    }

    @api
    setSelectionManual(results) {

        var lItems = [];
        for (let i = 0 ; i < results.length ; i++) {
            let selectedItem = results[i];
            lItems.push(selectedItem);
        }

        this.selection = lItems;

        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));

    }

    @api
    focusSearchField() {
        this.template.querySelector(`[data-id="combobox"]`).focus();
    }

    @api
    sendErrorNoResult(value){
        this.errormessage = value;
        this.searchResults = [];

        if (value != null && value != '') {
            this.loading = false;
        }

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

// INTERNAL FUNCTIONS

    // Put the highlight line to the first one
    initCursor() {

        // Remove the existing selected line highlight
        for (let i = 0 ; i < this.searchResults.length ; i++) {
            let idElement = this.searchResults[i].id;
            if (this.template.querySelector('[data-id="' + idElement + '"]')) {
                this.template.querySelector('[data-id="' + idElement + '"]').classList.remove("selectedResult");
            } 
        }
        
        // Highlight the first element
        this.indiceSelected = 0;
        let idElement = this.searchResults[0].id;
        if (this.template.querySelector('[data-id="' + idElement + '"]')) {
            this.template.querySelector('[data-id="' + idElement + '"]').classList.add("selectedResult");
        }
        
    }

    renderedCallback(){
        try{
            if(this.searchResults !== null && this.searchResults.length > 0 && this.searchResults[this.indiceSelected] !== null){
                let idElement = this.searchResults[this.indiceSelected].id;
                if(idElement !== null){
                    this.template.querySelector('[data-id="' + idElement + '"]').classList.add("selectedResult");
                }
            }
        }
        catch(error){
            console.error(error);
        }
    }

    handleKeyPress(code){

        try {
            this.errormessage = '';

            if(code.which === 40 && this.searchResults.length > 0 && this.indiceSelected < this.searchResults.length - 1 && this.searchResults[this.indiceSelected] !== null){
                let idElement = this.searchResults[this.indiceSelected].id;
                this.template.querySelector('[data-id="' + idElement + '"]').classList.remove("selectedResult");
                this.indiceSelected++;
                idElement = this.searchResults[this.indiceSelected].id;
                this.template.querySelector('[data-id="' + idElement + '"]').classList.add("selectedResult");

                if (this.indiceSelected >= 3) {
                    // this.template.querySelector('[data-id="ulList"]').scrollTop = (this.indiceSelected * 42);
                    this.template.querySelector('[data-id="ulList"]').scrollTop = (this.indiceSelected * 42) - (3 * 42);
                }
                
            }
            else if(code.which === 38 && this.searchResults.length > 0 && this.indiceSelected > 0 && this.searchResults[this.indiceSelected]){
                let idElement = this.searchResults[this.indiceSelected].id;
                this.template.querySelector('[data-id="' + idElement + '"]').classList.remove("selectedResult");
                this.indiceSelected--;
                idElement = this.searchResults[this.indiceSelected].id;
                this.template.querySelector('[data-id="' + idElement + '"]').classList.add("selectedResult");
                
                if (this.searchResults.length - this.indiceSelected > 3) {
                    this.template.querySelector('[data-id="ulList"]').scrollTop = (this.indiceSelected * 42) - (3 * 42);
                }
                
            }else if(code.which === 13 && this.searchResults.length > 0) {

                // Save selection
                let recordId = this.searchResults[this.indiceSelected].id;
                
                let selectedItem = this.searchResults.filter(result => result.id === recordId);
                if (selectedItem.length === 0) {
                    return;
                }
                selectedItem = selectedItem[0];

                // If the offer selected is out of stock
                if (selectedItem.stockBasketCSSClass == 'error-message') {

                    // if a substitute product can be used instead
                    if (selectedItem.isSubstituteArtile && selectedItem.subsituteArticle != null) {
                        if(this.isITA){
                            this.displayPopUpProductReplacement = true;
                        }
                        else{
                            this.handleStockReplacementYes();
                        }
                        this.productOfReplacement = selectedItem.subsituteArticle;
                    } else {
                        this.errormessage = selectedItem.stockMessage;
                    }

                } else {
                    const newSelection = [...this.selection];
                    newSelection.push(selectedItem);
                    this.selection = newSelection;
            
                    // Notify parent components that selection has changed
                    this.dispatchEvent(new CustomEvent('selectionchange'));
                } 
                
                this.searchTerm = '';
                this.searchResults = [];
            }
        } catch (error) {
            console.log('>>> handleKeyPress EXCEPTION');
            console.error(error);
        }
    }

    updateSearchTerm(newSearchTerm) {
        this.searchTerm = newSearchTerm;

        // Compare clean new search term with current one and abort if identical
        const newCleanSearchTerm = newSearchTerm.trim().replace(/\*/g, '').toLowerCase();
        if (this.cleanSearchTerm === newCleanSearchTerm) {
            return;
        }

        // Save clean search term
        this.cleanSearchTerm = newCleanSearchTerm;

        // Ignore search terms that are too small
        if (newCleanSearchTerm.length < MINIMAL_SEARCH_TERM_LENGTH) {
            this.searchResults = [];
            return;
        }

        // Apply search throttling (prevents search if user is still typing)
        if (this.searchThrottlingTimeout) {
            clearTimeout(this.searchThrottlingTimeout);
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchThrottlingTimeout = setTimeout(() => {
                // Send search event if search term is long enougth
                if (this.cleanSearchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH) {
                    this.loading = true;

                    const searchEvent = new CustomEvent('search', {
                        detail: {
                            contactType: this.searchType,
                            searchTerm: this.cleanSearchTerm,
                            selectedIds: this.selection.map(element => element.id)
                        }
                    });
                    this.dispatchEvent(searchEvent);
                }
                this.searchThrottlingTimeout = null;
            },
            SEARCH_DELAY
        );
    }

    isSelectionAllowed() {
        if (this.isMultiEntry) {
            return true;
        }
        return !this.hasSelection();
    }

    hasResults() {
        return this.searchResults.length > 0;
    }

    hasSelection() {
        return this.selection.length > 0;
    }

    get isDisplayResults() {
        if (this.donotdisplayresults) {
            return (false);
        }
        return (true);
    }

// EVENT HANDLING

    handleInput(event) {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.updateSearchTerm(event.target.value);
    }

    handleResultClick(event) {

        const recordId = event.currentTarget.dataset.recordid;

        // Save selection
        let selectedItem = this.searchResults.filter(result => result.id === recordId);
        if (selectedItem.length === 0) {
            return;
        }

        selectedItem = selectedItem[0];
        // Check if the stock is not out of stock
        if (selectedItem.stockBasketCSSClass == 'error-message') {
            // if a substitute product can be used instead
            if (selectedItem.isSubstituteArtile && selectedItem.subsituteArticle != null) {
                
                this.productOfReplacement = selectedItem.subsituteArticle;
                if(this.isITA){
                    this.displayPopUpProductReplacement = true;
                }
                else{
                    this.handleStockReplacementYes();
                }
            } else {
                this.errormessage = selectedItem.stockMessage;
            }
            
        } else {
            const newSelection = [...this.selection];
            newSelection.push(selectedItem);
            this.selection = newSelection;

            // Notify parent components that selection has changed
            this.dispatchEvent(new CustomEvent('selectionchange')); 
        }

        // Reset search
        this.searchTerm = '';
        this.searchResults = [];
        
    }

    handleComboboxClick() {
        // Hide combobox immediatly
        if (this.blurTimeout) {
            window.clearTimeout(this.blurTimeout);
        }
        this.hasFocus = false;
    }

    handleFocus() {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.hasFocus = true;
    }

    handleBlur() {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        // Delay hiding combobox so that we can capture selected result
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = window.setTimeout(() => {
                //this.hasFocus = false;
                this.blurTimeout = null;
            },
            300
        );
    }

    handleRemoveSelectedItem(event) {
        const recordId = event.currentTarget.name;
        this.selection = this.selection.filter(item => item.id !== recordId);
        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));
    }

    handleClearSelection() {
        this.selection = [];
        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));
    }

    handleStockReplacementYes() {
        const newSelection = [...this.selection];
        newSelection.push(this.productOfReplacement);
        this.selection = newSelection;
            
        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));

        // Close the popup
        this.displayPopUpProductReplacement = false;
    }

    handleStockReplacementNo() {
        this.displayPopUpProductReplacement = false;
    }
    

// STYLE EXPRESSIONS

    get getContainerClass() {
        let css = 'slds-combobox_container slds-has-inline-listbox ';
        if (this.hasFocus && this.hasResults()) {
            css += 'slds-has-input-focus ';
        }
        if (this.errors.length > 0) {
            css += 'has-custom-error';
        } 
        return css;
    }

    get getDropdownClass() {
        let css = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
        if (this.hasFocus && this.hasResults()) {
            css += 'slds-is-open';
        } else {
            css += 'slds-combobox-lookup';
        }
        return css;
    }

    get getInputClass() {
        let css = 'slds-input slds-combobox__input has-custom-height  '
            + (this.errors.length === 0 ? '' : 'has-custom-error ');
        if (!this.isMultiEntry) {
            css += 'slds-combobox__input-value '
                + (this.hasSelection() ? 'has-custom-border' : '');
        }

        css += ' searchField ';
        
        return css;
    }

    get getComboboxClass() {
        let css = 'slds-combobox__form-element slds-input-has-icon ';
        if (this.isMultiEntry) {
            css += 'slds-input-has-icon_right';
        } else {
            css += (this.hasSelection() ? 'slds-input-has-icon_left-right' : 'slds-input-has-icon_right');
        }
        return css;
    }

    get getSearchIconClass() {
        let css = 'slds-input__icon slds-input__icon_right ';
        if (!this.isMultiEntry) {
            css += (this.hasSelection() ? 'slds-hide' : '');
        }
        return css;
    }

    get getClearSelectionButtonClass() {
        return 'slds-button slds-button_icon slds-input__icon slds-input__icon_right '
            + (this.hasSelection() ? '' : 'slds-hide');
    }

    get getSelectIconName() {
        return this.hasSelection() ? this.selection[0].icon : 'standard:default';
    }

    get getSelectIconClass() {
        return 'slds-combobox__input-entity-icon '
            + (this.hasSelection() ? '' : 'slds-hide');
    }

    get getInputValue() {
        if (this.isMultiEntry) {
            return this.searchTerm;
        }
        return this.hasSelection() ? this.selection[0].title : this.searchTerm;
    }

    get getListboxClass() {
        return 'slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid '
            + (this.scrollAfterNItems ? 'slds-dropdown_length-with-icon-' + this.scrollAfterNItems : '');
    }

    get isInputReadonly() {
        if (this.isMultiEntry) {
            return false;
        }
        return this.hasSelection();
    }

    get isExpanded() {
        return this.hasResults();
    }
}