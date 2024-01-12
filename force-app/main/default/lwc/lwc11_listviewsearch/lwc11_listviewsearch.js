import { LightningElement, api, track, wire } from 'lwc';

/* IMPORT METHODS */
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

/* IMPORT LABELS */
import lbl_TECH_Customer from '@salesforce/label/c.LU_TECH_Contact_Customer';
import lbl_TECH_Team from '@salesforce/label/c.LU_TECH_Contact_Team';
import lbl_search from '@salesforce/label/c.LU_Contat_Search';

export default class Lwc11_listviewsearch extends LightningElement {
    
    /* LABELS */
    labels = {
        lbl_TECH_Customer,
        lbl_TECH_Team,
        lbl_search
    }

    /* VARIABLES */
    @track searchedTerms = "";
    @track _contacts = [];
    @api lcontacts = [];
    typeContact = this.labels.lbl_TECH_Team;

    /* INIT */
    @wire(CurrentPageReference) pageRef; // Required by pubsub
	connectedCallback() {

        // subscribe to events
        registerListener('contactTypeToggle', this.handleEvtContactTypeToggle, this);
        registerListener('contacts', this.handleEvtContacts, this);

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

            // Send the filtered list of data to be displayed
            // const evtonfiltereddata = new CustomEvent('filtereddata', { detail: JSON.stringify(filteredList) } );
            // this.dispatchEvent(evtonfiltereddata);

            fireEvent(this.pageRef, 'filtereddata', JSON.stringify(filteredList) );
        
        } else if (this.searchedTerms != '' || this.searchedTerms != undefined) {
            // Send the initial list of data to be displayed
            // const evtonfiltereddata = new CustomEvent('filtereddata', { detail: JSON.stringify(this.lcontacts) } );
            // this.dispatchEvent(evtonfiltereddata);

            fireEvent(this.pageRef, 'filtereddata', JSON.stringify(this.lcontacts));
        }

        // Send the search terms
        // const evtSendSearchTerm = new CustomEvent('updatesearchterm', { detail: this.searchedTerms } );
        // this.dispatchEvent(evtSendSearchTerm);

        fireEvent(this.pageRef, 'updatesearchterm', this.searchedTerms);
    }
}