/* eslint-disable dot-notation */
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';

/* IMPORT METHODS */
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

/* IMPORT LABELS */
import lbl_ContactNotSelected from '@salesforce/label/c.LU_Basket_ContactNotSelected';
import lbl_ContactNotSelectedNickname from '@salesforce/label/c.LU_Basket_ContactNotSelected_Nickname';
import lbl_ContactChange from '@salesforce/label/c.LU_Basket_Contact_Change';
import lbl_NoContactBasket from '@salesforce/label/c.LU_Basket_Contact_NoContactBasket';
import lbl_CatalogSelected from '@salesforce/label/c.LU_Basket_Contact_Catalog_Selected';
import lbl_TECH_OfferType_Standard from '@salesforce/label/c.LU_Offer_Type_Standard';
import lbl_TECH_OfferType_PersonalUse from '@salesforce/label/c.LU_Offer_Type_PersonalUse';
import lbl_TECH_OfferType_Gift from '@salesforce/label/c.LU_Offer_Type_Gift';
import lbl_TECH_OfferType_ProfessionalUse from '@salesforce/label/c.LU_Offer_Type_ProfessionalUse';

/* IMPORT APEX METHODS */
import getContactById from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getContactById';
import getUserCountry from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getUserCountry';
import getCurrentContact from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getMyContact';
import getUserContactTitle from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getUserContactTitle';
import lbl_defaultProfilePicUrl from '@salesforce/label/c.LU_Default_Profile_Pics_Url';
import getCurrentDraftOrderNb from '@salesforce/apex/lwc61_orerhome_nbarticles_ctrl.getArticleInCurrentDraftOrder';
import getCurrentUserInformation from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getCurrentUserInformation';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

export default class Lwc26_orderhome_contact extends LightningElement {
    rebate_job_title = 'Stanlover';
    

    @track profilePhoto = LogoBtn + '/icons/pictures-user.png';
    switchClient = LogoBtn + '/icons/icon-changeClient.svg';
    icon_catalog = LogoBtn + '/icons/icon_catalog.svg';
    
    /* LABELS */
    labels = {
        lbl_ContactNotSelected,
        lbl_ContactNotSelectedNickname,
        lbl_ContactChange,
        lbl_NoContactBasket,
        lbl_CatalogSelected,
        lbl_defaultProfilePicUrl
    }

    /* VARIABLES */
    @track contact;
    @track openSelection = false;
    @track noContactBasket = false;
    @track amount = 0;
    @track parameters;
    @track contactIdPreselected;
    @track catalogChoosed = '';
    @track displayCatalogChoose = false;
    @track isPushOfferOpened = false;
    @track displayButtonChangeContact = false;
    @track isITA = false;
    @track isFRA = false;
    @track isSmile = false;
    @track orderIdFromUrl;
    @track hasTheRightToOrderOnBehalfOf;
    @track isShowPaymentWarning = false;

    /* INIT */
    @wire(CurrentPageReference) pageRef; // Required by pubsub
    connectedCallback() {
        
        // EVENT : Subscribe to contact selection on the popup
        registerListener('orderHomeContactSelected', this.handleContactSelection, this);
        // EVENT : Subscribe to update of basket value
        registerListener('updatePurchaseAmount', this.handleChangeBasketAmount, this);
        // EVENT : catalog changes
        registerListener('catalogChange', this.handleCatalogChange, this);
        // EVENT : Subscribe to contact popup open request
        registerListener('orderHomeContactSelectionToBeOpened', this.handleClickChange, this);

        this.catalogChoosed = lbl_TECH_OfferType_Standard;

        /* CASE OF A CONTACT IN URL PARAMETER */
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

        console.log('xxxxx URL PARAMS xxxxx' , this.parameters);
        
        getCurrentUserInformation()
        .then(result => {
            this.hasTheRightToOrderOnBehalfOf = result.hasTheRightToOrderOnBehalfOf;
        })
        .catch(error => {
            console.log(">>>error");
            console.log(error);
        });


        getUserContactTitle()
            .then(result => {
                console.log('##################################lwc26')
                console.log(result);
                console.log(this.rebate_job_title);
                if(result !== "Smile" && result !== this.rebate_job_title){
                    console.log('Is not smile');
                    this.displayButtonChangeContact = true;
                } else {
                    console.log('Is not smile');
                    this.isSmile = true;
                }
            })
            .catch(error => {
                console.log(">>>error");
                console.log(error);
            });

        if (this.contactIdPreselected) {

            getContactById({ idContact: this.contactIdPreselected })

                .then(result => {
                    this.contact = result;
                    fireEvent(null, 'orderHomeContactSelected', ({ contact :  this.contact}));
                    if(this.contact.LU_TECH_ProfilePicture__c === null){
                        this.contact.LU_TECH_ProfilePicture__c = this.labels.lbl_defaultProfilePicUrl;
                    }
                    /* if (this.contact.AccountCountryCode__c === 'ITA'){
                        this.displayCatalogChoose = true;
                        // this.handleClickChange();
                    } */

                    getCurrentDraftOrderNb( { contactId : this.contact.Id, orderId : this.orderIdFromUrl } )
                    .then(vOrder => {
                        console.log('xxxxxxxxxxxx getCurrentDraftOrderNb xxxxxxxxxx')
                        console.log(vOrder)
                                                
                        if(vOrder != null){

                            const selectedEvent = new CustomEvent('ordertype', { detail: vOrder.Type });
                            this.dispatchEvent(selectedEvent);

                            if(vOrder.Type === 'B2B2C'){
                                this.displayButtonChangeContact = false;
                            }
                        }
                    })
                    .catch(error => {
                        console.log('>>>> error lwc61_orderhome_nbarticles :');
                        console.error(error);
                    }
                );
                })
                .catch(error => {
                    console.log(">>>error");
                    console.log(error);
                });

            getCurrentContact()
                .then(currentContact => {
    
                    // If Italy, then open the selection popup automatically 
                    if (currentContact.AccountCountryCode__c === 'ITA' ){
                        this.displayCatalogChoose = true;
                        if ((this.isPushOfferOpened == false && this.contact.Id == currentContact.Id) || currentContact.Title === "Smile" || currentContact.Title === this.rebate_job_title) {
                            console.log('for me');
                            this.handleCatalogChange(lbl_TECH_OfferType_PersonalUse);
                            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_PersonalUse);
                        } else {
                            console.log('not for me');
                            this.handleCatalogChange(lbl_TECH_OfferType_Standard);
                            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_Standard);
                        }
                        
                    }
    
                })
                .catch(error => {
                    console.log('>>>> error lwc26_orderhome_contact:');
                    console.log(error);
                });

        } else { /* CASE OF NO CONTACT IN URL PARAMETER */
            
            getCurrentContact()
            .then(currentContact => {
                
                this.contact = currentContact;
                
                // Send event for selection of the connected contact
                fireEvent(null, 'orderHomeContactSelected', ({ contact :  this.contact}));

                // If Italy, then open the selection popup automatically 
                if (currentContact.AccountCountryCode__c === 'ITA' ){
                    this.displayCatalogChoose = true;
                    if (this.isPushOfferOpened == false) {
                        if(this.isSmile == true) {
                            console.log('is smile catalogChange')
                            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_PersonalUse);
                        } else {
                            this.handleClickChange();
                        }
                    }
                    
                }

            })
            .catch(error => {
                console.log('>>>> error lwc26_orderhome_contact:');
                console.log(error);
            });
        }

        getUserCountry()
            .then(result => {
                if(result === "ITA"){
                    this.isITA = true;
                }
                else if(result === "FRA"){
                    this.isFRA = true;
                }
            })
            .catch(error => {
                console.log(">>>error");
                console.log(error);
            });


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

    /* EVENTS HANDLER */
    // Open the contact selection popup
    handleClickChange(event) {
        if(this.contact.Title !== "Smile" && this.contact.Title !== this.rebate_job_title ){
            this.openSelection = true;
        }
    }

    // Close the contact selection popup
    handleCloseContactSelection(event) {
        this.openSelection = false;
    }

    // Change the contact selected displayed
    handleContactSelection(value) {

        this.noContactBasket = false;

        // Retrieve the contact selected
        this.contact = value.contact;
        if (this.contact) {
            if(this.contact.LocalAttribute4__c) {
                this.isShowPaymentWarning = true;
            } else {
                this.isShowPaymentWarning = false;
            }
            if (this.contact.LU_TECH_ProfilePicture__c === undefined || this.contact.LU_TECH_ProfilePicture__c === null || this.contact.LU_TECH_ProfilePicture__c === "") {
                this.contact.LU_TECH_ProfilePicture__c = this.labels.lbl_defaultProfilePicUrl;
                console.log(this.labels.lbl_defaultProfilePicUrl);
            }
        } else {
            this.noContactBasket = true;
        }

        // Close the selection popup
        this.openSelection = false;
    }

    // Change the value of the basket
    handleChangeBasketAmount(value) {
        this.amount = value;
    }

    // Get catalog selected
    handleCatalogChange(value) {
        this.catalogChoosed = value;
        console.log('>>>>> this.catalogChoosed');
        console.log(this.catalogChoosed);
        if (this.catalogChoosed == lbl_TECH_OfferType_PersonalUse) {
            this.catalogChoosed = lbl_TECH_OfferType_PersonalUse + ', ' + lbl_TECH_OfferType_ProfessionalUse + ', ' + lbl_TECH_OfferType_Gift;
        }
        console.log(this.catalogChoosed);
    }
}