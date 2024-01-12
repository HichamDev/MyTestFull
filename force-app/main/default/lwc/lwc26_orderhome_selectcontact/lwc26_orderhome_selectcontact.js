/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';

/* IMPORT METHODS */
import { CurrentPageReference } from 'lightning/navigation'; 
import { fireEvent } from 'c/pubsub';

/* IMPORT APEX METHODS */
import getContactsForList from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getContacts';
//import getMyDealer from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getMyContact';
//import getContactById from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getContactById';
//import getConnectedUser from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getConnectedUser';
import getConnectedUserInformation from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getCurrentUserInformation';

// Import constants
import getConstants from '@salesforce/apex/AppConstants.getAllConstants';

/* IMPORT LABELS */
import lbl_InMyTeam from '@salesforce/label/c.LU_Basket_SelectContact_Team';
import lbl_Title from '@salesforce/label/c.LU_ContactSelection_Modal_Title';
import lbl_Subtitle from '@salesforce/label/c.LU_ContactSelection_Modal_Subtitle';
import lbl_Close from '@salesforce/label/c.LU_ContactSelection_Modal_Close';
import lbl_ForMe from '@salesforce/label/c.LU_Basket_Contact_ForMe';
import lbl_PerMeSC from '@salesforce/label/c.PerMe_SC';
import lbl_PerMeDM from '@salesforce/label/c.PerMe_DM';
import lbl_Button_Gifts from '@salesforce/label/c.LU_Basket_Contact_Gifts';
import lbl_Button_PersonalUse from '@salesforce/label/c.LU_Basket_Contact_Personal_Use';
import lbl_Button_ProfessionalUse from '@salesforce/label/c.LU_Basket_Contact_Professional_Use';
import lbl_Button_Standard from '@salesforce/label/c.LU_Basket_Contact_Standard';

import lbl_TECH_Customer from '@salesforce/label/c.LU_TECH_Contact_Customer';
import lbl_TECH_Team from '@salesforce/label/c.LU_TECH_Contact_Team';
import lbl_Customer from '@salesforce/label/c.LU_Customer_Title';
import lbl_Team from '@salesforce/label/c.LU_Team_Title';
import lbl_search_text from '@salesforce/label/c.LU_ContactSelection_Search_Text';

import lbl_TECH_OfferType_Standard from '@salesforce/label/c.LU_Offer_Type_Standard';
import lbl_TECH_OfferType_PersonalUse from '@salesforce/label/c.LU_Offer_Type_PersonalUse';
import lbl_TECH_OfferType_Gift from '@salesforce/label/c.LU_Offer_Type_Gift';
import lbl_TECH_OfferType_ProfessionalUse from '@salesforce/label/c.LU_Offer_Type_ProfessionalUse';

import lbl_Display_New_Contact_Button from '@salesforce/label/c.LU_Contact_DisplayContactButton';

export default class lwc26_orderhome_selectcontact extends LightningElement {
    rebate_job_title = 'Stanlover';

    /* LABELS */
    labels = {
        lbl_InMyTeam,
        lbl_Button_Gifts,
        lbl_Button_Standard,
        lbl_Button_PersonalUse,
        lbl_Button_ProfessionalUse,
        lbl_Title,
        lbl_Subtitle,
        lbl_Close,
        lbl_ForMe,
        lbl_PerMeSC,
        lbl_PerMeDM,
        lbl_TECH_Customer,
        lbl_Customer,
        lbl_TECH_Team,
        lbl_Team,
        lbl_search_text,
        lbl_Display_New_Contact_Button
    }
    
    /* CONST */
    ITA_TitleOrderOnlyForThem = ['Smile',this.rebate_job_title];
    ITA_TitleOrderOnlyForCustomers = 'Incaricata,Incaricata con gruppo,Sales Consultant, Group Sales Consultant';
    FRA_TitleOrderOnlyForCustomers = 'Conseillère, Animatrice, Animatrice de Secteur';
    ITA_TitleOrderOnlyForTeamMember = 'Direttore di Regione, Direttore di Filiale, Direttore di Zona, Star Leader, Sales Area';
    FRA_ProfileNameCanOrderOnBehalf = 'FRA_Customer Service';
    ITA_TitleSalesConsultant = ''; //récupéré dans le @wire(getConstants) 
    ITA_TitleGroupSalesConsultant = ''; //récupéré dans le @wire(getConstants) 


    /* VARIABLES */
    @track contacts = [];
    @track filteredList = [];
    @track switchValue = false;
    @track typeContact = this.labels.lbl_Customer; // Customer by default
    @track isloading = true;
    @track isManager = false;

    @track currentContact = null;
    @track currentUser = null;
    @track rightToOrderOnBehalf = false;
    @track isFRA = false;    
    @track isITA = false;
    @track isITAOnlyCustomerUser = false;
    @track isFRAOnlyCustomerUser = false;
    @track isITAOnlyTeamMemberUser = false;
    @track displayContactSelection = false;
    @track teamMemberSelected = null;
    @track displayNewContactButton = false;

    @track displaySwitch = false;
    @track userProfile;
    @track isCustomerView = false;
    @track isSmile = false;
    @track isDM = false;
    @track isConsultant = false;

    searchTerm = '';
    valueMyTeam = this.labels.lbl_TECH_Team; //'My Team';
    valueEndCustomers = this.labels.lbl_TECH_Customer; //'End Customers';

    @api idContactSelected = "";


    /* INIT */
    // WIRE METHODS
    @wire(CurrentPageReference) pageRef;
    @wire(getConstants) 
    connectedCallback() {
        
        if(this.labels.lbl_Display_New_Contact_Button === "true"){
            this.displayNewContactButton = true;
        }

        this.retrieveContactInfo();
        // this.getConstants();
        getConstants ()
        .then (data => {
            this.ITA_TitleSalesConsultant = data.ITA_TITLE_SALESCONSULTANT; 
            this.ITA_TitleGroupSalesConsultant = data.ITA_TITLE_GROUPSALESCONSULTANT; 
        }) 
    }
    
    
    retrieveContactInfo() {
        console.log('in lwc26_orderhome_selectcontact - retreive contact');
        // Get the contact connected information / rights
        getConnectedUserInformation()
        .then(dealerInfo => {

            if (dealerInfo) {
                console.log(dealerInfo);
                this.currentContact = dealerInfo.connectedContact;
                this.currentUser = dealerInfo.connectedUser;
                this.rightToOrderOnBehalf = dealerInfo.hasTheRightToOrderOnBehalfOf;

                // Get the country of the contact
                if (this.currentContact.AccountCountryCode__c === 'FRA'){
                    this.isFRA = true;
                } else {
                    this.isITA = true;
                }
                
                // Get if the user is a manager
                if (this.currentContact.LU_Is_Manager__c) {
                    this.isManager = true;
                }

                
                this.isConsultant = (this.currentContact.Title == this.ITA_TitleSalesConsultant || this.currentContact.Title == this.ITA_TitleGroupSalesConsultant);
                this.isDM = (this.currentContact.Title == 'Division Manager');

                // Default contact list displayed
                if (this.isITA && this.ITA_TitleOrderOnlyForCustomers.includes(this.currentContact.Title)) {
                    this.typeContact = this.valueEndCustomers;
                    this.isITAOnlyCustomerUser = true;
                    this.isCustomerView = true;
                    if(this.currentContact.Title != 'Smile' && this.currentContact.Title != this.rebate_job_title) {
                        fireEvent(null, 'catalogChange', lbl_TECH_OfferType_Standard);
                    } else {
                        fireEvent(null, 'catalogChange', lbl_TECH_OfferType_PersonalUse);
                    }
                } 
                if (this.isITA && this.ITA_TitleOrderOnlyForTeamMember.includes(this.currentContact.Title)) {
                    this.typeContact = this.valueMyTeam;
                    this.isITAOnlyTeamMemberUser = true;
                    this.isCustomerView = false;
                    fireEvent(null, 'catalogChange', lbl_TECH_OfferType_PersonalUse);
                } 
                if (this.isITA && this.ITA_TitleOrderOnlyForThem.includes(this.currentContact.Title)) {
                    // done in c/lwc26_orderhome_contact to do not open pop up then close it
                    /* if(this.currentContact.Title != 'Smile') {
                        fireEvent(null, 'catalogChange', lbl_TECH_OfferType_Standard);
                    } else {
                        fireEvent(null, 'catalogChange', lbl_TECH_OfferType_PersonalUse);
                    }
                    this.dispatchEvent(new CustomEvent('closecontactselection')); */
                }
                if (this.isFRA && this.FRA_TitleOrderOnlyForCustomers.includes(this.currentContact.Title)) {
                    this.typeContact = this.valueEndCustomers;
                    this.isFRAOnlyCustomerUser = true;
                    this.isCustomerView = true;
                }
                if (this.hasTheRightToOrderOnBehalfOf) {
                    this.typeContact = this.valueMyTeam;
                }
                if (this.currentContact.Title != 'Smile' && this.currentContact.Title != this.rebate_job_title) {
                    this.displayContactSelection = true;
                }

                // Retreive contacts to be displayed : either team member or customers
                this.retrieveContacts();
            }
        })
        .catch (error => {
            console.error(error);
            this.isloading = false;
        });

    }

    /* EVENTS METHODS */
    handleClose(event) {


        if (this.isITA) {
            if (this.ITA_TitleOrderOnlyForTeamMember.includes(this.currentContact.Title)) {
                fireEvent(null, 'catalogChange', lbl_TECH_OfferType_PersonalUse);
            }  else {
                fireEvent(null, 'catalogChange', lbl_TECH_OfferType_Standard);
                fireEvent(null, 'orderHomeContactSelected', ({ contact :  null}));
            }
            
            this.dispatchEvent(new CustomEvent('closecontactselection'));
        } else {
            if (event.detail !== undefined) {
                fireEvent(null, 'orderHomeContactSelected', ({ contact :  this.currentContact}));
            }
            this.dispatchEvent(new CustomEvent('closecontactselection'));
        }

    }

    handleSearch(event) {

        this.searchTerm = event.target.value;

        if (this.searchTerm && this.contacts) {
            
            this.filteredList = [];

            for (let i = 0; i < this.contacts.length; i++) { 

                if (this.typeContact === this.valueMyTeam) {
                    if ( (this.contacts[i].STHID__c && this.contacts[i].STHID__c.toLowerCase().startsWith(this.searchTerm.toLowerCase()) ) || 
                        ( this.contacts[i].FirstName && this.contacts[i].FirstName.toLowerCase().includes(this.searchTerm.toLowerCase()) ) || 
                        ( this.contacts[i].LastName && this.contacts[i].LastName.toLowerCase().includes(this.searchTerm.toLowerCase()) ) ){

                            this.filteredList.push(this.contacts[i]);
                    }
                } else {
                    if ( ( this.contacts[i].FirstName && this.contacts[i].FirstName.toLowerCase().includes(this.searchTerm.toLowerCase()) ) || 
                        ( this.contacts[i].LastName && this.contacts[i].LastName.toLowerCase().includes(this.searchTerm.toLowerCase()) ) ){

                            this.filteredList.push(this.contacts[i]);
                    }
                }

            }

        } else {
            this.filteredList = this.contacts;
        }

        for (let i = 0; i < this.filteredList.length; i++) { 
            if (this.filteredList[i].MobilePhone) {
                this.filteredList[i].clickToCall = 'tel:' + this.filteredList[i].MobilePhone;
            }
        }
    }

    handleSelectContactItem(event) {

        let con;
        for (let i = 0 ; i < this.contacts.length ; i++) {
            if (this.contacts[i].Id === event.currentTarget.dataset.id) {
                con = this.contacts[i]; break;
            }
        }

        if (this.isITA && this.isITAOnlyCustomerUser) {
            fireEvent(null, 'orderHomeContactSelected', ({ contact :  con}));
            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_Standard);
        }

        if (this.isITA && this.isITAOnlyTeamMemberUser) {
            this.teamMemberSelected = con;
            this.isSmile = (this.teamMemberSelected.Title == 'Smile' || this.teamMemberSelected.Title == this.rebate_job_title);
            console.log('is contact selected smile ? - ' + this.isSmile);
        }

        if (this.isFRA && this.isFRAOnlyCustomerUser) {
            fireEvent(null, 'orderHomeContactSelected', ({ contact :  con}));
            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_Standard);
        }
                
    }

    handleClickForMe(event) {

        // Send event for catalog choice
        if (this.isITA) {
            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_PersonalUse);
        }

        // Send event for selection of the connected contact
        fireEvent(null, 'orderHomeContactSelected', ({ contact :  this.currentContact}));
    }

    handleClickTeamMemberPersonalUse(event) {
        // Send event for catalog choice
        if (this.isITA) {
            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_PersonalUse);
        }

        // Send event for selection of the connected contact
        fireEvent(null, 'orderHomeContactSelected', ({ contact :  this.teamMemberSelected}));
    }

    handleClickTeamMemberProduct(event) {
        // Send event for catalog choice
        if (this.isITA) {
            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_Standard);
        }

        // Send event for selection of the connected contact
        fireEvent(null, 'orderHomeContactSelected', ({ contact :  this.teamMemberSelected}));
    }

    handleClickGifts(event) {
        
        // Send event for catalog choice
        if (this.isITA) {
            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_Gift);
        }

        // Send event for selection of no contact
        fireEvent(null, 'orderHomeContactSelected', ({ contact : this.currentContact }));
        // this.dispatchEvent(new CustomEvent('closecontactselection'));
    }

    handleClickTeamMemberGifts(event) {
        // Send event for catalog choice
        if (this.isITA) {
            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_Gift);
        }

        // Send event for selection of no contact
        fireEvent(null, 'orderHomeContactSelected', ({ contact : this.teamMemberSelected }));
    }

    
    handleClickProfesisonalUse(event) {
        
        // Send event for catalog choice
        if (this.isITA) {
            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_ProfessionalUse);
        }

        // Send event for selection of no contact
        fireEvent(null, 'orderHomeContactSelected', ({ contact : this.currentContact }));
        // this.dispatchEvent(new CustomEvent('closecontactselection'));
    }

    handleClickTeamMemberProfesisonalUse(event) {
        // Send event for catalog choice
        if (this.isITA) {
            fireEvent(null, 'catalogChange', lbl_TECH_OfferType_ProfessionalUse);
        }

        // Send event for selection of no contact
        fireEvent(null, 'orderHomeContactSelected', ({ contact : this.teamMemberSelected }));
    }

    handleToggleSwitch(event) {

        if (this.switchValue == true) {
            this.typeContact = this.labels.lbl_Customer;
            this.switchValue = false;
        } else {
            this.switchValue = true;
            this.typeContact = this.labels.lbl_Team;
        }

        this.retrieveContacts();
    }


    /* BUSINESS METHODS */
    retrieveContacts() {

        this.isloading = true;

        // Get the contacts to be displayed
        getContactsForList( { type : this.typeContact } )
        .then (results => {
            console.log('Nombre de résultat : ' + results.length);
            this.contacts = results;
            this.filteredList = results;
            this.isloading = false;

            for (let i = 0; i < this.filteredList.length; i++) { 
                if (this.filteredList[i].MobilePhone) {
                    this.filteredList[i].clickToCall = 'tel:' + this.filteredList[i].MobilePhone;
                }
            }
        })
        .catch (error => {
            console.log('>>>> error :');
            console.error(error);
            this.isloading = false;
        });

    }

}