import { LightningElement, track } from 'lwc';

import { registerListener, unregisterAllListeners } from 'c/pubsub';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* APEX METHODS */
import getDealer from '@salesforce/apex/lwc75_wishlist_withoutSharing_ctrl.getDealer';
import getProductWithBundle from '@salesforce/apex/lwc75_wishlist_ctrl.getProductWithBundle';
import createOrder from '@salesforce/apex/lwc75_wishlist_withoutSharing_ctrl.createOrder';

/* LABEL */
import lbl_captcha_text from '@salesforce/label/c.LU_Wishlist_Captcha_Text';
import lbl_wishlist_title from '@salesforce/label/c.LU_Wishlist_Title';
import lbl_product_description from '@salesforce/label/c.LU_Wishlist_Product_Description';
import lbl_quantity from '@salesforce/label/c.LU_Wishlist_Quantity';
import lbl_unit_price from '@salesforce/label/c.LU_Wishlist_Unit_Price';
import lbl_bundle_text from '@salesforce/label/c.LU_Wishlist_Bundle_Text';
import lbl_basket_total from '@salesforce/label/c.LU_Wishlist_Basket_Total';
import lbl_dealer_association from '@salesforce/label/c.LU_Wishlist_Dealer_Association';
import lbl_dealer_placeholder from '@salesforce/label/c.LU_Wishlist_Dealer_Placeholder';
import lbl_search_dealer from '@salesforce/label/c.LU_Wishlist_Search_Dealer';
import lbl_personal_informations from '@salesforce/label/c.LU_Wishlist_Personal_Informations';
import lbl_submit_form from '@salesforce/label/c.LU_Wishlist_Submit_Form';
import lbl_Error_Title from '@salesforce/label/c.LU_Wishlist_Error_Title';
import lbl_Success_Title from '@salesforce/label/c.LU_Wishlist_Success_Title';
import lbl_Error_Dealer_Missing from '@salesforce/label/c.LU_Wishlist_Error_Dealer_Missing';
import lbl_Error_Customer_Missing from '@salesforce/label/c.LU_Wishlist_Error_Customer_Missing';
import lbl_GDPR_Text from '@salesforce/label/c.LU_Wishlist_GDPR_Text';

export default class Lwc75_wishlist extends LightningElement {

    labels = {
        lbl_captcha_text,
        lbl_wishlist_title,
        lbl_product_description,
        lbl_quantity,
        lbl_unit_price,
        lbl_bundle_text,
        lbl_basket_total,
        lbl_dealer_association,
        lbl_dealer_placeholder,
        lbl_search_dealer,
        lbl_personal_informations,
        lbl_submit_form,
        lbl_GDPR_Text
    }

    @track xml;

    @track wList = {};
    @track l_item = [];
    @track total = 0;
    @track totalToDisplay = "";

    @track searchedTerm = "";
    @track l_dealer = []
    @track selectedDealer = {};

    @track displayResults = false;
    @track displaySelected = false;
    @track displayProducts = false;
    @track displayCaptcha = false;
    @track displayPage = false;
    @track isLoading = false;

    connectedCallback(){
        registerListener('captcha_validated', this.handleValidatedCaptcha, this);

        let parameters = this.getQueryParameters();

        if(parameters.source !== undefined && parameters.source !== "" && parameters.source === "ipaper"){
            this.displayPage = true;
        }
        else{
            this.displayCaptcha = true;
        }

        if(parameters.basket !== undefined && parameters.basket !== ""){

            this.xml = parameters.basket.replace(/\n|\r/g,'');

            let regItem = new RegExp('<item>(.*?)</item>', 'g');
            let regQuantity = new RegExp('<amount>(.*?)</amount>');
            let regId = new RegExp('<productid>(.*?)</productid>');
            let regPrice = new RegExp('<price>(.*?)</price>');
            let regName = new RegExp('<name>(.*?)</name>');

            try {
                for(let result of this.xml.match(regItem)) {
                    let item = {};
                    if(regQuantity.test(result)){
                        item.quantity = result.match(regQuantity)[1];
                    }
                    if(regId.test(result)){
                        item.productId = result.match(regId)[1];
                    }
                    if(regPrice.test(result)){
                        item.price = result.match(regPrice)[1];
                    }
                    if(regName.test(result)){
                        item.name = result.match(regName)[1].replace(/\+|\r/g,' ');
                    }
                    item.bundleText = "";
                    this.l_item.push(item);

                    this.total += (item.quantity * item.price);
                }
                this.totalToDisplay = (Math.round(this.total * 100) / 100).toFixed(2);
            }
            catch (error) {
                console.error(error);
            }

            getProductWithBundle({l_item : this.l_item})
            .then(results => {
                this.wList.l_itemWishlist = results;
                this.wList.idDealer = "";
                this.wList.contactFirstName = "";
                this.wList.contactLastName = "";
                this.wList.contactEmail = "";
                this.wList.contactMobile = "";

                this.displayProducts = true;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
        }
    }
    disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }

    sendWishlist() {

        this.isLoading = true;

        if (this.wList.idDealer == null || this.wList.idDealer == "") {
            const evtSuccess = new ShowToastEvent({
                title: lbl_Error_Title,
                message: lbl_Error_Dealer_Missing,
                variant: 'error'
            });
            this.dispatchEvent(evtSuccess);
            this.isLoading = false;
        } else if (this.wList.contactFirstName == "" || this.wList.contactLastName == "" || this.wList.contactEmail == "" || this.wList.contactMobile == "") {
            const evtSuccess = new ShowToastEvent({
                title: lbl_Error_Title,
                message: lbl_Error_Customer_Missing,
                variant: 'error'
            });
            this.dispatchEvent(evtSuccess);
            this.isLoading = false;
        } else {
            console.log(this.wList);
            createOrder({wList : this.wList})
            .then(results => {
                const evtSuccess = new ShowToastEvent({
                    message: lbl_Success_Title,
                    variant: 'success'
                });
                this.dispatchEvent(evtSuccess);
                this.isLoading = false;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
                this.isLoading = false;
            });
        }
    }

    searchDealerEnter(event){
        if(event.keyCode === 13){
            this.searchDealer(event);
        }
    }

    searchDealer(event){
        getDealer({searchedTerm : this.searchedTerm})
        .then(results => {

            console.log(results);

            this.l_dealer = results;
            if(this.l_dealer.length > 0){
                this.displayResults = true;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    handleRemoveSelectedItem() {
        this.selectedDealer = {};
        this.displaySelected = false;
    }

    get getListboxClass() {
        return 'slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid '
            + (this.scrollAfterNItems ? 'slds-dropdown_length-with-icon-' + this.scrollAfterNItems : '');
    }

    handleResultClick(event){
        this.wList.idDealer = event.currentTarget.dataset.id;

        for(let d of this.l_dealer){
            if(d.Id === event.currentTarget.dataset.id){
                this.selectedDealer = d;
            }
        }

        this.displayResults = false;

        this.displaySelected = true;
    }

    handleValidatedCaptcha(){
        this.displayCaptcha = false;
        this.displayPage = true;
    }

    updateSearchedTerms(event){
        this.searchedTerm = event.target.value;
    }
    updateFirstName(event){
        this.wList.contactFirstName = event.target.value;
    }
    updateLastName(event){
        this.wList.contactLastName = event.target.value;
    }
    updateMail(event){
        this.wList.contactEmail = event.target.value;
    }
    updatePhone(event){
        this.wList.contactMobile = event.target.value;
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