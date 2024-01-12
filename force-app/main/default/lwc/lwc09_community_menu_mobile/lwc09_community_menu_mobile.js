import { LightningElement, track } from 'lwc';

import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

import {loadStyle} from 'lightning/platformResourceLoader';

/* IMPORT STATIC RESOURCES */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';
import CssMenuMobile from '@salesforce/resourceUrl/CssMenuMobile';

/* IMPORT APEX */
import getMenuItems from '@salesforce/apex/LWC08_community_header_Ctrl.getMenuItems';

import lbl_TECH_Team from '@salesforce/label/c.LU_TECH_Contact_Team';

export default class Lwc09_community_footer_mobile extends LightningElement {

    /* LABELS */
    labels = {
        lbl_TECH_Team
    }

    nav_burger = LogoBtn + '/icons/nav_burger.png';

    /* VARIABLES */
    @track mainmenu = [];
    @track burgerlinks = [];

    @track searchedTerms = "";
    @track lcontacts = [];
    @track typeContact = this.labels.lbl_TECH_Team;

    @track isContactsPage = false;

    @track hideFooter = false;

    /* INIT */
    connectedCallback() {

        Promise.all([
            loadStyle(this, CssMenuMobile)
        ])

        let parameters = this.getQueryParameters();

        if (parameters.showheader !== undefined && parameters.showheader === "false") {
            this.hideFooter = true;
        }

        //subscribe to events
        registerListener('contactTypeToggle', this.handleEvtContactTypeToggle, this);
        registerListener('contacts', this.handleEvtContacts, this);

        this.isContactsPage = location.href.includes("contacts");

        getMenuItems({ device: 'Mobile' })
        .then(links => {
            console.log('>>>> links');
            console.log(links);
            if (links != null) {
               this.burgerlinks = links.lBurgerItems;
               this.mainmenu = links.lMenuItems;
               this.stanmag = links.stanmag;

                // for(let item of this.mainmenu){
                //     if(!item.textLinkIcon != null){
                //         item.icon = LogoBtn + item.textLinkIcon;
                //     }
                // }
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
        });
    }
	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }
    
    /* EVENTS METHODS */
    handleEvtContactTypeToggle(value) {
        // Change the type of contact displayed
        this.typeContact = value;
    }

    handleEvtContacts(value){
        this.lcontacts = JSON.parse(value.detail);
    }

    //UPDATE VARIABLE FROM INPUT
    updateSearchedTermsVariable(event) {

        this.searchedTerms = event.target.value;

        let filteredList = [];
        let i;

        if (this.searchedTerms && this.lcontacts) {
            
            for (i = 0; i < this.lcontacts.length; i++) { 

                if (this.typeContact === this.labels.lbl_TECH_Team) {
                    if ( (this.lcontacts[i].STHID__c && this.lcontacts[i].STHID__c.toLowerCase().startsWith(this.searchedTerms.toLowerCase()) ) || 
                        ( this.lcontacts[i].FirstName && this.lcontacts[i].FirstName.toLowerCase().includes(this.searchedTerms.toLowerCase()) ) || 
                        ( this.lcontacts[i].LastName && this.lcontacts[i].LastName.toLowerCase().includes(this.searchedTerms.toLowerCase()) ) ){

                            filteredList.push(this.lcontacts[i]);
                    }
                } else {
                    if ( ( this.lcontacts[i].FirstName && this.lcontacts[i].FirstName.toLowerCase().includes(this.searchedTerms.toLowerCase()) ) || 
                        ( this.lcontacts[i].LastName && this.lcontacts[i].LastName.toLowerCase().includes(this.searchedTerms.toLowerCase()) ) ){

                            filteredList.push(this.lcontacts[i]);
                    }
                }
            }

            fireEvent(this.pageRef, 'filtereddata', JSON.stringify(filteredList) );
        
        } else if (this.searchedTerms !== '' || this.searchedTerms !== undefined) {

            fireEvent(this.pageRef, 'filtereddata', { detail: JSON.stringify(this.lcontacts) });
        }

        fireEvent(this.pageRef, 'updatesearchterm', this.searchedTerms);
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